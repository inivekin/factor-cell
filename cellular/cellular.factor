USING: mutation scopes wall namespaces ;
IN: cellular

: dye ( cell -- )
  [ drop ] ! set-absorbing-cell ]
  [ [ dim>> { 0 0 } swap <rect> ] [ scroll>rect ] bi ]
  [ dup wall? dim-color selection-color ? <solid> >>boundary relayout-1 ] tri ;
: undye ( cell -- )
  dup wall? line-color content-background ? <solid> >>boundary relayout-1 ;

: focus-cell ( membrane -- )
  [ request-focus ]
  [ cell-coordinate focussed-coord set ] bi ;

: focus-membrane-above ( membrane -- )
  1 n-cell-above focus-cell ;
: focus-membrane-below ( membrane -- )
  1 n-cell-below focus-cell ;
: focus-membrane-before ( membrane -- )
  1 n-cell-before focus-cell ;
: focus-membrane-after ( membrane -- )
  1 n-cell-after focus-cell ;

: focus-out ( membrane -- )
  dup skin? [ drop ] [ parent>> request-focus ] if ;
: focus-in ( membrane -- )
  dup wall? [ gadget-child request-focus ] [ drop ] if ;

{ membrane-control wall } [ "highlighting" f {
  { gain-focus dye }
  { lose-focus undye }
  ! { mouse-enter tint-cell }
  ! { mouse-leave untint-cell }
  { T{ button-up } focus-cell }
  { T{ key-down f f "k" } focus-membrane-above }
  { T{ key-down f f "h" } focus-membrane-before }
  { T{ key-down f f "j" } focus-membrane-below }
  { T{ key-down f f "l" } focus-membrane-after }
  { T{ key-down f f "ESC" } focus-out }
  { T{ key-down f f "RET" } focus-in }
} define-command-map ] each

{ membrane-control wall } [ "mutating" f {
  { T{ key-down f f ";" } grow-below }
  { T{ key-down f { C+ } ";" } grow-after }
  { T{ key-down f f "," } excise-below }
  { T{ key-down f { C+ } "," } excise-after }

  { T{ key-down f f "u" } unmutate-once }
  { T{ key-down f f "U" } remutate-once }
} define-command-map ] each

membrane-control "splicing" f {
  { T{ key-up f f "e" } show-splicer }
} define-command-map

wall "organising" f {
  { T{ key-down f f "TAB" } siphon-up }
  { T{ key-down f { C+ } "TAB" } swivel }
} define-command-map
membrane-control "organising" f {
  { T{ button-down { # 2 } } splinter }
  { T{ key-down f f "TAB" } splinter }
} define-command-map


