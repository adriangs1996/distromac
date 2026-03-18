#!/usr/bin/env bash

htbicon=(
  icon=""
  # icon.color="0xffA6E3A1"
  icon.color="0xffa6e3a1"
  # icon.color="0xffCBA6F7"
  # icon.color="0xfff2cdcd"
  icon.font="Hack Nerd Font:Bold:35.0"
  label.drawing=off
  click_script="open -a launchpad"
  icon.padding_left=5
)

sketchybar --add item htbicon left --set htbicon "${htbicon[@]}"
