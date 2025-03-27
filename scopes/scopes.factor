USING: ui.gadgets ui.gadgets.labels interlinks mutation ;
IN: scopes

DEFER: filescope
: (filescope) ( str pathname -- gadget )
  [ <label> ] [ absolute-path '[ [ membrane-control? ] find-parent absorbing-cell [ [ _ filescope ] horizontal #@ splice ] with-variable ] <roll-button> ] bi* ;
: filescope ( str -- presentations )
  [ current-directory get directory-files [ [ >pathname dup directory? ] [ -rot [ (filescope) ] [ drop ] if ] bi ] map ] with-directory
  ;
