USING: cells ui.gadgets.sheets proteins ;
FROM: namespaces => set ;
IN: membranes

TUPLE: membrane-control < pane-control cell ;

: <membrane-control> ( cell -- membrane )
  f membrane-control new-pane
  [ synthesize ] >>quot over >>cell swap model>> >>model { 2 2 } >>gap ; 

: mitosis ( membranes -- membranes )
  [ cell>> (mitosis) <membrane-control> ] matrix-map ;
: carcinogen ( -- divider: ( i j -- membrane ) )
  [ 2array drop [ ] <chain> <cell> <membrane-control> ] ; inline

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

