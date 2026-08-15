{ lib, inputs }:
let
  autoImport =
    excludes: dir:
    let
      entries = builtins.readDir dir;
      importable = lib.filterAttrs (
        name: type:
        !(lib.elem name excludes)
        && (
          (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
          || (type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
        )
      ) entries;
    in
    lib.mapAttrsToList (name: _: dir + "/${name}") importable;
in
{
  inherit autoImport;

  mkHost =
    hostname: cfg:
    let
      isDarwin = lib.hasSuffix "-darwin" cfg.system;
      builder =
        cfg.builder
          or (if isDarwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem);

      hmModule =
        if isDarwin then
          inputs.home-manager.darwinModules.home-manager
        else
          inputs.home-manager.nixosModules.home-manager;
    in
    builder {
      system = cfg.system;
      specialArgs = {
        inherit inputs hostname;
        inherit (cfg) username;
        mylib = import ../lib { inherit lib inputs; };
      }
      // (cfg.extraSpecialArgs or { });

      modules = [
        ../modules
        ../services
        ../hosts/${hostname}/configuration.nix
        hmModule
        (if isDarwin then inputs.sops-nix.darwinModules.sops else inputs.sops-nix.nixosModules.sops)
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs hostname;
              inherit (cfg) username;
              mylib = import ../lib { inherit lib inputs; };
            };
            sharedModules = [ ../modules/home ];
            users.${cfg.username}.imports = [ ../hosts/${hostname}/home.nix ];
          };
        }
      ]
      ++ lib.optional (!isDarwin) ../hosts/${hostname}/hardware-configuration.nix
      ++ (cfg.extraModules or [ ]);
    };
}
