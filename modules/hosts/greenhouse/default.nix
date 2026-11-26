{ self, inputs, ... }: {
  flake.nixosConfigurations.greenhouse = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      greenhouseConfiguration
      server
      intel-gpu
      caddy-internal
      jellyfin
      seerr
      forgejo
      minecraft-server
      immich
    ];
  };
}
