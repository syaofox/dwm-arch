{
  description = "syaofox's NixOS configuration — DWM desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, agenix, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        main = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self agenix; };
          modules = [
            {
              nixpkgs.overlays = [ (import ./overlays) ];
              nixpkgs.config.allowUnfree = true;
            }
            ./hosts/main
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit self; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.syaofox = import ./modules/home;
              };
            }
          ];
        };
      };

      homeConfigurations = {
        "syaofox@main" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ (import ./overlays) ];
          };
          extraSpecialArgs = { inherit self; };
          modules = [ ./modules/home ];
        };
      };
    };
}
