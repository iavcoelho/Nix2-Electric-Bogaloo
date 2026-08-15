{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.modules.podman;
in
{
  options.my.modules.podman = {
    enable = lib.mkEnableOption "iwd wireless networking";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
    };
  };
}
