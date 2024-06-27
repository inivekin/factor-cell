USING: ui.gadgets ;
IN: ui.gadgets.cells.cellular

! something that can be in a cell
MIXIN: cellular

! TODO(kevinc) add in a replacer so you can specify dead/living/cancer cell types
GENERIC: (insert-cell-above) ( cell -- cell' )
: insert-cell-above ( cellular -- ) (insert-cell-above) gadget-child request-focus ;
GENERIC: (insert-cell-below) ( cell -- cell' )
: insert-cell-below ( cellular -- ) (insert-cell-below) gadget-child request-focus ;
GENERIC: (insert-cell-before) ( cell -- cell' )
: insert-cell-before ( cellular -- ) (insert-cell-before) gadget-child request-focus ;
GENERIC: (insert-cell-after) ( cell -- cell' )
: insert-cell-after ( cellular -- ) (insert-cell-after) gadget-child request-focus ;

GENERIC: remove-row ( cell -- )
GENERIC: remove-col ( cell -- )

GENERIC: focus-cell-above ( cell -- )
GENERIC: focus-cell-below ( cell -- )
GENERIC: focus-cell-before ( cell -- )
GENERIC: focus-cell-after ( cell -- )

GENERIC: insert-row-above ( cell -- )
GENERIC: insert-row-below ( cell -- )
GENERIC: insert-col-before ( cell -- )
GENERIC: insert-col-after ( cell -- )

GENERIC: embed-cell-in-wall ( cell -- )

