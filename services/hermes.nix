{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.hermes;
  baseDomain = config.my.services.caddy.hostName;

  defaultSettings = {
    extraDependencyGroups = [ "messaging" ];
    platforms = {
      discord.enabled = true;
    };
  };

  dashboardSettings = lib.optionalAttrs cfg.dashboard.enable {
    dashboard = {
      public_url = "https://hermes.${baseDomain}";
      oauth = {
        provider = "self-hosted";
        self_hosted = {
          issuer = "https://auth.${baseDomain}/realms/homelab";
          client_id = "hermes-dashboard";
        };
      };
    };
  };
in
{
  options.my.services.hermes = {
    dashboard.enable = lib.mkEnableOption "Hermes AI companion WebUI";

    enable = lib.mkEnableOption "Hermes AI companion";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Hermes settings that override this module's defaults.";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.hermes-agent = {
      enable = true;

      # Merge order: built-in defaults < dashboard configuration < host overrides.
      settings = lib.recursiveUpdate defaultSettings (lib.recursiveUpdate dashboardSettings cfg.settings);

      extraPlugins = [
        (pkgs.fetchFromGitHub {
          owner = "stephenschoettler";
          repo = "hermes-lcm";
          rev = "v0.20.0";
          hash = "sha256-yJ1Nn+su7YbKd+cgVOizXChzLbKHqTprSprF1p9/HYk=";
        })
      ];

      environmentFiles = [ config.sops.secrets.hermes-env.path ];
      addToSystemPackages = true;
      extraPackages = with pkgs; [
        uv
        python3
        poppler-utils
        typst
        wget
        curl
        git
        typst
      ];
    };

    fonts.packages = with pkgs; [
      liberation_ttf
    ];

    sops.secrets.hermes-env = {
      restartUnits = [
        "hermes-agent.service"
      ]
      ++ lib.optionals cfg.dashboard.enable [ "hermes-dashboard.service" ];
    };

    services.caddy.virtualHosts."hermes.${baseDomain}".extraConfig = lib.mkAfter ''
      reverse_proxy 127.0.0.1:9119
    '';

    systemd.services.hermes-agent.serviceConfig.Environment = [
      "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
      "REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt"
    ];

    systemd.services.hermes-dashboard = lib.mkIf cfg.dashboard.enable {
      description = "Hermes Agent Dashboard";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [
        config.services.hermes-agent.package
        pkgs.bash
        pkgs.coreutils
        pkgs.git
      ];

      serviceConfig = {
        EnvironmentFile = [ config.sops.secrets.hermes-env.path ];
        User = config.services.hermes-agent.user;
        Group = config.services.hermes-agent.group;
        WorkingDirectory = config.services.hermes-agent.workingDirectory;

        Environment = [
          "HERMES_HOME=${config.services.hermes-agent.stateDir}/.hermes"
          "HERMES_MANAGED=true"
          "HOME=${config.services.hermes-agent.stateDir}"
          "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
          "REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt"
        ];

        ExecStart = "${config.services.hermes-agent.package}/bin/hermes dashboard --host 0.0.0.0 --port 9119 --no-open --skip-build";
        Restart = "always";
        RestartSec = 5;
        UMask = "0007";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = false;
        PrivateTmp = true;

        ReadWritePaths = [
          config.services.hermes-agent.stateDir
          config.services.hermes-agent.workingDirectory
        ];
      };
    };
  };
}
