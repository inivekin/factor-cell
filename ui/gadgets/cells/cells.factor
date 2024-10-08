USING: accessors arrays assocs classes classes.tuple combinators
combinators.short-circuit continuations documents.elements
kernel listener math math.matrices math.order math.parser
namespaces sequences ui ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.cells.alive
ui.gadgets.cells.cellular ui.gadgets.cells.dead
ui.gadgets.cells.genomes ui.gadgets.cells.interlinks
ui.gadgets.cells.membranes ui.gadgets.cells.metabolics
ui.gadgets.cells.prisons ui.gadgets.cells.walls ui.gadgets.glass
ui.gadgets.grids ui.gadgets.scrollers ui.gestures ui.pens.solid
ui.theme ui.tools.button-list ui.tools.debugger
ui.tools.listener ui.tools.listener.popups ;
IN: ui.gadgets.cells

MIXIN: cell

INSTANCE: dead metabolic ! it's... alive!!!

INSTANCE: dead cell
INSTANCE: alive cell
INSTANCE: prison cell
INSTANCE: wall cell

! M: dead request-focus-on [ nip [ pair>> <reversed> ] [ find-wall ] bi [ filled-cell<< ] [ drop ] if* ]
!                          [ parent>> request-focus-on ]
!                          2bi ;

: new-default-row ( row col -- cell )
  2array <dead-cell> ;

: new-default-col ( col row -- cell )
  swap new-default-row ;

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

: focus-cell-in ( cell -- )
  dup wall? [ { 0 0 } swap cell-nth request-focus ] [ drop ] if ;
: focus-cell-out ( cell -- )
  parent>> find-wall request-focus ;

: (get-relative-cell) ( pair wall -- focusable/f )
  [ focus-outside-wall-limits? ] [ '[ _ _ cell-nth ] unless* ] 2bi
  ;

: focus-relative-cell ( cell quot: ( pair -- pair' ) -- )
  '[ pair>> @ ] [ parent>> find-wall ] bi (get-relative-cell) [ request-focus ] when* ; inline


M: cell (insert-cell-before)
  [ pair>> ] [ parent>> find-wall ] bi
  [ [ new-default-row ] create-cells-for-row-insert ]
  [ [ pair* ] dip insert-cells-by-row ]
  [ [ col-before ] dip cell-nth ] 2tri
  ;

M: cell (insert-cell-after)
  [ pair>> col-after ] [ parent>> find-wall ] bi
  [ [ new-default-row ] create-cells-for-row-insert ]
  [ [ pair* ] dip insert-cells-by-row ]
  [ cell-nth ] 2tri
  ;

M: cell (insert-cell-above)
  [ pair>> ] [ parent>> find-wall ] bi
  [ [ <reversed> ] dip [ new-default-col ] create-cells-for-col-insert ]
  [ [ pair* swap ] dip insert-cells-by-col ]
  [ [ row-above ] dip cell-nth ] 2tri
  ;

M: cell (insert-cell-below)
  [ pair>> row-below ] [ parent>> find-wall ] bi
  [ [ <reversed> ] dip [ new-default-col ] create-cells-for-col-insert ]
  [ [ pair* swap ] dip insert-cells-by-col ]
  [ cell-nth ] 2tri
  ;

M: cell (remove-cell-shift-col-up)
  [ pair>> ] [ parent>> find-wall ] bi
  [ [ <default-cell> ] cell-shifter-upward ]
  [ [ grid>> excise-cell-from-col swap ] keep [ grid<< ] [ dupd [ remove-gadget ] [ [ 1array ] dip remove-cell-wall-connections ] 2bi ] bi ]
  [ cell-nth [ request-focus ] [ relayout ] bi ] 2tri
  ;
M: cell (remove-cell-shift-row-left)
  [ pair>> ] [ parent>> find-wall ] bi
  [ [ <default-cell> ] cell-shifter-leftward ]
  [ [ grid>> excise-cell-from-row swap ] keep [ grid<< ] [ dupd [ remove-gadget ] [ [ 1array ] dip remove-cell-wall-connections ] 2bi ] bi  ]
  [ cell-nth [ request-focus ] [ relayout ] bi ] 2tri
  ;

: (insert-cell-row) ( pair wall -- )
  [ [ new-default-row ] create-cell-row ] [ insert-cell-row ] 2bi ;
: (insert-cell-col) ( pair wall -- )
  [ [ new-default-col ] create-cell-col ] [ insert-cell-col ] 2bi ;
M: cell insert-row-above ( cell -- )
  [ pair>> first ] [ find-wall ] bi (insert-cell-row) ;
M: cell insert-row-below ( cell -- )
  [ pair>> row-below first ] [ find-wall ] bi (insert-cell-row) ;
M: cell insert-col-before ( cell -- )
  [ pair>> second ] [ find-wall ] bi (insert-cell-col) ;
M: cell insert-col-after ( cell -- )
  [ pair>> col-after second ] [ find-wall ] bi (insert-cell-col) ;

M: cell remove-row ( cell -- )
  [ [ row-above ] focus-relative-cell ] 
  [ [ pair>> ] [ find-wall ] bi remove-cell-row ]
  [ relayout ]
  tri ;
M: cell remove-col ( cell -- )
  [ [ col-before ] focus-relative-cell ] 
  [ [ pair>> ] [ find-wall ] bi remove-cell-col ]
  [ relayout ]
  tri ;

M: cell focus-cell-above [ row-above ] focus-relative-cell ;
M: cell focus-cell-below [ row-below ] focus-relative-cell ;
M: cell focus-cell-before [ col-before ] focus-relative-cell ;
M: cell focus-cell-after [ col-after ] focus-relative-cell ;

: embed-in-wall ( cell -- wall )
  [ 1matrix ] [ pair>> ] [ { 0 0 } >>pair drop ] tri <cell-wall> ;
M: cell embed-cell [
  [ pair>> ] [ parent>> find-wall ] [ [ over <reversed> grid-remove ] dip embed-in-wall ] tri
  rot <reversed> grid-add drop ] keep request-focus ;
M: cell imprison-cell [
  [ pair>> ] [ parent>> find-wall ] [ [ over <reversed> grid-remove ] dip imprison ] tri
  rot <reversed> grid-add drop ] keep request-focus ;

: <cells> ( n -- gadget )
  <iota> dup [ 2array <dead-cell> ] cartesian-map { 0 0 } <cell-wall> ;

: show-splinter-popup ( interactor element popup -- )
    [ [ drop ] [ relevant-rect ] 2bi ] dip swap show-popup ;

:: <genome-debugger> ( error continuation interactor -- popup )
    error
    continuation
    error compute-restarts
    error interactor make-restart-hook-quot
    <debugger> frame-debugger ;

: genome-debugger-popup ( interactor error continuation -- )
  pick <genome-debugger> one-line-elt swap show-splinter-popup ;

: <amoeba> ( -- gadget )
  [ [ absorbing-cell get cell-genome ] 2dip genome-debugger-popup ] error-hook set 
  1 <cells> f >>pair ;

: open-cell-in-window ( cell -- )
  [ tuple>unfiltered-assoc dup [ [ f "parent" ] dip set-at ] [ [ { 0 0 } "pair" ] dip set-at ] bi 1 swap col [ clone ] map ] [ class-of ] bi slots>tuple 1matrix { 0 0 } <cell-wall>
  [ content-background <solid> >>interior ] [ pair>> first2 [ number>string ] bi@ ":" glue ] bi open-window ;

{ dead prison alive wall } [ "movement" f {
  { T{ key-down f { C+ } "k" } focus-cell-above }
  { T{ key-down f { C+ } "l" } focus-cell-after }
  { T{ key-down f { C+ } "h" } focus-cell-before }
  { T{ key-down f { C+ } "j" } focus-cell-below }
  { T{ key-down f { A+ } "t" } show-active-buttons-popup }
  { T{ key-down f { C+ } "W" } open-cell-in-window }
  { T{ key-down f f "ESC" } focus-cell-out }
  { T{ key-down f f "RET" } focus-cell-in }
} define-command-map ] each

dead "reviving" f {
  { T{ key-down f { C+ } "`" } toggle-editor }
  { T{ key-down f { C+ } "!" } revive-cell }
} define-command-map
alive "killing" f {
  { T{ key-down f { C+ } "!" } kill-cell }
  { T{ key-down f { C+ } "TAB" } expand-cell }
} define-command-map

{ dead prison alive wall } [ "mutation" f {
  { T{ key-down f { C+ } "|" } remove-col }
  { T{ key-down f { C+ } "-" } remove-row }

  { T{ key-down f { C+ } "$" } remove-cell-upward }
  { T{ key-down f { C+ } "~" } remove-cell-leftward }

  { T{ key-down f { C+ } "+" } insert-row-above }
  { T{ key-down f { C+ } "_" } insert-row-below }
  { T{ key-down f { C+ } "[" } insert-col-before }
  { T{ key-down f { C+ } "]" } insert-col-after }

  { T{ key-down f { C+ } "O" } insert-cell-above }
  { T{ key-down f { C+ } "o" } insert-cell-below }
  { T{ key-down f { C+ } "i" } insert-cell-before }
  { T{ key-down f { C+ } "a" } insert-cell-after }

  { T{ key-down f { C+ } "@" } embed-cell }
  { T{ key-down f { C+ } "%" } transpose-cells }
  { T{ key-down f { C+ } "#" } toggle-prison }

  ! { T{ key-down f { C+ } "K" } clone-cell-upward }
  ! { T{ key-down f { C+ } "L" } clone-cell-rightward }
  ! { T{ key-down f { C+ } "H" } clone-cell-leftward }
  ! { T{ key-down f { C+ } "J" } clone-cell-downward }
} define-command-map ] each

dead "spasm" f {
  { T{ key-down f { C+ } ">" } metabolize-rightward }
  { T{ key-down f { C+ } "<" } metabolize-leftward }
  { T{ key-down f { C+ } "V" } metabolize-downward }
  { T{ key-down f { C+ } "^" } metabolize-upward }
} define-command-map

: dye-cell ( cell -- )
  selection-color <solid> >>boundary relayout-1 ;
: undye-cell ( cell -- )
  content-background <solid> >>boundary relayout-1 ;

: tint-cell ( cell -- )
  line-color <solid> >>interior relayout-1 ;
: untint-cell ( cell -- )
  content-background <solid> >>interior relayout-1 ;
{ alive wall } [ "highlighting" f {
  { gain-focus dye-cell }
  { lose-focus undye-cell }
  { mouse-enter tint-cell }
  { mouse-leave untint-cell }
} define-command-map ] each

{ alive } [ "selection" f {
  { T{ button-down f f 1 } request-focus }
} define-command-map ] each


MAIN-WINDOW: factor-cell { { title "cells" } } <amoeba> <scroller> content-background <solid> >>interior >>gadgets ;
