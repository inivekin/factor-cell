USING: ui.commands ui.gadgets.cells.cellular ui.gadgets.cells.metabolics ui.gadgets.cells.walls ui.gadgets.editors
ui.gestures ;
IN: ui.gadgets.cells.mitochondria

TUPLE: mitochondrion < editor ;
INSTANCE: mitochondrion cellular
INSTANCE: mitochondrion metabolic

: <mitochondrion> ( -- mitochondrion )
  mitochondrion new-editor ;

mitochondrion "cell" f {
  { T{ key-down f { C+ } "O" } insert-cell-above }
  { T{ key-down f { C+ } "o" } insert-cell-below }
  { T{ key-down f { C+ } "i" } insert-cell-before }
  { T{ key-down f { C+ } "a" } insert-cell-after }

  { T{ key-down f { C+ } "k" } focus-cell-above }
  { T{ key-down f { C+ } "l" } focus-cell-after }
  { T{ key-down f { C+ } "h" } focus-cell-before }
  { T{ key-down f { C+ } "j" } focus-cell-below }
  ! { T{ key-down f { C+ } "K" } clone-cell-above }
  ! { T{ key-down f { C+ } "L" } clone-cell-after }
  ! { T{ key-down f { C+ } "H" } clone-cell-before }
  ! { T{ key-down f { C+ } "J" } clone-cell-below }

  { T{ key-down f { C+ } "-" } insert-row-above }
  { T{ key-down f { C+ } "_" } insert-row-below }
  { T{ key-down f { C+ } "[" } insert-col-before }
  { T{ key-down f { C+ } "]" } insert-col-after }

  { T{ key-down f { C+ } "#" } embed-cell-in-wall }
  { T{ key-down f { C+ } "%" } transpose-cells }

  { T{ key-down f { C+ } ">" } metabolize-rightward }
  { T{ key-down f { C+ } "<" } metabolize-leftward }
  { T{ key-down f { C+ } "v" } metabolize-downward }
  { T{ key-down f { C+ } "^" } metabolize-upward }

  { T{ key-down f { C+ } "UP" } increase-cell-size }
  { T{ key-down f { C+ } "DOWN" } decrease-cell-size }

  ! { T{ key-down f { C+ } "O" } remove-cell-above }
  ! { T{ key-down f { C+ } "o" } remove-cell-below }
  ! { T{ key-down f { C+ } "i" } remove-cell-before }
  ! { T{ key-down f { C+ } "a" } remove-cell-after }
  { T{ key-down f { C+ } "$" } remove-col }
  { T{ key-down f { C+ } "~" } remove-row }
} define-command-map

