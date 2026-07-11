{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  xdg.configFile = {
    "yazi/yazi.toml".source = ../../dotfiles/.config/yazi/yazi.toml;
    "yazi/keymap.toml".source = ../../dotfiles/.config/yazi/keymap.toml;
    "yazi/theme.toml".source = ../../dotfiles/.config/yazi/theme.toml;
    "yazi/flavors".source = ../../dotfiles/.config/yazi/flavors;
    "yazi/plugins/mv-dir.yazi".source = ../../dotfiles/.config/yazi/plugins/mv-dir.yazi;
    "yazi/plugins/rsync-paste.yazi".source = ../../dotfiles/.config/yazi/plugins/rsync-paste.yazi;
  };
}
