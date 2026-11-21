{ ... }: {
  flake.nixosModules.greenhouseConfiguration = { pkgs, ... }: {
    networking.hostName = "greenhouse";

    environment.systemPackages = with pkgs; [
      vim
      git
      curl
      wget
    ];
  };
}
