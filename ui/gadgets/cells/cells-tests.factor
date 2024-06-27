USING: math sequences ui.gadgets.cells ui.gadgets.cells.private ui.gadgets.cells.walls.private ;
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

! inserting a row into the grid
{
  { { { 0 0 } }
    { { 1 0 } } }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child [ insert-row-above ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
    { { 3 0 } { 3 1 } { 3 2 } }
  }
}
[ { 0 2 } 3 <cells> cell-nth gadget-child [ insert-row-above ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
    { { 3 0 } { 3 1 } { 3 2 } }
  }
}
[ { 0 2 } 3 <cells> cell-nth gadget-child [ insert-row-below ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test

! inserting a col into the grid
{
  { { { 0 0 } { 0 1 } } }
}
[ { 0 0 } 1 <cells> cell-nth gadget-child [ insert-col-before ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
    { { 2 0 } { 2 1 } { 2 2 } { 2 3 } }
  }
}
[ { 0 2 } 3 <cells> cell-nth gadget-child [ insert-col-before ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
    { { 2 0 } { 2 1 } { 2 2 } { 2 3 } }
  }
}
[ { 0 2 } 3 <cells> cell-nth gadget-child [ insert-col-after ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test

! embedding cells into cell walls
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
}
[ { 1 0 } 3 <cells> cell-nth gadget-child [ embed-cell-in-wall ] [ find-wall parent>> find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test

! focussing to cell outside of cell-wall
{
  { 0 1 }
}
[ 3 <cells> { 1 1 } swap cell-nth [ gadget-child embed-cell-in-wall ] keep [ pair>> row-above ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 1 0 }
}
[ 3 <cells> { 1 1 } swap cell-nth [ gadget-child embed-cell-in-wall ] keep [ pair>> col-before ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 1 2 }
}
[ 3 <cells> { 1 1 } swap cell-nth [ gadget-child embed-cell-in-wall ] keep [ pair>> col-after ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 2 1 }
}
[ 3 <cells> { 1 1 } swap cell-nth [ gadget-child embed-cell-in-wall ] keep [ pair>> row-below ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test

! focussing limit to wall with no parent
{
  { 0 1 }
}
[ 3 <cells> { 0 1 } swap [ cell-nth ] keep [ pair>> row-above ] [ find-wall ] bi* (get-relative-cell) pair>> ] unit-test
{
  { 2 1 }
}
[ 3 <cells> { 2 1 } swap [ cell-nth ] keep [ pair>> row-below ] [ find-wall ] bi* (get-relative-cell) pair>> ] unit-test
{
  { 1 0 }
}
[ 3 <cells> { 1 0 } swap [ cell-nth ] keep [ pair>> col-before ] [ find-wall ] bi* (get-relative-cell) pair>> ] unit-test
{
  { 1 2 }
}
[ 3 <cells> { 1 2 } swap [ cell-nth ] keep [ pair>> col-after ] [ find-wall ] bi* (get-relative-cell) pair>> ] unit-test

! focussing limit from embedded cell at edge of cell wall
{
  { 0 0 }
}
[ { 1 0 } 3 <cells> cell-nth dup gadget-child embed-cell-in-wall [ pair>> col-before ] [ find-wall ] bi (get-relative-cell) gadget-child pair>> ] unit-test
{
  { 0 0 }
}
[ { 1 2 } 3 <cells> cell-nth dup gadget-child embed-cell-in-wall [ pair>> col-after ] [ find-wall ] bi (get-relative-cell) gadget-child pair>> ] unit-test
{
  { 0 0 }
}
[ { 0 1 } 3 <cells> cell-nth dup gadget-child embed-cell-in-wall [ pair>> row-above ] [ find-wall ] bi (get-relative-cell) gadget-child pair>> ] unit-test
{
  { 0 0 }
}
[ { 2 1 } 3 <cells> cell-nth dup gadget-child embed-cell-in-wall [ pair>> row-below ] [ find-wall ] bi (get-relative-cell) gadget-child pair>> ] unit-test
