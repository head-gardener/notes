def todos [path: path = ./.] {
  rg '\(.\)' --json $path
  | lines
  | each {|| from json}
  | filter {|e| $e.type == 'match'}
  | each {||
    get data
    | reject absolute_offset
    | update lines {||
      get text
      | str replace --regex '^.*\(.\)\s+' ""
    }
    | update submatches {|| get 0.match.text}
    | update path {|| get text}
  }
  | rename file text line status
  | move text --after status
}