USING: interlinks ;
FROM: help.syntax.private => parse-help-text ;
IN: proteins

TUPLE: membrane-control < pane-control cell ;

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

TUPLE: wall < frame organism ;

GENERIC: synthesize ( protein -- )
: default-display ( seq -- )
  [ [ {
        { [ dup { [ membrane-control? ] [ wall? ] } 1|| ] [ "## " swap [ present append ] [ ] bi write-object nl ] }
        { [ dup gadget? ] [ gadget. ] }
        { [ dup gattaca? ] [ gattaca. ] }
        [ . ]
      } cond 
  ] each ] with-short-limits 
  ;
M: chain synthesize genes>> default-display ;
M: fold synthesize [ drains>> ] [ sources>> ] [ genes>> ] tri
                   [ with-datastack dup empty? [ 2drop ] ] keep
                   '[
                      _ default-display
                      [ [ ] curry <chain> swap cell>> model>> set-model ] 2each
                    ] if ;

