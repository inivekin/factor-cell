USING: wall interlinks proteins splicer ;
IN: mutation

MIXIN: mutagen

GENERIC: (mutate) ( skin mutation -- )
GENERIC: (unmutate) ( skin mutation -- )

TUPLE: +growth+ pairs direction range ;
TUPLE: +excise+ pairs direction range ;
TUPLE: +splice+ pairs direction dna relative-cells-in relative-cells-out ;
TUPLE: +splint+ pairs range ;

INSTANCE: +growth+ mutagen
INSTANCE: +excise+ mutagen
INSTANCE: +splice+ mutagen
INSTANCE: +splint+ mutagen

INITIALIZED-SYMBOL: mutations [ 1 ]

C: <growth> +growth+
C: <excise> +excise+
C: <splice> +splice+
C: <splint> +splint+

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
    [ drop control-value ] ! FIXME should this be doing cell>> also???
    [ relative-cells-in>> get-rel-cells [ cell>> control-value genes>> ] map { } concat-as ]
    [ relative-cells-out>> get-rel-cells [ cell>> ] map ]
    [ swap [ dna>> swap <fold> ] [ cell>> model>> set-model ] bi* ]
  }
  2cleave ;
: (resplice) ( quot cell mutation -- )
  drop cell>> model>> set-model ;

: non-empty-matrix? ( x -- ? )
  { [ matrix? ] [ empty? not ] [ first empty? not ] } 1&&
  ;
: (splinter) ( cell -- replaced )
  [ cell-coordinate ] [ parent>> ] [
  cell>>
  control-value genes>> { } like ] tri
  {
    { [ dup non-empty-matrix? ] [ [ [ ] curry <chain> <cell> ] matrix-map <wall> -rot swapout ] }
    ! { [ dup tuple? ] [ [ <default-cell> ] tuple>cells ] }
    { [ dup { [ sequence? ] [ empty? not ] } 1&& ] [ 1array flip [ [ ] curry <chain> <cell> ] matrix-map <wall> -rot swapout ] }
    [ throw ]
  } cond
  ;
: (unsplinter) ( replaced replacer -- )
  [ cell-coordinate ] [ parent>> ] bi swapout drop
  ;

: ?. ( quot -- )
  [ get-listener output>> ] dip with-pane ; inline
: (?undo/redo.) ( skin -- )
  '[ _ organism>> [ \ undo>> . undo>> . ] [ \ redo>> . redo>> . ] [ \ waste>> . waste>> . ] tri ] ?. ;
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
M: +splint+ (mutate) dupd biopsy (splinter) defecate ;
M: +splint+ (unmutate) [ drop organism>> waste>> pop ] [ biopsy ] 2bi (unsplinter) ;

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
  find-skin unmutate ;
: remutate-once ( cell -- )
  find-skin remutate ;

: (grow?) ( sheet pair splice -- dimension direction range )
  dup direction>> '[ grid>> dimension { 1 1 } v- [ 1array ] [ _ swap ] bi ]
  [ ]
  [ relative-cells-out>> [ v+ ] with map ] tri*
  flip [ maximum ] map
  swap [v-]
  ;
: grow? ( mutation skin -- mutation/f )
  [ swap pairs>> unclip-last [ probe ] dip ]
  [ drop [ (grow?) ] [ [ pairs>> [ [ nip ] with change-last ] keep ] curry 2dip ] bi ]
  [ drop [ dup [ 0 = ] all? [ 3drop f ] ] dip direction>> '[ _ v+ <growth> ] if ] 2tri ;
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

: infer-relative-pairs ( quot -- ins outs )
  infer
  [ in>> length <iota> [ 1 + neg 0 2array ] map ]
  [ out>> length <iota> [ 1 + 0 2array ] map ] bi ;

: parse-splice ( str splicer -- quot )
  ?manifest?>> '[ [ [ read-quot dup ] [ ] produce nip [ ] concat-as ] _ (with-manifest) ] with-string-reader ;
: splice-below ( splicer -- )
  [ splicing>> [ find-skin ] [ cell-coordinates ] bi vertical ]
  [ editor-string ]
  [ parse-splice dup infer-relative-pairs <splice> ]
  tri swap [ [ grow? ] keep [ mutate ] curry when* ] [ mutate ] 2bi ;
: splice-after ( splicer -- )
  [ splicing>> [ find-skin ] [ cell-coordinates ] bi horizontal ]
  [ editor-string ]
  [ parse-splice dup infer-relative-pairs [ [ <reversed> ] map ] bi@ <splice> ]
  tri swap [ [ grow? ] keep [ mutate ] curry when* ] [ mutate ] 2bi ;

: splinter ( cell -- )
  [ cell-coordinates mutations get <splint> ] [ find-skin ] bi mutate ;

splicer "splicing" f {
  { T{ key-down f f "RET" } splice-below }
  { T{ key-down f { C+ } "RET" } splice-after }
} define-command-map

