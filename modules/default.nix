{ mylib, ... }:
{
  imports = mylib.autoImport ["home"] ./.;
}
