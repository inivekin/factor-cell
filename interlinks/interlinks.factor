USING: ascii io.streams.peek ;
IN: interlinks

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


: get-rel-cells ( cell pairs -- cells )
  [ [ parent>> grid>> ] [ cell-coordinates last ] bi ]
  [ [ v+ swap matrix-nth ] 2with map ] bi*
  ;

! SYMBOL: absorbing-cell
! 
! : get-cell-from-coords ( str -- obj )
!   2parse-cell-coords absorbing-cell get find-wall cell-nth ;
! 
! : get-cell-contents-from-coords ( str -- obj )
!   get-cell-from-coords absorb ;
! 
! : get-relative-cell-from-coords ( str -- obj )
!   2parse-cell-coords absorbing-cell get [ pair>> v+ ] [ find-wall ] bi cell-nth ;
! 
! : get-relative-cell-contents-from-coords ( str -- obj )
!   get-relative-cell-from-coords absorb ;


! can only be used within a cell
! SYNTAX: # scan-token get-cell-contents-from-coords suffix ;
! SYNTAX: ## scan-token get-cell-from-coords clone suffix ;
! SYNTAX: & scan-token get-relative-cell-contents-from-coords suffix ;
! SYNTAX: #& scan-token get-relative-cell-from-coords clone suffix ;
