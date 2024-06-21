! Copyright (C) 2024 Your name.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators continuations
eval io io.encodings.utf8 io.files io.streams.string kernel
listener make math math.matrices namespaces prettyprint
prettyprint.backend sequences sequences.zipped stack-checker
ui.gadgets ui.gadgets.editors ui.gadgets.frames ui.gadgets.grids
ui.gadgets.panes ui.gadgets.tree-cells ui.gestures ui.pens.solid
ui.theme vectors ;
FROM: sequences => like ;
IN: ui.gadgets.scaling-editors

TUPLE: sheet-editor < editor ;
TUPLE: scaling-editor < frame element-id { cache initial: f } ;

: matrix-dim ( matrix -- x y )
    [ length ] [ first length ] bi
    ;

: new-scaling-editor ( -- scaling-editor )
    1 2 scaling-editor new-frame 
    sheet-editor new-editor 1 >>min-cols 1 >>max-cols line-color <solid> >>boundary
    { 0 0 } grid-add
    <pane> { 0 1 } grid-add
    ;

: <scaling-editor> ( -- scaling-editor )
    new-scaling-editor ;

: default-test-scaling-editor ( id -- editor )
     <scaling-editor> swap >>element-id dup children>> first "" swap set-editor-string ;

: increment-by-vertical-scroll ( n -- n' )
    scroll-direction get-global second + ;

: scale-font-and-col-width ( sheet-editor -- )
    [ font>> dup size>> increment-by-vertical-scroll swap size<< ]
    [ dup [ min-cols>> ] [ max-cols>> ] bi [ increment-by-vertical-scroll ] bi@ [ over min-cols<< ] [ over max-cols<< ] bi* drop ]
    [ relayout ]
    tri ;

: scale-font-and-col-width-up ( sheet-editor -- )
    [ font>> dup size>> 1 + swap size<< ]
    [ dup [ min-cols>> ] [ max-cols>> ] bi [ 1 + ] bi@ [ over min-cols<< ] [ over max-cols<< ] bi* drop ]
    [ relayout ]
    tri ;
: scale-font-and-col-width-down ( sheet-editor -- )
    [ font>> dup size>> 1 - swap size<< ]
    [ dup [ min-cols>> ] [ max-cols>> ] bi [ 1 - ] bi@ [ over min-cols<< ] [ over max-cols<< ] bi* drop ]
    [ relayout ]
    tri ;

: begin-drag ( sheet-editor -- )
    [ loc>> ]
    [ parent>> ] swap bi >>saved drop ;

: do-drag ( sheet-editor -- )
    ! from saved loc, select all cells to current loc
    ! parent>> saved>>
    drop
    ;

: sneaky-grid-add ( parent editor -- )
    add-gadget drop
    ;

: transpose-parent-cell ( sheet-editor -- )
    parent>> parent>> dup grid>> flip dup [ [ dup element-id>> first2 swap 2array >>element-id drop ] each ] each >>grid relayout
    ;

: increment-rows ( scaling-editors -- )
    [ [ dup element-id>> first2 [ 1 + ] dip 2array swap element-id<< ] each ] each ;

: increment-cols ( scaling-editors -- )
    [ [ dup element-id>> first2 1 + 2array swap element-id<< ] each ] each ;

: scaling-editors-inserted-above ( scaling-editor -- grid )
    dup element-id>> first
    '[ parent>>
      [ grid>> first length <iota> [ _ swap 2array <scaling-editor> swap >>element-id ] map
        V{ } like 1vector dup
      ] keep '[ [ _ swap sneaky-grid-add ] each ] each ]
    [ element-id>> first ]
    [ parent>> grid>> ] tri
    swap
    cut
    dup increment-rows
    surround
    V{ } like ;

: scaling-editors-inserted-below ( scaling-editor -- grid )
    dup element-id>> first
    '[ parent>>
      [ grid>> first length <iota> [ _ 1 + swap 2array <scaling-editor> swap >>element-id ] map
        V{ } like 1vector dup
      ] keep '[ [ _ swap sneaky-grid-add ] each ] each ]
    [ element-id>> first 1 + ]
    [ parent>> grid>> ] tri
    swap
    cut
    dup increment-rows
    surround
    V{ } like ;

: scaling-editors-inserted-before ( scaling-editor -- grid )
    dup element-id>> second
    '[ parent>>
      [ grid>> flip first length <iota> [ _ 2array <scaling-editor> swap >>element-id ] map
        V{ } like 1vector dup
      ] keep '[ [ _ swap sneaky-grid-add ] each ] each ]
    [ element-id>> second ]
    [ parent>> grid>> flip ] tri
    swap
    cut
    dup increment-cols
    surround
    V{ } like flip ;

: scaling-editors-inserted-after ( scaling-editor -- grid )
    dup element-id>> second
    '[ parent>>
      [ grid>> flip first length <iota> [ _ 1 + 2array <scaling-editor> swap >>element-id ] map
        V{ } like 1vector dup
      ] keep  '[ [ _ swap sneaky-grid-add ] each ] each ]
    [ element-id>> second 1 + ]
    [ parent>> grid>> flip ] tri
    swap
    cut
    dup increment-cols
    surround
    V{ } like flip ;

! get the number of columns for a specific row num gen or the number of rows for a specific col num gen
:: create-elements-for-insert-and-append ( col-max row-max col row -- seq )
    ! if same column, insert above, otherwise append
    col-max <iota> [ dup col = [ row ] [ row-max ] if swap 2array <scaling-editor> swap >>element-id ] map
    ;

: insert-cell ( cell row row-id -- row )
    [ 1vector ] 2dip cut dup 1vector increment-rows surround ;

: append-cell ( cell row -- row )
    swap suffix ;

: for-each-column-insert-or-append-cell ( cells grid row col -- grid' )
    [ <zipped> <enumerated> ] 2dip
    swap '[ [ first _ = ] ! the enumeration
       [ second first2 rot [ _ insert-cell ] [ append-cell ] if ] ! the grid and row
       bi
    ] map
    ;

: squash-cell ( sheet-editor -- )
    dup visible?>> not [ >>visible? ] keep
    [ parent>> children>> second f >>visible? clear-gadget ]
    [ parent>> children>> second t >>visible? [ "..." print ] with-pane ]
    if
    ;

:: squish-cells ( tcell -- )
    tcell parent>> element-id>> dup :> loc default-test-scaling-editor :> replacement
    tcell parent>> :> supercell
    supercell parent>>  replacement loc <reversed> grid-add drop
    replacement children>> first tcell parent>> grid>> matrix-dim [ # CHAR: x , # ] "" make swap set-editor-string
    replacement tcell parent>> >>cache children>> first request-focus
    ;

:: unsquish-cells ( tcell replacement -- )
    tcell parent>> :> supercell
    ! tcell standin element-id>> dup :> loc >>element-id drop
    tcell element-id>> :> loc 
    supercell replacement loc <reversed> grid-add drop
    replacement grid>> { 0 0 } swap matrix-nth children>> first request-focus
    ;

: squash-parent-cell ( sheet-editor -- )
    parent>> dup cache>> [ unsquish-cells ] [ squish-cells ] if*
    ;

: scaling-editor-inserted-above ( scaling-editor -- grid )
    dup element-id>> first2
    '[ parent>>
      [ grid>>  [ first length ] [ length ] bi _ _ swap create-elements-for-insert-and-append
        V{ } like 1vector dup
      ] keep '[ [ _ swap sneaky-grid-add ] each ] each first ]
    [ parent>> grid>> flip ]
    [ element-id>> first2 ]
    tri
    for-each-column-insert-or-append-cell
    V{ } like flip ;

: scaling-editor-inserted-below ( scaling-editor -- grid )
    dup element-id>> first2 [ 1 + ] dip
    '[ parent>>
      [ grid>>  [ first length ] [ length ] bi _ _ swap create-elements-for-insert-and-append
        V{ } like 1vector dup
      ] keep '[ [ _ swap sneaky-grid-add ] each ] each first ]
    [ parent>> grid>> flip ]
    [ element-id>> first2 [ 1 + ] dip ]
    tri
    for-each-column-insert-or-append-cell
    V{ } like flip ;

: insert-cell-col ( cell row row-id -- row )
    [ 1vector ] 2dip cut dup 1vector increment-cols surround ;

: for-each-row-insert-or-append-cell ( cells grid row col -- grid' )
    [ <zipped> <enumerated> ] 2dip
    '[ [ first _ = ] ! the enumeration
       [ second first2 rot [ _ insert-cell-col ] [ append-cell ] if ] ! the grid and row
       bi
    ] map
    ;

:: create-elements-for-insert-and-append-col ( col-max row-max col row -- seq )
    ! if same column, insert above, otherwise append
    col-max <iota> [ dup col = [ row ] [ row-max ] if 2array <scaling-editor> swap >>element-id ] map
    ;

: scaling-editor-inserted-before ( scaling-editor -- grid )
    dup element-id>> first2
    '[ parent>>
      [ grid>>  [ first length ] [ length ] swap bi _ _ create-elements-for-insert-and-append-col
        V{ } like 1vector dup
      ] keep '[ [ _ swap sneaky-grid-add ] each ] each first ]
    [ parent>> grid>> ]
    [ element-id>> first2 ] ! number might have changed since the prior call to this
    tri
    for-each-row-insert-or-append-cell
    V{ } like ;

: scaling-editor-inserted-after ( scaling-editor -- grid )
    dup element-id>> first2 1 +
    '[ parent>>
      [ grid>>  [ first length ] [ length ] swap bi _ _ create-elements-for-insert-and-append-col
        V{ } like 1vector dup
      ] keep '[ [ _ swap sneaky-grid-add ] each ] each first ]
    [ parent>> grid>> ]
    [ element-id>> first2 1 + ]
    tri
    for-each-row-insert-or-append-cell
    V{ } like ;

: insert-then-focus ( scaling-editor pair-to-focus inserter-quot -- focussed )
    [ '[ parent>> grid>> _ swap matrix-nth dup children>> first request-focus ] ]
    [ '[ _ keep parent>> swap >>grid relayout ] ]
    bi*
    swap
    bi
    ; inline

: (insert-cell-above) ( scaling-editor -- scaling-editor )
    parent>> dup element-id>>
    [ scaling-editor-inserted-above ]
    insert-then-focus
    ;
: insert-cell-above ( scaling-editor -- ) (insert-cell-above) drop ;

: (insert-cell-below) ( scaling-editor -- scaling-editor )
    parent>> dup element-id>> [ first 1 + ] [ second ] bi 2array
    [ scaling-editor-inserted-below ]
    insert-then-focus
    ;
: insert-cell-below ( scaling-editor -- ) (insert-cell-below) drop ;

: (insert-cell-before) ( scaling-editor -- scaling-editor )
    parent>> dup element-id>>
    [ scaling-editor-inserted-before ]
    insert-then-focus
    ;
: insert-cell-before ( scaling-editor -- ) (insert-cell-before) drop ;

: (insert-cell-after) ( scaling-editor -- scaling-editor )
    parent>> dup element-id>> [ first ] [ second 1 + ] bi 2array
    [ scaling-editor-inserted-after ]
    insert-then-focus
    ;
: insert-cell-after ( scaling-editor -- ) (insert-cell-after) drop ;

: insert-row-above ( scaling-editor -- )
    parent>> [ scaling-editors-inserted-above ] keep
    parent>> [ grid<< ] keep relayout
    ;

: insert-row-below ( scaling-editor -- )
    parent>> [ scaling-editors-inserted-below ] keep
    parent>> [ grid<< ] keep relayout
    ;
: insert-col-before ( scaling-editor -- )
    parent>> [ scaling-editors-inserted-before ] keep
    parent>> [ grid<< ] keep relayout
    ;
: insert-col-after ( scaling-editor -- )
    parent>> [ scaling-editors-inserted-after ] keep
    parent>> [ grid<< ] keep relayout
    ;

: embed-editor-to-treecell ( scaling-editor -- treecell )
    [ 1vector 1vector <treecell> ] [ element-id>> ] bi >>element-id ;

! adding levels to this?
: reset-editor-position ( scaling-editor -- )
    { 0 0 } >>element-id drop ;

: mutate-editor-as-treecell-of-editor ( subtreecell id treecell-grid -- )
    grid>> matrix-set-nth ;

: matrix-isolate ( matrix idx -- before after selected )
    cut [ rest ] [ first ] bi ;

: nondestructive-matrix-replace ( insertion matrix pair -- matrix' )
    rot
    [
      [ first matrix-isolate ] ! matrix split by row
      [ second matrix-isolate ] ! splitting columns of split rows
      bi
      drop ! what is being replaced
    ] dip
    1vector glue
    1vector glue
    ;

: embed-to-grid ( scaling-editor -- grid )
    [ parent>> ] ! supercell
    [ embed-editor-to-treecell ] ! subcell
    [ reset-editor-position ]
    tri
    [ add-gadget ] keep
    swap
    grid>>
    over element-id>>
    nondestructive-matrix-replace
    ;

: insert-cell-within ( scaling-editor -- )
    parent>> dup element-id>> swap
    [ parent>> ]
    [ embed-to-grid ] bi
    >>grid
    [ relayout ]
    [ grid>> matrix-nth grid>> { 0 0 } swap matrix-nth children>> first request-focus ] bi
    ;

: set-cell ( cell obj -- )
    [ pprint ] with-string-writer swap children>> first set-editor-string
    ;

: log-obj-to-file ( obj -- obj )
    dup P" ~/evaluation.txt" utf8 [ pprint ] with-file-writer
    ;

:: replace-treecell ( cell -- cell' )
    { 0 0 } default-test-scaling-editor 1vector 1vector <treecell> :> replacement
    cell element-id>> replacement element-id<<
    ! grid-add expects { col row } ... element-ids are currently { row col } ...
    cell parent>> replacement dup element-id>> first2 swap 2array grid-add drop
    replacement
    ;

: expand-cells-by-count ( row col cell -- )
    [ '[ 1 - [ _ children>> first insert-row-below ] times ] ] [ '[ 1 - [ _ children>> first insert-col-after ] times ] ] bi bi* 
    ;

DEFER: marshall-type-out
:: expand-matrix-to-treecell ( cell matrix -- )
    cell dup treecell?
        [ replace-treecell children>> first ]
        [ dup children>> first insert-cell-within ] if

        [ [ matrix matrix-dim ] dip expand-cells-by-count ] keep
        parent>> grid>> 
    matrix [ [ set-cell ] 2each ] 2each
    ;

:: expand-tuple-to-treecell ( cell tuple -- )
    cell dup treecell?
        [ replace-treecell children>> first ]
        [ dup children>> first insert-cell-within ] if

        [ tuple class-of set-cell ] ! put this in first cell

        [ children>> first (insert-cell-below) dup children>> first insert-cell-within tuple tuple>assoc :> matrix
                 [ [ matrix matrix-dim ] dip expand-cells-by-count ] keep
                 parent>> grid>> 
                 matrix [ [ marshall-type-out ] 2each ] 2each ] bi
                 ! matrix [ [ set-cell ] 2each ] 2each ] bi
    ;

: marshall-type-out ( cell obj -- )
    {
        { [ dup matrix? ] [ expand-matrix-to-treecell ] }
        { [ dup tuple? ] [ expand-tuple-to-treecell ] }
        [ set-cell ]
    } cond
    ;

: set-output-cells ( out-cells datastack -- )
    [ marshall-type-out ] 2each
    ;

: create-subcell-from-pane ( pane -- cell )
    dup '[ _ pprint ] [ P" ~/evaluation.txt" utf8 ] dip with-file-writer
    ;
: subcell-required? ( pane -- ? )
    children>> first children>> f = not
    ;

DEFER: marshall-cell-type-in
: (marshall-cell-type-in) ( obj -- x )
    {
        { [ dup scaling-editor? ] [ children>> first editor-string [ parse-string call( -- x ) ] with-interactive-vocabs ] }
        { [ dup treecell? ] [ grid>> marshall-cell-type-in ] }
        [ [ pprint-short ] with-string-writer " unknown cell type can't be marshalled in" append throw ]
    } cond
    ;

: marshall-cell-type-in ( cell -- x )
    [ [ (marshall-cell-type-in) ] map ] map ; recursive

: evaluate-cell ( in-seq cur-cell -- outseq )
    [
      [ [ (marshall-cell-type-in) ] map ]
      [ children>> first editor-string [ parse-string ] with-interactive-vocabs ]
      bi*
    ] keep
    children>> second [ with-datastack ] with-pane
    ! <pane> [ [ with-datastack ] with-pane ] keep
    ! dup subcell-required? [ create-subcell-from-pane ] when drop
    ;
 
: get-evaluation-requirements ( scaling-editor -- in-count out-count )
    children>> first editor-string [ parse-string ] with-interactive-vocabs infer [ in>> length ] [ out>> length ] bi
    ;

:: get-or-create-input-cells ( treecell in-count out-count position -- out-seq in-seq cur-cell )
    position second treecell grid>> col ! the column we are concerned with
    position first cut ! separate in-seq-with-prior-cells and cur-cell..
    [ in-count tail* ] dip ! drop prior cells from sequence
    1 cut ! seperate cur-cell and rest of cells
    [ first ] dip ! pull current cell out of single array
    out-count head-slice ! get reference only to cells required to write into
    -rot
    ;

:: get-or-create-input-cells-rowwise ( treecell in-count out-count position -- out-seq in-seq cur-cell )
    position first treecell grid>> flip col ! the column we are concerned with
    position second cut ! separate in-seq-with-prior-cells and cur-cell..
    [ in-count tail* ] dip ! drop prior cells from sequence
    1 cut ! seperate cur-cell and rest of cells
    [ first ] dip ! pull current cell out of single array
    out-count head-slice ! get reference only to cells required to write into
    -rot
    ;

:: prepare-out-cells-downwards ( scalingeditor out-count -- )
    scalingeditor element-id>> second
    scalingeditor parent>> grid>>
    col
    scalingeditor element-id>> first cut nip length out-count - 1 - dup 0 < [ abs [ scalingeditor children>> first insert-row-below ] times ] [ drop ] if
    ;

:: prepare-out-cells-upwards ( scalingeditor out-count -- )
    scalingeditor element-id>> second
    scalingeditor parent>> grid>>
    col
    scalingeditor element-id>> first cut drop length out-count - log-obj-to-file dup 0 < [ abs [ scalingeditor children>> first insert-row-above ] times ] [ drop ] if
    ;

:: prepare-out-cells-rightwards ( scalingeditor out-count -- )
    scalingeditor element-id>> first
    scalingeditor parent>> grid>> flip
    col
    scalingeditor element-id>> second cut nip length out-count - 1 - log-obj-to-file dup 0 < [ abs [ scalingeditor children>> first insert-col-after ] times ] [ drop ] if
    ;

:: prepare-out-cells-leftwards ( scalingeditor out-count -- )
    scalingeditor element-id>> second
    scalingeditor parent>> grid>> flip
    col
    scalingeditor element-id>> second cut drop length out-count - log-obj-to-file dup 0 < [ abs [ scalingeditor children>> first insert-col-before ] times ] [ drop ] if
    ;

: evaluate-cell-downwards ( sheet-editor -- )
    parent>> dup [ parent>> swap get-evaluation-requirements ]
    [ over prepare-out-cells-downwards ]
    [ element-id>> ] tri
    get-or-create-input-cells
    evaluate-cell
    set-output-cells
    ;

: evaluate-cell-upwards ( sheet-editor -- )
    parent>> dup [ parent>> swap get-evaluation-requirements ]
    [ over prepare-out-cells-upwards ]
    [ element-id>> ] tri
    swapd get-or-create-input-cells swapd
    evaluate-cell
    set-output-cells
    ;

: evaluate-cell-rightwards ( sheet-editor -- )
    parent>> dup [ parent>> swap get-evaluation-requirements ]
    [ over prepare-out-cells-rightwards ]
    [ element-id>> ] tri
    get-or-create-input-cells-rowwise
    evaluate-cell
    set-output-cells
    ;

: evaluate-cell-leftwards ( sheet-editor -- )
    parent>> dup [ parent>> swap get-evaluation-requirements ]
    [ over prepare-out-cells-leftwards ]
    [ element-id>> ] tri
    swapd get-or-create-input-cells-rowwise swapd 
    evaluate-cell
    set-output-cells
    ;

: (wrap-around) ( n upper-limit  -- n' )
    {
        { [ 2dup >= ] [ - ] }
        { [ over 0 < ] [ + ] }
        [ drop ]
    } cond
    ;

: wrap-around ( pair grid -- pair' )
    [ [ first ] [ length ] bi* (wrap-around) ] [ [ second ] [ first length ] bi* (wrap-around) ] 2bi
    2array
    ;

: focus-cell-shift ( sheet-editor coord-change -- )
    [ parent>> ] dip
    '[ element-id>> first2 @ 2array ]
    [ parent>> grid>> dup ]
    swap
    bi
    swap wrap-around swap matrix-nth children>> first request-focus
    ; inline

: focus-cell-rightwards ( sheet-editor -- )
    [ 1 + ] focus-cell-shift
    ;

: focus-cell-leftwards ( sheet-editor -- )
    [ 1 - ] focus-cell-shift
    ;

: focus-cell-upwards ( sheet-editor -- )
    [ [ 1 - ] dip ] focus-cell-shift
    ;

: focus-cell-downwards ( sheet-editor -- )
    [ [ 1 + ] dip ] focus-cell-shift
    ;

sheet-editor H{
!    { mouse-scroll [ scale-font-and-col-width ] }
    { T{ key-down f { C+ } "DOWN" } [ scale-font-and-col-width-down ] }
    { T{ key-down f { C+ } "UP" } [ scale-font-and-col-width-up ] }
!     { T{ button-down } [ begin-drag ] }
!     { T{ button-up } [ drop ] }
!     { T{ drag } [ do-drag ] }

    { T{ key-down f { C+ } "O" } [ insert-cell-above ] }
    { T{ key-down f { C+ } "o" } [ insert-cell-below ] }
    { T{ key-down f { C+ } "i" } [ insert-cell-before ] }
    { T{ key-down f { C+ } "a" } [ insert-cell-after ] }
    { T{ key-down f { C+ } "-" } [ insert-row-above ] }
    { T{ key-down f { C+ } "_" } [ insert-row-below ] }
    { T{ key-down f { C+ } "[" } [ insert-col-before ] }
    { T{ key-down f { C+ } "]" } [ insert-col-after ] }

    { T{ key-down f { C+ } "@" } [ insert-cell-within ] }

    { T{ key-down f { C+ } "k" } [ focus-cell-upwards ] }
    { T{ key-down f { C+ } "l" } [ focus-cell-rightwards ] }
    { T{ key-down f { C+ } "h" } [ focus-cell-leftwards ] }
    { T{ key-down f { C+ } "j" } [ focus-cell-downwards ] }
    ! { T{ key-down f { C+ } "K" } [ focus-cell-outwards ] } or focus minimum row element?
    ! { T{ key-down f { C+ } "J" } [ focus-cell-inwards ] }

    { T{ key-down f { C+ } "^" } [ evaluate-cell-upwards ] }
    { T{ key-down f { C+ } ">" } [ evaluate-cell-rightwards ] }
    { T{ key-down f { C+ } "<" } [ evaluate-cell-leftwards ] }
    { T{ key-down f { C+ } "v" } [ evaluate-cell-downwards ] }

    ! { T{ key-down f { C+ } "*" } [ squash-cell ] }
    { T{ key-down f { C+ } "*" } [ squash-parent-cell ] }
    { T{ key-down f { C+ } "t" } [ transpose-parent-cell ] }

    ! cell referencing
    ! vectors as grids
    ! objects/assocs as grids
} set-gestures
