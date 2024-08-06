{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    neorg-haskell-parser.url = "github:Simre1/neorg-haskell-parser";
    neorg-haskell-parser.flake = false;
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [

      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, lib, ... }: {

        packages.neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (pkgs.neovimUtils.makeNeovimConfig {
          plugins = [
            {
              plugin = pkgs.vimPlugins.nvim-treesitter;
              config = ''
                lua require'nvim-treesitter.configs'.setup { highlight = { enable = false } }
              '';
            }
            {
              plugin = pkgs.vimPlugins.plenary-nvim;
            }
            {
              plugin = pkgs.vimPlugins.neorg;
              config = "lua require('neorg').setup { load = { ['core.tangle'] = {} } }";
            }
          ];
        });

        packages.neorg-parser = lib.pipe
          (pkgs.haskellPackages.callCabal2nix
            "neorg-parser"
            inputs.neorg-haskell-parser
            { }
          )
          [ pkgs.haskell.lib.dontCheck # tests depend on helper files that get filtered
            pkgs.haskell.lib.justStaticExecutables
          ];

          packages.scripts = pkgs.stdenvNoCC.mkDerivation {
          name = "scripts";
        version = self.lastModified;
        src = self;

        installPhase = ''
          ${nixpkgs.lib.getExe self'.packages.neovim} -v -es ./nu.norg -c ':Neorg tangle current-file'
          mkdir $out
          cp *.nu $out/
        '';
      };
    };
  flake = { };
};
}
