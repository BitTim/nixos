{ moduleWithSystem, inputs, ... }: {
  flake.nixosModules.hyfetch = moduleWithSystem (
    { pkgs, self', ... }: {
      programs.hyfetch = {
        package = self'.packages.hyfetch;
      };
    }
  );

  perSystem = { pkgs, ... }: {
    packages.hyfetch = inputs.wrappers.hyfetch.wrap {
      inherit pkgs;
      settings = {
        preset = [
          "transgender"
          "lesbian"
          "transbian"
        ];
        mode = "rgb";
        auto_detect_light_dark = true;
        light_dark = "light";
        lightness = 0.4;
        color_align = {
          mode = "horizontal";
        };
        backend = "fastfetch";
        args = null;
        distro = null;
        pride_month_disable = false;
        custom_ascii_path = null;
        custom_presets = null;
        palette_glyph = null;
        palette_type = null;
      };
    };
  };
}
