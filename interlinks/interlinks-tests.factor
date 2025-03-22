USING: interlinks ;
IN: interlinks.tests


{
  V{
    { 1 0 }
  }
} [ "1" parse-cell-coords ] unit-test

{
  V{
    { 0 1 }
  }
} [ "a" parse-cell-coords ] unit-test

{
  V{
    { 0 0 }
  }
} [ "@" parse-cell-coords ] unit-test
{
  V{
    { 0 0 }
  }
} [ "0@" parse-cell-coords ] unit-test
{
  V{
    { 0 0 }
  }
} [ "0" parse-cell-coords ] unit-test

{
  V{
    { 1 1 }
  }
} [ "1a" parse-cell-coords ] unit-test
{
  V{
    { 3 4 }
  }
} [ "3d" parse-cell-coords ] unit-test

{
  V{
    { 9 0 }
    { 11 2 }
  }
} [ "9@11b" parse-cell-coords ] unit-test

{
  V{
    { 9 0 }
    { 0 -2 }
  }
} [ "9@0-b" parse-cell-coords ] unit-test

{
  V{
    { 0 29 }
    { 1 0 }
    { 1 0 }
    { -1 0 }
    { 1 0 }
  }
} [ "ab1@1@-1@1@" parse-cell-coords ] unit-test



{ "1@" }
[ V{ { 1 0 } } make-cell-coords ] unit-test

{ "0A" }
[ V{ { 0 1 } } make-cell-coords ] unit-test

{ "0@" }
[ V{ { 0 0 } } make-cell-coords ] unit-test

{ "1A" } [ V{ { 1 1 } } make-cell-coords ] unit-test
{ "3D" } [ V{ { 3 4 } } make-cell-coords ] unit-test

{ "9@11B" } [ V{ { 9 0 } { 11 2 } } make-cell-coords ] unit-test

{ "9@0-B" } [ V{ { 9 0 } { 0 -2 } } make-cell-coords ] unit-test

{ "0AB1@1@-1@1@" }
[ V{
    { 0 29 }
    { 1 0 }
    { 1 0 }
    { -1 0 }
    { 1 0 }
  } make-cell-coords ] unit-test






