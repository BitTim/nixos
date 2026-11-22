{ moduleWithSystem, ... }: {
  flake.nixosModules.jellyfin = moduleWithSystem (
    { ... }: {
      services.jellyfin = {
        enable = true;
        openFirewall = true; # Temporary since no reverse proxy yet

        # Hardware acceleration
        hardwareAcceleration = {
          enable = true;
          device = "/dev/dri/renderD128";
          type = "qsv";
        };
        transcoding = {
          enableHardwareEncoding = true;
          enableSubtitleExtraction = true;
          hardwareDecodingCodecs = {
            av1 = true;
            vc1 = true;
            vp8 = false;
            vp9 = true;
            h264 = true;
            hevc = true;
            mpeg2 = true;
            hevc10bit = true;
          };
          hardwareEncodingCodecs = {
            av1 = false;
            hevc = true;
          };
        };
      };
    }
  );
}
