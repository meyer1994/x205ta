# X205TA

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

Arch linux installation instructions for Asus X205TA

```
                   -`                    meyer@x205ta
                  .o+`                   ----------
                 `ooo/                   OS: Arch Linux x86_64
                `+oooo:                  Host: X205TAW 1.0
               `+oooooo:                 Kernel: 5.14.12-arch1-1
               -+oooooo+:                Uptime: 38 mins
             `/:-:++oooo+:               Packages: 455 (pacman)
            `/++++/+++++++:              Shell: bash 5.1.8
           `/++++++++++++++:             Resolution: 1366x768
          `/+++ooooooooooooo/`           WM: sway
         ./ooosssso++osssssso+`          Theme: Arc-Dark [GTK2/3]
        .oossssso-````/ossssss+`         Icons: Arc [GTK2/3]
       -osssssso.      :ssssssso.        Terminal: alacritty
      :osssssss/        osssso+++.       Terminal Font: Hack
     /ossssssss/        +ssssooo/-       CPU: Intel Atom Z3735F (4) @ 1.832GHz
   `/ossssso+/:-        -:/+osssso+-     GPU: Intel Atom Processor Z36xxx/Z37xxx Series Graphics & Display
  `+sso+:-`                 `.-/+oso:    Memory: 220MiB / 1906MiB
 `++:.                           `-/+/
 .`                                 `/
```

This is supposed to be a tutorial, in the most straightforward way possible, on
how to install [Arch Linux][1] on an Asus X205TA. This was quite a saga for me
to get it done in 2021.

## Table of contents

- [Getting started](#getting-started)
- [Pre install](#pre-install)
  - [bootia32.efi](#bootia32efi)
  - [Booting USB](#booting-usb)
- [Install](#install)
- [Post install](#post-install)
  - [Install grub](#install-grub)
  - [Generate `grub.cfg`](#generate-grubcfg)
  - [Audio](#audio)
- [Thanks](#thanks)

## Getting started

You will need:

- USB flash drive
- Another linux machine
- Arch Linux [ISO][2]

Older images did not have WIFI or sound working out of the box. However, newer
images are working correctly. There are still some [quirks][8] to deal,
however.

## Pre install

### `bootia32.efi`

First of all, you will need to create a `bootia32.efi` for yourself. You'll
neeed a new [`grub.cfg`](./grub.cfg) file. Luckily, I have one, copied from
this [blog][3] and it is included in this repo.

You **MUST** change the `ARCH_YYYYMM` label in the `grub.cfg` file to match the
ISO you have just downloaded. To get the correct label for the ISO you just
downloaded you can execute the following (line breaks added):

```sh
$ file archlinux-2021.10.01-x86_64.iso
archlinux-2021.10.01-x86_64.iso:
    ISO 9660 CD-ROM filesystem data (DOS/MBR boot sector)
    'ARCH_202110' (bootable)
```

After you have updated the `grub.cfg` file to match your ISO, you can execute
the following:

```sh
$ grub-mkstandalone -v \
    -d /usr/lib/grub/i386-efi/ \
    -O i386-efi \
    --modules='part_gpt part_msdos' \
    --fonts=unicode \
    --locales=uk \
    --themes='' \
    -o ./bootia32.efi \
    /boot/grub/grub.cfg=./grub.cfg
```

This will generate a `bootia32.efi` file on your current directory.

### Booting USB

This step is very easy. We are just going to copy all files from the ISO to a
USB flash drive and add our `bootia32.efi` file. First, format it using `vfat`
and set the label of the drive to match the Arch Linux ISO label. In our
example, it was `ARCH_202110`.

```sh
$ mkfs.vfat -F 32 /dev/sdc1 -n ARCH_202110
```

Mount it, so we can copy files to it:

```sh
$ mkdir /tmp/usb
$ mount /dev/sdc1 /tmp/usb
```

Mount the ISO file as well, so we can copy its files:

```sh
$ mkdir /tmp/iso
$ mount archlinux-2021.10.01-x86_64.iso /tmp/iso -o loop
mount: /tmp/iso: WARNING: source write-protected, mounted read-only.
```

Copy all files from ISO to USB, add our `bootia32.efi` as well:

```sh
$ cp -rv /tmp/iso/* /tmp/usb
$ cp -v bootia32.efi /tmp/usb/EFI/BOOT/
```

Clean up after yourself:

```sh
$ umount /tmp/iso
$ umount /tmp/usb
```

You have a bootable USB!!


## Install

To boot into the USB media just press `ESC`, or `F2` multiple times while the
computer is booting. Make sure you have "secure boot" deactivated in the BIOS.

Newer versions of arch linux installation medias come with a very handy script
that helps with the installation process. First, connect to the internet using
[`iwctl`][4]:

```sh
$ iwctl
[iwd]# station wlan0 scan
[iwd]# station wlan0 connect YOUR_WIFI
[iwd]# exit
```

Here I show the summary of my installation, which worked. You can modify it to
better suit your case.

```sh
$ archinstall
Select one of the above keyboard languages: us-acentos
Select one of the above regions to download packages from: United states
Select one of the above disks: /dev/mmcblk2
Found partitions on the selected drive: Format entire drive and setup a basic partition scheme
Select which filesystem your main partition should use: ext4
Enter disk encryption password (leave blank for no encryption):
Would you like to use GRUB as a bootloader: y
Desired hostname for installation: x205ta
Enter root password:
Enter a username: meyer1994
Password for user meyer1994:
Should this user be a supeuser: y
Enter a pre-programmed profile name: minimal
Choose which kernels to use: linux
Write additional packages to install:
Select one network interface to configure:
Enter a valid timezone: Brazil/East
Would you like automatic time synchronization: y
```

Wait for it to finish but do not restart.

## Post install

After you finished the installation process, while still in using the bootable
USB, [`chroot`][9] into the system. Usually, the system will be mounted in
`/mnt`. If not, mount them first and then `chroot` into it:

```sh
$ mount /dev/mmcblk2p2 /mnt
$ mount /dev/mmcblk2p1 /mnt/boot
$ arch-chroot /mnt
```

### Install grub

We need to install a correct version of grub into this system.

```sh
$ grub-install \
    -–target=i386-efi \
    -–efi-directory=/boot \
    --bootloader-id=grub_uefi \
    -–recheck
Installing for i386-efi partition
Installation finished. No errors reported
```

### Generate `grub.cfg`

And generate its configuration:

```sh
$ grub-mkconfig -o /boot/grub/grub.cfg
Generating grub configuration file
...
done
```

### Audio

Audio was a known issue with this machine. However, it seems to have been
resolved in newer linux kernel versions. To make it work, I just installed
`pulseaudio` and rebooted the computer.

```sh
$ pacman -S pulseaudio
```

## Thanks

- ifranali's [blog][6]: the main reference for this
- Arch Wiki X205TA [page][5]: gathering lots of info
- savagezen's [repo][7]: used by me the first time I got this working, back in
2016
- [Myself][10]: for making a question in 2016, which I forgot, and leading me
back to ifranali's blog
- [Wayback Machine][11]: for having a snapshot of ifranali's blog
- avakyeramian's [repo][8]: for having some fixes to problems I did not even
know existed

[1]: https://archlinux.org/
[2]: https://archlinux.org/download/
[3]: https://web.archive.org/web/20200803060417/https://ifranali.blogspot.com/2015/04/installing-arch-linux-on-asus-x205ta.html
[4]: https://wiki.archlinux.org/title/Iwd#iwctl
[5]: https://wiki.archlinux.org/title/ASUS_x205ta
[6]: https://web.archive.org/web/20200803060417/https://ifranali.blogspot.com/2015/04/installing-arch-linux-on-asus-x205ta.html
[7]: https://web.archive.org/web/20211016143553/https://github.com/savagezen/x205ta
[8]: https://web.archive.org/web/20211016142109/https://github.com/avakyeramian/Asus_X205TA_Debian_Fix
[9]: https://wiki.archlinux.org/title/Chroot
[10]: https://web.archive.org/web/20211016143503/https://superuser.com/questions/1071080/usb-does-not-boot-when-trying-to-install-linux-on-my-asus-eeebook-x205ta
[11]: https://web.archive.org/
