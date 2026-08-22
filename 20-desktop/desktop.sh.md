
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"



grep -qnP '[\x{201C}\x{201D}\x{2018}\x{2019}\x{2014}\x{2013}]' "$0" \
	  && { echo "smart chars found"; exit 1; }
	  


# = =    Firelink     = = = = = = =


if [ ! -d ~/firelink ]; then
	mkdir -p ~/firelink
	ln -s /var/lib/libvirt/images ~/firelink/vms
	ln -s /var/lib/docker         ~/firelink/docker
	ln -s /home/ai                ~/firelink/ai
	ln -s /games                  ~/firelink/games
fi

sudo chown "$USERNAME:$USERNAME" /games /home/ai




# = =    Nvidia     = = = = = = = =


if lspci | grep -qi nvidia; then
    sudo pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils linux-headers
    
    sudo sed -i 's/^MODULES=.*/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    
    sudo mkinitcpio -P
    
fi

# = =    HyDE     = = = = = = = =


sudo pacman -S --needed --noconfirm luarocks gobject-introspection
    # both discovered missing mid-install last time — pre-installed now

git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE

cd ~/HyDE/Scripts

sudo pacman -S archlinux-keyring

./install.sh -n
    # -n skips HyDE's own NVIDIA auto-install (already done in 1st-boot)


# = =    Remove Chaotic     = =

    
read -rp "Remove chaotic-aur now? (y/N): " REMOVE_CHAOTIC
if [[ "$REMOVE_CHAOTIC" == "y" ]]; then
    sudo sed -i '/\[chaotic-aur\]/,+1d' /etc/pacman.conf
    sudo pacman -Rns --noconfirm chaotic-keyring chaotic-mirrorlist
    sudo pacman -Sy
fi

echo "Done. Log out and back into Hyprland to pick up the keyboard change."

# = =    Keyboard     = = = = = =


if grep -q 'input = {' ~/.config/hypr/hyprland.lua; then
	sed -i '/input = {/a\		kb_variant = "colemak",' ~/.config/hypr/hyprland.lua
else
	cat >> ~/.config/hypr/hyprland.lua << 'EOF'

hl.config({
	input = {
		kb_variant = "colemak",
	}
})
EOF
fi

sudo localectl --no-convert set-x11-keymap us pc105 colemak



# = =    End     = = = = = = = = = 

umount -R /mnt

lsblk

echo "Reboot"