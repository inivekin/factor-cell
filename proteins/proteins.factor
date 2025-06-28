USING: interlinks ui.gadgets.sheets ;
FROM: help.syntax.private => parse-help-text ;
IN: proteins

TUPLE: membrane-control < pane-control ;
TUPLE: membrane < border ;
TUPLE: wall < frame organism ;

MIXIN: probe-able

TUPLE: capture pairs dermis ;

GENERIC: capture-cell ( cell -- capture )
GENERIC: uncapture-cell ( capture -- cell )

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


: default-display ( obj -- )
  dup sequence? [
  [ [ {
        { [ dup capture? ] [ [ present ] [ ] bi write-object nl ] }
        { [ dup { [ membrane? ] [ wall? ] } 1|| ] [ capture-cell [ present ] [ ] bi write-object nl ] }
        { [ dup gadget? ] [ gadget. ] }
        { [ dup gattaca? ] [ gattaca. ] }
        [ . ]
      } cond 
  ] each ] with-short-limits
  ]
  [
     .
  ] if
  ;

: synthesize ( seq dna: ( seq -- seq  ) -- seq )
  [ [ dup capture? [ uncapture-cell ] when ] map ] bi@
  with-datastack ;

: synthesis ( models seq dna -- )
  [ dup empty? [ 2drop ] ] dip
  '[
     _ default-display
     [
       dup gadget?
       [ over gadget-child unparent add-gadget drop ] ! TODO also put gadget in model?
       [
         [ ] curry swap model>> set-model
       ] if
     ] 2each
   ] if  ;

: <membrane-control> ( model -- membrane )
  f membrane-control new-pane
  ! you're gonna need to curry that pane, son.
  dup [ parent>> absorbing-cell [ first2 unclip-last [ concat ] [ [ synthesize ] [ synthesis ] bi ] bi* ] with-variable ] curry >>quot
  swap >>model { 2 2 } >>gap ! 0.5 >>fill
  ; 

: <membrane-gadget> ( gadget dna: ( seq -- seq ) -- membrane )
  [ membrane new swap add-gadget { 2 2 } >>size { 1 1 } >>fill ] [ <model> >>model ] bi* ;
:: <membrane> ( enzymes ribozymes dna: ( seq -- seq ) -- membrane )
  ribozymes enzymes [ model>> ] map dna <model>
  [ suffix <product> [ 2array ] with <arrow> <membrane-control> ]
  [ [ membrane new swap add-gadget { 2 2 } >>size { 1 1 } >>fill ] dip >>model ] bi
  ;
: <membrane-data> ( data -- membrane )
  { } { } rot [ ] curry <membrane> ;
: <membrane-model> ( model -- membrane )
  membrane new { 2 2 } >>size { 1 1 } >>fill swap [ >>model ] [ [ [ gadget. ] each ] <arrow> <membrane-control> ] bi add-gadget ;
: (mitosis) ( cell -- new-cell )
    control-value clone { } { } rot <membrane> ;

INSTANCE: wall probe-able
INSTANCE: membrane probe-able

TUPLE: fold sources genes drains ;
TUPLE: chain genes ;

C: <fold> fold
C: <chain> chain

MIXIN: protein
INSTANCE: fold protein
INSTANCE: chain protein

