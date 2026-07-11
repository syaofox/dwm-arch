{ lib, ... }:

{
  security = {
    polkit.enable = true;

    pam.services.login.faillock = {
      enable = false;
    };
  };

  services.accounts-daemon.enable = true;
}
