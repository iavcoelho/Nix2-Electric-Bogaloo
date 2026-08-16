{
  lib,
  config,
  osConfig,
  ...
}:
let
  enabled = osConfig.my.modules.firefox.enable;
in
{
  options.my.home.firefox.enable = lib.mkEnableOption "firefox web browser";

  config = lib.mkIf enabled {
    programs.firefox.enable = true;
  };
}