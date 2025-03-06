USING: ui.gadgets.frames ui.gadgets.grids ;
IN: ui.gadgets.sheets

: matrix-each-index ( matrix quot: ( ... elt i j -- ... ) -- )
    '[ [ swap @ ] curry each-index ] each-index ; inline

INITIALIZED-SYMBOL: cell-style [ f ]

MIXIN: sheet
INSTANCE: frame sheet
INSTANCE: grid sheet

GENERIC: insert-cell-rows ( cell cells sheet -- )
GENERIC: insert-cell-cols ( cell cells sheet -- )
! GENERIC: insert-cells-shift-rows ( cell filler: ( i j -- cell ) cells sheet -- )
GENERIC: insert-cells-shift-cols ( cell cells sheet -- )
GENERIC: remove-cell-rows ( cell cells sheet -- )
GENERIC: remove-cell-cols ( cell cells sheet -- )

GENERIC: cells-before ( n cell -- cell )

SYMBOL: focussed-coord
! pair is always { row col }, note grid/frame does { col row }
: cell-coordinate ( membrane-control -- pair/f )
  [ parent>> grid>> ]
  [ '[ rot _ = [ 2array ] [ 2drop f ] if ] matrix-map-index ] bi
  concat harvest ?last
  ;

: n-above ( pair n -- 'pair )
  '[ _ - ] over 0 spin change-nth ;
: n-below ( pair n -- 'pair )
  '[ _ + ] over 0 spin change-nth ;
: n-before ( pair n -- 'pair )
  '[ _ - ] over 1 spin change-nth ;
: n-after ( pair n -- 'pair )
  '[ _ + ] over 1 spin change-nth ;

: n-cells-away ( cell n quot: ( pair n -- 'pair ) -- cell )
  '[ cell-coordinate _ @ ] [ parent>> grid>> matrix-nth ] bi ; inline
: n-cell-above ( cell n -- cell )
  [ n-above ] n-cells-away ;
: n-cell-below ( cell n -- cell )
  [ n-below ] n-cells-away ;
: n-cell-before ( cell n -- cell )
  [ n-before ] n-cells-away ;
: n-cell-after ( cell n -- cell )
  [ n-after ] n-cells-away ;

: above/below ( matrix pair -- above below )
  first cut ;
: before/after ( matrix pair -- before after )
  [ flip ] [ second ] bi* cut ; 

: insert-rows ( pair cells sheet -- )
  [ grid>> pick above/below surround ]
  [ nip swap >>grid swap ]
  [ [ first dup ] [ dimension first over + ] [ grid>> <slice> ] tri* [ '[ _ + ] dip 2array grid-add ] with matrix-each-index drop ] 2tri
  ;
: insert-cols ( pair cells sheet -- )
  [ grid>> flip pick before/after surround flip ]
  [ nip swap >>grid swap ]
  [ [ second dup ] [ dimension second over + ] [ grid>> flip <slice> ] tri* [ + 2array grid-add ] with matrix-each-index drop ] 2tri
  ;
