{ ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      -- LazyVim will be installed on first run
      -- Theme is managed by generate-app-themes.py
    '';
  };
}
