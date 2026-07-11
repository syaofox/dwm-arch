{ config, pkgs, ... }:

let
  scripts = {
    dwmcmd = builtins.readFile ../../dotfiles/.local/bin/dwmcmd.sh;
    switch-theme = builtins.readFile ../../dotfiles/.local/bin/switch-theme.sh;
    switch-wallpaper = builtins.readFile ../../dotfiles/.local/bin/switch-wallpaper.sh;
    volume = builtins.readFile ../../dotfiles/.local/bin/volume.sh;
    show-keys = builtins.readFile ../../dotfiles/.local/bin/show-keys.sh;
    run-browser = builtins.readFile ../../dotfiles/.local/bin/run-browser.sh;
    rofi-websites = builtins.readFile ../../dotfiles/.local/bin/rofi-websites.sh;
    "115-merge" = builtins.readFile ../../dotfiles/.local/bin/115-merge.sh;
  };
in
{
  home.packages = builtins.attrValues (builtins.mapAttrs (name: content:
    pkgs.writeShellScriptBin name content
  ) scripts);
}
