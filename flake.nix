{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [

      ];
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, lib, ... }: {
        packages = rec {
          favicon_ico = pkgs.stdenvNoCC.mkDerivation {
            pname = "favicon-ico";
            version = "01072024";

            src = ./static/favicon.png;

            dontUnpack = true;

            buildPhase = ''
              ${pkgs.imagemagick}/bin/convert -resize 16x16 $src ./16x16.png
              ${pkgs.imagemagick}/bin/convert -resize 32x32 $src ./32x32.png
              ${pkgs.imagemagick}/bin/convert -resize 48x48 $src ./48x48.png
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

          blog-render = with pkgs;
            (stdenvNoCC.mkDerivation rec {
              pname = "norg-render";
              version = "25122024";

              src = ./unmanaged;

              pandocOpts = [
                "--to=html"
                ''--css="/static/styles.css"''
                "--highlight-style=pygments"
              ];

              LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
              LANG = "en_US.UTF-8";

              buildInputs = [
                neorg-haskell-parser
                pandoc
              ];

              buildPhase = ''
                mkdir build
                find -type f -name '*.norg' | sed 's/.\/\(.*\)\.norg/\1/' | \
                  xargs -I {} sh -c '
                    sed "s/{:\([^:]*\):[^}]*}/{\.\/\1.html}[\1]/" -i "./{}.norg";
                    neorg-pandoc -f "./{}.norg" | \
                      pandoc ${builtins.concatStringsSep " " pandocOpts} \
                      --toc --from=json --metadata title="{}" -s -o "build/{}.html";
                    echo "- [{}](/{}.html)" >> index.md;
                  '
                pandoc ${builtins.concatStringsSep " " pandocOpts} \
                  --metadata title="Sitemap" -s index.md -o "build/index.html";
              '';

              installPhase = ''
                cp build $out -rv
              '';
            });

          blog = pkgs.stdenvNoCC.mkDerivation {
            pname = "blog";
            version = "25122024";

            src = ./unmanaged;

            buildPhase = "";

            installPhase = ''
              mkdir $out
              cp ${blog-render}/* $out/ -rv
              cp ${favicon_ico} $out/favicon.ico -v
              cp ${robots_txt} $out/robots.txt -v
              mkdir $out/static
              cp ${styles_css} $out/static/styles.css -v
            '';
          };
        };
      };
      flake = { };
    };
}
