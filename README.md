# NC-OS Linux

> **Status: work in progress.** Nothing here is ready to install yet.

NC-OS is a desktop operating system that looks and behaves like a computer from a
neon-lit future city. It's also built to be **secure, fast and genuinely usable**.
Every readout on screen is real data from your machine: nothing is a prop.

It's built as a custom image on **Fedora Atomic** using
[Universal Blue](https://universal-blue.org) tooling.

## Goals

- **Hardened by default.** Inspired by GrapheneOS: read-only system image, SELinux
  enforcing, signed updates, Secure Boot, a hardened memory allocator, sandboxed apps,
  USB devices blocked while locked, a deny-by-default firewall and no telemetry.
- **An in-world shell.** Hyprland and Quickshell: a bar, panels, launcher, lock screen,
  notifications and a security panel, all showing live system data.
- **Agentic.** An AI agent is the main way to use the system. Claude is the default, but
  any model can be swapped in (any OpenAI-compatible API, or a local model). The agent runs
  unprivileged and sandboxed: anything that touches the system needs your admin approval,
  and it can't touch firmware, wipe disks or overclock hardware at all.
- **Safe updates.** Each update is a whole signed image; if one goes wrong, boot the
  previous one.

## Privacy

The published image contains **no one's personal data**. Anything personal (your name,
your town for the weather, your apps, accounts and choice of model) is asked for on
first boot and stays on your machine. See [docs/PRIVACY.md](docs/PRIVACY.md) for the
rules contributors follow.

## Building

Images are built by GitHub Actions from the `Containerfile` and `build_files/`, and
published to the GitHub Container Registry. Install instructions will follow once
there is something worth installing.

## Licence

[MIT](LICENSE). NC-OS is an independent project with original artwork. It is not
affiliated with, or endorsed by, any game or game studio.
