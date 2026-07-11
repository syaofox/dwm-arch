{
  imports = [
    ./boot.nix
    ./security.nix
    ./sysctl.nix
    ./users.nix
    ./desktop/dwm.nix
    ./desktop/lightdm.nix
    ./hardware/nvidia.nix
    ./hardware/audio.nix
    ./programs/fonts.nix
    ./programs/fcitx5.nix
    ./programs/docker.nix
    ./programs/nix.nix
    ./services/zram.nix
  ];
}
