
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

grep -qnP '[\x{201C}\x{201D}\x{2018}\x{2019}\x{2014}\x{2013}]' "$0" \
	  && { echo "smart chars found"; exit 1; }



# = =    Network     = = = = = =


sudo systemctl enable --now NetworkManager

retry ping -c1 archlinux.org




# = =    Timezone     = = = = = =


ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

hwclock --systohc



# = =    Locale     = = = = = = =


sed -i "s/^#\($LOCALE\)/\1/" /etc/locale.gen
	locale-gen
	
locale -a | grep -q "en_US.utf8" || { echo "Locale not generated" >&2; exit 1; }

echo "LANG=$LOCALE" > /etc/locale.conf

echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf



# = =    Hostname     = = = = = 


echo "$HOSTNAME" > /etc/hostname

cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF


	

# = =    TPM2     = = = = = = = =


echo Encryption Pass

sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 "/dev/disk/by-partlabel/cryptsystem"




# = =    zram     = = = = = = = =


sudo tee /etc/systemd/zram-generator.conf > /dev/null << EOF
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
EOF



# = =    yay     = = = = = = = = =

if ! command -v yay >/dev/null; then
	  sudo pacman -S --needed --noconfirm git base-devel
	  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
	  (cd /tmp/yay-bin && makepkg -si --noconfirm)
	fi

yay -S limine-mkinitcpio-hook

# = =    End     = = = = = = = = = 

echo "Run desktop.sh"