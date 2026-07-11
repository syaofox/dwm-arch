{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    cycle = true;
    pass = { enable = true; };
  };
}
