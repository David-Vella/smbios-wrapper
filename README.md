# About

A wrapper for the `smbios-thermal-ctl` command in `libsmbios` that simplifies common commands.

New:
```bash
sudo tmode -l   # list available thermal modes
sudo tmode -c   # print current thermal mode
sudo tmode -s p # set thermal mode to performance
```

Old:
```bash
sudo smbios-thermal-ctl -i
sudo smbios-thermal-ctl -g
sudo smbios-thermal-ctl --set-thermal-mode=Performance
```

# Installation

Download the installation files under [releases](https://github.com/David-Vella/smbios-wrapper/releases)

```bash
# extract the files
tar -xvf smbios-wrapper-1.1.0-install.tar.xz

# build the package
cd smbios-wrapper-1.1.0
makepkg

# install the package
sudo pacman -U smbios-wrapper-1.1.0-1-any.pkg.tar.xz
```
