{ config, lib, pkgs, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload = {
          enable = lib.mkDefault false;
          enableOffloadCmd = lib.mkDefault false;
        };
      };
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
