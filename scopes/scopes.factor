USING: ui.gadgets ui.gadgets.labels interlinks mutation ;
IN: scopes

DEFER: filescope
: (filescope) ( str pathname -- gadget )
  [ <label> ] [ absolute-path '[ [ membrane-control? ] find-parent absorbing-cell [ [ _ filescope ] vertical #@ splice ] with-variable ] <roll-button> ] bi* ;
  ! [ <label> ] [  [ <presentation> ] [ absolute-path '[ [ membrane-control? ] find-parent absorbing-cell [ [ _ filescope ] horizontal #@ splice ] with-variable ] >>hook ] bi ] bi* ;

: filescope ( str -- presentations )
  [ current-directory get directory-files
        [ [ >pathname dup directory? ]
          [ -rot [ (filescope) ] [ nip absolute-path >pathname ] if ]
          bi
        ] map
  ] with-directory
  ;

! : freezerscope ( -- )
!   freezer get [ ] <arrow> <cell> <membrane-control> "freezerscope" freezer get [ set-at ] change-model* ;

: (skilldeck) ( -- gadgets )
  P" ~/art/kotforn/img/skills/" [ current-directory get directory-files sort [ ".png" tail? ] filter [ >pathname ] map
                                  [ [ absolute-path ] map
                                    [ load-image <autoscaling-image-gadget> { 0.25 f } >>fill ] map
                                  ]
                                  [ [ string>> ] map ] bi [ <labeled-gadget> ] 2map
  ] with-directory ;
: skilldeck. ( -- )
  "skill deck" <label> { 2 2 } <filled-border> menu-border-color 15 <rounded> >>interior
  (skilldeck) '[ [ membrane-control? ] find-parent absorbing-cell [ _ random [ gadget. ] curry horizontal #@ [ parent>> grid>> ] [ cell-coordinate ] bi { 0 1 } get-rel-cell splice ] with-variable ] <roll-button>
  gadget. ;
