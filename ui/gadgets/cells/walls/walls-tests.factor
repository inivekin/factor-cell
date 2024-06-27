USING: accessors kernel tools.test ui.gadgets ui.gadgets.cells
ui.gadgets.cells.cellular ui.gadgets.cells.walls
ui.gadgets.cells.walls.private ;
IN: ui.gadgets.cells.walls-tests

{
  {
    { { 0 0 } { 0 1 } }
  }
}
[ { 1 0 } 2 <cells> [ cell-nth gadget-child remove-row ] keep grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
  }
}
[ { 1 0 } 3 <cells> [ cell-nth gadget-child remove-row ] keep grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } }
    { { 1 0 } }
  }
}
[ { 1 0 } 2 <cells> [ cell-nth gadget-child remove-col ] keep grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } { 0 1 } }
    { { 1 0 } { 1 1 } }
    { { 2 0 } { 2 1 } }
  }
}
[ { 1 0 } 3 <cells> [ cell-nth gadget-child remove-col ] keep grid>> [ pair>> ] map-cells ] unit-test
