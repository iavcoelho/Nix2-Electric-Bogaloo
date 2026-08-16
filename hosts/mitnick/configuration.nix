{ username, ... }:
{
  networking.hostName = "mitnick";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  environment.etc.hosts.enable = false;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
  };

  virtualisation.rosetta.enable = true;

  my.modules = {
    iwd.enable = true;
    shell.enable = true;
    podman.enable = true;
    pentesting.enable = true;
    niri.enable = true;
  };

  my.services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "26.05";
}
