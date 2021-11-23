#!/usr/bin/bash

# first of all get rid of the osbtructive, broken garbage that is packagekit
# it is locking up zypper constantly on a fresh install, so you cant even use zypper ffs
echo "Nuke PackageKit ... BEGONE!"
sudo systemctl disable packagekit
sudo systemctl stop packagekit
sudo systemctl mask packagekit
sudo killall packagekitd
sudo killall packagekit # whichever it is 
sudo zypper rm --clean-deps PackageKit
# TODO is this enough to prevent it from ever being reinstalled as a dep?
sudo zypper addlock PackageKit

# disable optional dependencies by default, heck that's why they're called OPTIONAL
echo "Disable optional dependencies by default..."
sudo sed -i 's/solver.onlyRequires = false/solver.onlyRequires = true/g' /etc/zypp/zypp.conf

# now we can start update and installion 
echo "Refresh, update distro and install packages from official repo..."
sudo zypper ref
sudo zypper dup


# add additional repos and their packages

# OpenSUSE packman
"Add opensuse packman repo..."
sudo zypper ar -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
sudo zypper dup --from packman --allow-vendor-change


# tumbleweed wine repo for the most up to date version
"Add tumbleweed WINE repo..."
sudo zypper addrepo https://download.opensuse.org/repositories/Emulators:Wine/openSUSE_Tumbleweed/Emulators:Wine.repo
sudo zypper refresh


# Microsoft VSCode and Teams
echo "Addrepo vscode..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
sudo zypper addrepo https://packages.microsoft.com/yumrepos/ms-teams/ ms-teams
sudo zypper refresh




# packages to install from official and newly added repos
packages = "htop gparted wine winetricks code teams"
sudo zypper in $packages


