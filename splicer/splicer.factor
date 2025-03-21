USING: ui.tools.listener.history ;
IN: splicer

TUPLE: splicer < interactor splicing ?manifest? ;

: listener-executing-interactor ( -- interactor )
  [ listener-gadget? ] find-window [ listener-window* ] unless*
  gadget-child input>> ;

: <splicer> ( -- interactor )
  splicer new-editor
  listener-executing-interactor
  {
    [ thread>> >>thread ]
    [ mailbox>> >>mailbox ]
    [ flag>> >>flag ]
    [ word-model>> >>word-model ]
  } cleave
  dup one-word-elt <element-model> >>token-model
  dup model>> <history> >>history
  [ manifest get ] with-interactive-vocabs >>?manifest?
  ;

