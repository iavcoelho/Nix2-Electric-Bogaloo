{ lib, pkgs, username, ... }:
let isLinux = pkgs.stdenv.isLinux; in
{

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ username ];
      extra-sandbox-paths = [ "/nix/var/nix/profiles/per-user/root" ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    }; 

    optimise = {
      automatic = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  networking = lib.mkIf isLinux {
    nftables.enable = lib.mkDefault true;
    firewall.enable = lib.mkDefault true;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    htop
    vim
  ];
}
