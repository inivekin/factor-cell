USING: math sequences ui.gadgets.cells ;
IN: ui.gadgets.cells-tests

! creating new cells for an insert row-wise
{
  { { 0 0 } }
}
[ { 0 0 } 1 <cells> [ new-default-row ] create-cells-for-row-insert [ pair>> ] map ] unit-test

{
  { { 0 1 } { 1 2 } }
}
[ { 0 1 } 2 <cells> [ new-default-row ] create-cells-for-row-insert [ pair>> ] map ] unit-test

{
  { { 0 5 } { 1 5 } { 2 4 } { 3 5 } { 4 5 } }
}
[ { 2 4 } 5 <cells> [ new-default-row ] create-cells-for-row-insert [ pair>> ] map ] unit-test


! creating new cells for an insert column-wise
{
  { { 2 0 } { 1 1 } { 2 2 } }
}
[ { 0 1 } 2 <cells> cell-nth (insert-cell-after) find-wall { 1 1 } swap [ new-default-col ] create-cells-for-col-insert [ pair>> ] map ] unit-test

{
  { { 0 0 } }
}
[ { 0 0 } <reversed> 1 <cells> [ new-default-col ] create-cells-for-col-insert [ pair>> ] map ] unit-test

{
  { { 2 0 } { 0 1 } }
}
[ { 0 1 } <reversed> 2 <cells> [ new-default-col ] create-cells-for-col-insert [ pair>> ] map ] unit-test

{
  { { 5 0 } { 5 1 } { 5 2 } { 5 3 } { 2 4 } }
}
[ { 2 4 } <reversed> 5 <cells> [ new-default-col ] create-cells-for-col-insert [ pair>> ] map ] unit-test

! inserting new cells into a cell-wall row-wise by new cell each time
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } { 0 4 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth 4 [ (insert-cell-before) ] times find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } { 0 4 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth 4 [ (insert-cell-after) ] times find-wall grid>> [ pair>> ] map-cells ] unit-test

! inserting new cells into a cell-wall row-wise by same cell each time
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } { 0 4 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth dup 4 [ (insert-cell-before) drop ] with times find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } { 0 4 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth dup 4 [ (insert-cell-after) drop ] with times find-wall grid>> [ pair>> ] map-cells ] unit-test

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
[ { 0 0 } 1 <cells> cell-nth 4 [ (insert-cell-above) ] times find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } }
    { { 1 0 } }
    { { 2 0 } }
    { { 3 0 } }
    { { 4 0 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth 4 [ (insert-cell-below) ] times find-wall grid>> [ pair>> ] map-cells ] unit-test
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
[ { 0 0 } 1 <cells> cell-nth dup 4 [ (insert-cell-above) drop ] with times find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } }
    { { 1 0 } }
    { { 2 0 } }
    { { 3 0 } }
    { { 4 0 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth dup 4 [ (insert-cell-below) drop ] with times find-wall grid>> [ pair>> ] map-cells ] unit-test

! inserting cells from new cells in different directions
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth
  (insert-cell-below)
  (insert-cell-above)
  (insert-cell-before)
  (insert-cell-after)
  find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth
  (insert-cell-after)
  (insert-cell-before)
  (insert-cell-below)
  find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } }
    { { 1 0 } { 1 1 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth
  (insert-cell-below)
  (insert-cell-after)
  find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
    { { 2 0 } { 2 1 } { 2 2 } { 2 3 } }
    { { 3 0 } { 3 1 } { 3 2 } { 3 3 } }
  }
}
[ { 0 0 } 1 <cells> cell-nth
  3 [ (insert-cell-below) ] times
  3 [ (insert-cell-after) ] times
  find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  { { { 0 0 }
      { 0 1 } } }
}
[ { 0 0 } 1 <cells> cell-nth (insert-cell-before) find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  { { { 0 0 }
      { 0 1 } } }
}
[ { 0 0 } 1 <cells> cell-nth (insert-cell-after) find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  { { { 0 0 }
      { 0 1 }
      { 0 2 } } }
}
[ { 0 0 } 1 <cells> cell-nth (insert-cell-after) (insert-cell-after) find-wall grid>> [ pair>> ] map-cells ] unit-test
{
  { { { 0 0 } { 0 1 } }
    { { 1 0 } { 1 1 } } }
}
[ { 0 0 } 1 <cells> cell-nth (insert-cell-after) (insert-cell-below) find-wall grid>> [ pair>> ] map-cells ] unit-test

{
  { { { 0 0 } }
    { { 1 0 } } }
}
[ { 0 0 } 1 <cells> cell-nth (insert-cell-above) find-wall grid>> [ pair>> ] map-cells ] unit-test

! inserting a row into the grid
{
  { { { 0 0 } }
    { { 1 0 } } }
}
[ { 0 0 } 1 <cells> cell-nth [ insert-row-above ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
    { { 3 0 } { 3 1 } { 3 2 } }
  }
}
[ { 0 2 } 3 <cells> cell-nth [ insert-row-above ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
    { { 3 0 } { 3 1 } { 3 2 } }
  }
}
[ { 0 2 } 3 <cells> cell-nth [ insert-row-below ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test

! inserting a col into the grid
{
  { { { 0 0 } { 0 1 } } }
}
[ { 0 0 } 1 <cells> cell-nth [ insert-col-before ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
    { { 2 0 } { 2 1 } { 2 2 } { 2 3 } }
  }
}
[ { 0 2 } 3 <cells> cell-nth [ insert-col-before ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
    { { 2 0 } { 2 1 } { 2 2 } { 2 3 } }
  }
}
[ { 0 2 } 3 <cells> cell-nth [ insert-col-after ] [ find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test

! embedding cells into cell walls
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
}
[ { 1 0 } 3 <cells> cell-nth [ embed-cell ] [ find-wall parent>> find-wall ] bi grid>> [ pair>> ] map-cells ] unit-test

! focussing to cell outside of cell-wall
{
  { 0 1 }
}
[ 3 <cells> { 1 1 } swap cell-nth [ embed-cell ] keep [ pair>> row-above ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 1 0 }
}
[ 3 <cells> { 1 1 } swap cell-nth [ embed-cell ] keep [ pair>> col-before ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 1 2 }
}
[ 3 <cells> { 1 1 } swap cell-nth [ embed-cell ] keep [ pair>> col-after ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 2 1 }
}
[ 3 <cells> { 1 1 } swap cell-nth [ embed-cell ] keep [ pair>> row-below ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test

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
  { 1 0 }
}
[ { 1 0 } 3 <cells> cell-nth dup embed-cell [ pair>> col-before ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 1 2 }
}
[ { 1 2 } 3 <cells> cell-nth dup embed-cell [ pair>> col-after ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 0 1 }
}
[ { 0 1 } 3 <cells> cell-nth dup embed-cell [ pair>> row-above ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test
{
  { 2 1 }
}
[ { 2 1 } 3 <cells> cell-nth dup embed-cell [ pair>> row-below ] [ find-wall ] bi (get-relative-cell) pair>> ] unit-test

