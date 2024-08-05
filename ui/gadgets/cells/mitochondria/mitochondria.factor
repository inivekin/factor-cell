USING: math.order ui.gadgets ui.gadgets.frames ;
IN: ui.gadgets.cells.mitochondria

TUPLE: mitochondrion < frame dormant ;
M: mitochondrion focusable-child* dup dormant>> [ drop f ] [ cell-genome ] if ;

