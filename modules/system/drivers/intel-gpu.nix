{ moduleWithSystem, ... }: {
  flake.nixosModules.intel-gpu = moduleWithSystem (
    { pkgs, ... }: {
      services.xserver.videoDrivers = [ "modesetting" ];

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
          intel-compute-runtime
        ];
      };

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };
    }
  );
}
