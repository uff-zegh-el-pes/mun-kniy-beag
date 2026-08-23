
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

grep -qnP '[\x{201C}\x{201D}\x{2018}\x{2019}\x{2014}\x{2013}]' "$0" \
	  && { echo "smart chars found"; exit 1; }


cat /sys/parameters/modules/nvidia_drm/modeset

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
