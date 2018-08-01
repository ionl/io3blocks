#!/usr/bin/bash
#
# 2018-04-29 ionl
#

source ~/.config/i3/i3blocks.ini

###
# battery level
batteryLevel () {
    bat="?"
    if   [ "$1" -gt "97" ]; then bat="";
    elif [ "$1" -gt "90" ]; then bat="";
    elif [ "$1" -gt "80" ]; then bat="";
    elif [ "$1" -gt "70" ]; then bat="";
    elif [ "$1" -gt "60" ]; then bat="";
    elif [ "$1" -gt "50" ]; then bat="";
    elif [ "$1" -gt "40" ]; then bat="";
    elif [ "$1" -gt "30" ]; then bat="";
    elif [ "$1" -gt "20" ]; then bat="";
    elif [ "$1" -gt "10" ]; then bat="";
    elif [ "$1" -gt "-1" ]; then bat="";
    fi;
    echo $bat
}
# convert code to icon from openweathermap api
iconImg () {
  strength=${1:2:1}
  case "${1:0:1}" in
    2) ico="";;
    3) ico="☂";;
    5) ico="";;
    7) ico="(.)";;
    8)
        if [ "$1" == "800" ]; then
          ico="☀";
          strength="";
        elif [ "$1" == "801" ]; then
          ico="☁";
          strength="";
        else
          ico="";
        fi;
        ico="☀";;
    *) ico="?";;
  esac
  echo "$ico`iconStrength $strength`"
}
# add information about strength of icon (cloud, rain etc.)
iconStrength () {
  case "$1" in
    1) str="¹";;
    2) str="²";;
    3) str="³";;
    4) str="⁴";;
    *) str="";;
  esac
  echo $str
}
# logo distribution
logoDistribution () {
    case "`lsb_release -i | xargs | cut -d' ' -f3`" in
        "Arch"     ) str="";;
        "BSD"      ) str="" ;;
        "Debian"   ) str="" ;;
        "Fedora"   ) str="" ;;
        "OpenSuse" ) str=""  ;;
        "Raspberry") str=""  ;;
        "Ubuntu"   ) str="" ;;
                  *) str="" ;;
    esac
    echo $str
}
# convert angle to direction from openweathermap api
windDirection () {
  if   [ -z $1 ];      then echo "~";
  elif [ $1 -gt 337 ]; then echo "";
  elif [ $1 -gt 292 ]; then echo "";
  elif [ $1 -gt 247 ]; then echo "";
  elif [ $1 -gt 202 ]; then echo "";
  elif [ $1 -gt 157 ]; then echo "";
  elif [ $1 -gt 122 ]; then echo "";
  elif [ $1 -gt  67 ]; then echo "";
  elif [ $1 -gt  22 ]; then echo "";
  else echo "?"; fi;
}
# Beaufort scale wind speed
windPower () {
  if   [ -z $1 ];      then echo "~";
  elif [ $1 -lt  1 ];  then echo "";
  elif [ $1 -lt  6 ];  then echo "";
  elif [ $1 -lt 12 ];  then echo "";
  elif [ $1 -lt 20 ];  then echo "";
  elif [ $1 -lt 29 ];  then echo "";
  elif [ $1 -lt 39 ];  then echo "";
  elif [ $1 -lt 50 ];  then echo "";
  elif [ $1 -lt 62 ];  then echo "";
  elif [ $1 -lt 75 ];  then echo "";
  elif [ $1 -lt 89 ];  then echo "";
  elif [ $1 -lt 103 ]; then echo "";
  elif [ $1 -lt 118 ]; then echo "";
  else echo ""; fi;
}
###
# Main
out=

case $1 in
    audio)
        if [ "`amixer get Master | grep -i '\[on\]' | wc -l`" -eq 2 ]; then
            lvl=`amixer get Master | egrep -o -m1 '[0-9]{1,3}%' | sed 's/%//g'`
            if   [ "$lvl" -gt "75" ]; then ico="";
            elif [ "$lvl" -gt "25" ]; then ico="";
            elif [ "$lvl" -lt "26" ]; then ico="";
            fi;
        else
           ico="ﱝ"
        fi;
        mic=" "
        out="$mic$ico$lvl";;

    battery) #  battery 2 methods : "acpi -bi" or "tlp-stats -b"
        tlp=`sudo tlp-stat -b`
        lvl="$(echo "$tlp" | grep remaining_percent | xargs | cut -d' ' -f3)"
        bat=`batteryLevel $lvl`

        case $(echo "$tlp" | grep -i state | xargs | cut -d' ' -f3) in
          charging)
            way="+";;
          discharging)
            way="-";;
          full)
            way="full";;
          idle)
            way="=";;
          unknown)
            way="unk";;
          *)
            way="?"
        esac

        pwr=`tlp-stat -s | grep -i "power source" | xargs | cut -d' ' -f4`
        if [ "$pwr" == "AC" ]; then
            if [ "$lvl" -gt "90" ]; then
                bat=
                way=
            fi;
            itm=""
        else
            rem=
            if [ "$lvl" -lt "10" ]; then
                rem="$(echo "$tlp" | grep remaining_running_time_now | xargs | cut -d' ' -f3)'"
            fi;
        fi;
        out="$itm$bat$way$rem";;

    black)
        sleep 1; xset dpms force off;;

    date)
        out="  `date '+%a%e %h %k:%M'`";;

    forecast)
        url="http://$api/data/2.5/forecast/daily?id=$id&APPID=$appid&units=metric&cnt=$forecastnbday"
        json=`curl -sL "$url"`

        if [ $? -eq 0 ]; then
            for i in $( seq 0 $((forecastnbday-1)) ); do
              ico=`echo "$json" | python3 -c "import sys, json; print(json.load(sys.stdin)['list'][$i]['weather'][0]['id'])"`
              out="`iconImg $ico`$out"
            done
        else
            out="☀?"
        fi;;

    load)
        load=`cat /proc/loadavg | grep -Pio '\d.\d' | head -1 | awk '{printf("%.1f",$1)}' | xargs`
        cpu="`lscpu | grep 'CPU MHz' | grep -Pio "\d+" | head -n1 | awk '{printf("%.1f",$1/1000)}' | xargs`"
        out="$cpu $load";;

    lock) # create lock session
        ;;

    memory)
        root=`df -h --output=avail / | xargs | grep -Po '\d+'`
        home=`du -sh -x /home/ionl | grep -Po '\d+'`
        hdd=`df -h --output=avail /home/ionl/2TO | xargs | grep -Po '\d+'`
        ram=`free -m | grep Mem | awk '{print ($4+$6)/1024}' | grep -Po '^\d+'`
        out="$root$hdd $home $ram";;

    monitor)
        EXTERNAL_OUTPUT="HDMI2"
        INTERNAL_OUTPUT="LVDS1"

        if [ ! -f "/tmp/monitor_mode.dat" ]; then
            # if we don't have a file, start at zero
            monitor_mode="all"
        else
            # otherwise read the value from the file
            monitor_mode=`cat /tmp/monitor_mode.dat`
        fi

        if [ $monitor_mode = "all" ]; then
            monitor_mode="EXTERNAL"
            xrandr --output $INTERNAL_OUTPUT --off --output $EXTERNAL_OUTPUT --mode 1920x1080
        elif [ $monitor_mode = "EXTERNAL" ]; then
            monitor_mode="INTERNAL"
            xrandr --output $INTERNAL_OUTPUT --mode 1366x768 --primary --output $EXTERNAL_OUTPUT --off
        elif [ $monitor_mode = "INTERNAL" ]; then
            monitor_mode="CLONES"
            xrandr --output $INTERNAL_OUTPUT --mode 1366x768 --output $EXTERNAL_OUTPUT --mode 1920x1080 --same-as $INTERNAL_OUTPUT
        else
            monitor_mode="all"
            xrandr --output $INTERNAL_OUTPUT --mode 1366x768 --output $EXTERNAL_OUTPUT --mode 1920x1080 --right-of $INTERNAL_OUTPUT
        fi
        echo "${monitor_mode}" > /tmp/monitor_mode.dat;;

    network)
        ip=`curl -s ipinfo.io/ip` #ip=`curl -s ifconfig.me/ip`
        eth0=0                    #eth0=`ifconfig enp0s25 | grep 'inet ' | wc -l`
        #wifi=`tlp-stat -r | grep "wifi " | xargs`
        ssid=
        #rate=" `iwlist wlp3s0 bitrate | xargs | egrep -o '[0-9]{2,}'`Mb/s"
        rate=
        bluetooth=
        download=

        #  public ip
        icn=""
        for i in "${ip_pub[@]}";
        do
            if [ "$ip" == "$i" ]; then
                icn="${ip_icn[1]}";
                break
            fi
        done

        #  wired network
        # if [ $eth0 == 1 ]; then eth0=""; else eth0=""; fi;

        #   wifi network
        # if [ "$wifi" == "wifi = on" ]; then wifi=""; else wifi="睊"; fi;

        #  bluetooth card

        ##  download
        out="$wifi$rate$eth0$ip"
        out=$icn;;

    package)
        i_ori=`pacman -Qent | wc -l`          # Packages installed by user
        i_aur=`pacman -Qm   | wc -l`          # Foreign packages (AUR)
        i_snd=`snap list | head -n-2 | wc -l` # Snap packages (canonical)
        i_pak=`flatpak list --app | wc -l`    # Flatpak packages (gnome)
        u_ori=`trizen -Qu  | wc -l`           # Arch packages to upgrade
        u_aur=`trizen -Qua | wc -l`           # AUR packages to upgrade
        orphan=`pacman -Qdt | wc -l`          # Orphans packages

        if [ "$u_ori" -gt "0" ]; then u_ori="u$u_ori";    else u_ori=;  fi;
        if [ "$u_aur" -gt "0" ]; then u_aur="u$u_aur";    else u_aur=;  fi;
        if [ "$orphan" != "0" ]; then orphan="💀$orphan"; else orphan=; fi;

        out="`logoDistribution`[$i_ori$u_ori $i_aur$u_aur $i_snd $i_pak]$orphan";;

    printscreen)
        params="-window root"
        screenshot=${screenshot_dest}$( date '+%Y-%m-%d_%H-%M-%S' )_screenshot.png
        import ${params} ${screenshot}
        xclip -selection clipboard -target image/png -i < ${screenshot};;

    sensors)
        if [ "$method" == "sensors" ]; then
            tmp=`sensors | grep temp1 | grep -Pio '\d+' | awk 'NR==2'`
            #fan="`sensors | grep fan1 | grep -Pio '\d+' | sed '2!d'`↺"
            tst=`sensors | grep -Pi fan1 | grep -Pio '\d'`
            fan="$(echo "$tst" | awk 'NR==2')k$(echo "$tst" | awk 'NR==3')↺"
        else
            tlp=`tlp-stat -t`
            tmp="$(echo "$tlp" | grep temp  | xargs | cut -d' ' -f4)"
            fan="$(echo "$tlp" | grep speed | xargs | cut -d' ' -f5)↺"
        fi;

        # thermometer icon
        if   [ "$tmp" -gt "80" ]; then thm="";
        elif [ "$tmp" -gt "60" ]; then thm="";
        elif [ "$tmp" -gt "40" ]; then thm="";
        elif [ "$tmp" -gt "20" ]; then thm="";
        elif [ "$tmp" -gt  "0" ]; then thm="";
        else                           thm=""; fi;
        tmp="$thm$tmp°"

        # uptime
        upt="`uptime -p | grep -Pio '\d+ (min|days|hours),' | sed 's/\(in\|ours\|ays\),//g' | sed 's/ //g' | head -n1`"

        # output
        out="$tmp $fan $upt";;

    system) # all planified task (1 time per day)
        trizen -Syy                                   # refresh local database
        sudo pacman -Sc  --noconfirm                  # remove all cache (used and unused packages)
        sudo pacman -Rns --noconfirm `pacman -Qdtq`;; # remove orphans

    weather)
        # parse json python3 -c "import sys, json; print(json.load(sys.stdin)['weather'][0]['main'])"
        out="?"
        url="http://$api/data/2.5/weather?id=$id&APPID=$appid&units=metric"
        json=`curl -sL "$url"`

        if [ $? -eq 0 ]; then
            icon=`echo "$json" | python3 -c "import sys, json; print(json.load(sys.stdin)['weather'][0]['id'])"`
            icon=`iconImg $icon`
            info=`echo "$json" | python3 -c "import sys, json; print(json.load(sys.stdin)['weather'][0]['main'])"`

            # temperature
            tmp=`echo $json | grep -Pio '"temp":\d+' | sed 's/"temp"://'`
            if   [ "$tmp" -gt "35" ]; then tmp="$tmp";
            elif [ "$tmp" -gt "25" ]; then tmp="$tmp";
            elif [ "$tmp" -gt "15" ]; then tmp="$tmp";
            elif [ "$tmp" -gt  "2" ]; then tmp="$tmp";
            elif [ "$tmp" -lt  "3" ]; then tmp="$tmp";
            fi;
            tmp="$tmp°"

            pres="`echo $json | grep -Pio '"pressure":\d+' | sed 's/"pressure"://'`"
            humi="`echo $json | grep -Pio '"humidity":\d+' | sed 's/"humidity"://'`%"
            spee=`echo $json | grep -Pio '"speed":[\d.]+' | sed 's/"speed"://'`
            spee=`echo "$spee * 3.6" | bc -l`
            spee="${spee%\.*}"
            beau="`windPower $spee`"
            spee="${spee}km/h"
            wind=`echo $json | grep -Pio '"deg":\d+' | sed 's/"deg"://'`
            wind="`windDirection $wind`"

            out="$tmp $pres $icon $humi $wind$spee$beau"
        fi;;
    *) ;;
esac

echo "$out";
exit 0;
