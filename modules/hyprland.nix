{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.my.modules.hyprland;

  defaultSettings = {
    cursor.no_hardware_cursors = 1;

    bind = [
      "SUPER, T, exec, foot"
      "SUPER, Q, killactive"
      "SUPER, SHIFT, E, exit"

      "SUPER, LEFT, movefocus, l"
      "SUPER, RIGHT, movefocus, r"
      "SUPER, UP, movefocus, u"
      "SUPER, DOWN, movefocus, d"

      "SUPER, SHIFT, LEFT, movewindow, l"
      "SUPER, SHIFT, RIGHT, movewindow, r"
      "SUPER, SHIFT, UP, movewindow, u"
      "SUPER, SHIFT, DOWN, movewindow, d"

      "SUPER, 1, workspace, 1"
      "SUPER, 2, workspace, 2"
      "SUPER, 3, workspace, 3"
      "SUPER, 4, workspace, 4"
      "SUPER, 5, workspace, 5"
      "SUPER, 6, workspace, 6"
      "SUPER, 7, workspace, 7"
      "SUPER, 8, workspace, 8"
      "SUPER, 9, workspace, 9"

      "SUPER, SHIFT, 1, movetoworkspace, 1"
      "SUPER, SHIFT, 2, movetoworkspace, 2"
      "SUPER, SHIFT, 3, movetoworkspace, 3"
      "SUPER, SHIFT, 4, movetoworkspace, 4"
      "SUPER, SHIFT, 5, movetoworkspace, 5"
      "SUPER, SHIFT, 6, movetoworkspace, 6"
      "SUPER, SHIFT, 7, movetoworkspace, 7"
      "SUPER, SHIFT, 8, movetoworkspace, 8"
      "SUPER, SHIFT, 9, movetoworkspace, 9"
    ];
  };
in
{
  options.my.modules.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Hyprland settings that override this module's defaults.";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    programs.hyprland.enable = true;
    hardware.graphics.enable = true;

    services.greetd = {
      enable = true;
      settings.default_session.command =
        "${lib.getExe pkgs.tuigreet} --time --cmd Hyprland";
    };

    home-manager.users.${username} = {
      home.packages = with pkgs; [ foot ];

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "hyprlang";
        package = null;
        portalPackage = null;
        settings = lib.recursiveUpdate defaultSettings cfg.settings;
      };
    };
  };
}