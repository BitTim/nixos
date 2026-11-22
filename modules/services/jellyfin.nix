{ moduleWithSystem, inputs, ... }: {
  flake.nixosModules.jellyfin = moduleWithSystem (
    { ... }: { config, ... }: {
      users = {
        groups = {
          jellyfin = { };
          media.gid = 5001; # Custom group used for file permissions
        };
        users = {
          jellyfin = {
            isSystemUser = true;
            group = "jellyfin";
            extraGroups = [ "media" ];
          };

          # Add main user to "media" group as well
          ${config.my.user.name}.extraGroups = [ "media" ];
        };
      };

      services.jellyfin = {
        enable = true;
        openFirewall = true; # Temporary since no reverse proxy yet

        # User setup (Use the use the uer and group from above)
        user = "jellyfin";
        group = "jellyfin";

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
