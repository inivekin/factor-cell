USING: accessors arrays assocs classes combinators
combinators.short-circuit
continuations eval io.streams.string kernel listener math
math.matrices math.order namespaces prettyprint
prettyprint.backend sequences stack-checker ui.commands
ui.gadgets ui.gadgets.cells.cellular ui.gadgets.cells.dead
ui.gadgets.cells.alive ui.gadgets.cells.genomes ui.gadgets.cells.membranes
ui.gadgets.cells.interlinks ui.gadgets.cells.prisons ui.gadgets.cells.walls
ui.gadgets.editors ui.gadgets.grids ui.gadgets.panes ;
FROM: ui.gadgets.cells.dead => dead? ;
IN: ui.gadgets.cells.metabolics

! something that can be evaluated from input to output
MIXIN: metabolic

: identify-enzymes ( metabolic -- quot in out )
  dup parent>> parent>> absorbing-cell [ editor-string [ parse-string ] with-interactive-vocabs ] with-variable dup infer [ in>> length ] [ out>> length ] bi ;

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

: metabolize ( in-stack quot cell -- out-stack )
  [ [ absorb ] map ] 2dip
  [ gadget-child { 0 1 } >>filled-cell drop ]
  [ cell-membrane [ with-datastack ] with-pane ] bi ;

: set-cell-dead ( cell obj -- )
  [ [ pprint ] without-limits ] with-string-writer swap cell-genome set-editor-string
  ;
: set-cell-alive ( cell obj -- )
  >>ref [ cell-membrane ] keep '[ _ ref>> pprint-short ] with-pane
  ;

: kill-cell ( cell -- )
  dup pair>> <dead-cell>
  [ replace-cell ]
  [ swap ref>> set-cell-dead ]
  [ request-focus drop ] 2tri
  ;
! change to metabolize in place? create new output cell an put in its place
: revive-cell ( cell -- )
  [ [ dup absorbing-cell [ cell-genome editor-string [ parse-string ] with-interactive-vocabs ] with-variable call( -- x ) ] [ pair>> ] bi <alive-cell> ] keep
  [ swap replace-cell ]
  [ drop dup ref>> set-cell-alive ] 2bi
  ;

DEFER: excrete
SYMBOL: recursion-check
: expand-cell ( cell -- )
  [ [ parent>> ] [ pair>> ] bi swap ]
  [ dup ref>> V{ } clone recursion-check [ excrete ] with-variable ]
  bi
  cell-nth request-focus
  ;

: matrix>cells ( cell matrix inserter: ( pair -- cell ) auto-collapse? -- multicellular )
  '[ matrix-dim [ <iota> ] bi@ [ 2array @ ] cartesian-map f <cell-wall> [ replace-cell ] [ _ [ imprison ] when drop ] [ grid>> ] tri ]
  ! [ [ [ excrete ] 2each ] 2each ] bi ! if recursing
  [ [ [ set-cell-alive ] 2each ] 2each ] bi ! better to not recurse and require incremental manual expansion?
  ; inline

: tuple>matrix ( obj -- matrix )
  [ class-of 1array ]
  ! [ tuple>assoc 1array ]
  [ ! make-mirror
      tuple>unfiltered-assoc 1array ]
  bi 2array
  ;
: tuple>cells ( cell obj inserter: ( pair -- cell ) -- multicellular )
  [ tuple>matrix ] dip f matrix>cells ; inline

: excrete ( cell obj -- )
  dup recursion-check get member-eq?
  [
    set-cell-alive
  ]
  [
    dup recursion-check get push
    {
      { [ dup non-empty-matrix? ] [ [ <default-cell> ] f matrix>cells ] }
      { [ dup tuple? ] [ [ <default-cell> ] tuple>cells ] }
      { [ dup { [ array? ] [ empty? not ] } 1&& ] [ 1array [ <default-cell> ] f matrix>cells ] }
      [ over alive? [ set-cell-alive ] [ set-cell-dead ] if ]
    } cond
    recursion-check get pop*
  ] if
  ;

: set-output-cells ( out-cells datastack -- )
  V{ } clone recursion-check [ [ excrete ] 2each ] with-variable
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
  
