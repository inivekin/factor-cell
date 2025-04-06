USING: cells ui.gadgets.sheets proteins interlinks ;
FROM: namespaces => set ;
IN: membranes

: <membrane-control> ( model -- membrane )
  f membrane-control new-pane
  ! you're gonna need to curry that pane, son.
  dup [ absorbing-cell [ synthesize ] with-variable ] curry >>quot
  swap >>model { 2 2 } >>gap ! 0.5 >>fill
  ; 

: mitosis ( membranes -- membranes )
  [ (mitosis) <membrane-control> ] matrix-map ;
: carcinogen ( -- divider: ( i j -- membrane ) )
  [ 2array drop [ ] <chain> <cell> <membrane-control> ] ; inline

: tint-cell ( cell -- )
  line-color <solid> >>interior relayout-1 ;
: untint-cell ( cell -- )
  content-background <solid> >>interior relayout-1 ;

