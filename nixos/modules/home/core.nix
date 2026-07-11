{ config, pkgs, lib, ... }:

{
  home = {
    username = "syaofox";
    homeDirectory = "/home/syaofox";
    stateVersion = "24.11";
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    DOCKER_BUILDKIT = "1";
  };

  home.packages = with pkgs; [
    # X11 tools
    xorg.xrdb
    xorg.xset
    xorg.xsetroot
    xorg.xrandr
    xdotool
    xss-lock
    xclip
    xfce.xfce4-clipman-plugin
    numlockx
    xwallpaper
    libnotify
    gnome-keyring

    # Desktop
    picom
    dunst
    networkmanagerapplet
    blueman
    polkit_gnome
    pasystray
    udiskie
    pavucontrol
    nwg-look
    zenity
    maim

    # Terminal tools
    eza
    bat
    ripgrep
    fd
    fzf
    zoxide
    thefuck
    trash-cli
    lazygit
    htop
    nvtop
    fastfetch
    calcurse
    jq

    # Media
    mpv
    gthumb
    imagemagick
    ffmpeg
    mediainfo

    # Archives
    unzip
    p7zip

    # Python (required by generate-app-themes)
    python3

    # Development
    nodejs
    nodePackages.npm
    uv
    vscode

    # Browsers
    chromium

    # Other
    qalculate-gtk
    uget
    aria2

    # Overlay packages
    dwm
    slstatus
    slock
    wallpick
    sysmenu
    generate-app-themes
  ];
}
