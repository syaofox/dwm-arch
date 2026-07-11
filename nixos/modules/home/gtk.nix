{ config, pkgs, ... }:

{
  gtk = {
    enable = true;

    font = {
      name = "Noto Sans 11";
      package = pkgs.noto-fonts;
    };

    iconTheme = {
      name = "Mint-Y-Purple";
      package = pkgs.mint-y-icons;
    };

    theme = {
      name = "Mint-Y-Purple";
      package = pkgs.mint-themes;
    };

    cursorTheme = {
      name = "Mint-Y-Purple";
      package = pkgs.mint-y-icons;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
      gtk-decoration-layout = "menu:";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
      gtk-decoration-layout = "menu:";
    };
  };

  qt = {
    enable = true;
    platformTheme = "qtct";
    style.name = "Fusion";
  };

  xdg.configFile = {
    "qt5ct/qt5ct.conf".source = ../../dotfiles/.config/qt5ct/qt5ct.conf;
    "qt6ct/qt6ct.conf".source = ../../dotfiles/.config/qt6ct/qt6ct.conf;
  };
}
