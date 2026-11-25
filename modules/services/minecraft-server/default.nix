{ lib, ... }: {
  flake.nixosModules.minecraft-server = { pkgs, config, ... }: {
    options.my.minecraft-server = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "undefbloom";
      };
      uuid = lib.mkOption {
        type = lib.types.str;
        default = "730bdb73-3c5b-4f5f-84cb-ca86fca21cda";
      };
    };

    config =
      let
        uuid = config.my.minecraft-server.uuid;
        name = config.my.minecraft-server.name;
        cfg = config.services.minecraft-server;
        opsFile = pkgs.writeText "ops.json" (
          builtins.toJSON [
            {
              uuid = uuid;
              name = name;
              level = 4;
              bypassesPlayerLimit = false;
            }
          ]
        );

      in
      {
        servies.minecraft-server = {
          enable = true;
          openFirewall = true;
          package = pkgs.papermc;
          declarative = true;

          # Server configuration
          eula = true;
          whitelist = {
            ${name} = uuid;
          };
          serverProperties = {
            difficulty = "normal";
            enforce-whitelist = true;
            gamemode = "survival";
            max-players = 1;
            motd = "\\u02da\\u208a\\u2027\\ua4b0\\u10d0 \\u00a7d\\u00a7lMy forever world\\u00a7r \\u0ed2\\ua4b1\\u2027\\u208a\\u02da";
            pause-when-empty-seconds = -1;
            white-list = true;
          };
        };

        systemd.tmpfiles.rules = [
          "L+ '${cfg.dataDir}/ops.json' - - - - ${opsFile}"
        ];
      };
  };
}
