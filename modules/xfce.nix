{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.my.modules.xfce;
in
{
  options.my.modules.xfce = {
    enable = lib.mkEnableOption "XFCE desktop environment";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    services.xserver.enable = true;
    services.xserver.desktopManager.xfce.enable = true;
    services.xserver.displayManager.lightdm.enable = true;

    hardware.graphics.enable = true;

    # On this software-rendered VM, libinput's button-debounce plugin misses
    # its timer deadlines ("scheduled expiry is in the past ... your system is
    # too slow") and swallows button-release events, turning clicks into stuck
    # window drags. Disable debounce for mice via a libinput quirk.
    environment.etc."libinput/local-overrides.quirks".text = ''
      [VM mice: disable libinput button debounce]
      MatchUdevType=mouse
      ModelBouncingKeys=1
    '';

    home-manager.users.${username} = {
      home.packages = with pkgs; [
        foot
        rofi
      ];
    };
  };
}