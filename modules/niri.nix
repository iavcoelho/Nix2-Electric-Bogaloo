{
  inputs,
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  cfg = config.my.modules.niri;

  defaultSettings = {
    prefer-no-csd = true;

    layout = {
      gaps = 8;
      focus-ring.enable = false;
    };

    input.keyboard = {
      xkb.layout = "us";
      xkb.variant = "intl";
    };

    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
      "Mod+Q".action.close-window = [ ];
      "Mod+T".action.spawn = [ "foot" ];
      "Mod+Shift+E".action.quit.skip-confirmation = true;

      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+Shift+Left".action.move-column-left = [ ];
      "Mod+Shift+Right".action.move-column-right = [ ];

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
    };
  };
in
{
  options.my.modules.niri = {
    enable = lib.mkEnableOption "niri window manager";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "niri settings that override this module's defaults.";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    programs.niri.enable = true;
    hardware.graphics.enable = true;

    services.greetd = {
      enable = true;
      settings.default_session.command =
        "${lib.getExe pkgs.greetd.tuigreet} --time --cmd niri-session";
    };

    home-manager.sharedModules = [ inputs.niri.homeModules.niri ];

    home-manager.users.${username} = {
      home.packages = with pkgs; [ foot ];

      programs.niri = {
        enable = true;
        package = pkgs.niri;
        settings = lib.recursiveUpdate defaultSettings cfg.settings;
      };
    };
  };
}