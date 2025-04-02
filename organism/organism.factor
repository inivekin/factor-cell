USING: cells classes io splicer wall ;
IN: organism

TUPLE: organism
    cells
    undo
    redo
    waste
    splicer
    ;

MIXIN: organisable
GENERIC: organise ( cell -- obj )
INSTANCE: membrane-control organisable
INSTANCE: wall organisable

: non-empty-matrix? ( x -- ? )
  { [ matrix? ] [ empty? not ] [ first empty? not ] } 1&& ;
: (metabolise) ( obj -- matrix )
  {
    { [ dup first non-empty-matrix? ] [ [ { } like ] { } map-as flip concat ] }
    { [ dup { [ length 1 = ] [ first tuple? ] } 1&& ] [ first tuple>matrix flip ] }
    { [ dup first { [ sequence? ] [ empty? not ] } 1&& ] [ 1array concat ] }
    ! TODO make this 1d handling work for straight up gene cells { [ dup { [ sequence? ] [ empty? not ] } 1&& ] [ 1array ] }
    [ throw ]
  } cond ;
  
: metabolise ( obj -- wall )
  (metabolise) [ [ ] curry <chain> <cell> ] matrix-map <wall> ;
: matrix>tuple ( matrix -- obj )
  dup dimension second 2 = [ flip ] when first2
  [ first organise
       first
   wrapped>> ]
  [ first organise
     dup dimension second 2 = [ flip ] unless ]
  bi* 1 swap col swap slots>tuple ;
: tuple-as-matrix? ( matrix -- ? )
  {
    [ dimension product 2 = ]
    [ first first organise
         first
         dup wrapper? [ wrapped>> class? ] [ drop f ] if ]
  } 1&&
  ;
DEFER: organise
M: membrane-control organise cell>> control-value genes>> { } like ;
M: wall organise 
  grid>> {
    { [ dup tuple-as-matrix? ] [ matrix>tuple ] } ! 1x2 with with class type as first elem forms a tuple
    { [ dup first matrix? ] [ [ organise ] matrix-map concat ] }
    { [ dup first sequence? ] [ [ organise ] matrix-map [ concat ] map flip ] }
    [ throw ]
  } cond
  ; recursive

: gadget>rect ( gadget -- rect )
  [ loc>> ] [ dim>> 2 v/n ] bi <rect> ;
: show-splicer ( cell -- )
  [ dup control-value genes>> [ [ dup { [ wall? ] [ membrane-control? ] } 1|| [ "## " swap present append write " " write ] [ . ] if ] each ] with-string-writer ]
  [ [ find-skin organism>> splicer>> ] keep
    >>splicing [ set-editor-string ] keep
    { 2 2 } <border> ! <scroller> { 2 2 } >>gap
    white-interior
    popup-color <solid> >>boundary
  ]
  [ gadget>rect ] tri
  over [ show-glass ] dip [ relayout ] [ request-focus ] bi ;

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

