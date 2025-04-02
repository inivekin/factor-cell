USING: organism wall interlinks proteins splicer sequences.extras ;
FROM: models => change-model ;
IN: mutation

MIXIN: mutagen

GENERIC: (mutate) ( skin mutation -- )
GENERIC: (unmutate) ( skin mutation -- )

INITIALIZED-SYMBOL: freezer [ LH{ } clone <model> ]

! NOTE in/out-pairs is a range of relative cells e.g. { 3 1 } 3rows of 1 column after reference-pairs
TUPLE: +growth+ reference-pairs direction in-pairs out-pairs dna ;
TUPLE: +excise+ reference-pairs direction in-pairs out-pairs dna ;
TUPLE: +splice+ reference-pairs direction in-pairs out-pairs dna ;
TUPLE: +splint+ reference-pairs direction in-pairs out-pairs dna ;
TUPLE: +siphon+ reference-pairs direction in-pairs out-pairs dna ;
TUPLE: +swivel+ reference-pairs direction in-pairs out-pairs dna ;
TUPLE: +stasis+ reference-pairs direction in-pairs out-pairs dna ;
TUPLE: +thaw+ reference-pairs direction in-pairs out-pairs dna ;

INSTANCE: +growth+ mutagen
INSTANCE: +excise+ mutagen
INSTANCE: +splice+ mutagen
INSTANCE: +splint+ mutagen
INSTANCE: +siphon+ mutagen
INSTANCE: +swivel+ mutagen
INSTANCE: +stasis+ mutagen
INSTANCE: +thaw+ mutagen

INITIALIZED-SYMBOL: mutations [ 1 ]

: <growth> ( ref direction out-pairs -- growth )
  [ f ]  dip f +growth+ boa ;
: <excise> ( ref direction in-pairs -- excise )
  f f +excise+ boa ;
: infer-relative-pairs ( quot -- ins outs )
  infer
  [ in>> length ]
  [ out>> length ] bi ;
:: <splice> ( ref quot direction -- splice )
  ref direction
  quot direction [ infer-relative-pairs ] [ horizontal = [ [ 1 swap 2array ] bi@ ] [ [ 1 2array ] bi@ ] if ] bi*
  quot +splice+ boa
  ;
: <splint> ( ref direction -- splint ) 
  f f f +splint+ boa ;
: <siphon> ( ref -- siphon )
  f f f f +siphon+ boa ;
: <swivel> ( ref -- swivel )
  f f f f +swivel+ boa ;
: <stasis> ( ref -- stasis )
  f f f f +stasis+ boa ;
: <thaw> ( ref -- thaw )
  f f f f +thaw+ boa ;

: expand-range ( out/in-pairs -- matrix )
  dup empty? [ first2 [ <iota> ] bi@ cartesian-product ] unless ;
: (regrow) ( cells sheet mutation -- )
  [ reference-pairs>> last swap ] [ direction>> ] bi {
    { vertical [ n-row-insert ]  }
    { horizontal [ n-col-insert ] }
    [ throw ]
  } case ;
: (grow) ( cell mutation -- )
  [ reference-pairs>> last ] [ out-pairs>> over v+ ] [ direction>> ] tri {
    { vertical [ insert-below ] }
    { horizontal [ insert-after ] }
    [ throw ]
  } case ;
: (excise) ( cell mutation -- excised )
  [ in-pairs>> ] [ direction>> ] bi {
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
  '[ second freezer get value>> at (mitosis) <membrane-control> _ _ swapout drop ] >>action
  [ hide-glass ] >>hook t >>selection-required? t >>takes-focus? drop
  ;
: show-cryogenics-popup ( cell -- )
  <cryogenics-table> [ world get world-focus swap over gadget>rect show-glass ] [ request-focus ] bi ;
: show-thaw-popup ( cell -- )
  <thaw-table> [ world get world-focus swap over gadget>rect show-glass ] [ field>> request-focus ] bi ;
: (freeze) ( cell -- )
  [ cell-coordinate ] [ parent>> ] bi 1 1 <cancer> { 0 0 } swap matrix-nth -rot swapout show-cryogenics-popup ;
: (unfreeze) ( cell -- )
  [ cell-coordinate ] [ parent>> ] bi freezer get control-value >alist pop -rot swapout drop ;

: get-out-mutations ( cell mutation -- cells )
  [ out-pairs>> expand-range concat ] [ direction>> <reversed> '[ _ v+ ] map ] bi get-rel-cells ;
: (splice) ( cell mutation -- replaced )
  {
    [ drop cell>> control-value ] ! NOTE this is the replaced return FIXME should this be doing cell>> also???
    [ [ in-pairs>> expand-range concat ] [ direction>> <reversed> '[ _ v- ] map ] bi get-rel-cells [ organise ] map ]
    [ get-out-mutations ] ! [ cell>> ] map ]
    [ swap [ dna>> swap <fold> ] [ cell>> model>> set-model ] bi* ]
  }
  2cleave ;
: (resplice) ( quot cell mutation -- )
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
: biopsy ( skin mutation -- cell ) reference-pairs>> probe ; 
M: +growth+ (mutate) [ biopsy ] [ (grow) ] bi ;
M: +growth+ (unmutate) [ biopsy ] [ (excise) ] bi drop ;
M: +excise+ (mutate) dupd [ biopsy ] [ (excise) ] bi defecate ;
                                                         ! TODO consider clamping pair probe to grid dims (currently probe to sheet level here as removed row/col may not exist anymore)
M: +excise+ (unmutate) [ drop organism>> waste>> pop ] [ reference-pairs>> but-last probe ] [ nip (regrow) ] 2tri ;
M: +splice+ (mutate) dupd [ biopsy ] [ (splice) ] bi defecate ;
M: +splice+ (unmutate) [ drop organism>> waste>> pop ] [ biopsy ] [ nip (resplice) ] 2tri ;
M: +splint+ (mutate) dupd biopsy (splinter) defecate ;
M: +splint+ (unmutate) [ drop organism>> waste>> pop ] [ biopsy ] 2bi (unsplinter) ;
M: +siphon+ (mutate) dupd biopsy (siphon) defecate ;
M: +siphon+ (unmutate) [ drop organism>> waste>> pop ] [ biopsy ] 2bi (unsiphon) ;
M: +swivel+ (mutate) biopsy (swivel) ;
M: +swivel+ (unmutate) biopsy (swivel) ;
M: +stasis+ (mutate) biopsy (freeze) ;
M: +stasis+ (unmutate) biopsy (unfreeze) ;
M: +thaw+ (mutate) biopsy show-thaw-popup ;
M: +thaw+ (unmutate) biopsy drop ;

: focus-mutation ( mutation skin -- )
  over { [ +thaw+? ] [ +stasis+? ] } 1|| [ 2drop ]
  [
      over biopsy
      swap {
        { [ dup out-pairs>> ] [ [ out-pairs>> ] [ direction>> ] bi v- ] }
        { [ dup in-pairs>> ] [ [ in-pairs>> vneg ] [ direction>> ] bi v+ ] }
        [ drop { 0 0 } ]
      } cond
      n-cell-relative yield [ request-focus ] [ scroll>gadget ] bi
  ] if
  ;
   

: mutate ( mutation skin -- )
  [ store-dna ] ! [ store-dna ] ?undo/redo. ]
  [ swap (mutate) ]
  [ focus-mutation ] 2tri ;
: unmutate ( skin -- )
  [ restore-dna ] ! [ restore-dna ] ?undo/redo. ]
  [ swap (unmutate) ] bi ;
: remutate ( skin -- )
  [ unrestore-dna ] ! [ unrestore-dna ] ?undo/redo. ]
  [ swap (mutate) ] bi ;

: unmutate-once ( cell -- )
  find-skin unmutate ;
: remutate-once ( cell -- )
  find-skin remutate ;

: (grow?) ( sheet pair splice -- dimension direction range )
  dup direction>> [ '[ grid>> dimension { 1 1 } v- [ 1array ] [ _ swap ] bi ]
  [ ]
  ] keep '[ out-pairs>> v+ _ v- ! subtract direction because that already exists?
          ] tri*
  swap [v-]
  ;
: grow? ( mutation skin -- mutation/f )
  [ swap reference-pairs>> unclip-last [ probe ] dip ]
  [ drop [ (grow?) ] [ [ reference-pairs>> [ [ nip ] with change-last ] keep ] curry 2dip ] bi ]
  [ drop [ dup [ 0 = ] all? [ 3drop f ] ] dip
  direction>>
  '[ _ v+ <growth> ] if ] 2tri ;
: (siphon?) ( cells -- mutations )
  [ dup wall? [ cell-coordinates <siphon> ] [ drop f ] if ] map sift
  ;
: siphon? ( mutation skin -- mutations )
  over biopsy swap get-out-mutations (siphon?)
  ;
: grow ( cell direction -- )
  '[ cell-coordinates _ mutations get 1 2array <growth> ]
  [ find-skin mutate ] bi ;
: grow-below ( cell -- )
  vertical grow ;
: grow-after ( cell -- )
  horizontal grow ;
: excise ( cell direction -- )
  over parent>> grid>> dimension over
  {
    { vertical [ second mutations get swap ] }
    { horizontal [ first mutations get ] }
    [ throw ]
  } case 2array
  '[ cell-coordinates _ _ <excise> ]
  [ [ skin? ] find-parent mutate ] bi ;
: excise-below ( cell -- )
  vertical excise ;
: excise-after ( cell -- )
  horizontal excise ;

: parse-splice ( str splicer -- quot )
  ?manifest?>> '[ [ [ read-quot dup ] [ ] produce nip [ ] concat-as ] _ (with-manifest) ] with-string-reader ;

: (splice-along) ( splice skin -- )
  [ [ grow? ] keep [ mutate ] curry when* ]
  [ [ siphon? ] keep [ mutate ] curry each ]
  [ mutate ]
  2tri ;
: splice-along ( splicer direction -- )
  '[
  [ splicing>> [ find-skin ] [ cell-coordinates ] bi ]
  [ editor-string ]
  [ dup splicing>> absorbing-cell [ parse-splice _ <splice> ] with-variable ]
  tri swap (splice-along)
  ] [ hide-glass ] swap bi ;

: splice-below ( splicer -- )
  vertical splice-along ;
: splice-after ( splicer -- )
  horizontal splice-along ;
:: splice ( quot direction cell -- )
  cell cell-coordinates 
  quot
  direction
  <splice> cell find-skin (splice-along)
  ;

: resume-selection ( splicer -- )
  [ hide-glass ] [ splicing>> request-focus ] bi ;
: splinter ( cell -- )
  [ cell-coordinates mutations get <splint> ] [ find-skin ] bi mutate ;
: siphon-up ( wall -- )
  [ cell-coordinates <siphon> ] [ find-skin ] bi mutate ;

: swivel ( wall -- )
  [ cell-coordinates <swivel> ] [ find-skin ] bi mutate ;

: freeze ( cell -- )
  [ cell-coordinates <stasis> ] [ find-skin ] bi mutate ;
: thaw ( cell -- )
  [ cell-coordinates <thaw> ] [ find-skin ] bi mutate ;

FROM: ui.gadgets.glass.private => glass? ;
: hide-glass-without-refocus ( glass -- )
    [ glass? ] find-parent
    [ dup find-world [ unparent ] dip drop ] when* ;
:: highlighter-search ( cell -- )
  cell dup membrane-control? [ parent>> ] when :> searching-cell
  searching-cell grid>> [ [ cell-coordinates make-cell-coords ] [ gadget-text ] [ ] tri 3array ] matrix-map concat <model>
  [ { 0 1 } swap cols flip ] <arrow> trivial-renderer [ second ] <search-table> dup table>>
  [ first parse-cell-coords searching-cell find-skin swap probe request-focus ] >>action [ hide-glass-without-refocus ] >>hook t >>selection-required? drop
  [ world get world-focus swap over gadget>rect show-glass ] [ request-focus ] bi ;

splicer "splicing" f {
  { T{ key-down f f "RET" } splice-below }
  { T{ key-down f { C+ } "RET" } splice-after }
  { T{ key-down f f "ESC" } resume-selection }
} define-command-map

