#!/bin/bash
log() { echo "[$(date +'%H:%M:%S')] $*"; }
err() { echo "[$(date +'%H:%M:%S')] ERROR: $*" >&2; }

LOGDIR="/tmp/dwm"
LOGFILE="$LOGDIR/dwm.log"
mkdir -p "$LOGDIR"
exec > >(tee -a "$LOGFILE") 2>&1
log "=== DWM session starting (PID: $$) ==="



command -v dbus-update-activation-environment >/dev/null &&
    dbus-update-activation-environment --systemd --all

pgrep -f "polkit-gnome-authentication" >/dev/null ||
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null &


if command -v numlockx >/dev/null; then
    numlockx on &
else
    log "numlockx not installed, skipping"
fi

# blueman-applet
for svc in xsettingsd dunst slstatus pasystray nm-applet xfce4-clipman; do
    if pgrep -x "$svc" >/dev/null; then
        log "$svc already running, skipping"
    else
        log "Starting $svc..."
        $svc >/dev/null &
    fi
done

if pgrep -x fcitx5 >/dev/null; then
    log "fcitx5 already running, skipping"
else
    log "Starting fcitx5..."
    fcitx5 -d &
fi


if pgrep -x picom >/dev/null 2>&1; then
    log "picom already running, skipping"
else
    log "Starting picom..."
    picom --config "$HOME/.config/picom/picom.conf" -b &
fi

if command -v xwallpaper >/dev/null; then
    WALLPAPER_CONF="$HOME/.config/wallpaper.conf"
    WALLPAPER=$([[ -f "$WALLPAPER_CONF" ]] && [[ -s "$WALLPAPER_CONF" ]] && cat "$WALLPAPER_CONF" || echo "$HOME/.config/walls/nord-2.png")
    log "Setting wallpaper: $WALLPAPER"
    xwallpaper --zoom "$WALLPAPER" &
else
    err "xwallpaper not found, wallpaper not set"
fi

systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
