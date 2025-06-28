USING: mutation scopes wall namespaces ;
IN: cellular

: focus-cell ( membrane -- ) [ request-focus ] [ scroll>gadget ] bi ;
: com-focus-cell ( membrane -- ) [ dermis>> ] [ pairs>> ] bi mutating-probe focus-cell ;
: focus-membrane-above ( membrane -- )
  1 n-cell-above focus-cell ;
: focus-membrane-below ( membrane -- )
  1 n-cell-below focus-cell ;
: focus-membrane-before ( membrane -- )
  1 n-cell-before focus-cell ;
: focus-membrane-after ( membrane -- )
  1 n-cell-after focus-cell ;

: focus-out ( membrane -- )
  dup dermis? [ drop ] [ parent>> dup dermis? [ drop ] [ request-focus ] if ] if ;
: focus-in ( membrane -- )
  dup wall? [ gadget-child request-focus ] [ drop ] if ;

{ wall membrane } [ "highlighting" f {
  { gain-focus dye }
  { lose-focus undye }
  ! { mouse-enter tint-cell }
  ! { mouse-leave untint-cell }
  { T{ button-down { # 1 } } focus-cell }
  { T{ key-down f f "k" } focus-membrane-above }
  { T{ key-down f f "h" } focus-membrane-before }
  { T{ key-down f f "j" } focus-membrane-below }
  { T{ key-down f f "l" } focus-membrane-after }
  { T{ key-up f f "ESC" } focus-out }
  { T{ key-up f f "RET" } focus-in }
  { T{ key-up f f "/" } highlighter-search }
} define-command-map ] each

{ wall membrane } [ "mutating" f {
  { T{ key-up f f ";" } grow-below }
  { T{ key-up f { C+ } ";" } grow-after }
  { T{ key-up f f "," } excise-below }
  { T{ key-up f { C+ } "," } excise-after }
  { T{ key-up f f ":" } split-below }
  { T{ key-up f { C+ } ":" } split-after }

  { T{ key-up f f "u" } unmutate-once }
  { T{ key-up f f "U" } remutate-once }
  { T{ key-up f f "f" } freeze-colony }
  { T{ key-up f f "F" } thaw-colony }

  { T{ button-down { mods { C+ } } { # 1 } } reference-cell-in-splicer }
} define-command-map ] each

membrane "splicing" f {
  { T{ key-up f f "e" } show-splicer }
} define-command-map

wall "organising" f {
  { T{ key-up f f "TAB" } siphon-up }
  { T{ key-up f { C+ } "TAB" } swivel-colony }
} define-command-map
membrane "organising" f {
  { T{ button-up { # 2 } } splinter }
  { T{ key-up f f "TAB" } splinter }
} define-command-map

{ membrane wall } [ "common" f {
    { T{ key-down f ${ os macos? M+ A+ ? } "t" } show-active-buttons-popup }
} define-command-map ] each

[ capture? ] \ com-focus-cell H{
    { +primary+ t }
} define-operation
