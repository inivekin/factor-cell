USING: interlinks ;
IN: proteins

TUPLE: membrane-control < pane-control cell ;

TUPLE: fold sources genes drains ;
TUPLE: chain genes ;

C: <fold> fold
C: <chain> chain

MIXIN: protein
INSTANCE: fold protein
INSTANCE: chain protein

GENERIC: synthesize ( protein -- )

M: chain synthesize genes>> [ [ dup gadget? [ gadget. ] [ . ] if  ] each ] with-short-limits ;
M: fold synthesize [ drains>> ] [ sources>> ] [ genes>> ] tri
                   [ with-datastack dup empty? [ 2drop ] ] keep
                   '[
                      _ [ dup gadget? [ gadget. ] [ . ] if ] each
                      [ [ ] curry <chain> swap cell>> model>> set-model ] 2each
                    ] if ;

