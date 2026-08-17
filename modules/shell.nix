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

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.tmux = {
      enable = true;
      clock24 = true;
    };

    programs.lazygit = {
      enable = true;
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
