unit main;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses
  lview, lwin, lwin2, lroot, lio, lform, lgui, ldat, limg, limg2, Windows, Messages, StdCtrls, SysUtils, Classes, Graphics,
  Controls, Forms, ExtCtrls;
{$align on}{$iochecks on}{$O+}{$W-}{$U+}{$V+}{$B-}{$X+}{$T-}{$P+}{$H+}{$J-} { set critical compiler conditionals for proper compilation - 10aug2025 }
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2025 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. Text2EXE exe viewer
//## Version.................. 1.00.1531
//## Items.................... 1
//## Last Updated ............ 20nov2025, 19oct2025, 13oct2025, 12oct2025, 10oct2025, 08oct2025, 05oct2025, 17nov2007, 26aug2007
//## Lines of Code............ 3,300+
//##
//## main.pas ................ app code
//## lroot.pas ............... app boot and control
//## lform.pas ............... lite form and controls (use GUI/GUI2 compiler directive for compact EXE)
//## lio.pas ................. file io
//## limg.pas ................ image
//## limg2.pas ............... extended image
//## lnet.pas ................ network
//## lwin.pas ................ static Win32 api calls
//## lwin2.pas ............... dynamic Win32 api calls
//## lzip.pas ................ zip support
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | ttext2exe              | tobject           | 1.00.1510 | 20nov2025   | Text2EXE app - 19oct2025, 17nov2007, 26aug2007
//## ==========================================================================================================================================================================================================================


const

tep_customCursor20
:array[0..401] of byte=(
84,69,65,51,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,20,0,0,0,0,0,0,15,0,64,137,212,1,255,0,0,0,13,0,64,137,212,2,255,0,0,0,12,0,64,137,212,3,255,0,0,0,11,0,64,137,212,1,255,255,255,167,1,255,64,137,212,2,255,0,0,0,10,0,64,137,212,1,255,255,255,167,2,255,64,137,212,2,255,0,0,0,9,0,64,137,212,1,255,255,255,167,3,255,64,137,212,2,255,0,0,0,8,0,64,137,212,1,255,255,255,167,4,255,64,137,212,2,255,0,0,0,7,0,64,137,212,1,255,255,255,167,5,255,64,137,212,2,255,0,0,0,6,0,64,137,212,1,255,255,255,167,6,255,64,137,212,2,255,0,0,0,5,0,64,137,212,1,255,255,255,167,7,255,64,137,212,2,255,0,0,0,4,0,64,137,212,1,255,255,255,167,8,255,64,137,212,2,255,0,0,0,3,0,64,137,212,1,255,255,255,167,5,255,64,137,212,6,255,0,0,0,2,0,64,137,212,1,255,255,255,167,2,255,64,137,212,1,255,255,255,167,2,255,64,137,212,1,255,0,0,0,7,0,64,137,212,1,255,255,255,167,1,255,64,137,212,2,255,255,255,167,3,255,64,137,212,1,255,0,0,0,6,0,64,137,212,3,255,0,0,0,1,0,64,137,212,1,255,255,255,167,2,255,64,137,212,1,255,0,
0,0,6,0,64,137,212,2,255,0,0,0,2,0,64,137,212,1,255,255,255,167,3,255,64,137,212,1,255,0,0,0,5,0,64,137,212,1,255,0,0,0,4,0,64,137,212,1,255,255,255,167,1,255,64,137,212,2,255,0,0,0,10,0,64,137,212,2,255,0,0,0,20,0);


tep_splashScreen20
:array[0..476] of byte=(
84,69,65,51,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,20,0,0,0,0,0,0,106,0,140,184,229,22,255,0,0,0,3,0,140,184,229,1,255,255,255,167,22,255,64,137,212,1,255,0,0,0,2,0,140,184,229,1,255,255,255,167,22,255,64,137,212,1,255,0,0,0,2,0,140,184,229,1,255,255,255,167,5,255,64,137,212,1,255,255,255,167,16,255,64,137,212,1,255,0,0,0,2,0,140,184,229,1,255,255,255,167,4,255,64,137,212,1,255,209,252,163,1,255,64,137,212,1,255,255,255,167,5,255,64,137,212,1,255,255,255,167,9,255,64,137,212,1,255,0,0,0,2,0,140,184,229,1,255,255,255,167,3,255,64,137,212,1,255,209,252,163,3,255,64,137,212,1,255,255,255,167,3,255,64,137,212,1,255,209,252,163,1,255,64,137,212,1,255,255,255,167,8,255,64,137,212,1,255,0,0,0,2,0,140,184,229,1,255,255,255,167,2,255,64,137,212,1,255,209,252,163,5,255,64,137,212,1,255,255,255,167,1,255,64,137,212,1,255,209,252,163,3,255,64,137,212,1,255,255,255,167,3,255,64,137,212,1,255,255,255,167,3,255,64,137,212,1,255,0,0,0,2,0,140,184,229,1,255,255,255,167,1,255,64,137,212,1,255,
209,252,163,7,255,64,137,212,1,255,209,252,163,5,255,64,137,212,1,255,255,255,167,1,255,64,137,212,1,255,209,252,163,1,255,64,137,212,1,255,255,255,167,2,255,64,137,212,1,255,0,0,0,2,0,140,184,229,1,255,64,137,212,1,255,209,252,163,9,255,64,137,212,1,255,209,252,163,5,255,64,137,212,1,255,209,252,163,3,255,64,137,212,1,255,255,255,167,1,255,64,137,212,1,255,0,0,0,2,0,140,184,229,1,255,209,252,163,17,255,64,137,212,1,255,209,252,163,3,255,64,137,212,2,255,0,0,0,2,0,140,184,229,1,255,209,252,163,22,255,64,137,212,1,255,0,0,0,3,0,64,137,212,22,255,0,0,0,106,0);


tep_aboutWindow20
:array[0..491] of byte=(
84,69,65,51,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,18,0,0,0,20,0,0,0,0,0,0,20,0,64,137,212,14,255,0,0,0,3,0,64,137,212,16,255,0,0,0,2,0,64,137,212,16,255,0,0,0,2,0,64,137,212,1,255,255,255,167,14,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,167,14,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,167,14,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,167,6,255,64,137,212,1,255,255,255,167,7,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,167,5,255,64,137,212,1,255,192,252,185,1,255,64,137,212,1,255,255,255,167,3,255,64,137,212,1,255,255,255,167,2,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,167,4,255,64,137,212,1,255,192,252,185,3,255,64,137,212,1,255,255,255,167,1,255,64,137,212,1,255,192,252,185,1,255,64,137,212,1,255,255,255,167,1,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,167,3,255,64,137,212,1,255,192,252,185,5,255,64,137,212,1,255,192,252,185,3,255,64,137,212,2,255,0,0,0,2,0,64,137,212,1,255,255,255,167,2,255,64,137,212,1,
255,192,252,185,7,255,64,137,212,1,255,192,252,185,3,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,167,1,255,64,137,212,1,255,192,252,185,9,255,64,137,212,1,255,192,252,185,2,255,64,137,212,1,255,0,0,0,2,0,64,137,212,2,255,192,252,185,13,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,192,252,185,14,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,192,252,185,14,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,192,252,185,14,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,192,252,185,14,255,64,137,212,1,255,0,0,0,3,0,64,137,212,14,255,0,0,0,20,0);

tep_borderColor20
:array[0..511] of byte=(
84,69,65,51,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0,20,0,0,0,0,0,0,21,0,64,137,212,1,255,0,0,0,19,0,64,137,212,1,255,139,182,228,1,255,0,0,0,18,0,64,137,212,1,255,139,182,228,1,255,0,0,0,18,0,64,137,212,1,255,139,182,228,1,255,0,0,0,18,0,64,137,212,1,255,139,182,228,1,255,0,0,0,11,0,64,137,212,3,255,0,0,0,4,0,64,137,212,1,255,139,182,228,1,255,0,0,0,10,0,64,137,212,1,255,218,250,252,1,255,64,137,212,3,255,0,0,0,3,0,64,137,212,1,255,139,182,228,1,255,0,0,0,9,0,64,137,212,6,255,0,0,0,3,0,64,137,212,1,255,139,182,228,1,255,0,0,0,9,0,64,137,212,6,255,0,0,0,3,0,64,137,212,1,255,139,182,228,1,255,0,0,0,8,0,64,137,212,1,255,218,250,251,1,255,64,137,212,4,255,0,0,0,4,0,64,137,212,1,255,139,182,228,1,255,0,0,0,7,0,64,137,212,1,255,218,250,251,2,255,64,137,212,3,255,0,0,0,5,0,64,137,212,1,255,139,182,228,1,255,0,0,0,6,0,64,137,212,1,255,218,250,251,2,255,1,192,208,1,255,64,137,212,1,255,0,0,0,7,0,64,137,212,1,255,139,182,228,1,255,0,0,0,5,0,64,137,212,1,255,218,250,251,2,255,1,192,208,
1,255,64,137,212,1,255,0,0,0,8,0,64,137,212,1,255,139,182,228,1,255,0,0,0,4,0,64,137,212,1,255,218,250,251,2,255,1,192,208,1,255,64,137,212,1,255,0,0,0,9,0,64,137,212,1,255,139,182,228,1,255,0,0,0,3,0,64,137,212,1,255,218,249,251,2,255,1,192,208,1,255,64,137,212,1,255,0,0,0,10,0,64,137,212,1,255,139,182,228,1,255,0,0,0,3,0,64,137,212,1,255,1,192,208,2,255,64,137,212,1,255,0,0,0,11,0,64,137,212,1,255,139,182,228,1,255,0,0,0,3,0,64,137,212,3,255,0,0,0,12,0,64,137,212,1,255,139,182,228,16,255,0,0,0,3,0,64,137,212,18,255,0,0,0,21,0);

tep_backColor20
:array[0..561] of byte=(
84,69,65,51,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0,20,0,0,0,0,0,0,23,0,64,137,212,14,255,0,0,0,5,0,64,137,212,1,255,255,255,128,14,255,64,137,212,1,255,0,0,0,3,0,64,137,212,1,255,255,255,128,16,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,16,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,12,255,64,137,212,3,255,255,255,128,1,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,11,255,64,137,212,1,255,218,250,252,1,255,64,137,212,4,255,0,0,0,2,0,64,137,212,1,255,255,255,128,10,255,64,137,212,7,255,0,0,0,2,0,64,137,212,1,255,255,255,128,10,255,64,137,212,7,255,0,0,0,2,0,64,137,212,1,255,255,255,128,9,255,64,137,212,1,255,218,250,251,1,255,64,137,212,4,255,255,255,128,1,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,8,255,64,137,212,1,255,218,250,251,2,255,64,137,212,3,255,255,255,128,2,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,7,255,64,137,212,1,255,218,250,251,2,255,1,192,208,1,255,64,137,212,1,255,255,255,128,
4,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,6,255,64,137,212,1,255,218,250,251,2,255,1,192,208,1,255,64,137,212,1,255,255,255,128,5,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,5,255,64,137,212,1,255,218,250,251,2,255,1,192,208,1,255,64,137,212,1,255,255,255,128,6,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,4,255,64,137,212,1,255,218,249,251,2,255,1,192,208,1,255,64,137,212,1,255,255,255,128,7,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,4,255,64,137,212,1,255,1,192,208,2,255,64,137,212,1,255,255,255,128,8,255,64,137,212,1,255,0,0,0,2,0,64,137,212,1,255,255,255,128,4,255,64,137,212,3,255,255,255,128,9,255,64,137,212,1,255,0,0,0,3,0,64,137,212,1,255,255,255,128,14,255,64,137,212,1,255,0,0,0,5,0,64,137,212,14,255,0,0,0,23,0);

tep_widen20
:array[0..351] of byte=(
84,69,65,51,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0,20,0,0,0,0,0,0,26,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,9,0,64,137,212,1,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,1,255,0,0,0,5,0,64,137,212,2,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,2,255,0,0,0,3,0,64,137,212,3,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,3,255,0,0,0,3,0,64,137,212,2,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,2,255,0,0,0,5,0,64,137,212,1,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,1,255,0,0,0,9,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,26,0);

tep_shrink20
:array[0..351] of byte=(
84,69,65,51,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0,20,0,0,0,0,0,0,26,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,7,0,64,137,212,1,255,0,0,0,4,0,64,137,212,8,255,0,0,0,4,0,64,137,212,1,255,0,0,0,2,0,64,137,212,2,255,0,0,0,3,0,64,137,212,8,255,0,0,0,3,0,64,137,212,2,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,8,255,0,0,0,2,0,64,137,212,3,255,0,0,0,2,0,64,137,212,2,255,0,0,0,3,0,64,137,212,8,255,0,0,0,3,0,64,137,212,2,255,0,0,0,2,0,64,137,212,1,255,0,0,0,4,0,64,137,212,8,255,0,0,0,4,0,64,137,212,1,255,0,0,0,7,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,12,0,64,137,212,8,255,0,0,0,26,0);

tep_screen20:array[0..200] of byte=(
84,69,65,49,35,18,0,0,0,20,0,0,0,0,255,0,55,0,0,128,16,0,255,0,1,0,0,128,1,166,166,255,16,0,0,128,2,166,166,255,15,0,0,255,1,0,0,128,2,166,166,255,13,0,0,255,3,0,0,128,2,166,166,255,12,0,0,255,4,0,0,128,2,166,166,255,10,0,0,255,6,0,0,128,2,166,166,255,9,0,0,255,7,0,0,128,2,166,166,255,7,0,0,255,9,0,0,128,2,166,166,255,6,0,0,255,10,0,0,128,2,166,166,255,4,0,0,255,12,0,0,128,2,166,166,255,3,0,0,255,13,0,0,128,2,166,166,255,1,0,0,255,15,0,0,128,1,0,255,0,1,0,0,128,16,0,255,0,8,0,0,128,3,0,255,0,15,0,0,128,3,0,255,0,13,0,0,128,7,0,255,0,11,0,0,128,7,0,255,0,6);


   //TEPs -> Text Images in 1-6 bit format at fixed height of 20 pixels and variable width
   tepNew='T2K00K00)3000fOrPl()~'+'000000000000000000000GLL0000fgM000GggP000agQL000fgg600Gggg100aggQ000fgg600Gggg100aggQ000fgg600Gggg100GLL500000000000000000000000000000#';//xxxxxxxxxT2K00K00)3000fOrPl()~'+'000000000000000000000KLL0000fgM000GggP000agQL000fgg600Gggg100aggQ000fgg600Gggg100aggQ000fgg600Gggg100KLLL00000000000000000000000000000#';//xxxxxxxxxxxT6K00K00)J01uoz)Apzz1pzz1pjx1FjxugSvlgSvAFjx1pz)tV))kV)zkx(zbxkxbNkxT6SvKYBtAFTv))))t)))T6ixdXxzdrvqkV))CrfxLj8tT(wqbV))JN(zu6yzcQwzT(Atbx()Sx()JN()1Fz)c(wqAN()Apz)ugixcQwqcQgol6CtTQgoloz)uEz)cYBtcEz)TsPmcYxqlEz)c(Atl6ixlYRvc(Qv~'+'00000000000000000000000000000000000000000000123455567800000000009ABBCCDEFGH0000000002IIIIIJAKLMH000000003IIIJANNFOPQ000000003IIIANNRSTUV000000005IIANNWXXYZa000000005IANNWXXYbca00000000dANRWXXYbbca000000006NNWXXYbb99e000000007NWXXYbb91Zf00000000gRXXYb'+'b911Zh00000000gWXYbb911ijh00000000kXYbb911iljm00000000nYYb9911oljm00000000pqrrrrspppVm0000000000000000000000000000000000000000000000000000000000000000#';
   tepOpen='T3K00K00)300Kqv2WAu8)xVb))))V7CQ~'+'0000000000000000000000000000000000089000000001011000000008100GI00009100QSIII20000YZZZZ20000QSSSS20000YZJIIII200QSgjjjj200YJjjjjL000Qgjjjj2000IjjjjL0000GIIII20000000000000000000000000000000000000000000#';//xxxxxxxxxx
   tepSaveAs='T3K00K00)300hjspiow)))))xkx)zrNr~'+'00000000000000000000009999990008IIIIII1008IRRRRI1008IZaaSI1008IRRRRI1008IZaaSI1008IRRRRI1008IIIIII1008IIIIII1008IjjjjL1008IjjjRL1008IjjjRL1008IjjjRL1000999999000000000000000000000000000000000000000000#';//xxxxxxxxxxxxxxT6K00K00)BW04I8w4IOx)z7wI9bjSn5mYAw)))))iow)cPcoNT5mdUw)xkx)03y)rLNsNTrkm1Nsn6x)sQx)X5com17rhjspOY9)JEvzJE9)Tsv)rLdtwfdtcPsp9cOxOYv)8X4hwftu5Ny)Ahy)vaZeSnLneZ()F)y)(uZeZF()EweyPdz)I9rkX5Mn~'+'0000000000000000000000000000000000000000000122222222222300000045677777777789400000A9B7CCCCDDD78EF00000A9B7777777778GF00000F987HIIIICI7HGF00000F98777777777HGF00000F987HHHHHHH7HGF00000FJH777777777IKF00000FL3MNNNNOMMP2QF00000FEL9LRRKLSSJ9RF00000FQGGNP6B'+'TU65VGF00000FEKWP44OMXY5ZGF00000FEKWP9aMDbcAdGF00000FQKRT9KDebDFdGF000004KQEWfHeegHhdEF0000004FaQQQQQQQEiA00000000000000000000000000000000000000000000#';
   tepPrint='T5K00K00)300RkvaPl()uEz)kuY9))))4Fyk)x)bTsva5JykKqv25LaCUwva6NikBjKDW2wa7RSkH5LENT5F8VSkYAwaTr5G9ZCkZEwaZDsG~'+'00000000000000000000000000000000000000000000000000011100000000000000001222110000000000000132222244000000000113322224000000000115133322400000000115666113346440000015667766611461140000855599AA9998888B0000C5DD55DDDCCCCCCE0000C5DDDD5CCCCCCCCE0000FFGGGGGF'+'FFFFFHH000000FFFGGGFFFFHHFH000000IJJKKJKKIIKKII0000000LLMMNLLNNLL00000000000LLMNNLL000000000000000OOO0000000000000000000000000000000000000000000000000#';//xxxxxxxxT4K00K000yF0028W)))p)(xl0000G2v)r)))G3z)ojDI1CqxxNC8(GcX1mZrl1t)~'+'0000000000000000000000000000000010000000000000000001211000000000000000122221100000000000012232222100000000001222223221000000000422232222100000000556542223210000000556777554221750000056578877755175590000565677AA7775555900005657667775555559000056577565'+'5555555900005557757555555BC0000005557575555BB5C000000D7755755BB55CC0000000DD775BB55CC00000000000DD755CC000000000000000DCC00000000000000000000000000000#';

   tepAdd='T2K00K00)300jm7pPl()~'+'000000000000000000000KLLL00GgggQ00agcg600fgfg10GgQgQ00agcg600fLLf10GgQgQ00agcg600fgfg10GgQgQ00aggg600KLLL00000000000000000000000000000#';
   tepDel='T2K00K00)300jm7pPl()~'+'000000000000000000000KLLL00GgggQ00aggg600fggg10GgggQ00aggg600fLLf10GgggQ00aggg600fggg10GgggQ00aggg600KLLL00000000000000000000000000000#';
   tepOpenN='T3K00K00)300Kqv2WAu8)xVb))))V7CQ~'+'0000000000000000000000000009000000000900000000999000000099900GI00009000QSIII29000YZZZZ20000QSSSS20000YZJIIII200QSgjjjj200YJjjjjL000Qgjjjj2000IjjjjL0000GIIII20000000000000000000000000000000000000000000#';
   tepUndo='T1K00K00)300Kqv2~'+'0000000000000000000000000F0431m2807W0y02m7400G000000000000000000000#';
   tepCut='T2K00K00)3000fOrWAu8~'+'00000000000000000000004G00000140000G010000KK000004100000L000000100000K100000YA0000g8800088220002YW000WWW2000W2000000000000000000000000#';
   tepCopy='T2K00K00)3000fOrPl()~'+'00000000000000KL0000GgM0000agP0000PPLL00GgQgM00aLbgP00fgPPL0GMLgg60agcLb10PLfgQ0GgQML60GLbgg1000PLP000Ggg6000GLL0000000000000000000000#';
   tepPaste='T3K00K00)300WAu80fOr)llaPl()~'+'000000000000000000000009900000099HA990008PBAHPB1008RPRRBR1008R9999R1008RRRRRR1008RRJIII1008RRJaaK2008RRJaaKK008RRJKIKI208RRJaaaa208RRJKIIY208RRJaaaa208PRJKIIY20099Haaaa200000IIII0000000000000000000000#';
   tepMessage='T2K00K00)300hjsp))))~'+'000000000000000000000GLL5000fgg600Gggg600aLbg100fggQ00GMLL600aggg100PLLP00Gggg600aLLb100fggQ00GQLb600aggg100KLL50000000000000000000000#';
   tepColor='T3e00K00)30000mV)ztV)(xl0000))))~'+'00000000000000000000000000000000000000000000008900000000GI00000000P910000000QI20000008991000000GII20000009991000000III20000009990000000III000000WD91000000GLI2000000iL90000000gLI000000WjY0000000GjI0000000iL40000000gL2000000WjX0000000GjJ0000000iD400000'+'00gT2000000WjX0000000GjJ0000000W940000000GR20000000Wa00000000GI000000000000000000000000000000000000000000000000000000000000000000000000000000000000000#';
   tepCenter='T2K00K00)300jm7pPl()~'+'000000000000000000000KLLL00GgggQ00aggg600fggg10GgQgQ00agcg600fMLg10GgQgQ00agcg600fggg10GgggQ00aggg600KLLL00000000000000000000000000000#';//xxxxxxxxxT2K00K00)300jm7pPl()~'+'000000000000000000000LLLL10GgggQ00aggg600fggg10GgQgQ00agcg600fMLg10GgQgQ00agcg600fggg10GgggQ00aggg600LLLL10000000000000000000000000000#';//xxxxxxxxT1K00K00)3000fOr~'+'0000000000u)FW0W0202808WWW02228(8WWW0222808W0W0202u)F00000000000000#';//xxxxxxxxxxT2K00K00)300mRSNY9jO~'+'000000000000000000000LLLL50GLLLL10K000K0050A050G1W2G10K0e0K005ggA50GXggI10K0e0K0050A050G1W2G10K000K00LLLL50GLLLL1000000000000000000000#';
   tepInfo='T2K00K00)3000fOr))))~'+'000000000LL0000bgQ100aMLf10GMLLb10PLfLb1GMLQLP0PLLLLPGMLLLL6aLLQLb1PLbMLPGMLfLL6aLLQLb1aLbML60PLfLb10PLLL600fLLQ000bgQ1000KL1000000000#';
   tepHelp='T2K00K00)3000fOr))))~'+'000000000LL0000bgQ100aMLf10GMfQb10PbgQb1GMgLQP0PbMbMPGMLLgL6aLLfMb1PLbQLPGMLfLL6aLLQLb1aLLLL60PLfLb10PLQL600fLLQ000bgQ1000KL1000000000#';
   tepTextWnd='T2K00K00)3000fOr))))~'+'00000000000000000000GLLLLL0LLLLLLGLLLLL5aggggg1fggggQGQLLfg6aggggg1fggggQGQLLLb6aggggg1fggggQGQLLLb6aggggg1fggggQ0LLLLL100000000000000#';
   tepTextWndColor='T3K00K00)3000fOr))))RlV)14Sq~'+'0000000000000000000000000000000999999990899999999189999999918IIIIIIII18IIIIIIII18I9999II918IIIIIIAB98IIIIII9998I999999998IIIIIAB918IIIIIPB918I9999RCI18IIIIPZHI18IIIARCII10999PZ99900000XC00000000910000#';

   tepUp='T2e00K00)3000000028W~'+'00000000000000000000000000000000000000000000000000000000K000000A00000K500000g20000KL10000gg0000KLL0000ggA000KLL5000ggg2000GL00000eA00000L10000Wg00000K500000g20000GL00000eA00000L10000Wg00000K500000g20000GL00000eA00000L10000Wg00000000000000000000000000'+'00000000000000000#';
   tepDown='T2e00K00)3000000028W~'+'000000000000000000000000000000000000000000GL00000eA00000L10000Wg00000K500000g20000GL00000eA00000L10000Wg00000K500000g20000GL00000eA00000L10000Wg0000KLL5000ggg2000LL5000Wgg2000GL50000eg20000K500000g200000500000W2000000000000000000000000000000000000000'+'00000000000000000#';
   tepOptions='T2e00K00)300W02G028W~'+'00K100000g00000KL0K100gA0g00L50K10Wg20g00L50G10Wg20e00KL00LG0gA0WA8LL50LLXgg2WggL5L1KLXgYg0ggG5GLK50e2eAg2040KL50020gg20000L50000Wg20000KL00000gA0000KL50000gg2000K5L1000gYg00GL5KL00eg2gA0GH50L50ee2Wg201K0GL1W0A0eg00010KL00W00gA00500L00W20WA0G500G00e2'+'00800000000000000#';

   

   
   //border sizes --------------------------------------------------------------
   t2ebNone           =0;
   t2ebFine           =4;
   t2ebSmall          =8;
   t2ebMedium         =18;
   t2ebLarge          =40;
   t2ebExtraLarge     =60;

   
type
  ttext2exe=class;

  tform1 = class(tform)

    procedure formcreate(sender: tobject);
    procedure formclose(sender: tobject; var action: tcloseaction);
    procedure formclosequery(sender: tobject; var canclose: boolean);
    procedure formresize(sender: tobject);

  private

   imenu:tgenericmainmenu;
   itext2exe:ttext2exe;
   isettings:tappsettings;

   procedure _onbusy(sender:tobject);
   procedure wmsizing(var x:tmessage); message wm_sizing;
   procedure xcmd(sender:tobject;const xcode:string);
   procedure xsavesettings;

  public

   //create
   destructor destroy; override;
   procedure exitsystem;

  end;

{ttext2exe}
  ttext2exe=class(tobject)
  private

   ifont:tfont;
   ioverview:tgenericguiform;
   ichangeid,ipngDropmode,irunmode:longint;
   iref,iapptitle,iname:string;
   ititleform,iform:tform;
   itoolbar:tgenerictoolbar;
   istatus:tgenericstatus;
   idoc:texeviewer;
   iundo:string;
   ipassShow,ipassToedit,ipassToview,icancelled,icansave,imodified,ibusy:boolean;
   idefTitle:string;
   ipasswordboxTEMP,ititleboxTEMP:tedit;

   ifilename         ,ifilenameFilterlist        :string;
   icursorfilename   ,icursorfilenameFilterlist  :string;
   isplashfilename   ,isplashfilenameFilterlist  :string;
   iaboutfilename    ,iaboutfilenameFilterlist   :string;

   fonhelp,fonchange,fonbusy:tnotifyevent;
   foncmd:tcmdevent;

   procedure xchanged;
   procedure xupdatebuttons;
   function xexehead:string;
   procedure _onresize(sender:tobject);
   procedure setbusy(x:boolean);
   procedure _onclick(sender:tobject);
   procedure _ontimer(sender:tobject);
   function getpassword:string;
   procedure setpassword(x:string);
   procedure clear;
   procedure settitle(x:string);
   function gettitle:string;
   procedure setauthor(x:string);
   function getauthor:string;
   procedure setcancopy(x:boolean);
   function getcancopy:boolean;
   procedure setautotitle(x:boolean);
   function getautotitle:boolean;
   procedure setbrsize(x:longint);
   function getbrsize:longint;
   function getbrstyle:string;
   procedure setbrstyle(x:string);
   procedure updatefont;
   function bas(x:longint;d:string):string;//bytes as string
   procedure setonhelp(x:tnotifyevent);
   procedure disassociate;
   procedure xnotsaved;
   function xfromfile(const x:string;var e:string):boolean;
   function xfromfile_v1(const xfilename:string;var e:string):boolean;
   function _onacceptfiles(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
   procedure setcustomimage2(n,xusethisfileInsteadOfPrompting:string;const nclear:boolean);
   procedure setcustomimage3(n,xusethisfileInsteadOfPrompting:string;xusethisdataInsteadofPrompting:pobject;const nclear:boolean);
   procedure setpngDropmode(x:longint);
   procedure setrunmode(x:longint);
   function xgrabcolor:boolean;
   procedure _onpassshow(sender:tobject);
   procedure _ontitleauto(sender:tobject);
   procedure xonmouse(sender:tobject);
   function xpasswordStatus:string;
   procedure setfilename(x:string);
   function xmakepng(a:pobject):boolean;

  public

   //options
   opreview:boolean;

   //create
   constructor create(atitle:string;atitleform:tform); virtual;
   destructor destroy; override;
   property form:tform read iform;
   procedure xcmd(sender:tobject;const xcode:string);

   //core
   property doc            :texeviewer      read idoc;
   property overview       :tgenericguiform read ioverview;
   //edit
   function new(prompt:boolean;var e:string):boolean;
   property password       :string         read getpassword        write setpassword;
   property title          :string         read gettitle           write settitle;
   property author         :string         read getauthor          write setauthor;
   property cancopy        :boolean        read getcancopy         write setcancopy;
   property autotitle      :boolean        read getautotitle       write setautotitle;
   property passToedit     :boolean        read ipassToedit        write ipassToedit;
   property passToview     :boolean        read ipassToview        write ipassToview;
   property passShow       :boolean        read ipassShow          write ipassShow;
   property brsize         :longint        read getbrsize          write setbrsize;
   property brstyle        :string         read getbrstyle         write setbrstyle;
   property pngDropmode    :longint        read ipngDropmode       write setpngDropmode;
   property runmode        :longint        read irunmode           write setrunmode;
   procedure center;
   procedure show;
   procedure hide;

   //default
   function xnewdefault(prompt:boolean;const xid:longint;var e:string):boolean;
   procedure xsavedefault(const xid:longint);
   function xhavedefault(const xid:longint):boolean;
   procedure xloaddefault(const xid:longint);

   //custom image support
   function hascustomimage(n:string):boolean;
   procedure setcustomimage(n:string;const nclear:boolean);

   //busy
   property busy:boolean read ibusy write setbusy;

   //color
   procedure ucolor;
   procedure ubordercolor;

   //font
   procedure ufont;

   //undo
   function canundo:boolean;
   function undo(var e:string):boolean;

   //copy
   function cancopytoclipboard:boolean;
   function copytoclipboard(var e:string):boolean;

   //cut
   function cancuttoclipboard:boolean;
   function cuttoclipboard(var e:string):boolean;

   //paste
   function canpastefromclipboard:boolean;
   function pastefromclipboard(var e:string):boolean;
   function pastereplaceall(var e:string):boolean;//05oct2025

   //selectall
   procedure selectall;

   //help
   function canhelp:boolean;
   function help(var e:string):boolean;

   //details
   procedure udetails;
   procedure uoverview;
   procedure about;

   //io
   property filename:string read ifilename write setfilename;
   function uSave(const xnewpath:string;var e:string):boolean;
   function cansave:boolean;
   function save(var e:string):boolean;
   function ucanrun:boolean;
   procedure urun;
   function tofile(const x:string;var e:string):boolean;
   function tostr(var x,e:string;const xfilenameForRef:string;xpromptforPassword:boolean):boolean;
   function okforopen:boolean;
   function uOpen(const xnewpath:string;var e:string):boolean;
   function fromfile(const x:string;var e:string):boolean;

   //misc
   property splashfilename:string read isplashfilename write isplashfilename;
   property aboutfilename:string  read iaboutfilename  write iaboutfilename;
   property cursorfilename:string read icursorfilename write icursorfilename;

   //events
   property oncmd:tcmdevent read foncmd write foncmd;
   property onhelp:tnotifyevent read fonhelp write setonhelp;
   property onchange:tnotifyevent read fonchange write fonchange;
   property onbusy:tnotifyevent read fonbusy write fonbusy;

  end;

var
  Form1: TForm1;


//info procs -------------------------------------------------------------------
procedure app__create;
procedure app__destroy;
{$ifdef gui4}
procedure app__splash(const n:string);
{$endif}
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


implementation

{$R *.DFM}


//info procs -------------------------------------------------------------------

{$ifdef gui4}
procedure app__splash(const n:string);
begin

case strmatch(n,'splash') of
true:dialog__splash(splash__png,242611,1.5,1,1,true,true);
else dialog__splash(about_png,242611,1.5,4,10,false,false);
end;//case

end;
{$endif}

procedure app__create;
begin

application.initialize;
application.createform(tform1, form1);

end;

procedure app__destroy;
begin

app__setmainform(nil);
form1.Hide;
freeobj(@form1);

end;

function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='950'
else if (xname='height')              then result:='200'
else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='ver')                 then result:='1.00.1531'
else if (xname='date')                then result:='20nov2025'
else if (xname='name')                then result:='Text2EXE'
else if (xname='web.name')            then result:='text2exe'//used for website name
else if (xname='des')                 then result:='Create portable text documents'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')

//.app colors etc
else if (xname='app.fontsize')        then result:='10'
else if (xname='app.fontname')        then result:='Arial'
else if (xname='app.backcolor')       then result:=intstr32(clWindow)
else if (xname='app.tintcolor')       then result:=intstr32(clLime)

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'
//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
//else if (xname='portal.tep')          then result:=intstr32(tepBE20)
//.software
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'
//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'
//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web: '+app__info('url.portal')

else
   begin
   //nil
   end;

except;end;
end;

procedure tform1.formcreate(sender: tobject);
var
   n,v,e:string;
   p:longint;
begin
try

//make common
app__makecommon(self,isettings,imenu);


//file -------------------------------------------------------------------------

with imenu do
begin

addtop('&File','file');

add2('&New','new','Ctrl+N');
add ('New Default 1','new.default.1');
add ('New Default 2','new.default.2');
add ('New Default 3','new.default.3');
add ('New &Instance','new.instance');
add ('Show App Folder','app.folder');
addsep;

add2('&Open','open','Ctrl+O');
add ('Open from Desktop','open.desktop');

add2('&Save','save','Ctrl+S');
add2('Save &As','saveas','Ctrl+A');
add ('Save to Desktop','saveas.desktop');

add ('Run Document','run');
addsep;

add ('Make Default 1','save.default.1');
add ('Make Default 2','save.default.2');
add ('Make Default 3','save.default.3');
addsep;

add ('E&xit','exit');


//edit -------------------------------------------------------------------------
addtop('&Edit','edit');
add2('&Undo','undo','Ctrl+Z');
addsep;
add2('Cu&t','cut','Ctrl+X');
add2('&Copy','copy','Ctrl+C');
add2('&Paste','paste','Ctrl+V');
add('Paste Replace','pastereplace');
add('Select &All','selectall');
//???????????? imenu.add('Font','font');


tadd('Standard Options');
add2('Details','details','F4');
add2('Border color','brcolor','F4');
add2('Background color','bgcolor','F5');
add2('Author','author','F6');
addsep;
add2('Overview Panel','overview','F12');


//border -----------------------------------------------------------------------

addtop('&Border','border');
tadd('Border Size');
add('None','brsize.'+intstr32(t2ebNone));
add('Fine','brsize.'+intstr32(t2ebFine));
add('Small','brsize.'+intstr32(t2ebSmall));
add('Medium','brsize.'+intstr32(t2ebMedium));
add('Large','brsize.'+intstr32(t2ebLarge));
add('Extra Large','brsize.'+intstr32(t2ebExtraLarge));
add('-5 px','brsize-5');
add('+5 px','brsize+5');

tadd('Border Style');

for p:=0 to max16 do if form__brstyles(p,n,v) then add(n,'brstyle.'+v) else break;


//advanced ---------------------------------------------------------------------
addtop('&Advanced','advanced');

tadd('Splash Screen Graphic');
add('Test','splash.test');
add('Open','splash.set');
add('Copy','splash.copy');
add('Paste','splash.paste');
add('Remove','splash.del');
add('Show Folder','splash.folder');

tadd('About Window Graphic');
add('Test','about.test');
add('Open','about.set');
add('Copy','about.copy');
add('Paste','about.paste');
add('Remove','about.del');
add('Show Folder','about.folder');

tadd('Custom Cursor');
add('Open','cursor.set');
add('Remove','cursor.del');
add('Show Folder','cursor.folder');

addsep;
add('Preview Splash/About Graphic Changes','preview.auto');


//options ----------------------------------------------------------------------
addtop('&Options','options');
tadd('Drag and Drop Graphic Modes');
add('1. Drop image on top half of window = Splash Screen Graphic, bottom half = About Window Graphic','pngdropmode.1');
add('2. Drop Wide image = Splash Screen Graphic, and Tall image = About Window Graphic','pngdropmode.0');
add('3. Drop image = Splash Screen Graphic','pngdropmode.2');
add('4. Drop image = About Window Graphic','pngdropmode.3');
tadd('Run Mode');
add('Keep editor up','runmode.0');
add('Hide editor','runmode.1');


//help -------------------------------------------------------------------------
xaddHelp;

end;//menu


//itext2exe
itext2exe:=ttext2exe.create( app__info('name') ,form1);
itext2exe.form.parent:=form1;
itext2exe.form.align:=altop;
itext2exe.form.visible:=true;
itext2exe.new(false,e);

//form
setbounds(0,0,strint32(app__info('width')),(height-clientheight)+itext2exe.form.clientheight);


//apply settings ---------------------------------------------------------------
with isettings do
begin

ds['brstyle']        :='flat';
di['brsize']         :=t2ebMedium;
di['brcolor']        :=rgba0__int(240,240,240);
di['bgcolor']        :=rgba0__int(255,255,255);
db['allowcopy']      :=true;
db['autotitle']      :=true;
di['width']          :=500;
di['height']         :=500;
db['preview.auto']   :=true;
di['pngdropmode']    :=1;//19oct2025
di['runmode']        :=0;
db['pass.toedit']    :=false;
db['pass.toview']    :=false;
db['pass.show']      :=false;
db['overview.show']  :=false;

itext2exe.doc.border           :=i['brsize'];
itext2exe.doc.brstyle          :=s['brstyle'];
itext2exe.doc.brcolor          :=i['brcolor'];
itext2exe.doc.bgcolor          :=i['bgcolor'];
itext2exe.doc.cancopy          :=b['allowcopy'];
itext2exe.doc.autotitle        :=b['autotitle'];
itext2exe.doc.form.width       :=frcmin32(i['width'],32);
itext2exe.doc.form.height      :=frcmin32(i['height'],32);
itext2exe.opreview             :=b['preview.auto'];
itext2exe.pngDropmode          :=i['pngdropmode'];
itext2exe.runmode              :=i['runmode'];
itext2exe.passtoedit           :=b['pass.toedit'];
itext2exe.passtoview           :=b['pass.toview'];
itext2exe.passshow             :=b['pass.show'];

if h['filename']   then itext2exe.filename:=io__extractfilepath(io__readportablefilename(s['filename']));
if h['s.filename'] then itext2exe.splashFilename:=io__readportablefilename(s['s.filename']);
if h['a.filename'] then itext2exe.aboutFilename:=io__readportablefilename(s['a.filename']);
if h['c.filename'] then itext2exe.cursorFilename:=io__readportablefilename(s['c.filename']);

end;//isettings



//open file for editing from "paramstr"
if (low__param(1)<>'') then
   begin

   if not itext2exe.fromfile( low__param(1), e ) then showerror(e);

   end;


//events -----------------------------------------------------------------------
imenu.oncmd          :=xcmd;
itext2exe.onbusy     :=_onbusy;
itext2exe.oncmd      :=xcmd;
//xxxxitext2exe.onhelp:=help2click;


//show
app__start(self);
itext2exe.show;

if isettings.b['overview.show'] then itext2exe.uoverview;

except;end;
end;

destructor tform1.destroy;
begin
try

//save settings
xsavesettings;

//disconnect and close support controls
app__stop(self,isettings);

//controls
freeobj(@itext2exe);

//self
inherited destroy;

except;end;
end;

procedure tform1.xsavesettings;
begin
try

//get
isettings.s['brstyle']        :=itext2exe.doc.brstyle;
isettings.i['brsize']         :=itext2exe.doc.border;
isettings.i['brcolor']        :=itext2exe.doc.brcolor;
isettings.i['bgcolor']        :=itext2exe.doc.bgcolor;
isettings.b['allowcopy']      :=itext2exe.doc.cancopy;
isettings.b['autotitle']      :=itext2exe.doc.autotitle;
isettings.i['width']          :=itext2exe.doc.form.width;
isettings.i['height']         :=itext2exe.doc.form.height;
isettings.b['preview.auto']   :=itext2exe.opreview;
isettings.i['pngdropmode']    :=itext2exe.pngDropmode;
isettings.i['runmode']        :=itext2exe.runmode;
isettings.b['pass.toedit']    :=itext2exe.passtoedit;
isettings.b['pass.toview']    :=itext2exe.passtoview;
isettings.b['pass.show']      :=itext2exe.passshow;
isettings.b['overview.show']  :=itext2exe.overview.visible;

isettings.s['filename']       :=io__makeportablefilename(io__extractfilepath(itext2exe.filename));
isettings.s['s.filename']     :=io__makeportablefilename(itext2exe.splashFilename);
isettings.s['a.filename']     :=io__makeportablefilename(itext2exe.aboutFilename);
isettings.s['c.filename']     :=io__makeportablefilename(itext2exe.cursorFilename);

//save
isettings.save;

except;end;
end;

procedure tform1.wmsizing(var x:tmessage);
var
   a:prect;
begin

a:=prect(x.lparam);
a.bottom:=a.top+height;
x.result:=0;

end;

procedure tform1.exitsystem;
begin
if (not itext2exe.busy) and itext2exe.okforopen then app__halt;
end;

procedure tform1.formclose(sender: tobject; var action: tcloseaction);
begin

exitsystem;
action:=canone;

end;

procedure tform1.formclosequery(sender: tobject; var canclose: boolean);
begin

exitsystem;
canclose:=false;

end;

procedure tform1._onbusy(sender:tobject);
begin

imenu.topenabled:=not itext2exe.busy;
app__processmessages;

end;


procedure tform1.formresize(sender: tobject);
var
   v:longint;
begin

if (itext2exe<>nil) then v:=itext2exe.form.height else v:=0;
height:=(height-clientheight)+v;

end;


//## TText2EXE #################################################################

constructor ttext2exe.create(atitle:string;atitleform:tform);
var
   e,z:string;
begin

//self
inherited create;

//vars
opreview                    :=true;
ichangeid                   :=0;
iref                        :='';

ipasswordboxTEMP            :=nil;
ititleboxTEMP               :=nil;

iapptitle                   :=atitle;
ititleform                  :=atitleform;

ifont                       :=tfont.create;
ifont.name                  :='arial';
ifont.size                  :=10;

ibusy                       :=false;
imodified                   :=false;
icansave                    :=false;
icancelled                  :=false;

ipassToedit                 :=false;
ipassToview                 :=false;
ipassShow                   :=false;

iform                       :=tform.create(nil);
iform.parent                :=nil;
iform.width                 :=640;
iform.height                :=30;
iform.vertscrollbar.visible :=false;
iform.horzscrollbar.visible :=false;
iform.bordericons           :=[];
iform.borderstyle           :=bsnone;

idefTitle                   :='Your Title Here ( Edit > Details )';

app__addwndproc(iform.handle,nil,true);//count this form towards the gui list - 04oct2025


ifilename                   :=io__extractfilepath(io__exename)+'Untitled.exe';
ifilenameFilterlist         :=
 dialog__mask( translate('Text2EXE Documents')   ,'*.exe' )+
 dialog__mask( translate('Text2EXE Project')     ,'*.t2ep' )+
 dialog__mask( translate('Rich Text Documents')  ,'*.rtf' )+
 dialog__mask( translate('Text Documents')       ,'*.txt' );

icursorfilename             :=io__extractfilepath(io__exename)+'Untitled.ani';
icursorfilenameFilterlist   :=
  dialog__mask( translate('All Cursors')         ,'*.ani;*.cur;*.ico' )+
  dialog__mask( translate('Animated Cursor')     ,'*.ani' )+
  dialog__mask( translate('Static Cursor')       ,'*.cur' )+
  dialog__mask( translate('Icon')                ,'*.ico' );

isplashfilename              :=io__extractfilepath(io__exename)+'Untitled.png';
isplashfilenameFilterlist    :=
  dialog__mask( translate('All Images') ,'*.png;*.jpeg;*.jif;*.jpg;*.tga;*.bmp;*.dib;*.tea;*.tep' )+
  dialog__mask( translate('Portable Network Graphic') ,'*.png' )+
  dialog__mask( translate('JPEG Image') ,'*.jpeg;*.jif;*.jpg' )+
  dialog__mask( translate('TGA Image') ,'*.tga' )+
  dialog__mask( translate('Bitmap Image') ,'*.bmp' )+
  dialog__mask( translate('DIB Image') ,'*.dib' )+
  dialog__mask( translate('TEA Image') ,'*.tea' )+
  dialog__mask( translate('TEP Image') ,'*.tep' );

iaboutfilename               :=io__extractfilepath(io__exename)+'Untitled.png';
iaboutfilenameFilterlist     :=isplashfilenameFilterlist;


itoolbar:=tgenerictoolbar.create(iform);//09oct2025

with itoolbar do
begin

add('new',tepNew,'New document');
add('open',tepOpen,'Open document from file');
add('saveas',tepSaveAs,'Save document to file');

addsep;

add('undo',tepUndo,'Undo last text change');
add('cut',tepCut,'Cut selection to Clipboard');
add('copy',tepCopy,'Copy selection to Clipboard');
add('paste',tepPaste,'Paste text from Clipboard');
add('pastereplace',tepPaste,'Replace text with Clipboard');

addsep;
add('overview',tepInfo,'Toggle Overview Panel display');
add('details',tepTextWnd,'Edit document preferences');

addsep;

add2('brcolor',tep_borderColor20,
 'Set border color'+rcode+
 '* Click for color window'+rcode+
 '* Click and drag for screen color'
 );

add2('brsize-5',tep_shrink20,'Shrink border');
add2('brsize+5',tep_widen20,'Enlarge border');

add2('bgcolor',tep_backColor20,
 'Set background color'+rcode+
 '* Click for color window'+rcode+
 '* Click and drag for screen color'
 );

addsep;

add2('splash.test',tep_screen20,'Test Splash Screen');
add2('splash.set',tep_splashScreen20,'Open Splash Screen Graphic');

add2('about.set',tep_aboutWindow20,'Open About Window Graphic');
add2('cursor.set',tep_customCursor20,'Open Custom Cursor');

end;


//istatus
istatus:=tgenericstatus.create(iform);

istatus.add(170,'','password.set','Password options');
istatus.add(65,'','allowcopy.set','Copy options');

istatus.add(60,'','title.set','Edit document title');
istatus.add(70,'','author.set','Edit author details');

istatus.add( 80,'','splash.set','Open Splash Screen Graphic');
istatus.add( 80,'','about.set','Open About Window Graphic');
istatus.add( 120,'','cursor.set','Open Custom Cursor');
istatus.add( 120,'Ready','status','Work status');
istatus.l.align['status']:=0;//left

idoc:=texeviewer.create(true);

//overview window -----------------------------------------------------------
ioverview:=tgenericguiform.create(nil);
ioverview.caption:='Overview';
app__addwndproc(ioverview.handle,nil,false);
ioverview.hide;

with ioverview.gui do
begin

//Preferences
title('','Preferences');
line2('password.set','','Set Password preferences');
line2('allowcopy.set','','Set Copy preferences');
line2('title.set','','Edit document Title');
line2('author.set','','Edit document Author details');
line2('splash.set','','Open Splash Screen Graphic');
line2('about.set','','Open About Window Graphic');
line2('cursor.set','','Open Custom Cursor');

//Name
title('saveas','Name');
line2('{filename}saveas','','Save changes');
line2('run','Run Document','Run document (exe) and preview');

//Size
title('','Size');
npart;

//.exe
line('{exe}nil','');

//.rtf
line('{rtf}nil','');

//.txt
line('{txt}nil','');

//.space
npart;

//Status
title2('{status}saveas','Status','Save changes');
line2('{statusval}saveas','','Save changes');

end;


//events -----------------------------------------------------------------------
iform.onresize         :=_onresize;

itoolbar.oncmd          :=xcmd;
itoolbar.onmouse        :=xonmouse;

istatus.oncmd           :=xcmd;

ioverview.gui.oncmd      :=xcmd;

idoc.form.onaccept     :=_onacceptfiles;
idoc.richedit.onchange :=_onclick;


updatefont;
_onresize(self);
onhelp:=nil;
new(false,e);
xupdatebuttons;

//timer
low__timerset(self,_ontimer,600);

end;

destructor ttext2exe.destroy;
begin
try

//disconnect
disassociate;
low__timerdel(self,_ontimer);

//controls
freeobj(@ioverview);
freeobj(@itoolbar);
freeobj(@istatus);
freeobj(@idoc);
freeobj(@iform);
freeobj(@ifont);

//self
inherited destroy;

except;end;
end;

procedure ttext2exe.setfilename(x:string);
begin
ifilename:=strdefb( io__extractfilepath(x),io__extractfilepath(io__exename) )+strdefb(io__extractfilename(x),'Untitled.exe')
end;

procedure ttext2exe.xcmd(sender:tobject;const xcode:string);
label
   skipend;
var
   a:tbasicimage;
   b:tstr8;
   etmp,e,v:string;
   p,v32:longint;
   bol1,xok:boolean;

   function mv(const x:string):boolean;
   begin
   result:=strm(xcode,x,v,v32);
   end;

   function m(const x:string):boolean;
   begin
   result:=strmatch(x,xcode);
   end;

begin
try

//defaults
v      :='';
v32    :=0;
xok    :=true;
e      :=gecTaskfailed;
a      :=nil;
b      :=nil;

//get
if      m('new')              then xok:=new(true,e)
else if mv('new.default.')    then xok:=xnewdefault(true,v32,e)
else if m('open')             then xok:=uopen('',e)
else if m('open.desktop')     then xok:=uopen(io__windesktop,e)
else if m('save')             then xok:=save(e)
else if m('saveas')           then xok:=usave('',e)
else if m('saveas.desktop')   then xok:=usave(io__windesktop,e)
else if mv('save.default.')   then xsavedefault(v32)
else if m('run')              then urun
else if m('exit') then
   begin

   if (not busy) and okforopen then app__halt;

   end

else if m('undo')             then xok:=undo(e)
else if m('cut')              then xok:=cuttoclipboard(e)
else if m('copy')             then xok:=copytoclipboard(e)
else if m('paste')            then xok:=pastefromclipboard(e)
else if m('pastereplace')     then xok:=pastereplaceall(e)
else if m('selectall')        then selectall
else if m('font')             then ufont

else if m('details')          then udetails
else if m('password.set')     then udetails
else if m('allowcopy.set') then
   begin

   idoc.cancopy:=not idoc.cancopy;
   xnotsaved;

   end
else if m('title.set')        then udetails
else if m('author.set')       then udetails
else if mv('brstyle.')        then brstyle:=v
else if mv('brsize.')         then brsize:=v32
else if mv('brsize+')         then brsize:=brsize+v32
else if mv('brsize-')         then brsize:=brsize-v32
else if m('brcolor')          then ubordercolor
else if m('bgcolor')          then ucolor
else if m('author')           then doc.info
else if m('overview') then
   begin

   case ioverview.visible of
   true:ioverview.hide;
   else uoverview
   end;//case

   end
else if mv('pngdropmode.')    then pngDropMode:=v32
else if mv('runmode.')        then runmode:=v32

else if m('splash.test')      then doc.splash
else if m('splash.set')       then setcustomimage('splash',false)
else if m('splash.del') then
   begin

   if showquery('Remove Splash Screen Graphic?') then setcustomimage('splash',true);

   end
else if m('splash.copy') then
   begin

   a    :=misimg32(1,1);
   xok  :=mis__fromdata(a, @idoc.splashimage, etmp) and clip__copyimage(a);

   end
else if m('splash.paste') then
   begin

   a    :=misimg32(1,1);
   b    :=str__new8;

   xok  :=clip__pasteimage(a) and png__todata(a,@b,etmp);
   if xok then setcustomimage3('splash','',@b,false);

   end

else if m('splash.folder') then runlow(io__extractfilepath(isplashfilename),'')

else if m('about.test')       then doc.about
else if m('about.set')        then setcustomimage('about',false)
else if m('about.del') then
   begin

   if showquery('Remove About Window Graphic?') then setcustomimage('about',true);

   end
else if m('about.copy') then
   begin

   a    :=misimg32(1,1);
   xok  :=mis__fromdata(a, @idoc.aboutimage, etmp) and clip__copyimage(a);

   end
else if m('about.paste') then
   begin

   a    :=misimg32(1,1);
   b    :=str__new8;

   xok  :=clip__pasteimage(a) and png__todata(a,@b,etmp);
   if xok then setcustomimage3('about','',@b,false);

   end

else if m('about.folder') then runlow(io__extractfilepath(iaboutfilename),'')

else if m('cursor.set')       then setcustomimage('cursor',false)
else if m('cursor.del') then
   begin

   if showquery('Remove Custom Cursor?') then setcustomimage('cursor',true);

   end
else if m('cursor.folder') then runlow(io__extractfilepath(icursorfilename),'')
else if m('preview.auto') then opreview:=not opreview

else if (xcode<>'') then
   begin
   //nil
   end;

//successful
skipend:

except;end;

//free
freeobj(@a);
str__free(@b);

//show error
if not xok then showerror(e);

//apply changes immediately
_ontimer(self);

end;

function ttext2exe._onacceptfiles(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
var
   v,dext,e:string;
   a:tbasicimage;
   b:tstr8;
   c:lwin.tpoint;
begin

//defaults
result :=(xindex<=9);//allow upto 10 files
a      :=nil;
b      :=nil;

try
//get
if io__fileexists(xfilename) then
   begin

   dext:=io__readfileext_low(xfilename);

   if (dext='ico') or (dext='cur') or (dext='ani') then
      begin

      setcustomimage2('cursor',xfilename,false);

      end
   else if (dext='png') or (dext='jpg') or (dext='jif') or (dext='jpeg') or (dext='tga') or (dext='tea') or (dext='tep') or (dext='bmp') or (dext='dib') then
      begin

      //get
      case ipngDropmode of
      0:begin//automatic -> wide=splash, tall=about

         b    :=str__new8;
         if io__fromfile(xfilename,@b,e) and xmakepng(@b) then
            begin

            a:=misimg32(1,1);

            if png__fromdata(a,@b,e) then
               begin

               case (a.width>=round(1.3*a.height)) of
               true:v:='splash';
               else v:='about';
               end;//case

               end
            else v:='splash';

            end;
         end;
      1:begin//drag to: top-half=splash, bottom-half=about

         win____getcursorpos(c);

         case (c.y<=(idoc.form.top+(idoc.form.height div 2))) of
         true:v:='splash';
         else v:='about';
         end;//case

         end;
      2:v:='splash';
      else v:='about';
      end;//case

      //set
      setcustomimage2(v,xfilename,false);

      end
   else if (dext='txt') or (dext='rtf') then
      begin

      idoc.richedit.fromfile(xfilename,e);
      xnotsaved;

      end
   else if (dext='exe') or (dext='t2ep') then//19oct2025
      begin

      xfromfile(xfilename,e);
      xchanged;

      end;

   end;

except;end;

//free
freeobj(@a);
freeobj(@b);

end;

procedure ttext2exe.xonmouse(sender:tobject);
begin

if itoolbar.mousedragging and xgrabcolor and itoolbar.mouseupstroke then xnotsaved;

end;

function ttext2exe.xgrabcolor:boolean;
var
   v,v1,v2:longint;
begin

result :=true;
v1     :=idoc.brcolor;
v2     :=idoc.bgcolor;
v      :=low__cursorcolor;

if (itoolbar.list.itemcode='brcolor') then
   begin
   if (v<>idoc.brcolor) then idoc.brcolor:=v;
   end
else if (itoolbar.list.itemcode='bgcolor') then
   begin
   if (v<>idoc.bgcolor) then idoc.bgcolor:=v;
   end
else result:=false;

if (v1<>idoc.brcolor) or (v2<>idoc.bgcolor) then
   begin

   idoc.form.paintnow2(true);

   end;

end;

procedure ttext2exe._onresize(sender:tobject);
const
   sp=5;
var
   z,x,y,w,h:longint;
begin

w:=iform.clientwidth;
h:=itoolbar.height + istatus.height;

itoolbar.setbounds(0,0,w,0);

iform.setbounds(iform.left,iform.top,iform.width,(iform.height-iform.clientheight)+h);

end;

procedure ttext2exe.setbusy(x:boolean);
var
   ok:boolean;
   z:string;
begin

//init
ibusy                     :=x;

//get
ok                        :=not x;
iform.enabled             :=ok;
itoolbar.enabled          :=ok;

istatus.l.caption['status'] :=low__aorbstr('Ready','Working',ibusy);
istatus.enabled            :=ok;
istatus.paintnow;

app__processmessages;

//event
if assigned(fonbusy) then fonbusy(self);

//sync
xupdatebuttons;

end;

procedure ttext2exe.xupdatebuttons;
var
   z,x:string;
   bol1,xok:boolean;

   procedure ss(const xcode,xval:string);
   begin
   istatus.l.caption[xcode]:=xval;
   end;

   procedure ss2(const xcode,v1,v2:string;usev2:boolean);
   begin
   istatus.l.caption[xcode] :=low__aorbstr(v1,v2,usev2);
   istatus.l.marked[xcode]  :=usev2;
   end;

begin

//name
iname:=io__extractfilename(ifilename);

case (iname<>'') of
true:begin
   x:=iname+' - '+iapptitle;
   if imodified then x:='*'+x;
   end;
false:x:=iapptitle;
end;

if (application.title<>x) then application.title:=x;
if (ititleform<>nil) and (ititleform.caption<>x) then ititleform.caption:=x;


//toolbar
xok:=not busy;

with itoolbar.list do
begin

enabled['new']         :=xok;
enabled['open']        :=xok;
enabled['saveas']      :=xok;

enabled['undo']        :=xok and canundo;
enabled['cut']         :=xok and cancuttoclipboard;
enabled['copy']        :=xok and cancopytoclipboard;
enabled['paste']       :=xok and canpastefromclipboard;
enabled['details']     :=xok;

enabled['brcolor']     :=xok;
enabled['bgcolor']     :=xok;

enabled['splash.test'] :=xok and doc.cansplash;
enabled['splash.set']  :=xok;
enabled['about.set']   :=xok;
enabled['cursor.set']  :=xok;

enabled['brsize-5']    :=(brsize>0);
enabled['brsize+5']    :=(brsize<255);

marked['overview']     :=(ioverview<>nil) and ioverview.visible;

end;


//password
z:=xpasswordStatus;
ss2('password.set',z,z,passToedit or passToview);

bol1:=(password<>'');
istatus.l.flash['password.set']:=((passToedit or passToview) and (not bol1)) or (((not passToedit) and (not passToview)) and bol1);


//copy
ss2('allowcopy.set', translate('No Copy'), translate('Copy'), idoc.cancopy);

//title
ss2('title.set','No Title','Title',(title<>'') );
istatus.l.flash['title.set']:=strmatch(title,idefTitle);

//author
ss2('author.set','No Author','Author',author<>'');

//splash
ss2('splash.set', translate('No Splash'), translate('Splash'), hascustomimage('splash'));

//about
ss2('about.set', translate('No About'), translate('About'), hascustomimage('about'));

//cursor
ss2('cursor.set', translate('No Cursor'), translate('Cursor'), hascustomimage('cursor'));


//overview
if ioverview.visible then uoverview;

end;

function ttext2exe.xpasswordStatus:string;
begin

if      passToview  then result:=translate('Password to Edit + View')
else if passToedit  then result:=translate('Password to Edit')
else                     result:=translate('No Password');

end;

procedure ttext2exe.xnotsaved;
begin

imodified:=true;
xchanged;

end;

procedure ttext2exe.ubordercolor;
var
   x:longint;
begin

x:=idoc.brcolor;
if not dialog__color(x) then exit;

idoc.brcolor:=x;

xnotsaved;

end;

procedure ttext2exe.ucolor;
var
   x:longint;
begin

x:=idoc.bgcolor;
if not dialog__color(x) then exit;

idoc.bgcolor:=x;

xnotsaved;

end;

function ttext2exe.cansave:boolean;
begin
result:=icansave;
end;

function ttext2exe.save(var e:string):boolean;
label
     skipend;
begin

//defaults
result :=false;
busy   :=true;
e      :=gecTaskfailed;

try
//get
if not tofile(ifilename,e) then goto skipend;

//update
imodified  :=false;
icansave   :=true;

//successful
result:=true;
skipend:

except;end;

busy:=false;
xchanged;

end;

function ttext2exe.hascustomimage(n:string):boolean;
begin

n     :=strlow(n);

if      (n='cursor') then result:=idoc.cancursor
else if (n='splash') then result:=idoc.cansplash
else if (n='about')  then result:=idoc.canabout
else                      result:=false;

end;

procedure ttext2exe.setcustomimage(n:string;const nclear:boolean);
begin
setcustomimage2(n,'',nclear);
end;

procedure ttext2exe.setcustomimage2(n,xusethisfileInsteadOfPrompting:string;const nclear:boolean);
begin
setcustomimage3(n,xusethisfileInsteadOfPrompting,nil,nclear);
end;

procedure ttext2exe.setcustomimage3(n,xusethisfileInsteadOfPrompting:string;xusethisdataInsteadofPrompting:pobject;const nclear:boolean);
label
   skipdone,skipend;
var
   stitle,sname,slist,e:string;
   sdata:tstr8;
begin

//defaults
e     :=gecTaskfailed;
n     :=strlow(n);
sdata :=nil;

try
//get
if (n='cursor') then
   begin

   sname  :=icursorfilename;
   slist  :=icursorfilenameFilterlist;
   stitle :='Open Custom Cursor';
   if nclear then
      begin

      idoc.cursor__setimagedata(nil);
      goto skipdone;

      end;

   end
else
   begin


   case (n='splash') of
   true:begin

      sname  :=isplashfilename;
      slist  :=isplashfilenameFilterlist;
      stitle :='Open Splash Screen Graphic';

      end;
   else begin

      sname  :=iaboutfilename;
      slist  :=iaboutfilenameFilterlist;
      stitle :='Open About Window Graphic';

      end;
   end;//case

   if nclear then
      begin

      case (n='splash') of
      true:idoc.splash__setimagedata(nil);
      else idoc.about__setimagedata(nil);
      end;//case

      goto skipdone;

      end;

   end;

//prompt for filename
if (xusethisdataInsteadofPrompting<>nil) then
   begin

   sdata :=str__new8;
   str__add(@sdata,xusethisdataInsteadofPrompting);

   end
else
   begin

   case (xusethisfileInsteadOfPrompting<>'') of
   true:sname:=xusethisfileInsteadOfPrompting;
   else if not dialog__open2(sname,slist,stitle) then goto skipdone;
   end;

   //load
   sdata :=str__new8;
   if not io__fromfile(sname,@sdata,e) then goto skipend;

   end;

//set
if (n='cursor') then
   begin

   if (xusethisfileInsteadOfPrompting='') then
      begin
      icursorfilename           :=sname;
      icursorfilenameFilterlist :=slist;
      end;
   idoc.cursor__setimagedata(@sdata);

   end
else
   begin

   //as png
   if not xmakepng(@sdata) then goto skipend;

   //set
   case (n='splash') of
   true:begin

      if (xusethisfileInsteadOfPrompting='') then
         begin
         isplashfilename            :=sname;
         isplashfilenameFilterlist  :=slist;
         end;

      idoc.splash__setimagedata(@sdata);
      if idoc.cansplash and opreview then idoc.splash;

      end;
   else begin

      if (xusethisfileInsteadOfPrompting='') then
         begin
         iaboutfilename            :=sname;
         iaboutfilenameFilterlist  :=slist;
         end;

      idoc.about__setimagedata(@sdata);
      if idoc.canabout and opreview then idoc.about;

      end;
   end;//case

   end;


//succesful
skipdone:
e:='';
xnotsaved;

skipend:

except;end;

//free
str__free(@sdata);

//show error
if (e<>'') then showerror2(e,5);

end;

function ttext2exe.xmakepng(a:pobject):boolean;
label
   skipend;
var
   s:tbasicimage;
   e,str1,xformat:string;
   xbase64:boolean;
begin

//defaults
result :=false;
s      :=nil;

try
//check
if not str__lock(a) then goto skipend;

//detect image format
if not mis__format(a,xformat,xbase64)then goto skipend;

//convert image to png
if not strmatch(xformat,'png') then
   begin

   s:=misimg32(1,1);

   if not mis__fromdata(s,a,e) then goto skipend;
   if not png__todata4(s,a,32,str1,e) then goto skipend;

   end;

//successful
result:=true;
skipend:

except;end;

//free
freeobj(@s);
str__uaf(a);

end;

function ttext2exe.ucanrun:boolean;
begin
result:=icansave and (not imodified) and strmatch(io__readfileext(ifilename,false),'exe');
end;

procedure ttext2exe.urun;
begin

if ucanrun then
   begin

   case irunmode of
   1:begin
      application.minimize;
      app__showall(false,false);
      end;
   end;//case

   runlow(ifilename,'');

   end;

end;

function ttext2exe.usave(const xnewpath:string;var e:string):boolean;
var
   df:string;
begin

//defaults
result         :=false;
e              :=gectaskfailed;

//adjust folder destination
case (xnewpath<>'') of
true:df:=io__asfolder(xnewpath)+io__extractfilename(ifilename);
else df:=ifilename;
end;//case

//prompt for filename
if not dialog__save(df,ifilenamefilterlist) then
   begin

   result:=true;
   exit;

   end;

//save
busy:=true;
ifilename:=df;

if tofile(df,e) then
   begin

   imodified       :=false;
   icansave        :=true;

   //successful
   result          :=true;

   end;

busy:=false;
xchanged;

end;

procedure ttext2exe.xsavedefault(const xid:longint);
var
   e:string;
begin

busy :=true;
tofile( app__settingsfile('default'+intstr32(xid)+'.t2ep') ,e );
busy :=false;

end;

procedure ttext2exe.xloaddefault(const xid:longint);
var
   e:string;
begin

busy :=true;
xfromfile( app__settingsfile('default'+intstr32(xid)+'.t2ep') ,e );

imodified  :=false;
icansave   :=false;
ifilename  :=io__extractfilepath(ifilename)+'Untitled.exe';

busy :=false;
xchanged;

end;

function ttext2exe.xhavedefault(const xid:longint):boolean;
begin
result:=io__fileexists( app__settingsfile('default'+intstr32(xid)+'.t2ep') );
end;

function ttext2exe.uopen(const xnewpath:string;var e:string):boolean;
label
   redo;
var
   df:string;
   xaskonce:boolean;
begin

//defaults
result         :=false;
e              :=gectaskfailed;
xaskonce       :=true;

//adjust folder destination
case (xnewpath<>'') of
true:df:=io__asfolder(xnewpath)+io__extractfilename(ifilename);
else df:=ifilename;
end;//case

//prompt for filename
redo:
icancelled     :=false;

if not dialog__open(df,ifilenamefilterlist) then
   begin

   result:=true;
   exit;

   end;

//prompt to save changes
if xaskonce and (not okforopen) then
   begin

   result:=true;
   exit;

   end;

//open
busy       :=true;
xaskonce   :=false;
result     :=fromfile(df,e);

if not result then
   begin

   if not strmatch(e,gecTaskCancelled) then showerror(e);

   busy:=false;
   goto redo;

   end;

//sync -> only if successfully loaded
if not icancelled then ifilename:=df;

//stop
busy:=false;
xchanged;

end;

function ttext2exe.okforopen:boolean;
var
   e:string;
begin

//defaults
result:=false;

//prompt user to save changes
if imodified then
   begin

   case byte(showYNC(translate('Save Changes to')+' '+io__ExtractFileName(iFileName)+'?')) of
   lln :imodified:=false;
   llc :exit;
   lly :if not usave('',e) then showerror(e);
   end;//case

   end;

result:=not imodified;

end;

function ttext2exe.new(prompt:boolean;var e:string):boolean;
label
     skipend;
begin

//defaults
result          :=false;
e               :=gecunexpectederror;

//prompt
if prompt and (not okforopen) then
   begin

   result:=true;
   goto skipend;

   end;

//update undo
busy:=true;
clear;
center;
imodified  :=false;
icansave   :=false;
ifilename  :=io__extractfilepath(ifilename)+'Untitled.exe';
xchanged;

//successful
result:=true;
skipend:

busy:=false;

end;

function ttext2exe.xnewdefault(prompt:boolean;const xid:longint;var e:string):boolean;
label
     skipend;
begin

//defaults
result          :=false;
e               :=gecunexpectederror;

//prompt
if prompt and (not okforopen) then
   begin

   result:=true;
   goto skipend;

   end;

//update undo
busy:=true;
clear;
xloaddefault(xid);
center;
imodified :=false;
icansave  :=false;
ifilename :=io__extractfilepath(ifilename)+'Untitled.exe';
xchanged;

//successful
result:=true;
skipend:

busy:=false;

end;

procedure ttext2exe.setpassword(x:string);
begin

//check
if (x=password) then exit;

//set
idoc.password  :=x;
xnotsaved;

end;

function ttext2exe.getpassword:string;
begin
result:=idoc.password;
end;

procedure ttext2exe.setcancopy(x:boolean);
begin

if (x=cancopy) then exit;
idoc.cancopy:=x;
xupdatebuttons;

end;

function ttext2exe.getcancopy:boolean;
begin
result:=idoc.cancopy;
end;

procedure ttext2exe.setautotitle(x:boolean);
begin

if (x=autotitle) then exit;
idoc.autotitle:=x;
xupdatebuttons;

end;

function ttext2exe.getautotitle:boolean;
begin
result:=idoc.autotitle;
end;

procedure ttext2exe.selectall;
begin
win____sendmessage(idoc.richedit.handle,em_setsel,0,-1);
end;

procedure ttext2exe.settitle(x:string);
begin

if (x=title) then exit;
idoc.form.text:=x;
xnotsaved;

end;

function ttext2exe.gettitle:string;
begin
result:=idoc.form.text;
end;

procedure ttext2exe.setauthor(x:string);
begin

if (x=author) then exit;
idoc.author:=x;
xnotsaved;

end;

function ttext2exe.getauthor:string;
begin
result:=idoc.author;
end;

procedure ttext2exe.setonhelp(x:tnotifyevent);
begin

fonhelp                  :=x;
itoolbar.l.enabled['help'] :=canhelp;

end;

procedure ttext2exe._onclick(sender:tobject);
begin

if (sender=idoc.richedit) then
   begin

   xnotsaved;

   end;

end;

procedure ttext2exe.xchanged;
begin

low__irollone(ichangeid);
if assigned(fonchange) then fonchange(self);

end;

procedure ttext2exe._ontimer(sender:tobject);
begin

if low__setstr(iref,bolstr(ioverview.visible)+'|'+intstr32(ichangeid)) then xupdatebuttons;

end;

function ttext2exe.tostr(var x,e:string;const xfilenameForRef:string;xpromptforPassword:boolean):boolean;
begin

//defaults
result        :=false;
e             :=gecTaskfailed;
x             :='';

if not idoc.writetostr(x,e,xfilenameForRef,passtoEdit,passtoView,xpromptforPassword) then exit;

//successful
result:=true;

end;

function ttext2exe.xexehead:string;
var
   a:tstr8;
begin

//defaults
result:='';

try

//get
a:=nil;
a:=str__new8;
a.aadd(file__exeview_exe);
low__decompress(@a);

if (a.len<5000) then showerror2('EXE Viewer is damaged',5);//04oct2025

//set
result:=a.text;
except;end;

//free
freeobj(@a);

end;

function ttext2exe.tofile(const x:string;var e:string):boolean;
label
   skipend;
var
   v:tfastvars;
   de,z:string;

   function vadd(const xname,xdata:string):boolean;
   var
      s,d:tstr8;
   begin

   //defaults
   result :=false;

   try
   //check
   if (v=nil) or (xname='') then exit;

   //init
   s      :=str__new8;
   d      :=str__new8;

   //get
   s.text:=xdata;

   if str__tob64(@s,@d,0) then
      begin

      s.clear;
      v.s[xname] :=d.text;
      result     :=true;

      end;

   except;end;

   //free
   str__free(@s);
   str__free(@d);

   end;

begin

//defaults
result          :=false;
e               :=gecTaskfailed;
v               :=nil;

try
//init
de:=strlow( io__readfileext(x,false) );

//get
if (de='exe') then
   begin

   //only replace known exe types -> e.g. those with our io__exemarker present
   if not idoc.xcanreplaceexe(x,e) then exit;

   //create
   if not tostr(z,e,x,true) then goto skipend;

   e             :=gecoutofmemory;
   z             :=xexehead + io__exemarkerb + z;

   end

else if (de='rtf') then
   begin

   if not idoc.richedit.tostr(z,e,true) then goto skipend;

   end

else if (de='t2ep') then
   begin

   //init
   v             :=tfastvars.create;

   //settings
   v.s['format']         :='t2ep';
   v.s['brstyle']        :=idoc.brstyle;
   v.i['brsize']         :=idoc.border;
   v.i['brcolor']        :=idoc.brcolor;
   v.i['bgcolor']        :=idoc.bgcolor;
   v.b['allowcopy']      :=idoc.cancopy;
   v.i['width']          :=idoc.form.width;
   v.i['height']         :=idoc.form.height;
   v.b['pass.toedit']    :=passtoedit;
   v.b['pass.toview']    :=passtoview;
   v.b['pass.show']      :=passshow;
   v.s['title']          :=idoc.form.text;
   v.b['autotitle']      :=idoc.autotitle;
   v.s['s.filename']     :=io__makeportablefilename(splashFilename);
   v.s['a.filename']     :=io__makeportablefilename(aboutFilename);
   v.s['c.filename']     :=io__makeportablefilename(cursorFilename);

   //rtf
   if not idoc.richedit.tostr(z,e,true) then goto skipend;
   if not vadd('rtf',z)                 then goto skipend;

   //author
   if not vadd('author',idoc.author)    then goto skipend;

   //splash.png
   if not vadd('splash.png',idoc.splashimage.text) then goto skipend;

   //about.png
   if not vadd('about.png',idoc.aboutimage.text)   then goto skipend;

   //cursor.cur
   if not vadd('cursor.cur',idoc.cursorimage.text) then goto skipend;

   //v -> str
   z:=v.text;

   end

else begin//txt

   if not idoc.richedit.tostr(z,e,false) then goto skipend;

   end;

//save
if not io__tofilestr(x,z,e) then exit;

//successful
result:=true;
skipend:
except;end;

//free
freeobj(@v);

end;

function ttext2exe.fromfile(const x:string;var e:string):boolean;
begin

result:=xfromfile(x,e);
if result then
   begin

   //updatestatus
   imodified  :=false;
   icansave   :=true;
   ifilename  :=x;
   xchanged;

   end;

end;

function ttext2exe.xfromfile(const x:string;var e:string):boolean;
label
   skipend;
var
   b:tstr8;
   v:tfastvars;
   de,etmp:string;
   dpasstoEdit,dpasstoView:boolean;

   function vget(const xname:string):string;
   var
      s,d:tstr8;
   begin

   //defaults
   result :='';
   s      :=nil;
   d      :=nil;

   try
   //check
   if (v=nil)            then exit;
   if not v.found(xname) then exit;

   //init
   s      :=str__new8;
   d      :=str__new8;

   //get
   s.text :=v.s[xname];
   if str__fromb64(@s,@d) then result:=d.text;

   except;end;

   //free
   freeobj(@s);
   freeobj(@d);

   end;

begin

//defaults
result      :=false;
icancelled  :=false;
e           :=gecTaskfailed;
b           :=nil;
v           :=nil;

try
//init
de:=strlow( io__readfileext(x,false) );

//get
if (de='exe') then
   begin

   //get
   if (not idoc.readfromexe(x,e,dpasstoEdit,dpasstoView)) and (not xfromfile_v1(x,e)) then
      begin
      if strmatch(e,gecdatacorrupt) then e:=gecunknownformat;
      if icancelled then result:=true;

      exit;
      end;

   //password modes
   ipasstoEdit:=dpasstoEdit;
   ipasstoView:=dpasstoView;

   end

else if (de='t2ep') then//19oct2025
   begin

   //init
   v             :=tfastvars.create;
   v.text        :=io__fromfilestr2(x);
   b             :=str__new8;

   //check
   if not strmatch(v.s['format'],'t2ep') then
      begin

      e:=gecUnknownFormat;
      goto skipend;

      end;

   //rtf
   idoc.richedit.fromstr(vget('rtf'),etmp);

   //author
   idoc.author:=vget('author');

   //splash.png
   b.text:=vget('splash.png');
   idoc.splash__setimagedata(@b);

   //about.png
   b.text:=vget('about.png');
   idoc.about__setimagedata(@b);

   //cursor.cur
   b.text:=vget('cursor.cur');
   idoc.cursor__setimagedata(@b);

   //settings
   idoc.brstyle          :=v.s['brstyle'];
   idoc.border           :=v.i['brsize'];
   idoc.brcolor          :=v.i['brcolor'];
   idoc.bgcolor          :=v.i['bgcolor'];
   idoc.cancopy          :=v.b['allowcopy'];
   idoc.form.width       :=frcmin32(v.i['width'],32);
   idoc.form.height      :=frcmin32(v.i['height'],32);
   passtoedit            :=v.b['pass.toedit'];
   passtoview            :=v.b['pass.toview'];
   passshow              :=v.b['pass.show'];
   idoc.form.text        :=v.s['title'];
   idoc.autotitle        :=v.b['autotitle'];
   v.s['s.filename']     :=io__readportablefilename(v.s['s.filename']);
   v.s['a.filename']     :=io__readportablefilename(v.s['a.filename']);
   v.s['c.filename']     :=io__readportablefilename(v.s['c.filename']);

   end

//rtf / txt
else if not idoc.richedit.fromfile(x,e) then exit;


//preview
if (de='exe') or (de='t2ep') then
   begin

   if opreview then idoc.splash;

   end;

//successful
result:=true;
skipend:

except;end;

//free
str__free(@b);
freeobj(@v);

end;

function ttext2exe.xfromfile_v1(const xfilename:string;var e:string):boolean;
label
   skipend;
const
   v1header  ='T2Ev1';
   v1scanpos =53300;//base position for header of documents v1.00.162
var
   dl,dw,dh,xpos:longint;
   xtitle,xauthor,x,v,a,b,etmp:string;
   xcancopy:boolean;
   c:twinrect;

   function xreadval(var xpos:longint;const x:string;var xval:string):boolean;
   var//v2 - returns an error if past eot
      xlen:longint;
   begin

   //defaults
   result :=false;
   xval   :='';

   try
   //range
   if (xpos<1) then xpos:=1;

   //check
   if (xpos>low__len(x)) then exit;

   //init
   xlen   :=str__to32(strcopy1(x,xpos,4));
   inc(xpos,4);
   if (xlen<0) then exit;

   //get
   xval   :=strcopy1(x,xpos,xlen);
   inc(xpos,xlen);

   //successful
   result :=( xlen = low__len(xval) );

   except;end;
   end;

   function xfindheader(const x:string;var xpos:integer):boolean;
   var
      a:char;
      tmp,p,xlen,hlen:longint;
   begin

   //defaults
   result :=false;
   xpos   :=0;

   try
   //init
   xlen   :=low__len(x);
   hlen   :=low__len(v1header);
   if (xlen<1) or (hlen<1) then exit;
   a      :=v1header[1];

   //scan
   for p:=v1scanpos to xlen do if (x[p-1+stroffset]=a) and (strcopy1(x,p,hlen)=v1header) then
      begin

      tmp:=p-4;

      if (tmp>=1) then
         begin

         //successful
         xpos   :=tmp;
         result :=true;
         break;

         end;

      end;//p

   except;end;
   end;

begin

//defaults
result      :=false;
e           :=gecTaskfailed;
xpos        :=1;

try
//from file
x           :=io__fromfilestr2(xfilename);

//find header
if not xfindheader(x,xpos) then goto skipend;

//header
if not xreadval(xpos,x,b) and (b<>v1header) then goto skipend;

//other
e           :=gecDataCorrupt;
if not xreadval(xpos,x,b) then goto skipend;

//decrypt section [pass v|data len|data]
b           :=str__ecap2(b,false,true);
xpos        :=1;
if (b='') then goto skipend;

//title
if not xreadval(xpos,b,a) then goto skipend;
xtitle:=a;

//Author
if not xreadval(xpos,b,a) then goto skipend;
xauthor:=a;

//CanCopy
if not xreadval(xpos,b,a) then goto skipend;
xcancopy:=strbol(a);

//width
if not xreadval(xpos,b,a) then goto skipend;
dw:=strint32(a);

//Height
if not xreadval(xpos,b,a) then goto skipend;
dh:=strint32(a);

//password verification
if not xreadval(xpos,b,a) then goto skipend;

if (a<>'') then
   begin

   v:='';
   dialog__password(v);
   if (v<>a) then
      begin

      e:=gecAccessDenied;
      goto skipend;

      end;

   password:=v;

   end;

//clear ------------------------------------------------------------------------
clear;

//get --------------------------------------------------------------------------
idoc.cancopy   :=xcancopy;
idoc.author    :=xauthor;
idoc.form.text :=xtitle;
idoc.brstyle   :='flat';
idoc.brcolor   :=rgba0__int(128,128,128);

//bgcolor
if not xreadval(xpos,b,a) then goto skipend;
idoc.bgcolor:=strint32(a);

//border
if not xreadval(xpos,b,a) then goto skipend;
idoc.border:=strint32(a);

//data len
if not xreadval(xpos,b,a) then goto skipend;
dl:=strint32(a);
if (dl<0) then goto skipend;

//data
if not xreadval(xpos,b,a) then goto skipend;
b:='';
a:=strcopy1(a,1,dl);

if not idoc.richedit.fromstr(a,etmp) then
   begin

   e:=etmp;
   goto skipend;

   end;

//size
idoc.form.width       :=frcmin32(dw,32);
idoc.form.height      :=frcmin32(dh,32);

//successful
result:=true;
skipend:

except;end;
end;

procedure ttext2exe.clear;
begin

idoc.clear;
title              :=idefTitle;

end;

procedure ttext2exe.show;
begin
form__centerByCursor(idoc.form);
idoc.form.show;
end;

procedure ttext2exe.hide;
begin
idoc.form.hide;
end;

procedure ttext2exe.center;
begin
form__centerbymainform(idoc.form);
end;

function ttext2exe.cancopytoclipboard:boolean;
begin
result:=idoc.richedit.cancopytoclipboard;
end;

function ttext2exe.copytoclipboard(var e:string):boolean;
begin

busy:=true;
result:=idoc.richedit.copytoclipboard(e);
busy:=false;

end;

function ttext2exe.canundo:boolean;
begin
result:=imodified and bool(win____sendmessage(idoc.richedit.handle,em_canundo,0,0));
end;

function ttext2exe.undo(var e:string):boolean;
begin

//defaults
result        :=false;
e             :=gecTaskfailed;

if not canundo then exit;

busy          :=true;
result        :=bool(win____sendmessage(idoc.richedit.handle,wm_undo,0,0));
busy          :=false;
xchanged;;

end;

function ttext2exe.cancuttoclipboard:boolean;
begin
result:=idoc.richedit.cancopytoclipboard;
end;

function ttext2exe.cuttoclipboard(var e:string):boolean;
begin

//defaults
result :=false;
e      :=gecTaskfailed;

busy   :=true;
win____sendmessage(idoc.richedit.handle,wm_cut,0,0);
xnotsaved;
result :=true;
busy   :=false;

end;

function ttext2exe.canpastefromclipboard:boolean;
var
   x:longint;
begin

//defaults
result:=false;

//get
x:=win____sendmessage(idoc.richedit.handle,em_canpaste,cf_text,0);

if (x=0) then
   begin
   x:=win____sendmessage(idoc.richedit.handle,em_canpaste,0,0);
   if (x=0) then exit;
   end;

//successful
result:=true;

end;

function ttext2exe.pastefromclipboard(var e:string):boolean;
var
   x:integer;
begin

//defaults
result         :=false;
e              :=gecTaskfailed;

//check
if not canpastefromclipboard then exit;

//get
busy:=true;
x:=win____sendmessage(idoc.richedit.handle,em_pastespecial,0,0);//rtf
if (x<>0) then x:=win____sendmessage(idoc.richedit.handle,em_pastespecial,cf_text,0);

//updatestatus
xnotsaved;

//successful
result:=(x=0);

busy:=false;

end;

function ttext2exe.pastereplaceall(var e:string):boolean;//05oct2025
begin

selectall;
result:=pastefromclipboard(e);

end;

function ttext2exe.getbrsize:longint;
begin
result:=idoc.border;
end;

procedure ttext2exe.setbrsize(x:longint);
begin

if (x=brsize) then exit;
idoc.border:=x;
xnotsaved;

end;

function ttext2exe.getbrstyle:string;
begin
result:=idoc.brstyle
end;

procedure ttext2exe.setbrstyle(x:string);
begin

if (x=brstyle) then exit;
idoc.brstyle:=x;
xnotsaved;

end;

procedure ttext2exe.setpngDropmode(x:longint);
begin
ipngDropmode:=frcrange32(x,0,3);
end;

procedure ttext2exe.setrunmode(x:longint);
begin
irunmode:=frcrange32(x,0,1);
end;

procedure ttext2exe.udetails;
label
   redo;
const
   sp=8;
var
   a:tform;
   xpassword,xtitle:tedit;
   e:tmemo;
   xautoTitle,xpassShow,xpassToedit,xpassToview,xallowCopy:tcheckbox;
   af,f:tpanel;
   b1,b2:tbutton;

   function nl(const xlabel:string):tlabel;//new label
   begin

   result:=tlabel.create(af);
   result.parent:=af;
   result.caption:=xlabel;
   result.tag:=controls_id(af);
   result.visible:=true;
   gui__stdcursor(result);

   end;

   function ne(const xtext:string):tedit;//new edit
   begin

   result:=tedit.create(af);
   result.parent:=af;
   result.tag:=controls_id(af);
   result.text:=xtext;
   gui__stdcursor(result);

   end;

   function nc(const xlabel:string;const xval:boolean):tcheckbox;//new checkbox
   begin

   result:=tcheckbox.create(af);
   result.parent:=af;
   result.tag:=controls_id(af);
   result.caption:=xlabel;
   result.checked:=xval;
   gui__stdcursor(result);

   end;

begin

redo:

try

//init

//a
a:=nil;
a:=tform.create(nil);
a.font.name:=app__info('app.fontname');
a.font.size:=strint32(app__info('app.fontsize'));
a.borderstyle:=bssingle;
a.bordericons:=[bisystemmenu];
a.vertscrollbar.visible:=false;
a.horzscrollbar.visible:=false;
a.width:=500;
a.height:=400;
a.caption:='Details';
gui__stdcursor(a);

//af
af:=tpanel.create(a);
af.parent:=a;
af.bevelinner:=bvnone;
af.bevelouter:=bvnone;
af.caption:='';
af.visible:=true;
af.align:=alclient;
gui__stdcursor(af);

//title
nl(translate('Title'));
xtitle:=ne(title);
xtitle.enabled:=not autotitle;;

//user preferences
nl(translate('Preferences'));

//g
xautoTitle   :=nc( translate('Title from filename'), autoTitle );
xallowCopy   :=nc( translate('Allow copy'), cancopy );
xpassToedit  :=nc( translate('Require password to edit'), passtoEdit );
xpassToview  :=nc( translate('Require password to edit and view'), passtoView );
xpassShow    :=nc( translate('Show password'), passShow );

nl(translate('Password'));
xpassword:=ne(password);
xpassword.passwordchar:=low__aorbstr('*',#0,passshow)[1];

//d
nl('Author Details');

//e
e:=tmemo.create(af);
e.parent:=af;
e.tag:=controls_id(af);
e.text:=author;
e.wordwrap:=false;
e.scrollbars:=ssboth;
gui__stdcursor(e);

//f
f:=tpanel.create(a);
f.parent:=a;
f.bevelinner:=bvnone;
f.bevelouter:=bvnone;
f.caption:='';
f.visible:=true;
f.align:=albottom;
gui__stdcursor(f);

//b1
b2:=tbutton.create(f);
b2.parent:=f;
b2.caption:=translate('Apply');
b2.modalresult:=mrok;
b2.width:=130;
b2.top:=sp;
b2.left:=f.clientwidth-b2.width-sp;
b2.default:=true;
gui__stdcursor(b2);

//b1
b1:=tbutton.create(f);
b1.parent:=f;
b1.caption:=translate('Cancel');
b1.modalresult:=mrcancel;
b1.cancel:=true;//10oct2025
b1.width:=b2.width;
b1.top:=b2.top;
b1.left:=b2.left-b1.width-sp;
gui__stdcursor(b1);

//f cont.
f.height:=b2.top+b2.height+sp;

//size
controls_auto_size(af,true,sp);

//center and show

ipasswordboxTEMP   :=xpassword;
xpassShow.onclick  :=_onpassshow;

ititleboxTEMP      :=xtitle;
xautoTitle.onclick  :=_ontitleauto;

form__centerbymainform(a);
a.showmodal;

if (a.modalresult=mrok) then
   begin

   title       :=xtitle.text;
   autotitle   :=xautotitle.checked;
   password    :=xpassword.text;
   author      :=e.text;
   cancopy     :=xallowCopy.checked;
   passToedit  :=xpassToedit.checked;
   passToview  :=xpassToview.checked;
   passShow    :=xpassShow.checked;

   end;

except;end;

//free
freeobj(@a);
ipasswordboxTEMP :=nil;
ititleboxTEMP    :=nil;

xchanged;

end;

procedure ttext2exe._onpassshow(sender:tobject);
begin

if (ipasswordboxTEMP<>nil) and (sender is tcheckbox) then ipasswordboxTEMP.passwordchar:=low__aorbstr('*',#0,(sender as tcheckbox).checked)[1];

end;

procedure ttext2exe._ontitleauto(sender:tobject);
begin

if (ititleboxTEMP<>nil) and (sender is tcheckbox) then ititleboxTEMP.enabled:=not (sender as tcheckbox).checked;

end;

function ttext2exe.canhelp:boolean;
begin
result:=assigned(fonhelp);
end;

function ttext2exe.help(var e:string):boolean;
label
     skipend;
begin

//defaults
result        :=false;
e             :=gecunexpectederror;

try
//check
if not canhelp then goto skipend;

//get
if assigned(fonhelp) then
   begin

   busy:=true;
   fonhelp(self);

   end;

//successful
result:=true;
skipend:
except;end;

busy:=false;

end;

procedure ttext2exe.disassociate;
begin

if (iform<>nil) then
   begin

   iform.hide;
   iform.parent:=nil;

   end;

end;

procedure ttext2exe.ufont;
begin
{
if dialog__font(ifont) then
   begin

   updatefont;
   imodified:=true;
   updatestatus;

   end;
}
end;

procedure ttext2exe.updatefont;
//var
//   z:TCharFormatA;
begin
{
low__cls(@z,sizeof(z));
z.cbSize       :=sizeof(z);
z.dwMask       :=CFM_COLOR;
z.crTextColor  :=ifont.color;
//z.szFaceName   :=ifont.facename;

win____sendmessage(idoc.richedit.handle,EM_SETCHARFORMAT,SCF_SELECTION,lparam(@z));
}
end;

procedure ttext2exe.about;
begin
idoc.about;
end;

function ttext2exe.bas(x:longint;d:string):string;//bytes as string
begin

result:=d+':'+#32;

case (x>=1000) of
true:result:=result+low__mbb(x,3,false)+' Mb';
else result:=result+low__b(x,false)+' bytes';
end;//case

end;

procedure TText2EXE.uoverview;
var
   x,e:string;
begin
try

//update values using codes ----------------------------------------------------

with ioverview.gui do
begin

bcaption['password.set']       :=xpasswordStatus;
bcaption['allowcopy.set']      :=low__aorbstr('Disallow copy','Allow copy',idoc.CanCopy);
bcaption['title.set']          :=bas(low__len(self.title),'Title');
bcaption['author.set']         :=bas(low__len(idoc.author),'Author');
bcaption['splash.set']         :=bas(idoc.splashimage.len,'Splash');
bcaption['about.set']          :=bas(idoc.aboutimage.len,'About');
bcaption['cursor.set']         :=bas(idoc.cursorimage.len,'Cursor');


//Name
bcaption['{filename}saveas']   :=io__extractfilename(filename);
benabled['run']                :=ucanrun;

//Size
//.exe
tostr(x,e,'',false);
bcaption['{exe}nil']          :=bas(low__len(xexehead + io__exemarkerb + x),'EXE');

//.rtf
idoc.RichEdit.tostr(x,e,true);
bcaption['{rtf}nil']          :=bas(low__len(x),'RTF');

//.txt
idoc.RichEdit.tostr(x,e,false);
bcaption['{txt}nil']          :=bas(low__len(x),'TXT');

//status
case icansave of
true:x:=low__aorbstr('Not Saved','Saved',not imodified);
else x:=low__aorbstr('Not Saved','No Changes',not imodified);
end;//case

bcaption['{statusval}saveas'] :=x;

end;


//center and show
if (not ioverview.visible) and (form1<>nil) then
   begin

   ioverview.left   :=form1.left;
   ioverview.top    :=form1.top+form1.height;

   end;

//update
ioverview.gui.paintnow;

//show
if not ioverview.visible then
   begin

   ioverview.show;
   xchanged;

   end;

except;end;
end;

procedure tform1.xcmd(sender:tobject;const xcode:string);
label
   skipend;
var
   e,n,v:string;
   p,v32:longint;
   xcancopy,xcanpaste,bol1,xok:boolean;

   function mv(const x:string):boolean;
   begin
   result:=strm(xcode,x,v,v32);
   end;

   function m(const x:string):boolean;
   begin
   result:=strmatch(x,xcode);
   end;

begin
try

//defaults
v      :='';
v32    :=0;
xok    :=false;
e      :=gecTaskfailed;


//get

if m('file') then
   begin

   for p:=1 to 3 do imenu.enabled['new.default.'+intstr32(p)]:=itext2exe.xhavedefault(p);

   imenu.enabled['save']             :=itext2exe.cansave;
   imenu.enabled['run']              :=itext2exe.ucanrun;

   end

else if m('edit') then
   begin

   imenu.enabled['undo']         :=itext2exe.canundo;
   imenu.enabled['cut']          :=itext2exe.cancuttoclipboard;
   imenu.enabled['copy']         :=itext2exe.cancopytoclipboard;

   bol1                          :=itext2exe.canpastefromclipboard;
   imenu.enabled['paste']        :=bol1;
   imenu.enabled['pastereplace'] :=bol1;

   imenu.checked['overview']     :=itext2exe.overview.visible;

   end

else if m('border') then
   begin

   //.border size
   for p:=0 to t2ebExtraLarge do imenu.checked['brsize.'+intstr32(p)]:=(p=itext2exe.brsize);

   imenu.enabled['brsize+5']     :=(itext2exe.brsize<255);
   imenu.enabled['brsize-5']     :=(itext2exe.brsize>=1);

   for p:=0 to max16 do
   begin

   case form__brstyles(p,n,v) of
   true:imenu.checked['brstyle.'+v]:=strmatch(itext2exe.brstyle,v);
   else break;
   end;//case

   end;//p

   end

else if m('options') then
   begin

   for p:=0 to 3 do imenu.checked['pngdropmode.'+intstr32(p)]  :=(p=itext2exe.pngdropmode);

   for p:=0 to 1 do imenu.checked['runmode.'+intstr32(p)]      :=(p=itext2exe.runmode);

   end

else if m('advanced') then
   begin

   //.splash
   xcancopy                        :=itext2exe.hascustomimage('splash');
   xcanpaste                       :=clip__canpasteimage;

   imenu.enabled['splash.test']    :=itext2exe.doc.cansplash;
   imenu.enabled['splash.del']     :=xcancopy;
   imenu.enabled['splash.copy']    :=xcancopy;
   imenu.enabled['splash.paste']   :=xcanpaste;

   //.about
   xcancopy                        :=itext2exe.hascustomimage('about');

   imenu.enabled['about.test']     :=itext2exe.doc.canabout;
   imenu.enabled['about.del']      :=xcancopy;//20nov2025
   imenu.enabled['about.copy']     :=xcancopy;//20nov2025
   imenu.enabled['about.paste']    :=xcanpaste;//20nov2025

   //.cursor
   imenu.enabled['cursor.del']     :=itext2exe.hascustomimage('cursor');

   imenu.checked['preview.auto']   :=itext2exe.opreview;

   imenu.enabled['splash.folder']  :=io__folderexists(io__extractfilepath(itext2exe.splashfilename));
   imenu.enabled['about.folder']   :=io__folderexists(io__extractfilepath(itext2exe.aboutfilename));
   imenu.enabled['cursor.folder']  :=io__folderexists(io__extractfilepath(itext2exe.cursorfilename));

   end

else if m('new.instance') then
   begin

   xsavesettings;
   runlow(io__exename,'');

   end
else if m('app.folder') then runlow(app__rootfolder,'')

else itext2exe.xcmd(self,xcode);


//successful
xok    :=true;
skipend:

except;end;

//show error
if not xok then showerror(e);

end;

end.
