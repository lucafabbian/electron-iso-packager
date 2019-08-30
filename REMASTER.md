# Remaster guide
`electron-iso-packager` comes with this extensions already installed:
```
Xorg-7.7 openbox aterm nss gdk-pixbuf2 gtk3 libasound libcups
```
If you want to add/remove something you need to remaster the iso, clone this repo and update the included files with the remastered version. This document will guide you in the process; it's divided into two parts: the first explains how to create a remaster tinycore with the desired packages (difficult), the second how to create your own `electron-iso-packager` with the iso you've prepared (easy).

## Create custom iso file
First install on your system [Virtualbox](https://www.virtualbox.org/) and download a fresh tinycore iso from the official mirror (the minimal version, called [core.iso](https://distro.ibiblio.org/tinycorelinux/10.x/x86/release/Core-current.iso), it's enough); you will also need a ftp server (such as [vsftpd](https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-a-user-s-directory-on-ubuntu-16-04)) running on your system with write permissions enabled: it's the simplest way to move files between your system and the virtual machine.

Open Virtualbox -> New -> Linux(Other Linux 32bit) -> ram 1024 -> choose no virtual disk  
Start the machine and insert the core.iso file you have downloaded previously. Press enter to boot. If everything is ok, you should see the following message:
```
tc@box:~$ _
```
Now you can can use `ftpput/ftpget` inside the virtual machine to store/load files from the ftp server on your system.
```bash
ftpput -u USERNAME -p PASSWORD IP_ADDRESS REMOTE_FILE LOCAL_FILE  # Store file
ftpget -u USERNAME -p PASSWORD IP_ADDRESS LOCAL_FILE REMOTE_FILE  # Load file
```

Inside the virtual machine, use `tce-load` to install the packages you want, default are:
```bash
tce-load -wi Xorg-7.7 openbox aterm ezremaster      # Graphical environment, required!
tce-load -wi nss gdk-pixbuf2 gtk3 libasound libcups # Minimun libs to make electron work
```
Then, use `ftpget` to upload a copy of the core.iso as `/home/tc/core.iso`.  
If no errors occurred, type `startx` and boot into the graphical environment.  
Open ezremaster with right click -> Applications -> ezremaster  
Choose "Use ISO Image" and type "/home/tc/core.iso". Keep "/tmp/ezremaster" as temporary dir.  
Next -> Insert the boot codes you prefer (default: leave blank) -> Next  
Now you have the possibility to add the extension installed previously, just click the "Load" button next to "Inside initrd apps on boot". Don't forget to remove ezremaster or it will be included as well!

Done! Just wait a few minutes and the iso file will be ready as `/tmp/ezremaster/ezremaster.iso`; use `ftpput` to upload it on your system.

## Cloning electron-iso-packager
Just use the included script `updateIsoFiles.sh`, and you are done!
```
git clone https://github.com/lucafabbian/electron-iso-packager.git
sudo ./electron-iso-packager/updateIsoFiles.sh /path/to/your/ezremaster.iso
```
The script will do everything needed. When it ends, if you want you can enter the dir and use `npm link` to make electron-iso-packager command avaiable globally.
