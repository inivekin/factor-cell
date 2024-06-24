USING: ui.gadgets.cells.walls ui.gadgets.editors ui.gadgets.frames ui.gadgets.panes ;
IN: ui.gadgets.cells

TUPLE: cell < frame pair ;
M: cell focusable-child* gadget-child first ;

! something that can be in a cell
MIXIN: cellular
INSTANCE: editor cellular

GENERIC: (insert-cell-above) ( cell -- cell' )
GENERIC: focus-cell-above ( cell -- )
GENERIC: (insert-cell-below) ( cell -- cell' )
GENERIC: focus-cell-below ( cell -- )

GENERIC: (insert-cell-before) ( cell -- cell' )
GENERIC: focus-cell-before ( cell -- )
GENERIC: (insert-cell-after) ( cell -- cell' )
GENERIC: focus-cell-after ( cell -- )

: <bordered-cell> ( border pair -- gadget )
  1 2 cell new-frame swap >>pair
  <editor> { 0 0 } grid-add
  <pane> { 0 1 } grid-add
  swap <filled-border>
  ;

: <default-cell> ( pair -- gadget ) { 1 1 } swap <bordered-cell> ;
<PRIVATE
: row-above* ( pair -- col row' ) first2 1 - ;
: row-below* ( pair -- col row' ) first2 1 + ;
: col-before* ( pair -- col' row ) first2 [ 1 - ] dip ;
: col-after* ( pair -- col' row ) first2 [ 1 + ] dip ;
: row-above ( pair -- pair' ) row-above* 2array ;
: row-below ( pair -- pair' ) row-below* 2array ;
: col-before ( pair -- pair' ) col-before* 2array ;
: col-after ( pair -- pair' ) col-after* 2array ;
: pair* ( pair -- col row ) first2 ;
PRIVATE>

: find-wall ( gadget -- wall ) [ wall? ] find-parent ;
: focus-relative-cell ( cell quot: ( col row -- col row ) -- )
    '[ pair>> @ ] [ find-wall ] bi cell-nth request-focus ; inline
: new-default-row ( row col -- cell )
  2array <default-cell> ;

: new-default-col ( col row -- cell )
  swap new-default-row ;

M: cellular (insert-cell-above) parent>>
  [ pair>> ] [ find-wall ] bi
  [ [ new-default-row ] create-cells-for-row-insert ]
  [ [ pair* ] dip insert-cells-by-row ]
  [ cell-nth ] 2tri
  ;
: insert-cell-above ( cellular -- ) (insert-cell-above) drop ;

M: cellular (insert-cell-below) parent>>
  [ pair>> ] [ find-wall ] bi
  [ [ row-below ] dip [ new-default-row ] create-cells-for-row-insert ]
  [ [ row-below* ] dip insert-cells-by-row ]
  [ cell-nth ] 2tri
  ;
: insert-cell-below ( cellular -- ) (insert-cell-below) drop ;

M: cellular (insert-cell-before) parent>>
  [ pair>> ] [ find-wall ] bi
  [ [ <reversed> ] dip [ new-default-col ] create-cells-for-col-insert ]
  [ [ pair* swap ] dip insert-cells-by-col ]
  [ cell-nth ] 2tri
  ;
: insert-cell-before ( cellular -- ) (insert-cell-before) drop ;

M: cellular (insert-cell-after) parent>>
  [ pair>> ] [ find-wall ] bi
  [ [ col-after <reversed> ] dip [ new-default-col ] create-cells-for-col-insert ]
  [ [ col-after* swap ] dip insert-cells-by-col ]
  [ cell-nth ] 2tri
  ;
: insert-cell-after ( cellular -- ) (insert-cell-after) drop ;

M: cellular focus-cell-above parent>> [ row-above ] focus-relative-cell ;
M: cellular focus-cell-below parent>> [ row-below ] focus-relative-cell ;
M: cellular focus-cell-before parent>> [ col-before ] focus-relative-cell ;
M: cellular focus-cell-after parent>> [ col-after ] focus-relative-cell ;

: <cells> ( n -- gadget )
  <iota> dup [ 2array <default-cell> ] cartesian-map { 0 0 } <cell-wall> ;

editor "cell" f {
  { T{ key-down f { C+ } "O" } insert-cell-above }
  { T{ key-down f { C+ } "o" } insert-cell-below }
  { T{ key-down f { C+ } "i" } insert-cell-before }
  { T{ key-down f { C+ } "a" } insert-cell-after }
} define-command-map
