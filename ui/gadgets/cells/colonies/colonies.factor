USING: accessors arrays calendar combinators io
io.encodings.binary io.encodings.utf8 io.files io.streams.string
json kernel models.arrow models.delay present prettyprint
sequences strings ui ui.gadgets ui.gadgets.cells.alive
ui.gadgets.cells.cellular ui.gadgets.cells.dead
ui.gadgets.cells.prisons ui.gadgets.cells.walls
ui.gadgets.editors ui.gadgets.scrollers ;
IN: ui.gadgets.cells.colonies

: serialize-pane ( dead -- bytes )
  cell-membrane
      [ tuple>unfiltered-assoc dup [ f "parent" ] dip set-at 1 swap col [ clone ] map ] [ class-of ] bi slots>tuple object>bytes >base64 >string
  ;

: serialize-genome ( dead -- string )
  dup gadget-child dormant>> [ nip editor-string ] [ cell-genome editor-string ] if*
  ;
:: serialize-dead ( dead -- assoc )
  H{ } clone :> ser-dead dead [ serialize-genome "genome" ser-dead set-at ] [ serialize-pane "membrane" ser-dead set-at ] bi
  ser-dead ;

: serialize ( cell -- str )
  {
    { [ dup wall? ] [ grid>> [ [ serialize ] map ] map ] }
    { [ dup dead? ] [ serialize-genome ] }
    { [ dup alive? ] [ ref>> [ pprint ] with-string-writer  ] }
    { [ dup prison? ] [ gadget-text  ] }
    [ "unhandled type on serialization" throw ]
  } cond
  ; recursive

: backup-cell-file ( pathname -- )
  absolute-path dup [ now ".%y%m%d-%H%M%S" strftime print ] with-string-writer append but-last
  copy-file
  ;
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
  dup [ <amoeba> cell>file ] unless-file-exists
  [ file>cell ] keep [ present swap <scroller> swap open-window ] [ over [ model>> 10 seconds <delay> spin '[ _ [ backup-cell-file ] [ _ cell>file ] bi ] <arrow> ] [ model<< ] bi ] 2bi
  ;
