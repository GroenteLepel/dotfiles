#!/usr/bin/env bash

apt update
apt upgrade

# Add the syncthing candidate to APT sources:
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing candidate" | sudo tee /etc/apt/sources.list.d/syncthing.list
apt install syncthing
if [ ! -d /home/.config/autostart/ ]; then
  mkdir -p /home/.config/autostart/;
fi
cp /usr/share/applications/syncthing-start.desktop ~/.config/autostart/

apt install ffmpeg
apt install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install flathub md.obsidian.Obsidian

snap install signal-desktop
snap install firefox
snap install mailspring
snap install vlc
snap install transmission
snap install discord
snap install steam
