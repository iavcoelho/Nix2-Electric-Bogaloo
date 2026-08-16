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
        import QtQuick
        import QtQuick.Layouts
        import Quickshell
        import Quickshell.Hyprland
        import Quickshell.Io
        import Quickshell.Wayland
        import Quickshell.Widgets

        Scope {
          PanelWindow {
            id: launcher
            visible: false

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
              top: true
              left: true
              right: true
              bottom: true
            }

            property string query: ""

            function collectApps() {
              apps.clear()
              for (let i = 0; i < DesktopEntries.applications.count; i++) {
                const e = DesktopEntries.applications.get(i)
                apps.append({ entry: e })
              }
            }

            function refilter() {
              filtered.clear()
              const q = query.trim().toLowerCase()
              for (let i = 0; i < apps.count; i++) {
                const e = apps.get(i).entry
                const name = e.name || ""
                const generic = e.genericName || ""
                if (q === "" || name.toLowerCase().includes(q) || generic.toLowerCase().includes(q)) {
                  filtered.append({ entry: e })
                }
              }
              results.currentIndex = 0
            }

            function launch() {
              const e = filtered.get(results.currentIndex).entry
              if (e) {
                e.execute()
                hide()
              }
            }

            function show() {
              query = ""
              collectApps()
              refilter()
              visible = true
              input.forceActiveFocus()
            }

            function hide() {
              visible = false
            }

            ListModel {
              id: apps
            }

            ListModel {
              id: filtered
            }

            // Dismiss on click outside the box
            MouseArea {
              anchors.fill: parent
              onClicked: launcher.hide()
            }

            Rectangle {
              id: box
              width: 600
              height: 500
              anchors.centerIn: parent
              color: "#dd181825"
              radius: 12
              border.color: "#33ffffff"
              border.width: 1

              ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Rectangle {
                  Layout.fillWidth: true
                  implicitHeight: 48
                  radius: 8
                  color: "#40000000"
                  border.color: "#55ffffff"
                  border.width: 1

                  TextInput {
                    id: input
                    anchors {
                      left: parent.left
                      right: parent.right
                      verticalCenter: parent.verticalCenter
                    }
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    color: "#eeeeee"
                    font.pointSize: 16
                    focus: true
                    selectByMouse: true

                    Keys.onPressed: (event) => {
                      if (event.key === Qt.Key_Escape) {
                        launcher.hide()
                        event.accepted = true
                      } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        launcher.launch()
                        event.accepted = true
                      } else if (event.key === Qt.Key_Up) {
                        results.decrementCurrentIndex()
                        event.accepted = true
                      } else if (event.key === Qt.Key_Down) {
                        results.incrementCurrentIndex()
                        event.accepted = true
                      }
                    }

                    onTextChanged: launcher.query = text
                  }
                }

                ListView {
                  id: results
                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  clip: true

                  model: filtered
                  highlightFollowsCurrentItem: true
                  currentIndex: 0

                  delegate: Rectangle {
                    required property var modelData
                    width: results.width
                    implicitHeight: 44
                    radius: 8
                    color: results.currentIndex === index ? "#44ffffff" : "transparent"

                    RowLayout {
                      anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                      }
                      spacing: 12

                      IconImage {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        source: Quickshell.iconPath(modelData.entry.icon)
                      }

                      Text {
                        Layout.fillWidth: true
                        text: modelData.entry.name
                        color: "#eeeeee"
                        font.pointSize: 14
                        elide: Text.ElideRight
                      }

                      Text {
                        text: modelData.entry.genericName
                        color: "#aaaaaa"
                        font.pointSize: 11
                        elide: Text.ElideRight
                      }
                    }

                    MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      onClicked: {
                        results.currentIndex = index
                        launcher.launch()
                      }
                    }
                  }
                }
              }
            }
          }

          GlobalShortcut {
            name: "launcher"

            onPressed: {
              if (launcher.visible) launcher.hide()
              else launcher.show()
            }
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