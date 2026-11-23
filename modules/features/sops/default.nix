{ moduleWithSystem, inputs, ... }: {
  flake.nixosModules.sops = moduleWithSystem (
    { ... }: {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    }
  );
}
