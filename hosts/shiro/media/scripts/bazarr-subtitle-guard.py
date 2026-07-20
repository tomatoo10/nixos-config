#!/usr/bin/env python3
"""Validate Bazarr sidecar subtitles and quarantine obviously bad sync results.

This is intentionally conservative: it only rewrites a subtitle when ffsubsync
produces a clearly sane result without dropping many cues. Otherwise it moves
the bad sidecar out of Plex/Bazarr's normal sidecar path so Bazarr can search
again instead of leaving a wildly mistimed subtitle in the library.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path


VIDEO_EXTENSIONS = (".mkv", ".mp4", ".m4v", ".avi", ".mov", ".webm")
SIDEcar_TOKENS = {
    "ar",
    "ara",
    "br",
    "de",
    "eng",
    "en",
    "es",
    "forced",
    "fr",
    "fre",
    "ger",
    "hi",
    "ita",
    "it",
    "por",
    "pt",
    "pt-br",
    "sdh",
    "spa",
}
TIMESTAMP_RE = re.compile(
    r"(\d\d):(\d\d):(\d\d),(\d\d\d)\s+-->\s+"
    r"(\d\d):(\d\d):(\d\d),(\d\d\d)"
)
ASS_DIALOGUE_RE = re.compile(r"^Dialogue:[^,]*,(\d+:\d\d:\d\d\.\d\d),(\d+:\d\d:\d\d\.\d\d),", re.MULTILINE)


def log(level: str, message: str) -> None:
    print(f"bazarr-subtitle-guard[{level}]: {message}")


def seconds(parts: tuple[str, ...]) -> float:
    hours, minutes, secs, millis = parts
    return int(hours) * 3600 + int(minutes) * 60 + int(secs) + int(millis) / 1000


def ass_seconds(value: str) -> float:
    hours, minutes, rest = value.split(":")
    return int(hours) * 3600 + int(minutes) * 60 + float(rest)


def subtitle_summary(path: Path) -> dict[str, float | int]:
    starts: list[float] = []
    ends: list[float] = []
    text = path.read_text(errors="replace")
    if path.suffix.lower() in {".ass", ".ssa"}:
        for match in ASS_DIALOGUE_RE.finditer(text):
            starts.append(ass_seconds(match.group(1)))
            ends.append(ass_seconds(match.group(2)))
    else:
        for match in TIMESTAMP_RE.finditer(text):
            starts.append(seconds(match.groups()[0:4]))
            ends.append(seconds(match.groups()[4:8]))
    return {
        "cues": len(starts),
        "first": starts[0] if starts else -1,
        "last": ends[-1] if ends else -1,
    }


def candidate_video_stems(subtitle: Path) -> list[str]:
    stem = subtitle.stem
    stems = [stem]
    parts = stem.split(".")
    while len(parts) > 1 and parts[-1].lower() in SIDEcar_TOKENS:
        parts = parts[:-1]
        stems.append(".".join(parts))
    return stems


def infer_video(subtitle: Path) -> Path | None:
    for stem in candidate_video_stems(subtitle):
        for candidate in subtitle.parent.iterdir():
            if candidate.is_file() and candidate.suffix.lower() in VIDEO_EXTENSIONS and candidate.stem == stem:
                return candidate

    # Fallback for unusual language suffixes: pick the longest video stem that
    # prefixes the subtitle stem. This still avoids cross-episode matches.
    videos = [p for p in subtitle.parent.iterdir() if p.is_file() and p.suffix.lower() in VIDEO_EXTENSIONS]
    matches = [p for p in videos if subtitle.stem.startswith(p.stem + ".")]
    return max(matches, key=lambda p: len(p.stem), default=None)


def ffprobe(video: Path) -> dict:
    output = subprocess.check_output(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration:stream=index,codec_type:stream_tags=language,title",
            "-of",
            "json",
            str(video),
        ],
        text=True,
    )
    return json.loads(output)


def duration_seconds(probe: dict) -> float:
    return float(probe.get("format", {}).get("duration") or 0)


def reference_audio_stream(video: Path, probe: dict) -> str:
    audio_streams = [s for s in probe.get("streams", []) if s.get("codec_type") == "audio"]
    if not audio_streams:
        return "0:a:0"

    # For anime and Japanese media, syncing dialogue subtitles to a dub track is
    # the common failure mode. Prefer Japanese/original audio when present.
    for audio_position, stream in enumerate(audio_streams):
        tags = stream.get("tags", {}) or {}
        language = str(tags.get("language", "")).lower()
        title = str(tags.get("title", "")).lower()
        if language in {"ja", "jpn", "japanese"} or "japanese" in title:
            return f"0:a:{audio_position}"

    return "0:a:0"


def is_impossible(summary: dict[str, float | int], video_duration: float) -> bool:
    if summary["cues"] == 0 or video_duration <= 0:
        return False
    return bool(summary["last"] > video_duration + 60)


def preserve_copy(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def unique_path(directory: Path, subtitle: Path, suffix: str) -> Path:
    stamp = time.strftime("%Y%m%d-%H%M%S")
    return directory / f"{subtitle.name}.{stamp}.{suffix}"


def try_repair(subtitle: Path, video: Path, reference: str, original: dict[str, float | int], video_duration: float) -> Path | None:
    # Avoid converting styled anime ASS/SSA to flat SRT automatically. If an ASS
    # sidecar is impossible, quarantine it and let Bazarr search again.
    if subtitle.suffix.lower() != ".srt":
        return None

    tmp = subtitle.with_name(f".{subtitle.name}.guard.tmp.srt")
    try:
        subprocess.run(
            [
                "ffsubsync",
                str(video),
                "-i",
                str(subtitle),
                "-o",
                str(tmp),
                "--reference-stream",
                reference,
                "--max-offset-seconds",
                "900",
            ],
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=240,
        )
        if not tmp.exists() or tmp.stat().st_size < 1000:
            return None
        candidate = subtitle_summary(tmp)
        if is_impossible(candidate, video_duration):
            return None
        if candidate["cues"] < int(original["cues"] * 0.90):
            return None
        return tmp
    except Exception as exc:  # noqa: BLE001 - this is a guard, not a hard dependency.
        log("WARN", f"ffsubsync repair failed for {subtitle}: {exc}")
        return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("subtitle_arg", nargs="?", help="Downloaded subtitle path from Bazarr, e.g. {{subtitles}}")
    parser.add_argument("video_arg", nargs="?", help="Optional matching video path")
    parser.add_argument("--subtitle", dest="subtitle_opt")
    parser.add_argument("--video", dest="video_opt")
    args = parser.parse_args()

    subtitle_value = args.subtitle_opt or args.subtitle_arg
    if not subtitle_value:
        log("WARN", "no subtitle path argument was provided")
        return 0

    subtitle = Path(subtitle_value).expanduser()
    if not subtitle.exists():
        log("WARN", f"subtitle does not exist: {subtitle}")
        return 0

    video_value = args.video_opt or args.video_arg
    video = Path(video_value).expanduser() if video_value else infer_video(subtitle)
    if not video or not video.exists():
        log("WARN", f"could not infer matching video for {subtitle}")
        return 0

    probe = ffprobe(video)
    video_duration = duration_seconds(probe)
    summary = subtitle_summary(subtitle)
    if not is_impossible(summary, video_duration):
        log("OK", f"{subtitle.name}: cues={summary['cues']} last={summary['last']:.3f}s video={video_duration:.3f}s")
        return 0

    backups = subtitle.parent / ".subtitle-guard-backups"
    quarantine = subtitle.parent / ".subtitle-guard-quarantine"
    backup_path = unique_path(backups, subtitle, f"original{subtitle.suffix.lower() or '.sub'}")
    preserve_copy(subtitle, backup_path)

    reference = reference_audio_stream(video, probe)
    repaired = try_repair(subtitle, video, reference, summary, video_duration)
    if repaired is not None:
        shutil.copyfile(repaired, subtitle)
        repaired.unlink(missing_ok=True)
        log("FIXED", f"{subtitle.name}: repaired using {reference}; original backed up to {backup_path}")
        return 0

    bad_path = unique_path(quarantine, subtitle, "bad-sync")
    bad_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(subtitle), str(bad_path))
    log(
        "QUARANTINED",
        f"{subtitle.name}: impossible timing cues={summary['cues']} last={summary['last']:.3f}s "
        f"video={video_duration:.3f}s; original backed up to {backup_path}; moved to {bad_path}",
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
