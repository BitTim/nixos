{ ... }: {
  flake.nixosModule.firewall = { ... }: {
    networking.firewall.enable = true;
  };
}
