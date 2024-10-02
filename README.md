# virtualbox-secureboot-fedora-setup
Scripts to configure VirtualBox on Fedora with Secure Boot enabled, including generating and signing kernel modules.

# VirtualBox Secure Boot Setup on Fedora

This repository contains two Bash scripts (`pre-reboot.sh` and `post-reboot.sh`) that help configure VirtualBox in Fedora with Secure Boot enabled. The scripts will guide you through generating and registering a key for signing the VirtualBox kernel modules, preventing errors related to kernel module loading under Secure Boot.

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [How It Works](#how-it-works)
- [Usage](#usage)
  - [Pre-reboot Setup](#pre-reboot-setup)
  - [Post-reboot Setup](#post-reboot-setup)
- [Error Handling](#error-handling)
- [License](#license)

## Overview

When running VirtualBox on Fedora with Secure Boot enabled, you may encounter an error due to unsigned kernel modules. These scripts will help you:
1. Generate a signing key and register it with Secure Boot.
2. Sign the VirtualBox kernel modules.
3. Load the signed modules automatically, ensuring VirtualBox runs smoothly.

## Prerequisites

- Fedora with Secure Boot enabled.
- VirtualBox installed.
- OpenSSL installed (for generating the signing key).
- Root access for registering the key with `mokutil` and loading kernel modules.

## How It Works

1. **`pre-reboot.sh`**: 
   - Generates a private key and a public certificate.
   - Registers the public key with the system using `mokutil`.
   - Prevents re-execution of the script if it has already been run once (using a state file).

2. **`post-reboot.sh`**: 
   - Signs the VirtualBox kernel modules with the private key.
   - Loads the signed modules into the kernel.

## Usage

### Pre-reboot Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/virtualbox-secureboot-setup.git
   cd virtualbox-secureboot-setup
Make the pre-reboot.sh script executable:

bash

chmod +x pre-reboot.sh

Run the script:

bash

    sudo ./pre-reboot.sh

    When prompted, provide a password to enroll the key with Secure Boot.

    Reboot your system and follow the instructions to enroll the key (use the password you set earlier).

Post-reboot Setup

    After the reboot, make the post-reboot.sh script executable:

    bash

chmod +x post-reboot.sh

Run the script to sign and load the VirtualBox kernel modules:

bash

    sudo ./post-reboot.sh

    The script will sign and load the necessary modules (vboxdrv, vboxnetflt, vboxnetadp). VirtualBox should now function properly.

Error Handling

    Script already executed: If pre-reboot.sh has already been executed, it will create a state file (/var/log/pre_reboot_vbox_done). To re-run the script, delete the file with:

    bash

sudo rm /var/log/pre_reboot_vbox_done

Missing keys in post-reboot.sh: If you haven't run pre-reboot.sh yet, the post-reboot.sh script will alert you to generate the keys first.

Secure Boot not enrolled: Ensure that Secure Boot is properly configured and the key has been enrolled after the reboot.

## License

This project is licensed under the MIT License.
