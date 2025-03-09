USING: cells ui.gadgets.sheets ;
FROM: namespaces => set ;
IN: membranes

TUPLE: membrane-control < pane-control cell ;

: default-membrane-action ( quot -- )
  [ dup gadget? [ gadget. ] [ . ] if ] compose { } clone swap with-datastack drop
  ;
: <membrane-control> ( cell quot -- membrane )
  f membrane-control new-pane
  swap >>quot over >>cell swap model>> >>model { 1 1 } >>gap ; 

: mitosis ( membranes -- membranes )
  [ cell>> (mitosis) [ default-membrane-action ] <membrane-control> ] matrix-map ;
: carcinogen ( -- divider: ( i j -- membrane ) )
  [ 2array [ ] curry <cell> [ default-membrane-action ] <membrane-control> ] ; inline


: dye-cell ( cell -- )
  selection-color <solid> >>boundary relayout-1 ;
: undye-cell ( cell -- )
  content-background <solid> >>boundary relayout-1 ;

: tint-cell ( cell -- )
  line-color <solid> >>interior relayout-1 ;
: untint-cell ( cell -- )
  content-background <solid> >>interior relayout-1 ;

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

