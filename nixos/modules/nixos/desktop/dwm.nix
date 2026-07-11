{ config, lib, pkgs, ... }:

let
  dwmSessionPkg = pkgs.writeShellScriptBin "dwm-session" ''
    set -Eeuo pipefail
    DWM_SESSION="$HOME/.local/share/dwm/dwm-session.sh"
    if [[ ! -x "$DWM_SESSION" ]]; then
      echo "ERROR: $DWM_SESSION not found or not executable" >&2
      exit 1
    fi
    exec "$DWM_SESSION"
  '';
in
{
  environment.systemPackages = [ dwmSessionPkg ];

  services.xserver.displayManager.session = [{
    name = "dwm";
    desktop = "dwm";
    start = ''
      exec ${dwmSessionPkg}/bin/dwm-session
    '';
  }];
}
