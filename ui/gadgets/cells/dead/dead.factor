USING: accessors arrays eval kernel listener math namespaces
ui.gadgets ui.gadgets.borders ui.gadgets.cells.cellular
ui.gadgets.cells.genomes ui.gadgets.cells.membranes
ui.gadgets.cells.mitochondria ui.gadgets.frames ui.gadgets.grids
ui.pens.solid ui.theme ui.tools.listener ;
IN: ui.gadgets.cells.dead

TUPLE: dead < border pair ;
: cell-genome ( dead -- genome )
  gadget-child { 0 0 } grid-child
  ;
: cell-membrane ( dead -- genome )
  gadget-child { 0 1 } grid-child
  gadget-child
  ;
M: dead focusable-child* cell-genome ;

: <dead-cell> ( pair -- gadget )
  1 2 mitochondrion new-frame white-interior
  <membrane> [ { 0 1 } grid-add ] keep gadget-child
  <genome> [ swap >>output { 0 0 } grid-add ] keep
  '[ [ _ ] 2dip debugger-popup ] error-hook set
  dead new-border { 1 1 } >>size { 1 1 } >>fill swap >>pair
  code-border-color <solid> >>interior
  ;

! : <default-cell> ( pair -- gadget ) <dead-cell> ;

: toggle-editor ( cell -- )
  [
    gadget-child dup { 0 0 } grid-child genome?
    [ [ dup { 0 0 } grid-child f >>visible? >>dormant drop ] [ { 0 0 } grid-remove { 0 1 } >>filled-cell drop ] bi ]
    [ dup dormant>> t >>visible? { 0 0 } grid-add f >>dormant { 0 0 } >>filled-cell drop ] if
  ] keep relayout
  ;

