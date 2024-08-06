function render -d "render everything to markdown, more or less"
  mkdir -p render
  for f in (fd 'norg' -t f  . | sed 's|./\(.*\).norg|\1|')
    nix run .#neorg-parser -- -f $f.norg | nix run s#pandoc -- -f json -o render/$f.md
    sed -e 's/](\(.*\))/](\1.md)/; s/^\(\s*\)-   [uicp]$/\1- [ ]/; s/^\(\s*\)-   d$/\1- [x]/' render/$f.md -i
  end
end
