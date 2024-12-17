# **VirtualBox Secure Boot Setup on Fedora**

This repository provides a streamlined solution to configure **VirtualBox** on Fedora systems with **Secure Boot enabled**. It automates key generation, module signing, and loading processes, reducing manual intervention while adding robust troubleshooting options.

This project is a **fork** of the original repository by [itteamlxs](https://github.com/itteamlxs) from [virtualbox-secureboot-fedora-setup](https://github.com/itteamlxs/virtualbox-secureboot-fedora-setup). I encountered additional challenges, particularly with **KVM conflicts** on **Fedora 41**, and reworked the guide and scripts to help others experiencing similar issues.

---

## **Table of Contents**

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Why KVM Conflicts May Occur](#why-kvm-conflicts-may-occur)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Step 1: Pre-reboot Setup](#step-1-pre-reboot-setup)
  - [Step 2: Post-reboot Setup](#step-2-post-reboot-setup)
- [Troubleshooting](#troubleshooting)
- [Future Kernel Updates](#future-kernel-updates)
- [Credits](#credits)
- [License](#license)

---

## **Overview**

When using VirtualBox on Fedora with **Secure Boot enabled**, you may encounter errors such as:

```
modprobe: ERROR: could not insert 'vboxdrv': Operation not permitted
```

This happens because **Secure Boot** requires all kernel modules to be signed with a trusted key. This repository automates the following tasks:

1. Generating a custom key pair.
2. Registering the public key with Secure Boot using **MOK Manager**.
3. Signing VirtualBox kernel modules (`vboxdrv`, `vboxnetflt`, `vboxnetadp`).
4. Loading the signed modules into the kernel.

---

## **How It Works**

The repository provides two scripts to simplify the process:

### **1. `pre-reboot.sh`**

- Generates a private key (`MOK.priv`) and public key (`MOK.der`) for signing modules.
- Registers the public key using `mokutil`.
- Prompts the user to reboot for key enrollment using **MOK Manager**.
- Creates a state file (`/var/log/pre_reboot_vbox_done`) to prevent re-execution.

### **2. `post-reboot.sh`**

- Signs VirtualBox kernel modules (`vboxdrv`, `vboxnetflt`, `vboxnetadp`).
- Loads the signed modules into the kernel.
- Ensures successful module loading.

---

## **Why KVM Conflicts May Occur**

**KVM (Kernel-based Virtual Machine)** conflicts with VirtualBox because both hypervisors attempt to use the hardware virtualization extensions (Intel VT-x or AMD-V). When KVM modules are loaded, VirtualBox may fail with errors like:

```
VT-x is not available (VERR_VMX_NO_VMX)
```

> While this conflict **may not occur for everyone**, it happened in my case on **Fedora 41**. This issue inspired me to fork the original repository and include these steps to help others troubleshoot similar problems.

If you encounter this issue, follow the [Troubleshooting](#troubleshooting) section to **disable and blacklist KVM modules**.

---

## **Prerequisites**

Ensure the following tools and packages are installed:

```bash
sudo dnf install kernel-devel kernel-headers gcc mokutil openssl
```

---

## **Usage**

### **Step 1: Pre-reboot Setup**

1. Clone the repository and navigate to it:

   ```bash
   git clone https://github.com/yourusername/virtualbox-secureboot-fedora-setup.git
   cd virtualbox-secureboot-fedora-setup
   ```

2. Make the `pre-reboot.sh` script executable and run it:

   ```bash
   chmod +x pre-reboot.sh
   sudo ./pre-reboot.sh
   ```

   - Generates the signing keys (`MOK.priv` and `MOK.der`).
   - Registers the public key with Secure Boot using `mokutil`.
   - Prompts you to set a password for key enrollment.

3. **Reboot your system**:\
   During boot, the **MOK Manager** will appear:
   - Select **Enroll MOK**.
   - Select **Continue**.
   - Enter the password set earlier.

---

### **Step 2: Post-reboot Setup**

1. After rebooting, make the `post-reboot.sh` script executable and run it:

   ```bash
   chmod +x post-reboot.sh
   sudo ./post-reboot.sh
   ```

   - Signs VirtualBox kernel modules.
   - Loads the signed modules into the kernel.

2. Verify that the modules are loaded successfully:

   ```bash
   lsmod | grep vbox
   ```

   Expected output:

   ```plaintext
   vboxnetadp            32768  0
   vboxnetflt            40960  0
   vboxdrv              700416  2 vboxnetflt,vboxnetadp
   ```

3. Start VirtualBox:
   ```bash
   virtualbox
   ```

---

## **Troubleshooting**

### **1. KVM Conflict: Disable and Blacklist KVM Modules**

If VirtualBox fails due to KVM conflicts:

1. Unload KVM modules:

   ```bash
   sudo modprobe -r kvm_intel kvm_amd kvm
   ```

2. Blacklist KVM modules to prevent automatic loading:\
   Add the following lines to `/etc/modprobe.d/blacklist.conf`:

   ```plaintext
   blacklist kvm
   blacklist kvm_intel
   blacklist kvm_amd
   ```

3. Rebuild the initramfs and reboot:

   ```bash
   sudo dracut --force
   sudo reboot
   ```

4. Verify KVM is disabled:
   ```bash
   lsmod | grep kvm
   ```

### **2. Check Secure Boot Status**

Ensure Secure Boot is enabled:

```bash
mokutil --sb-state
```

### **3. Check Module Logs**

Check the logs for Secure Boot or module errors:

```bash
dmesg | grep -i "secure boot"
dmesg | grep vbox
```

### **4. Rebuild VirtualBox Modules**

If modules fail to load, rebuild them manually:

```bash
sudo /usr/lib/virtualbox/vboxdrv.sh setup
```

---

## **Future Kernel Updates**

After kernel updates, re-run the `post-reboot.sh` script to re-sign and reload the VirtualBox modules:

```bash
sudo ./post-reboot.sh
```

---

## **Credits**

- Original repository by [itteamlxs](https://github.com/itteamlxs) from [virtualbox-secureboot-fedora-setup](https://github.com/itteamlxs/virtualbox-secureboot-fedora-setup).
- Forked and enhanced for **Fedora 41** by [Alby11](https://github.com/Alby11), based on personal experience with **KVM conflicts** and module signing issues.

---

## **License**

This project is licensed under the MIT License.

---

**End of README**

Let me know if you need any more tweaks or assistance! 😊
