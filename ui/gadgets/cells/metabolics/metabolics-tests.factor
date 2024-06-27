USING: accessors kernel make math math.matrices sequences
tools.test ui.gadgets ui.gadgets.cells ui.gadgets.cells.cellular
ui.gadgets.cells.metabolics ui.gadgets.cells.private
ui.gadgets.cells.walls ui.gadgets.cells.walls.private
ui.gadgets.editors vectors ;
IN: ui.gadgets.cells.metabolics-tests

: <test-colony-rightward> ( -- wall )
  [ { 0 0 } <default-cell> "1" over gadget-child gadget-child set-editor-string
  , { 0 1 } <default-cell> "2" over gadget-child gadget-child set-editor-string
  , { 0 2 } <default-cell> "+" over gadget-child gadget-child set-editor-string
  ,
  ] V{ } make 1vector { 0 0 } <cell-wall> ; inline

: <test-colony-leftward> ( -- wall )
  [ { 0 0 } <default-cell> "+" over gadget-child gadget-child set-editor-string
  , { 0 1 } <default-cell> "2" over gadget-child gadget-child set-editor-string
  , { 0 2 } <default-cell> "1" over gadget-child gadget-child set-editor-string
  ,
  ] V{ } make 1vector { 0 0 } <cell-wall> ; inline

: <test-colony-downward> ( -- wall )
  [ { 0 0 } <default-cell> "1" over gadget-child gadget-child set-editor-string 1vector
  , { 1 0 } <default-cell> "2" over gadget-child gadget-child set-editor-string 1vector
  , { 2 0 } <default-cell> "+" over gadget-child gadget-child set-editor-string 1vector
  ,
  ] V{ } make { 0 0 } <cell-wall> ; inline

: <test-colony-upward> ( -- wall )
  [ { 0 0 } <default-cell> "+" over gadget-child gadget-child set-editor-string 1vector
  , { 1 0 } <default-cell> "2" over gadget-child gadget-child set-editor-string 1vector
  , { 2 0 } <default-cell> "1" over gadget-child gadget-child set-editor-string 1vector
  ,
  ] V{ } make { 0 0 } <cell-wall> ; inline

{ [ + ] 2 1 } [ { 0 2 } <test-colony-rightward> cell-nth gadget-child identify-enzymes ] unit-test
{ [ 2 ] 0 1 } [ { 0 1 } <test-colony-rightward> cell-nth gadget-child identify-enzymes ] unit-test

! checking output cells get inserted if not existent
{ { V{ { 0 0 } { 0 1 } { 0 2 } { 0 3 } } } }
[ <test-colony-rightward> 1 over grid>> first { 0 2 } [ (insert-cell-after) ] metabolic-output-cells grid>> [ pair>> ] map-cells ] unit-test

! getting stacks for evaluation/output
{
  V{ { 0 3 } }
  V{ { 0 0 } { 0 1 } }
  { 0 2 }
}
[ 2 1 { 0 2 } <test-colony-rightward> metabolic-pathway-rightward [ [ [ gadget-child pair>> ] map ] bi@ ] dip gadget-child pair>> ] unit-test

! evaluating stacks
{
  { 3 }
}
[ { 0 2 } <test-colony-rightward> [ cell-nth gadget-child identify-enzymes ] 2keep metabolic-pathway-rightward [ rot ] dip metabolize nip ] unit-test

{
  "1"
  "1"
}
[ { 0 0 } 1 <cells> [ cell-nth gadget-child "1" over set-editor-string metabolize-rightward ] 2keep [ [ col-after ] dip cell-nth gadget-child editor-string ] [ cell-nth gadget-child editor-string ] 2bi ] unit-test
{
  "1"
  "1"
}
[ { 0 0 } 1 <cells> [ cell-nth gadget-child "1" over set-editor-string metabolize-leftward ] 2keep [ [ col-after ] dip cell-nth gadget-child editor-string ] [ cell-nth gadget-child editor-string ] 2bi ] unit-test

! >
{
  "3"
}
[ { 0 2 } <test-colony-rightward> [ cell-nth gadget-child metabolize-rightward ] 2keep [ col-after ] [ cell-nth gadget-child editor-string ] bi* ] unit-test

! <
{
  "1"
  "1"
}
[ { 0 0 } <test-colony-rightward> [ cell-nth gadget-child metabolize-leftward ] 2keep [ [ col-after ] dip cell-nth gadget-child editor-string ] [ cell-nth gadget-child editor-string ] 2bi ] unit-test
{
  "3"
}
[ { 0 0 } <test-colony-leftward> [ cell-nth gadget-child metabolize-leftward ] 2keep cell-nth gadget-child editor-string ] unit-test

! v
{
  "3"
}
[ { 2 0 } <test-colony-downward> [ cell-nth gadget-child metabolize-downward ] 2keep [ row-below ] [ cell-nth gadget-child editor-string ] bi* ] unit-test

! v
{
  "3"
}
[ { 0 0 } <test-colony-upward> [ cell-nth gadget-child metabolize-upward ] 2keep cell-nth gadget-child editor-string ] unit-test

