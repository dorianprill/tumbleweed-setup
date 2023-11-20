#!/usr/bin/bash

# first of all get rid of the obstructive broken garbage that is packagekit
# it is locking up zypper constantly on a fresh install, so you cant even use zypper ffs
echo "Nuke PackageKit... BEGONE!"
sudo systemctl stop packagekit
sudo systemctl mask packagekit
sudo zypper rm --clean-deps PackageKit
# TODO is this enough to prevent it from ever being reinstalled as a dep?
sudo zypper addlock PackageKit

# disable optional dependencies by default, heck that's why they're called OPTIONAL
echo "Disable optional dependencies by default..."
sudo sed -i 's/# solver.onlyRequires = false/solver.onlyRequires = true/g' /etc/zypp/zypp.conf

sudo zypper refresh

# add additional repos and their packages

# OpenSUSE packman
"Add opensuse packman repo and update distribution"
sudo zypper ar -cfp 90 https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
sudo zypper dup --from packman --allow-vendor-change


# tumbleweed wine repo for the most up to date version
echo "Add tumbleweed WINE repo..."
sudo zypper addrepo https://download.opensuse.org/repositories/Emulators:Wine/openSUSE_Tumbleweed/Emulators:Wine.repo
sudo zypper refresh

# Microsoft VSCode and Teams repos
echo " Add microsoft's repos..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
sudo zypper refresh

# Add GitHub's own RPM repo
echo "Add github's repo..."
sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo
sudo zypper refresh

echo "Install OpenBuildSystem Package Installer (OPI)..."
sudo zypper in opi
echo "Use OPI to install the codec pack (incl. non-free)..."
opi codecs


# packages to install from official and newly added repos
packages_sys="htop gparted hardinfo flatpak"
packages_av="vlc"
packages_programming="gcc clang lldb git gh helix code"
packages_tools="inkscape xournalpp"
packages_compat="wine winetricks lutris"
packages_tex="texlive texlive-latexmk texlive-xelatex-dev texlive-pgf texlive-biblatex texlive-biber texlive-beamer texlive-beamertheme-metropolis texlive-fira texlive-firamath texlive-listings texlive-listingsutf8 texlive-csquotes texlive-multirow texlive-tcolorbox texlive-babel-german texlive-german texlive-datetime2 texlive-datetime2-english texlive-datetime2-german texlive-fancyhdr texlive-xifthen texlive-enumitem texlive-comment texlive-lcg"
packages="$packages_sys $packages_av $packages_programming $packages_tools $packages_compat $packages_tex"
sudo zypper in $packages

# add rustup / cargo 
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
