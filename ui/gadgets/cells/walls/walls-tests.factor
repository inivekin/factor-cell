USING: accessors kernel tools.test ui.gadgets ui.gadgets.cells
ui.gadgets.cells.cellular ui.gadgets.cells.walls ;
IN: ui.gadgets.cells.walls-tests

! remove row
{
  {
    { { 0 0 } { 0 1 } }
  }
}
[ { 1 0 } 2 <cells> [ cell-nth remove-row ] keep grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
  }
}
[ { 1 0 } 3 <cells> [ cell-nth remove-row ] keep grid>> [ pair>> ] map-cells ] unit-test

! remove column
{
  {
    { { 0 0 } }
    { { 1 0 } }
  }
}
[ { 1 0 } 2 <cells> [ cell-nth remove-col ] keep grid>> [ pair>> ] map-cells ] unit-test

{
  {
    { { 0 0 } { 0 1 } }
    { { 1 0 } { 1 1 } }
    { { 2 0 } { 2 1 } }
  }
}
[ { 1 0 } 3 <cells> [ cell-nth remove-col ] keep grid>> [ pair>> ] map-cells ] unit-test

! remove individual cells shifting up
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
  { 1 1 }
}
[ [ { 3 1 } <default-cell> suffix dup 1vector decrement-cols ] 3 <cells> grid>> flip { 1 1 } nondestructive-matrix-excise [ flip [ pair>> ] map-cells ] [ pair>> ] bi* ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
  { 1 1 }
}
[ [ { 3 1 } <default-cell> suffix dup 1vector decrement-cols ] { 1 1 } 3 <cells> grid>> excise-cell-from-col [ [ pair>> ] map-cells ] [ pair>> ] bi* ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
  { 0 0 }
}
[ { 0 0 } 3 <cells> [ [ <default-cell> ] cell-shifter-upward ] [ grid>> excise-cell-from-col ] 2bi [ [ pair>> ] map-cells ] [ pair>> ] bi* ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
  { 1 1 }
}
[ { 1 1 } 3 <cells> [ [ <default-cell> ] cell-shifter-upward ] [ grid>> excise-cell-from-col ] 2bi [ [ pair>> ] map-cells ] [ pair>> ] bi* ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
  { 1 2 }
}
[ { 1 2 } 3 <cells> [ [ <default-cell> ] cell-shifter-upward ] [ grid>> excise-cell-from-col ] 2bi [ [ pair>> ] map-cells ] [ pair>> ] bi* ] unit-test
! remove individual cells shifting left
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
  { 0 0 }
}
[ { 0 0 } 3 <cells> [ [ <default-cell> ] cell-shifter-leftward ] [ grid>> excise-cell-from-row ] 2bi [ [ pair>> ] map-cells ] [ pair>> ] bi* ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
  { 1 1 }
}
[ { 1 1 } 3 <cells> [ [ <default-cell> ] cell-shifter-leftward ] [ grid>> excise-cell-from-row ] 2bi [ [ pair>> ] map-cells ] [ pair>> ] bi* ] unit-test
{
  {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
  }
  { 1 2 }
}
[ { 1 2 } 3 <cells> [ [ <default-cell> ] cell-shifter-leftward ] [ grid>> excise-cell-from-row ] 2bi [ [ pair>> ] map-cells ] [ pair>> ] bi* ] unit-test


! 1 <cells> { 0 0 } over cell-nth cell-genome "link-color <solid>" swap set-editor-string
          ! { 0 0 } over cell-nth metabolize-downward
          ! { 1 0 } over cell-nth insert-cell-below ! FIXME this puts new cell in subcell, should parent>> out to find wall 
