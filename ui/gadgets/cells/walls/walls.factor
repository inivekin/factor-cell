USING: accessors arrays assocs kernel math math.matrices
sequences sequences.zipped ui.gadgets ui.gadgets.grids
ui.pens.solid ui.theme vectors ;
IN: ui.gadgets.cells.walls

TUPLE: wall < grid pair ;

M: wall focusable-child* gadget-child gadget-child ;

MIXIN: multicellular
INSTANCE: wall multicellular

: matrix-dim ( matrix -- x y ) [ length ] [ first length ] bi ;

: find-wall ( gadget -- wall/f ) [ wall? ] find-parent ;

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
: create-cell-row ( row-index multicell quot: ( col row -- cell ) -- seq )
  '[ _ [ grid>> matrix-dim nip <iota> ] dip with map ] keep over add-cells ; inline
: create-cell-col ( row-index multicell quot: ( col row -- cell ) -- seq )
  '[ _ [ grid>> matrix-dim drop <iota> ] dip with map ] keep over add-cells ; inline

: create-cells-for-col-insert ( pair multicell quot: ( col row -- cell ) -- seq )
  '[ _ [ grid>> matrix-dim swap 2array ] dip (create-cells-for-insert) ] keep over add-cells
  ; inline

: each-cell ( cells quot: ( cell -- ) -- ) '[ [ dup wall? [ gadget-child ] unless @ ] each ] each ; inline
: map-cells ( cells quot: ( cell -- cell ) -- cells' ) '[ [ dup wall? [ gadget-child ] unless @ ] map ] map ; inline

<PRIVATE
: change-pair-el ( cell n quote: ( n -- n ) -- )
  [ swap pair>> ] dip change-nth ; inline
: increment-rows ( cells -- ) [ 1 [ 1 + ] change-pair-el ] each-cell ;
: increment-cols ( cells -- ) [ 0 [ 1 + ] change-pair-el ] each-cell ;
: decrement-rows ( cells -- ) [ 1 [ 1 - ] change-pair-el ] each-cell ;
: decrement-cols ( cells -- ) [ 0 [ 1 - ] change-pair-el ] each-cell ;

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

: (insert-cell-row) ( multicell cells insert-idx -- grid' )
    [ 1vector swap ] dip cut dup increment-cols surround ; inline
: (insert-cell-col) ( multicell cells insert-idx -- grid' )
    [ 1vector swap ] dip cut dup increment-rows surround ; inline

: excise-row-from-grid ( grid index -- grid' excised )
  cut 1 cut swap [ dup decrement-cols 2array concat ] dip ;
: excise-col-from-grid ( grid index -- grid' excised )
  [ flip ] dip cut 1 cut swap [ dup decrement-rows 2array concat flip ] dip ;
PRIVATE>

GENERIC: insert-cells-by-row ( cells col row multi-cell -- )
GENERIC: insert-cell-row ( cells row-index multi-cell -- )
GENERIC: insert-cells-by-col ( cells col row multi-cell -- )
GENERIC: insert-cell-col ( cells col-index multi-cell -- )
GENERIC: cell-nth ( pair multicell -- cell )

GENERIC: remove-cell-row ( row-index multi-cell -- )
: (remove-cell-row) ( pair wall -- )
  [ swap [ grid>> ] [ first ] bi* excise-row-from-grid ] 2keep nip [ '[ _ remove-gadget ] each ] [ grid<< ] bi ;
M: multicellular remove-cell-row (remove-cell-row) ;

GENERIC: remove-cell-col ( col-index multi-cell -- )
: (remove-cell-col) ( pair wall -- )
  [ swap [ grid>> ] [ second ] bi* excise-col-from-grid ] 2keep nip [ '[ _ remove-gadget ] each ] [ grid<< ] bi ;
M: multicellular remove-cell-col (remove-cell-col) ;

M: multicellular insert-cells-by-row [ grid>> -roll '[ _ insert-rows ] insert-on-index-else-append ] keep grid<< ;
M: multicellular insert-cell-row [ grid>> -rot (insert-cell-row) ] keep grid<< ;
M: multicellular insert-cells-by-col [ grid>> flip -roll '[ _ insert-cols ] insert-on-index-else-append flip ] keep grid<< ;
M: multicellular insert-cell-col [ grid>> flip -rot (insert-cell-col) flip ] keep grid<< ;
M: multicellular cell-nth grid>> matrix-nth gadget-child ;

: transpose-cells ( cell -- )
  find-wall [ grid>> [ dup pair>> <reversed> >>pair drop ] each-cell ] [ dup grid>> flip >>grid relayout ] bi ;

: 1matrix ( el -- matrix ) 1vector 1vector ;

: <cell-wall> ( children pair -- gadget )
  swap wall new-grid dim-color <solid> >>boundary swap >>pair ;
