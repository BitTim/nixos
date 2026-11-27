{ self, inputs, ... }: {
  flake.nixosConfigurations.arbor = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      arborConfiguration
      server
      caddy-portal
      portal-forward
    ];
  };
}
