! Copyright (C) 2024 Your name.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors grouping make sequences ui.gadgets.borders
ui.gadgets.editors ui.gadgets.scaling-editors
ui.gadgets.tree-cells ui.gadgets.tree-cells vectors ;
IN: ui.gadgets.cell-trees

: embed-grid ( -- gadget )
    [ { 0 0 } default-test-scaling-editor
    , { 0 1 } default-test-scaling-editor
    , { 0 2 } default-test-scaling-editor
    , { 0 3 } default-test-scaling-editor
    , ] V{ } make 1vector <treecell> { 0 1 } >>element-id
    ;

: test-grid ( -- gadget )
    [ { 0 0 } default-test-scaling-editor , embed-grid
    , { 1 0 } default-test-scaling-editor , { 1 1 } default-test-scaling-editor
    , ] V{ } make 2 <groups> V{ } like <treecell> ; inline

: <cell-tree> ( -- gadget )
    { 0 0 } default-test-scaling-editor 1vector 1vector <treecell> { 0 0 } >>element-id
    1vector 1vector <treecell> ;
