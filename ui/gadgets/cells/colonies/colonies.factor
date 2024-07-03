USING: io io.encodings.binary ;
IN: ui.gadgets.cells.colonies

: cell>file ( pathname cell -- )
  '[ _ object>bytes write ] binary swap with-file-writer ;

: file>cell ( pathname -- cell )
  binary file-contents bytes>object ;
