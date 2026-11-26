{ ... }: {
  flake.nixosModules.immich = { config, ... }: {
    users = {
      groups = {
        immich = { };
        photos.gid = 5002; # Custom group used for file permissions
      };
      users = {
        immich = {
          isSystemUser = true;
          group = "immich";
          extraGroups = [
            "photos"
            "video"
            "render"
          ];
        };

        # Add main user to "media" group as well
        ${config.my.user.name}.extraGroups = [ "photos" ];
      };
    };

    services.immich = {
      enable = true;

      user = "immich";
      group = "immich";

      mediaLocation = "/mnt/soil/immich";
      accelerationDevices = null;
    };
  };
}
