{ username, ... }:
{
  networking.hostName = "mitnick";

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
