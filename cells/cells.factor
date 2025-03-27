USING: math.matrices ;
IN: cells

TUPLE: cell model ;

: <cells> ( n-rows m-cols quot: ( n m -- cell ) -- cells )
    <matrix-by-indices>
    ; inline
: <cell> ( obj -- cell )
    <model> cell boa ;

: (mitosis) ( cell -- new-cell )
    control-value clone <cell> ;

: tuple>unfiltered-assoc ( obj -- assoc )
  [ class-of all-slots ] [ tuple-slots ] bi zip [ [ name>> ] dip ] assoc-map ;
: tuple>matrix ( obj -- matrix )
  [ class-of 1array ]
  [ tuple>unfiltered-assoc 1array ]
  bi 2array
  ;

