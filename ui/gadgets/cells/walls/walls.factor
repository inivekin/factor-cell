USING: ui.gadgets.grids sequences.zipped math.matrices ;
IN: ui.gadgets.cells.walls

TUPLE: wall < grid pair ;

MIXIN: multicellular
INSTANCE: wall multicellular

: matrix-dim ( matrix -- x y ) [ length ] [ first length ] bi ;

: add-cells ( multicell cells -- )
  [ add-gadget drop ] with each
  ;

! all cells not getting the inserted cell must get an appended cell
:: (create-cells-for-insert) ( pair dim cell-gen: ( col row -- gadget ) -- seq )
  dim first <iota> cell-gen
  '[ dup pair first = [ pair second ] [ dim second ] if @ ] map
  ; inline

: create-cells-for-row-insert ( pair multicell quot: ( col row -- cell ) -- seq )
  '[ _ [ grid>> matrix-dim 2array ] dip (create-cells-for-insert) ] keep over add-cells
  ; inline

: create-cells-for-col-insert ( pair multicell quot: ( col row -- cell ) -- seq )
  '[ _ [ grid>> matrix-dim swap 2array ] dip (create-cells-for-insert) ] keep over add-cells
  ; inline

<PRIVATE
: each-cell ( quot: ( cell -- ) -- ) '[ [ gadget-child @ ] each ] each ; inline
: map-cells ( cells quot: ( cell -- cell ) -- cells' ) '[ [ gadget-child @ ] map ] map ; inline

: change-pair-el ( cell n quote: ( n -- n ) -- )
  [ swap pair>> ] dip change-nth ; inline
: increment-rows ( cells -- ) [ 1 [ 1 + ] change-pair-el ] each-cell ;
: increment-cols ( cells -- ) [ 0 [ 1 + ] change-pair-el ] each-cell ;

: insert-rows ( cell row row-id -- cells )
  [ 1vector ] 2dip cut dup 1vector increment-rows surround ;

: insert-cols ( cell col col-id -- cells )
  [ 1vector ] 2dip cut dup 1vector increment-cols surround
  ;

: append-cell ( cell cells -- cells' )
  swap suffix ;

:: insert-on-index-else-append ( multicell cells insert-idx inserter -- grid' )
  cells multicell <zipped> <enumerated>
  [
    [ first insert-idx = ] ! the enumeration
    [ second first2 rot inserter [ append-cell ] if ] ! the grid and row/column
    bi
  ] map
  ; inline
PRIVATE>

GENERIC: insert-cells-by-row ( cells col row multi-cell -- )
GENERIC: insert-cells-by-col ( cells col row multi-cell -- )
GENERIC: cell-nth ( pair multicell -- cell )

M: multicellular insert-cells-by-row [ grid>> -roll '[ _ insert-rows ] insert-on-index-else-append ] keep grid<< ;
M: multicellular insert-cells-by-col [ grid>> flip -roll '[ _ insert-cols ] insert-on-index-else-append flip ] keep grid<< ;
M: multicellular cell-nth grid>> matrix-nth gadget-child ;

: 1matrix ( el -- matrix ) 1vector 1vector ;

: <cell-wall> ( children pair -- gadget )
  swap wall new-grid dim-color <solid> >>boundary swap >>pair ;
