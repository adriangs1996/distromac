#!/bin/bash
export PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
export OX_BG="0xff24202c"
export OX_FG="0xfff4cde9"
export OX_DIM="0xff6f5a71"
export OX_MG="0xffad7fa8"
export OX_ORG="0xfff99286"
export SPACE_ICONS=("􀊴" "􀌃" "􀨁" "􀢅" "􀰬" "􀧶" "􁸅" "􀟆" "􁷯")

 sb_separator() {
	sepName="sep$RANDOM"
	sketchybar \
		--add item "$sepName" "$1" \
		--set "$sepName" \
		\
		label="───────" \
		padding_left="$2" \
		padding_right="$3" \
		icon.drawing=off \
		label.font.size=9.0 \
		label.color="$OX_DIM"
}

sb_vertical_time() {

	sketchybar --add item clock.minute right \
		--set clock.minute \
		update_freq=1 \
		script="sketchybar --set \$NAME label=\"\$(date '+%M')\"" \
		icon.drawing=off \
		label.color="0xff89DCEB" \
		label.font="Hack Nerd Font:Bold:22.0" \
		padding_right=8 \
		padding_left=2 \
		background.drawing=off

	sketchybar --add item clock.separator right \
		--set clock.separator \
		icon.drawing=off \
		label="---" \
		padding_right=2 \
		padding_left=2

	sketchybar --add item clock.hour right \
		--set clock.hour \
		update_freq=1 \
		script="sketchybar --set \$NAME label=\"\$(date '+%H')\"" \
		icon.drawing=off \
		label.font="Hack Nerd Font:Bold:22.0" \
		label.color="0xff89DCEB" \
		padding_right=2 \
		padding_left=2 \
		background.drawing=off
	
	sketchybar --add item clock.icon right \
		--set clock.icon \
		icon="" \
		icon.font="Hack Nerd Font:Bold:30.0" \
		icon.color="0xffCBA6F7" \
		padding_right=8 \
		padding_left=8 \
		label.drawing=off
		# icon.color="0xff89DCEB" 
}
