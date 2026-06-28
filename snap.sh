#!/usr/bin/env bash

apt update
apt upgrade

# Install syncthing
# Add the release PGP keys:
if [ ! -d /etc/apt/keyrings/ ]; then
  mkdir -p /etc/apt/keyrings/;
fi
apt install curl
curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

# Add the "stable-v2" channel to your APT sources:
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable-v2" | sudo tee /etc/apt/sources.list.d/syncthing.list

apt update
apt install syncthing
if [ ! -d /home/.config/autostart/ ]; then
  mkdir -p /home/.config/autostart/;
fi
cp /usr/share/applications/syncthing-start.desktop ~/.config/autostart/

apt install ffmpeg

# GNOME tiling manager
apt install -y gettext
git clone git@github.com:ubuntu/Tiling-Assistant.git /tmp/tiling-assistant
cd /tmp/tiling-assistant
./scripts/build.sh -i
cd -
rm -rf /tmp/tiling-assistant

apt install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install flathub md.obsidian.Obsidian
flatpak install flathub com.prusa3d.PrusaSlicer

snap install signal-desktop
snap install firefox
snap install mailspring
snap install vlc
snap install transmission
snap install discord
snap install steam
