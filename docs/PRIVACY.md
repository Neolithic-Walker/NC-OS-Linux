# Privacy rules for this repo

This repo is public. Its only job is to let people build and download NC-OS.
**No personal data from anyone's own machine ever goes in it.**

## Never commit

- Names, email addresses, phone numbers, postcodes, towns or addresses
- Hostnames, usernames and home folder paths
- IP or MAC addresses, Wi-Fi names, hardware serial numbers, licence keys
- Account details, calendars, inboxes, app lists or launch targets from your own setup
- API keys, tokens, passwords or signing keys
- Screenshots or logs from your own machines; use a clean test VM

## How it's enforced

1. **Allow-list `.gitignore`.** Only the folders the build needs can be committed.
2. **Generic by design.** Anything personal is asked for on first boot and stored on
   that machine, never in the image. Your own setup is layered on locally.
3. **Private blocklist.** A list of your personal details (one per line) that must never
   appear. It is **never** stored in the repo:
   - on your machine: `~/.config/nc-os/privacy-blocklist.txt`
   - in CI: the `PRIVACY_BLOCKLIST` repository secret

   Use specific terms (a full name, an email address, a hostname), not short words that
   could appear in ordinary text. Matches are reported by file and line only, so the
   public build logs never show the term.
4. **Pre-commit hook.** Run once per clone: `git config core.hooksPath .githooks`.
   It runs the blocklist check, and gitleaks if it's installed.
5. **CI.** Every push and pull request runs gitleaks over the whole history plus the
   blocklist check. The image build won't start until both pass.
6. **GitHub settings.** Secret scanning and push protection are on; commits use a GitHub
   no-reply email.
7. **Images.** Strip EXIF and other metadata before committing any picture.

## Signing

Images are signed with cosign once the `SIGNING_SECRET` repository secret exists. Only
the public key (`cosign.pub`) is committed. The private key never leaves GitHub's
encrypted secrets and the maintainer's own machine.

## If something slips

Treat it as leaked, even if you delete it quickly: it may already have been copied.
Stop pushing, tell the maintainer, change anything that can be changed (keys, tokens,
passwords), then remove it from the history.
