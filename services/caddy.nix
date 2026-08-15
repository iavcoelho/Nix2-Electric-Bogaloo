{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.caddy;
in
{
  options.my.services.caddy = {
    enable = lib.mkEnableOption "Caddy reverse proxy";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "creampie.home";
      readOnly = true;
      description = "Base domain for services";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.caddy = {
      enable = true;
      globalConfig = ''
        acme_ca https://100.93.161.49:6060/acme/acme/directory
        acme_ca_root ${../certs/step-ca-root.pem}
      '';
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
      80
      443
    ];

  };
}
