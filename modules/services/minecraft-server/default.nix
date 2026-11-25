{ ... }: {
  flake.nixosModules.minecraft-server = { pkgs, ... }: {
    services.minecraft-server = {
      enable = true;
      package = pkgs.papermc;
      declarative = true;

      # Server configuration
      eula = true;
      whitelist = {
        undefbloom = "730bdb73-3c5b-4f5f-84cb-ca86fca21cda";
      };
      serverProperties = {
        difficulty = "normal";
        enforce-whitelist = true;
        gamemode = "survival";
        max-players = 1;
        motd = "\u02da\u208a\u2027\ua4b0\u10d0 \u00a7d\u00a7lMy forever world\u00a7r \u0ed2\ua4b1\u2027\u208a\u02da";
        pause-when-empty-seconds = -1;
        white-list = true;
      };
    };
  };
}
