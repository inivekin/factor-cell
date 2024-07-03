USING: accessors classes combinators fonts io.streams.string
kernel make math.parser prettyprint sequences ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.buttons.private ui.gadgets.cells.cellular ui.gadgets.cells.dead
ui.gadgets.cells.metabolics ui.gadgets.cells.walls
ui.gadgets.editors ui.gadgets.grids ui.gestures ui.pens.solid
ui.theme ;
IN: ui.gadgets.cells.prisons

TUPLE: prison < button pair bunk ;

M: prison absorb bunk>> absorb ; recursive

: prison-window ( str -- str' )
  "~[" "]" surround ;
: wall-sentencing ( wall -- str )
  [ { 0 0 } swap cell-nth class-of [ pprint-short ] with-string-writer ]
  [ grid>> matrix-dim [ number>string ] bi@ ":" glue " " glue ] bi
  prison-window ;
: dead-sentencing ( dead -- str )
  gadget-child gadget-child editor-string [ pprint-short ] with-string-writer
  prison-window ;
! TODO this should bo a cell mixin generic?
: prison-sentence ( cell -- str )
  {
    { [ dup wall? ] [ wall-sentencing ] }
    { [ dup dead? ] [ dead-sentencing ] }
    [ throw ]
  } cond ;

: bail-out ( prison -- cell )
  [ dup parent>> [ remove-gadget ] keep ]
  [ [ bunk>> ] [ pair>> ] bi >>pair dup pair>> <reversed> grid-add drop ]
  [ bunk>> ]
  tri
  ;

: <prison-cell> ( prisoner pair -- prison )
  over prison-sentence [ bail-out drop ] prison new-button
  dup gadget-child monospace-font link-color font-with-foreground >>font drop
  swap >>pair
  swap >>bunk
  ;

:: imprison ( cell -- prison )
  cell dup parent>> remove-gadget
  cell dup pair>> <prison-cell> :> p
  cell parent>> p dup pair>> <reversed> grid-add drop
  p
  ;

: toggle-prison ( cell -- )
  dup prison? [ bail-out ] [ find-wall imprison ] if request-focus
  ;

: dye-cell ( cell -- )
  link-color <solid> >>boundary relayout-1 ;
: undye-cell ( cell -- )
  f >>boundary relayout-1 ;
dead "selection" f {
  { gain-focus dye-cell }
  { lose-focus undye-cell }
} define-command-map

