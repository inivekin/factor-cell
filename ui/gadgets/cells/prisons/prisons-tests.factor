USING: ui.gadgets.cells.prisons ;
IN: ui.gadgets.cells.prisons-tests

{

}
[ 1 <cells> cell-nth imprison ] unit-test
! <amoeba> 2 [ { 0 0 } over cell-nth ] times dup cell-genome "1" swap set-editor-string imprison
