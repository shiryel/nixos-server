# Inspirations:
# - https://github.com/barrucadu/nixfiles/blob/1e54794479e653b139fd26806c952f28e1bddabb/shared/default.nix#L74

{ self, pkgs, lib, ... }:

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

  # Reboot on panic and oops
  # https://utcc.utoronto.ca/~cks/space/blog/linux/RebootOnPanicSettings
  boot.kernel.sysctl = {
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;
  };

  services.fail2ban = {
    enable = true;
    bantime-increment.enable = true;
    bantime-increment.rndtime = "8m";
    bantime-increment.overalljails = true;
    ignoreIP = [ "189.110.0.0/16" ];
  };

  services = {
    k3s = {
      enable = true;
      clusterInit = false;
      role = "server";
    };
  };

  environment.systemPackages = with pkgs; [ neovim lsof git ];

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkForce "prohibit-password";
        PasswordAuthentication = false;
        GatewayPorts = "clientspecified";
      };
    };
  };

  networking.firewall = {
    enable = true;
    logRefusedConnections = false; # stop logging "kernel: refused connection:"
    allowedTCPPorts = [
      # https://docs.k3s.io/installation/requirements#networking
      6443

      # web
      80
      443
      4000 # for testing

      27015 # steam
      25565 # minecraft sushibar
      25566 # minecraft kuro
      14004 # veloren
    ];

    allowedUDPPorts = [
      27015 # steam
      30000 # minetest

      # satisfactory
      7777
      15000
      15777
    ];
  };

  # https://wiki.nixos.org/wiki/Rsync
  # e.g.: rsync -Pav --delete --checksum -e "ssh -i ~/.ssh/id_ed25519_server" ./ root@example.com:/var/lib/rancher/k3s/storage/pvc
  # To generate a hashed password run mkpasswd
  users = {
    mutableUsers = true;
    users = {
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBifJNLeF3qcMBLnQLDHp4HjhiBpZUmhcMLRfC/3/7qs shiryel@hotmail.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/EySg33KUX2jVFThjM7pkMhw6fgUO1+A3rBO84Vrp5 server"
        ];
        initialHashedPassword = lib.mkForce "$6$X7l.d/DQuzwJ5VqA$2mQqvLWHjMQx1/g0bjuhG9x158eFxnoFhAwTr5piJtf7ddOYLnHs/prz/0DcPqApO2f9VvktkvOH/MHs4lfWI1";
      };
      shiryel = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBifJNLeF3qcMBLnQLDHp4HjhiBpZUmhcMLRfC/3/7qs shiryel@hotmail.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/EySg33KUX2jVFThjM7pkMhw6fgUO1+A3rBO84Vrp5 server"
        ];
        initialHashedPassword = lib.mkForce "$6$X7l.d/DQuzwJ5VqA$2mQqvLWHjMQx1/g0bjuhG9x158eFxnoFhAwTr5piJtf7ddOYLnHs/prz/0DcPqApO2f9VvktkvOH/MHs4lfWI1";
      };
    };
  };

  system.stateVersion = "24.05";
}
