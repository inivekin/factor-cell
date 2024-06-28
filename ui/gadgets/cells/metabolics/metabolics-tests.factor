USING: accessors kernel make math math.matrices sequences
tools.test ui.gadgets ui.gadgets.cells ui.gadgets.cells.cellular
ui.gadgets.cells.metabolics ui.gadgets.cells.walls
ui.gadgets.editors vectors ;
IN: ui.gadgets.cells.metabolics-tests

: <test-colony-rightward> ( -- wall )
  [ { 0 0 } <default-cell> "1" over cell-genome set-editor-string
  , { 0 1 } <default-cell> "2" over cell-genome set-editor-string
  , { 0 2 } <default-cell> "+" over cell-genome set-editor-string
  ,
  ] V{ } make 1vector { 0 0 } <cell-wall> ; inline

: <test-colony-leftward> ( -- wall )
  [ { 0 0 } <default-cell> "+" over cell-genome set-editor-string
  , { 0 1 } <default-cell> "2" over cell-genome set-editor-string
  , { 0 2 } <default-cell> "1" over cell-genome set-editor-string
  ,
  ] V{ } make 1vector { 0 0 } <cell-wall> ; inline

: <test-colony-downward> ( -- wall )
  [ { 0 0 } <default-cell> "1" over cell-genome set-editor-string 1vector
  , { 1 0 } <default-cell> "2" over cell-genome set-editor-string 1vector
  , { 2 0 } <default-cell> "+" over cell-genome set-editor-string 1vector
  ,
  ] V{ } make { 0 0 } <cell-wall> ; inline

: <test-colony-upward> ( -- wall )
  [ { 0 0 } <default-cell> "+" over cell-genome set-editor-string 1vector
  , { 1 0 } <default-cell> "2" over cell-genome set-editor-string 1vector
  , { 2 0 } <default-cell> "1" over cell-genome set-editor-string 1vector
  ,
  ] V{ } make { 0 0 } <cell-wall> ; inline

{ [ + ] 2 1 } [ { 0 2 } <test-colony-rightward> cell-nth cell-genome identify-enzymes ] unit-test
{ [ 2 ] 0 1 } [ { 0 1 } <test-colony-rightward> cell-nth cell-genome identify-enzymes ] unit-test

! checking output cells get inserted if not existent
! { { V{ { 0 0 } { 0 1 } { 0 2 } { 0 3 } } } }
! [ <test-colony-rightward> 1 over grid>> first { 0 2 } [ (insert-cell-after) ] metabolic-output-cells grid>> [ pair>> ] map-cells ] unit-test

! getting stacks for evaluation/output
{
  V{ { 0 3 } }
  V{ { 0 0 } { 0 1 } }
  { 0 2 }
}
[ 2 1 { 0 2 } <test-colony-rightward> metabolic-pathway-rightward [ [ [ pair>> ] map ] bi@ ] dip pair>> ] unit-test

! evaluating stacks
{
  { 3 }
}
[ { 0 2 } <test-colony-rightward> [ cell-nth cell-genome identify-enzymes ] 2keep metabolic-pathway-rightward [ rot ] dip metabolize nip ] unit-test

{
  "1"
  "1"
}
[ { 0 0 } 1 <cells> [ cell-nth "1" over cell-genome set-editor-string metabolize-rightward ] 2keep [ [ col-after ] dip cell-nth cell-genome editor-string ] [ cell-nth cell-genome editor-string ] 2bi ] unit-test
{
  "1"
  "1"
}
[ { 0 0 } 1 <cells> [ cell-nth "1" over cell-genome set-editor-string metabolize-leftward ] 2keep [ [ col-after ] dip cell-nth cell-genome editor-string ] [ cell-nth cell-genome editor-string ] 2bi ] unit-test

! >
{
  "3"
}
[ { 0 2 } <test-colony-rightward> [ cell-nth metabolize-rightward ] 2keep [ col-after ] [ cell-nth cell-genome editor-string ] bi* ] unit-test

! <
{
  "1"
  "1"
}
[ { 0 0 } <test-colony-rightward> [ cell-nth metabolize-leftward ] 2keep [ [ col-after ] dip cell-nth cell-genome editor-string ] [ cell-nth cell-genome editor-string ] 2bi ] unit-test
{
  "3"
}
[ { 0 0 } <test-colony-leftward> [ cell-nth metabolize-leftward ] 2keep cell-nth cell-genome editor-string ] unit-test

! v
{
  "3"
}
[ { 2 0 } <test-colony-downward> [ cell-nth metabolize-downward ] 2keep [ row-below ] [ cell-nth cell-genome editor-string ] bi* ] unit-test

! v
{
  "3"
}
[ { 0 0 } <test-colony-upward> [ cell-nth metabolize-upward ] 2keep cell-nth cell-genome editor-string ] unit-test

