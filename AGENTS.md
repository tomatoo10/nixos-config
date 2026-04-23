# Home-Server Migration Plan & Agent Guide

## Goal

Migrate home-server from Ubuntu (Docker-based) to NixOS as the third host in this flake.
The server is an old laptop — minimize compilation, maximize binary cache hits.

## Current State

The `hosts/server/` and `server-modules/` directories came with the upstream template repository (hadi/jack, French locale, rose-pine theme). They are **not actively used** — treat them as reference material to cherry-pick from, not as a working config to inherit wholesale.

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

| Service | Port | What it does |
|---|---|---|
| Radarr | 7878 | Movie management |
| Sonarr | 8989 | TV show management |
| Prowlarr | 9696 | Indexer manager |
| Bazarr | 6767 | Subtitles |
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

| Service | Worth it? | Notes |
|---|---|---|
| AdGuard Home | Yes | Network-wide ad blocking |
| Fail2Ban | Yes if SSH exposed | Intrusion prevention |
| Glance | Nice | Dashboard |
| Others | Optional | Browse `server-modules/` and pick what fits |

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

1. **`nixos/systemd-boot.nix` does not exist** — must be created (see Phase 1.4)
2. **Server host NOT in flake outputs** — `nixosConfigurations` only has ryu and sora, must add home-server
3. **`nix.nix` trusted-users** has `"tomato"` (from upstream) — change to `"ak4m3"`
4. **`nixarr` and `sops-nix`** are flake inputs but NOT wired into any host's module list — must add to home-server

If reusing upstream `server-modules/`:
5. **Domain `hadi.diy`** is hardcoded everywhere — grep and replace with your domain
6. **SSH key in `ssh.nix`** is hadi's — replace with your ed25519 pubkey
7. **Cloudflare tunnel ID** `f7c8f777-...` is in cloudflared.nix AND arr.nix — create your own
8. **sops secrets** reference hadi's encrypted files — you need your own age key + re-encrypt

## Quick Reference: What Goes Where

| Want to... | File |
|---|---|
| Add a system package (all hosts) | `nixos/utils.nix` → `environment.systemPackages` |
| Add a user package (per host) | `hosts/<name>/home.nix` → `home.packages` |
| Add a server service | `server-modules/<name>.nix` + import in `hosts/home-server/configuration.nix` |
| Change theme | `hosts/<name>/variables.nix` → imports line |
| Add a cachix cache | `nixos/nix.nix` → `substituters` + `trusted-public-keys` |
| Override a shared setting per-host | Use `lib.mkForce` in the host's config (see sora's TLP overriding power-profiles-daemon) |
| Add a Hyprland keybind | `home/system/hyprland/bindings.nix` |
| Add a neovim plugin/language | `home/programs/nvf/<relevant>.nix` |
| Add a new flake input | `flake.nix` inputs + wire into the host's modules list |

## Tailscale Network

All three hosts have tailscale enabled:
- **ryu**: `services.tailscale.enable = true` (firewall off for HTB, tailscale0 trusted)
- **sora**: `services.tailscale.enable = true` (tailscale0 trusted)
- **home-server**: planned (tailscale0 trusted)

Use tailscale IPs/MagicDNS to reach the server from ryu/sora without exposing ports to the internet.
This can replace Cloudflare tunnel for private access.
