#!/usr/bin/env bash

apt update
apt upgrade

# Add the syncthing candidate to APT sources:
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing candidate" | sudo tee /etc/apt/sources.list.d/syncthing.list
apt install syncthing
cp /usr/share/applications/syncthing-start.desktop ~/.config/autostart/

apt install ffmpeg

snap install signal-desktop
snap install firefox
snap install mailspring
snap install vlc
snap install transmission
snap install obsidian
snap install discord
snap install steam
