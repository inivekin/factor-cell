! Copyright (C) 2024 Your name.
! See https://factorcode.org/license.txt for BSD license.
USING: ui.gadgets.grids ui.gestures ;
IN: ui.gadgets.tree-cells

TUPLE: treecell < grid saved selected element-id ;

: new-treecell ( children class -- treecell )
    new-grid ;

: <treecell> ( children -- treecell )
    treecell new-treecell dim-color <solid> >>boundary ;

: begin-drag ( treecell -- )
    dup loc>> >>saved drop ;

: do-drag ( treecell -- )
    ! from saved loc, select all cells to current loc
    drop
    ;

treecell H{
    { T{ button-down f f 2 } [ begin-drag ] }
    { T{ button-up f f 2 } [ drop ] }
    { T{ drag } [ do-drag ] }
} set-gestures

