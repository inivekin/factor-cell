USING: accessors concurrency.flags documents.elements kernel
math ui.commands ui.gadgets ui.gadgets.cells.cellular
ui.gadgets.cells.walls ui.gadgets.editors ui.gestures
ui.tools.listener ui.tools.listener.completion
ui.tools.listener.history ;
IN: ui.gadgets.cells.genomes

TUPLE: genome < interactor ;
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
  genome new-editor <flag> >>flag
  dup one-word-elt <element-model> >>token-model
  dup <word-model> >>word-model
  dup model>> <history> >>history ;

: force-propagate-ctrl-l ( genome -- ) T{ key-down f { C+ } "l" } swap parent>> propagate-gesture ;
: force-propagate-ctrl-j ( genome -- ) T{ key-down f { C+ } "j" } swap parent>> propagate-gesture ;

genome "cell" f {
  { T{ key-down f { C+ } "UP" } increase-cell-size }
  { T{ key-down f { C+ } "DOWN" } decrease-cell-size }

  { T{ key-down f { C+ } "l" } force-propagate-ctrl-l }
  { T{ key-down f { C+ } "j" } force-propagate-ctrl-j }
  { T{ key-down f f "TAB" } code-completion-popup }
} define-command-map

