unit limg2;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses {$ifdef gui4}windows, graphics, ljpeg, {$endif} lwin, lwin2, lroot;
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
//## Library.................. extended image/graphics (modernised legacy codebase)
//## Version.................. -
//## Items.................... -
//## Last Updated ............ 05oct2025
//## Lines of Code............ 500+
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


{$ifdef gui4}
const
   //image action strings - 27jul2024 ------------------------------------------
   //for use with mis__todata, mis__tofile and other image procs
   //send specific commands and values to procs

//   ia_sep                             =#1;
//   ia_valsep                          =#2;
   ia_sep                             ='|';//
   ia_s                               =ia_sep;//short form
   ia_valsep                          =':';
   ia_v                               =ia_valsep;

   //actions -> all actions are assumed to "set" a value or condition unless otherwise stated
   ia_none                            ='';

   //.debug
   ia_debug                           ='debug';

   //.stream support
   ia_usestr9                         ='use.str9';

   //.info
   ia_info_filename                   ='info.filename';

   //.animation support
   ia_cellcount                       ='cellcount';
   ia_delay                           ='delay';
   ia_loop                            ='loop';
   ia_hotspot                         ='hotspot';//2 vals -> x,y
   ia_bpp                             ='bpp';
   ia_size                            ='size';
   ia_transparentcolor                ='transparentcolor';
   ia_nonAnimatedFormatsSaveImageStrip='nonanimatedformatssaveimagestrip';//14dec2024
   ia_transparent                     ='transparent';

   //.manual quality
   ia_quality100                      ='quality'+ia_v+'0-100';//0..100 - 0=worst, 100=best
   //.auto quality
   ia_bestquality                     ='quality'+ia_v+'best';
   ia_highquality                     ='quality'+ia_v+'high';
   ia_goodquality                     ='quality'+ia_v+'good';
   ia_fairquality                     ='quality'+ia_v+'fair';
   ia_lowquality                      ='quality'+ia_v+'low';

   //.bit depth
   ia_32bitPLUS                       ='32bitplus';//04jun2025
   ia_24bitPLUS                       ='24bitplus';//04jun2025

   //.size limit
   ia_limitsize64                     ='limitsize64'+ia_v+'bytes';//0..n, where 0=disabled, 1..N limits data size

   //.info vars -> these typically store reply info
   ia_info_quality                    ='info.quality';
   ia_info_cellcount                  ='info.cellcount';
   ia_info_bytes_image                ='info.bytes.image';
   ia_info_bytes_mask                 ='info.bytes.mask';


   //TGA action codes ----------------------------------------------------------
   ia_tga_best                        ='tga.best';

   //.bit depth
   ia_tga_32bpp                       ='tga.32bpp';
   ia_tga_24bpp                       ='tga.24bpp';
   ia_tga_8bpp                        ='tga.8bpp';
   ia_tga_autobpp                     ='tga.autobpp';

   //.compression
   ia_tga_RLE                         ='tga.rle';
   ia_tga_noRLE                       ='tga.norle';

   //.orientation
   ia_tga_topleft                     ='tga.topleft';
   ia_tga_botleft                     ='tga.botleft';


   //PPM action codes ----------------------------------------------------------
   ia_ppm_binary                      ='ppm.binary';
   ia_ppm_ascii                       ='ppm.ascii';


   //PGM action codes ----------------------------------------------------------
   ia_pgm_binary                      ='pgm.binary';
   ia_pgm_ascii                       ='pgm.ascii';


   //PGM action codes ----------------------------------------------------------
   ia_pbm_binary                      ='pbm.binary';
   ia_pbm_ascii                       ='pbm.ascii';


   //PNM action codes ----------------------------------------------------------
   ia_pnm_binary                      ='pnm.binary';
   ia_pnm_ascii                       ='pnm.ascii';

   //XBM action codes ----------------------------------------------------------
   ia_xbm_char                        ='xbm.char';
   ia_xbm_char2                       ='xbm.char2';
   ia_xbm_short                       ='xbm.short';
   ia_xbm_short2                      ='xbm.short2';
{$endif}


//basic procs ------------------------------------------------------------------
function png__fromdata(s:tobject;d:pobject;var e:string):boolean;//25jul2025: fixed row rounding error


//advanced procs ---------------------------------------------------------------

{$ifdef gui4}

//ia procs ---------------------------------------------------------------------
//image action procs -> send and receive optional info from image procs
//.add to end
function ia__add(xactions,xnewaction:string):string;
function ia__addlist(xactions:string;xlistofnewactions:array of string):string;
function ia__sadd(xactions,xnewaction:string;xvals:array of string):string;//name+vals.string
function ia__iadd(xactions,xnewaction:string;xvals:array of longint):string;//name+vals.longint
function ia__iadd64(xactions,xnewaction:string;xvals:array of comp):string;//name+vals.longint

//.simplified list of per-image-format "action" options -> mainly for dialog window etc
procedure ia__useroptions(xinit,xget:boolean;ximgext:string;var xlistindex,xlistcount:longint;var xlabel,xhelp,xaction:string);
procedure ia__useroptions_suppress(xall:boolean;xformatmask:string);//use to disable (hide) certain format options in the save as dialog window - 21dec2024
procedure ia__useroptions_suppress_clear;

//.add at beginning
function ia__preadd(xactions,xnewaction:string):string;
function ia__spreadd(xactions,xnewaction:string;xvals:array of string):string;//name+vals(string)
function ia__ipreadd(xactions,xnewaction:string;xvals:array of longint):string;//name+vals(longint)
function ia__ipreadd64(xactions,xnewaction:string;xvals:array of comp):string;//name+vals(comp)

//find
function ia__ok(xactions,xfindname:string):boolean;//same as found
function ia__found(xactions,xfindname:string):boolean;

function ia__sfindval(xactions,xfindname:string;xvalindex:longint;xdefval:string;var xout:string):boolean;
function ia__ifindval(xactions,xfindname:string;xvalindex,xdefval:longint;var xout:longint):boolean;
function ia__ifindval64(xactions,xfindname:string;xvalindex:longint;xdefval:comp;var xout:comp):boolean;

function ia__sfindvalb(xactions,xfindname:string;xvalindex:longint;xdefval:string):string;
function ia__ifindvalb(xactions,xfindname:string;xvalindex,xdefval:longint):longint;
function ia__ifindval64b(xactions,xfindname:string;xvalindex:longint;xdefval:comp):comp;

function ia__sfind(xactions,xfindname:string;var xvals:array of string):boolean;
function ia__ifind(xactions,xfindname:string;var xvals:array of longint):boolean;
function ia__ifind64(xactions,xfindname:string;var xvals:array of comp):boolean;

function ia__find(xactions,xfindname:string;var xvals:array of string):boolean;


//misc procs
function mis__format(xdata:pobject;var xformat:string;var xbase64:boolean):boolean;//18sep2025, 26jul2024: created to handle tstr8 and tstr9
function miscells(s:tobject;var sbits,sw,sh,scellcount,scellw,scellh,sdelay:longint;var shasai:boolean;var stransparent:boolean):boolean;//16dec2024, 27jul2021
procedure mis__nocells(s:tobject);
function miscopy(s,d:tobject):boolean;//27dec2024, 12feb2022
function mis__copy(s,d:tobject):boolean;


//io procs
function mis__fromfile(s:tobject;sfilename:string;var e:string):boolean;//09jul2021
function mis__fromfile2(s:tobject;sfilename:string;sbuffer:boolean;var e:string):boolean;//09jul2021
function mis__fromdata(s:tobject;sdata:pobject;var e:string):boolean;//25jul2024
function mis__fromdata2(s:tobject;sdata:pobject;sbuffer:boolean;var e:string):boolean;//06jun2025, 25jul2024


//png procs
function png__todata(s:tobject;d:pobject;var e:string):boolean;
function png__todata2(s:tobject;d:pobject;daction:string;var e:string):boolean;
function png__todata3(s:tobject;d:pobject;var daction,e:string):boolean;//29may2025, 06may2025, OK=27jan2021, 20jan2021
function png__todata4(s:tobject;d:pobject;dbits:longint;var daction,e:string):boolean;//29may2025, 06may2025, OK=27jan2021, 20jan2021


//bmp procs
function bmp__valid(x:tobject):boolean;
function bmp__new24:tbitmap;
function bmp__size(x:tbitmap;w,h:longint):boolean;


//tea procs
function tea__info3(adata:pobject;xsyszoom:boolean;var aw,ah,aSOD,aversion,aval1,aval2:longint;var atransparent,asyscolors:boolean):boolean;//18nov2024
function tea__fromdata32(d:tobject;sdata:pobject;var xw,xh:longint):boolean;//05oct2025
function tea__fromdata322(d:tobject;sdata:pobject;xconverttransparency:boolean;var xw,xh:longint):boolean;//05oct2025


//tep procs
function tep__fromdata(s:tobject;d:pobject;var e:string):boolean;//05oct2025


//bmp procs --------------------------------------------------------------------
function bmp32__todata3(s:tobject;d:pobject;dfullheader:boolean;dinfosize,dbits:longint):boolean;//11jun2025: dinfosize, 09jun2025, 28may2025, 15may2025

function bmp__fromdata(d:tobject;s:pobject;var e:string):boolean;
function bmp__fromdata2(d:tobject;s:pobject;var xbits:longint;var e:string):boolean;

function bmp32__fromdata(d:tobject;s:pobject):boolean;//11jun2025: supports DIB +12b patch, 15may2025
function bmp32__fromdata2(d:tobject;s:pobject;sallow_dib_patch_12:boolean):boolean;//12jun2025: dib_patch_12 control, 11jun2025: supports DIB +12b patch, 15may2025
function bmp24__fromdata(d:tobject;s:pobject):boolean;//15may2025
function bmp16__fromdata(d:tobject;s:pobject):boolean;//15may2025
function bmp8__fromdata(d:tobject;s:pobject):boolean;//09jun2025: supports bi_rgb + bi_rle8 + bi_rle4, 15may2025
function bmp4__fromdata(d:tobject;s:pobject):boolean;//15may2025
function bmp1__fromdata(d:tobject;s:pobject):boolean;//15may2025


//dib procs --------------------------------------------------------------------
function dib__fromdata(s:tobject;d:pobject;var e:string):boolean;
function dib__fromdata2(s:tobject;d:pobject;var xoutbpp:longint;var e:string):boolean;

function dib32__fromdata(d:tobject;s:pobject):boolean;//15may2025
function dib24__fromdata(d:tobject;s:pobject):boolean;//15may2025
function dib16__fromdata(d:tobject;s:pobject):boolean;//15may2025
function dib8__fromdata(d:tobject;s:pobject):boolean;//28may2025
function dib4__fromdata(d:tobject;s:pobject):boolean;//28may2025
function dib1__fromdata(d:tobject;s:pobject):boolean;//28may2025


//jpg procs --------------------------------------------------------------------
function jpg__can:boolean;
function jpg__fromdata(s:tobject;d:pobject;var e:string):boolean;


//tga procs --------------------------------------------------------------------
function tga__fromdata(s:tobject;d:pobject;var e:string):boolean;

{$endif}


implementation

uses lio, limg;


function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;


//basic procs ------------------------------------------------------------------

function png__fromdata(s:tobject;d:pobject;var e:string):boolean;//25jul2025: fixed row rounding error
label
   skipend;
var
   d64:tobject;//decoded base64 version of "d" -> automatic and optionally used to keep "d" unchanged
   sr8:pcolorrow8;
   sr24:pcolorrow24;
   sr32:pcolorrow32;
   sc24:tcolor24;
   sc32:tcolor32;
   drowsize,xpos,xbitdepth,spos,int1,int2,int3,int4,p,xcoltype,sbits,xbits,sw,sh,xw,xh,sx,sy:longint;
   xdata,xval,n,v,lastfd,fd,str1,str2,str3:tstr8;
   fbpp,flen:longint;
   xnam:array[0..3] of byte;
   xcollist:array[0..255] of tcolor32;
   xtransparent,dok:boolean;

   function fi32(xval:longint):longint;//26jan2021, 11jan2021, 11jun2017
   var
      a,b:tint4;
   begin
   //get
   a.val:=xval;
   b.bytes[0]:=a.bytes[3];
   b.bytes[1]:=a.bytes[2];
   b.bytes[2]:=a.bytes[1];
   b.bytes[3]:=a.bytes[0];
   //set
   result:=b.val;
   end;

   function xpullchunk(var xname:array of byte;xdata:pobject):boolean;
   label//Chunk structure: "i32(length(xdata))+xname+xdata+i32(misc.crc32b(xname+xdata))"
      skipend;
   var
      xlen:longint;
   begin
   //defaults
   result:=false;

   //check
   if (xdata=nil) or (sizeof(xname)<>4) then exit;

   //init
   str__clear(xdata);
   xname[0]:=0;
   xname[1]:=0;
   xname[2]:=0;
   xname[3]:=0;

   //chunk length
   if dok then xlen:=fi32(str__int4(d,spos-1)) else xlen:=fi32(str__int4(@d64,spos-1));
   inc(spos,4);
   if (xlen<0) then goto skipend;

   //chunk name
   if dok then
      begin
      xname[0]:=str__bytes0(d,spos-1+0);
      xname[1]:=str__bytes0(d,spos-1+1);
      xname[2]:=str__bytes0(d,spos-1+2);
      xname[3]:=str__bytes0(d,spos-1+3);
      end
   else
      begin
      xname[0]:=str__bytes0(@d64,spos-1+0);
      xname[1]:=str__bytes0(@d64,spos-1+1);
      xname[2]:=str__bytes0(@d64,spos-1+2);
      xname[3]:=str__bytes0(@d64,spos-1+3);
      end;
   inc(spos,4);

   //chunk data
   if (xlen>=1) then
      begin
      if dok then str__add3(xdata,d,spos-1,xlen) else str__add3(xdata,@d64,spos-1,xlen);
      end;

   if (str__len(xdata)<>xlen) then goto skipend;
   inc(spos,xlen+4);//step over trailing crc32(4b)

   //successful
   result:=true;
   skipend:
   end;

   function xpaeth(a,b,c:byte):longint;
   var
      p,pa,pb,pc:longint;
   begin
   //a = left, b=above, c=upper left
   p:=a+b-c;//initial estimate
   pa:=abs(p-a);
   pb:=abs(p-b);
   pc:=abs(p-c);
   if (pa<=pb) and (pa<=pc) then result:=a
   else if (pb<=pc)         then result:=b
   else                          result:=c;
   end;
begin
//defaults
result :=false;
e      :=gecTaskfailed;
xbits  :=0;
dok    :=true;
d64    :=nil;
n      :=nil;
v      :=nil;
xdata  :=nil;
xval   :=nil;
lastfd :=nil;
fd     :=nil;
str1   :=nil;
str2   :=nil;
str3   :=nil;
xtransparent:=false;

//check
if not str__lock(d) then exit;

try
//init
if not misok82432(s,sbits,sw,sh) then
   begin
   if (sw<1) then sw:=1;
   if (sh<1) then sh:=1;
   missize2(s,sw,sh,true);
   if not misok82432(s,sbits,sw,sh) then goto skipend;
   end;

spos  :=1;
n     :=str__new8;
v     :=str__new8;
xdata :=str__new8;
xval  :=str__new8;
lastfd:=str__new8;
fd    :=str__new8;
str1  :=str__new8;
str2  :=str__new8;
str3  :=str__new8;

//.palette
for p:=0 to high(xcollist) do
begin
xcollist[p].r:=0;
xcollist[p].g:=0;
xcollist[p].b:=0;
xcollist[p].a:=255;//fully solid
end;//p

//header
if not str__asame3(d,0,[137,80,78,71,13,10,26,10],true) then
   begin

   //init
   dok:=false;
   if (d64=nil) then d64:=str__newsametype(d);//same type

   //switch to base64 encoded text mode
   //.strip "b64:" header
   if str__asame3(d,0,[98,54,52,58],true) then
      begin
      str__add3(@d64,d,4,str__len(d));
      if not str__fromb64(@d64,@d64) then goto skipend;
      end
   //.raw base64 data (no header)
   else
      begin
      if not str__fromb64(d,@d64) then goto skipend;
      end;

   //check again
   if not str__asame3(@d64,0,[137,80,78,71,13,10,26,10],true) then
      begin
      e:=gecUnknownformat;
      goto skipend;
      end;

   end;
spos:=9;

//IHDR                         //name   width.4     height.4   bitdepth.1  colortype.1 (6=R8,G8,B8,A8)  compressionMethod.1(#0 only = deflate/inflate)  filtermethod.1(#0 only) interlacemethod.1(#0=LR -> TB scanline order)
if (not xpullchunk(xnam,@xval)) or (not low__comparearray(xnam,[uuI,uuH,uuD,uuR])) or (str__len(@xval)<13) then
   begin
   e:=gecDatacorrupt;
   goto skipend;
   end;

xw:=fi32(str__int4(@xval,1-1));//1..4
xh:=fi32(str__int4(@xval,5-1));//5..8

if (xw<=0) or (xh<=0) then
   begin
   e:=gecDatacorrupt;
   goto skipend;
   end
else
   begin
   //size "s" to match datastream image
   if not missize2(s,xw,xh,true) then goto skipend;
   sw:=misw(s);
   sh:=mish(s);
   if (sw<>xw) or (sh<>xh) then goto skipend;
   end;

xbitdepth:=str__bytes0(@xval,9-1);
if (xbitdepth<>8) then//we support bit depth of 8bits only
   begin
   e:=gecUnsupportedFormat;
   goto skipend;
   end;

xcoltype:=str__bytes0(@xval,10-1);
if (str__bytes0(@xval,11-1)<>0) or (str__bytes0(@xval,12-1)<>0) or (str__bytes0(@xval,13-1)<>0) then
   begin
   e:=gecUnsupportedFormat;
   goto skipend;
   end;

//read remaining chunks
while true do
begin
if not xpullchunk(xnam,@xval) then
   begin
   e:=gecDataCorrupt;
   goto skipend;
   end;

//.iend
if low__comparearray(xnam,[uuI,uuE,uuN,uuD]) then break
//.idat
else if low__comparearray(xnam,[uuI,uuD,uuA,uuT]) then str__add(@xdata,@xval)
//.plte
else if low__comparearray(xnam,[uuP,uuL,uuT,uuE]) then
   begin
   int1:=frcrange32(str__len(@xval) div 3,0,1+high(xcollist));
   if (int1>=1) then
      begin
      int2:=1;
      for p:=0 to (int1-1) do
      begin
      xcollist[p].r:=str__bytes0(@xval,int2+0-1);
      xcollist[p].g:=str__bytes0(@xval,int2+1-1);
      xcollist[p].b:=str__bytes0(@xval,int2+2-1);
      inc(int2,3);
      end;//p
      end;//int1
   end
//.trns
else if low__comparearray(xnam,[uuT,uuR,uuN,uuS]) then
   begin
   int1:=frcrange32(str__len(@xval),0,1+high(xcollist));
   if (int1>=1) then
      begin
      for p:=0 to (int1-1) do xcollist[p].a:=str__bytes0(@xval,p);
      end;//int1
   end;
end;//while


//.finalise
str__clear(@xval);

//.decompress "xdata"
if ( (str__len(@xdata)>=1) and (not low__decompress(@xdata)) ) or (str__len(@xdata)<=0) then
   begin
   e:=gecDataCorrupt;
   goto skipend;
   end;

//check datalen matches expected datalen ---------------------------------------
//   Color   Allowed     Interpretation
//   Type    Bit Depths
//   0       1,2,4,8,16  Each pixel is a grayscale sample.
//   2       8,16        Each pixel is an R,G,B triple.
//   3       1,2,4,8     Each pixel is a palette index;
//                       a PLTE chunk must appear.
//   4       8,16        Each pixel is a grayscale sample,
//                       followed by an alpha sample.
//   6       8,16        Each pixel is an R,G,B triple,
//                       followed by an alpha sample.
case xcoltype of
0:xbits:=8;
2:xbits:=24;
3:xbits:=8;
4:xbits:=16;
6:xbits:=32;
end;

//was: drowsize:=mis__rowsize4(xw,xbits);//29may2025 - error -> PNG does not round like a bitmap - 25jul2025
drowsize:=xw*(xbits div 8);

if ( (xh * (1+drowsize) ) > str__len(@xdata) ) then
   begin
   e:=gecDataCorrupt;
   goto skipend;
   end;

//scanlines
//.filter support
fbpp:=xbits div 8;//bytes per pixel
flen:=(xw*fbpp);//size of row excluding leading filter byte
fd.setlen(flen);
lastfd.setlen(flen);for p:=1 to flen do lastfd.pbytes[p-1]:=0;

for sy:=0 to (xh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;
xpos:=1+(sy*(1+flen));

//.unscramble filter row "filtertype.1 + scanline"
case xdata.pbytes[xpos-1] of
0:;//none -> nothing to do
1:begin//.f1 -> sub -> write difference in pixels in horizontal lines
   for p:=1 to flen do
   begin
   int1:=xdata.pbytes[xpos+p-1];
   if ((p-fbpp)>=1) then int2:=xdata.pbytes[xpos+p-fbpp-1] else int2:=0;
   int1:=int1+int2;
   if (int1>255) then dec(int1,256);
   xdata.pbytes[xpos+p-1]:=int1;
   end;//p
   end;
2:begin//.f2 - up -> write difference in pixels in vertical lines
   for p:=1 to flen do
   begin
   int2:=lastfd.pbytes[p-1];
   int1:=xdata.pbytes[xpos+p-1];
   int1:=int1+int2;
   if (int1>255) then dec(int1,256);
   xdata.pbytes[xpos+p-1]:=int1;
   end;//p
   end;
3:begin//.f3 - average
   for p:=1 to flen do
   begin
   int3:=lastfd.pbytes[p-1];
   if ((p-fbpp)>=1) then int2:=xdata.pbytes[xpos+p-fbpp-1] else int2:=0;
   int1:=xdata.pbytes[xpos+p-1];
   int1:=int1+trunc((int2+int3)/2);
   if (int1>255) then dec(int1,256);
   xdata.pbytes[xpos+p-1]:=int1;
   end;//p
   end;
4:begin
   //.f4 - paeth
   for p:=1 to flen do
   begin
   if ((p-fbpp)>=1) then int4:=lastfd.pbytes[p-fbpp-1] else int4:=0;
   int3:=lastfd.pbytes[p-1];
   if ((p-fbpp)>=1) then int2:=xdata.pbytes[xpos+p-fbpp-1] else int2:=0;
   int1:=xdata.pbytes[xpos+p-1];
   int1:=int1+xpaeth(int2,int3,int4);
   if (int1>255) then dec(int1,256);
   xdata.pbytes[xpos+p-1]:=int1;
   end;//p
   end;
else
   begin
   e:=gecDatacorrupt;
   goto skipend;
   end;
end;//case

//.32 => 32
if (xbits=32) and (sbits=32) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc32.r:=xdata.pbytes[xpos+1-1];
   sc32.g:=xdata.pbytes[xpos+2-1];
   sc32.b:=xdata.pbytes[xpos+3-1];
   sc32.a:=xdata.pbytes[xpos+4-1];
   if (sc32.a=0) then xtransparent:=true;//17jan2021
   sr32[sx]:=sc32;
   inc(xpos,4);
   end;//sx
   end
//.32 => 24
else if (xbits=32) and (sbits=24) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc24.r:=xdata.pbytes[xpos+1-1];
   sc24.g:=xdata.pbytes[xpos+2-1];
   sc24.b:=xdata.pbytes[xpos+3-1];
   if (xdata.pbytes[xpos+4-1]=0) then xtransparent:=true;//17jan2021
   sr24[sx]:=sc24;
   inc(xpos,4);
   end;//sx
   end
//.32 => 8
else if (xbits=32) and (sbits=8) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc24.r:=xdata.pbytes[xpos+1-1];
   sc24.g:=xdata.pbytes[xpos+2-1];
   sc24.b:=xdata.pbytes[xpos+3-1];
   if (sc24.g>sc24.r) then sc24.r:=sc24.g;
   if (sc24.b>sc24.r) then sc24.r:=sc24.b;
   if (xdata.pbytes[xpos+4-1]=0) then xtransparent:=true;//17jan2021
   sr8[sx]:=sc24.r;
   inc(xpos,4);
   end;//sx
   end
//.24 => 32
else if (xbits=24) and (sbits=32) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc32.r:=xdata.pbytes[xpos+1-1];
   sc32.g:=xdata.pbytes[xpos+2-1];
   sc32.b:=xdata.pbytes[xpos+3-1];
   sc32.a:=255;//fully solid
   sr32[sx]:=sc32;
   inc(xpos,3);
   end;//sx
   end
//.24 => 24
else if (xbits=24) and (sbits=24) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc24.r:=xdata.pbytes[xpos+1-1];
   sc24.g:=xdata.pbytes[xpos+2-1];
   sc24.b:=xdata.pbytes[xpos+3-1];
   sr24[sx]:=sc24;
   inc(xpos,3);
   end;//sx
   end
//.24 => 8
else if (xbits=32) and (sbits=8) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc24.r:=xdata.pbytes[xpos+1-1];
   sc24.g:=xdata.pbytes[xpos+2-1];
   sc24.b:=xdata.pbytes[xpos+3-1];
   if (sc24.g>sc24.r) then sc24.r:=sc24.g;
   if (sc24.b>sc24.r) then sc24.r:=sc24.b;
   sr8[sx]:=sc24.r;
   inc(xpos,3);
   end;//sx
   end
//.8 => 32
else if (xbits=8) and (sbits=32) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc32:=xcollist[xdata.pbytes[xpos+1-1]];
   if (sc32.a=0) then xtransparent:=true;//17jan2021
   sr32[sx]:=sc32;
   inc(xpos,1);
   end;//sx
   end
//.8 => 24
else if (xbits=8) and (sbits=24) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc32:=xcollist[xdata.pbytes[xpos+1-1]];
   sc24.r:=sc32.r;
   sc24.g:=sc32.g;
   sc24.b:=sc32.b;
   if (sc32.a=0) then xtransparent:=true;//17jan2021
   sr24[sx]:=sc24;
   inc(xpos,1);
   end;//sx
   end
//.8 => 8
else if (xbits=8) and (sbits=8) then
   begin
   for sx:=0 to (xw-1) do
   begin
   sc32:=xcollist[xdata.pbytes[xpos+1-1]];
   if (sc32.g>sc32.r) then sc32.r:=sc32.g;
   if (sc32.b>sc32.r) then sc32.r:=sc32.b;
   if (sc32.a=0) then xtransparent:=true;//17jan2021
   sr8[sx]:=sc32.r;
   inc(xpos,1);
   end;//sx
   end
else break;


//.sync lastf2 -> do here BEFORE xrow is modified below - 14jan2021
xpos:=1+(sy*(1+flen));

for p:=1 to flen do lastfd.pbytes[p-1]:=xdata.pbytes[xpos+p-1];

end;//sy

//animation information
if mishasai(s) then
   begin
   misai(s).format:='PNG';
   misai(s).subformat:='';
   misai(s).transparent:=xtransparent;//information purposes only

   misai(s).count:=1;
   misai(s).cellwidth:=misw(s);
   misai(s).cellheight:=mish(s);
   misai(s).delay:=0;

   case xcoltype of
   0:misai(s).bpp:=8;
   2:misai(s).bpp:=24;
   3:misai(s).bpp:=8;
   4:misai(s).bpp:=16;
   6:misai(s).bpp:=32;
   end;//case
   end;

//successful
result:=true;
skipend:
except;end;
//free
str__free(@n);
str__free(@v);
str__free(@xdata);
str__free(@xval);
str__free(@lastfd);
str__free(@fd);
str__free(@str1);
str__free(@str2);
str__free(@str3);
str__free(@d64);
str__uaf(d);//27jan2021
end;


//advanced procs ---------------------------------------------------------------

{$ifdef gui4}


//ia procs ---------------------------------------------------------------------

procedure ia__useroptions_suppress(xall:boolean;xformatmask:string);//use to disable (hide) certain format options in the save as dialog window - 21dec2024
begin
system_ia_useroptions_suppress_all:=xall;
system_ia_useroptions_suppress_masklist:=xformatmask;
end;

procedure ia__useroptions_suppress_clear;
begin
system_ia_useroptions_suppress_all:=false;
system_ia_useroptions_suppress_masklist:='';
end;

procedure ia__useroptions(xinit,xget:boolean;ximgext:string;var xlistindex,xlistcount:longint;var xlabel,xhelp,xaction:string);

   function m(xext:string):boolean;//image ext match
   begin
   result:=strmatch(xext,ximgext);
   end;

   procedure dcount(dcount:longint);
   begin
   xlistcount:=frcmin32(dcount,0);
   xlistindex:=frcrange32(xlistindex,0,frcmin32(xlistcount-1,0));
   end;

   procedure i(dlabel:string;dactlist:array of string);//info
   begin
   xlabel:=dlabel;
   xhelp:='';
   xaction:=ia__addlist('',dactlist);
   end;

   procedure i2(dlabel:string;dactlist:array of string;dhelp:string);//info - 28dec2024
   begin
   xlabel:=dlabel;
   xhelp:=dhelp;
   xaction:=ia__addlist('',dactlist);
   end;

   function f:string;//filename
   begin
   result:=app__settingsfile(ximgext+'.ia');
   end;

   function getindex:longint;
   var
      e:string;
   begin
   result:=strint32(io__fromfilestr2(f));
   end;

   procedure setindex(x:longint);
   var
      e:string;
   begin
   io__tofilestr(f, intstr32( frcrange32(x,0,frcmin32(xlistcount-1,0)) ),e);
   end;
begin
try
//suppression check - all
if system_ia_useroptions_suppress_all then
   begin
   dcount(0);
   i('-',['']);
   exit;
   end;
//suppression check - by complex masklist (ximgext requires a leading "." dot to match in the mask)
if (system_ia_useroptions_suppress_masklist<>'') and filter__matchlist('.'+ximgext,system_ia_useroptions_suppress_masklist) then
   begin
   dcount(0);
   i('-',['']);
   exit;
   end;

//init
if xinit then xlistindex:=getindex;//get listindex from disk for this image format

//get
if m('tga') then
   begin
   dcount(8);
   case xlistindex of
   0:i2('Default'                     ,['']                       ,'Default');
   1:i2('Best'                        ,[ia_tga_best]              ,'Best quality');
   2:i2('32bit Color RLE'             ,[ia_tga_32bpp,ia_tga_RLE]  ,'Compressed 32bit color image');
   3:i2('32bit Color'                 ,[ia_tga_32bpp,ia_tga_noRLE],'Uncompressed 32bit color image');
   4:i2('24bit Color RLE'             ,[ia_tga_24bpp,ia_tga_RLE]   ,'Compressed 24bit color image');
   5:i2('24bit Color'                 ,[ia_tga_24bpp,ia_tga_noRLE] ,'Uncompressed 24bit color image');
   6:i2('8bit Grey RLE'               ,[ia_tga_8bpp,ia_tga_RLE]    ,'Compressed 8bit greyscale image');
   7:i2('8bit Grey'                   ,[ia_tga_8bpp,ia_tga_noRLE]  ,'Uncompressed 8bit greyscale image');
   end;//case
   end
else if m('jpg') or m('jif') or m('jpeg') then
   begin
   dcount(6);
   case xlistindex of
   0:i2('Default'                     ,['']                        ,'Default');
   1:i2('Best'                        ,[ia_bestquality]            ,'Best image quality');
   2:i2('High'                        ,[ia_highquality]            ,'High image quality');
   3:i2('Good'                        ,[ia_goodquality]            ,'Good image quality');
   4:i2('Fair'                        ,[ia_fairquality]            ,'Fair image quality');
   5:i2('Low'                         ,[ia_lowquality]             ,'Low image quality');
   end;//case
   end
else if m('ppm') then
   begin
   dcount(3);
   case xlistindex of
   0:i2('Default'                     ,['']                       ,'Default');
   1:i2('Binary'                      ,[ia_ppm_binary]            ,'Binary image | Smaller file size than ascii');
   2:i2('Ascii'                       ,[ia_ppm_ascii]             ,'Ascii image | Larger file size than binary but can be edited in a text editor');
   end;//case
   end
else if m('pgm') then
   begin
   dcount(3);
   case xlistindex of
   0:i2('Default'                     ,['']                       ,'Default');
   1:i2('Binary'                      ,[ia_pgm_binary]            ,'Binary Image | Smaller file size than ascii');
   2:i2('Ascii'                       ,[ia_pgm_ascii]             ,'Ascii Image | Larger file size than binary but can be edited in a text editor');
   end;//case
   end
else if m('pbm') then
   begin
   dcount(3);
   case xlistindex of
   0:i2('Default'                     ,['']                       ,'Default');
   1:i2('Binary'                      ,[ia_pbm_binary]            ,'Binary Image | Smaller file size than ascii');
   2:i2('Ascii'                       ,[ia_pbm_ascii]             ,'Ascii Image | Larger file size than binary but can be edited in a text editor');
   end;//case
   end
else if m('pnm') then
   begin
   dcount(3);
   case xlistindex of
   0:i2('Default'                     ,['']                       ,'Default');
   1:i2('Binary'                      ,[ia_pnm_binary]            ,'Binary Image | Smaller file size than ascii');
   2:i2('Ascii'                       ,[ia_pnm_ascii]             ,'Ascii Image | Larger file size than binary but can be edited in a text editor');
   end;//case
   end
else if m('xbm') then
   begin
   dcount(6);
   case xlistindex of
   0:i2('Default'                     ,['']                      ,'Data Type|Store pixels as 2 char hex blocks with format padding|Largest file size for best compatibility');
   1:i2('Smallest'                    ,[ia_xbm_short]            ,'Data Type|Store pixels as 4 char hex blocks|Smaller file size than Char, Char Padded, and Short Padded');
   2:i2('Char'                        ,[ia_xbm_char]             ,'Data Type|Store pixels as 2 char hex blocks|Larger file size than Short');
   3:i2('Short (X10)'                 ,[ia_xbm_short]            ,'Data Type|Store pixels as 4 char hex blocks|Smaller file size than Char');
   4:i2('Char Padded'                 ,[ia_xbm_char2]            ,'Data Type|Store pixels as 2 char hex blocks with format padding|Format padding increases file size|Larger file size than Short Padded');
   5:i2('Short Padded (X10)'          ,[ia_xbm_short2]           ,'Data Type|Store pixels as 4 char hex blocks with format padding|Format padding increases file size|Smaller file size than Char Padded');
   end;//case
   end
else
   begin
   dcount(0);
   i('-',['']);
   end;

//set -> store listindex to disk for next time
if (not xget) then setindex(xlistindex);
except;end;
end;

function ia__add(xactions,xnewaction:string):string;
begin
result:=xactions+insstr(ia_sep,xactions<>'')+xnewaction;
end;

function ia__addlist(xactions:string;xlistofnewactions:array of string):string;
var
   p:longint;
   v:string;
begin
//init
result:=xactions;

//get
for p:=0 to high(xlistofnewactions) do
begin
v:=xlistofnewactions[p];
if (v<>'') then result:=ia__add(result,v);
end;
end;

function ia__preadd(xactions,xnewaction:string):string;
begin
result:=xnewaction+insstr(ia_sep,xactions<>'')+xactions;
end;

function ia__sadd(xactions,xnewaction:string;xvals:array of string):string;//name+vals(string)
var
   p:longint;
   v:string;
begin
result:=xactions;
if (xnewaction<>'') then
   begin
   result:=result+insstr(ia_sep,result<>'')+xnewaction;

   for p:=0 to high(xvals) do
   begin
   //filter
   v:=xvals[p];
   low__remchar(v,ia_sep);
   low__remchar(v,ia_valsep);
   //set
   result:=result+ia_valsep+v;
   end;

   end;
end;

function ia__spreadd(xactions,xnewaction:string;xvals:array of string):string;//name+vals(string)
var
   p:longint;
   xdata,v:string;
begin
result:=xactions;
if (xnewaction<>'') then
   begin
   xdata:=xnewaction;

   for p:=0 to high(xvals) do
   begin
   //filter
   v:=xvals[p];
   low__remchar(v,ia_sep);
   low__remchar(v,ia_valsep);
   //set
   xdata:=xdata+ia_valsep+v;
   end;

   result:=xdata+insstr(ia_sep,result<>'')+result;
   end;
end;

function ia__iadd(xactions,xnewaction:string;xvals:array of longint):string;//name+vals(longint)
var
   p:longint;
begin
result:=xactions;
if (xnewaction<>'') then
   begin
   result:=result+insstr(ia_sep,result<>'')+xnewaction;
   for p:=0 to high(xvals) do result:=result+ia_valsep+intstr32(xvals[p]);
   end;
end;

function ia__iadd64(xactions,xnewaction:string;xvals:array of comp):string;//name+vals(comp)
var
   p:longint;
begin
result:=xactions;
if (xnewaction<>'') then
   begin
   result:=result+insstr(ia_sep,result<>'')+xnewaction;
   for p:=0 to high(xvals) do result:=result+ia_valsep+intstr64(xvals[p]);
   end;
end;

function ia__ipreadd(xactions,xnewaction:string;xvals:array of longint):string;//name+vals(longint)
var
   p:longint;
   xdata:string;
begin
result:=xactions;
if (xnewaction<>'') then
   begin
   xdata:=xnewaction;

   for p:=0 to high(xvals) do xdata:=xdata+ia_valsep+intstr32(xvals[p]);

   result:=xdata+insstr(ia_sep,result<>'')+result;
   end;
end;

function ia__ipreadd64(xactions,xnewaction:string;xvals:array of comp):string;//name+vals(comp)
var
   p:longint;
   xdata:string;
begin
result:=xactions;
if (xnewaction<>'') then
   begin
   xdata:=xnewaction;

   for p:=0 to high(xvals) do xdata:=xdata+ia_valsep+intstr64(xvals[p]);

   result:=xdata+insstr(ia_sep,result<>'')+result;
   end;
end;

function ia__found(xactions,xfindname:string):boolean;
begin
result:=ia__ok(xactions,xfindname);
end;

function ia__ok(xactions,xfindname:string):boolean;
var
   v:array[0..9] of string;
begin
result:=ia__find(xactions,xfindname,v);
end;

function ia__sfindval(xactions,xfindname:string;xvalindex:longint;xdefval:string;var xout:string):boolean;
var
   svals:array[0..9] of string;
begin
result:=ia__sfind(xactions,xfindname,svals);

case result and (xvalindex>=0) and (xvalindex<=high(svals)) of
true:xout:=strdefb(svals[xvalindex],xdefval);
else xout:=xdefval;
end;
end;

function ia__ifindval(xactions,xfindname:string;xvalindex,xdefval:longint;var xout:longint):boolean;
var
   svals:array[0..9] of string;
begin
result:=ia__sfind(xactions,xfindname,svals);

case result and (xvalindex>=0) and (xvalindex<=high(svals)) of
true:xout:=strint(strdefb(svals[xvalindex],intstr32(xdefval)));
else xout:=xdefval;
end;
end;

function ia__ifindval64(xactions,xfindname:string;xvalindex:longint;xdefval:comp;var xout:comp):boolean;
var
   svals:array[0..9] of string;
begin
result:=ia__sfind(xactions,xfindname,svals);

case result and (xvalindex>=0) and (xvalindex<=high(svals)) of
true:xout:=strint64(strdefb(svals[xvalindex],intstr64(xdefval)));
else xout:=xdefval;
end;
end;

function ia__bfindval(xactions,xfindname:string;xvalindex:longint;xdefval:boolean;var xout:boolean):boolean;//04aug2024
var
   svals:array[0..9] of string;
begin
result:=ia__sfind(xactions,xfindname,svals);

case result and (xvalindex>=0) and (xvalindex<=high(svals)) of
true:xout:=strbol(strdefb(svals[xvalindex],bolstr(xdefval)));
else xout:=xdefval;
end;
end;

function ia__ifindvalb(xactions,xfindname:string;xvalindex,xdefval:longint):longint;
begin
ia__ifindval(xactions,xfindname,xvalindex,xdefval,result);
end;

function ia__ifindval64b(xactions,xfindname:string;xvalindex:longint;xdefval:comp):comp;
begin
ia__ifindval64(xactions,xfindname,xvalindex,xdefval,result);
end;

function ia__sfindvalb(xactions,xfindname:string;xvalindex:longint;xdefval:string):string;
begin
ia__sfindval(xactions,xfindname,xvalindex,xdefval,result);
end;

function ia__sfind(xactions,xfindname:string;var xvals:array of string):boolean;
begin
result:=ia__find(xactions,xfindname,xvals);
end;

function ia__ifind(xactions,xfindname:string;var xvals:array of longint):boolean;
var
   p:longint;
   svals:array[0..9] of string;
begin
//init
for p:=0 to high(xvals) do xvals[p]:=0;

//get
result:=ia__find(xactions,xfindname,svals);
if result then
   begin
   for p:=0 to smallest32(high(svals),high(xvals)) do xvals[p]:=strint(svals[p]);
   end;
end;

function ia__ifind64(xactions,xfindname:string;var xvals:array of comp):boolean;
var
   p:longint;
   svals:array[0..9] of string;
begin
//init
for p:=0 to high(xvals) do xvals[p]:=0;

//get
result:=ia__find(xactions,xfindname,svals);
if result then
   begin
   for p:=0 to smallest32(high(svals),high(xvals)) do xvals[p]:=strint64(svals[p]);
   end;
end;

function ia__find(xactions,xfindname:string;var xvals:array of string):boolean;
var
   fn,fv,n,v,z:string;
   xlen,zlen,lp,p,zp:longint;
   c:char;

   procedure xreadvals(x:string);
   var
      vc,xlen,lp,p:longint;
      v:string;
      c:char;
   begin
   //init
   vc:=0;
   xlen:=low__len(x);

   //check
   if (xlen<=0) then exit;

   //get
   lp:=1;
   for p:=1 to xlen do
   begin
   c:=x[p-1+stroffset];
   if (c=ia_valsep) or (p=xlen) then
      begin
      if (vc>high(xvals)) then break;
      v:=strcopy1(x,lp,p-lp+low__insint(1,(p=xlen)));
      xvals[vc]:=v;
      //inc
      inc(vc);
      lp:=p+1;
      end;
   end;//p
   end;
begin
//defaults
result:=false;

//init
for p:=0 to high(xvals) do xvals[p]:='';

//special
if (xfindname='') then
   begin
   result:=true;
   exit;
   end;

//check
xlen:=low__len(xactions);
if (xlen<=0) then exit;

//split name -> some actions have values as part of their name in order to share multiple different value types, such as quality:100: or quality:5 or quality:best
fn:=xfindname;
fv:='';
for p:=1 to low__len(fn) do if (fn[p-1+stroffset]=ia_valsep) then
   begin
   fn:=strcopy1(fn,1,p-1);
   fv:=strcopy1(xfindname,p+1,low__len(xfindname));
   break;
   end;

//find -> work from last to first -> most recent value is at end
lp:=xlen;
for p:=xlen downto 1 do
begin
c:=xactions[p-1+stroffset];

if (c=ia_sep) or (p=1)then
   begin
   //extract last action -> first action
   if (c=ia_sep) then z:=strcopy1(xactions,p+1,lp-p) else z:=strcopy1(xactions,p,lp-p+1);
   zlen:=low__len(z);

   //examine extracted action
   if (zlen>=1) then
      begin
      //split action into name and values (yes a name can have values too)
      n:=z;
      v:='';

      for zp:=1 to zlen do
      begin
      c:=z[zp-1+stroffset];
      if (c=ia_valsep) or (zp=zlen) then
         begin
         n:=strcopy1(z,1,zp-low__insint(1,(zp<>zlen)));
         v:=strcopy1(z,low__len(n)+2,zlen);
         break;
         end;
      end;//p2

      //match base name -> we now stop after this point, only difference is whether it's TRUE (name vals match if any) or FALSE (no match)
      if strmatch(n,fn) then
         begin
         result:=strmatch(fv,strcopy1(v,1,low__len(fv)));
         if result then
            begin
            //read values from the end of the xfindname (e.g. past it's base name and it's name's vals)
            xreadvals( strcopy1(v,low__len(fv)+low__insint(2,fv<>''),low__len(v)) );
            end;

         //stop
         break;
         end;
      end;

   //lp
   lp:=frcmin32(p-1,0);
   end;

end;//p
end;

function mis__format(xdata:pobject;var xformat:string;var xbase64:boolean):boolean;//18sep2025, 26jul2024: created to handle tstr8 and tstr9
label
   skipend,redo;
var
   a:tobject;
   str1:string;
   xmustfree,xonce:boolean;

   function sm(ext:string):boolean;
   begin
   result:=strmatch(str1,ext);
   end;
begin
//defaults
result:=false;
xmustfree:=false;
xformat:='';
xbase64:=false;
a:=nil;

try
//lock
if not str__lock(xdata) then goto skipend;

//length check
a:=xdata^;//a pointer at this stage
if (str__len(@a)<=0) then goto skipend;

//init
xonce:=true;
redo:
//get
if io__anyformat(@a,str1) then
   begin
   if (str1='B64') then
      begin
      if xonce then
         begin
         xonce:=false;
         xbase64:=true;
         //.duplicate "a" using same string handler
         xmustfree:=true;
         a:=str__newsametype(xdata);
         str__fromb642(xdata,@a,1);
         goto redo;
         end;
      end
   else
      begin
      //get
      xformat:=str1;

      //detect known format ----------------------------------------------------
      if not result then
         begin

         result:=sm('png') or sm('tea') or sm('img32') or sm('tga') or sm('ppm') or sm('pgm') or sm('pbm') or sm('pnm') or
                 sm('bmp') or sm('dib') or sm('san') or sm('gif') or sm('ico') or sm('cur') or sm('ani') or sm('xbm') or
                 sm('tep');

         end;

      {$ifdef gamecore}
      if not result then result:=sm('pic8');
      {$endif}

      {$ifdef jpeg}
      if not result then result:=sm('jpg') or sm('tj32');
      {$endif}

      end;
   end;

skipend:
except;end;
try
if xmustfree and str__ok(@a) then str__free(@a);
str__uaf(xdata);
except;end;
end;

function miscells(s:tobject;var sbits,sw,sh,scellcount,scellw,scellh,sdelay:longint;var shasai:boolean;var stransparent:boolean):boolean;//16dec2024, 27jul2021
var
   xbits,xw,xh:longint;
   xhasai:boolean;
begin
//defaults
result:=false;
try
sbits:=0;
sw:=1;
sh:=1;
scellcount:=1;
scellw:=1;
scellh:=1;
sdelay:=500;//500 ms
shasai:=false;
stransparent:=false;
//check
if not misokex(s,xbits,xw,xh,xhasai) then exit;
//get
sbits:=xbits;
sw:=frcmin32(xw,1);
sh:=frcmin32(xh,1);
if xhasai then
   begin
   scellcount:=frcmin32(misai(s).count,1);
   stransparent:=misai(s).transparent;
   sdelay:=frcmin32(misai(s).delay,0);//16dec2024: allow to zero out
   end;
shasai:=xhasai;
scellw:=frcmin32(trunc(sw/scellcount),1);
scellh:=sh;
//successful
result:=true;
except;end;
end;

procedure mis__nocells(s:tobject);
begin
misai(s).cellwidth  :=misw(s);
misai(s).cellheight :=mish(s);
misai(s).delay      :=0;//16nov2024
misai(s).count      :=1;
end;

function asimg(x:tobject):tbasicimage;//12feb2202
begin
if (x<>nil) and (x is tbasicimage) then result:=x as tbasicimage else result:=nil;
end;

function miscopy(s,d:tobject):boolean;//27dec2024, 12feb2022
label
   skipend;
var
   //s
   sbits,sw,sh,scellcount,scellw,scellh,sdelay:longint;
   shasai:boolean;
   stransparent:boolean;
   //d
   dbits,dw,dh,dcellcount,dcellw,dcellh,ddelay:longint;
   dhasai:boolean;
   dtransparent:boolean;
begin
//defaults
result:=false;

//invalid
if zznil2(s) or zznil2(d) then goto skipend
//fast
else if zzimg(s) and zzimg(d) then result:=asimg(d).copyfrom(asimg(s))//09may2022
//moderate
else
   begin
   //.info
   if not miscells(s,sbits,sw,sh,scellcount,scellw,scellh,sdelay,shasai,stransparent) then goto skipend;
   if not miscells(d,dbits,dw,dh,dcellcount,dcellw,dcellh,ddelay,dhasai,dtransparent) then goto skipend;
   //.size
   if ((sw<>dw) or (sh<>dh)) and (not missize(d,sw,sh)) then goto skipend;//27dec2024: fixed
   //.bits
   if (sbits<>dbits) and (not missetb2(d,sbits)) then goto skipend;
   //.pixels -> full 32bit RGBA support - 15feb2022
   if not miscopyarea32(0,0,sw,sh,misarea(s),d,s) then goto skipend;
   //.ai
   if shasai and dhasai and (not misaicopy(s,d)) then goto skipend;
   end;

//successful
result:=true;
skipend:
end;

function mis__copy(s,d:tobject):boolean;

   function xaicopy(s,d:tobject):boolean;
   begin
   result:=misv(s) and misv(d);
   if result and (not misaicopy(s,d)) then misaiclear(misai(d)^);
   end;
begin
result:=missize(d,misw(s),mish(s)) and miscopyarea322(maxarea,0,0,misw(s),mish(s),area__make(0,0,misw(s)-1,mish(s)-1),d,s,0,0) and xaicopy(s,d);
end;

function mis__fromfile(s:tobject;sfilename:string;var e:string):boolean;//09jul2021
begin
result:=mis__fromfile2(s,sfilename,false,e);
end;

function mis__fromfile2(s:tobject;sfilename:string;sbuffer:boolean;var e:string):boolean;//09jul2021
var
   a:tobject;
begin
//defaults
result:=false;
e:=gecTaskfailed;
a:=nil;
//get
try
a:=str__new9;
result:=io__fromfile64(sfilename,@a,e) and mis__fromdata2(s,@a,sbuffer,e);
except;end;
try
str__free(@a);
except;end;
end;

function mis__fromdata(s:tobject;sdata:pobject;var e:string):boolean;//25jul2024
begin
result:=mis__fromdata2(s,sdata,false,e);
end;

function mis__fromdata2(s:tobject;sdata:pobject;sbuffer:boolean;var e:string):boolean;//06jun2025, 25jul2024
label
   skipend;
var
   d,ddataobj:tobject;
   ddata:pobject;
   dbuffered:boolean;
   sbits,sw,sh:longint;
   sformat:string;
   sbase64:boolean;
   int1,int2:longint;

   function startbuffer:boolean;
   begin
   //get
   if sbuffer then
      begin
      dbuffered:=true;
      d:=misraw(sbits,sw,sh);
      result:=mis__copy(s,d);
      end
   else result:=true;

   //static image by default
   mis__nocells(d);
   end;

   function stopbuffer:boolean;
   begin
   //get
   if dbuffered then
      begin
      result:=mis__copy(d,s);
      dbuffered:=false;
      freeobj(@d);
      end
   else result:=true;
   end;
begin
//defaults
result:=false;
e:=gecTaskfailed;
d:=s;
ddataobj:=nil;
ddata:=@ddataobj;
dbuffered:=false;

try
//check
if not str__lock(sdata)          then goto skipend else ddata:=sdata;
if not misok82432(s,sbits,sw,sh) then goto skipend;

//detect data format #1
if not mis__format(sdata,sformat,sbase64) then
   begin

   //detect data format #2 -> unzip data and run 2nd format detection - 26jul2024
   case strmatch(sformat,'zip') of
   true:begin

      ddataobj:=str__newsametype(sdata);//same type
      ddata:=@ddataobj;

      if (not str__add(ddata,sdata)) or (not low__decompress(ddata)) then
         begin
         e:=gecDatacorrupt;
         goto skipend;
         end;

      //failed again -> quit
      if not mis__format(ddata,sformat,sbase64) then
         begin
         e:=gecUnknownformat;
         goto skipend;
         end;

      end;

   else begin

      e:=gecUnknownformat;
      goto skipend;

      end;

   end;//case

   end;

//double buffer to protect "s" from corruption -> we overwrite "s" only when we have good data
if sbuffer then
   begin
   d:=misraw(sbits,sw,sh);
   if not miscopy(s,d) then goto skipend;
   end;

//get
if (sformat='PNG') then
   begin
   if not startbuffer then goto skipend;
   if not png__fromdata(d,ddata,e) then goto skipend;
   if not stopbuffer then goto skipend;
   end
{
else if (sformat='ICO') then
   begin
   if not startbuffer then goto skipend;
   if (not ico__fromdata(d,ddata,e)) and (not low__fromico322(d,ddata,0,true,e)) then goto skipend;
   if not stopbuffer then goto skipend;
   end
else if (sformat='CUR') then
   begin
   if not startbuffer then goto skipend;
   if (not cur__fromdata(d,ddata,e)) and (not low__fromico322(d,ddata,0,true,e)) then goto skipend;
   if not stopbuffer then goto skipend;
   end
else if (sformat='ANI') then
   begin
   //update this to sub-proc handling -> ico__fromdata()
   if not startbuffer then goto skipend;
   if not low__fromani322(d,ddata,0,true,e) then goto skipend;
   if not stopbuffer then goto skipend;
   end
}
else if (sformat='TEA') then
   begin
   if not startbuffer then goto skipend;
   if not tea__fromdata32(d,ddata,int1,int2) then goto skipend;
   if not stopbuffer then goto skipend;
   end
else if (sformat='TEP') then
   begin
   if not startbuffer then goto skipend;
   if not tep__fromdata(d,ddata,e) then goto skipend;//19oct2025
   if not stopbuffer then goto skipend;
   end
{
else if (sformat='IMG32') then
   begin
   if not startbuffer then goto skipend;
   if not img32__fromdata(d,ddata,e) then goto skipend;
   if not stopbuffer then goto skipend;
   end
else if (sformat='SAN') then//16sep2025
   begin
   if not startbuffer then goto skipend;
   if not san__fromdata(d,ddata,e) then goto skipend;
   if not stopbuffer then goto skipend;
   end
else if (sformat='PIC8') then//16sep2025
   begin
   if not startbuffer then goto skipend;
   if not img8__fromdata(d,ddata,e) then goto skipend;
   if not stopbuffer then goto skipend;
   end
}
else if (sformat='BMP') then//does not require a buffer - 25jul2024
   begin
   if not bmp__fromdata(d,ddata,e) then goto skipend;
   end
{
else if (sformat='XBM') then//does not require a buffer - 18sep2025
   begin
   if not xbm__fromdata(d,ddata,e) then goto skipend;
   end
}
else if (sformat='DIB') then//does not require a buffer - 25jul2024
   begin
   if not dib__fromdata(d,ddata,e) then goto skipend;
   end
{
else if (sformat='TJ32') then
   begin
   if not startbuffer then goto skipend;
   if not tj32__fromdata(d,ddata,e) then goto skipend;
   if not stopbuffer then goto skipend;
   end
}
else if (sformat='JPG') then//requires both BMP and JPEG support
   begin
   if not jpg__fromdata(d,ddata,e) then goto skipend;
   end
{
else if (sformat='GIF') then
   begin
   if not startbuffer then goto skipend;
   if not gif__fromdata(d,ddata,e) then goto skipend;//06aug2024
   if not stopbuffer then goto skipend;
   end
}
else if (sformat='TGA') then
   begin
   if not tga__fromdata(d,ddata,e) then goto skipend;
   end
{
else if (sformat='PPM') then
   begin
   if not ppm__fromdata(d,ddata,e) then goto skipend;
   end
else if (sformat='PGM') then
   begin
   if not pgm__fromdata(d,ddata,e) then goto skipend;
   end
else if (sformat='PBM') then
   begin
   if not pbm__fromdata(d,ddata,e) then goto skipend;
   end
else if (sformat='PNM') then
   begin
   if not pnm__fromdata(d,ddata,e) then goto skipend;
   end
}
else
   begin
   goto skipend;
   end;

//successful
result:=true;
skipend:
except;end;
try
//cellwidth and cellheight -> default to 0x0 when no "ai" present, such with jpeg/bitmap - 26jul2024
if mishasai(s) and ((misai(s).cellwidth=0) or (misai(s).cellheight=0)) then
   begin
   mis__nocells(s);
   end;

//free double buffers
if (ddata<>nil) and (ddata<>sdata) then str__free(ddata);
if (d<>nil)     and (d<>s)         then freeobj(@d);

//last
str__uaf(sdata);
except;end;
end;


//png procs --------------------------------------------------------------------
function png__todata(s:tobject;d:pobject;var e:string):boolean;
begin
result:=png__todata2(s,d,'',e);
end;

function png__todata2(s:tobject;d:pobject;daction:string;var e:string):boolean;
begin
result:=png__todata3(s,d,daction,e);
end;

function png__todata3(s:tobject;d:pobject;var daction,e:string):boolean;//29may2025, 06may2025, OK=27jan2021, 20jan2021
label
   skipend;
var
   vmin,vmax,dbits:longint;
   v0,v255,vother:boolean;
begin
//defaults
result:=false;
e     :=gecTaskfailed;

try
//get
case misb(s) of
24  :dbits:=24;
8   :dbits:=8;
else dbits:=32;
end;

//.determine if 32bit image uses any alpha values
if (dbits=32) then
   begin
   mask__range2(s,v0,v255,vother,vmin,vmax);

   //fully solid -> no transparency -> safe to switch to 24 bit mode
   if (vmin>=255) and (vmax>=255) then dbits:=24;
   end;

//.count colors -> if 256 or less then switch to 8 bit mode
if (dbits<=24) then
   begin
   case mis__countcolors257(s) of
   0..256:dbits:=8;
   end;//case
   end;

//.min bit depth
if      ia__found(daction,ia_32bitPLUS)   then dbits:=32
else if ia__found(daction,ia_24bitPLUS)   then dbits:=24;

//set
result:=png__todata4(s,d,dbits,daction,e);

skipend:
except;end;
end;

function png__todata4(s:tobject;d:pobject;dbits:longint;var daction,e:string):boolean;//29may2025, 06may2025, OK=27jan2021, 20jan2021
label
   skipend;
var
   plist:array[0..255] of tcolor32;
   sr32:pcolorrow32;
   sr24:pcolorrow24;
   sr8:pcolorrow8;
   c32:tcolor32;
   c24:tcolor24;
   fsize,fmode,pdiv,plimit,pcount,drowsize,int1,int2,int3,int4,dpos,p,di,sbits,sw,sh,sx,sy:longint;
   lastf2,f1,f2,f3,f4,drow,str1:tstr8;
   fbpp,flen0,flen1,flen2,flen3,flen4:longint;

   function i32(xval:longint):longint;//26jan2021, 11jan2021, 11jun2017
   var
      a,b:tint4;
   begin
   //defaults
   a.val:=xval;
   //get
   b.bytes[3]:=a.bytes[0];
   b.bytes[2]:=a.bytes[1];
   b.bytes[1]:=a.bytes[2];
   b.bytes[0]:=a.bytes[3];
   //set
   result:=b.val;
   end;

   function daddchunk2(const n:array of byte;v:tstr8;vcompress:boolean):boolean;
   begin
   //defaults
   result:=false;

   //check
   if (v=nil) or (sizeof(n)<>4) then exit;

   //compress -> for "IDAT" chunks only -> must use standard linux "deflate" algorithm - 11jan2021
   if vcompress and (v.len>=1) and (not low__compress(@v)) then exit;

   //get
   str__addint4(d, i32(v.len) );
   str__aadd(d,n);

   if (v.len>=1) then str__add(d,@v);

   //.insert name at begining of val and then do crc32 on it - 26jan2021
   v.ains(n,0);
   str__addint4(d, i32(low__crc32b(v)) );

   //successful
   result:=true;
   end;

   function daddchunk(const n:array of byte;v:tstr8):boolean;
   begin
   result:=daddchunk2(n,v,false);
   end;

   procedure r32(const sx:longint);
   begin
   //get
   case sbits of
   8:begin
      c32.r:=sr8[sx];
      c32.g:=c32.r;
      c32.b:=c32.r;
      c32.a:=255;
      end;
   24:begin
      c24:=sr24[sx];
      c32.r:=c24.r;
      c32.g:=c24.g;
      c32.b:=c24.b;
      c32.a:=255;
      end;
   32:begin
      c32:=sr32[sx];

      case dbits of
      24:c32.a:=255;
      8 :if (c32.a=0) then
         begin
         c32.r:=0;
         c32.g:=0;
         c32.b:=0;
         end;
      end;//case

      end;
   end;//case

   //set -> adjust color
   if (pdiv>=2) then
      begin
      c32.r:=(c32.r div pdiv)*pdiv;
      c32.g:=(c32.g div pdiv)*pdiv;
      c32.b:=(c32.b div pdiv)*pdiv;

      //.retain full transparent pixels
      if (c32.a>=1) then
         begin
         c32.a:=(c32.a div pdiv)*pdiv;
         if (c32.a<=0) then c32.a:=1;
         end;
      end;
   end;

   function pfind(var xindex:byte):boolean;
   var
      p:longint;
   begin
   //defaults
   result:=false;
   xindex:=0;

   //find
   for p:=0 to (pcount-1) do if (c32.r=plist[p].r) and (c32.g=plist[p].g) and (c32.b=plist[p].b) and (c32.a=plist[p].a) then
      begin
      result:=true;
      xindex:=p;
      break;
      end;//p
   end;

   function pmake:boolean;
   label
      skipend;
   var
      sx,sy:longint;
      i:byte;
   begin
   //defaults
   result:=false;

   //reset
   pcount:=0;

   //count colors
   for sy:=0 to (sh-1) do
   begin
   if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;

   for sx:=0 to (sw-1) do
   begin
   r32(sx);

   //.color already in palette list of colors
   if pfind(i) then
      begin
      //
      end

   //.at capacity -> can't continue
   else if (pcount>=plimit) then
      begin
      //.shift to new color adjuster to reduce overall color count
      pdiv:=frcrange32( pdiv + low__aorb(1,30,pdiv>30) ,1,240);
      goto skipend;
      end

   //.add color to palette list
   else
      begin
      plist[pcount].r:=c32.r;
      plist[pcount].g:=c32.g;
      plist[pcount].b:=c32.b;
      plist[pcount].a:=c32.a;
      inc(pcount);
      end;

   end;//sx
   end;//sy

   //successful
   result:=true;
   skipend:
   end;

   function ddeflatesize(x:tstr8;xfrom0:longint):longint;//a value estimate of WHAT it might be if we were to actually compressing "x" to return it's size - 29may2025: teaked for better estimation, 16jan2021
   var//Typical way for PNG standard to determine best filter type to use - 16jan2021
      //Note: Tested against actual per filter compression, simple method below
      //      produces PNG images for about 107% larger than per filter compression
      //      checking but with only 21% time taken or 4.76x faster.
      lv,p:longint;
   begin
   result:=0;

   if (x<>nil) and (xfrom0>=0) and (x.len>=1) then
      begin
      lv:=0;

      for p:=xfrom0 to frcmax32(xfrom0+drowsize-1,x.len-1) do if (lv<>x.pbytes[p]) then
         begin
         inc(result,x.pbytes[p]);
         lv:=x.pbytes[p];
         end;//p

      end;
   end;

   function xpaeth(a,b,c:byte):longint;
   var
      p,pa,pb,pc:longint;
   begin
   //a = left, b=above, c=upper left
   p:=a+b-c;//initial estimate
   pa:=abs(p-a);
   pb:=abs(p-b);
   pc:=abs(p-c);

   if (pa<=pb) and (pa<=pc) then result:=a
   else if (pb<=pc)         then result:=b
   else                          result:=c;
   end;

   procedure w32;
   begin
   drow.pbytes[di+0]:=c32.r;
   drow.pbytes[di+1]:=c32.g;
   drow.pbytes[di+2]:=c32.b;
   drow.pbytes[di+3]:=c32.a;
   inc(di,4);
   end;

   procedure w24;
   begin
   drow.pbytes[di+0]:=c32.r;
   drow.pbytes[di+1]:=c32.g;
   drow.pbytes[di+2]:=c32.b;
   inc(di,3);
   end;

   procedure w8;
   var
      v:byte;
   begin
   pfind(v);
   drow.pbytes[di+0]:=v;
   inc(di,1);
   end;

   procedure fsmallest(xsize,xmode:longint);
   begin
   if (xsize<fsize) then
      begin
      fsize:=xsize;
      fmode:=xmode;
      end;
   end;

   procedure fset(f:tstr8;xmode:byte);
   var
      p:longint;
   begin
   if (xmode>=1) and (f<>nil) then
      begin
      drow.pbytes[dpos-1]:=xmode;
      for p:=1 to drowsize do drow.pbytes[dpos+p-1]:=f.pbytes[p-1];
      end;
   end;
begin
//defaults
result   :=false;
e        :=gecTaskfailed;
pcount   :=0;
drow     :=nil;
lastf2   :=nil;
f1       :=nil;
f2       :=nil;
f3       :=nil;
f4       :=nil;
str1     :=nil;

try
//check
if not str__lock(d)              then goto skipend;
if not misok82432(s,sbits,sw,sh) then goto skipend;

//range
case dbits of
32,24,8:;
else    dbits:=32;
end;

//clear
str__clear(d);

//init
fbpp     :=dbits div 8;//bytes per pixel -> filter support
drowsize :=sw * fbpp;//unlike bitmap, PNG does not round rowsize to nearest 4bytes - 29may2025
lastf2   :=str__new8;
f1       :=str__new8;
f2       :=str__new8;
f3       :=str__new8;
f4       :=str__new8;
drow     :=str__new8;
str1     :=str__new8;

//image action -> less data - 06may2025
if      ia__found(daction,ia_bestquality) then pdiv:=1//off
else if ia__found(daction,ia_highquality) then pdiv:=2
else if ia__found(daction,ia_goodquality) then pdiv:=3
else if ia__found(daction,ia_fairquality) then pdiv:=4
else if ia__found(daction,ia_lowquality)  then pdiv:=5
else                                           pdiv:=1;//off

//make palette
if (dbits<=8) then
   begin
   plimit:=256;
   while not pmake do;
   end;

//header
str__aadd(d,[137,80,78,71,13,10,26,10]);

//IHDR                         //name   width.4     height.4   bitdepth.1  colortype.1 (6=R8,G8,B8,A8)  compressionMethod.1(#0 only = deflate/inflate)  filtermethod.1(#0 only) interlacemethod.1(#0=LR -> TB scanline order)
str1.clear;
str1.addint4( i32(sw) );
str1.addint4( i32(sh) );
str1.addbyt1(8);

//.color type
case dbits of
8 :str1.addbyt1(3);//8 => palette based (includes only RGB entries of any number between 1 and 256 entirely dependant on the size of DATA in "PLTE" chunk, need to use "tRNS" which like palette stores JUST the alpha values for each palette entry)
24:str1.addbyt1(2);//    0=greyscale, 1=palette used, 2=color used, 4=alpha used -> add these together to produce final value - 11jan2021
32:str1.addbyt1(6);
end;

str1.addbyt1(0);
str1.addbyt1(0);
str1.addbyt1(0);
daddchunk([uuI,uuH,uuD,uuR],str1);
str1.clear;

//scanlines
drow.setlen( sh * (1+drowsize) );//room for "filter style(1b)" + actual row data

//.filter support
f1.setlen(drowsize);
f2.setlen(drowsize);
f3.setlen(drowsize);
f4.setlen(drowsize);
lastf2.setlen(drowsize);
for p:=0 to (drowsize-1) do lastf2.pbytes[p]:=0;

di:=0;
for sy:=0 to (sh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;

drow.pbytes[di+0]:=0;//filter subtype=none (#0)
inc(di);
dpos:=di;

//.32
if (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   r32(sx);
   w32;
   end;//sx
   end
//.24
else if (dbits=24) then
   begin
   for sx:=0 to (sw-1) do
   begin
   r32(sx);
   w24;
   end;//sx
   end
//.8
else if (dbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   r32(sx);
   w8;
   end;//sx
   end;

//sample all filters and use the one that compresses the best
//.f0
flen0:=ddeflatesize(drow,dpos);

//.f1 -> sub -> write difference in pixels in horizontal lines
for p:=1 to drowsize do
begin
int1:=drow.pbytes[dpos+p-1];
if ((p-fbpp)>=1) then int2:=drow.pbytes[dpos+p-fbpp-1] else int2:=0;
int1:=int1-int2;
if (int1<0) then inc(int1,256);
f1.pbytes[p-1]:=int1;
end;//p
flen1:=ddeflatesize(f1,0);

//.f2 - up -> write difference in pixels in vertical lines
for p:=1 to drowsize do
begin
int2:=lastf2.pbytes[p-1];
int1:=drow.pbytes[dpos+p-1];
int1:=int1-int2;
if (int1<0) then inc(int1,256);
f2.pbytes[p-1]:=int1;
end;//p
flen2:=ddeflatesize(f2,0);

//.f3 - average
for p:=1 to drowsize do
begin
int3:=lastf2.pbytes[p-1];
if ((p-fbpp)>=1) then int2:=drow.pbytes[dpos+p-fbpp-1] else int2:=0;
int1:=drow.pbytes[dpos+p-1];
int1:=int1-trunc((int2+int3)/2);
if (int1<0) then inc(int1,256);
f3.pbytes[p-1]:=int1;
end;//p
flen3:=ddeflatesize(f3,0);

//.f4 - paeth
for p:=1 to drowsize do
begin
if ((p-fbpp)>=1) then int4:=lastf2.pbytes[p-fbpp-1] else int4:=0;
int3:=lastf2.pbytes[p-1];
if ((p-fbpp)>=1) then int2:=drow.pbytes[dpos+p-fbpp-1] else int2:=0;
int1:=drow.pbytes[dpos+p-1];
int1:=int1-xpaeth(int2,int3,int4);
if (int1<0) then inc(int1,256);
f4.pbytes[p-1]:=int1;
end;//p
flen4:=ddeflatesize(f4,0);

//.sync lastf2 -> do here BEFORE xrow is modified below - 14jan2021
for p:=1 to drowsize do lastf2.pbytes[p-1]:=drow.pbytes[dpos+p-1];

//.write filter back into row
fsize:=flen0;
fmode:=0;

fsmallest(flen1,1);
fsmallest(flen2,2);
fsmallest(flen3,3);
fsmallest(flen4,4);

//.write
case fmode of
1:fset(f1,1);
2:fset(f2,2);
3:fset(f3,3);
4:fset(f4,4);
end;//case

end;//sy

//.PLTE - rgb color palette -> must preceed "IDAT"
if (dbits<=8) then
   begin
   str1.setlen(pcount*3);

   for p:=0 to (pcount-1) do
   begin
   str1.pbytes[(p*3)+0]:=plist[p].r;
   str1.pbytes[(p*3)+1]:=plist[p].g;
   str1.pbytes[(p*3)+2]:=plist[p].b;
   end;//p

   daddchunk([uuP,uuL,uuT,uuE],str1);
   str1.clear;
   end;

//.tRNS - color palette of alpha values -> must follow "PLTE" and preceed "IDAT"
if (dbits<=8) and (sbits>=32) then
   begin
   str1.setlen(pcount);

   for p:=0 to (pcount-1) do str1.pbytes[p]:=plist[p].a;

   daddchunk([llt,uuR,uuN,uuS],str1);
   str1.clear;
   end;

//.IDAT
daddchunk2([uuI,uuD,uuA,uuT],drow,true);

//IEND
str1.clear;
daddchunk([uuI,uuE,uuN,uuD],str1);//27jan2021

//successful
result:=true;
skipend:
except;end;
//clear on error
if not result then str__clear(d);
//free
str__free(@lastf2);
str__free(@f1);
str__free(@f2);
str__free(@f3);
str__free(@f4);
str__free(@drow);
str__free(@str1);
str__uaf(d);
end;


function bmp__valid(x:tobject):boolean;
begin
result:=(x<>nil) and (x is tbitmap) and ((x as tbitmap).width>=1) and ((x as tbitmap).height>=1);
end;

function bmp__new24:tbitmap;
begin
try

result             :=nil;
result             :=tbitmap.create;
result.pixelformat :=pf24bit;
result.width       :=1;
result.height      :=1;

except;end;
end;

function bmp__size(x:tbitmap;w,h:longint):boolean;
begin
try

result:=(x<>nil);
if result and ( (w<>x.width) or (h<>x.height)) then
   begin

   x.width  :=w;
   x.height :=h;

   end;

except;result:=false;end;
end;


function tea__info3(adata:pobject;xsyszoom:boolean;var aw,ah,aSOD,aversion,aval1,aval2:longint;var atransparent,asyscolors:boolean):boolean;//18nov2024
label
   skipend;
var
   v:tint4;
   int1,xpos:longint;
begin
//defaults
result:=false;

try
aw:=0;
ah:=0;
aSOD:=13;
aversion:=1;
aval1:=0;
aval2:=0;
atransparent:=true;
asyscolors:=true;
//check
if (not str__lock(adata)) or (str__len(adata)<13) then goto skipend;
//get
//.header
int1:=str__bytes0(adata,3);
if (str__bytes0(adata,0)=uuT) and (str__bytes0(adata,1)=uuE) and (str__bytes0(adata,2)=uuA) and ( (int1=nn2) or (int1=nn3) ) and (str__bytes0(adata,4)=ssHash) then
   begin
   //init
   aSOD:=27;//zero based (27=28 bytes)
   xpos:=5;

   //version 2 = 24 bit color and version 3 = 32 bit color - 18nov2024
   if      (int1=nn2) then aversion:=2
   else if (int1=nn3) then aversion:=3
   else                    goto skipend;

   if (str__len(adata)<(aSOD+1)) then goto skipend;//1 based
   //transparent
   atransparent:=(str__bytes0(adata,xpos)<>0);
   inc(xpos,1);
   //syscolors -> black=font color, black+1=border color
   asyscolors:=(str__bytes0(adata,xpos)<>0);
   inc(xpos,1);
   //reserved 1-4
   inc(xpos,4);
   //val1
   v.bytes[0]:=str__bytes0(adata,xpos+0);
   v.bytes[1]:=str__bytes0(adata,xpos+1);
   v.bytes[2]:=str__bytes0(adata,xpos+2);
   v.bytes[3]:=str__bytes0(adata,xpos+3);
   inc(xpos,4);
   aval1:=v.val;
   //val2
   v.bytes[0]:=str__bytes0(adata,xpos+0);
   v.bytes[1]:=str__bytes0(adata,xpos+1);
   v.bytes[2]:=str__bytes0(adata,xpos+2);
   v.bytes[3]:=str__bytes0(adata,xpos+3);
   inc(xpos,4);
   aval2:=v.val;
   end
else if (str__bytes0(adata,0)=uuT) and (str__bytes0(adata,1)=uuE) and (str__bytes0(adata,2)=uuA) and (str__bytes0(adata,3)=nn1) and (str__bytes0(adata,4)=ssHash) then xpos:=5//TEA1#
else goto skipend;
//.w
v.bytes[0]:=str__bytes0(adata,xpos+0);
v.bytes[1]:=str__bytes0(adata,xpos+1);
v.bytes[2]:=str__bytes0(adata,xpos+2);
v.bytes[3]:=str__bytes0(adata,xpos+3);
aw:=v.val;
if (aw<=0) then goto skipend;
inc(xpos,4);
//.h
v.bytes[0]:=str__bytes0(adata,xpos+0);
v.bytes[1]:=str__bytes0(adata,xpos+1);
v.bytes[2]:=str__bytes0(adata,xpos+2);
v.bytes[3]:=str__bytes0(adata,xpos+3);
ah:=v.val;
if (ah<=0) then goto skipend;
//.multiplier

{$ifdef gui}
if xsyszoom then gui__zoom(aw,ah);
{$endif}

//successful
result:=true;
skipend:
except;end;
try;str__autofree(adata);except;end;
end;

function tea__fromdata32(d:tobject;sdata:pobject;var xw,xh:longint):boolean;//05oct2025
begin
result:=tea__fromdata322(d,sdata,false,xw,xh);
end;

function tea__fromdata322(d:tobject;sdata:pobject;xconverttransparency:boolean;var xw,xh:longint):boolean;//05oct2025
label//Supports "d" in 8/24/32 bits
   skipend,redo4,redo5;
var
   a4:tint4;
   a5:tcolor40;
   slen,p,dd,dbits,dx,dy,xSOD,xversion,xval1,xval2:longint;
   tr,tg,tb:byte;
   xfirst:boolean;
   dr8 :pcolorrow8;
   dr24:pcolorrow24;
   dr32:pcolorrow32;
   dc24:tcolor24;
   dc32:tcolor32;
   xtransparent,xsyscolors:boolean;
begin
//defaults
result:=false;
xw:=0;
xh:=0;
try
//check
if not str__lock(sdata) then goto skipend;
if not tea__info3(sdata,false,xw,xh,xSOD,xversion,xval1,xval2,xtransparent,xsyscolors) then goto skipend;
//size
if not missize(d,xw,xh) then goto skipend;
if not misok82432(d,dbits,xw,xh) then goto skipend;
//get

slen                  :=str__len(sdata);
dd                    :=xSOD;//start of data
dx                    :=0;
dy                    :=0;
xfirst                :=true;
xconverttransparency  :=xconverttransparency and (xversion<=2) and (dbits>=32);

if not misscan82432(d,dy,dr8,dr24,dr32) then goto skipend;

//.recsize = 4 bytes
if (xversion=1) or (xversion=2) then
   begin

redo4:
if ((dd+3)<slen) then
   begin

   a4.bytes[0]:=str__bytes0(sdata,dd+0);
   a4.bytes[1]:=str__bytes0(sdata,dd+1);
   a4.bytes[2]:=str__bytes0(sdata,dd+2);
   a4.bytes[3]:=str__bytes0(sdata,dd+3);

   //.get pixels
   if (a4.a>=1) then
      begin

      if xfirst then
         begin

         xfirst:=false;
         tr:=a4.r;
         tg:=a4.g;
         tb:=a4.b;

         end;

      for p:=1 to a4.a do
      begin
      case dbits of
      8:begin

         if (a4.g>a4.r) then a4.r:=a4.g;
         if (a4.b>a4.r) then a4.r:=a4.b;
         dr8[dx]:=a4.r;

         end;
      24:begin

         dc24.r:=a4.r;
         dc24.g:=a4.g;
         dc24.b:=a4.b;
         dr24[dx]:=dc24;

         end;
      32:begin

         dc32.r:=a4.r;
         dc32.g:=a4.g;
         dc32.b:=a4.b;

         //TEA v1 and v2 used 24bit color palettes and top-left pixel color when transparent
         case xconverttransparency and (tr=a4.r) and (tg=a4.g) and (tb=a4.b) of
         true:dc32.a:=0;
         else dc32.a:=255;
         end;//case

         dr32[dx]:=dc32;

         end;

      end;//case

      //.inc
      inc(dx);

      if (dx>=xw) then
         begin

         dx:=0;
         inc(dy);
         if (dy>=xh) then break;
         if not misscan82432(d,dy,dr8,dr24,dr32) then goto skipend;

         end;

      end;//p
      end;//a4.a

   //.loop
   inc(dd,4);
   if ((dd+3)<slen) then goto redo4;

   end;
   end

else if (xversion=3) then
   begin
//.recsize = 5 bytes
redo5:
if ((dd+4)<slen) then
   begin
   a5.r:=str__bytes0(sdata,dd+0);
   a5.g:=str__bytes0(sdata,dd+1);
   a5.b:=str__bytes0(sdata,dd+2);
   a5.a:=str__bytes0(sdata,dd+3);//not alpha BUT repeat count
   a5.c:=str__bytes0(sdata,dd+4);//alpha value

   //.get pixels
   if (a5.a>=1) then
      begin
      for p:=1 to a5.a do
      begin
      case dbits of
      8:begin
         if (a5.g>a5.r) then a5.r:=a5.g;
         if (a5.b>a5.r) then a5.r:=a5.b;
         dr8[dx]:=a5.r;
         end;
      24:begin
         dc24.r:=a5.r;
         dc24.g:=a5.g;
         dc24.b:=a5.b;
         dr24[dx]:=dc24;
         end;
      32:begin
         dc32.r:=a5.r;
         dc32.g:=a5.g;
         dc32.b:=a5.b;
         dc32.a:=a5.c;//18nov2024
         dr32[dx]:=dc32;
         end;
      end;//case
      //.inc
      inc(dx);
      if (dx>=xw) then
         begin
         dx:=0;
         inc(dy);
         if (dy>=xh) then break;
         if not misscan82432(d,dy,dr8,dr24,dr32) then goto skipend;
         end;
      end;//p
      end;//a5.a
   //.loop
   inc(dd,5);
   if ((dd+4)<slen) then goto redo5;
   end;
   end;

//xtransparent
misai(d).transparent:=xtransparent;//07apr2021
misai(d).syscolors:=xsyscolors;//13apr2021
//successful
result:=true;
skipend:
except;end;
try;str__uaf(sdata);except;end;
end;


function tep__fromdata(s:tobject;d:pobject;var e:string):boolean;//05oct2025
label//s=target image to fill, d=data we're reading image from
   skipend;

const
   rpccPal8:array[0..7] of longint=(clBlack,clRed,clYellow,clLime,clBlue,clSilver,clGray,clWhite);
   rpccBPPS:array[0..8] of longint =(0,2,4,8,16,32,64,128,256);//bbp => colors
   tpccSOF                         =29;//Encoded Value - Start of File
   tpccEOF                         =35;//End of File
   tpccEOP                         =126;//End of Palette
   tpccStartComment                =123;// '{'
   tpccEndComment                  =125;// '}'
   tpccMaxInt                      =16777216;

var
   dlen:longint;
    spal8:array[0..255] of tcolor8;
   spal24:array[0..255] of tcolor24;
   spal32:array[0..255] of tcolor32;
   pcount,spalCount:longint;
   xpos,sbits,sx,sy,sw,sh,sbpp:longint;
   xtransColorIndex:byte;
   c32:tcolor32;
   sr32:pcolorrow32;
   sr24:pcolorrow24;
    sr8:pcolorrow8;

   function v1:byte;
   begin

   if (xpos>=0) and (xpos<dlen) then
      begin

      result:=str__pbytes0(d,xpos);
      inc(xpos);

      end
   else result:=0;

   end;

   function xasnum(var x:byte):boolean;
   begin

   result:=true;

   case x of
   48..57   :dec(x,48);//0-9=10 "0..9"
   65..90   :dec(x,55);//10-35=26 "a..z"
   97..122  :dec(x,61);//36-61=26 "a..z"
   40..41   :inc(x,22);//62-63=2 "(..)"
   else      x:=0;
   end;//case

   end;

   function xasnumb(const x:byte):byte;
   begin
   result:=x;
   xasnum(result);
   end;

   function xheader:boolean;
   label
      skipend,redo;
   var
      int1,commentcount,count,p:longint;
      v:byte;
      c24:tcolor24;
      eop,eof:boolean;
   begin

   //defaults
   result       :=false;

   //check
   if (dlen<=0) then exit;

   //init
   commentcount :=0;
   eof          :=false;
   eop          :=false;
   count        :=0;

   //read
   redo:

   if (xpos>=dlen) then goto skipend;
   v:=v1;

   //.start of comment
   case v of
   tpccstartcomment  :inc(commentcount);//start of embedded comment
   tpccendcomment    :dec(commentcount);//end of embedded comment
   tpcceof           :if (commentcount=0) then eof:=true;//end of file
   tpcceop           :if (commentcount=0) then eop:=true;//end of palette and header
   else begin

      if (commentcount=0) then
         begin

         xasnum(v);

         case count of

         //t
         0:if (v=tpccsof) then inc(count);

         //bits/per/pixel 1-6
         1:case (v>=1) and (v<=6) of
           true:begin

              sbpp       :=v;
              spalCount  :=rpccbpps[sbpp];

              //.standard color palette
              for p:=0 to high(rpccPal8) do
              begin

              spal32[p]:=inta__c32(rpccPal8[p],255);
              spal24[p]:=int__c24(rpccPal8[p]);
               spal8[p]:=int__c8(rpccPal8[p]);

              end;//p

              inc(count);

              end;
           false:goto skipend;{unsupported bbp 1-3 only}
           end;//end of case

         //width and height
         2,3:begin

            case count of
            2:begin

               sw:=v;
               inc(sw,xasnumb(v1)*64);
               inc(sw,xasnumb(v1)*64*64);
               inc(count);

               end;
            3:begin

               sh:=v;
               inc(sh,xasnumb(v1)*64);
               inc(sh,xasnumb(v1)*64*64);
               inc(count);

               end;
            end;//case

            end;

         //palette 1-N
         4:begin

            int1             := v +(xasnumb(v1)*64) + (xasnumb(v1)*64*64) + (xasnumb(v1)*64*64*64);
            spal32[pcount]   :=inta__c32(int1,255);
            spal24[pcount]   :=int__c24(int1);
             spal8[pcount]   :=int__c8(int1);

            inc(pcount);

            if (pcount>=spalCount) then inc(count);

            end;

         5:;//null - wait for eop or eop
         end;//case

         end;//if

      end;//begin
   end;//case

   //loop
   if (not eop) and (not eof) then goto redo;

   //successful
   result:=eop and (sbpp>0) and (sw>0) and (sh>0);

   skipend:
   end;

   function pr(const x:byte):byte;
   begin
   if (x>=0) and (x<spalCount) then result:=x else result:=pred(spalCount);
   end;

   procedure p1(x:byte);
   var
      v:byte;
   begin

   //top-left pixel is assumed to be transparent -> record index and use from this point on
   if (sx=0) and (sy=0) then xtransColorIndex:=x;

   //draw non-transparent pixels only
   if (sx<sw) and (sy<sh) and (x<>xtransColorIndex) then
      begin

      case sbits of
       8:sr8 [sx]:=spal8[x];
      24:sr24[sx]:=spal24[x];
      32:sr32[sx]:=spal32[x];
      end;//case

      end;

   //inc to next pixel/row
   inc(sx);

   if (sx>=sw) then
      begin

      sx:=0;
      inc(sy);
      if (sy<sh) then misscan82432(s,sy,sr8,sr24,sr32);

      end;

   end;

   procedure pp(x:byte);
   var
      v1,v2,v3,v4,v5:byte;
   begin

   case sbpp of

   //16/32/64 color : (0-63)
   4..6:p1( pr(x) );

   //8 color : (0-7) + (0-7)*8
   3:begin

     //get
     v1:=pr(x div 8);
     dec(x,v1*8);

     //set
     p1( pr(x) );
     p1(v1);

     end;

   //4 color : (0-3) + (0-3)*4 + (0-3)*16
   2:begin

     //get
     v1:=pr(x div 16);
     dec(x,v1*16);

     v2:=pr(x div 4);
     dec(x,v2*4);

     //set
     p1( pr(x) );
     p1(v2);
     p1(v1);

     end;

   //2 color : (0-1) + (0-1)*2 + (0-1)*4 + (0-1)*8 + (0-1)*16 + (0-1)*32
   1:begin

     //get
     v1:=pr(x div 32);
     dec(x,v1*32);

     v2:=pr(x div 16);
     dec(x,v2*16);

     v3:=pr(x div 8);
     dec(x,v3*8);

     v4:=pr(x div 4);
     dec(x,v4*4);

     v5:=pr(x div 2);
     dec(x,v5*2);

     //set
     p1( pr(x) );
     p1(v5);
     p1(v4);
     p1(v3);
     p1(v2);
     p1(v1);

     end;
   else exit;//unknown bpp

   end;//case

   end;

   function xreadpixels:boolean;
   label
      redo;
   var
      commentcount:longint;
      v:byte;
      z:tcolor24;
      eof:boolean;
   begin

   //defaults
   result        :=false;
   commentcount  :=0;
   eof           :=false;
   misscan82432(s,0,sr8,sr24,sr32);

   //read
   redo:
   v:=v1;

   //.start comment
   case v of
   tpccstartcomment :inc(commentcount);
   tpccendcomment   :dec(commentcount);
   tpcceof          :if (commentcount=0) then eof:=true;
   else if (commentcount=0) and xasnum(v) then pp(v);
   end;

   //loop
   if (not eof) and (xpos<dlen) then goto redo;

   //successful
   result:=true;

   end;

begin

//defaults
result :=false;

try
//check
if not str__lock(d)                       then goto skipend;
if not misok82432(s,sbits,sw,sh)          then goto skipend;

//init
dlen          :=str__len(d);
sw            :=0;
sh            :=0;
sx            :=0;
sy            :=0;
sbpp          :=6;//6 bit => 64 colors
xpos          :=0;
pcount        :=0;
spalCount     :=0;
low__cls(@spal32,sizeof(spal32));
low__cls(@spal24,sizeof(spal24));
low__cls(@spal8 ,sizeof(spal8));

//read header
if not xheader then goto skipend;

//check version
if (sBpp<1) or (sBpp>6) then goto skipend;

//check width and height
if (sw<=0) or (sh<=0) then goto skipend;

//size and cls
missize(s,sw,sh);
mis__cls(s,255,255,255,0);

//read pixels
if not xreadpixels then goto skipend;

//successful
result:=true;

skipend:
except;end;

//free
str__uaf(d);

end;



//jpg procs --------------------------------------------------------------------
function jpg__can:boolean;
begin
{$ifdef jpeg}result:=true;{$else}result:=false;{$endif}
end;

function jpg__fromdata(s:tobject;d:pobject;var e:string):boolean;
label
   skipend;
var
   sbits,sw,sh:longint;
begin
//defaults
result :=false;
e      :=gecTaskfailed;

try
{$ifdef jpeg}

//check
if not str__lock(d)               then goto skipend;
if not misok82432(s,sbits,sw,sh)  then goto skipend;

//get
if not jpg____fromdata(d,s) then goto skipend;//04may2025

//ai information
misai(s).count       :=1;
misai(s).cellwidth   :=misw(s);
misai(s).cellheight  :=mish(s);
misai(s).delay       :=0;
misai(s).transparent :=false;
misai(s).bpp         :=24;

//successful
result:=true;

{$endif}
skipend:
except;end;
//free
str__uaf(d);
end;


//bmp procs --------------------------------------------------------------------
function bmp32__todata3(s:tobject;d:pobject;dfullheader:boolean;dinfosize,dbits:longint):boolean;//11jun2025: dinfosize, 09jun2025, 28may2025, 15may2025
label//Special Note: if (dbits=24) then V1 (hsW95) header should be used for Clipboard compatibility - 09jun2025
   skipend;
var
   p,dcompression,ymax,dheadsize,dpos,dbytes,drowsize,sbits,sx,sy,sw,sh:longint;
   d8  :tstr8;//pointer only
   sr32:pcolorrow32;
   sr24:pcolorrow24;
   sr8 :pcolorrow8;
   c32 :tcolor32;
   c24 :tcolor24;

   procedure w1(const x:byte);
   begin
   if (dpos<dbytes) then
      begin
      if (d8<>nil) then d8.pbytes[dpos]:=x else str__setbyt1(d,dpos,x);
      end;
   inc(dpos,1);
   end;

   procedure w2(const x:word);
   begin
   w1(twrd2(x).bytes[0]);
   w1(twrd2(x).bytes[1]);
   end;

   procedure w4(const x:longint);
   begin
   w1(tint4(x).bytes[0]);
   w1(tint4(x).bytes[1]);
   w1(tint4(x).bytes[2]);
   w1(tint4(x).bytes[3]);
   end;

   procedure w16;//0..255 div 8 -> 0..31 (555 => 5 bit each for RGB)
   begin
   w2( (c32.b div 8) + ((c32.g div 8)*32) + ((c32.r div 8)*1024) );//15 bit
   end;
begin
//defaults
result:=false;
d8    :=nil;

try
//check
if not str__lock(d)                            then goto skipend;
if not misok82432(s,sbits,sw,sh)               then goto skipend;
if (dbits<>32) and (dbits<>24) and (dbits<>16) then goto skipend;

//dinfosize - filter
case dinfosize of
hsOS2:;
hsW95:;
hsV04_nocolorspace:;
hsV04:;
hsV05:;//OK
0:if (sbits=32) and (dbits=32) and mask__hastransparency32(s) then dinfosize:=hsV05 else dinfosize:=hsW95;
else dinfosize:=hsW95;
end;

//dcompression - decide
case dinfosize of
hsV04_nocolorspace,hsV04,hsV05:dcompression:=BI_BITFIELDS;
else                           dcompression:=BI_RGB;
end;//case

//range
if (dinfosize=hsOS2) then//only handles 16bit width/height values
   begin
   sw:=frcmax32(sw,max16);
   sh:=frcmax32(sh,max16);
   end;

//init
drowsize  :=mis__rowsize4(sw,dbits);//nearest 4 bytes
dheadsize :=low__aorb(dinfosize, dinfosize+14, dfullheader);
dbytes    :=dheadsize + (sh * drowsize);
ymax      :=sh-1;
dpos      :=0;

//size
if not str__setlen(d,dbytes) then goto skipend;
d8:=str__as8(d);

//zero the header section
for p:=0 to (dheadsize-1) do  str__setbytes0(d,p,0);

//bmp header (14)
if dfullheader then
   begin
   w1(uuB);
   w1(uuM);
   w4(dbytes);//size
   w2(0);
   w2(0);
   w4(dheadsize);
   end;


//bitmapinfoheader

//.hsOS2
if (dinfosize=hsOS2) then
   begin
   //.size4
   w4(dinfosize);

   //.width2
   w2(sw);

   //.height2
   w2(sh);

   //.planes2
   w2(1);

   //.bits2
   w2(dbits);
   end

//.hsW95..hsV05
else
   begin
   //.size4
   w4(dinfosize);

   //.width4
   w4(sw);

   //.height4
   w4(sh);

   //.planes2
   w2(1);

   //.bits2
   w2(dbits);

   //.blank4
   w4(dcompression);

   //.imagesize
   w4(sh *drowsize);

   //.bV4XPelsPerMeter
   w4(0);

   //.bV4YPelsPerMeter
   w4(0);

   //.bV4ClrUsed
   w4(0);

   //.bV4ClrImportant
   w4(0);

   //.v4 header extension -> permits saving of 32bit image with alpha channel - 09jun2025
   if (dinfosize>=hsV04_nocolorspace) then
      begin
      w4( rgba__int(0,0,255,0) );//red mask
      w4( rgba__int(0,255,0,0) );//green mask
      w4( rgba__int(255,0,0,0) );//blue mask
      w4( rgba__int(0,0,0,255) );//alpha mask

      //csType - bV4CSType/bV5CSType
      w1(uuB);
      w1(uuG);
      w1(uuR);
      w1(llS);

      //jump back from end of header to "intent" is -16
      if (dinfosize=hsV05) then
         begin
         dpos:=dheadsize-16;
         w4(4);//same as Gimp
         end;
      end;
   end;

//get
for sy:=0 to (sh-1) do
begin
if not misscan82432(s,ymax-sy,sr8,sr24,sr32) then goto skipend;

dpos:=dheadsize + (sy*drowsize);

//.32 -> 32
if (sbits=32) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c32:=sr32[sx];
   w1(c32.b);
   w1(c32.g);
   w1(c32.r);
   w1(c32.a);
   end;//sx
   end
//.32 -> 24
else if (sbits=32) and (dbits=24) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c32:=sr32[sx];
   w1(c32.b);
   w1(c32.g);
   w1(c32.r);
   end;//sx
   end
//.32 -> 16
else if (sbits=32) and (dbits=16) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c32:=sr32[sx];
   w16;
   end;//sx
   end
//.24 -> 32
else if (sbits=24) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c24:=sr24[sx];
   w1(c24.b);
   w1(c24.g);
   w1(c24.r);
   w1(255);
   end;//sx
   end
//.24 -> 24
else if (sbits=24) and (dbits=24) then//28may2025: fixed
   begin
   for sx:=0 to (sw-1) do
   begin
   c24:=sr24[sx];
   w1(c24.b);
   w1(c24.g);
   w1(c24.r);
   end;//sx
   end
//.24 -> 16
else if (sbits=24) and (dbits=16) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c24:=sr24[sx];
   c32.r:=c24.r;
   c32.g:=c24.g;
   c32.b:=c24.b;
   w16;
   end;//sx
   end
//.8 -> 32
else if (sbits=8) and (dbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c24.r:=sr8[sx];
   w1(c24.r);
   w1(c24.r);
   w1(c24.r);
   w1(255);
   end;//sx
   end
//.8 -> 24
else if (sbits=8) and (dbits=24) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c24.r:=sr8[sx];
   w1(c24.r);
   w1(c24.r);
   w1(c24.r);
   end;//sx
   end
//.8 -> 16
else if (sbits=8) and (dbits=16) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c24.r:=sr8[sx];
   c32.r:=c24.r;
   c32.g:=c24.r;
   c32.b:=c24.r;
   w16;
   end;//sx
   end;

end;//sy

//successful
result:=true;
skipend:
except;end;
//clear on error
if not result then str__clear(d);
//free
str__uaf(d);
end;

function bmp__fromdata(d:tobject;s:pobject;var e:string):boolean;
var
   xbpp:longint;
begin
result:=bmp__fromdata2(d,s,xbpp,e);
end;

function bmp__fromdata2(d:tobject;s:pobject;var xbits:longint;var e:string):boolean;//15mar2025
label
   skipend;
var
   sheadstyle,scompression,slen,spos,int1,int2,sbits,dbits:longint;

   function r1:byte;
   begin
   if (spos<slen) then result:=str__byt1(s,spos) else result:=0;
   inc(spos);
   end;

   function r2:word;
   begin
   twrd2(result).bytes[0]:=r1;
   twrd2(result).bytes[1]:=r1;
   end;

   function r4:longint;
   begin
   tint4(result).bytes[0]:=r1;
   tint4(result).bytes[1]:=r1;
   tint4(result).bytes[2]:=r1;
   tint4(result).bytes[3]:=r1;
   end;
begin
//defaults
result:=false;
e     :=gecTaskfailed;
xbits :=32;//default

try
//check
if not str__lock(s)                  then goto skipend;
if not misok82432(d,dbits,int1,int2) then goto skipend;

//init
slen      :=str__len(s);
spos      :=0;
if (slen<12) then goto skipend;

//bmp header
if (r1=uuB) and (r1=uuM) then spos:=14//jump to main header
else                          spos:=0;

//.0S/2 and Win3.1 header (12b)
sheadstyle:=r4;

case sheadstyle of
hsOS2:;
hsW95:;
hsV04_nocolorspace:;
hsV04:;
hsV05:;
else goto skipend;//unsupported header size (type)
end;


//.read header fields
if (sheadstyle=hsOS2) then
   begin
   //.width2
   if (r2<=0) then goto skipend;

   //.height2
   if (r2<=0) then goto skipend;

   //.planes2
   if (r2<>1) then goto skipend;

   //.bits2
   sbits:=r2;
   case sbits of
   1,4,8,16,24,32:;
   else goto skipend;
   end;

   end
else
   begin
   //common fields to all 3 remaining headers

   //.width4
   if (r4<=0) then goto skipend;

   //.height4 - 08jun2025
   if (low__posn(r4)<=0) then goto skipend;

   //.planes2
   if (r2<>1) then goto skipend;

   //.bits2
   sbits:=r2;
   case sbits of
   1,4,8,16,24,32:;
   else goto skipend;
   end;

   //.compression4
   scompression:=r4;
   case scompression of
   bi_rgb       :;//ok for all bit depths
   bi_bitfields :if ((sbits<>16) and (sbits<>32)) or (sheadstyle<hsW95) then goto skipend;
   bi_rle4      :if (sbits<>4) then goto skipend;
   bi_rle8      :if (sbits<>8) then goto skipend;
   bi_jpeg      :if (sbits<16) then goto skipend;
   bi_png       :if (sbits<16) then goto skipend;
   else                             goto skipend;
   end;//case

   end;


//get
xbits:=sbits;

case sbits of
16,24,32:result:=bmp32__fromdata(d,s);
1,4,8   :result:=bmp8__fromdata(d,s);
end;

//.ai information
if result then
   begin
   misai(d).count       :=1;
   misai(d).cellwidth   :=misw(d);
   misai(d).cellheight  :=misw(d);
   misai(d).delay       :=0;
   misai(d).transparent :=false;//alpha channel is used instead (if supplied image was 32bit)
   misai(d).bpp         :=xbits;
   end;

skipend:
except;end;
//clear on error
if not result then
   begin
   missize(d,1,1);
   misaiclear2(d);
   end;
//free
str__uaf(s);
end;

function bmp32__fromdata(d:tobject;s:pobject):boolean;//11jun2025: supports DIB +12b patch, 15may2025
begin
result:=bmp32__fromdata2(d,s,true);
end;

function bmp32__fromdata2(d:tobject;s:pobject;sallow_dib_patch_12:boolean):boolean;//12jun2025: dib_patch_12 control, 11jun2025: supports DIB +12b patch, 15may2025
label
   skipend;
var
   e:string;
   sintent,sstartofdata,slen,sheadstyle,sinfosize,simagesize,scompression,spos,srowsize,dbits,dw,dh,dx,dy,int1,int2,sbits:longint;
   vb32,rmask,gmask,bmask,amask,sr,sg,sb,sa,mr,mg,mb,ma:longint;//mask support (scompression=bi_bitfields)
   sdib_patchmode_12,sdib,dflip:boolean;
   s8  :tstr8;//pointer only
   dr32:pcolorrow32;
   dr24:pcolorrow24;
   dr8 :pcolorrow8;
   c32 :tcolor32;
   c24 :tcolor24;
   b   :tobject;

   function xscalemultipler(xbitsused:longint):longint;
   begin
   case xbitsused of
   8:result:=1;
   7:result:=2;
   6:result:=4;
   5:result:=8;
   4:result:=17;
   3:result:=36;
   2:result:=85;
   1:result:=255;
   else result:=1;
   end;//case
   end;

   function r1:byte;
   begin
   case (spos<slen) of
   true:if (s8<>nil) then result:=s8.pbytes[spos] else result:=str__byt1(s,spos);
   else result:=0;
   end;//case
   //inc
   inc(spos);
   end;

   function r2:word;
   begin
   twrd2(result).bytes[0]:=r1;
   twrd2(result).bytes[1]:=r1;
   end;

   function r3:longint;
   begin
   tint4(result).bytes[0]:=r1;
   tint4(result).bytes[1]:=r1;
   tint4(result).bytes[2]:=r1;
   tint4(result).bytes[3]:=0;
   end;

   function r4:longint;
   begin
   tint4(result).bytes[0]:=r1;
   tint4(result).bytes[1]:=r1;
   tint4(result).bytes[2]:=r1;
   tint4(result).bytes[3]:=r1;
   end;

   function bb(const rgbaVALUE,rgbaMASK,rgbaSHIFTRIGHT,rgbaMULTIPLIER:longint):byte;//bit-mask processor - 08jun2025
   var
      v:longint;
   begin
   //get
   v:=rgbaVALUE and rgbaMASK;//use AND to extract component value from pixel value (e.g. RGBA -> Red only with red-mask)
   v:=v shr rgbaSHIFTRIGHT;//shift value to right to bring to zero it (0..N)

   //scale to 8bit
   if (rgbaMULTIPLIER<>1) then v:=v*rgbaMULTIPLIER;

   //range check
   if (v<0) then v:=0 else if (v>255) then v:=255;

   //set
   result:=byte(v);
   end;

   procedure rb;
   begin
   c32.r:=bb(vb32,rmask,sr,mr);
   c32.g:=bb(vb32,gmask,sg,mg);
   c32.b:=bb(vb32,bmask,sb,mb);
   if (amask=0) then c32.a:=255 else c32.a:=bb(vb32,amask,sa,ma);
   end;

   procedure r16;//555 = 15bit
   var//0..255 div 8 -> 0..31 (5 bit)
      v:word;

      procedure p(var dcol:byte;xfactor:longint);
      var
         z:word;
      begin
      z:=v div xfactor;
      dec(v,z*xfactor);
      z:=z*8;
      if (z>255) then z:=255;
      dcol:=z;
      end;
   begin
   if (scompression=bi_bitfields) then
      begin
      vb32:=r2;
      rb;
      end
   else
      begin
      v:=r2;
      p(c32.r,1024);
      p(c32.g,32);
      p(c32.b,1);
      c32.a:=255;
      end;
   end;

   procedure r24;
   begin
   if (scompression=bi_bitfields) then
      begin
      vb32:=r3;
      rb;
      end
   else
      begin
      c32.b:=r1;
      c32.g:=r1;
      c32.r:=r1;
      c32.a:=255;
      end;
   end;

   procedure r32;
   begin
   if (scompression=bi_bitfields) then
      begin
      vb32:=r4;
      rb;
      end
   else
      begin
      c32.b:=r1;
      c32.g:=r1;
      c32.r:=r1;
      c32.a:=r1;
      end;
   end;
begin
//defaults
result           :=false;
s8               :=nil;
b                :=nil;
sinfosize        :=0;
simagesize       :=0;
scompression     :=bi_rgb;
dflip            :=false;
sintent          :=0;
rmask            :=0;
gmask            :=0;
bmask            :=0;
amask            :=0;
sdib_patchmode_12:=false;//supports the DIB +12b "patch mode" by checking expected and actual total data sizes for a 12byte discrepancy - 12jun2025

try
//check
if not str__lock(s)                  then goto skipend;
if not misok82432(d,dbits,int1,int2) then goto skipend;

//init
s8        :=str__as8(s);
slen      :=str__len(s);
spos      :=0;
if (slen<12) then goto skipend;

//bmp header
if (r1=uuB) and (r1=uuM) then
   begin
   sdib        :=false;
   spos        :=10;
   sstartofdata:=frcmin32(r4,0);
   sinfosize   :=14;
   spos        :=14;//jump to main header
   end
else
   begin
   sdib        :=true;
   spos        :=0;
   sstartofdata:=0;
   end;

//info header
//.size4
sheadstyle:=r4;
inc(sinfosize,sheadstyle);

//.check header type
case sheadstyle of
hsOS2:;
hsW95:;
hsV04_nocolorspace:;
hsV04:;
hsV05:;
else goto skipend;//unsupported header size (type)
end;//case

//.header too small
if (sheadstyle<hsOS2) then goto skipend

//.0S/2 and Win3.1 header (12b)
else if (sheadstyle=hsOS2) then
   begin
   //.width2
   dw:=r2;
   if (dw<=0) then goto skipend;

   //.height2
   dh:=r2;
   if (dh<=0) then goto skipend;

   //.planes2
   if (r2<>1) then goto skipend;

   //.bits2
   sbits:=r2;

   case sbits of
   0       :sbits:=32;//assumes a JPEG or PNG image is present
   16,24,32:;//ok
   else     goto skipend;//unsupported
   end;//case

   end
//.hsW95, hsV04_nocolorspace, hsV04 and hsV05
else if (sheadstyle>=hsW95) then
   begin
   //common fields to all 3 remaining headers

   //.width4
   dw:=r4;
   if (dw<=0) then goto skipend;

   //.height4 - 08jun2025
   int1  :=r4;
   dflip :=(int1<0);
   dh    :=low__posn(int1);

   if (dh<=0) then goto skipend;

   //.planes2
   if (r2<>1) then goto skipend;

   //.bits2
   sbits:=r2;

   case sbits of
   0       :sbits:=32;//assumes a JPEG or PNG image is present
   16,24,32:;//ok
   else     goto skipend;//unsupported
   end;//case

   //.compression4
   scompression:=r4;
   case scompression of
   bi_rgb       :;//ok for all bit depths
   bi_bitfields :if ((sbits<>16) and (sbits<>32)) or (sheadstyle<hsW95) then goto skipend;
   bi_jpeg      :if (sbits<16) then goto skipend;
   bi_png       :if (sbits<16) then goto skipend;
   else                             goto skipend;
   end;//case

   //.image size - required when compression type is JPEG or PNG
   simagesize:=r4;

   //.bitfields support
   if (scompression=bi_bitfields) then
      begin

      //.sdib_patchmode_12 -> there is no clear indication when this is to be used only the total bytes is +12 more than expected - 12jun2025
      if sdib and sallow_dib_patch_12 and ( (sinfosize+simagesize+12)=str__len(s) ) then
         begin
         sdib_patchmode_12:=true;
         inc(sinfosize,12);
         end;

      //.hsW95 (when BMP has no mask bits -> can be 555 or 565, assume 565)
      if (sheadstyle=hsW95) then
         begin

         //.DIB only - invalid for BMP
         if sdib_patchmode_12 then
            begin
            spos:=sinfosize-12;
            rmask:=r4;
            gmask:=r4;
            bmask:=r4;
            amask:=0;
            end;

         end

      //.hsV04 and V05
      else
         begin
         //read mask values
         r4;//bV5XPelsPerMeter;
         r4;//bV5YPelsPerMeter;
         r4;//bV5ClrUsed;
         r4;//bV5ClrImportant;//0..39

         //.rgba bit-masks
         rmask:=r4;
         gmask:=r4;
         bmask:=r4;
         amask:=r4;

         end;

      //.fallback to default "565" with no alpha
      if (rmask=0) and (gmask=0) and (bmask=0) and (amask=0) then
         begin
         rmask:=63488;
         gmask:=2016;
         bmask:=31;
         amask:=0;
         end;

      //mask support values
      //.shift right count
      sr:=bit__findfirst32(rmask);
      sg:=bit__findfirst32(gmask);
      sb:=bit__findfirst32(bmask);
      sa:=bit__findfirst32(amask);

      //.mulitpler to scale value back to a range of 0..255 (8 bit)
      mr:=xscalemultipler(bit__findcount32(rmask));
      mg:=xscalemultipler(bit__findcount32(gmask));
      mb:=xscalemultipler(bit__findcount32(bmask));
      ma:=xscalemultipler(bit__findcount32(amask));

      //jump back from end of header to beginning of "intent" is -16
      if (sheadstyle=hsV05) then
         begin
         spos:=sinfosize-16;
         sintent:=r4;
         end;
      end;

   end
else goto skipend;

//init
srowsize  :=mis__rowsize4(dw,sbits);

//size
if not missize(d,dw,dh) then goto skipend;

//start of data
sstartofdata:=largest32(sstartofdata,sinfosize);

//decide
case scompression of
bi_jpeg:begin
   result:=str__add3(@b,s,sstartofdata,simagesize) and jpg__fromdata(d,@b,e);
   goto skipend;
   end;
bi_png:begin
   b:=str__newsametype(s);
   result:=str__add3(@b,s,sstartofdata,simagesize) and png__fromdata(d,@b,e);
   goto skipend;
   end;
end;

//get
for dy:=0 to (dh-1) do
begin

case dflip of
true:if not misscan82432(d,dy,dr8,dr24,dr32)      then goto skipend;
else if not misscan82432(d,dh-1-dy,dr8,dr24,dr32) then goto skipend;
end;//case

spos:=sstartofdata + (dy*srowsize);

//.32 -> 32
if (sbits=32) and (dbits=32) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r32;
   dr32[dx]:=c32;
   end;//dx
   end
//.32 -> 24
else if (sbits=32) and (dbits=24) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r32;
   c24.r:=c32.r;
   c24.g:=c32.g;
   c24.b:=c32.b;
   dr24[dx]:=c24;
   end;//dx
   end
//.32 -> 8
else if (sbits=32) and (dbits=8) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r32;
   dr8[dx]:=c32__lum(c32);
   end;//dx
   end
//.24 -> 32
else if (sbits=24) and (dbits=32) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r24;
   dr32[dx]:=c32;
   end;//dx
   end
//.24 -> 24
else if (sbits=24) and (dbits=24) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r24;
   c24.r:=c32.r;
   c24.g:=c32.g;
   c24.b:=c32.b;
   dr24[dx]:=c24;
   end;//dx
   end
//.24 -> 8
else if (sbits=24) and (dbits=8) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r24;
   dr8[dx]:=c32__lum(c32);
   end;//dx
   end
//.16 -> 32
else if (sbits=16) and (dbits=32) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r16;
   dr32[dx]:=c32;
   end;//dx
   end
//.16 -> 24
else if (sbits=16) and (dbits=24) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r16;
   c24.r:=c32.r;
   c24.g:=c32.g;
   c24.b:=c32.b;
   dr24[dx]:=c24;
   end;//dx
   end
//.16 -> 8
else if (sbits=16) and (dbits=8) then
   begin
   for dx:=0 to (dw-1) do
   begin
   r16;
   dr8[dx]:=c32__lum(c32);
   end;//dx
   end;

end;//dy

//successful
result:=true;
skipend:
except;end;
//clear on error
if not result then missize(d,1,1);
//free
str__free(@b);
str__uaf(s);
end;

function bmp24__fromdata(d:tobject;s:pobject):boolean;//15may2025
begin
result:=bmp32__fromdata(d,s);
end;

function bmp16__fromdata(d:tobject;s:pobject):boolean;//15may2025
begin
result:=bmp32__fromdata(d,s);
end;

function bmp8__fromdata(d:tobject;s:pobject):boolean;//09jun2025: supports bi_rgb + bi_rle8 + bi_rle4, 15may2025
label
   skipend;
var
   plist:array[0..255] of tcolor32;
   sstartofdata,pcolsize,simagesize,sheadstyle,sinfosize,scompression,pval,px,p,plimit,pcount,slen,spos,srowsize,dbits,dw,dh,dx,dy,int1,int2,sbits:longint;
   dflip:boolean;
   s8  :tstr8;//pointer only
   dr32:pcolorrow32;
   dr24:pcolorrow24;
   dr8 :pcolorrow8;
   c32 :tcolor32;
   c24 :tcolor24;

   function r1:byte;
   begin
   case (spos<slen) of
   true:if (s8<>nil) then result:=s8.pbytes[spos] else result:=str__byt1(s,spos);
   else result:=0;
   end;//case
   //inc
   inc(spos);
   end;

   function r2:word;
   begin
   twrd2(result).bytes[0]:=r1;
   twrd2(result).bytes[1]:=r1;
   end;

   function r4:longint;
   begin
   tint4(result).bytes[0]:=r1;
   tint4(result).bytes[1]:=r1;
   tint4(result).bytes[2]:=r1;
   tint4(result).bytes[3]:=r1;
   end;

   function xread_rle48:boolean;
   label
      skipend;
   var
      acount,vcount,sp,p,ylast,dx,dy,v,v1,v2:longint;
      bol1,srle8:boolean;

      function xreadpixel4(const x:byte;var xfirst:boolean):byte;
      begin
      result:=x div 16;
      if not xfirst then result:=x - (result*16);
      //inc
      xfirst:=not xfirst;
      end;

      procedure xpush(i:byte);
      begin
      //check

      //.dx
      if (dx>=dw) then
         begin
         dx:=0;
         inc(dy);
         end;

      //.dy
      if (dy>=dh) then exit;

      //range
      if (i>=plimit) then i:=plimit-1;
      c32:=plist[i];

      //init
      if (ylast<>dy) then
         begin
         ylast:=dy;

         case dflip of
         true:misscan82432(d,dy,dr8,dr24,dr32);
         else misscan82432(d,dh-1-dy,dr8,dr24,dr32);
         end;//case

         end;

      //set
      case dbits of
      32:dr32[dx]:=c32;
      24:begin
         c24.r:=c32.r;
         c24.g:=c32.g;
         c24.b:=c32.b;
         dr24[dx]:=c24;
         end;
      8 :dr8[dx]:=c32__lum(c32);
      end;//case

      //inc
      inc(dx);
      end;
   begin
   //init
   result:=false;
   dx    :=0;
   dy    :=0;
   ylast :=-1;
   spos  :=sstartofdata;
   srle8 :=(scompression=bi_rle8);

   //get
   for sp:=0 to (simagesize-1) do
   begin
   v1:=r1;
   v2:=r1;

   case v1 of
   0:begin

      case v2 of
      0:begin//end of line
         inc(dy);
         dx:=0;
         end;
      1:begin
         result:=true;
         goto skipend;//end of bitmap
         end;
      2:begin//shift RIGHT and UP (2 bytes)
         //.x
         inc(dx,r1);//right
         if (dx>=dw) then dx:=dw-1;
         //.y
         inc(dy,r1);//up
         if (dy>=dh) then dy:=dh-1;
         end;
      3..255:begin//absolute (padded to word boundary, so last item may be ZERO but unused)

         //.8bit
         if srle8 then
            begin
            for p:=1 to v2 do xpush(r1);
            if not low__even(v2) then r1;//read zero pad byte
            end
         //.4bit
         else
            begin
            acount:=0;
            vcount:=0;
            bol1  :=true;

            for p:=1 to v2 do//number of pixels -> 2 pixels per byte -> still a 2-byte (word) boundary
            begin
            //.read byte
            if (acount<=0) then
               begin
               v     :=r1;
               acount:=2;//read two pixels from one byte
               inc(vcount);
               end;
            dec(acount);

            //.read pixel
            xpush( xreadpixel4(v,bol1) );
            end;//p

            if not low__even(vcount) then r1;//read zero pad byte
            end;

         end;//begin

      end;//case v2
      end;//begin

   1..255:begin//repeat

      //.8bit
      if srle8 then
         begin
         for p:=1 to v1 do xpush(v2);
         end
      //.4bit
      else
         begin
         bol1:=true;
         for p:=1 to v1 do xpush( xreadpixel4(v2,bol1) );
         end;

      end;//begin

   end;//case

   //check
   if (dy>=dh) then break;

   end;//sp

   //successful
   result:=true;
   skipend:
   end;

   procedure p8;
   var
      i:byte;
   begin
   i:=r1;
   if (i>=plimit) then i:=plimit-1;
   c32:=plist[i];
   end;

   procedure p4;
   var
      i:byte;
   begin
   //inc
   inc(px);
   if (px>=3) then px:=1;
   if (px=1)  then pval:=r1;

   //get
   case px of
   1:begin
      i:=pval div 16;
      dec(pval,i*16);
      end;
   2:i:=pval;
   else i:=0;
   end;//case

   //enforce upper limit
   if (i>=plimit) then i:=plimit-1;

   //set
   c32:=plist[i];
   end;

   procedure p1;
   var
      i:byte;

      procedure v(xdiv:byte);
      begin
      i:=pval div xdiv;
      dec(pval,i*xdiv);
      end;
   begin
   //inc
   inc(px);
   if (px>=9) then px:=1;
   if (px=1)  then pval:=r1;

   //get
   case px of
   1:v(128);
   2:v(64);
   3:v(32);
   4:v(16);
   5:v(8);
   6:v(4);
   7:v(2);
   8:i:=pval;
   end;//case

   //enforce upper limit
   if (i>=plimit) then i:=plimit-1;

   //set
   c32:=plist[i];
   end;
begin
//defaults
result       :=false;
s8           :=nil;
simagesize   :=0;
sinfosize    :=0;
scompression:=bi_rgb;
dflip       :=false;

try
//check
if not str__lock(s)                  then goto skipend;
if not misok82432(d,dbits,int1,int2) then goto skipend;

//init
s8        :=str__as8(s);
slen      :=str__len(s);
spos      :=0;
if (slen<12) then goto skipend;

//bmp header
if (r1=uuB) and (r1=uuM) then
   begin
   spos        :=10;
   sstartofdata:=frcmin32(r4,0);

   sinfosize   :=14;
   spos        :=14;//jump to main header
   end
else
   begin
   sstartofdata:=0;
   spos        :=0;
   end;

//info header
//.size4
sheadstyle:=r4;
inc(sinfosize,sheadstyle);

//.check header type
case sheadstyle of
hsOS2:;
hsW95:;
hsV04:;
hsV05:;
else goto skipend;//unsupported header size (type)
end;//case

//.0S/2 and Win3.1 header (12b)
if (sheadstyle=hsOS2) then
   begin
   //.width2
   dw:=r2;
   if (dw<=0) then goto skipend;

   //.height2
   dh:=r2;
   if (dh<=0) then goto skipend;

   //.planes2
   if (r2<>1) then goto skipend;

   //.bits2
   sbits:=r2;

   case sbits of
   1,4,8:;//OK
   else  goto skipend;
   end;

   //.pcount
   case sbits of
   1:plimit:=2;
   4:plimit:=16;
   8:plimit:=256;
   end;//case

   pcount    :=plimit;
   pcolsize  :=3;//bgr = 3 bytes

   end
else
   begin
   //common fields to all 3 remaining headers

   //.width4
   dw:=r4;
   if (dw<=0) then goto skipend;

   //.height4 - 08jun2025
   int1  :=r4;
   dflip :=(int1<0);
   dh    :=low__posn(int1);

   if (dh<=0) then goto skipend;

   //.planes2
   if (r2<>1) then goto skipend;

   //.bits2
   sbits:=r2;

   case sbits of
   1,4,8:;//OK
   else  goto skipend;
   end;

   //.compression4
   scompression:=r4;
   case scompression of
   bi_rgb       :;//ok for all bit depths
   bi_rle4      :if (sbits<>4) then goto skipend;
   bi_rle8      :if (sbits<>8) then goto skipend;
   else                             goto skipend;
   end;//case

   //.image size - required when compression type is JPEG or PNG or packed data such as rle4/8
   simagesize:=r4;

   //.biXPelsPerMeter4
   r4;

   //.biYPelsPerMeter4
   r4;

   //.biClrUsed4 -> 0=full size e.g. 256
   case sbits of
   8   :plimit:=256;
   4   :plimit:=16;
   1   :plimit:=2;
   else plimit:=256;
   end;//case

   pcount:=frcrange32(r4,0,plimit);
   if (pcount<=0) then pcount:=plimit;

   pcolsize:=4;//rgb = 4 bytes
   end;

//.jump to start of palette
spos:=sinfosize;

//.palette
low__cls(@plist,sizeof(plist));

for p:=0 to (pcount-1) do
begin
plist[p].b:=r1;
plist[p].g:=r1;
plist[p].r:=r1;
if (pcolsize=4) then plist[p].a:=r1;//just read it, don't use it
plist[p].a:=255;//force as solid
end;//p

//init
srowsize  :=mis__rowsize4(dw,sbits);

//size
if not missize(d,dw,dh) then goto skipend;

//cls
mis__cls(d,0,0,0,0);//black and transparent (if 32bit canvas)

//start of data
sstartofdata:=largest32(sstartofdata, sinfosize + (pcount*pcolsize) );

//RLE-8 and RLE-4
case scompression of
bi_rle4,bi_rle8:begin
   result:=xread_rle48;
   goto skipend;
   end;
end;

//get
for dy:=0 to (dh-1) do
begin

case dflip of
true:if not misscan82432(d,dy,dr8,dr24,dr32)      then goto skipend;
else if not misscan82432(d,dh-1-dy,dr8,dr24,dr32) then goto skipend;
end;//case

spos:=sstartofdata + (dy*srowsize);
px  :=0;

//.8 -> 32
if (sbits=8) and (dbits=32) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p8;
   dr32[dx]:=c32;
   end;//dx
   end
//.8 -> 24
else if (sbits=8) and (dbits=24) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p8;
   c24.r:=c32.r;
   c24.g:=c32.g;
   c24.b:=c32.b;
   dr24[dx]:=c24;
   end;//dx
   end
//.8 -> 8
else if (sbits=8) and (dbits=8) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p8;
   dr8[dx]:=c32__lum(c32);
   end;//dx
   end
//.4 -> 32
else if (sbits=4) and (dbits=32) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p4;
   dr32[dx]:=c32;
   end;//dx
   end
//.4 -> 24
else if (sbits=4) and (dbits=24) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p4;
   c24.r:=c32.r;
   c24.g:=c32.g;
   c24.b:=c32.b;
   dr24[dx]:=c24;
   end;//dx
   end
//.4 -> 8
else if (sbits=4) and (dbits=8) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p4;
   dr8[dx]:=c32__lum(c32);
   end;//dx
   end
//.1 -> 32
else if (sbits=1) and (dbits=32) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p1;
   dr32[dx]:=c32;
   end;//dx
   end
//.1 -> 24
else if (sbits=1) and (dbits=24) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p1;
   c24.r:=c32.r;
   c24.g:=c32.g;
   c24.b:=c32.b;
   dr24[dx]:=c24;
   end;//dx
   end
//.1 -> 8
else if (sbits=1) and (dbits=8) then
   begin
   for dx:=0 to (dw-1) do
   begin
   p1;
   dr8[dx]:=c32__lum(c32);
   end;//dx
   end;

end;//dy

//successful
result:=true;
skipend:
except;end;
//clear on error
if not result then missize(d,1,1);
//free
str__uaf(s);
end;

function bmp4__fromdata(d:tobject;s:pobject):boolean;//15may2025
begin
result:=bmp8__fromdata(d,s);
end;

function bmp1__fromdata(d:tobject;s:pobject):boolean;//15may2025
begin
result:=bmp8__fromdata(d,s);
end;


//dib procs --------------------------------------------------------------------
function dib__fromdata(s:tobject;d:pobject;var e:string):boolean;
var
   xbpp:longint;
begin
result:=dib__fromdata2(s,d,xbpp,e);
end;

function dib__fromdata2(s:tobject;d:pobject;var xoutbpp:longint;var e:string):boolean;
begin
result:=bmp__fromdata2(s,d,xoutbpp,e);
end;

function dib32__fromdata(d:tobject;s:pobject):boolean;//15may2025
begin
result:=bmp32__fromdata(d,s);
end;

function dib24__fromdata(d:tobject;s:pobject):boolean;//15may2025
begin
result:=bmp24__fromdata(d,s);
end;

function dib16__fromdata(d:tobject;s:pobject):boolean;//15may2025
begin
result:=bmp16__fromdata(d,s);
end;

function dib8__fromdata(d:tobject;s:pobject):boolean;//28may2025
begin
result:=bmp8__fromdata(d,s);
end;

function dib4__fromdata(d:tobject;s:pobject):boolean;//28may2025
begin
result:=bmp4__fromdata(d,s);
end;

function dib1__fromdata(d:tobject;s:pobject):boolean;//28may2025
begin
result:=bmp1__fromdata(d,s);
end;


//tga procs --------------------------------------------------------------------

function tga__fromdata(s:tobject;d:pobject;var e:string):boolean;
label
   skipend;
const
   ssColorImage   =2;
   ssGreyImage    =3;
   ssColorImageRLE=10;
   ssGreyImageRLE =11;
var
   stype,dpos,dbits,sbits,sw,sh,sx,sy,ssy:longint;
   s32:tcolor32;
   s24:tcolor24;
   s8:tcolor8;
   sr32:pcolorrow32;
   sr24:pcolorrow24;
   sr8 :pcolorrow8;
   xrle,dtopleft:boolean;
   xcolmapBytes,idlen,v,vc:longint;
   b:tbyt1;

   procedure d32;
   begin
   s32:=str__c32(d,dpos);
   inc(dpos,4);

   s24.r:=s32.r;
   s24.g:=s32.g;
   s24.b:=s32.b;

   s8:=s32.r;
   if (s32.g>s8) then s8:=s32.g;
   if (s32.b>s8) then s8:=s32.b;
   end;

   procedure d24;
   begin
   s24:=str__c24(d,dpos);
   inc(dpos,3);

   s32.r:=s24.r;
   s32.g:=s24.g;
   s32.b:=s24.b;
   s32.a:=255;

   s8:=s32.r;
   if (s32.g>s8) then s8:=s32.g;
   if (s32.b>s8) then s8:=s32.b;
   end;

   procedure d8;
   begin
   s8:=str__c8(d,dpos);
   inc(dpos,1);

   s32.r:=s8;
   s32.g:=s8;
   s32.b:=s8;
   s32.a:=255;

   s24.r:=s8;
   s24.g:=s8;
   s24.b:=s8;
   end;

   function dv:boolean;
   begin
   v:=str__bytes0(d,dpos);
   inc(dpos);

   if (v>=128) then
      begin
      result:=true;
      vc:=(v-127);
      end
   else
      begin
      result:=false;
      vc:=-(v+1);
      end;
   end;
begin
//defaults
result:=false;
e:=gecTaskfailed;

try
//check
if not str__lock(d) then goto skipend;
if not misok82432(s,sbits,sw,sh) then goto skipend;

//header - 18b
if (str__len(d)<18) then
   begin
   e:=gecUnknownformat;
   goto skipend;
   end;

//.ident field
idlen:=str__bytes0(d,0);

//.d[1]: 0=no map included, 1=color map included -> not used for an "unmapped image"
//.color map size in bytes -> need to calc so we can skip over it
xcolmapBytes:=frcrange32(str__bytes0(d,1),0,1) * str__wrd2(d,5) * (str__bytes0(d,7) div 8);

//.type -> 2 = uncompressed RGB image, 3=uncompressed greyscale image
stype:=str__bytes0(d,2);
xrle:=(stype=ssGreyImageRLE) or (stype=ssColorImageRLE);

//.width + height
sw:=str__wrd2(d,12);
sh:=str__wrd2(d,14);
if (sw<1) or (sh<1) then
   begin
   e:=gecUnsupportedFormat;
   goto skipend;
   end;

//.bpp - 8, 24 or 32
dbits:=str__bytes0(d,16);

if ( ((stype=ssGreyImage) or (stype=ssGreyImageRLE)) and (dbits=8) )  or  ( ((stype=ssColorImage) or (stype=ssColorImageRLE)) and ((dbits=24) or (dbits=32)) ) then
   begin
   //ok
   end
else
   begin
   e:=gecUnsupportedFormat;
   goto skipend;
   end;

//.up or down
b.val:=str__bytes0(d,17);
dtopleft:=(5 in b.bits);//bit 5

//size s
if not missize(s,sw,sh) then goto skipend;

//pixels
dpos:=18+idlen+xcolmapBytes;

for ssy:=0 to (sh-1) do
begin
if dtopleft then sy:=ssy else sy:=sh-1-ssy;
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;
if xrle then vc:=0 else vc:=-sw;

//.32 -> 32
if (dbits=32) and (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d32;

   if (vc<0) then
      begin
      d32;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr32[sx]:=s32;
   end;
   end
//.32 -> 24
else if (dbits=32) and (sbits=24) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d32;

   if (vc<0) then
      begin
      d32;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr24[sx]:=s24;
   end;
   end
//.32 -> 8
else if (dbits=32) and (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d32;

   if (vc<0) then
      begin
      d32;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr8[sx]:=s8;
   end;
   end
//.24 -> 32
else if (dbits=24) and (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d24;

   if (vc<0) then
      begin
      d24;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr32[sx]:=s32;
   end;
   end
//.24 -> 24
else if (dbits=24) and (sbits=24) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d24;

   if (vc<0) then
      begin
      d24;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr24[sx]:=s24;
   end;
   end
//.24 -> 8
else if (dbits=24) and (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d24;

   if (vc<0) then
      begin
      d24;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr8[sx]:=s8;
   end;
   end
//.8 -> 32
else if (dbits=8) and (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d8;

   if (vc<0) then
      begin
      d8;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr32[sx]:=s32;
   end;
   end
//.8 -> 24
else if (dbits=8) and (sbits=24) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d8;

   if (vc<0) then
      begin
      d8;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr24[sx]:=s24;
   end;
   end
//.8 -> 8
else if (dbits=8) and (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   if xrle and (vc=0) and dv then d8;

   if (vc<0) then
      begin
      d8;
      inc(vc);
      end
   else if (vc>=1) then dec(vc);

   sr8[sx]:=s8;
   end;
   end;
end;//sy

//ai information
misai(s).count:=1;
misai(s).cellwidth:=misw(s);
misai(s).cellheight:=mish(s);
misai(s).delay:=0;
misai(s).transparent:=false;//alpha channel is used instead (if supplied image was 32bit)
misai(s).bpp:=dbits;

//successful
result:=true;

skipend:
except;end;
try;str__uaf(d);except;end;
end;


{$endif}

end.
