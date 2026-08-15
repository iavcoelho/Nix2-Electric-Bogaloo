{ lib, config, pkgs, ... }:
let cfg = config.my.services.openssh; in
{
  options.my.services.openssh.enable = lib.mkEnableOption "hardened SSH server";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
