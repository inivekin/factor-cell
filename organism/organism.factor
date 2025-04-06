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

: #> ( membrane-control -- obj )
  control-value [ clone ] { } map-as ;
: #& ( membrane-control -- model )
  model>> ;

: non-empty-matrix? ( x -- ? )
  { [ matrix? ] [ empty? not ] [ first empty? not ] } 1&& ;
: (metabolise) ( obj -- matrix )
  {
    { [ dup first non-empty-matrix? ] [ [ { } like ] { } map-as flip concat ] }
    { [ dup { [ length 1 = ] [ first tuple? ] } 1&& ] [ first tuple>matrix ] }
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
M: membrane-control organise ; ! control-value genes>> { } like ;
M: wall organise 
  grid>> {
    { [ dup tuple-as-matrix? ] [ matrix>tuple ] } ! 1x2 with with class type as first elem forms a tuple
    { [ dup first matrix? ] [ [ organise ] matrix-map concat ] }
    { [ dup first sequence? ] [ [ organise ] matrix-map [ concat ] map flip ] }
    [ throw ]
  } cond
  ; recursive
M: gadget organise ;

: gadget>rect ( gadget -- rect )
  [ loc>> ] [ dim>> 2 v/n ] bi <rect> ;
: deactivate-dermal-splicer ( splicer -- )
  parent>> <gadget> { 0 1 } grid-add { 0 0 } >>filled-cell drop ;
: activate-dermal-splicer ( dermis -- splicer )
  [ parent>> parent>> parent>> ] [ organism>> splicer>> popup-color <solid> >>boundary ] bi { 0 1 } grid-add
  grid>> { 1 0 } swap matrix-nth ;
: show-splicer ( cell -- )
  [ control-value dup sequence? [ last ] when genes>> [ [ { { [ dup { [ wall? ] [ membrane-control? ] } 1|| ] [ capture-cell present write ] } { [ dup capture? ] [ present write ] } [ . ] } cond ] each ] with-string-writer ]
  [ find-dermis activate-dermal-splicer ]
  [ >>splicing [ set-editor-string ] keep request-focus ] tri ;

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
  <organism> <dermis> 
  ;

: <epidermis> ( row cols -- gadget )
  <cellular-organism> [ drop <gadget> ] [ <scroller> white-interior ] bi
  ! [ <cell> ] bi@ 2array 1array flip <wall>
  1 2 <frame> { 2 2 } >>gap swap { 0 0 } grid-add swap { 0 1 } grid-add white-interior { 0 0 } >>filled-cell
  ;

: <amoeba> ( -- gadget )
  1 1 <epidermis>
  ;

