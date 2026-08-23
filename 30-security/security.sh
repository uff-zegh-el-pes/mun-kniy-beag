#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"


cat /sys/module/nvidia_drm/parameters/modeset

# = =    Mullvad     = = = = = = =


yay -S --needed --noconfirm mullvad-vpn

sudo systemctl enable --now mullvad-daemon

until sudo mullvad status &>/dev/null; do sleep 1; done

sudo mullvad lan set allow


# = =    UFW     = = = = = = = = =


sudo pacman -S --needed --noconfirm ufw

	
sudo systemctl enable ufw


sudo ufw default deny incoming


sudo ufw default allow outgoing


sudo ufw --force enable



# = =    End     = = = = = = = = = 

echo "Run virt.sh"
