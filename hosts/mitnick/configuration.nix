{ username, ... }:
{
  networking.hostName = "mitnick";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 0;
  };

  environment.etc.hosts.enable = false;

  networking.firewall.trustedInterfaces = [
    "lo"
    "tun0"
  ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
    ];
  };

  virtualisation.rosetta.enable = true;

  my.modules = {
    iwd.enable = true;
    shell.enable = true;
    podman.enable = true;
    pentesting.enable = true;
    xfce.enable = true;
    firefox.enable = true;
  };

  my.services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  system.stateVersion = "26.05";
}
