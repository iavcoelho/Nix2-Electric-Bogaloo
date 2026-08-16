{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.my.modules.hyprland;

  inl = lib.generators.mkLuaInline;

  mkBind = key: action: {
    _args = [
      (inl "mod .. \" + ${key}\"")
      (inl "hl.dsp.${action}")
    ];
  };

  mkFocus = dir: mkBind (dir) "focus({ direction = \"${dir}\" })";
  mkMove = dir: mkBind "SHIFT + ${dir}" "window.move({ direction = \"${dir}\" })";
  mkWs = n: mkBind (toString n) "focus({ workspace = ${toString n} })";
  mkMoveWs = n: mkBind "SHIFT + ${toString n}" "window.move({ workspace = ${toString n} })";

  defaultSettings = {
    mod._var = "ALT";

    config = {
      cursor.no_hardware_cursors = 1;
      animations.enabled = false;

      input = {
        kb_layout = "pt";
        kb_variant = "mac";
      };
    };

    monitor = {
      output = "Virtual-1";
      mode = "2560x1600@60";
      position = "auto";
      scale = 1.33;
    };

    bind = [
      (mkBind "T" "exec_cmd(\"foot\")")
      (mkBind "Q" "window.close()")
      (mkBind "SHIFT + E" "exit()")

      (mkBind "SPACE" "global(\"quickshell:launcher\")")

      (mkFocus "left")
      (mkFocus "right")
      (mkFocus "up")
      (mkFocus "down")

      (mkMove "left")
      (mkMove "right")
      (mkMove "up")
      (mkMove "down")

      (mkWs 1)
      (mkWs 2)
      (mkWs 3)
      (mkWs 4)
      (mkWs 5)
      (mkWs 6)
      (mkWs 7)
      (mkWs 8)
      (mkWs 9)

      (mkMoveWs 1)
      (mkMoveWs 2)
      (mkMoveWs 3)
      (mkMoveWs 4)
      (mkMoveWs 5)
      (mkMoveWs 6)
      (mkMoveWs 7)
      (mkMoveWs 8)
      (mkMoveWs 9)
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
        "${lib.getExe pkgs.tuigreet} --time --cmd start-hyprland";
    };

    home-manager.users.${username} = {
      home.packages = with pkgs; [ foot ];

      xdg.configFile."foot/foot.ini".text = ''
        [main]
        font=monospace:size=16
      '';

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        package = null;
        portalPackage = null;
        settings = lib.recursiveUpdate defaultSettings cfg.settings;
      };
    };
  };
}
