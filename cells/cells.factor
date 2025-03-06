USING: math.matrices ;
IN: cells

TUPLE: cell model ;

: <cells> ( n-rows m-cols quot: ( n m -- cell ) -- cells )
    <matrix-by-indices>
    ; inline
: <cell> ( obj -- cell )
    <model> cell boa ;

