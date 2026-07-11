{ config, pkgs, ... }:

{
  home.file = {
    ".Xresources".source = ../../config/.Xresources;
    ".Xresources.d".source = ../../config/Xresources.d;
  };
}
