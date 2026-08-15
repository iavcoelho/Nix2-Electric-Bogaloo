{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.modules.sops;
in
{
  options.my.modules.sops = {
    enable = lib.mkEnableOption "sops-nix secret management";
    secretsFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to this host's encrypted secrets YAML.";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    sops = {
      defaultSopsFile = cfg.secretsFile;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    environment.systemPackages = [
      pkgs.sops
      pkgs.age
      pkgs.ssh-to-age
    ];
  };
}
