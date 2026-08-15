{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.adguard;
  baseDomain = config.my.services.caddy.hostName;
in
{
  options.my.services.adguard.enable = lib.mkEnableOption "AdGuard Home DNS";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.adguardhome = {
      enable = true;
      mutableSettings = true;

      host = "0.0.0.0";
      port = 3000;

      settings = {
        dns = {
          bind_hosts = [
            "100.93.161.49"
            "127.0.0.1"
          ];
          port = 53;

          upstream_dns = [
            "https://dns.quad9.net/dns-query"
          ];

          bootstrap_dns = [
            "9.9.9.9"
            "149.112.112.112"
          ];

          allowed_clients = [ ];
          use_private_ptr_resolvers = false;
        };

        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          parental_enabled = false;
          safe_search = {
            enabled = false;
          };

          # DNS rewrites for your local subdomains
          rewrites = [
            {
              domain = "${baseDomain}";
              answer = "100.93.161.49";
            }
            {
              domain = "*.${baseDomain}";
              answer = "100.93.161.49";
            }
          ];
        };

      };
    };

    networking.firewall.interfaces = {
      tailscale0 = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [ 53 ];
      };

      end0 = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [ 53 ];
      };

      wlan0 = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [ 53 ];
      };
    };

    networking.nameservers = [ "127.0.0.1" ];

    # AdGuard web interface on its own subdomain
    services.caddy.virtualHosts."adguard.${baseDomain}".extraConfig = lib.mkAfter ''
      reverse_proxy 127.0.0.1:3000
    '';
  };
}
