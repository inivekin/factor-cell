USING: accessors eval kernel listener math math.matrices
prettyprint.sections sequences stack-checker ui.gadgets
ui.gadgets.cells.cellular ui.gadgets.cells ui.gadgets.cells.walls ui.gadgets.editors ;
IN: ui.gadgets.cells.metabolics

! something that can be evaluated from input to output
MIXIN: metabolic

: identify-enzymes ( metabolic -- quot in out )
  editor-string [ parse-string ] with-interactive-vocabs dup infer [ in>> length ] [ out>> length ] bi ;

: lacking-cells-after? ( out cells pair -- n )
  second cut nip length 1 - swap - ;
: lacking-cells-before? ( out cells pair -- n )
  second cut drop length swap - ;
! treat columns as rows during this so using the row utilities
: lacking-cells-below? ( out cells pair -- n ) lacking-cells-after? ;
: lacking-cells-above? ( out cells pair -- n ) lacking-cells-before? ;

: output-cell-insertion-needed? ( n -- f/n )
  dup 0 < [ drop f ] unless ;
: insert-cell-times ( pair cells inserter -- quot: ( n -- ) )
  '[ abs [ _ second _ nth gadget-child gadget-child @ drop ] times ] ; inline

: prepare-metabolic-outputs ( counter inserter -- count: ( out cells pair -- ) insert: ( cells pair -- ) )
  [ '[ @ output-cell-insertion-needed? ] ]
  [ '[ swap _ insert-cell-times ] ] bi* ; inline

: metabolic-output-cells ( out cells pair inserter -- )
  [ [ lacking-cells-after? output-cell-insertion-needed? ] ] dip
  '[ swap _ insert-cell-times ] 2bi when*
  ; inline

:: metabolic-output-cells-back ( out cells pair inserter -- )
  out cells pair lacking-cells-before? output-cell-insertion-needed?
  inserter '[ abs [ pair second cells nth gadget-child gadget-child @ drop ] times ] when*
  ; inline

: metabolic-pathway-split ( priors posts in out -- out-stack in-stack cell )
  [ '[ _ tail-slice* ] ]           ! drop prior cells so only in-stack remains
  [ '[ 1 cut [ first ]             ! pull current cell out of single array
             [ _ head-slice ] bi* ! get reference only to cells required to write into
     ]
  ]
  bi* ! create the quotes with in/out counts curried
  bi* ! execute the quotes for preceding cells and succeeding cells respectively
  -rot
  ;

: metabolic-row ( pair wall -- cells pair )
  [ dup first ] dip grid>> row swap ;
: metabolic-col ( pair wall -- cells pair )
  [ dup first ] dip grid>> col swap ;

: metabolic-pathway-horizontal ( out pair wall counter inserter -- priors posts )
  '[ metabolic-row _ _ prepare-metabolic-outputs 2bi when* ] ! ensure output cells exist
  [ metabolic-row second cut ] ! separate in-seq-with-prior-cells and cur-cell..
  2bi
  ; inline
: metabolic-pathway-vertical ( out pair wall counter inserter -- priors posts )
  '[ metabolic-col _ _ prepare-metabolic-outputs 2bi when* ] ! ensure output cells exist
  [ metabolic-col second cut ] ! separate in-seq-with-prior-cells and cur-cell..
  2bi
  ; inline

: metabolic-pathway-rightward ( in out pair wall -- out-stack in-stack cell )
  [ metabolic-row [ lacking-cells-after? ] [ (insert-cell-after) ] prepare-metabolic-outputs 2bi when* ]
  [ '[ _ _ metabolic-row second cut ] 2dip metabolic-pathway-split ]
  3bi ;
: metabolic-pathway-leftward ( in out pair wall -- out-stack in-stack cell )
  [ metabolic-row [ lacking-cells-before? ] [ (insert-cell-before) ] prepare-metabolic-outputs 2bi when* ]
  [ '[ _ _ metabolic-row second cut ] 2dip swap metabolic-pathway-split ]
  3bi ;
: metabolic-pathway-downward ( in out pair wall -- out-stack in-stack cell )
  [ metabolic-col [ lacking-cells-below? ] [ (insert-cell-below) ] prepare-metabolic-outputs 2bi when* ]
  [ '[ _ _ metabolic-col second cut ] 2dip metabolic-pathway-split ]
  3bi ;
: metabolic-pathway-upward ( in out pair wall -- out-stack in-stack cell )
  [ metabolic-col [ lacking-cells-above? ] [ (insert-cell-above) ] prepare-metabolic-outputs 2bi when* ]
  [ '[ _ _ metabolic-col second cut ] 2dip swap metabolic-pathway-split ]
  3bi ;

DEFER: marshall-cell-type-in
: (marshall-cell-type-in) ( obj -- x )
  {
    ! FIXME(kevinc) this cell? check will fail on first load as cell type not fully known?
    { [ dup border? [ dup gadget-child cell? ] [ f ] if ] [ gadget-child gadget-child editor-string [ parse-string call( -- x ) ] with-interactive-vocabs ] }
    { [ dup wall? ] [ grid>> marshall-cell-type-in ] }
    [ [ pprint-short ] with-string-writer " unknown cell type can't be marshalled in" append throw ]
  } cond
  ;

: marshall-cell-type-in ( cell -- x )
  [ (marshall-cell-type-in) ] map-cells ; recursive

: metabolize ( in-stack quot cell -- out-stack )
  [ [ (marshall-cell-type-in) ] map ] 2dip
  gadget-child children>> second [ with-datastack ] with-pane ;

: set-cell ( cell obj -- )
  [ pprint ] with-string-writer swap gadget-child gadget-child set-editor-string
  ;

DEFER: marshall-type-out
: marshall-type-out ( cell obj -- )
  set-cell
  ;

: set-output-cells ( out-cells datastack -- )
  [ marshall-type-out ] 2each
  ;

: metabolize-rightward ( cellular -- )
  [ identify-enzymes ] [ parent>> [ pair>> ] [ find-wall ] bi ] bi
  metabolic-pathway-rightward [ rot ] dip metabolize set-output-cells ;
: metabolize-leftward ( cellular -- )
  [ identify-enzymes ] [ parent>> [ pair>> ] [ find-wall ] bi ] bi
  metabolic-pathway-leftward [ <reversed> swap rot ] dip metabolize set-output-cells ;
  
: metabolize-downward ( cellular -- )
  [ identify-enzymes ] [ parent>> [ pair>> <reversed> ] [ find-wall ] bi ] bi
  metabolic-pathway-downward [ rot ] dip metabolize set-output-cells ;
: metabolize-upward ( cellular -- )
  [ identify-enzymes ] [ parent>> [ pair>> <reversed> ] [ find-wall ] bi ] bi
  metabolic-pathway-upward [ <reversed> swap rot ] dip metabolize set-output-cells ;
  
