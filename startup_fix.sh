#!/bin/sh

# This script is used to fix startup issues with VirtualBox on Fedora with Secure Boot enabled.

for module in "vboxdrv" "vboxnetflt" "vboxnetadp"; do
  echo "Signing and loading module $module"
  sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 MOK.priv MOK.der $(modinfo -n $module) &&
    sudo modprobe $module
done
