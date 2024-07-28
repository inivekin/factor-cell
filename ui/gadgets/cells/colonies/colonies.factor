USING: accessors arrays calendar combinators io
io.encodings.binary io.encodings.utf8 io.files io.streams.string
json kernel models.arrow models.delay present prettyprint
sequences strings ui ui.gadgets ui.gadgets.cells.alive
ui.gadgets.cells.cellular ui.gadgets.cells.dead
ui.gadgets.cells.prisons ui.gadgets.cells.walls
ui.gadgets.editors ui.gadgets.scrollers ;
IN: ui.gadgets.cells.colonies

: serialize ( cell -- str )
  {
    { [ dup wall? ] [ grid>> [ [ serialize ] map ] map ] }
    { [ dup dead? ] [ gadget-text ] }
    { [ dup alive? ] [ ref>> [ pprint ] with-string-writer  ] }
    { [ dup prison? ] [ gadget-text  ] }
    [ "unhandled type on serialization" throw ]
  } cond
  ; recursive

: cell>file ( pathname cell -- )
  serialize [ >json write ] curry utf8 swap with-file-writer ;

DEFER: json-matrix>cells 
: (>cells) ( obj cell -- )
  {
    { [ over string? ] [ cell-genome set-editor-string ] }
    { [ over sequence? ] [ [ json-matrix>cells ] [ swap replace-cell ] bi* ] }
    [ "unhandled type on deserialization" throw ]
  } cond
  ;
: json-matrix>cells ( m -- wall )
  dup matrix-dim [ <iota> ] bi@ [ 2array <dead-cell> ] cartesian-map { 0 0 } <cell-wall> [ grid>> [ [ (>cells) ] 2each ] 2each ] keep 
  ;

: file>cell ( pathname -- cell )
  binary file-contents >string json> json-matrix>cells f >>pair ;

: open-colony ( pathname -- )
  [ file>cell ] keep [ present swap <scroller> swap open-window ] [ over [ model>> 10 seconds <delay> spin '[ _ _ cell>file ] <arrow> ] [ model<< ] bi ] 2bi
  ;
