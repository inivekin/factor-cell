USING: cells classes splicer wall ;
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
    { [ dup non-empty-matrix? ] [ [ { } like ] { } map-as ] }
    { [ dup { [ length 1 = ] [ first tuple? ] } && ] [ first tuple>matrix flip ] }
    ! { [ dup { [ sequence? ] [ empty? not ] } 1&& ] [ 1array ] }
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
     ! concat
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
: auto-rank-down ( matrix -- sequence )
  dup dimension first2 [ 1 = [ flip concat ] when ] dip 1 = [ concat ] when ;
DEFER: organise
M: membrane-control organise cell>> control-value genes>> { } like ;
M: wall organise 
  grid>> {
    { [ dup tuple-as-matrix? ] [ matrix>tuple ] } ! 1x2 with with class type as first elem forms a tuple
    ! rank 1 matrix concats to array to mirror metabolise making an array into a rank1 matrix thing
    { [ dup matrix? ] [ [ organise ] matrix-map auto-rank-down auto-rank-down ] }
    [ throw ]
  } cond
  ; recursive

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

