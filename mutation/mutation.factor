USING: wall interlinks proteins splicer ;
IN: mutation

! SINGLETONS: +growth+ +excise+ +splice+ absorb explode collapse ;
MIXIN: mutagen

GENERIC: (mutate) ( mutation skin -- )
GENERIC: (unmutate) ( mutation skin -- )

TUPLE: +growth+ pairs direction range ;
TUPLE: +excise+ pairs direction range ;
TUPLE: +splice+ pairs dna ;

INSTANCE: +growth+ mutagen
INSTANCE: +excise+ mutagen
INSTANCE: +splice+ mutagen

INITIALIZED-SYMBOL: mutations [ 1 ]

C: <growth> +growth+
C: <excise> +excise+
C: <splice> +splice+

: (regrow) ( cells sheet mutation -- )
  [ pairs>> last swap ] [ direction>> ] bi {
    { vertical [ n-row-insert ]  }
    { horizontal [ n-col-insert ] }
    [ throw ]
  } case ;
: (grow) ( cell mutation -- )
  [ pairs>> last ] [ range>> over v+ ] [ direction>> ] tri {
    { vertical [ insert-below ] }
    { horizontal [ insert-after ] }
    [ throw ]
  } case ;
: (excise) ( cell mutation -- excised )
  [ range>> ] [ direction>> ] bi {
    { vertical [ first remove-below ] }
    { horizontal [ second remove-after ] }
    [ throw ]
  } case ;

: (splice) ( cell mutation -- replaced )
  {
    [ drop control-value ]
    [ dna>> infer in>> length <iota> [ 1 + neg 0 2array ] map get-rel-cells [ cell>> control-value genes>> ] map { } concat-as ]
    [ dna>> infer out>> length <iota> [ 1 + 0 2array ] map get-rel-cells [ cell>> ] map ]
    [ swap [ dna>> swap <fold> ] [ cell>> model>> set-model ] bi* ]
  }
  2cleave ;
: (resplice) ( quot cell mutation -- )
  drop cell>> model>> set-model ;

: ?. ( quot -- )
  [ get-listener output>> ] dip with-pane ; inline
: (?undo/redo.) ( skin -- )
  '[ _ organism>> [ \ undo>> . undo>> ... ] [ \ redo>> . redo>> ... ] bi ] ?. ;
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
: biopsy ( skin mutation -- cell ) pairs>> probe ; 
M: +growth+ (mutate) [ biopsy ] [ (grow) ] bi ;
M: +growth+ (unmutate) [ biopsy ] [ (excise) ] bi drop ;
M: +excise+ (mutate) dupd [ biopsy ] [ (excise) ] bi defecate ;
                                                         ! TODO consider clamping pair probe to grid dims (currently probe to sheet level here as removed row/col may not exist anymore)
M: +excise+ (unmutate) [ drop organism>> waste>> pop ] [ pairs>> but-last probe ] [ nip (regrow) ] 2tri ;
M: +splice+ (mutate) dupd [ biopsy ] [ (splice) ] bi defecate ;
M: +splice+ (unmutate) [ drop organism>> waste>> pop ] [ biopsy ] [ nip (resplice) ] 2tri ;

: mutate ( mutation skin -- )
  [ [ store-dna ] ?undo/redo. ]
  [ swap (mutate) ] 2bi ;
: unmutate ( skin -- )
  [ [ restore-dna ] ?undo/redo. ]
  [ swap (unmutate) ] bi ;
: remutate ( skin -- )
  [ [ unrestore-dna ] ?undo/redo. ]
  [ swap (mutate) ] bi ;

: unmutate-once ( cell -- )
  [ skin? ] find-parent unmutate ;
: remutate-once ( cell -- )
  [ skin? ] find-parent remutate ;

: grow ( cell direction -- )
  '[ cell-coordinates _ mutations get 1 2array <growth> ]
  [ [ skin? ] find-parent mutate ] bi ;
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

: splice ( splicer -- )
  ! get surrounding cells based on splice direction and inference of quote
  ! set splicing cell as symbol for relative cell getting?
  [ splicing>> [ [ skin? ] find-parent ] [ cell-coordinates ] bi ]
  [ editor-string ]
  [ ?manifest?>> '[ [ [ read-quot dup ] [ ] produce nip [ ] concat-as ] _ (with-manifest) ] with-string-reader <splice> ]
  tri swap mutate ;

splicer "splicing" f {
  { T{ key-down f f "RET" } splice }
} define-command-map

