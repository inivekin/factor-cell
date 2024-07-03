USING: accessors arrays kernel eval math ui.gadgets ui.gadgets.cells.cellular ui.gadgets.borders
ui.gadgets.cells.genomes ui.gadgets.cells.membranes ui.gadgets.cells.interlinks
ui.gadgets.cells.mitochondria ui.gadgets.frames ui.gadgets.grids
;
IN: ui.gadgets.cells.dead

TUPLE: dead < border pair ;
M: dead focusable-child* gadget-child ;

: cell-genome ( dead -- genome )
  gadget-child { 0 0 } grid-child
  ;

M: dead absorb dup absorbing-cell [ cell-genome editor-string [ parse-string call( -- x ) ] with-interactive-vocabs ] with-variable ;

: <dead-cell> ( pair -- gadget )
  1 2 mitochondrion new-frame
  content-background <solid> >>interior
  <genome> { 0 0 } grid-add
  <membrane> { 0 1 } grid-add
  dead new-border { 1 1 } >>size { 1 1 } >>fill swap >>pair
  line-color <solid> >>interior
  ;

! : <default-cell> ( pair -- gadget ) <dead-cell> ;

: toggle-editor ( cell -- )
  [
    gadget-child dup { 0 0 } grid-child genome?
    [ [ dup { 0 0 } grid-child f >>visible? editor-string >>dormant drop ] [ { 0 0 } grid-remove drop ] bi ]
    [ dup dormant>> <genome> [ set-editor-string ] keep { 0 0 } grid-add drop ] if
  ] keep relayout
  ;

