{ ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    storageDriver = "overlay2";
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };
}
