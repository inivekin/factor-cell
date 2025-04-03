USING: ui.gadgets ui.gadgets.labels interlinks mutation images.viewer.scaling ;
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

: ./ ( -- pathname ) current-directory get ;
: skill-gadget ( pathname -- gadget )
  [ absolute-path load-image <autoscaling-image-gadget> { 0.25 f } >>fill ] [ 4 head* <label> ] bi <labeled-gadget> ;
: ([skill-cell]) ( skill-gadget -- quot: ( cell in-paris out-pairs -- cells ) )
  '[ 3drop [ _ ] <chain> <cell> <membrane-control> 1array 1array ] ;
: [skill-cell] ( skill-gadgets -- quot: ( cell in-paris out-pairs -- cells ) )
  '[ [
    #@ cell-coordinates horizontal { 1 1 } _ random
    deep-clone ([skill-cell]) <growth>
    #@ find-skin mutate
  ] with-#scope ]
  ;
: skill-deck ( -- skillwall )
  "skills" <label> vertical <track> swap 1 track-add { 2 2 } <filled-border> dim-color 15 <rounded> >>interior
  P" ~/art/kotforn/img/skills/"
  [ ./ directory-files [ ".png" tail? ] filter [ skill-gadget ] map ] with-directory
  [skill-cell]
  <roll-button> ;

