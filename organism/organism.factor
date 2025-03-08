USING: cells wall ;
IN: organism

TUPLE: organism
    cells
    undo
    redo
    waste
    ;

: <organism> ( -- organism )
    organism new
    V{ } clone >>undo
    V{ } clone >>redo
    V{ } clone >>waste ;

: <cellular-organism> ( rows cols -- gadget )
    [ 2array <cell> ] <cells>
    <organism> <wall> <scroller> white-interior
    ;

: <amoeba> ( -- gadget )
    1 1 <cellular-organism>
    ;

