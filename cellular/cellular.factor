USING: mutation scopes wall namespaces ;
IN: cellular

: dye ( cell -- )
  [ scroll>gadget ]
  [ dup wall? dim-color selection-color ? <solid> >>boundary relayout-1 ] bi ;
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
  { T{ key-up f f "k" } focus-membrane-above }
  { T{ key-up f f "h" } focus-membrane-before }
  { T{ key-up f f "j" } focus-membrane-below }
  { T{ key-up f f "l" } focus-membrane-after }
  { T{ key-up f f "ESC" } focus-out }
  { T{ key-up f f "RET" } focus-in }
  { T{ key-up f f "/" } highlighter-search }
} define-command-map ] each

{ membrane-control wall } [ "mutating" f {
  { T{ key-up f f ";" } grow-below }
  { T{ key-up f { C+ } ";" } grow-after }
  { T{ key-up f f "," } excise-below }
  { T{ key-up f { C+ } "," } excise-after }

  { T{ key-up f f "u" } unmutate-once }
  { T{ key-up f f "U" } remutate-once }
  { T{ key-up f f "f" } freeze }
  { T{ key-up f f "F" } thaw }
} define-command-map ] each

membrane-control "splicing" f {
  { T{ key-up f f "e" } show-splicer }
} define-command-map

wall "organising" f {
  { T{ key-up f f "TAB" } siphon-up }
  { T{ key-up f { C+ } "TAB" } swivel }
} define-command-map
membrane-control "organising" f {
  { T{ button-up { # 2 } } splinter }
  { T{ key-up f f "TAB" } splinter }
} define-command-map

{ membrane-control wall } [ "common" f {
    { T{ key-down f ${ os macos? M+ A+ ? } "t" } show-active-buttons-popup }
} define-command-map ] each
