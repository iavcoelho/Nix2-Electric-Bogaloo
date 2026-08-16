{
  lib,
  config,
  ...
}:
let
  cfg = config.my.modules.firefox;
in
{
  options.my.modules.firefox.enable = lib.mkEnableOption "firefox web browser";

  config = lib.mkIf cfg.enable { };
}