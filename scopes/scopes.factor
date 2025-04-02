USING: ui.gadgets ui.gadgets.labels interlinks mutation ;
IN: scopes

: with-#scope ( gadget quot -- )
  [ [ membrane-control? ] find-parent absorbing-cell ] dip with-variable ; inline

DEFER: filescope
: (filescope) ( str pathname -- gadget )
  [ <label> ] [ absolute-path '[ [ [ _ filescope ] vertical #@ gene-expression ] with-#scope ] <roll-button> ] bi* ;

: filescope ( str -- presentations )
  [ current-directory get directory-files
        [ [ >pathname dup directory? ]
          [ -rot [ (filescope) ] [ nip absolute-path >pathname ] if ]
          bi
        ] map
  ] with-directory
  ;

: (freezerscope) ( button cell -- )
  '[ [ _ cell>> control-value genes>> call( -- ) ] vertical #@ gene-expression ] with-#scope ;

: freezerscope ( -- gadget )
  freezer get [ >alist ] <arrow> [ [ first2 [ <label> ] dip [ (freezerscope) ] curry <roll-button> gadget. ] each ] <pane-control> ;

