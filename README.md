# Dotfiles

# Ubuntu 20.04 + i3wm

## Install i3

```bash
sudo apt-get update && sudo apt-get install -y i3
```

## Enable touchpad gestures

Check if `/etc/X11/xorg.conf.d/` directory exists or not. If not, create one.

```bash
vim /etc/X11/xorg.conf.d/90-touchpad.conf
```

Add the following lines:

```vim
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
        Option "TappingButtonMap" "lrm"
        Option "NaturalScrolling" "on"
        Option "ScrollMethod" "twofinger"
EndSection
```

Logout for changes to appear.
[Source](https://cravencode.com/post/essentials/enable-tap-to-click-in-i3wm/)


## Screen tearing/flickering problem

```bash
sudo apt purge xserver-xorg-video-intel
```

No idea why this works but it does the job. But this also breaks backlight management.

**But** if there is no tearing/flickering problem then do the following:

```vim
sudo find /sys/ -type f -iname '*brightness*'
```

Make sure that your output device is present in `/sys/class/backlight`. If not, make a symlink to it.

```bash
sudo ln -s /sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-LVDS-1/intel_backlight  /sys/class/backlight
```

**NOTE**: The above path for the device may vary from system to system.

```bash
sudo mkdir -p /etc/X11/xorg.conf.d/ 
sudo vim /etc/X11/xorg.conf.d/00-backlight.conf
```

```vim
  Section "Device"
        Identifier  "Intel Graphics"
        Driver      "intel"
        Option      "Backlight"  "intel_backlight"
    EndSection
```

[Source](https://askubuntu.com/questions/715306/xbacklight-no-outputs-have-backlight-property-no-sys-class-backlight-folder)


### Fix backlight function

If you had screen tearing and flickering issue and removed the intel drivers then use the below method to fix the backlight function.

```bash
wget https://github.com/haikarainen/light/releases/download/v1.2/light_1.2_amd64.deb
sudo apt install -f ./light_1.2_amd64.deb
sudo chgrp video /sys/class/backlight/*/brightness
sudo chmod 664 /sys/class/backlight/*/brightness
```

## Volume control

`pactl` must work out of the box, but IF in case audio stuff breaks try `pulseaudio-ctl`

```bash
sudo apt install -y make
git clone https://github.com/graysky2/pulseaudio-ctl.git
cd pulseaudio-ctl
sudo make install
```

[Source](https://www.reddit.com/r/i3wm/comments/ahwb57/pulseaudio_exceeding_100_volume_with_keybindings/eeit7rw/?utm_source=reddit&utm_medium=web2x&context=3)


### Volume goes beyond 100% issue

```bash
#!/bin/sh
current=$(pacmd dump-volumes | awk 'NR==1{print $8}' | sed 's/\%//')
[ $current -lt 100 ] && pactl set-sink-volume 0 +1%
```

[Source](https://www.reddit.com/r/i3wm/comments/ahwb57/pulseaudio_exceeding_100_volume_with_keybindings/eeizcov/?utm_source=reddit&utm_medium=web2x&context=3)

Or try to use pulseaudio-ctl instead which by default limits the volume to 100%.
# Application Installation

## Samba server setup

```bash
sudo apt install -y nautilus nautilus-share samba samba-client
sudo usermod -a -G sambashare $USER
sudo systemctl enable smbd
sudo systemctl start smbd
```

Then use Nautilus to *share* the folder.


# How-to


## Assign workspace to an application

Put terminal and the application in the same workspace in tiling mode.

```bash
xprop | grep WM_CLASS
```

The mouse cursor will change to a cross(+), click on the window of the application to get it's **Class**.

Ex output:  

> WM_CLASS(STRING) = "google-chrome", "Google-chrome"

Open the i3config and assign the workspace:

```bash
vim ~/.config/i3/config
```

```vim
assign [class="Google-chrome"] $ws2
```

## Find the value of the key used

```bash
xev -event keyboard  | egrep -o 'keycode.*\)'
```