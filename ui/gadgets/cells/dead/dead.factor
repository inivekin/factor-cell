USING: accessors arrays kernel ui.gadgets ui.gadgets.borders
ui.gadgets.cells.genomes ui.gadgets.cells.membranes
ui.gadgets.cells.mitochondria ui.gadgets.frames ui.gadgets.grids
;
IN: ui.gadgets.cells.dead

TUPLE: dead < border pair ;
M: dead focusable-child* gadget-child ;

: <dead-cell> ( pair -- gadget )
  1 2 mitochondrion new-frame
  <genome> { 0 0 } grid-add
  <membrane> { 0 1 } grid-add
  dead new-border { 1 1 } >>size { 1 1 } >>fill swap >>pair
  ;

: new-default-row ( row col -- cell )
  2array <dead-cell> ;

: new-default-col ( col row -- cell )
  swap new-default-row ;

