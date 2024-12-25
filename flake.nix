{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [

      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, lib, ... }: {
        packages = rec {
          favicon_ico = pkgs.stdenvNoCC.mkDerivation {
            pname = "favicon-ico";
            version = "01072024";

            src = ./static;

            buildPhase = ''
              ${pkgs.imagemagick}/bin/convert -resize 16x16 ./favicon.png ./16x16.png
              ${pkgs.imagemagick}/bin/convert -resize 32x32 ./favicon.png ./32x32.png
              ${pkgs.imagemagick}/bin/convert -resize 48x48 ./favicon.png ./48x48.png
              ${pkgs.imagemagick}/bin/convert 16x16.png 32x32.png 48x48.png favicon.ico
            '';

            installPhase = ''
              cp favicon.ico $out
            '';
          };

          robots_txt = pkgs.writeText "robots.txt" ''
            User-agent: *
            Disallow:
          '';

          styles_css = ./static/styles.css;

          neorg-haskell-parser = let
            base = pkgs.haskellPackages.callPackage
              (import static/neorg-haskell-parser.nix) {};
          in lib.pipe base (with pkgs.haskell.lib; [
            doJailbreak
            dontCheck
            dontHaddock
            justStaticExecutables
          ]);

          blog-render = with pkgs; (stdenvNoCC.mkDerivation rec {
              pname = "norg-render";
              version = "25122024";

              src = ./unmanaged;

              pandocOpts = [
                "--to=html"
                ''--css="/static/styles.css"''
                "--highlight-style=pygments"
              ];

              buildPhase = ''
                mkdir build
                find -type f -name '*.norg' | sed 's/.\/\(.*\)\.norg/\1/' | \
                  xargs -I {} sh -c '
                    ${neorg-haskell-parser}/bin/neorg-pandoc -f "./{}.norg" | \
                      ${lib.getExe pkgs.pandoc} \
                      ${builtins.concatStringsSep " " pandocOpts} \
                      --toc --from=json --metadata title="{}" -s -o "build/{}.html"; \
                    echo "- [{}](/{}.html)" >> index.md;
                  '
                ${lib.getExe pkgs.pandoc} \
                  ${builtins.concatStringsSep " " pandocOpts} \
                  --metadata title="Sitemap" -s index.md -o "build/index.html"; \
              '';

              installPhase = ''
                cp build $out -rv
                mkdir $out/static
                cp ${favicon_ico} $out/favicon.ico -v
                cp ${robots_txt} $out/robots.txt -v
                cp ${styles_css} $out/static/styles.css -v
              '';
          });
        };
      };
  flake = { };
};
}
