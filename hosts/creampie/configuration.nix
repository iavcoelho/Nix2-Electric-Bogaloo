{ username, ... }:
{
  networking.hostName = "creampie";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "hermes"
    ];
  };

  boot = {
    tmp.useTmpfs = true;
    loader.raspberry-pi.bootloader = "kernel";
  };

  my.modules = {
    iwd.enable = true;
    shell.enable = true;
    podman.enable = true;
    sops = {
      enable = true;
      secretsFile = ../../secrets/creampie.yaml;
    };
  };

  my.services = {
    openssh.enable = true;
    tailscale.enable = true;
    step-ca.enable = true;
    caddy.enable = true;
    keycloak.enable = true;
    oauth2-proxy.enable = true;
    radicale.enable = true;
    adguard.enable = true;
    hermes = {
      enable = true;
      dashboard.enable = true;
      settings = {
        mcp_servers = {
          hound = {
            url = "http://127.0.0.1:8765/mcp";
          };
        };
        model = {
          default = "deepseek-v4-flash";
          provider = "opencode-go";
          base_url = "https://opencode.ai/zen/go/v1";
        };

        plugins.enabled = [
          "hermes-lcm"
        ];

        context.engine = "lcm";

        agent = {
          reasoning_overrides = {
            "deepseek-v4-flash" = "low";
          };
        };
      };
    };
  };

  system.stateVersion = "26.05";
}
