USING: io organism wall interlinks proteins splicer sequences.extras ;
FROM: models => change-model ;
IN: mutation

MIXIN: mutagen

GENERIC: (mutate) ( skin mutation mutagen -- )
GENERIC: (unmutate) ( skin mutation mutagen -- )

INITIALIZED-SYMBOL: freezer [ LH{ } clone <model> ]

! NOTE in/ribozymes is a range of relative cells e.g. { 3 1 } 3rows of 1 column after nucleus
TUPLE: mutation nucleus pathway enzymes ribozymes dna type ;
C: <mutation> mutation
SINGLETONS: growth excise splice splint siphon swivel stasis thaw insplice ;

INSTANCE: growth mutagen
INSTANCE: excise mutagen
INSTANCE: splice mutagen
INSTANCE: splint mutagen
INSTANCE: siphon mutagen
INSTANCE: swivel mutagen
INSTANCE: stasis mutagen
INSTANCE: thaw mutagen
INSTANCE: insplice mutagen

INITIALIZED-SYMBOL: mutations [ 1 ]

: <growth> ( ref pathway ribozymes quot: ( cell pair-from pair-to -- cells ) -- growth )
  [ f ] 2dip growth <mutation> ;
: <excise> ( ref pathway enzymes -- excise )
  f f excise <mutation> ;
: infer-relative-pairs ( quot -- ins outs )
  infer
  [ in>> length ]
  [ out>> length ] bi ;
:: <splice> ( ref quot pathway -- splice )
  ref pathway
  quot pathway [ infer-relative-pairs ] [ horizontal = [ [ 1 swap 2array ] bi@ ] [ [ 1 2array ] bi@ ] if ] bi*
  quot splice <mutation>
  ;
:: <inplace-splice> ( ref quot pathway -- splice )
  ref pathway
  f f 
  quot insplice <mutation>
  ;
: <splint> ( ref pathway -- splint ) 
  f f f splint <mutation> ;
: <siphon> ( ref -- siphon )
  f f f f siphon <mutation> ;
: <swivel> ( ref -- swivel )
  f f f f swivel <mutation> ;
: <stasis> ( ref -- stasis )
  f f f f stasis <mutation> ;
: <thaw> ( ref -- thaw )
  f f f f thaw <mutation> ;

: expand-range ( out/enzymes -- matrix )
  dup empty? [ first2 [ <iota> ] bi@ cartesian-product ] unless ;
: (regrow) ( cells sheet mutation -- )
  [ nucleus>> last swap ] [ pathway>> ] bi {
    { vertical [ n-row-insert ]  }
    { horizontal [ n-col-insert ] }
    [ throw ]
  } case ;
: (grow) ( cell mutation -- )
  { [ nucleus>> last ] [ ribozymes>> over v+ ] [ dna>> ] [ pathway>> ] } cleave {
    { vertical [ insert-below ] }
    { horizontal [ insert-after ] }
    [ throw ]
  } case ;
: (excise) ( cell mutation -- excised )
  [ enzymes>> ] [ pathway>> ] bi {
    { vertical [ first remove-below ] }
    { horizontal [ second remove-after ] }
    [ throw ]
  } case ;

: (splinter) ( cell -- replaced )
  [ cell-coordinate ] [ parent>> ] [ organise ] tri metabolise -rot swapout ;
: (unsplinter) ( replaced replacer -- )
  [ cell-coordinate ] [ parent>> ] bi swapout drop ;
: (siphon) ( wall -- replaced )
  [ cell-coordinate ] [ parent>> ] [ organise [ ] curry <chain> <cell> <membrane-control> ] tri -rot swapout ;
: (unsiphon) ( replaced replacer -- )
  [ cell-coordinate ] [ parent>> ] bi swapout drop ;
: (swivel) ( wall -- )
  [ grid>> flip ] [ grid<< ] bi ;

: <cryogenics-table> ( cell -- table )
  '[ freezer get [ [ _ swap ] dip set-at ] change-model* ] <action-field> "cell label" >>default-text
  ;
: <thaw-table> ( cell -- table )
  [ freezer get [ keys [ ">" swap 2array ] map ] <arrow> trivial-renderer [ second ] <search-table> dup table>> ] dip
  [ cell-coordinate ] [ parent>> ] bi
  '[ second freezer get value>> at _ _ swapout drop ] >>action [ hide-glass ] >>hook t >>selection-required? t >>takes-focus? drop
  ;
: show-cryogenics-popup ( cell -- )
  <cryogenics-table> [ world get world-focus swap over gadget>rect show-glass ] [ request-focus ] bi ;
: show-thaw-popup ( cell -- )
  <thaw-table> [ world get world-focus swap over gadget>rect show-glass ] [ table>> request-focus ] bi ;
: (freeze) ( cell -- )
  [ cell-coordinate ] [ parent>> ] bi 1 1 <cancer> { 0 0 } swap matrix-nth -rot swapout show-cryogenics-popup ;
: (unfreeze) ( cell -- )
  [ cell-coordinate ] [ parent>> ] bi freezer get control-value >alist pop -rot swapout drop ;

: get-out-mutations ( cell mutation -- cells )
  [ ribozymes>> expand-range concat ] [ pathway>> <reversed> '[ _ v+ ] map ] bi get-rel-cells ;
: (splice) ( cell mutation -- replaced )
  {
    [ drop cell>> control-value ] ! NOTE this is the replaced return FIXME should this be doing cell>> also???
    [ [ enzymes>> expand-range concat [ vneg ] map ] [ pathway>> <reversed> '[ _ v- ] map ] bi get-rel-cells [ organise ] map ]
    [ get-out-mutations ] ! [ cell>> ] map ]
    [ swap [ dna>> swap <fold> ] [ cell>> model>> set-model ] bi* ]
  }
  2cleave ;
: (resplice) ( quot cell mutation -- )
  drop cell>> model>> set-model ;
: (insplice) ( cell mutation -- replaced )
  {
    [ drop cell>> control-value ] ! NOTE this is the replaced return FIXME should this be doing cell>> also???
    [ swap [ dna>> <chain> ] [ cell>> model>> set-model ] bi* ]
  }
  2cleave ;
: (reinsplice) ( quot cell mutation -- )
  drop cell>> model>> set-model ;

: ?. ( quot -- )
  [ get-listener output>> ] dip with-pane ; inline
: (?undo/redo.) ( skin -- )
  '[ [ _ organism>> [ \ undo>> . undo>> . ] [ \ redo>> . redo>> . ] [ \ waste>> . waste>> . ] tri ] ?. ] with-short-limits ;
: ?undo/redo. ( quot -- )
  '[ dup (?undo/redo.) @ ] keep (?undo/redo.) ; inline
: new-dna-branch? ( organism -- ? )
  [ undo>> ] [ redo>> ] bi [ dimension second ] bi@ = ;
: store-dna ( mutation organism -- )
  organism>>
  [ [ new-dna-branch? ] [ undo>> empty? not ] bi and ]
  [ [
     ! organism shuffled to
     ! undos mutation redos
     [ undo>> swap ] [ redo>> ] bi dup length [ drop [ last ] dip push ] [ drop pop swap suffix! swap push ] if-zero ] [ undo>> swap 1vector swap push ] bi-curry if ] bi
     ! FIXME yikes
  ;

: restore-dna ( organism -- mutation )
  organism>>
  [ undo>> pop ]
  [ [ redo>> push ] curry [ last ] bi ] bi
  ;

: unrestore-dna ( organism -- mutation )
  organism>>
  [ redo>> pop ]
  [ [ undo>> push ] curry [ last ] bi ] bi
  ;

: defecate ( skin waste -- ) swap organism>> waste>> push ;
: biopsy ( skin mutation -- cell ) nucleus>> probe ; 
M: growth (mutate) drop [ biopsy ] [ (grow) ] bi ;
M: growth (unmutate) drop [ biopsy ] [ (excise) ] bi drop ;
M: excise (mutate) drop dupd [ biopsy ] [ (excise) ] bi defecate ;
                                                         ! TODO consider clamping pair probe to grid dims (currently probe to sheet level here as removed row/col may not exist anymore)
M: excise (unmutate) drop [ drop organism>> waste>> pop ] [ nucleus>> but-last probe ] [ nip (regrow) ] 2tri ;
M: splice (mutate) drop dupd [ biopsy ] [ (splice) ] bi defecate ;
M: splice (unmutate) drop [ drop organism>> waste>> pop ] [ biopsy ] [ nip (resplice) ] 2tri ;
M: splint (mutate) drop dupd biopsy (splinter) defecate ;
M: splint (unmutate) drop [ drop organism>> waste>> pop ] [ biopsy ] 2bi (unsplinter) ;
M: siphon (mutate) drop dupd biopsy (siphon) defecate ;
M: siphon (unmutate) drop [ drop organism>> waste>> pop ] [ biopsy ] 2bi (unsiphon) ;
M: swivel (mutate) drop biopsy (swivel) ;
M: swivel (unmutate) drop biopsy (swivel) ;
M: stasis (mutate) drop biopsy (freeze) ;
M: stasis (unmutate) drop biopsy (unfreeze) ;
M: thaw (mutate) drop biopsy show-thaw-popup ;
M: thaw (unmutate) drop biopsy drop ;
M: insplice (mutate) drop dupd [ biopsy ] [ (insplice) ] bi defecate ;
M: insplice (unmutate) drop [ drop organism>> waste>> pop ] [ biopsy ] [ nip (reinsplice) ] 2tri ;

: focus-mutation ( mutation skin -- )
  over type>> { [ thaw? ] [ stasis? ] } 1|| [ 2drop ]
  [
      over biopsy
      swap {
        { [ dup ribozymes>> ] [ [ ribozymes>> ] [ pathway>> ] bi v- ] }
        [ drop { 0 0 } ]
      } cond
      n-cell-relative [ relayout ] [ request-focus ] [ scroll>gadget ] tri
  ] if
  ;
   

: mutate ( mutation skin -- )
  [ store-dna ] ! [ store-dna ] ?undo/redo. ]
  [ swap dup type>> (mutate) ]
  [ focus-mutation ] 2tri ;
: unmutate ( skin -- )
  [ restore-dna ] ! [ restore-dna ] ?undo/redo. ]
  [ [ swap dup type>> (unmutate) ] [ focus-mutation ] 2bi ] bi ;
: remutate ( skin -- )
  [ unrestore-dna ] ! [ unrestore-dna ] ?undo/redo. ]
  [ [ swap dup type>> (mutate) ] [ focus-mutation ] 2bi ] bi ;

: unmutate-once ( cell -- )
  find-skin unmutate ;
: remutate-once ( cell -- )
  find-skin remutate ;

: (grow?) ( sheet pair splice -- dimension pathway range )
  dup pathway>> [ '[ grid>> dimension { 1 1 } v- [ 1array ] [ _ swap ] bi ]
  [ ]
  ] keep '[ ribozymes>> v+ _ v- ! subtract pathway because that already exists?
          ] tri*
  swap [v-]
  ;
: [cancerous-growth] ( -- quot: ( cell pair-from pair-to -- cells ) )
  [ swap v- nip first2 <cancer> ] ;
: [clone-growth] ( -- quot: ( cell pair-from pair-to -- cells ) )
  [ [ parent>> grid>> ] 2dip submatrix mitosis ] ;

: growth-needed? ( mutation skin -- mutation/f )
  [ swap nucleus>> unclip-last [ probe ] dip ]
  [ drop [ (grow?) ] [ [ nucleus>> [ [ nip ] with change-last ] keep ] curry 2dip ] bi ]
  [ drop [ dup [ 0 = ] all? [ 3drop f ] ] dip
  pathway>>
  '[ _ v+ [cancerous-growth] <growth> ] if ] 2tri ;
: (siphon?) ( cells -- mutations )
  [ dup wall? [ cell-coordinates <siphon> ] [ drop f ] if ] map sift
  ;
: siphons-needed? ( mutation skin -- mutations )
  over biopsy swap get-out-mutations (siphon?)
  ;
: grow ( cell pathway -- )
  '[ cell-coordinates _ mutations get 1 2array [cancerous-growth] <growth> ]
  [ find-skin mutate ] bi ;
: grow-below ( cell -- )
  vertical grow ;
: grow-after ( cell -- )
  horizontal grow ;
: split ( cell pathway -- )
  '[ cell-coordinates _ mutations get 1 2array [clone-growth] <growth> ]
  [ find-skin mutate ] bi ;
: split-below ( cell -- )
  vertical split ;
: split-after ( cell -- )
  horizontal split ;


: excision ( cell pathway -- )
  over parent>> grid>> dimension over
  {
    { vertical [ second mutations get swap ] }
    { horizontal [ first mutations get ] }
    [ throw ]
  } case 2array
  '[ cell-coordinates _ _ <excise> ]
  [ [ skin? ] find-parent mutate ] bi ;
: excise-below ( cell -- )
  vertical excision ;
: excise-after ( cell -- )
  horizontal excision ;

: parse-splice ( str splicer -- quot )
                    ! FIXME this won't work for multi-line syntax, do something like listener calculating thread's parse-lines
  ?manifest?>> '[ [ [ read-quot dup ] [ ] produce nip [ ] concat-as ] _ (with-manifest) ] with-string-reader ;

: (splice-along) ( splice skin -- )
  [ [ growth-needed? ] keep [ mutate ] curry when* ]
  [ [ siphons-needed? ] keep [ mutate ] curry each ]
  [ mutate ]
  2tri ;
: splice-along ( splicer pathway -- )
  '[
  [ splicing>> [ find-skin ] [ cell-coordinates ] bi ]
  [ editor-string ]
  [ dup splicing>> absorbing-cell [ parse-splice _ <splice> ] with-variable ]
  tri swap (splice-along)
  ] [ hide-glass ] swap bi ;
: inplace-splice-along ( splicer pathway -- )
  '[
  [ splicing>> [ find-skin ] [ cell-coordinates ] bi ]
  [ editor-string ]
  [ dup splicing>> absorbing-cell [ parse-splice _ <inplace-splice> ] with-variable ]
  tri swap (splice-along)
  ] [ hide-glass ] swap bi ;

: splice-below ( splicer -- )
  vertical splice-along ;
: splice-after ( splicer -- )
  horizontal splice-along ;
: insplice-below ( splicer -- )
  vertical inplace-splice-along ;
: insplice-after ( splicer -- )
  horizontal inplace-splice-along ;
:: gene-expression ( quot pathway cell -- )
  cell cell-coordinates 
  quot
  pathway
  <splice> cell find-skin (splice-along)
  ;

: resume-selection ( splicer -- )
  [ hide-glass ] [ splicing>> request-focus ] bi ;
: splinter ( cell -- )
  [ cell-coordinates mutations get <splint> ] [ find-skin ] bi mutate ;
: siphon-up ( wall -- )
  [ cell-coordinates <siphon> ] [ find-skin ] bi mutate ;

: swivel-colony ( wall -- )
  [ cell-coordinates <swivel> ] [ find-skin ] bi mutate ;

: freeze-colony ( cell -- )
  [ cell-coordinates <stasis> ] [ find-skin ] bi mutate ;
: thaw-colony ( cell -- )
  [ cell-coordinates <thaw> ] [ find-skin ] bi mutate ;

FROM: ui.gadgets.glass.private => glass? ;
: hide-glass-without-refocus ( glass -- )
    [ glass? ] find-parent
    [ dup find-world [ unparent ] dip drop ] when* ;
CONSTANT: cell-search-limit 50
:: highlighter-search ( cell -- )
  cell dup membrane-control? [ parent>> ] when :> searching-cell
  searching-cell grid>> [ [ cell-coordinates make-cell-coords ] [ gadget-text cell-search-limit index-or-length head ] [ ] tri 3array ] matrix-map concat <model>
  [ { 0 1 } swap cols flip ] <arrow> trivial-renderer [ second ] <search-table> dup table>>
  [ first parse-cell-coords searching-cell find-skin swap probe request-focus ] >>action [ hide-glass-without-refocus ] >>hook t >>selection-required?
  10 >>min-rows 10 >>max-rows 30 >>min-cols 30 >>max-cols drop
  <scroller> white-interior
  [ world get world-focus swap over gadget>rect show-glass ] [ request-focus ] bi ;

: reference-cell-in-splicer ( cell -- )
  [ capture-cell present ] [ find-skin organism>> splicer>> [ user-input ] keep ]
  [ swap over [ popup-color <solid> >>boundary ] [ gadget>rect ] bi* ] tri over [ show-glass ] [ request-focus ] bi*
  ;

:: splinter-reprobe ( cell pair sheet -- cell )
  cell membrane-control? [ cell splinter pair sheet matrix-nth ] [ cell ] if
  ;
: mutating-probe ( skin pairs -- cell )
  unclip-last [ [ over clamp-pair-to-wall
    swap grid>> [ matrix-nth ] [ splinter-reprobe ] 2bi ] each ] [ swap grid>> matrix-nth ] bi* ;
M: capture uncapture-cell ( capture -- cell )
  [ skin>> ] [ pairs>> ] bi mutating-probe ;
SYNTAX: ## #@ find-skin scan-token parse-cell-coords
     swap capture boa suffix ;
     ! mutating-probe suffix ;
     ! mutating-probe capture-cell suffix \ uncapture-cell suffix ;

splicer "splicing" f {
  { T{ key-down f f "RET" } splice-below }
  { T{ key-down f { C+ } "RET" } splice-after }
  { T{ key-down f { A+ } "RET" } insplice-below }
  { T{ key-down f { A+ C+ } "RET" } insplice-after }
  { T{ key-down f f "ESC" } resume-selection }
} define-command-map

