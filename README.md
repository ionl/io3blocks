# io3blocks
16 blocks for i3wm called in i3blocks.conf like the example below
```
[weather]
command=~/.config/i3/i3blocks.sh weather 2>/dev/null
interval=300
color=#FFFF00
```
1. audio
1. battery
1. black
1. date
1. forecast
   * x days weather forecast. Each icon can be followed by digit symbolizing intensity
1. lightning
1. load
1. lock
1. memory
1. monitor
1. network
1. printscreen
1. sensor
1. system
1. update
   * __[db AUR snap flatpak] orphan__ each can be followed with update'number : *AUR^5*
1. weather
   * (__temperature__) (__pression__) (__current weather icon__) (__humidity rate__) {wind}(__km/h__)(__direction__)(__Beaufort scale__)

## Final result (on 12,5" laptop with font pango:Ubuntu Nerd Font 11)
![](img/status_bar.png)

# Todo
1. download/upload rate network
1. screen lightning intensity

# Binaries used
* binaries
* curl
* ifconfig
* iwlist
* pacman
* sensors
* tlp-stat
* trizen
* xclip
* xrandr

# Distribution used
* archlinux

# Files
* config
* i3blocks.ini
* i3blocks.conf
* i3blocks.sh    [line=363 word=1515 char=11650 maxline=131]


