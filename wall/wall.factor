USING: ui.gadgets ui.gadgets.sheets membranes ;
FROM: ui.gadgets.scrollers.private => update-scroller ;
IN: wall

! don't update scroller if lower focused gadget already updated?
! M: wall update-scroller 2drop ;

: pad-cols-after-amount ( cells sheet-grid -- n )
  [ dimension second ] bi@ - ;

: probe ( dermis pairs -- cell )
  [ over clamp-pair-to-wall
   swap grid>> matrix-nth ] each ;

: dermis? ( cellular -- organism/? )
  { [ wall? ] [ organism>> ] } 1&& ;
: find-dermis ( cellular -- dermis/f )
  [ dermis? ] find-parent ;
: cell-coordinates ( cellular -- pairs )
  [ dup dermis? not ] [ [ parent>> ] [ cell-coordinate ] bi ] produce nip <reversed> ;

M: probe-able capture-cell ( cell -- capture )
  [ cell-coordinates ] [ find-dermis ] bi capture boa ;


M: capture present pairs>> make-cell-coords " ## " " " surround ;

: <cancer> ( m n -- cancer )
  carcinogen <matrix-by-indices> ;

: pad-cols-before-amount ( pair cells -- m n )
  [ second ] [ dimension first ] bi* swap ;

: pad-cols-before ( cells pair -- padded )
  over pad-cols-before-amount [ drop ]
  [ <cancer> swap 2array stitch ] if-zero ;

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

:: submatrix ( matrix pair-from pair-to  -- submatrix )
  matrix pair-to pair-from v- [ <iota> ] map first2 [ pair-from first v+n swap rows ] [ pair-from second v+n swap cols ] bi* ;

: insert-after ( cell pair-from pair-to quot: ( cell-pair-from pair-to -- cells ) -- )
  '[ _ call( cell pair-from pair-to -- cells ) ] 3keep 
  drop { 0 1 } v+ swap parent>> n-col-insert ;
: remove-after ( cell n -- removed )
  over [ cell-coordinate ] [ ] [ parent>> ] tri* remove-cols ;
: insert-below ( cell pair-from pair-to quot: ( cell-pair-from pair-to -- cells ) -- )
  '[ _ call( cell pair-from pair-to -- cells ) ] 3keep 
  drop { 1 0 } v+ swap parent>> n-row-insert ;
: remove-below ( cell n -- removed )
  over [ cell-coordinate ] [ ] [ parent>> ] tri* remove-rows ;

! TODO collect each cell model into a wall product, add/remove from product with insertion/removal above
: <wall> ( cells -- wall )
  dup dimension first2 wall new-frame { 2 2 } >>gap swap
  [ 2array [ <membrane-control> ] dip grid-add ] matrix-each-index ;
: <dermis> ( cells organism -- wall )
  [ <wall> ]
  [ >>organism ] bi* ;

