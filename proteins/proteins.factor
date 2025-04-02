USING: interlinks ;
FROM: help.syntax.private => parse-help-text ;
IN: proteins

TUPLE: membrane-control < pane-control cell ;
TUPLE: wall < frame organism ;

MIXIN: probe-able

INSTANCE: membrane-control probe-able
INSTANCE: wall probe-able

GENERIC: capture-cell ( cell -- capture )
GENERIC: uncapture-cell ( capture -- cell )

TUPLE: capture pairs skin ;

TUPLE: fold sources genes drains ;
TUPLE: chain genes ;

C: <fold> fold
C: <chain> chain

MIXIN: protein
INSTANCE: fold protein
INSTANCE: chain protein

TUPLE: gattaca text style ;
C: <gattaca> gattaca
SYNTAX: ..: \ ; parse-help-text default-style get <gattaca> suffix ;
: gattaca. ( gattaca -- )
  [ text>> ] [ style>> ] bi [ print-element ] with-style ;
: .. ( element -- )
  {
    { [ dup gattaca? ] [ gattaca. ] }
    [ . ]
  } cond ;


GENERIC: synthesize ( protein -- )
: default-display ( seq -- )
  [ [ {
        { [ dup capture? ] [ [ present ] [ ] bi write-object nl ] }
        { [ dup { [ membrane-control? ] [ wall? ] } 1|| ] [ capture-cell [ present ] [ ] bi write-object nl ] }
        { [ dup gadget? ] [ gadget. ] }
        { [ dup gattaca? ] [ gattaca. ] }
        [ . ]
      } cond 
  ] each ] with-short-limits 
  ;
M: chain synthesize genes>> default-display ;
M: fold synthesize [ drains>> ] [ sources>> ] [ genes>> ] tri [ [ dup capture?  [ uncapture-cell ] when ] map ] bi@
                   [ with-datastack dup empty? [ 2drop ] ] keep
                   '[
                      _ default-display
                      [
                        dup { [ membrane-control? ] [ wall? ] } 1|| [ capture-cell [ ] curry ] [ [ ] curry ] if
                        <chain> swap cell>> model>> set-model ] 2each
                    ] if ;

