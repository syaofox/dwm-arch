{ inputs, ... }:

{
  # Add nixos-hardware profile here, e.g.:
  # imports = [ inputs.nixos-hardware.nixosModules.common-cpu-intel ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];
}
