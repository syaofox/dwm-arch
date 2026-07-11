{ config, pkgs, ... }:

{
  home.file = {
    ".local/share/fcitx5/themes/dwm".source = ../../dotfiles/.local/share/fcitx5/themes/Material-Color-Cyan;
    ".config/fcitx5/conf/classicui.conf".text = ''
      Theme=dwm
      DarkTheme=dwm-dark
      Font="Noto Sans CJK SC 11"
      Vertical Candidate List=False
    '';
  };
}
