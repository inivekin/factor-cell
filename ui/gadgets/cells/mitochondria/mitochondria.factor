USING: accessors kernel math.order ui.gadgets ui.gadgets.frames
ui.gadgets.grids ;
IN: ui.gadgets.cells.mitochondria

TUPLE: mitochondrion < frame dormant ;
M: mitochondrion focusable-child* dup dormant>> [ drop f ] [ 
    gadget-child { 0 0 } grid-child ! cell-genome
    ] if ;

