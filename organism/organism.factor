USING: cells splicer wall ;
IN: organism

TUPLE: organism
    cells
    undo
    redo
    waste
    splicer
    ;

: show-splicer ( cell -- )
  [ dup control-value genes>> [ [ . ] each ] with-string-writer ]
  [ [ [ skin? ] find-parent organism>> splicer>> ] keep
    >>splicing [ set-editor-string ] keep
    { 2 2 } <border> white-interior
    popup-color <solid> >>boundary
  ]
  [ [ loc>> ] [ dim>> 2 v/n ] bi <rect> ] tri
  over [ show-glass ] dip request-focus ;

: <organism> ( -- organism )
  organism new
  V{ } clone >>undo
  V{ } clone >>redo
  V{ } clone >>waste
  <splicer>
  >>splicer
  ;

: <cellular-organism> ( rows cols -- gadget )
  [ 2array drop { } [ "e to edit" print-element ] { } <fold> <cell> ] <cells>
  <organism> <skin> <scroller> white-interior
  ;

: <amoeba> ( -- gadget )
  1 1 <cellular-organism>
  ;

