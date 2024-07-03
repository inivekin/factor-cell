USING: ui.gadgets.borders ui.gadgets.cells.cellular ;
IN: ui.gadgets.cells.alive

TUPLE: alive < border pair ref ;
! M: alive focusable-child* gadget-child ;

M: alive absorb ref>> ;

: <alive-cell> ( obj pair -- gadget )
  <membrane>
  alive new-border { 1 1 } >>size { 1 1 } >>fill
  swap >>pair
  swap >>ref
  ;

: <default-cell> ( pair -- gadget ) f swap <alive-cell> ;
