#!/bin/env bash
set -e

if ! test $(pgrep slurp); then
  ACTION=$1
  TMP=/tmp/screenshot.png

  case $ACTION in

  select-copy)
    # wayshot -f $TMP --extension png
    grim -g "$(slurp)" - >$TMP
    ;;

  copy)
    # wayshot -f $TMP --extension png
    grim -c $TMP
    ;;

  *)
    echo Some action needed
    exit 1
    ;;

  esac
fi

wl-copy -t image/png <$TMP

notify-send -a control -t 1500 \
  Screenshot "Copied to clipboard"

# swappy -f $TMP
