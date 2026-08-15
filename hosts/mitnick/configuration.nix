{ username, ... }:
{
  networking.hostName = "mitnick";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
  };

  my.modules = {
    iwd.enable = true;
    shell.enable = true;
  };

  my.services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "26.05";
}
