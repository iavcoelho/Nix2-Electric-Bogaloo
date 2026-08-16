{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.my.modules.quickshell;
in
{
  options.my.modules.quickshell = {
    enable = lib.mkEnableOption "Quickshell desktop shell";

    shellQml = lib.mkOption {
      type = lib.types.str;
      default = ''
        import QtQuick // for Text
        import Quickshell // for PanelWindow

        PanelWindow {
          anchors {
            top: true
            left: true
            right: true
          }

          implicitHeight: 30

          Text {
            anchors.centerIn: parent
            text: "quickshell"
          }
        }
      '';
      description = "Quickshell shell.qml content (customize freely).";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    home-manager.users.${username} = {
      home.packages = [ pkgs.quickshell ];

      xdg.configFile."quickshell/shell.qml".text = cfg.shellQml;

      systemd.user.services.quickshell = {
        Unit = {
          Description = "Quickshell desktop shell";
          After = [ "hyprland-session.target" ];
          PartOf = [ "hyprland-session.target" ];
        };
        Service = {
          Type = "exec";
          ExecStart = "${lib.getExe pkgs.quickshell}";
          Restart = "on-failure";
          RestartSec = "5s";
          Environment = [ "QT_QPA_PLATFORM=wayland" ];
        };
        Install.WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}