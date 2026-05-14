#!/bin/bash

[ -f "$HOME/.profile" ] && . "$HOME/.profile"

exec "$HOME/.local/share/dwm/dwm-session.sh"