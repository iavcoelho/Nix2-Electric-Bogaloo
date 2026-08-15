{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.tailscale;
in
{
  options.my.services.tailscale.enable = lib.mkEnableOption "Enable the Tailscale service";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
    };

    networking.firewall = {
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    systemd.network.wait-online.enable = false;
    boot.initrd.systemd.network.wait-online.enable = false;

    environment.systemPackages = [ pkgs.tailscale ];
  };
}
