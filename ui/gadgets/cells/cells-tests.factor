USING: math sequences ui.gadgets.cells ui.gadgets.cells.walls.private ;
IN: ui.gadgets.cells-tests

! creating new cells for an insert row-wise
{
  { { 0 0 } }
}
[ { 0 0 } 1 <cells> [ new-default-row ] create-cells-for-row-insert [ gadget-child pair>> ] map ] unit-test

{
  { { 0 1 } { 1 2 } }
}
[ { 0 1 } 2 <cells> [ new-default-row ] create-cells-for-row-insert [ gadget-child pair>> ] map ] unit-test

{
  { { 0 5 } { 1 5 } { 2 4 } { 3 5 } { 4 5 } }
}
[ { 2 4 } 5 <cells> [ new-default-row ] create-cells-for-row-insert [ gadget-child pair>> ] map ] unit-test


! creating new cells for an insert column-wise
{
  { { 2 0 } { 1 1 } { 2 2 } }
}
[ { 0 1 } 2 <cells> cell-nth gadget-child (insert-cell-after) find-wall { 1 1 } swap [ new-default-col ] create-cells-for-col-insert [ gadget-child pair>> ] map ] unit-test

{
  { { 0 0 } }
}
[ { 0 0 } <reversed> 1 <cells> [ new-default-col ] create-cells-for-col-insert [ gadget-child pair>> ] map ] unit-test

{
  { { 2 0 } { 0 1 } }
}
[ { 0 1 } <reversed> 2 <cells> [ new-default-col ] create-cells-for-col-insert [ gadget-child pair>> ] map ] unit-test

{
  { { 5 0 } { 5 1 } { 5 2 } { 5 3 } { 2 4 } }
}
[ { 2 4 } <reversed> 5 <cells> [ new-default-col ] create-cells-for-col-insert [ gadget-child pair>> ] map ] unit-test

! inserting new cells into a cell-wall row-wise by new cell each time
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } { 0 4 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child 4 [ (insert-cell-before) gadget-child ] times find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } { 0 4 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child 4 [ (insert-cell-after) gadget-child ] times find-wall grid>> [ pair>> ] map-cells ] unit-test

! inserting new cells into a cell-wall row-wise by same cell each time
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } { 0 4 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child dup 4 [ (insert-cell-before) drop ] with times find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } { 0 4 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child dup 4 [ (insert-cell-after) drop ] with times find-wall grid>> [ pair>> ] map-cells ] unit-test

! inserting new cells into a cell-wall column-wise
{
  {
    { { 0 0 } }
    { { 1 0 } }
    { { 2 0 } }
    { { 3 0 } }
    { { 4 0 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child 4 [ (insert-cell-above) gadget-child ] times find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } }
    { { 1 0 } }
    { { 2 0 } }
    { { 3 0 } }
    { { 4 0 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child 4 [ (insert-cell-below) gadget-child ] times find-wall grid>> [ pair>> ] map-cells ] unit-test
! inserting new cells into a cell-wall column-wise by same cell each time
{
  {
    { { 0 0 } }
    { { 1 0 } }
    { { 2 0 } }
    { { 3 0 } }
    { { 4 0 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child dup 4 [ (insert-cell-above) drop ] with times find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } }
    { { 1 0 } }
    { { 2 0 } }
    { { 3 0 } }
    { { 4 0 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child dup 4 [ (insert-cell-below) drop ] with times find-wall grid>> [ pair>> ] map-cells ] unit-test

! inserting cells from new cells in different directions
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child
  (insert-cell-below) gadget-child
  (insert-cell-above) gadget-child
  (insert-cell-before) gadget-child
  (insert-cell-after) gadget-child
  find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child
  (insert-cell-after) gadget-child
  (insert-cell-before) gadget-child
  (insert-cell-below) gadget-child
  find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } }
    { { 1 0 } { 1 1 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child
  (insert-cell-below) gadget-child
  (insert-cell-after) gadget-child
  find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
    { { 2 0 } { 2 1 } { 2 2 } { 2 3 } }
    { { 3 0 } { 3 1 } { 3 2 } { 3 3 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child
  3 [ (insert-cell-below) gadget-child ] times
  3 [ (insert-cell-after) gadget-child ] times
  find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  { { { 0 0 }
      { 0 1 } } }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child (insert-cell-before) find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  { { { 0 0 }
      { 0 1 } } }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child (insert-cell-after) find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  { { { 0 0 }
      { 0 1 }
      { 0 2 } } }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child (insert-cell-after) gadget-child (insert-cell-after) find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  { { { 0 0 } { 0 1 } }
    { { 1 0 } { 1 1 } } }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child (insert-cell-after) gadget-child (insert-cell-below) find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  { { { 0 0 } }
    { { 1 0 } } }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child (insert-cell-above) find-wall grid>> [ pair>> ] map-cells ] unit-test
