{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.oauth2-proxy;
  baseDomain = config.my.services.caddy.hostName; # CHANGED variable name for clarity
in
{
  options.my.services.oauth2-proxy.enable = lib.mkEnableOption "oauth2-proxy OIDC gateway";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.oauth2-proxy = {
      enable = true;
      provider = "oidc";

      oidcIssuerUrl = "https://auth.${baseDomain}/realms/homelab";

      clientID = "oauth2-proxy";
      clientSecretFile = config.sops.secrets.oauth2-proxy-client-secret.path;
      cookie.secretFile = config.sops.secrets.oauth2-proxy-cookie-secret.path;

      cookie.domain = ".${baseDomain}";

      httpAddress = "127.0.0.1:4180";

      redirectURL = "https://auth.${baseDomain}/oauth2/callback";

      email.domains = [ "*" ];
      setXauthrequest = true;

      extraConfig = {
        whitelist-domain = [ ".${baseDomain}" ];
        insecure-oidc-allow-unverified-email = true;
      };
    };

    sops.secrets.oauth2-proxy-client-secret = {
      restartUnits = [ "oauth2-proxy.service" ];
    };

    sops.secrets.oauth2-proxy-cookie-secret = {
      restartUnits = [ "oauth2-proxy.service" ];
    };

    # UPDATED: Handle OAuth2 endpoints on auth subdomain, before Keycloak catch-all
    services.caddy.virtualHosts."auth.${baseDomain}".extraConfig = lib.mkBefore ''
      handle /oauth2/* {
        reverse_proxy 127.0.0.1:4180
      }
    '';
  };
}
