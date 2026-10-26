#!/bin/bash
# NC-OS image build. Runs inside the image build; nothing here may contain
# personal data (see docs/PRIVACY.md).
set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Packages
# Phase 1 (Foundations): no extras yet. Packages for the shell, security
# baseline and agent layer are added phase by phase.
