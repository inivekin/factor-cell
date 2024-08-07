USING: ui.gadgets.panes ;
IN: ui.gadgets.cells.membranes

TUPLE: membrane < pane ;

: <membrane> ( -- membrane )
  f membrane new-pane { 1 1 } <filled-border> ;
