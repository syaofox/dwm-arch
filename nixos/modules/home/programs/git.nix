{ ... }:

{
  programs.git = {
    enable = true;
    userName = "syaofox";
    userEmail = "syaofox@gmail.com";
    lfs.enable = true;

    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --all";
      ls = "log --oneline --graph --decorate";
      co = "checkout";
      ci = "commit";
      br = "branch";
      ac = "!git add -A && git commit";
      ce = "commit --allow-empty -m";
      cem = "commit --allow-empty -m";
    };
  };
}
