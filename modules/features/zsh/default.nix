{ inputs, moduleWithSystem, ... }: {
  flake.nixosModules.zsh = moduleWithSystem (
    { pkgs, self', ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          zsh = self'.packages.zsh;
        })
      ];

      programs.zsh.enable = true;
    }
  );

  perSystem = { pkgs, lib, ... }: {
    packages.zsh = inputs.wrappers.wrappers.zsh.wrap {
      inherit pkgs;
      zshAliases = {
        nv = lib.getExe pkgs.neovim;
        hf = lib.getExe pkgs.hyfetch;
        cat = lib.getExe pkgs.bat;
      };
      zshrc.content = ''
        eval "$(starship init zsh)"
        	  '';
    };
  };
}
