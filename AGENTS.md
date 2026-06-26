# Home-Server Migration Plan & Agent Guide

## Current State

The active homeserver host is `hosts/shiro/`. Older server material and imported configs are **reference material to cherry-pick from**, not working configs to inherit wholesale.

NO HACKS. The user is EXTREMELY concerned about code quality, much more so than immediate results. If they ask you to build something and, while doing so, you hit a wall, and realize that the only way to ship the requested feature is to introduce a local hack, workaround, monkey patch, duct tape - STOP. STOP IMMEDIATELY. Either fix the underlying flaw that blocked you in a ROBUST, WELL DESIGNED, PRODUCTION READY manner, or be honest that the prompt can't be completed without hacks.

To make it very clear:

- DO NOT INTRODUCE HACKS IN THE CODEBASE.
- DO NOT COMMIT CODE THAT COULD BREAK THINGS LATER.
- DO NOT COMMIT PARTIAL SOLUTIONS OR WORKAROUNDS.

THIS IS VERY IMPORTANT.
THIS IS VERY IMPORTANT.
THIS IS VERY IMPORTANT.

The author appreciates honestly and he WILL be glad and thankful if you respond a request with "I couldn't complete your request because the repository lacked support for X". He will be even happier if you go ahead and update the repo to provide the necessary support in a well designed, robust way. But he will be VERY ANGRY if, while attempting to implement a feature, you introduce a workaround that will potentially break things later.

NEVER introduce hacks in the codebase.

Also assume that none of the code you're working in is in production, so, backwards compatibility is NOT IMPORTANT. If you find something that is poorly designed and fixing it would require breaking existing APIs or behavior, DO SO. Do it properly rather than preserving a flawed design. Prioritize clarity, correctness, and maintainability over compatibility with existing code.

Core values:

- ABSOLUTE code quality over speed of delivery.
- Correctness over convenience.
- Clarity over cleverness.
- Maintainability over short-term productivity.
- Robust design over quick fixes.
- Simplicity over complexity.
- Doing it right over doing it now.
- Honesty above everything.

After every change you make, provide a clear, honest report on ANY change that you are not confident about and that could be considered a fragile hack.

### shiro media stack contract

The active media stack is native Radarr/Sonarr/Prowlarr/qBittorrent/Plex plus a Cleanuparr container. Keep these apps consistent with this contract when changing paths, categories, tags, or cleanup rules.

Filesystem layout:

- Shared data root: `/srv/data`
- Final media libraries:
  - Movies: `/srv/data/media/movies`
  - TV: `/srv/data/media/tv`
  - Anime: `/srv/data/media/anime`
- qBittorrent download root: `/srv/data/torrents`
- qBittorrent incomplete path: `/srv/data/torrents/incomplete`
- Active qBittorrent category paths:
  - `movies` -> `/srv/data/torrents/movies`
  - `tv` -> `/srv/data/torrents/tv`
  - `animes` -> `/srv/data/torrents/animes`
  - `unlinked` -> `/srv/data/torrents/unlinked`
- Do **not** use the singular torrent category/path `anime`; the active category is `animes`.
- Radarr/Sonarr root folders should point at final media library folders, not `/srv/data` and not torrent folders. This follows TRaSH Guides' separation of download folders from media libraries.

Radarr:

- Root folder: `/srv/data/media/movies`
- Download client: qBittorrent at `localhost:8080`
- qBittorrent category: `movies`
- Radarr download-client tags: none
- Recyclarr profiles:
  - `Movies - 1080p Remux`
  - `Movies - 4K Test`

Sonarr:

- Root folders:
  - TV: `/srv/data/media/tv`
  - Anime: `/srv/data/media/anime`
- Recyclarr profiles:
  - `Series - 1080p Remux`
  - `Anime - 1080p Remux`
- Sonarr tags used for download-client routing:
  - `tv`
  - `anime`
- Download clients:
  - `qBittorrent - TV`: category `tv`, restricted to Sonarr tag `tv`
  - `qBittorrent - Animes`: category `animes`, restricted to Sonarr tag `anime`
- When adding a normal TV show, use root folder `/srv/data/media/tv`, profile `Series - 1080p Remux`, and tag `tv`.
- When adding an anime show, use root folder `/srv/data/media/anime`, profile `Anime - 1080p Remux`, and tag `anime`.
- If a Sonarr series is missing the expected tag, it may have no eligible download client or may route incorrectly after future changes; check tags when troubleshooting grabs.

Prowlarr and Byparr:

- Prowlarr is the source of truth for indexers; avoid manually duplicating Prowlarr-managed indexers in Radarr/Sonarr.
- App links use localhost URLs on shiro:
  - Prowlarr server URL: `http://localhost:9696`
  - Radarr app URL: `http://localhost:7878`
  - Sonarr app URL: `http://localhost:8989`
- Byparr is the only configured Cloudflare/DDoS-GUARD solver service:
  - Container: `byparr`
  - Image: `ghcr.io/thephaseless/byparr:latest`
  - URL for Prowlarr: `http://localhost:8191`
  - Bind: `127.0.0.1:8191:8191`, so it is local-only.
- App sync level should be `fullSync` for both Radarr and Sonarr.
- Prowlarr app tags are currently empty; do not confuse them with Sonarr download-client routing tags.
- Radarr sync categories are movie categories (`2000` family).
- Sonarr sync categories are TV categories (`5000` family), with anime sync category `5070`.
- Prowlarr Byparr proxy is Prowlarr state: add it under Settings -> Indexers -> Indexer Proxies -> FlareSolverr with host `http://localhost:8191`. Use a proxy tag such as `byparr` and add the same tag only to indexers that need Cloudflare/DDoS-GUARD solving.
- Indexers themselves are Prowlarr DB/API state. They may require credentials/cookies and should not be committed. Use Prowlarr WebUI or a future API provisioning script; keep Prowlarr as the only place where indexers are manually managed.

Cleanuparr:

- Container mounts `/srv/data/torrents` as `/downloads`.
- Download directory mapping:
  - Source: `/srv/data/torrents`
  - Target: `/downloads`
- Arr instance URLs should point to shiro services:
  - Radarr: `http://192.168.18.7:7878`
  - Sonarr: `http://192.168.18.7:8989`
- qBittorrent WebUI auth bypass must include Podman's bridge subnet `10.88.0.0/16`, because Cleanuparr reaches qBittorrent from its container IP, not from `192.168.18.7` or `127.0.0.1`.
- Cleanuparr category-aware rules should use `movies`, `tv`, `animes`, and `unlinked`; never `anime`.
- Unlinked cleanup should scan `/downloads/movies`, `/downloads/tv`, and `/downloads/animes`, moving/marking unlinked items with target category `unlinked`.

State vs Git:

- Recyclarr quality profiles and custom formats are declarative in `hosts/shiro/media/recyclarr.nix` and sync daily.
- Byparr container enablement is declarative in `hosts/shiro/media/containers.nix`; Prowlarr proxy/indexer rows are stateful.
- qBittorrent `qBittorrent.conf` is managed declaratively in `hosts/shiro/media/qbittorrent.nix` via `services.qbittorrent.serverConfig`, using the exported live baseline in `hosts/shiro/service-configs/qbittorrent/qBittorrent.conf` as source material. This intentionally includes the current qBittorrent WebUI password hash because the user accepted that trade-off for this LAN/Tailscale-only setup.
- qBittorrent categories are Nix/Git-owned in `hosts/shiro/service-configs/qbittorrent/categories.json` and installed before qBittorrent starts. Do not edit categories in the WebUI unless you also export/update the JSON file.
- Radarr, Sonarr, Prowlarr, and Cleanuparr store app state in their own databases/config directories; do not commit SQLite DBs or API keys.
- User-facing rebuild/reinstall instructions for WebUI-managed state live under `reference/webui-managed/<app>/README.md`.

Reference sources:

- `nixos/core/` — reusable base modules: Home Manager integration, Nix settings, users, OpenSSH.
- `nixos/boot/` — bootloader modules: `systemd-boot.nix` and `secure-boot.nix`.
- `nixos/desktop/` — desktop/workstation modules: workstation defaults, PipeWire audio, fonts, Hyprland, SDDM.
- `nixos/hardware/` — shared hardware support such as AMD GPU acceleration.
- `nixos/virtualisation/` — container/runtime modules such as Docker.
- `nixos/gaming/` — Steam/GameMode/Gamescope stack.
- `hosts/shiro/` — current NixOS host for the new server.
- `hosts/shiro/networking.nix`, `storage.nix`, and `system.nix` — shiro host networking, storage/tmpfiles/Btrfs, and base system behavior.
- `hosts/shiro/media/` — shiro media service modules: shared media group, qBittorrent, Arr services, Recyclarr, Plex, containers, and Qui.
- `hosts/shiro/service-configs/qbittorrent/` — exported qBittorrent baseline files and sanitized template.
- `reference/webui-managed/` — human setup notes for apps whose important settings live in DB/WebUI state.
- `reference/webui-managed/` — human setup notes for apps whose important settings live in DB/WebUI state.

Historical migration notes below may still mention old paths such as flat
`nixos/*.nix` files or `server-modules/`. Treat those as reference material only;
the active shared module layout is the grouped `nixos/` tree listed above, and
shiro's active service modules live under `hosts/shiro/`.

## Project Philosophy: Improve, Don't Blindly Port

For every new feature, service, migration, or config change, check the old Ubuntu configs and upstream template only as historical context. The goal is not to reproduce the old setup byte-for-byte; the goal is a better NixOS setup that preserves the user's intended behavior.

Required workflow for new features:

1. Identify the old behavior/config if one exists.
2. Decide whether to:
   - **port directly** when the old config is already sensible,
   - **adapt** when paths, secrets, networking, or NixOS conventions differ,
   - **redesign/improve** when NixOS modules, declarative config, security, reliability, or maintainability can make it better.
3. If not matching the old config exactly, explain the difference and why it is likely better before finalizing.
4. Keep secrets out of Git. Use placeholders in reference files and model real secrets with `sops-nix` or another explicit secret mechanism.
5. Prefer clear, declarative, reproducible service definitions over ad-hoc Docker/container state when practical.

This applies to the whole project, not just the configs currently copied from the old server.

## Commit Messages

When asked to create commits, use a descriptive commit title and include a concise explanation of what changed, why it changed, and any important behavior or migration impact.

The primary stack you want: **Radarr + Sonarr + qBittorrent + Plex** (or Jellyfin).
Most of this is already modeled in `server-modules/arr.nix` via nixarr, though you may choose Docker instead.

The upstream server config imports (for reference):

- `nixos/`: home-manager, nix, users, utils, docker, amd-graphics, **systemd-boot** (NOT lanzaboote)
- `server-modules/`: SSH, firewall, cloudflared, glance, adguard, arr, stirling-pdf, cyberchef, linkding, mazanoke, nginx, fail2ban, freshrss, default-creds, umami
- Does NOT import: audio, fonts, hyprland, sddm (headless server)

## Phase 1: Create the New Host

### 1.1 — Create `hosts/home-server/` directory

Copy structure from `hosts/server/` but adapt for ak4m3:

```
hosts/home-server/
├── configuration.nix
├── hardware-configuration.nix  # Generate on the target laptop
├── variables.nix               # ak4m3 user, Sao Paulo timezone, your domain
├── home.nix                    # Minimal: shell, git, nvf, fetch, nixy
└── secrets/
    └── default.nix             # sops secrets for cloudflared, wireguard, etc.
```

### 1.2 — variables.nix

```nix
{config, lib, ...}: {
  imports = [
    ../../themes/rose-pine.nix  # or any theme (server is headless, theme affects shell colors)
  ];

  config.var = {
    hostname = "home-server";  # pick your hostname
    username = "ak4m3";
    configDirectory = "/home/" + config.var.username + "/.config/nixos";
    keyboardLayout = "us";
    location = "Guapimirim";
    timeZone = "America/Sao_Paulo";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "pt_BR.UTF-8";
    git = {
      username = "akamee666";
      email = "moraes@akmee.xyz";
    };
    autoUpgrade = false;
    autoGarbageCollector = true;
  };

  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
```

### 1.3 — configuration.nix

Key differences from desktop hosts:

- NO audio, fonts, hyprland, sddm, lanzaboote (headless)
- YES docker, amd-graphics (if the old laptop has AMD), server-modules
- Use `systemd-boot.nix` instead of `lanzaboote.nix` (Secure Boot not needed on a home server)
- Add tailscale for mesh access from ryu/sora

```nix
{config, ...}: {
  imports = [
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix   # MUST CREATE THIS FILE (see below)
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/docker.nix

    # Server services — enable what you need
    ../../server-modules/ssh.nix
    ../../server-modules/firewall.nix
    ../../server-modules/cloudflared.nix
    ../../server-modules/nginx.nix
    ../../server-modules/fail2ban.nix
    ../../server-modules/arr.nix
    # ../../server-modules/adguardhome.nix
    # ../../server-modules/glance
    # ... add more as needed

    ./hardware-configuration.nix
    ./variables.nix
    ./secrets
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];

  system.stateVersion = "24.05";
}
```

### 1.4 — Create `nixos/systemd-boot.nix`

The current server config imports this but the file doesn't exist yet:

```nix
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
```

### 1.5 — Add to flake.nix

```nix
home-server = nixpkgs.lib.nixosSystem {
  modules = [
    {
      nixpkgs.overlays = [];
      _module.args = { inherit inputs; };
    }
    inputs.home-manager.nixosModules.home-manager
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
    inputs.nixarr.nixosModules.default  # for the arr stack
    inputs.sops-nix.nixosModules.sops   # for secrets
    ./hosts/home-server/configuration.nix
  ];
};
```

**Important**: The existing server config references `nixarr` and `sops-nix` as modules but these are NOT in the current flake outputs for the server — check if they need to be added.

## Phase 2: Old Laptop Optimizations

This is critical — the server is an old laptop, so building from source is painful.

### 2.1 — Maximize Binary Cache Hits

Stick to `nixpkgs-stable` instead of `nixpkgs` (unstable) for the server. Stable has much better Hydra cache coverage.

```nix
# In flake.nix, use stable for the server:
home-server = nixpkgs-stable.lib.nixosSystem { ... };
```

This alone will eliminate most local compilation. Unstable packages change daily and cache misses are frequent.

### 2.2 — Avoid Source-Heavy Inputs

Do NOT import these on the server (they build from source):

- `hyprland` — builds from git with submodules, massive compile
- `caelestia-shell` / `caelestia-cli` — depends on quickshell, heavy
- `nvf` — if building neovim plugins from source, consider using a minimal nvim config or just `pkgs.neovim` from stable

### 2.3 — Cross-Build From ryu

If the server laptop is too slow to build at all, build from ryu and push:

```bash
# Build the server config on ryu (fast desktop)
nixos-rebuild build --flake .#home-server

# Copy the closure to the server
nix copy --to ssh://home-server ./result

# On the server, switch to the new config
sudo nixos-rebuild switch --flake .#home-server
```

Or use `nixos-rebuild --target-host`:

```bash
# From ryu, build and deploy to server in one step
nixos-rebuild switch --flake .#home-server --target-host ak4m3@home-server --use-remote-sudo
```

### 2.4 — Remote Builds (Alternative)

Configure ryu as a remote builder for the server:

```nix
# On home-server's configuration.nix:
nix.buildMachines = [{
  hostName = "ryu";  # or tailscale IP
  systems = ["x86_64-linux"];
  maxJobs = 8;
  speedFactor = 10;
  supportedFeatures = ["nixos-test" "big-parallel"];
}];
nix.distributedBuilds = true;
```

This way `nixos-rebuild` on the server offloads compilation to ryu automatically.

## Phase 3: Service Setup

### Media Stack (Priority 1 — the main use case)

Two approaches, pick one:

#### Option A: Native NixOS via nixarr (upstream `arr.nix` as reference)

The `server-modules/arr.nix` uses the `nixarr` flake input. Cherry-pick what you need:

| Service      | Port | What it does                       |
| ------------ | ---- | ---------------------------------- |
| Radarr       | 7878 | Movie management                   |
| Sonarr       | 8989 | TV show management                 |
| Prowlarr     | 9696 | Indexer manager                    |
| Bazarr       | 6767 | Subtitles                          |
| Transmission | 9091 | Torrent client (VPN via WireGuard) |

For Plex: `services.plex.enable = true` (native NixOS, not part of nixarr).
For qBittorrent: not in nixarr — use Docker (Option B) or `services.qbittorrent` if available.

#### Option B: Docker (closer to your current Ubuntu setup)

Since you already use Docker on Ubuntu, this is the fastest migration path:

```nix
# In hosts/home-server/configuration.nix
virtualisation.oci-containers.backend = "docker";
virtualisation.oci-containers.containers = {
  radarr = {
    image = "lscr.io/linuxserver/radarr:latest";
    ports = ["7878:7878"];
    volumes = ["/srv/radarr:/config" "/mnt/data/media:/media"];
    environment = { PUID = "1000"; PGID = "1000"; TZ = "America/Sao_Paulo"; };
  };
  sonarr = {
    image = "lscr.io/linuxserver/sonarr:latest";
    ports = ["8989:8989"];
    volumes = ["/srv/sonarr:/config" "/mnt/data/media:/media"];
    environment = { PUID = "1000"; PGID = "1000"; TZ = "America/Sao_Paulo"; };
  };
  qbittorrent = {
    image = "lscr.io/linuxserver/qbittorrent:latest";
    ports = ["8080:8080" "6881:6881"];
    volumes = ["/srv/qbittorrent:/config" "/mnt/data/media/torrents:/downloads"];
    environment = { PUID = "1000"; PGID = "1000"; TZ = "America/Sao_Paulo"; };
  };
  plex = {
    image = "lscr.io/linuxserver/plex:latest";
    extraOptions = ["--network=host"];
    volumes = ["/srv/plex:/config" "/mnt/data/media:/media"];
    environment = { PUID = "1000"; PGID = "1000"; TZ = "America/Sao_Paulo"; VERSION = "docker"; };
  };
};
```

This is literally your docker-compose translated to Nix. Declarative, version-controlled, no compose file drift.

#### Option C: Hybrid

Use native NixOS for Radarr/Sonarr (well-supported in nixpkgs) and Docker for Plex/qBittorrent.

### Media Storage

Set up a data drive (external or internal) mounted at `/mnt/data`:

- `/mnt/data/media/movies`
- `/mnt/data/media/tv`
- `/mnt/data/media/torrents`

Add the mount to `hardware-configuration.nix` (btrfs with `compress=zstd` recommended).

### Remote Access

Two options:

1. **Tailscale only** (simplest) — already on ryu/sora, just `tailscale up` on server and access via MagicDNS
2. **Cloudflare Tunnel** — if you want public access; requires your own domain, tunnel setup, and sops secrets

### Other Services (cherry-pick from upstream server-modules)

| Service      | Worth it?          | Notes                                       |
| ------------ | ------------------ | ------------------------------------------- |
| AdGuard Home | Yes                | Network-wide ad blocking                    |
| Fail2Ban     | Yes if SSH exposed | Intrusion prevention                        |
| Glance       | Nice               | Dashboard                                   |
| Others       | Optional           | Browse `server-modules/` and pick what fits |

## Phase 4: Secrets Setup

### 4.1 — Initialize sops-nix

```bash
# Generate an age key on the server
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# Create .sops.yaml in repo root
cat > .sops.yaml << 'EOF'
keys:
  - &ryu age1...      # from ryu's key
  - &sora age1...     # from sora's key
  - &server age1...   # from home-server's key
creation_rules:
  - path_regex: hosts/home-server/secrets/.*
    key_groups:
      - age:
        - *server
        - *ryu        # so you can edit secrets from ryu
EOF
```

### 4.2 — Required Secrets

For the media stack:

- `wireguard-pia` — WireGuard VPN config for Transmission
- `recyclarr` — Recyclarr config (quality profiles sync)
- `cloudflared-token` — Cloudflare tunnel credentials (if using CF tunnel)
- `freshrss-password` — FreshRSS default user password (if using FreshRSS)

## Phase 5: Installation

### On the Old Laptop

1. Boot NixOS minimal ISO from USB
2. Partition disk (use disko or manual)
3. Mount and `nixos-generate-config` to get hardware-configuration.nix
4. Copy the generated hardware-configuration.nix into `hosts/home-server/`
5. From ryu (if building remotely): `nixos-rebuild switch --flake .#home-server --target-host root@<ip> --use-remote-sudo`
6. Or copy the flake to the server and build locally

### Post-Install

```bash
# Set up tailscale
sudo tailscale up

# Set up sops age key
mkdir -p ~/.config/sops/age
# Copy or generate key

# If using Cloudflare tunnel:
cloudflared tunnel login
cloudflared tunnel create home-server

# Mount media drive
# (should be in hardware-configuration.nix already)

# Verify services
systemctl status jellyfin radarr sonarr transmission-daemon
```

## Important Warnings

Things to fix before the home-server can work:

1. **`nixos/boot/systemd-boot.nix` exists** — import this path for non-Secure-Boot hosts.
2. **Server host NOT in flake outputs** — `nixosConfigurations` only has ryu and sora, must add home-server
3. **`nix.nix` trusted-users** has `"tomato"` (from upstream) — change to `"ak4m3"`
4. **`nixarr` and `sops-nix`** are flake inputs but NOT wired into any host's module list — must add to home-server

If reusing upstream `server-modules/`: 5. **Domain `hadi.diy`** is hardcoded everywhere — grep and replace with your domain 6. **SSH key in `ssh.nix`** is hadi's — replace with your ed25519 pubkey 7. **Cloudflare tunnel ID** `f7c8f777-...` is in cloudflared.nix AND arr.nix — create your own 8. **sops secrets** reference hadi's encrypted files — you need your own age key + re-encrypt

## Quick Reference: What Goes Where

| Want to...                         | File                                                                                     |
| ---------------------------------- | ---------------------------------------------------------------------------------------- |
| Add a system package (desktop hosts) | `nixos/desktop/workstation-base.nix` → `environment.systemPackages`                    |
| Add a user package (per host)      | `hosts/<name>/home.nix` → `home.packages`                                                |
| Add a shiro media service          | `hosts/shiro/media/<name>.nix` + import in `hosts/shiro/configuration.nix`               |
| Change theme                       | `hosts/<name>/variables.nix` → imports line                                              |
| Add a cachix cache                 | `nixos/core/nix.nix` → `substituters` + `trusted-public-keys`                            |
| Override a shared setting per-host | Use `lib.mkForce` in the host's config (see sora's TLP overriding power-profiles-daemon) |
| Add a Hyprland keybind             | `home/system/hyprland/bindings.nix`                                                      |
| Add a neovim plugin/language       | `home/programs/nvf/<relevant>.nix`                                                       |
| Add a new flake input              | `flake.nix` inputs + wire into the host's modules list                                   |

## Tailscale Network

All three hosts have tailscale enabled:

- **ryu**: `services.tailscale.enable = true` (firewall off for HTB, tailscale0 trusted)
- **sora**: `services.tailscale.enable = true` (tailscale0 trusted)
- **home-server**: planned (tailscale0 trusted)

Use tailscale IPs/MagicDNS to reach the server from ryu/sora without exposing ports to the internet.
This can replace Cloudflare tunnel for private access.

Current policy after shiro media setup:

- Prefer localhost for services on the same machine (`localhost:7878`, `localhost:8989`, `localhost:9696`, `localhost:8080`).
- Prefer LAN IPs for same-LAN cross-machine access; use shiro's LAN IP `192.168.18.7` for LAN clients and container-to-host callbacks where localhost is not valid.
- Use Tailscale only when the peers are not on the same LAN or when SSH over the tailnet is explicitly desired.
- Do not accept Tailscale DNS by default on ryu/sora/shiro (`--accept-dns=false`) and do not put `100.100.100.100` first in system nameservers. MagicDNS resolves short names like `shiro` to tailnet IPs, which can bypass LAN preference and has caused tailscaled DNS-forwarding overhead.


## TODO - NEXT

1. Continue organizing the nixos/ folder, you stopped at the middle of it. (Find a better name for it as well)
2. Add bazarr application and configure it to find .srt subtitles automatically, if configuration is trough WEBUI, tell the user.
3. Figure out why trying to watch a movie from web in ryu hosts does not work because plex says we are watching from remote. (Phone app works fine, accessing shiro:84200 works fine, plex.tv does not)
4. Figure out why subtitles that comes within the movie (in this case whiplash) on the web browser (ryu) create transcoding and if is there a way to avoid that.
