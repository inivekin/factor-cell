USING: accessors kernel math ui.commands ui.gadgets
ui.gadgets.cells.cellular ui.gadgets.cells.walls
ui.gadgets.editors ui.gestures ;
IN: ui.gadgets.cells.genomes

TUPLE: genome < editor ;
INSTANCE: genome cellular

M: cellular increase-cell-size ( cellular -- )
  [ dup font>> dup size>> 1 + >>size clone swap font<< ]
  [ relayout ]
  bi ;
M: cellular decrease-cell-size ( cellular -- )
  [ dup font>> dup size>> 1 - >>size clone swap font<< ]
  [ relayout ]
  bi ;


: <genome> ( -- genome )
  genome new-editor ;

: force-propagate-ctrl-l ( genome -- )
  T{ key-down f { C+ } "l" } swap parent>> propagate-gesture
  ;

genome "cell" f {
  { T{ key-down f { C+ } "UP" } increase-cell-size }
  { T{ key-down f { C+ } "DOWN" } decrease-cell-size }

  { T{ key-down f { C+ } "l" } force-propagate-ctrl-l }
} define-command-map

