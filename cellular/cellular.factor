USING: organism membranes mutation wall ;
IN: cellular

: dye ( cell -- )
  dup wall? line-color selection-color ? <solid> >>boundary relayout-1 ;
: undye ( cell -- )
  content-background <solid> >>boundary relayout-1 ;

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

  { T{ key-down f f ";" } grow-below }
  { T{ key-down f { C+ } ";" } grow-after }
  { T{ key-down f f "," } excise-below }
  { T{ key-down f { C+ } "," } excise-after }

  { T{ key-down f f "u" } unmutate-once }
  { T{ key-down f f "U" } remutate-once }

  { T{ key-up f f "e" } show-splicer }

  { T{ button-down { # 2 } } splinter }
  { T{ key-down f f "TAB" } splinter }

} define-command-map ] each


