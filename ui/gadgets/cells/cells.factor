USING: accessors arrays combinators.short-circuit kernel math math.order sequences ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.cells.cellular
ui.gadgets.cells.membranes ui.gadgets.cells.mitochondria ui.gadgets.cells.walls
ui.gadgets.editors ui.gadgets.frames ui.gadgets.grids
ui.gadgets.panes ui.gestures ;
IN: ui.gadgets.cells

TUPLE: cell < frame pair ;
M: cell focusable-child* gadget-child ;

: <bordered-cell> ( border pair -- gadget )
  1 2 cell new-frame swap >>pair
  <mitochondrion> { 0 0 } grid-add
  <membrane> { 0 1 } grid-add
  swap <filled-border>
  ;

: <default-cell> ( pair -- gadget ) { 1 1 } swap <bordered-cell> ;
<PRIVATE
: col-before* ( pair -- col row' ) first2 1 - ;
: col-after* ( pair -- col row' ) first2 1 + ;
: row-above* ( pair -- col' row ) first2 [ 1 - ] dip ;
: row-below* ( pair -- col' row ) first2 [ 1 + ] dip ;
: row-above ( pair -- pair' ) row-above* 2array ;
: row-below ( pair -- pair' ) row-below* 2array ;
: col-before ( pair -- pair' ) col-before* 2array ;
: col-after ( pair -- pair' ) col-after* 2array ;
: pair* ( pair -- col row ) first2 ;
PRIVATE>

: (row-limits) ( pair wall -- index max ) [ first ] [ grid>> length ] bi* ;
: (col-limits) ( pair wall -- index max ) [ second ] [ grid>> first length ] bi* ;

: clamp-pair-to-wall ( pair wall -- pair' )
  [ (row-limits) 1 - 0 swap clamp ] [ (col-limits) 1 - 0 swap clamp ] 2bi 2array ;

: top-most-wall? ( wall -- ? ) find-wall pair>> f = ;

DEFER: focus-outside-wall-limits?
: get-cell-outside-wall ( wall direction: ( pair -- pair' ) -- focusable/f )
  '[ pair>> @ ]
  [ parent>> find-wall ] bi
  [ focus-outside-wall-limits? ]
  [ '[ _ _ cell-nth ] unless* ] 2bi ; inline

: (focus-outside-wall-limits?) ( pair wall quot: ( pair -- pair' ) -- focusable/f )
  [ dup top-most-wall? not ] [ '[ nip _ get-cell-outside-wall ] ] bi*
  [ [ clamp-pair-to-wall ] keep cell-nth ] if
  ; inline

: focus-outside-wall-limits? ( pair wall -- focusable/f )
  {
    { [ 2dup (row-limits) >= ] [ [ row-below ] (focus-outside-wall-limits?) ] }
    { [ over first 0 < ] [ [ row-above ] (focus-outside-wall-limits?) ] }
    { [ 2dup (col-limits) >= ] [ [ col-after ] (focus-outside-wall-limits?) ] }
    { [ over second 0 < ] [ [ col-before ] (focus-outside-wall-limits?) ] }
    [ 2drop f ]
  } cond
  ;

: (get-relative-cell) ( pair wall -- focusable/f )
  [ focus-outside-wall-limits? ] [ '[ _ _ cell-nth gadget-child ] unless* ] 2bi
  ;

: focus-relative-cell ( cell quot: ( pair -- pair' ) -- )
  '[ pair>> @ ] [ find-wall ] bi (get-relative-cell) [ request-focus ] when* ; inline

: new-default-row ( row col -- cell )
  2array <default-cell> ;

: new-default-col ( col row -- cell )
  swap new-default-row ;

M: cellular (insert-cell-before) parent>>
  [ pair>> ] [ find-wall ] bi
  [ [ new-default-row ] create-cells-for-row-insert ]
  [ [ pair* ] dip insert-cells-by-row ]
  [ [ col-before ] dip cell-nth ] 2tri
  ;

M: cellular (insert-cell-after) parent>>
  [ pair>> col-after ] [ find-wall ] bi
  [ [ new-default-row ] create-cells-for-row-insert ]
  [ [ pair* ] dip insert-cells-by-row ]
  [ cell-nth ] 2tri
  ;

M: cellular (insert-cell-above) parent>>
  [ pair>> ] [ find-wall ] bi
  [ [ <reversed> ] dip [ new-default-col ] create-cells-for-col-insert ]
  [ [ pair* swap ] dip insert-cells-by-col ]
  [ [ row-above ] dip cell-nth ] 2tri
  ;

M: cellular (insert-cell-below) parent>>
  [ pair>> row-below ] [ find-wall ] bi
  [ [ <reversed> ] dip [ new-default-col ] create-cells-for-col-insert ]
  [ [ pair* swap ] dip insert-cells-by-col ]
  [ cell-nth ] 2tri
  ;

! M: cellular (remove-cell-above) parent>>
!   [ pair>> ] [ find-wall ] bi
!   [ [ pair* swap ] dip excise-cell-in-col ]
!   [ [ row-above ] dip cell-nth ] 2tri
!   ;

: (insert-cell-row) ( pair wall -- )
  [ [ new-default-row ] create-cell-row ] [ insert-cell-row ] 2bi ;
: (insert-cell-col) ( pair wall -- )
  [ [ new-default-col ] create-cell-col ] [ insert-cell-col ] 2bi ;
M: cellular insert-row-above ( cellular -- ) parent>>
  [ pair>> first ] [ find-wall ] bi (insert-cell-row) ;
M: cellular insert-row-below ( cellular -- ) parent>>
  [ pair>> row-below first ] [ find-wall ] bi (insert-cell-row) ;
M: cellular insert-col-before ( cellular -- ) parent>>
  [ pair>> second ] [ find-wall ] bi (insert-cell-col) ;
M: cellular insert-col-after ( cellular -- ) parent>>
  [ pair>> col-after second ] [ find-wall ] bi (insert-cell-col) ;

M: cellular remove-row ( cellular -- ) parent>>
  [ [ row-above ] focus-relative-cell ] 
  [ [ pair>> ] [ find-wall ] bi remove-cell-row ]
  [ relayout ]
  tri ;
M: cellular remove-col ( cellular -- ) parent>>
  [ [ col-before ] focus-relative-cell ] 
  [ [ pair>> ] [ find-wall ] bi remove-cell-col ]
  [ relayout ]
  tri ;

M: cellular focus-cell-above parent>> [ row-above ] focus-relative-cell ;
M: cellular focus-cell-below parent>> [ row-below ] focus-relative-cell ;
M: cellular focus-cell-before parent>> [ col-before ] focus-relative-cell ;
M: cellular focus-cell-after parent>> [ col-after ] focus-relative-cell ;

M: cellular increase-cell-size ( cellular -- )
  [ dup font>> dup size>> 1 + >>size clone swap font<< ]
  [ relayout ]
  bi ;
M: cellular decrease-cell-size ( cellular -- )
  [ dup font>> dup size>> 1 - >>size clone swap font<< ]
  [ relayout ]
  bi ;

: embed-in-wall ( cell -- wall )
  [ parent>> 1matrix ] [ pair>> ] [ { 0 0 } >>pair drop ] tri <cell-wall> ;
M: cellular embed-cell-in-wall [ parent>>
  [ pair>> ] [ find-wall ] [ [ over <reversed> grid-remove ] dip embed-in-wall ] tri
  rot <reversed> grid-add drop ] keep request-focus ;

: <cells> ( n -- gadget )
  <iota> dup [ 2array <default-cell> ] cartesian-map f <cell-wall> ;

: <amoeba> ( -- gadget )
  1 <cells> 1matrix f <cell-wall> ;

