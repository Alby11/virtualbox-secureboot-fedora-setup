#!/bin/bash

# Archivo de estado para verificar si ya se ha ejecutado el script
STATE_FILE="/var/log/pre_reboot_vbox_done"

# Verificar si el archivo de estado ya existe
if [[ -f "$STATE_FILE" ]]; then
    echo "El script pre-reboot.sh ya se ha ejecutado previamente. No es necesario volver a ejecutarlo."
    exit 1
fi

# 1. Generar una clave privada y un certificado público para la firma de los módulos
echo "Generando la clave privada y el certificado público para la firma de los módulos..."
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=VirtualBox Module Signing/"

# 2. Registrar la clave pública en el sistema para Secure Boot
echo "Registrando la clave pública en el sistema (se te pedirá una contraseña)..."
sudo mokutil --import MOK.der

# 3. Crear el archivo de estado para marcar que el script ya fue ejecutado
echo "Creando archivo de estado para evitar la ejecución múltiple..."
sudo touch "$STATE_FILE"

# 4. Informar al usuario que debe reiniciar el sistema
echo "Clave pública registrada. Debes reiniciar el sistema para inscribir la clave en el sistema."
echo "Por favor, reinicia el sistema manualmente y luego ejecuta el script post-reboot.sh."
