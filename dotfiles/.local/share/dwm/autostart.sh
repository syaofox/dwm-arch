#!/bin/bash
log() { echo "[$(date +'%H:%M:%S')] $*"; }
err() { echo "[$(date +'%H:%M:%S')] ERROR: $*" >&2; }

LOGDIR="/tmp/dwm"
LOGFILE="$LOGDIR/dwm.log"
mkdir -p "$LOGDIR"
[ -f "$LOGFILE" ] && [ "$(stat -c%s "$LOGFILE")" -gt 1048576 ] && mv "$LOGFILE" "$LOGFILE.old"
exec > >(tee -a "$LOGFILE") 2>&1
log "=== DWM session starting (PID: $$) ==="

command -v dbus-update-activation-environment >/dev/null &&
    dbus-update-activation-environment --systemd --all

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &

if command -v numlockx >/dev/null 2>&1; then
    numlockx on &
else
    log "numlockx not installed, skipping"
fi

for svc in xsettingsd dunst slstatus nm-applet blueman-applet pasystray xfce4-clipman; do
    log "Starting $svc..."
    $svc &
done

log "Starting fcitx5..."
fcitx5 -d &


log "Starting picom..."
# picom --config "$HOME/.config/picom/picom.conf" -b &

if command -v xwallpaper >/dev/null; then
    WALLPAPER_CONF="$HOME/.config/wallpaper.conf"
    WALLPAPER=$([[ -f "$WALLPAPER_CONF" ]] && [[ -s "$WALLPAPER_CONF" ]] && cat "$WALLPAPER_CONF" || echo "$HOME/.config/walls/nord-2.png")
    log "Setting wallpaper: $WALLPAPER"
    xwallpaper --zoom "$WALLPAPER" &
else
    err "xwallpaper not found, wallpaper not set"
fi

systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
