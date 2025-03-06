USING: ui.gadgets ui.gadgets.sheets membranes organism ;
IN: wall

TUPLE: wall < frame organism ;

! M: wall request-focus-on [ get-coordinates ] [ parent>> request-focus-on ] 2bi ;

: pad-cols-after-amount ( cells sheet-grid -- n )
  [ dimension second ] bi@ - ;

: wall~>organism ( cell -- organism )
  [ { [ wall? ] [ organism>> ] } && ] find-parent organism>> ;
: <cancer> ( m n -- cancer )
  carcinogen <matrix-by-indices> ;

  
: pad-cols-before-amount ( pair cells -- m n )
  [ second ] [ dimension first ] bi* swap ;

: pad-cols-before ( cells pair -- padded )
  over pad-cols-before-amount [ drop ]
  [ <cancer> swap 2array stitch ] if-zero ;

: pad-new-rows-cols? ( n -- ? ) neg? ;

:: pad-cols-after ( cells pair sheet -- padded )
! if need to pad after new row?
  cells sheet grid>> pad-cols-after-amount [ cells ] ! no padding after needed, leave padded alone
  [
    dup neg?
    ! stitch more cells, then insert rows
    [ abs cells length swap <cancer> cells swap 2array stitch ]
    ! else need to pad fter sheet, insertpadding cols to sheets, then insert new rows
    [ sheet grid>> length swap <cancer> sheet dup grid>> -rot insert-cols cells ]
    if
  ] if-zero
  ; inline
: n-row-insert ( cells pair sheet -- )
  [ drop pad-cols-before ]
  [ pad-cols-after ]
  [ swapd insert-rows ] 2tri ; inline
: n-col-insert ( cells pair sheet -- )
  [ flip ] [ <reversed> ] [ dup grid>> flip >>grid ] tri* [ n-row-insert ] keep dup grid>> flip >>grid drop ;


: insert-cell-below ( membrane -- )
    [ mitosis ] [ cell-coordinate ] [ parent>> ] tri
    n-row-insert ;
: insert-cell-after ( membrane -- )
    [ mitosis ] [ cell-coordinate ] [ parent>> ] tri
    n-col-insert ;

: <wall> ( cells organism -- wall )
    swap dup dimension first2 wall new-frame swap
    [
        2array [ [ default-membrane-action ] <membrane-control> ] dip grid-add
    ] matrix-each-index
    swap >>organism ;

