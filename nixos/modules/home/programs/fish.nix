{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      grep = "rg";
    };

    shellInit = ''
      set fish_color_autosuggestion 565f89
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    fisher
  ];
}
