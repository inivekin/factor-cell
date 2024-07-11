USING: ui.gadgets.borders ui.gadgets.cells.cellular ;
IN: ui.gadgets.cells.alive

TUPLE: alive < border pair ref ;
! M: alive focusable-child* gadget-child ;

: map-embedded-matrix-tuples ( matrix -- matrix )
  dup non-empty-matrix? [ [ [ dup { [ non-empty-matrix? ] [ tuple-as-matrix? ] } 1&& [ matrix>tuple ] [ map-embedded-matrix-tuples ] if ] map ] map ] when ; recursive
M: alive absorb ref>> map-embedded-matrix-tuples ;

: <alive-cell> ( obj pair -- gadget )
  <membrane>
  content-background <solid> >>interior
  alive new-border { 1 1 } >>size { 1 1 } >>fill
  swap >>pair
  swap >>ref
  content-background <solid> >>interior
  ;

: <default-cell> ( pair -- gadget ) f swap <alive-cell> ;
