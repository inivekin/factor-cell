USING: cells wall ;
IN: organism

TUPLE: organism
    cells
    undo
    redo
    ;

! mitosis
: cell-division ( cell organism -- new-cell )
    [ control-value clone <cell> ] [ cells>> '[ _ push-model ] keep ] bi* ;

: cell-divider ( organism -- divider: ( i j -- membrane ) )
    '[ 2array <cell> [ _ cells>> push-model ] [ [ default-membrane-action ] <membrane-control> ] bi ] ; inline

: <organism> ( cells -- organism )
    organism new swap <model> >>cells
    V{ } clone [ >>undo ] [ >>redo ] bi ;

: <cellular-organism> ( rows cols -- gadget )
    [ 2array <cell> ] <cells>
    [ V{ } concat-as <organism> ] [ <wall> <scroller> white-interior ] bi
    ;

: <amoeba> ( -- gadget )
    1 1 <cellular-organism>
    ;

{ membrane-control wall } [ "highlighting" f {
  { gain-focus dye-cell }
  { lose-focus undye-cell }
  { mouse-enter tint-cell }
  { mouse-leave untint-cell }
  { T{ button-up } focus-cell }
  { T{ key-down f f "k" } focus-membrane-above }
  { T{ key-down f f "h" } focus-membrane-before }
  { T{ key-down f f "j" } focus-membrane-below }
  { T{ key-down f f "l" } focus-membrane-after }

  { T{ key-down f f "o" } insert-cell-below }
  { T{ key-down f f "a" } insert-cell-after }
} define-command-map ] each

