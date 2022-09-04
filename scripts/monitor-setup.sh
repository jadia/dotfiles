#!/usr/bin/env bash

#declare -a modes=( extended hdmi-only lcd-only mirrored )
declare -a modes=( extended lcd-only )
declare -a dock_modes=( dual triple )

MONITOR_SETUP="/tmp/monitor_setup"
I3_RESTART="/usr/bin/i3-msg restart"
WALLPAPER_RESET="feh --bg-scale --randomize /home/nitish/dotfiles/wallpapers/*"
LAPTOP_DISPLAY="eDP-1" #5402
SECOND_DISPLAY="HDMI-1" #5402
# Dual Monitors
LEFT_DISPLAY="DP-1-1-8"
RIGHT_DISPLAY="DP-1-1-1"


# DISPLAY_RESET="xrandr --output $LAPTOP_DISPLAY --auto --primary --dpi 96 --output $SECOND_DISPLAY --off"
DISPLAY_RESET="xrandr --output $LAPTOP_DISPLAY --auto --primary --output $SECOND_DISPLAY --off --output $LEFT_DISPLAY --off --output $RIGHT_DISPLAY --off"

function get_index {
	value="$@"
	if [[ ${value} = "lcd-only" || ${value} = "triple" || ${value} = "" ]] ; then 
		current_index=-1
		return 0
	fi

	if [[ ${value} = "dual" || ${value} = "triple" ]] ; then
		for i in "${!dock_modes[@]}"; do
		if [[ "${dock_modes[$i]}" = "${value}" ]]; then
			current_index=${i}
		fi
		done
	else
		#${!modes[@]} return the index; ${modes[@]} will return the element.
		for i in "${!modes[@]}"; do
		if [[ "${modes[$i]}" = "${value}" ]]; then
			current_index=${i}
		fi
		done
	fi
}

function switch_setup {
	case "$@" in
		"extended" )
			xrandr --auto && xrandr --output $SECOND_DISPLAY --primary --left-of $LAPTOP_DISPLAY
			echo "extended" > $MONITOR_SETUP
			$I3_RESTART
			$WALLPAPER_RESET

		;;
		"dual" )
			xrandr --output eDP-1 --off --output HDMI-1 --off --output DP-1 --off --output DP-1-1 --off --output DP-1-1-8 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-1-1-1 --mode 1920x1080 --pos 3840x0 --rotate normal
			echo "dual" > $MONITOR_SETUP
			$I3_RESTART
			$WALLPAPER_RESET

		;;
		"triple" )
			xrandr --output eDP-1 --mode 1920x1080 --pos 2834x1080 --rotate normal --output HDMI-1 --off --output DP-1 --off --output DP-1-1 --off --output DP-1-1-8 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-1-1-1 --mode 1920x1080 --pos 3840x0 --rotate normal
			echo "dual" > $MONITOR_SETUP
			$I3_RESTART
			$WALLPAPER_RESET

		;;
		"lcd-only" )
			xrandr --auto && xrandr --output $SECOND_DISPLAY --off --output $LAPTOP_DISPLAY --primary --dpi 96
			echo "lcd-only" > $MONITOR_SETUP
			$I3_RESTART
			$WALLPAPER_RESET

		;;
		"hdmi-only" )
			xrandr --auto && xrandr --output $SECOND_DISPLAY --primary --output $LAPTOP_DISPLAY --off
			echo "hdmi-only" > $MONITOR_SETUP
			$I3_RESTART
			$WALLPAPER_RESET
		;;		
		"mirrored" )
			xrandr --auto && xrandr --output $SECOND_DISPLAY --primary --same-as $LAPTOP_DISPLAY --output $LAPTOP_DISPLAY
			echo "hdmi-only" > $MONITOR_SETUP
			$I3_RESTART
			$WALLPAPER_RESET
		;;
		* | "" )
			echo "" > $MONITOR_SETUP
			$DISPLAY_RESET
			$I3_RESTART
			$WALLPAPER_RESET
		;;
	esac
}

if [ -e $MONITOR_SETUP ]; then
	CURRENT_SETUP=$(cat $MONITOR_SETUP)
else
	echo "" > $MONITOR_SETUP
	$DISPLAY_RESET
	$I3_RESTART
	$WALLPAPER_RESET
fi

if xrandr|grep -q "$SECOND_DISPLAY connected"; then
	get_index $CURRENT_SETUP
	index=$(( current_index + 1 ))
	switch_setup ${modes[$index]}
	echo ${modes[$index]} > $MONITOR_SETUP
elif xrandr|grep -q "$LEFT_DISPLAY connected"; then
	get_index $CURRENT_SETUP
	echo "current_index"
	echo $current_index
	index=$(( current_index + 1 ))
	switch_setup ${dock_modes[$index]}
	echo ${dock_modes[$index]} > $MONITOR_SETUP
else
	rm $MONITOR_SETUP
	$DISPLAY_RESET
	$I3_RESTART
	$WALLPAPER_RESET
fi
