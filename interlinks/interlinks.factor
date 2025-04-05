USING: ascii io.streams.peek namespaces ui.gadgets.sheets ;
IN: interlinks

SYMBOL: absorbing-cell

: letter>coord ( ch -- n )
  CHAR: @ - ;

: digit>number ( ch -- n )
  48 - ;

: negate? ( peek -- ? )
  CHAR: - = ;

: parse-number-coord ( n -- x next/f )
  [ dup dup [ digit? ] when ] [ digit>number [ read1 ] dip ] produce 0 [ swap 10 * + ] reduce swap ;
: parse-letter-coord ( n -- x next/f )
  [ dup [ [ Letter? ] [ CHAR: @ = ] bi or ] [ f ] if* ] [ dup CHAR: @ = [ ch>upper ] unless letter>coord [ read1 ] dip ] produce 0 [ swap 27 * + ] reduce swap ;

: (>letter-coord) ( n -- a )
  CHAR: @ + ;
: >letter-coord ( num radix -- str )
  over 
  [ 2drop "@" ] [
  drop dup 1 <= [ invalid-radix ] when [ dup 0 > ] swap
  [ /mod (>letter-coord) ] curry "" produce-as nip reverse! ] if-zero ;
: number>letter-coord ( n -- str )
  [ abs 27 >letter-coord ] [ neg? [ "-" prepend ] when ] bi ;
: and-negate? ( quot: ( n -- x next/f ) -- x next/f )
  [ dup negate? [ drop read1 ] when ] prepose [ negate? [ [ neg ] when ] curry dip ] bi ; inline

: parse-cell-coords ( str -- pairs )
! check for preceding "^" upleveling or for each number/letter -ves
  [ V{ } clone read1
      [ [ parse-number-coord ] and-negate? [ parse-letter-coord ] and-negate? [ 2array suffix ] dip dup ] loop drop
  ] with-string-reader ;

: make-cell-coords ( pairs -- str )
  [ first2 [ number>string ] [ number>letter-coord ] bi* append ] map "" join ;

: set-absorbing-cell ( cell -- )
  absorbing-cell set ;

: get-rel-cell ( wall ref-pair rel-pair -- cell )
  v+ swap matrix-nth ;
: get-rel-cells ( cell pairs -- cells )
  [ [ parent>> grid>> ] [ cell-coordinate ] bi ]
  [ [ get-rel-cell ] 2with map ] bi*
  ;

: #@ ( -- cell ) absorbing-cell get ;
SYNTAX: #&& #@ [ parent>> grid>> ] [ cell-coordinate ] bi scan-token parse-cell-coords last get-rel-cell suffix ;
