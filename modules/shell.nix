{
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  cfg = config.my.modules.shell;
in
{
  options.my.modules.shell.enable = lib.mkEnableOption "fish as default shell";

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
    users.users.${username}.shell = pkgs.fish;

    programs = {

      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      tmux = {
        enable = true;
        clock24 = true;
      };

      lazygit = {
        enable = true;
      };

      bat = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      git
      gh
      devenv
      python3
      ripgrep
    ];
  };
}
