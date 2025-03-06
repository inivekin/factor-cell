USING: ui.gadgets ui.gadgets.sheets membranes organism ;
IN: wall

TUPLE: wall < frame organism ;

! M: wall request-focus-on [ get-coordinates ] [ parent>> request-focus-on ] 2bi ;

: <cell-padding> ( m n filler: ( i j -- cell ) -- padding )
    <matrix-by-indices> ; inline

: pad-cells-before-amount ( cells pair -- m n )
  [ dimension first ] [ second ] bi* ;
: pad-cells-after-amount ( cells sheet-grid -- n )
  [ dimension second ] bi@ - ;

: wall~>organism ( cell -- organism )
  [ { [ wall? ] [ organism>> ] } && ] find-parent organism>> ;
: <padding> ( m n sheet -- padding )
  wall~>organism cell-divider <cell-padding> ;

  
:: (pad-cell-cols) ( sheet cells pair -- cells padding )
  ! cells before padding of new cell
  cells pair pad-cells-before-amount [ drop cells ] [
    sheet wall~>organism cell-divider <cell-padding> cells 2array stitch
  ] if-zero

  ! cells after padding of new cells or extra padding cells
  ! extra sheet lingers here
  [ sheet 2dup grid>> pad-cells-after-amount ] [ dimension first swap ] bi
  [ drop f swap ]
  [ dup neg?
    [ '[ _ _ abs sheet wall~>organism cell-divider <cell-padding> 2array stitch f ] dip ]
    [ sheet wall~>organism cell-divider <cell-padding> ] if
  ] if-zero drop ;
: pad-cell-cols ( sheet cells pair -- cells padding )
   (pad-cell-cols) ;

: pad-cols-before-amount ( pair cells -- m n )
  [ second ] [ dimension first ] bi* swap ;

: pad-cols-before ( cells pair sheet -- padded )
  [ over pad-cols-before-amount [ drop ] ]
  [ '[ _ <padding> swap 2array stitch ] if-zero ] bi* ; inline

: pad-new-rows-cols? ( n -- ? ) neg? ;

:: pad-cols-after ( cells pair sheet -- padded )
! if need to pad after new row?
    ! stitch more cells, then insert rows
! else need to pad fter sheet, insertpadding cols to sheets, then insert new rows
  cells sheet grid>> pad-cells-after-amount [ cells ] ! no padding after needed, leave padded alone
  [
    dup neg?
    [ abs cells length swap sheet <padding> cells swap 2array stitch ]
    [ sheet grid>> length swap sheet <padding> sheet dup grid>> -rot insert-cols cells ] if
  ] if-zero
  ; inline
: n-row-insert ( cells pair sheet -- )
  [ pad-cols-before ]
  [ pad-cols-after ]
  [ swapd insert-rows ] 2tri ; inline
: n-col-insert ( cells pair sheet -- )
  [ flip ] [ <reversed> ] [ dup grid>> flip >>grid ] tri* [ n-row-insert ] keep dup grid>> flip >>grid drop ;


: insert-cell-below-old ( membrane -- )
  [
    [ parent>> ]
    [
      [ cell>> ] [ [ wall? ] find-parent ] bi
      organism>> cell-division [ default-membrane-action ] <membrane-control> 1array 1array
    ]
    [ cell-coordinate ]
    tri
    [ pad-cell-cols ] keep
  ]
  [ parent>> insert-cells-shift-rows ] bi ;
: insert-cell-below ( membrane -- )
    [
      [ cell>> ] [ [ wall? ] find-parent ] bi
      organism>> cell-division [ default-membrane-action ] <membrane-control> 1array 1array
    ]
    [ cell-coordinate ]
    [ parent>> ]
    tri
    n-row-insert ;
: insert-cell-after ( membrane -- )
    [
      [ cell>> ] [ [ wall? ] find-parent ] bi
      organism>> cell-division [ default-membrane-action ] <membrane-control> 1array 1array
    ]
    [ cell-coordinate ]
    [ parent>> ]
    tri
    n-col-insert ;

: <wall> ( organism cells -- wall )
    dup dimension first2 wall new-frame swap
    [
        2array [ [ default-membrane-action ] <membrane-control> ] dip grid-add
    ] matrix-each-index
    swap >>organism ;

