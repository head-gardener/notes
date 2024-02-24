def graph [where: path = .] {
  rg '\{:[a-z\-]*:[^\{]*\}' --json
  | lines
  | each {|| from json}
  | filter {|e| $e.type == 'match' }
  | each {||
    get data
    | update path {|| get text}
    | reject lines line_number absolute_offset
    | update submatches {||
      get 0.match.text
      | str replace -r '\{:(.*):.*\}' '$1'
    }
  }
  | rename from to
  | update from {|| str replace '.norg' '' }
  | reduce --fold '' {|it, acc| $acc + $'"($it.from)" -> "($it.to)"' + "\n"}
  | $"digraph G {\n($in)}"
  | dot -Tpng
  | feh -
}
