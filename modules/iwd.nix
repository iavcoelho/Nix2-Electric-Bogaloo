{ lib, config, pkgs, ... }:
let cfg = config.my.modules.iwd; in
{
  options.my.modules.iwd = {
    enable = lib.mkEnableOption "iwd wireless networking";
    mdns = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    networking = {
      useNetworkd = true;
      wireless.enable = false;
      wireless.iwd = {
        enable = true;
        settings = {
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
          Settings.AutoConnect = true;
        };
      };
    };

    systemd.network.networks = lib.mkIf cfg.mdns {
      "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
      "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
    };

    systemd.services = {
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };

    networking.firewall.allowedUDPPorts = lib.mkIf cfg.mdns [ 5353 ];
  };
}
