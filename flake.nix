{
  description = "Nixos Minimal ISO with custom SSH auth";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # build ISO with: 
      # nix build .#nixosConfigurations.server.config.system.build.diskoImages (or diskoImagesScript for impure configs)
      # qemu-img convert -O qcow2 -o preallocation=off result/vda.raw ./nixos.qcow2 
      # Test with: qemu-kvm -m 3G -smp 2 -hda nixos.qcow2
      # 
      # deploy with: nixos-rebuild switch --use-remote-sudo --target-host root@server.shiryel.com --flake ".#nixos"   
      nixosConfigurations.nixos =
        nixpkgs.lib.nixosSystem {
          # do not add lib, args, specialArgs, system here, they will conflict with nixpkgs.(...) on modules
          modules = [
            #"${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            #impermanence.nixosModules.impermanence
            disko.nixosModules.disko
            ./hardware/server.nix
            ./config.nix
            ({ pkgs, ... }: {
              nixpkgs.hostPlatform = system;

              # TODO: remove on 24.05, in favor of (the automatic) nixpkgs.flake.source
              #nix = {
              #  # fixes nix-index and set <nixpkgs> to current version
              #  nixPath = [ "nixpkgs=${nixpkgs.outPath}" ];
              #};

              system.autoUpgrade = {
                enable = true;
                flake = self.outPath;
                flags = [
                  "--update-input"
                  "nixpkgs"
                  "--no-write-lock-file"
                  "-L"
                ];
                dates = "Mon *-*-* 08:45:00";
                allowReboot = true;
              };
            })
          ];
        };
    };
}
