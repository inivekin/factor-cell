USING: ui.gadgets ui.gadgets.sheets membranes ;
IN: wall

TUPLE: wall < frame organism ;

: pad-cols-after-amount ( cells sheet-grid -- n )
  [ dimension second ] bi@ - ;

: probe ( skin pairs -- cell )
  [ swap grid>> matrix-nth ] each ;
  
: skin? ( cellular -- organism/? )
  { [ wall? ] [ organism>> ] } && ;
: find-skin ( cellular -- skin/f )
  [ skin? ] find-parent ;
: cell-coordinates ( cellular -- pairs )
  [ dup skin? not ] [ [ parent>> ] [ cell-coordinate ] bi ] produce nip <reversed> ;

: get-rel-cells ( cell pairs -- cells )
  [ [ parent>> grid>> ] [ cell-coordinates last ] bi ]
  [ [ v+ swap matrix-nth ] 2with map ] bi*
  ;

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

: insert-after ( cell pair-from pair-to  -- )
  ! [ [ parent>> grid>> ] 2dip submatrix mitosis ] ! FIXME use mutagen dna to generate cells
  [ swap v- nip first2 <cancer> ]
  [ drop { 0 1 } v+ swap parent>> ] 3bi n-col-insert ;
: remove-after ( cell n -- removed )
  over [ cell-coordinate ] [ ] [ parent>> ] tri* remove-cols ;
: insert-below ( cell pair-from pair-to -- )
  ! [ [ parent>> grid>> ] 2dip submatrix mitosis ]
  [ swap v- nip first2 <cancer> ]
  [ drop { 1 0 } v+ swap parent>> ] 3bi n-row-insert ;
: remove-below ( cell n -- removed )
  over [ cell-coordinate ] [ ] [ parent>> ] tri* remove-rows ;

: swapout ( replacer pair sheet -- replaced )
  [ grid>> matrix-nth swap ]
  [ -rot <reversed> grid-add drop ] 2bi ;

: <wall> ( cells -- wall )
  dup dimension first2 wall new-frame { 2 2 } >>gap swap
  [ 2array [ <membrane-control> ] dip grid-add ] matrix-each-index ;
: <skin> ( cells organism -- wall )
  [ <wall> ]
  [ >>organism ] bi* ;

