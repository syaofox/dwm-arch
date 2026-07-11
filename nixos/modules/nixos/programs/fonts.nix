{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    dejavu_fonts
    wqy_zenhei
    jetbrains-mono
    terminus_font
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "DejaVu Sans Mono" "Noto Sans Mono CJK SC" ];
      sansSerif = [ "DejaVu Sans" "Noto Sans CJK SC" ];
      serif = [ "DejaVu Serif" "Noto Serif CJK SC" ];
    };
  };
}
