> > > EXTREMELY IMPORTANT <<<

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

---

# NixOS Configuration - ak4m3

## Overview

Multi-host NixOS flake managing three machines:
- **ryu** — Desktop PC (AMD Zen 3+, dGPU, daily driver + cybersecurity/HTB)
- **sora** — ThinkPad T14 Gen1 AMD (Ryzen PRO 4750U Zen 2, portable, hardened WiFi)
- **home-server** — Old laptop repurposed as media/services server (planned migration from Ubuntu)

All hosts share a modular Nix config with per-host overrides. Desktop environment is Hyprland + Caelestia shell. Theming is handled by Stylix (base16). Secrets use sops-nix.

## Repository Structure

```
.
├── flake.nix                  # Flake inputs, host definitions
├── flake.lock
├── nixos/                     # Shared NixOS system modules (imported by all/most hosts)
│   ├── audio.nix              # PipeWire (ALSA, Pulse, JACK, WirePlumber)
│   ├── amd-graphics.nix       # RADV, VA-API, ROCm OpenCL, Vulkan ICD
│   ├── docker.nix             # Docker + user group (ryu + server, NOT sora)
│   ├── fonts.nix              # Nerd Fonts, Noto, emoji, system fonts
│   ├── gaming.nix             # Steam, Proton-GE, GameMode, Gamescope (sora only)
│   ├── home-manager.nix       # HM global config (useGlobalPkgs, extraSpecialArgs)
│   ├── hyprland.nix           # Hyprland from flake input + UWSM
│   ├── lanzaboote.nix         # Secure Boot (ryu + sora, NOT server)
│   ├── nix.nix                # Flakes, cachix substituters, GC, trusted users
│   ├── sddm.nix               # SDDM with sddm-astronaut theme (desktop only)
│   ├── users.nix              # User creation, Fish shell, direnv
│   └── utils.nix              # NetworkManager, power-profiles-daemon, XDG portals, base packages
├── home/                      # Home-manager modules
│   ├── programs/
│   │   ├── brave/             # Brave browser (Wayland, VA-API, privacy hardened)
│   │   ├── discord/           # Nixcord (ryu only)
│   │   ├── fetch/             # Custom nerdfetch
│   │   ├── ghostty/           # Terminal (Fish integration, split keybinds, paste protection off)
│   │   ├── git/               # Git config + lazygit + signing (signing currently disabled)
│   │   ├── group/             # cybersecurity.nix — nmap, wireshark, hashcat, claude-code, vigil
│   │   ├── mangohud/          # Performance overlay (sora only, session-wide, hidden by default)
│   │   ├── nightshift/        # Blue light toggle (hyprsunset)
│   │   ├── nix-utils/         # Placeholder
│   │   ├── nixy/              # NixOS management TUI script
│   │   ├── nvf/               # Neovim (modular: options, keymaps, languages, picker, multicursors, etc.)
│   │   ├── shell/             # Fish + fzf + starship + zoxide + eza + yazi
│   │   ├── spicetify/         # Spotify customization (ryu only)
│   │   ├── thunar/            # File manager + GTK + icon theme
│   │   └── zathura/           # PDF viewer
│   └── system/
│       ├── caelestia-shell/   # Shell UI (bar, launcher, appearance, scheme)
│       ├── hyprland/          # Compositor settings (bindings, animations, polkit)
│       ├── hyprpaper/         # Wallpaper
│       ├── mime/              # File associations
│       └── udiskie/           # USB automount
├── hosts/
│   ├── ryu/                   # Desktop: gruvbox theme, firewall off (HTB), docker, cybersec tools
│   ├── sora/                  # Laptop: tokyo-night, TLP, thinkfan, WiFi hardening, disko LUKS+btrfs
│   └── server/                # Server (jack/hadi): rose-pine, all server-modules, sops secrets
├── server-modules/            # FROM UPSTREAM TEMPLATE (hadi's config) — reference/cherry-pick, not actively maintained
│   ├── arr.nix                # nixarr: Jellyfin, Radarr, Sonarr, Prowlarr, Bazarr, Readarr, Transmission+VPN
│   ├── adguardhome.nix        # DNS ad blocking (:3000)
│   ├── cloudflared.nix        # Cloudflare Tunnel (all services → *.hadi.diy)
│   ├── cyberchef.nix          # Data analysis (:8754)
│   ├── default-creds.nix      # Default credentials lookup (:8087)
│   ├── eleakxir.nix           # Leak search engine (:9198, currently disabled)
│   ├── fail2ban.nix           # Intrusion prevention (5 retries, 24h ban, escalating)
│   ├── firewall.nix           # Firewall + no ping
│   ├── freshrss.nix           # RSS reader (YouTube ext, rss.hadi.diy)
│   ├── glance/                # Dashboard (home page + server monitoring page)
│   ├── linkding.nix           # Bookmarks (Docker container, :9090)
│   ├── mazanoke.nix           # Image compressor (:8755)
│   ├── mealie.nix             # Recipe manager (:8092)
│   ├── nginx.nix              # Reverse proxy (minimal, services add their own vhosts)
│   ├── ssh.nix                # SSH (key-only, no root, tunneled via cloudflared)
│   ├── stirling-pdf.nix       # PDF tools (:8083)
│   └── umami.nix              # Analytics (:8097)
├── themes/
│   ├── gruvbox-dark-medium.nix  # ryu — warm browns, Maple Mono NF
│   ├── tokyo-night.nix          # sora — dark blues/purples
│   ├── rose-pine.nix            # server — soft pinks, rounded
│   ├── zen.nix                  # unused/available
│   └── wallpapers/              # 25+ wallpapers (anime, pixel, landscapes, space)
└── pkgs/                        # Custom packages (currently empty)
```

## Key Architecture Decisions

- **Shared modules in `nixos/`** are imported by all desktop hosts. Server imports a subset (no hyprland, sddm, audio, fonts, lanzaboote).
- **`utils.nix`** enables `power-profiles-daemon` globally; sora overrides it to `false` because TLP manages power instead.
- **Server uses `systemd-boot.nix`** (not lanzaboote) — this file needs to be created when setting up the new home-server.
- **Secrets**: sops-nix with per-service secrets (cloudflared token, wireguard-pia config, recyclarr, freshrss password).
- **Themes**: Stylix base16 with custom `config.theme.*` options (rounding, gaps, opacity, blur, animation-speed).

## Host-Specific Notes

### ryu (Desktop)
- `networking.firewall.enable = false` — for HTB machines, `/etc/hosts` also made writable
- `AQ_DRM_DEVICES = "/dev/dri/card1"` — hardcoded, may change between boots
- `amd_pstate=active` works on Zen 3+
- Has docker, cybersecurity tools, spicetify, discord (nixcord)
- Monitors: DP-1 (1080p@144Hz), HDMI-A-1 (1360x768@60Hz rotated)
- Tailscale enabled

### sora (ThinkPad T14 Gen1 AMD)
- **No amd_pstate** — Zen 2 BIOS lacks CPPC, falls back to `acpi-cpufreq`
- TLP: performance on AC, powersave on battery, boost always on (old CPU needs it)
- Battery thresholds: 60/85 (desk-plugged most of the time)
- Thinkfan: tpacpi sensor, conservative curve (tune after `sensors`)
- `psmouse.synaptics_intertouch=0` fixes erratic touchpad
- WiFi hardened: MAC randomization, IPv6 privacy, no LLMNR/mDNS/avahi
- LUKS + btrfs via disko
- Touchpad: natural scroll, clickfinger, disable while typing, scroll_factor 0.4
- Tailscale enabled
- Gaming: Steam + Proton-GE, GameMode, Gamescope, MangoHUD (session-wide, toggle Shift_R+F12)

### server (jack — from upstream template, NOT actively used)
- This host and `server-modules/` came with the upstream repo (hadi's config)
- Hostname: jack, user: hadi, French locale, rose-pine theme
- Useful as **reference** for the planned home-server migration
- Cherry-pick modules as needed (arr.nix, firewall.nix, ssh.nix, etc.)
- Domain `*.hadi.diy`, tunnel ID, SSH keys — all need replacing for your setup

## Flake Inputs

| Input | Purpose |
|---|---|
| nixpkgs (unstable) | Main packages |
| nixpkgs-stable (25.05) | Stable fallbacks |
| nixos-hardware | ThinkPad-specific modules (sora) |
| hyprland | Compositor (built from source) |
| disko | Declarative partitioning (sora) |
| stylix | System-wide theming |
| nixcord | Discord config (ryu) |
| sops-nix | Secrets management (server) |
| nvf | Neovim framework |
| home-manager | User environment |
| lanzaboote | Secure Boot (ryu, sora) |
| caelestia-shell/cli | Custom shell UI |
| spicetify-nix | Spotify theming (ryu) |
| nixarr | Media server stack (server) |
| codex-cli-nix | OpenAI Codex CLI |
| claude-code | Claude Code CLI |

## Common Commands

```bash
# Rebuild current host
sudo nixos-rebuild switch --flake .#ryu
sudo nixos-rebuild switch --flake .#sora

# Test without switching (dry run)
sudo nixos-rebuild test --flake .#ryu

# Update flake inputs
nix flake update

# Update single input
nix flake update nixpkgs

# Garbage collect
nix-collect-garbage -d

# Format all nix files
nix fmt

# Check flake
nix flake check
```

## Coding Conventions

- All nix files use 2-space indentation
- Attribute sets use `with pkgs;` for package lists
- `lib.mkDefault` for overridable defaults, `lib.mkForce` for hard overrides
- Host-specific settings go in `hosts/<name>/`, shared in `nixos/` or `home/`
- Server service modules each define their own cloudflared tunnel ingress
- Comments only for non-obvious decisions (why, not what)
- Theme values are accessed via `config.theme.*` and `config.lib.stylix.colors.*`

## Security

- Secrets are in sops-nix, NEVER commit plaintext secrets
- SSH keys in `server-modules/ssh.nix` — update when changing hosts
- Cloudflare tunnel credentials are sops-encrypted
- WireGuard VPN config for Transmission is sops-encrypted
- `sudo.wheelNeedsPassword = false` globally — acceptable for single-user machines
