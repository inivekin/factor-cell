USING: arrays classes kernel math sequences ui.gadgets ;
IN: ui.gadgets.cells.cellular

! something that can be in a cell
MIXIN: cellular

GENERIC: (insert-cell-above) ( cell -- cell' )
: insert-cell-above ( cell -- ) (insert-cell-above) request-focus ;
GENERIC: (insert-cell-below) ( cell -- cell' )
: insert-cell-below ( cell -- ) (insert-cell-below) request-focus ;
GENERIC: (insert-cell-before) ( cell -- cell' )
: insert-cell-before ( cell -- ) (insert-cell-before) request-focus ;
GENERIC: (insert-cell-after) ( cell -- cell' )
: insert-cell-after ( cell -- ) (insert-cell-after) request-focus ;


GENERIC: (remove-cell-shift-col-up) ( cell -- cell' )
: remove-cell-upward ( cell -- ) (remove-cell-shift-col-up) drop ;
GENERIC: (remove-cell-shift-row-left) ( cell -- cell' )
: remove-cell-leftward ( cell -- ) (remove-cell-shift-row-left) drop ;

GENERIC: remove-row ( cell -- )
GENERIC: remove-col ( cell -- )

GENERIC: focus-cell-above ( cell -- )
GENERIC: focus-cell-below ( cell -- )
GENERIC: focus-cell-before ( cell -- )
GENERIC: focus-cell-after ( cell -- )

GENERIC: insert-row-above ( cell -- )
GENERIC: insert-row-below ( cell -- )
GENERIC: insert-col-before ( cell -- )
GENERIC: insert-col-after ( cell -- )

GENERIC: embed-cell ( cell -- )
GENERIC: imprison-cell ( cell -- )

GENERIC: absorb ( cell -- cell' )
GENERIC: excrete ( cell -- )

GENERIC: increase-cell-size ( cell -- )
GENERIC: decrease-cell-size ( cell -- )

: col-before* ( pair -- col row' ) first2 1 - ;
: col-after* ( pair -- col row' ) first2 1 + ;
: row-above* ( pair -- col' row ) first2 [ 1 - ] dip ;
: row-below* ( pair -- col' row ) first2 [ 1 + ] dip ;
: row-above ( pair -- pair' ) row-above* 2array ;
: row-below ( pair -- pair' ) row-below* 2array ;
: col-before ( pair -- pair' ) col-before* 2array ;
: col-after ( pair -- pair' ) col-after* 2array ;
: pair* ( pair -- col row ) first2 ;

: non-empty-matrix? ( x -- ? )
  { [ matrix? ] [ empty? not ] [ first empty? not ] } 1&&
  ;

: matrix-dim ( matrix -- x y ) [ length ] [ first length ] bi ;

: matrix>tuple ( matrix -- obj )
  first2 [ first absorb ] bi@ 1 swap col swap slots>tuple
  ;
: tuple-as-matrix? ( matrix -- ? )
  {
    [ matrix-dim * 2 = ] ! must be 1x2 or 2x1 matrix
    [ first first absorb class? ]
    ! [ B second wall? ]
  } 1&&
  ;
