{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.radicale;
  baseDomain = config.my.services.caddy.hostName;
in
{
  options.my.services.radicale.enable = lib.mkEnableOption "Radicale CalDAV/CardDAV server";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.radicale = {
      enable = true;

      settings = {
        server.hosts = [
          "127.0.0.1:5232"
        ];

        auth.type = "http_x_remote_user";

        # The web UI probes for existing auth with a fetch that omits cookies
        # unless this is enabled; with X-Remote-User auth the browser must
        # send the oauth2-proxy session cookie through the dav gate instead
        # of showing radicale's own login form.
        web.prefer_browser_login = true;
      };
    };

    # UPDATED: Dedicated dav subdomain, no path prefix needed
    services.caddy.virtualHosts."dav.${baseDomain}".extraConfig = lib.mkAfter ''
      redir /.well-known/caldav / 301
      redir /.well-known/carddav / 301

      # Optional: redirect /dav to root for compatibility
      redir /dav / permanent

      handle {
        # forward_auth shorthand, expanded to add a redirect for
        # unauthenticated requests: oauth2-proxy /oauth2/auth replies 401
        # (no Location header), which we translate into the SSO login flow.
        reverse_proxy 127.0.0.1:4180 {
          method GET
          rewrite /oauth2/auth
          header_up X-Forwarded-Method {method}
          header_up X-Forwarded-Uri {uri}

          @good status 2xx
          handle_response @good {
            request_header X-Auth-Request-User {rp.header.X-Auth-Request-User}
            request_header X-Auth-Request-Email {rp.header.X-Auth-Request-Email}
          }

          @unauthorized status 401
          handle_response @unauthorized {
            redir https://auth.${baseDomain}/oauth2/start?rd={scheme}://{host}{uri} temporary
          }
        }

        reverse_proxy 127.0.0.1:5232 {
          header_up X-Remote-User {http.request.header.X-Auth-Request-User}
        }
      }
    '';
  };
}
