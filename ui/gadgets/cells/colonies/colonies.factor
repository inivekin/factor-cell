USING: accessors arrays assocs calendar combinators formatting
io io.directories io.encodings.binary io.encodings.utf8 io.files
io.pathnames io.streams.string json json.prettyprint kernel models.arrow
models.delay present prettyprint sequences serialize strings ui
ui.gadgets ui.gadgets.cells ui.gadgets.cells.alive
ui.gadgets.cells.cellular ui.gadgets.cells.dead
ui.gadgets.cells.prisons ui.gadgets.cells.walls
ui.gadgets.editors ui.gadgets.scrollers ;
IN: ui.gadgets.cells.colonies

: serialize-pane ( dead -- bytes )
  cell-membrane
  clone dup unparent object>bytes
      ! [ tuple>unfiltered-assoc dup [ f "parent" ] dip set-at 1 swap col [ clone ] map ] [ class-of ] bi slots>tuple object>bytes >base64 >string
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
  serialize [ pprint-json ] curry utf8 swap with-file-writer ;

DEFER: json-matrix>cells 
: (>cells) ( obj cell -- )
  {
    { [ over string? ] [ cell-genome set-editor-string ] }
    { [ over sequence? ] [ [ json-matrix>cells ] [ swap replace-cell ] bi* ] }
    [ "unhandled type on deserialization" throw ]
  } cond
  ;

: startup-connect-cells ( wall -- )
  dup grid>> swap '[ [ _ swap dup dead? [ 1array swap add-cell-wall-connections ] [ nip dup wall? [ startup-connect-cells ] [ drop ] if ] if ] each ] each
  ; recursive

: json-matrix>cells ( m -- wall )
  dup matrix-dim [ <iota> ] bi@ [ 2array <dead-cell> ] cartesian-map { 0 0 } <cell-wall>
  [ grid>> [ [ (>cells) ] 2each ] 2each ] keep 
  [ startup-connect-cells ] keep 
  ;

: startup-metabolize ( wall -- )
  {
    { [ dup wall? ] [ grid>> [ [ startup-metabolize ] each ] each ] } 
    { [ dup dead? ] [ dup cell-genome editor-string "gadget." tail? [ [ metabolize-downward ] [ toggle-editor ] bi ] [ drop ] if ] } 
    [ drop ]
  } cond ; recursive

: file>cell ( pathname -- cell )
  binary file-contents >string json> json-matrix>cells f >>pair
  dup grid>> [ [ startup-metabolize ] each ] each
  ;

: open-colony ( pathname -- )
  dup [ <amoeba> cell>file ] unless-file-exists
  [ file>cell ] keep [ present swap <scroller> white-interior swap open-window ] [ over [ model>> 10 seconds <delay> spin '[ _ [ backup-cell-file ] [ _ cell>file ] bi ] <arrow> ] [ model<< ] bi ] 2bi
  ;
