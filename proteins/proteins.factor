USING: ;
IN: proteins

TUPLE: fold sources genes drains ;
TUPLE: chain genes ;

C: <fold> fold
C: <chain> chain

MIXIN: protein
INSTANCE: fold protein
INSTANCE: chain protein

GENERIC: synthesize ( protein -- )

M: chain synthesize genes>> [ [ . ] each ] with-short-limits ;
M: fold synthesize [ drains>> ] [ sources>> ] [ genes>> ] tri
                   [ with-datastack dup empty? [ 2drop ] ] keep '[ _ [ . ] each [ [ ] curry <chain> swap model>> set-model ] 2each ] if ;

