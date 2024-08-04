USING: accessors arrays kernel eval math ui.gadgets ui.gadgets.cells.cellular ui.gadgets.borders
ui.gadgets.cells.genomes ui.gadgets.cells.membranes ui.gadgets.cells.interlinks
ui.gadgets.cells.mitochondria ui.gadgets.frames ui.gadgets.grids
;
IN: ui.gadgets.cells.dead

TUPLE: dead < border pair ;
: cell-genome ( dead -- genome )
  gadget-child { 0 0 } grid-child
  ;
: cell-membrane ( dead -- genome )
  gadget-child { 0 1 } grid-child
  ;
M: dead focusable-child* cell-genome ;


M: dead absorb dup absorbing-cell [ cell-genome editor-string [ parse-string call( -- x ) ] with-interactive-vocabs ] with-variable ;

: <dead-cell> ( pair -- gadget )
  1 2 mitochondrion new-frame
  content-background <solid> >>interior
  <genome> { 0 0 } grid-add
  <membrane> { 0 1 } grid-add
  dead new-border { 0 0 } >>size { 1 1 } >>fill swap >>pair
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

