#!/bin/bash

# Verificar si el archivo de clave privada existe
if [[ ! -f "MOK.priv" || ! -f "MOK.der" ]]; then
    echo "Los archivos de clave MOK.priv y MOK.der no se encuentran. Ejecuta pre-reboot.sh primero."
    exit 1
fi

# 1. Firmar los módulos del kernel de VirtualBox
echo "Firmando los módulos del kernel de VirtualBox..."
sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 MOK.priv MOK.der $(modinfo -n vboxdrv)
sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 MOK.priv MOK.der $(modinfo -n vboxnetflt)
sudo /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 MOK.priv MOK.der $(modinfo -n vboxnetadp)

# 2. Verificar que los módulos estén correctamente cargados
echo "Cargando los módulos firmados..."
sudo modprobe vboxdrv
sudo modprobe vboxnetflt
sudo modprobe vboxnetadp

# 3. Mensaje de éxito
echo "Módulos firmados y cargados correctamente. VirtualBox debería funcionar sin problemas ahora."
