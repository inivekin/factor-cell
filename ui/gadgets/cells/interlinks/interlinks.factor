USING: ascii io.streams.peek namespaces ui.gadgets.cells.cellular ;
IN: ui.gadgets.cells.interlinks

: letter>coord ( ch -- n )
  CHAR: @ - ;

: digit>number ( ch -- n )
  48 - ;

: negate? ( -- ? )
  peek1 CHAR: - = ;

: get-number-coord ( -- n )
  negate? dup [ read1 drop ] when
  [ peek1 digit? ] [ read1 digit>number ] produce 0 [ swap 10 * + ] reduce
  swap [ neg ] when ;
: get-letter-coord ( -- n )
  negate? dup [ read1 drop ] when
  [ peek1 [ [ Letter? ] [ CHAR: @ = ] bi or ] [ f ] if* ] [ read1 dup CHAR: @ = [ drop 0 ] [ ch>upper letter>coord ] if ] produce 0 [ swap 27 * + ] reduce
  swap [ neg ] when ;

: 2parse-cell-coords ( str -- pair )
! check for preceding "^" upleveling or for each number/letter -ves
  [ input-stream get <peek-stream> [ get-number-coord get-letter-coord ] with-input-stream ] with-string-reader 2array ;

SYMBOL: absorbing-cell

: get-cell-from-coords ( str -- obj )
  2parse-cell-coords absorbing-cell get find-wall cell-nth ;

: get-cell-contents-from-coords ( str -- obj )
  get-cell-from-coords absorb ;

: get-relative-cell-from-coords ( str -- obj )
  2parse-cell-coords absorbing-cell get [ pair>> v+ ] [ find-wall ] bi cell-nth ;

: get-relative-cell-contents-from-coords ( str -- obj )
  get-relative-cell-from-coords absorb ;


! can only be used within a cell
SYNTAX: # scan-token get-cell-contents-from-coords suffix ;
SYNTAX: ## scan-token get-cell-from-coords clone suffix ;
SYNTAX: & scan-token get-relative-cell-contents-from-coords suffix ;
SYNTAX: && scan-token get-relative-cell-from-coords clone suffix ;
