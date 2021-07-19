# electron-iso-packager
Package your Electron app into a bootable .iso file.  
Now you can easily create a live cd from your code - no hard disk required at boot!  
Iso files created by this script work with virtual machines as well.

The average output file size is around ~125mb, so it's even less than an .exe bundle.

Under the hood, this script calls [electron-packager](https://github.com/electron/electron-packager) to obtain a linux32 packaged version of your app and then puts the result inside a remastered version of [Tinycore Linux](https://distro.ibiblio.org/tinycorelinux/), a slim linux distro, with only the bare necessary to run Electron + a window manager ([openbox](http://openbox.org/wiki/Main_Page)) and a minimal terminal.  
Check [REMASTER.md]() for a complete list of included packages.


## Installation and usage
Unfortunately, Linux is needed, as well as some basic utilities.
On debian-like environments:
```bash
apt install coreutils zutils cpio genisoimage # Install dependencies
npm install -g electron-packager              # Install the electron-packager package, it will be used internally to generate the linux app 
npm install -g electron-iso-packager          # Install this package globally
```

Then run with root permissions:
```bash
electron-iso-packager <sourcedir> <appname> [postscript] [customiso.iso]

# Examples:
sudo electron-iso-packager ./ MyApp
sudo electron-iso-packager ./ MyApp "read -n 1" # Wait keypress before packaging iso
```
Where `<sourcedir>` is the base directory of the application source (same as [electron-packager](https://github.com/electron/electron-packager)).  
After a while, it will spawn a file called `appname.iso` inside your current directory. Enjoy!  
You may specify a linux command as third argument, it will be executed after `electron-packager` has finished but before .iso is created, giving you the possibility to edit the `electron-iso-linux-ia32` folder, where your app files are stored before compression. It also allows you to edit `electron-iso-linux-ia32/autostart.sh` to change boot options as explained below. You can also set a custom iso file as the base of your system instead of the default one (check the [remaster](./REMASTER.md) guide).    
No further customization is supported yet, but some options will be added soon. Feel free to open a [github issue]() if you think something important is missing.

## Autostart
After `electron-packager` has finished, a file called `autostart.sh` is added to the result. This is the file responsable of launching your app after boot.  
You can replace it using a postscript command, for example:
```bash
sudo electron-iso-packager ./ MyApp "cp customAutostart.sh ./electron-iso-linux-ia32/autostart.sh"
```
Default autostart:
```bash
#!/bin/sh

# Autostart electron-app
/home/tc/electron-iso-linux-ia32/electron-iso --no-sandbox &

# Default tinycore desktop .xsession
"$DESKTOP" 2>/tmp/wm_errors &
export WM_PID=$!
hsetroot -add "#0E5CA8" -add "#87C6C9" -gradient 0 -center /usr/local/share/pixmaps/logo.png # Change to set custom background
[ -x $HOME/.mouse_config ] && $HOME/.mouse_config &
[ $(which "$ICONS".sh) ] && ${ICONS}.sh &
[ -d "/usr/local/etc/X.d" ] && find "/usr/local/etc/X.d" -type f -o -type l -print | while read F; do . "$F"; done
[ -d "$HOME/.X.d" ] && find "$HOME/.X.d" -type f -print | while read F; do . "$F"; done
```

## Remaster and customizing the result at runtime
Need some extra linux software to be included? Check the [remaster](./REMASTER.md) guide.

As said before, [aterm](https://linux.die.net/man/1/aterm) package is included, so you if you want, you can just right-click the desktop and install new packages at runtime or install the os on a persistent disk.  
If your goal is to obtain persistency, you may also be interested in tinycore boot codes as explained [here](http://wiki.tinycorelinux.net/wiki:boot_codes_explained).

## License
This package is licensed under GPL-3.0-or-later license.
Tinycore is licensed under [gpl v2](http://tinycorelinux.net/faq.html).
