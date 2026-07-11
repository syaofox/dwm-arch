{ config, lib, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.gtk = {
          enable = true;
          theme = {
            package = pkgs.mint-themes;
            name = "Mint-Y-Dark-Purple";
          };
          iconTheme = {
            package = pkgs.mint-y-icons;
            name = "Mint-Y-Purple";
          };
          cursorTheme = {
            package = pkgs.mint-y-icons;
            name = "Mint-Y-Purple";
          };
        };
        extraSeatDefaults = ''
          user-session = dwm
        '';
      };
      excludePackages = with pkgs; [ xterm ];
    };
  };
}
