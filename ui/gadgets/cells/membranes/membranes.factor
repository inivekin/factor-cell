USING: accessors ui.gadgets.borders ui.gadgets.panes ;
IN: ui.gadgets.cells.membranes

TUPLE: membrane < pane ;

: <membrane> ( -- membrane )
  f membrane new-pane { 0 0 } <filled-border> white-interior t >>root? ;
