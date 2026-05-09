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

pgrep -f "polkit-gnome-authentication" >/dev/null 2>&1 ||
    /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &

if command -v numlockx >/dev/null 2>&1; then
    numlockx on &
else
    log "numlockx not installed, skipping"
fi

for svc in xsettingsd dunst slstatus pasystray nm-applet blueman-applet xfce4-clipman; do
    if pgrep -x "$svc" >/dev/null 2>&1; then
        log "$svc already running, skipping"
    else
        log "Starting $svc..."
        $svc >/dev/null 2>&1 &
    fi
done

if pgrep -x fcitx5 >/dev/null 2>&1; then
    log "fcitx5 already running, skipping"
else
    log "Starting fcitx5..."
    fcitx5 -d &
fi


log "Starting picom..."
picom --config "$HOME/.config/picom/picom.conf" -b &

if command -v xwallpaper >/dev/null; then
    WALLPAPER_CONF="$HOME/.config/wallpaper.conf"
    WALLPAPER=$([[ -f "$WALLPAPER_CONF" ]] && [[ -s "$WALLPAPER_CONF" ]] && cat "$WALLPAPER_CONF" || echo "$HOME/.config/walls/nord-2.png")
    log "Setting wallpaper: $WALLPAPER"
    xwallpaper --zoom "$WALLPAPER" &
else
    err "xwallpaper not found, wallpaper not set"
fi

systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
