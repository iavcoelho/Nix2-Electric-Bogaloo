{
  description = "Multi-host Nix configuration";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      mylib = import ./lib { inherit lib inputs; };

      hosts = {
        creampie = {
          system = "aarch64-linux";
          username = "admin";

          builder = inputs.nixos-raspberrypi.lib.nixosSystem;

          extraModules = [
            inputs.hermes-agent.nixosModules.default
            inputs.nixos-raspberrypi.nixosModules.trusted-nix-caches
            inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
            inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
          ];

          extraSpecialArgs = {
            inherit (inputs) nixos-raspberrypi;
          };
        };

        macbook = {
          system = "aarch64-darwin";
          username = "iavcoelho";
        };

        mitnick = {
          system = "aarch64-linux";
          username = "ashe";
        };
      };

      isDarwin = _: cfg: lib.hasSuffix "-darwin" cfg.system;
    in
    {
      nixosConfigurations = lib.mapAttrs mylib.mkHost (lib.filterAttrs (n: c: !(isDarwin n c)) hosts);

      darwinConfigurations = lib.mapAttrs mylib.mkHost (lib.filterAttrs isDarwin hosts);
    };
}
