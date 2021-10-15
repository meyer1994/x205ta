# X205TA

Arch linux installation instructions for Asus X205TA

## Introduction

This is supposed to be a tutorial, in the most straightforward way possible, on
how to install [Arch Linux][1] on an Asus X205TA. This was quite a saga for me
to get it done in 2021.

## Getting started

You will need:

- USB flash drive
- Another linux machine
- Arch Linux [ISO][2]
- This repo

```sh
$ git clone https://github.com/meyer1994/x205ta
$ cd x205ta
```

Older Arch Linux images did not have WIFI working out of the box for this
machine. This tutorial assumes you are using a newer image with WIFI working.

## Creating bootable media

### Creating `bootia32.efi`

First of all, you will need to create a `bootia32.efi` for yourself. You'll
neeed a new [`grub.cfg`](./grub.cfg) file. Luckily, I have one, copied from
this [blog][3] and it is included in this repo.

You **MUST** change the `ARCH_YYYYMM` label in the `grub.cfg` file to match the
ISO you have just downloaded. To get the correct label for the ISO you just
downloaded you can execute the following (line breaks added to output for
easier reading):

```sh
$ file archlinux-2021.10.01-x86_64.iso
archlinux-2021.10.01-x86_64.iso:
    ISO 9660 CD-ROM filesystem data (DOS/MBR boot sector)
    'ARCH_202110' (bootable)
```

In the example above, you **MUST** use the `ARCH_202110` label on your `grub.cfg`
file. You can replace the label using `sed`.

```sh
$ sed -i 's/ARCH_[0-9]\+/ARCH_202110/' grub.cfg
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

### Creating bootable USB

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


## Installing arch

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

Wait for it to finish and `chroot` into the system:

```sh
$ arch-chroot /mnt
```

If it is not mounted, mount the partitions first (the commands order matters
here):

```sh
$ mount /dev/mmcblk2p2 /mnt
$ mount /dev/mmcblk2p1 /mnt/boot
$ arch-chroot /mnt
```

We need to install grub correctly.

```sh
$ grub-install \
    -–target=i386-efi \
    -–efi-directory=/boot \
    --bootloader-id=grub_uefi \
    -–recheck
Installing for i386-efi partition
Installation finished. No error reported
```

And generate its configuration:

```sh
$ grub-mkconfig -o /boot/grub/grub.cfg
Generating grub configuration file
...
done
```

fin.

## Thanks

Thanks to the community:

- ifranali [blog][6]
- Arch Wiki X205TA [page][5]
- savagezen's [repo][7]


[1]: https://archlinux.org/
[2]: https://archlinux.org/download/
[3]: https://web.archive.org/web/20200803060417/https://ifranali.blogspot.com/2015/04/installing-arch-linux-on-asus-x205ta.html
[4]: https://wiki.archlinux.org/title/Iwd#iwctl
[5]: https://wiki.archlinux.org/title/ASUS_x205ta
[6]: https://web.archive.org/web/20200803060417/https://ifranali.blogspot.com/2015/04/installing-arch-linux-on-asus-x205ta.html
[7]: https://github.com/savagezen/x205ta
