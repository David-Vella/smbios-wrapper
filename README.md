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

Install on Arch Linux using the included `PKGBUILD`

David Vella, June 2020