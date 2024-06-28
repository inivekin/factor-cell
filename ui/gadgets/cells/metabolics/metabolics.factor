USING: accessors arrays combinators combinators.short-circuit
compiler.cfg.stacks.global continuations eval io.streams.string
kernel listener math math.matrices math.order prettyprint
sequences stack-checker ui.commands ui.gadgets
ui.gadgets.cells.cellular ui.gadgets.cells.dead
ui.gadgets.cells.genomes ui.gadgets.cells.membranes
ui.gadgets.cells.walls ui.gadgets.editors ui.gadgets.grids
ui.gadgets.panes ;
FROM: ui.gadgets.cells.dead => dead? ;
IN: ui.gadgets.cells.metabolics

! something that can be evaluated from input to output
MIXIN: metabolic

: identify-enzymes ( metabolic -- quot in out )
  editor-string [ parse-string ] with-interactive-vocabs dup infer [ in>> length ] [ out>> length ] bi ;

: lacking-cells-after? ( out cells pair -- n )
  second cut nip length 1 - swap - ;
: lacking-cells-before? ( out cells pair -- n )
  second cut drop length swap - ;
: lacking-cells-below? ( out cells pair -- n ) lacking-cells-after? ;
: lacking-cells-above? ( out cells pair -- n ) lacking-cells-before? ;

: output-cell-insertion-needed? ( n -- f/n )
  dup 0 < [ drop f ] unless ;
: insert-cell-times ( pair cells inserter -- quot: ( n -- ) )
  '[ abs [ _ second _ nth @ drop ] times ] ; inline

: prepare-metabolic-outputs ( counter inserter -- count: ( out cells pair -- ) insert: ( cells pair -- ) )
  [ '[ @ output-cell-insertion-needed? ] ]
  [ '[ swap _ insert-cell-times ] ] bi* ; inline

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

: marshall-cell-type-in ( cell -- x )
  {
    { [ dup dead? ] [ gadget-child gadget-child editor-string [ parse-string call( -- x ) ] with-interactive-vocabs ] }
    { [ dup wall? ] [ grid>> marshall-cell-type-in ] }
    [ [ pprint-short ] with-string-writer " unknown cell type can't be marshalled in" append throw ]
  } cond ; recursive

: metabolize ( in-stack quot cell -- out-stack )
  [ [ marshall-cell-type-in ] map ] 2dip
  gadget-child children>> second [ with-datastack ] with-pane ;

: cell-genome ( cell -- genome )
  2 [ gadget-child ] times ;

: set-cell ( cell obj -- )
  [ pprint ] with-string-writer swap cell-genome set-editor-string
  ;

DEFER: marshall-type-out
: marshall-type-out ( cell obj -- )
  set-cell
  ;

: set-output-cells ( out-cells datastack -- )
  [ marshall-type-out ] 2each
  ;

: metabolize-rightward ( cell -- )
  [ cell-genome identify-enzymes ] [ [ pair>> ] [ find-wall ] bi ] bi
  metabolic-pathway-rightward [ rot ] dip metabolize set-output-cells ;
: metabolize-leftward ( cell -- )
  [ cell-genome identify-enzymes ] [ [ pair>> ] [ find-wall ] bi ] bi
  metabolic-pathway-leftward [ <reversed> swap rot ] dip metabolize set-output-cells ;
  
: metabolize-downward ( cell -- )
  [ cell-genome identify-enzymes ] [ [ pair>> <reversed> ] [ find-wall ] bi ] bi
  metabolic-pathway-downward [ rot ] dip metabolize set-output-cells ;
: metabolize-upward ( cell -- )
  [ cell-genome identify-enzymes ] [ [ pair>> <reversed> ] [ find-wall ] bi ] bi
  metabolic-pathway-upward [ <reversed> swap rot ] dip metabolize set-output-cells ;
  
