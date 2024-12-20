function syncer -d "sync remote periodically with notifications"
  while true
    nix run nixpkgs#git-sync -- -ns
    set time "$(date +"%R %D" )"
    set sleep "$(math 60x 60)"
    if test $status -eq 0
      notify-send "git sync" "Sync successful at $time"
    else
      notify-send -t $(math 1000x 60x 2) -u critical "git sync" "Sync failure at $time"
    end
    echo "time: $time, next in $sleep seconds"
    sleep "$sleep"
  end
end
