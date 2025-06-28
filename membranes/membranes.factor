USING: cells ui.gadgets.sheets proteins interlinks ;
FROM: namespaces => set ;
IN: membranes

: mitosis ( membranes -- membranes )
  [ (mitosis) ] matrix-map ;

: tint-cell ( cell -- )
  line-color <solid> >>interior relayout-1 ;
: untint-cell ( cell -- )
  content-background <solid> >>interior relayout-1 ;

