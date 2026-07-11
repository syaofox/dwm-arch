{ config, lib, pkgs, ... }:

{
  users = {
    mutableUsers = false;

    users.syaofox = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "render"
        "audio"
        "docker"
      ];
      shell = pkgs.fish;
      initialPassword = "changeme";
    };
  };

}
