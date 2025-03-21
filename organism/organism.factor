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
  [ dup control-value second [ [ . ] each ] with-string-writer ]
  [ [ [ skin? ] find-parent organism>> splicer>> ] keep >>splicing [ set-editor-string ] keep ]
  [ [ loc>> ] [ dim>> 2 v/n ] bi <rect> ] tri
  over [ show-glass ] dip request-focus ;

: <organism> ( -- organism )
  organism new
  V{ } clone >>undo
  V{ } clone >>redo
  V{ } clone >>waste
  <splicer> >>splicer
  ;

: <cellular-organism> ( rows cols -- gadget )
  [ 2array [ ] curry { } clone swap 2array <cell> ] <cells>
  <organism> <wall> <scroller> white-interior
  ;

: <amoeba> ( -- gadget )
  1 1 <cellular-organism>
  ;

