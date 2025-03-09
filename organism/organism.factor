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
  [ dup control-value [ ... ] with-string-writer ]
  [ [ [ skin? ] find-parent organism>> splicer>> ] keep >>splicing [ set-editor-string ] keep ]
  [ [ loc>> ] [ dim>> 2 v/n ] bi <rect> ] tri
  show-glass ;

: <organism> ( -- organism )
  organism new
  V{ } clone >>undo
  V{ } clone >>redo
  V{ } clone >>waste
  <splicer> >>splicer
  ;

: <cellular-organism> ( rows cols -- gadget )
  [ 2array [ ] curry <cell> ] <cells>
  <organism> <wall> <scroller> white-interior
  ;

: <amoeba> ( -- gadget )
  1 1 <cellular-organism>
  ;

