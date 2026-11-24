{ moduleWithSystem, lib, ... }: {
  flake.nixosModules.jellyfin = moduleWithSystem (
    { ... }:
    { config, ... }:
    let
      domain = config.my.domain;
    in
    {
      options.my.jellyfin = {
        subdomain = lib.mkOption {
          type = lib.types.str;
          default = "firefly";
        };
      };

      config =
        let
          subdomain = config.my.jellyfin.subdomain;
        in
        {
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

          # Reverse Proxy Setup
          services.caddy.virtualHosts = {
            "${subdomain}.internal.${domain}, ${subdomain}.local.${domain}".extraConfig = ''
              tls { dns cloudflare {env.CF_API_TOKEN} }
              reverse_proxy 127.0.0.1:8096
            '';
            "http://${subdomain}.${domain}".extraConfig = "reverse_proxy 127.0.0.1:8096";
          };
        };
    }
  );
}
