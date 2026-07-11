{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      confirm_os_window_close = 0;
      background_opacity = "0.95";
      hide_window_decorations = "yes";
    };
    extraConfig = ''
      include theme.conf
    '';
  };

  xdg.configFile."kitty/theme.conf".text = "";
}
