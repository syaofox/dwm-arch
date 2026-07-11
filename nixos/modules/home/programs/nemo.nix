{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nemo
    nemo-fileroller
    ffmpegthumbnailer
    tumbler
  ];

  home.file = {
    ".local/share/nemo/actions".source = ../../dotfiles/.local/share/nemo/actions;
    ".local/share/nemo/scripts".source = ../../dotfiles/.local/share/nemo/scripts;
  };
}
