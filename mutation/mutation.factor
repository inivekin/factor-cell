USING: wall ;
IN: mutation

SINGLETONS: +growth+ +excise+ +splice+ absorb explode collapse ;
TUPLE: mutation
    pairs
    direction
    range
    type
    state
    ;
INITIALIZED-SYMBOL: mutations [ 1 ]

C: <mutation> mutation

: <growth> ( pairs direction range -- mutation )
  +growth+ f <mutation> ;

: <excise> ( pairs direction range -- mutation )
  +excise+ f <mutation> ;

: <splice> ( pairs state -- mutation )
  +splice+ swap [ f f ] 2dip <mutation> ;

: (ungrow) ( mutation cells skin -- )
  swapd '[ pairs>> unclip [ _ swap probe ] [ ] bi* swap ] [ direction>> ] bi {
    { vertical [ insert-after ] }
    { horizontal [ insert-below ] }
    [ throw ]
  } case ;
: (grow) ( mutation cell -- )
  swap [ pairs>> last ] [ range>> over v+ ] [ direction>> ] tri {
    { vertical [ insert-below ] }
    { horizontal [ insert-after ] }
    [ throw ]
  } case ;
: (excise) ( mutation cell -- excised )
  swap [ range>> ] [ direction>> ] bi {
    { vertical [ second remove-below ] }
    { horizontal [ first remove-after ] }
    [ throw ]
  } case ;

: (splice) ( mutation cell -- replaced )
  [ control-value ]
  [ swapd [ state>> ] dip cell>> model>> set-model ]
  bi ;

: new-dna-branch? ( organism -- ? )
  [ undo>> ] [ redo>> ] bi [ dimension second ] bi@ = ;
: store-dna ( mutation organism -- )
  organism>>
  [ [ new-dna-branch? ] [ undo>> empty? not ] bi and ]
  [ undo>> [ last push ] [ swap 1vector swap push ] bi-curry if ] bi ;

: restore-dna ( organism -- mutation )
  organism>>
  [ undo>> pop ]
  [ [ redo>> push ] curry [ last ] bi ] bi ;

: unrestore-dna ( organism -- mutation )
  organism>>
  [ redo>> pop ]
  [ [ undo>> push ] curry [ last ] bi ] bi ;

: (unmutate) ( mutation skin -- )
  over type>> {
    { +growth+ [ over pairs>> probe (excise) drop ] }
    { +excise+ [ [ organism>> waste>> pop ] [ (ungrow) ] bi ] }
    [ [ . ] with-string-writer "not implemented: " prepend throw ]
  } case ;

: (mutate) ( mutation skin -- )
  over type>> {
    { +growth+ [ over pairs>> probe (grow) ] }
    { +excise+ [ [ over pairs>> probe (excise) ] keep organism>> waste>> push ] }
    { +splice+ [ [ over pairs>> probe (splice) ] keep organism>> waste>> push ] }
    [ [ . ] with-string-writer "not implemented: " prepend throw ]
  } case ;
: mutate ( mutation skin -- )
  [ store-dna ]
  [ (mutate) ] 2bi ;
: unmutate ( skin -- )
  [ restore-dna ]
  [ (unmutate) ] bi ;
: remutate ( skin -- )
  [ unrestore-dna ]
  [ (mutate) ] bi ;

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
  { { vertical [ first mutations get ] } { horizontal [ second mutations get swap ] } [ throw ] } case 2array
  '[ cell-coordinates _ _ <excise> ]
  [ [ skin? ] find-parent mutate ] bi ;
: excise-below ( cell -- )
  vertical excise ;
: excise-after ( cell -- )
  horizontal excise ;

: splice ( splicer -- )
  [ splicing>> [ [ skin? ] find-parent ] [ cell-coordinates ] bi ]
  [ editor-string [ [ read-quot ] with-interactive-vocabs ] with-string-reader <splice> ] bi swap mutate ;
  
