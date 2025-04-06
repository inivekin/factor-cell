USING: interlinks ui.gadgets.sheets ;
FROM: help.syntax.private => parse-help-text ;
IN: proteins

TUPLE: membrane-control < pane-control ;
TUPLE: membrane < border ;
TUPLE: wall < frame organism ;

MIXIN: probe-able

: <membrane> ( gadget -- membrane )
  [ membrane new-border { 2 2 } >>size { 1 1 } >>fill ] [ model>> >>model ] bi ;

INSTANCE: membrane-control probe-able
INSTANCE: wall probe-able
INSTANCE: membrane probe-able

GENERIC: capture-cell ( cell -- capture )
GENERIC: uncapture-cell ( capture -- cell )

TUPLE: capture pairs dermis ;

TUPLE: fold sources genes drains ;
TUPLE: chain genes ;

C: <fold> fold
C: <chain> chain

MIXIN: protein
INSTANCE: fold protein
INSTANCE: chain protein

TUPLE: gattaca text style ;
C: <gattaca> gattaca
: gattaca. ( gattaca -- )
  [ text>> ] [ style>> ] bi [ print-element ] with-style ;
: (..) ( element -- )
  {
    { [ dup gattaca? ] [ gattaca. ] }
    [ . ]
  } cond ;
SYNTAX: .. \ ; parse-help-text default-style get <gattaca> suffix ;


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
! use model>> instead of genes>> so that you can put normal gadgets in, treat them as normal cells, give base gadget some cell things
M: chain synthesize genes>> default-display ;
M: fold synthesize [ drains>> ] [ sources>> [ control-value genes>> ] map concat ] [ genes>> ] tri [ [ dup capture? [ uncapture-cell ] when ] map ] bi@
                   [ with-datastack dup empty? [ 2drop ] ] keep
                   '[
                      _ default-display
                      [
                        {
                              { [ dup { [ membrane-control? ] [ wall? ] } 1|| ] [ capture-cell [ ] curry <chain> swap model>> set-model ] }
                              { [ dup gadget? ] [ <membrane> swap [ cell-coordinate ] [ parent>> ] bi swapout drop ] }
                              [ [ ] curry <chain> swap model>> set-model ]
                        } cond
                         ] 2each
                    ] if ;

