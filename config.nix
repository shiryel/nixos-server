{ pkgs, lib, ... }:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-old --delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:NixOS/nixpkgs/nixos-23.11";
    dates = "Mon *-*-* 00:00:00";
    allowReboot = true;
  };

  environment.systemPackages = with pkgs; [ neovim ];

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkForce "prohibit-password";
        PasswordAuthentication = false;
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # https://docs.k3s.io/installation/requirements#networking
      6443
    ];
  };

  users = {
    mutableUsers = true;
    users = {
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBifJNLeF3qcMBLnQLDHp4HjhiBpZUmhcMLRfC/3/7qs shiryel@hotmail.com"
        ];
        initialHashedPassword = lib.mkForce "$6$X7l.d/DQuzwJ5VqA$2mQqvLWHjMQx1/g0bjuhG9x158eFxnoFhAwTr5piJtf7ddOYLnHs/prz/0DcPqApO2f9VvktkvOH/MHs4lfWI1";
      };
    };
  };
}
