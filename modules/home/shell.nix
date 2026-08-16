{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:
let
  enabled = osConfig.my.modules.shell.enable;
in
{
  options.my.home.shell.enable = lib.mkEnableOption "shell environment";

  config = lib.mkIf enabled {
    programs.fish = {
      enable = true;
      shellAliases = {
        ls = "eza -l --icons --group-directories-last --no-user";
      };
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.eza = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "github_dark";
        editor = {
          color-modes = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          statusline.mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
      };

      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }
      ];
    };

  };
}
