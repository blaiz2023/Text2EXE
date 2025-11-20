unit limg;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses {$ifdef gui4}windows, graphics,{$endif} lwin, lwin2, lroot;
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
//## Library.................. image/graphics (modernised legacy codebase)
//## Version.................. 1.00.460 (+1)
//## Items.................... 6
//## Last Updated ............ 05oct2025
//## Lines of Code............ 3,600+
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
//## | tbasicimage            | tobject           | 1.00.187   | 07dec2023   | Lightweight + fast system independent image, not resizable, supports 8/24/32 bit pixel depth - 09may2022, 27jul2021, 25jan2021, ??jan2020: created
//## | twinbmp                | tobject           | 1.00.160   | 04sep2025   | Replacement for tbitmap - 27aug2025: GDI handling upgrades, 27aug2025, 01may2025, 26apr2025
//## | trawimage              | tobject           | 1.00.070   | 26apr2025   | Independent resizeable image -> persistent pixel rows and supports 8/24/32 bit color depth - 27dec2024, 25jul2024: created
//## | c8__/c24__/c32__/int__ | family of procs   | 1.00.010   | 05oct2025   | Graphic color conversion procs - subset of Gossamer procs
//## | mis*/mis__*            | family of procs   | 1.00.030   | 05oct2025   | Graphic procs for working with multiple different image objects - subset of Gossamer procs
//## | mask__*                | family of procs   | 1.00.002   | 05oct2025   | Mask related procs for working with alpha channel on 32bit images or 8bit images - subset of Gossamer procs
//## ==========================================================================================================================================================================================================================


type

{tanimationinformation}
   //.bitmap animation helper record
   panimationinformation=^tanimationinformation;
   tanimationinformation=record
    format:string;//uppercase EXT (e.g. JPG, BMP, SAN etc)
    subformat:string;//same style as format, used for dual format streams "ATEP: 1)animation header + 2)image"
    info:string;//UNICODE WARNING --- optional custom information data block packed at end of image data - 22APR2012
    filename:string;
    map16:string;//UNICODE WARNING --- 26MAY2009 - used in "CAN or Compact Animation" to map all original cells to compacted imagestrip
    transparent:boolean;
    syscolors:boolean;//13apr2021
    flip:boolean;
    mirror:boolean;
    delay:longint;
    itemindex:longint;
    count:longint;//0..X (0=1cell, 1=2cells, etc)
    bpp:byte;
    binary:boolean;
    //cursor - 20JAN2012
    hotspotX:longint;//-1=not set=default
    hotspotY:longint;//-1=not set=default
    hotspotMANUAL:boolean;//use this hotspot instead of automatic hotspot - 03jan2019
    //32bit capable formats
    owrite32bpp:boolean;//default=false, for write modes within "ccs.todata()" where 32bit is used as the default save BPP - 22JAN2012
    //final
    readB64:boolean;//true=image was b64 encoded
    readB128:boolean;//true=image was b128 encoded
    writeB64:boolean;//true=encode image using b64
    writeB128:boolean;//true=encode image using b128 - 09feb2015
    //internal
    iosplit:longint;//position in IO stream that animation sep. (#0 or "#" occurs)
    cellwidth:longint;
    cellheight:longint;
    use32:boolean;
    end;

{tbasicimage}
   tbasicimage=class(tobject)
   private
    idata,irows:tstr8;
    ibits,iwidth,iheight:longint;
    iprows8 :pcolorrows8;
    iprows16:pcolorrows16;
    iprows24:pcolorrows24;
    iprows32:pcolorrows32;
    istable:boolean;
    procedure setareadata(sa:twinrect;sdata:tstr8);
    function getareadata(sa:twinrect):tstr8;
    function getareadata2(sa:twinrect):tstr8;
   public
    //animation support
    ai:tanimationinformation;
    dtransparent:boolean;
    omovie:boolean;//default=false, true=fromdata will create the "movie" if not already created
    oaddress:string;//used for "AAS" to load from a specific folder - 30NOV2010
    ocleanmask32bpp:boolean;//default=false, true=reads only the upper levels of the 8bit mask of a 32bit icon/cursor to eliminate poor mask quality - ccs.fromicon32() etc - 26JAN2012
    rhavemovie:boolean;//default=false, true=object has a movie as it's animation
    //create
    constructor create; virtual;
    destructor destroy; override;
    function copyfrom(s:tbasicimage):boolean;//09may2022, 09feb2022
    //information
    property stable:boolean read istable;
    property bits:longint read ibits;
    property width:longint read iwidth;
    property height:longint read iheight;
    property prows8 :pcolorrows8  read iprows8;
    property prows16:pcolorrows16 read iprows16;
    property prows24:pcolorrows24 read iprows24;
    property prows32:pcolorrows32 read iprows32;
    property rows:tstr8 read irows;
    //workers
    function sizeto(dw,dh:longint):boolean;
    function setparams(dbits,dw,dh:longint):boolean;
    function findscanline(slayer,sy:longint):pointer;
    //io
    function todata:tstr8;//19feb2022
    function fromdata(s:tstr8):boolean;//19feb2022
    //core
    property data:tstr8 read idata;
    //.raw data handlers
    function setraw(dbits,dw,dh:longint;ddata:tstr8):boolean;
    function getarea(ddata:tstr8;da:twinrect):boolean;//07dec2023
    function getarea_fast(ddata:tstr8;da:twinrect):boolean;//07dec2023 - uses a statically sized buffer (sizes it to correct length if required) so repeat usage is faster
    function setarea(ddata:tstr8;da:twinrect):boolean;//07dec2023
    property areadata[sa:twinrect]:tstr8 read getareadata write setareadata;
    property areadata_fast[sa:twinrect]:tstr8 read getareadata2 write setareadata;
   end;

{trawimage}
   trawimage=class(tobject)
   private
    icore:tdynamicstr8;
    irows:tstr8;
    ifallback:tstr8;
    ibits,iwidth,iheight:longint;
    irows8 :pcolorrows8;
    irows15:pcolorrows16;
    irows16:pcolorrows16;
    irows24:pcolorrows24;
    irows32:pcolorrows32;
    procedure setbits(x:longint);
    procedure setwidth(x:longint);
    procedure setheight(x:longint);
    function getscanline(sy:longint):pointer;
    procedure xsync;
   public
    //animation support
    ai:tanimationinformation;
    dtransparent:boolean;
    omovie:boolean;//default=false, true=fromdata will create the "movie" if not already created
    oaddress:string;//used for "AAS" to load from a specific folder - 30NOV2010
    ocleanmask32bpp:boolean;//default=false, true=reads only the upper levels of the 8bit mask of a 32bit icon/cursor to eliminate poor mask quality - ccs.fromicon32() etc - 26JAN2012
    rhavemovie:boolean;//default=false, true=object has a movie as it's animation
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property core:tdynamicstr8 read icore;
    function setparams(dbits,dw,dh:longint):boolean;
    function setparams2(dbits,dw,dh:longint;dforce:boolean):boolean;//27dec2024
    property bits:longint   read ibits   write setbits;
    property width:longint  read iwidth  write setwidth;
    property height:longint read iheight write setheight;
    property rows   :tstr8  read irows;//12dec2024
    property prows8 :pcolorrows8  read irows8;
    property prows15:pcolorrows16 read irows15;
    property prows16:pcolorrows16 read irows16;
    property prows24:pcolorrows24 read irows24;
    property prows32:pcolorrows32 read irows32;
    property scanline[sy:longint]:pointer read getscanline;
    function rowinfo(sy:longint):string;
   end;

{twinbmp}
//xxxxxxxxxxxxxxxxxxxxxxxxxxx//bbbbbbbbbbbbbbbbbbbbbbb
   twinbmp=class(tobject)
   private

    iinfo       :TBitmapInfoHeader;
    ifont       :HFONT;
    ibrush      :HBRUSH;
    ifontOLD    :HGDIOBJ;
    ibrushOLD   :HGDIOBJ;
    ihbitmapOLD :HBITMAP;
    ihbitmap    :HBITMAP;
    icore       :pointer;
    idc         :hdc;

    irows:tstr8;
    ibits,iwidth,iheight,irowsize:longint;

    irows8 :pcolorrows8;
    irows15:pcolorrows16;
    irows16:pcolorrows16;
    irows24:pcolorrows24;
    irows32:pcolorrows32;

    procedure setwidth(x:longint);
    procedure setheight(x:longint);
    procedure setbits(x:longint);
    function xcreate(xnew:boolean):boolean;

   public

    //animation support
    ai:tanimationinformation;

    //create
    constructor create; virtual;
    destructor destroy; override;

    //information
    property dc           :hdc           read idc;
    property handle       :hbitmap       read ihbitmap;
    property bits         :longint       read ibits write setbits;
    property width        :longint       read iwidth write setwidth;
    property height       :longint       read iheight write setheight;
    property rowsize      :longint       read irowsize;
    function bytes        :comp;
    property font         :hfont         read ifont;
    property brush        :hbrush        read ibrush;

    //setparams
    function setparams(dbits,dw,dh:longint):boolean;
    function setparams2(dbits,dw,dh:longint;dforce:boolean):boolean;

    //scanline
    property rows         :tstr8         read irows;
    property prows8       :pcolorrows8   read irows8;
    property prows15      :pcolorrows16  read irows15;
    property prows16      :pcolorrows16  read irows16;
    property prows24      :pcolorrows24  read irows24;
    property prows32      :pcolorrows32  read irows32;
    function getscanline(sy:longint):pointer;

    //workers
    function copyarea(sa:twinrect;s:hdc):boolean;
    function copyarea2(da,sa:twinrect;s:hdc):boolean;

    //support
    function setfont(xfontname:string;xsharp,xbold:boolean;xsize,xcolor,xbackcolor:longint):boolean;
    function setfont2(xfontname:string;xsharp,xbold,xtransparent:boolean;xsize,xcolor,xbackcolor:longint):boolean;//10oct2025
{$ifdef gui3}
    function fontheight:longint;
{$endif}
   end;


var

   limg_started          :boolean=false;

   //.ref arrays
   ref65025_div_255      :array[0..65025] of byte;//06apr2017

   //.filter arrays
   fb255                 :array[-1024..1024] of byte;
   fbwrap255             :array[-1024..1024] of byte;

   //.temp buffer support
   systmpstyle           :array[0..99] of byte;//0=free, 1=available, 2=locked
   systmpid              :array[0..99] of string;
   systmptime            :array[0..99] of comp;
   systmpbmp             :array[0..99] of tbasicimage;//23may2020
   systmppos             :longint;
   //.temp int buffer support
   sysintstyle           :array[0..99] of byte;//0=free, 1=available, 2=locked
   sysintid              :array[0..99] of string;
   sysinttime            :array[0..99] of comp;
   sysintobj             :array[0..99] of tdynamicinteger;
   sysintpos             :longint;
   //.temp byte buffer support
   sysbytestyle          :array[0..99] of byte;//0=free, 1=available, 2=locked
   sysbyteid             :array[0..99] of string;
   sysbytetime           :array[0..99] of comp;
   sysbyteobj            :array[0..99] of tdynamicbyte;
   sysbytepos            :longint;

   //.mis support
   system_default_ai     :tanimationinformation;//29may2019
   system_screenlogpixels:longint=96;


//color procs ------------------------------------------------------------------

function c32__lum(x:tcolor32):byte;
procedure c24__greyscale(var x:tcolor24);
procedure c24__GuiDisableGrey(var x:tcolor24);//sourced from ttoolbars from Text2EXE 2007
function c24__int(x:tcolor24):longint;//16sep2025
function c32__int(x:tcolor32):longint;//16sep2025
function c32__c8(x:tcolor32):tcolor8;
function c24__c8(x:tcolor24):tcolor8;
function c32__c24(x:tcolor32):tcolor24;
function rgba__int(r,g,b,a:byte):longint;
function int__splice24(xpert01:extended;s,d:longint):longint;//16sep2025, 13nov2022
function int__c8(x:longint):tcolor8;//16sep2025
function int__c24(x:longint):tcolor24;//16sep2025
function int__c32(x:longint):tcolor32;//19oct2025
function inta__c32(x:longint;a:byte):tcolor32;
function rgba0__int(r,g,b:byte):longint;
function int24__rgba0(x24__or__syscolor:longint):longint;


//image procs ------------------------------------------------------------------

function misimg(dbits,dw,dh:longint):tbasicimage;
function misimg8(dw,dh:longint):tbasicimage;//26jan2021
function misimg24(dw,dh:longint):tbasicimage;
function misimg32(dw,dh:longint):tbasicimage;
function misraw(dbits,dw,dh:longint):trawimage;
function misraw8(dw,dh:longint):trawimage;//26jan2021
function misraw24(dw,dh:longint):trawimage;
function misraw32(dw,dh:longint):trawimage;
function miswin(dbits,dw,dh:longint):twinbmp;
function miswin8(dw,dh:longint):twinbmp;
function miswin24(dw,dh:longint):twinbmp;
function miswin32(dw,dh:longint):twinbmp;
function misatleast(s:tobject;dw,dh:longint):boolean;//26jul2021

function misv(s:tobject):boolean;//valid
function misb(s:tobject):longint;//bits 0..N
procedure missetb(s:tobject;sbits:longint);
function missetb2(s:tobject;sbits:longint):boolean;//12feb2022
function misw(s:tobject):longint;
function mish(s:tobject):longint;

function misaiclear2(s:tobject):boolean;
function misaiclear(var x:tanimationinformation):boolean;
function misai(s:tobject):panimationinformation;
function low__aicopy(var s,d:tanimationinformation):boolean;
function misaicopy(s,d:tobject):boolean;
function mishasai(s:tobject):boolean;
function mis__canarea(s:tobject;sa:twinrect;var sarea:twinrect):boolean;

function mis__hasai(s:tobject):boolean;
function mis__ai(s:tobject):panimationinformation;
function missize(s:tobject;dw,dh:longint):boolean;
function missize2(s:tobject;dw,dh:longint;xoverridelock:boolean):boolean;
procedure mis__calccells2(s:tobject;var xdelay,xcount,xcellwidth,xcellheight:longint);
function mis__onecell(s:tobject):boolean;//06aug2024, 26apr2022
function mis__resizable(s:tobject):boolean;
function mis__retaindataonresize(s:tobject):boolean;//26jul2024: same as "mis__resizable()"
function mis__rowsize4(ximagewidth,xbitsPERpixel:longint):longint;//rounds to nearest 4 bytes - 27may2025

{$ifdef gui3}
function mis__reducecolors256(s:tobject;xMaxColorCount:longint):boolean;//17sep2025
function misokk82432(s:tobject):boolean;
function misscan832(s:tobject;sy:longint;var sr8:pcolorrow8;var sr32:pcolorrow32):boolean;//14feb2022
function mis__countcolors257(s:tobject):longint;//limited color counter -> counts up to 257 colors - 14may2025
function miscls(s:tobject;xcolor:longint):boolean;
function misclsarea(s:tobject;sarea:twinrect;xcolor:longint):boolean;
{$endif}

function misclsarea3(s:tobject;sarea:twinrect;xcolor,xcolor2,xalpha,xalpha2:longint):boolean;
function mis__cls(s:tobject;r,g,b,a:byte):boolean;//04aug2024
function mis__cls3(s:tobject;sa:twinrect;scolor32:tcolor32):boolean;//29jan2025
function mis__cls2(s:tobject;sa:twinrect;r,g,b,a:byte):boolean;//04aug2024

function misarea(s:tobject):twinrect;
function miscopyarea32(ddx,ddy,ddw,ddh:currency;sa:twinrect;d,s:tobject):boolean;//can copy ALL 32bits of color
function miscopyarea321(da,sa:twinrect;d,s:tobject):boolean;//can copy ALL 32bits of color
function miscopyarea322(da_clip:twinrect;ddx,ddy,ddw,ddh:currency;sa:twinrect;d,s:tobject;xscroll,yscroll:longint):boolean;//can copy ALL 32bits of color
function miscopyarea323(da_clip:twinrect;ddx,ddy,ddw,ddh:currency;sa:twinrect;d,s:tobject;xscroll,yscroll:longint;xmix32:boolean):boolean;//18nov2024: xmix32 mixes alpha colors into a lesser bit depth image e.g. drawing a 32 bit image onto a 24 bit one, can copy ALL 32bits of color
function miscopyarea324(da_clip:twinrect;ddx,ddy,ddw,ddh:currency;sa:twinrect;d,s:tobject;xscroll,yscroll,xAlphaPower255:longint;xmix32:boolean):boolean;//18nov2024: xmix32 mixes alpha colors into a lesser bit depth image e.g. drawing a 32 bit image onto a 24 bit one, can copy ALL 32bits of color - 09oct2025

function misinfo(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misinfo2432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misinfo82432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misinfo8162432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misinfo824(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;

function misokex(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
function misok824(s:tobject;var sbits,sw,sh:longint):boolean;
function misok82432(s:tobject;var sbits,sw,sh:longint):boolean;
function misok2432(s:tobject;var sbits,sw,sh:longint):boolean;//01may2025

function misscan2432(s:tobject;sy:longint;var sr24:pcolorrow24;var sr32:pcolorrow32):boolean;//26jan2021
function misscan82432(s:tobject;sy:longint;var sr8:pcolorrow8;var sr24:pcolorrow24;var sr32:pcolorrow32):boolean;//26jan2021
function misscan24(s:tobject;sy:longint;var sr24:pcolorrow24):boolean;//26jan2021
function misscan32(s:tobject;sy:longint;var sr32:pcolorrow32):boolean;//26jan2021


//mask procs -------------------------------------------------------------------

{$ifdef gui3}
function mask__empty(s:tobject):boolean;
function mask__setval(s:tobject;xval:longint):boolean;
function mask__range(s:tobject;var xmin,xmax:longint):boolean;//15feb2022
function mask__range2(s:tobject;var v0,v255,vother:boolean;var xmin,xmax:longint):boolean;//15feb2022
function mask__hasTransparency32(s:tobject):boolean;//one or more alpha values are below 255 - 27may2025
function mask__hasTransparency322(s:tobject;var xsimple0255:boolean):boolean;//one or more alpha values are below 255 - 27may2025
{$endif}

//temp procs -------------------------------------------------------------------
//note: rapid reuse of temporary objects for caching tasks, like for intensive graphics scaling work etc
function low__createimg24(var x:tbasicimage;xid:string;var xwascached:boolean):boolean;
procedure low__freeimg(var x:tbasicimage);
procedure low__checkimg;
function low__createint(var x:tdynamicinteger;xid:string;var xwascached:boolean):boolean;
procedure low__freeint(var x:tdynamicinteger);
procedure low__checkint;
function low__createbyte(var x:tdynamicbyte;xid:string;var xwascached:boolean):boolean;
procedure low__freebyte(var x:tdynamicbyte);
procedure low__checkbyte;


//canvas procs -----------------------------------------------------------------

{$ifdef gui3}
function wincanvas__textwidth(x:hdc;const xval:string):longint;
function wincanvas__textheight(x:hdc;const xval:string):longint;
function wincanvas__textout(x:hdc;xtransparent:boolean;dx,dy:longint;const xval:string):boolean;
function wincanvas__textextent(x:hdc;const xval:string):tpoint;
function wincanvas__textrect(x:hdc;xtransparent:boolean;xarea:twinrect;dx,dy:longint;const xval:string):boolean;
{$endif}


//start-stop procs -------------------------------------------------------------
procedure limg__start;
procedure limg__stop;


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
function info__limg(xname:string):string;//information specific to this unit of code


implementation


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__limg(xname:string):string;//information specific to this unit of code

   function m(const x:string):boolean;
   begin
   result:=strmatch( x, strcopy1(xname,1,low__len(x)) );
   if result then strdel1(xname,1,low__len(x));
   end;

begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//check -> xname must match unit name
if not m('limg.') then exit;

//get
if      (xname='ver')        then result:='1.00.460'
else if (xname='date')       then result:='05oct2025'
else if (xname='name')       then result:='Graphics'
else
   begin
   //nil
   end;

except;end;
end;


//start-stop procs -------------------------------------------------------------
procedure limg__start;
var
   v,p:longint;
   d:hdc;
begin
try

//check
if limg_started then exit else limg_started:=true;


//ref arrays -------------------------------------------------------------------
//.ref65025_div_255 - 06apr2017
for p:=0 to high(ref65025_div_255) do ref65025_div_255[p]:=p div 255;


//filter arrays ----------------------------------------------------------------
//.fb255
for p:=low(fb255) to high(fb255) do
begin
v:=p;
if (v<0) then v:=0 else if (v>255) then v:=255;
fb255[p]:=byte(v);
end;//p

//.fbwrap255
for p:=low(fbwrap255) to high(fbwrap255) do
begin
v:=p;
 repeat
 if (v>255) then dec(v,255)
 else if (v<0) then inc(v,255)
 until (v>=0) and (v<=255);
fbwrap255[p]:=byte(v);
end;//p


//temp support -----------------------------------------------------------------
//.temp buffer support
systmppos:=0;
for p:=0 to high(systmpstyle) do
begin
systmpstyle[p]:=0;//free
systmpid[p]:='';
systmptime[p]:=0;
systmpbmp[p]:=nil;
end;//p

//.temp int buffer support
sysintpos:=0;
for p:=0 to high(sysintstyle) do
begin
sysintstyle[p]:=0;//free
sysintid[p]:='';
sysinttime[p]:=0;
sysintobj[p]:=nil;
end;//p

//.temp byte buffer support
sysbytepos:=0;
for p:=0 to high(sysbytestyle) do
begin
sysbytestyle[p]:=0;//free
sysbyteid[p]:='';
sysbytetime[p]:=0;
sysbyteobj[p]:=nil;
end;//p

d:=0;
try
d:=win____GetDC(0);
if (d<>0) then
   begin
   system_screenlogpixels:=win____GetDeviceCaps(d,LOGPIXELSY);
   if (system_screenlogpixels<=0) then system_screenlogpixels:=96;
   end;
finally
win____ReleaseDC(0,d);
end;

except;end;
end;

procedure limg__stop;
var
   p:longint;
begin
try

//check
if not limg_started then exit else limg_started:=false;


//temp support -----------------------------------------------------------------
//.temp buffer support
for p:=0 to high(systmpstyle) do
begin
systmpstyle[p]:=2;//locked
freeobj(@systmpbmp[p]);
end;//p
//.temp int support
for p:=0 to high(sysintstyle) do
begin
sysintstyle[p]:=2;//locked
freeobj(@sysintobj[p]);
end;//p
//.temp byte support
for p:=0 to high(sysbytestyle) do
begin
sysbytestyle[p]:=2;//locked
freeobj(@sysbyteobj[p]);
end;//p

except;end;
end;


//color procs ------------------------------------------------------------------

function c32__lum(x:tcolor32):byte;
begin
result:=x.r;
if (x.g>result) then result:=x.g;
if (x.b>result) then result:=x.b;
end;

procedure c24__greyscale(var x:tcolor24);
begin
if (x.g>x.r) then x.r:=x.g;
if (x.b>x.r) then x.r:=x.b;
x.g:=x.r;
x.b:=x.r;
end;

procedure c24__GuiDisableGrey(var x:tcolor24);//sourced from ttoolbars from Text2EXE 2007
begin

//get
x.r:=byte( (x.r+x.g+x.b) div 3 );

//adjust "black/white"
if      (x.r=0)   then x.r:=50
else if (x.r=255) then x.r:=240;

//set
x.g:=x.r;
x.b:=x.r;

end;

function c24__int(x:tcolor24):longint;//16sep2025
begin
tint4(result).r:=x.r;
tint4(result).g:=x.g;
tint4(result).b:=x.b;
tint4(result).a:=0;//*
end;

function c32__int(x:tcolor32):longint;//16sep2025
begin
tint4(result).r:=x.r;
tint4(result).g:=x.g;
tint4(result).b:=x.b;
tint4(result).a:=x.a;
end;

function c32__c8(x:tcolor32):tcolor8;
begin
result:=x.r;
if (x.g>result) then result:=x.g;
if (x.b>result) then result:=x.b;
end;

function c24__c8(x:tcolor24):tcolor8;
begin
result:=x.r;
if (x.g>result) then result:=x.g;
if (x.b>result) then result:=x.b;
end;

function c32__c24(x:tcolor32):tcolor24;
begin
result.r:=x.r;
result.g:=x.g;
result.b:=x.b;
end;

function rgba__int(r,g,b,a:byte):longint;
begin
tint4(result).r:=r;
tint4(result).g:=g;
tint4(result).b:=b;
tint4(result).a:=a;
end;

function int__c8(x:longint):tcolor8;//16sep2025
begin
result:=tint4(x).r;
if (tint4(x).g>result) then result:=tint4(x).g;
if (tint4(x).b>result) then result:=tint4(x).b;
end;

function int__splice24(xpert01:extended;s,d:longint):longint;//16sep2025, 13nov2022
var//xpert01 range is 0..1 (0=0% and 0.5=50% and 1=100%)
   p2:extended;
   v:longint;
begin

//init
if (xpert01<0) then xpert01:=0 else if (xpert01>1) then xpert01:=1;
p2:=1-xpert01;

//r
v:=round( (tint4(d).r*xpert01) + (tint4(s).r*p2) );
if (v<0) then v:=0 else if (v>255) then v:=255;
tint4(result).r:=v;

//g
v:=round( (tint4(d).g*xpert01) + (tint4(s).g*p2) );
if (v<0) then v:=0 else if (v>255) then v:=255;
tint4(result).g:=v;

//b
v:=round( (tint4(d).b*xpert01) + (tint4(s).b*p2) );
if (v<0) then v:=0 else if (v>255) then v:=255;
tint4(result).b:=v;

//a
tint4(result).a:=0;//*

end;

function int__c24(x:longint):tcolor24;//16sep2025
begin
result.r:=tint4(x).r;
result.g:=tint4(x).g;
result.b:=tint4(x).b;
end;

function inta__c32(x:longint;a:byte):tcolor32;//16sep2025
begin
result.r:=tint4(x).r;
result.g:=tint4(x).g;
result.b:=tint4(x).b;
result.a:=a;
end;

function int__c32(x:longint):tcolor32;//19oct2025
begin
result.r:=tint4(x).r;
result.g:=tint4(x).g;
result.b:=tint4(x).b;
result.a:=tint4(x).a;
end;

function rgba0__int(r,g,b:byte):longint;
begin
tint4(result).r:=r;
tint4(result).g:=g;
tint4(result).b:=b;
tint4(result).a:=0;
end;

function int24__rgba0(x24__or__syscolor:longint):longint;
begin
if (x24__or__syscolor<0) then result:=win____GetSysColor(x24__or__syscolor and $000000FF) else result:=x24__or__syscolor;
end;


//image procs ------------------------------------------------------------------

function misv(s:tobject):boolean;//valid
begin
result:=(s<>nil) and ( (s is tbasicimage) or (s is trawimage) or (s is twinbmp) );
end;

function misb(s:tobject):longint;//bits 0..N
begin
//defaults
result:=0;

try
//get
if zznil(s,2072) then exit
//.image
else if (s is tbasicimage) then result:=(s as tbasicimage).bits
//.winbmp
else if (s is twinbmp)     then result:=(s as twinbmp).bits
//.rawimage
else if (s is trawimage)   then result:=(s as trawimage).bits;
except;end;
end;

procedure missetb(s:tobject;sbits:longint);
begin
try
sbits:=frcmin32(sbits,1);
if not misv(s) then exit
else if (s is tbasicimage)    then (s as tbasicimage).setparams(sbits,misw(s),mish(s))
else if (s is twinbmp)        then (s as twinbmp).setparams(sbits,misw(s),mish(s))
else if (s is trawimage)      then (s as trawimage).setparams(sbits,misw(s),mish(s));
except;end;
end;

function missetb2(s:tobject;sbits:longint):boolean;//12feb2022
begin
missetb(s,sbits);
result:=(misb(s)<>sbits);
end;

function misw(s:tobject):longint;
begin
if      (s=nil)            then result:=0
else if (s is tbasicimage) then result:=(s as tbasicimage).width
else if (s is twinbmp)     then result:=(s as twinbmp).width
else if (s is trawimage)   then result:=(s as trawimage).width
else                            result:=0;
end;

function mish(s:tobject):longint;
begin
if      (s=nil)            then result:=0
else if (s is tbasicimage) then result:=(s as tbasicimage).height
else if (s is twinbmp)     then result:=(s as twinbmp).height
else if (s is trawimage)   then result:=(s as trawimage).height
else                            result:=0;
end;

function misaiclear2(s:tobject):boolean;
begin
result:=(s<>nil) and misaiclear(misai(s)^);
end;

function misaiclear(var x:tanimationinformation):boolean;
begin
//defaults
result:=false;

try
//get
with x do
begin
binary:=true;
format:='';
subformat:='';
info:='';//22APR2012
filename:='';
map16:='';//Warning: won't work under D10 - 21aug2020
transparent:=false;
syscolors:=false;
flip:=false;
mirror:=false;
delay:=0;
itemindex:=0;
count:=1;
bpp:=24;
//cursor - 20JAN2012
hotspotX:=0;
hotspotY:=0;
hotspotMANUAL:=false;//use system generated AUTOMATIC hotspot - 03jan2019
//special
owrite32bpp:=false;//22JAN2012
//final
readb64:=false;
readb128:=false;
writeb64:=false;
writeb128:=false;
//internal
iosplit:=0;//none
cellwidth:=0;
cellheight:=0;
use32:=false;
end;
//successful
result:=true;
except;end;
end;

function misai(s:tobject):panimationinformation;
begin
result:=mis__ai(s);
end;

function low__aicopy(var s,d:tanimationinformation):boolean;
begin
//defaults
result           :=false;

try
//get
d.format         :=s.format;
d.subformat      :=s.subformat;
d.filename       :=s.filename;
d.map16          :=s.map16;
d.transparent    :=s.transparent;
d.syscolors      :=s.syscolors;//13apr2021
d.flip           :=s.flip;
d.mirror         :=s.mirror;
d.delay          :=s.delay;
d.itemindex      :=s.itemindex;
d.count          :=s.count;
d.bpp            :=s.bpp;
d.owrite32bpp    :=s.owrite32bpp;
d.binary         :=s.binary;
d.readB64        :=s.readB64;
d.readB128       :=s.readB128;
d.readB128       :=s.readB128;
d.writeB64       :=s.writeB64;
d.writeB128      :=s.writeB128;
d.iosplit        :=s.iosplit;
d.cellwidth      :=s.cellwidth;
d.cellheight     :=s.cellheight;
d.use32          :=s.use32;//22may2022
//.special - 10jul2019
d.hotspotMANUAL  :=s.hotspotMANUAL;
d.hotspotX       :=s.hotspotX;
d.hotspotY       :=s.hotspotY;
//successful
result           :=true;
except;end;
end;

function misaicopy(s,d:tobject):boolean;
begin
if mishasai(d) then
   begin
   if mishasai(s) then result:=low__aicopy(misai(s)^,misai(d)^) else result:=misaiclear(misai(d)^);
   end
else result:=false;
end;

function mis__canarea(s:tobject;sa:twinrect;var sarea:twinrect):boolean;
var
   sw,sh:longint;
begin
result:=false;

sarea:=sa;
sw:=misw(s);
sh:=mish(s);

if (sa.right<sa.left) or (sa.bottom<sa.top) or (sa.bottom<0) or (sa.top>=sh) or (sa.right<0) or (sa.left>=sw) then
   begin
   //can't work with area
   end
else
   begin
   //range area to image limits
   sarea.left   :=frcrange32(sa.left  ,0,sw-1);
   sarea.right  :=frcrange32(sa.right ,0,sw-1);
   sarea.top    :=frcrange32(sa.top   ,0,sh-1);
   sarea.bottom :=frcrange32(sa.bottom,0,sh-1);
   result:=true;
   end;
end;

function mis__hasai(s:tobject):boolean;
begin
result:=false;

if zznil(s,2077)           then exit
else if (s is tbasicimage) then result:=true
else if (s is trawimage)   then result:=true
else if (s is twinbmp)     then result:=true;
end;

function mis__ai(s:tobject):panimationinformation;
begin
result:=@system_default_ai;//always return a pointer to a valid structure

if zznil(s,2078)           then misaiclear(system_default_ai)
else if (s is tbasicimage) then result:=@(s as tbasicimage).ai
else if (s is trawimage)   then result:=@(s as trawimage).ai
else if (s is twinbmp)     then result:=@(s as twinbmp).ai
else                            misaiclear(system_default_ai);
end;

function mishasai(s:tobject):boolean;
begin
result:=mis__hasai(s);
end;

function misimg(dbits,dw,dh:longint):tbasicimage;
begin
result:=tbasicimage.create;
if (result<>nil) then result.setparams(dbits,frcmin32(dw,1),frcmin32(dh,1));
end;

function misimg8(dw,dh:longint):tbasicimage;//26jan2021
begin
result:=misimg(8,dw,dh);
end;

function misimg24(dw,dh:longint):tbasicimage;
begin
result:=misimg(24,dw,dh);
end;

function misimg32(dw,dh:longint):tbasicimage;
begin
result:=misimg(32,dw,dh);
end;

function misraw(dbits,dw,dh:longint):trawimage;
begin
result:=trawimage.create;
if (result<>nil) then result.setparams(dbits,frcmin32(dw,1),frcmin32(dh,1));
end;

function misraw8(dw,dh:longint):trawimage;//26jan2021
begin
result:=misraw(8,dw,dh);
end;

function misraw24(dw,dh:longint):trawimage;
begin
result:=misraw(24,dw,dh);
end;

function misraw32(dw,dh:longint):trawimage;
begin
result:=misraw(32,dw,dh);
end;

function miswin(dbits,dw,dh:longint):twinbmp;
begin
result:=twinbmp.create;
if (result<>nil) then result.setparams(dbits,frcmin32(dw,1),frcmin32(dh,1));
end;

function miswin8(dw,dh:longint):twinbmp;
begin
result:=miswin(8,dw,dh);
end;

function miswin24(dw,dh:longint):twinbmp;
begin
result:=miswin(24,dw,dh);
end;

function miswin32(dw,dh:longint):twinbmp;
begin
result:=miswin(32,dw,dh);
end;

function misatleast(s:tobject;dw,dh:longint):boolean;//26jul2021
label
   skipend;
begin
//defaults
result:=false;

try
//check
if zznil(s,101) then exit;
//get
if (dw<=0) or (dh<=0) then
   begin
   result:=true;
   exit;
   end;
if (misw(s)<dw) or (mish(s)<dh) then
   begin
   if not missize(s,dw+100,dh+100) then goto skipend;
   end;
//successful
result:=true;
skipend:
except;end;
end;

function missize(s:tobject;dw,dh:longint):boolean;
begin
result:=missize2(s,dw,dh,false);
end;

function missize2(s:tobject;dw,dh:longint;xoverridelock:boolean):boolean;
label
   skipend;
begin
//defaults
result:=false;

try
//check
if zznil(s,2102) then exit;
//range
dw:=frcmin32(dw,1);
dh:=frcmin32(dh,1);
//.image
if      (s is tbasicimage) then result:=(s as tbasicimage).sizeto(dw,dh)
//.sysimage
else if (s is twinbmp)     then result:=(s as twinbmp).setparams((s as twinbmp).bits,dw,dh)
//.rawimage
else if (s is trawimage)   then result:=(s as trawimage).setparams((s as trawimage).bits,dw,dh);

skipend:
except;end;
end;

procedure mis__calccells2(s:tobject;var xdelay,xcount,xcellwidth,xcellheight:longint);
begin
xdelay      :=frcmin32(misai(s).delay,0);//ms
xcount      :=frcmin32(misai(s).count,1);
xcellwidth  :=frcmin32(misw(s) div xcount,1);
xcellheight :=mish(s);
end;

function mis__onecell(s:tobject):boolean;//06aug2024, 26apr2022
label
   skipend;
var
   a:tbasicimage;
   xdelay,xcount,xcellwidth,xcellheight:longint;
begin
//defaults
result:=false;
a:=nil;

//check
if not mis__hasai(s) then
   begin
   result:=true;
   exit;
   end;

try
//info -> get most up-to-data animation information
mis__calccells2(s,xdelay,xcount,xcellwidth,xcellheight);

mis__ai(s).delay      :=xdelay;
mis__ai(s).count      :=xcount;
mis__ai(s).cellwidth  :=xcellwidth;
mis__ai(s).cellheight :=xcellheight;

if (xcount<=1) then
   begin
   result:=true;
   goto skipend;
   end;

//get
case mis__resizable(s) of
true:if not missize(s,xcellwidth,xcellheight) then goto skipend;
else begin//image can't be resized without data loss so we need to buffer off a copy and then write it back

   //create "a" using same bit depth as "s" -> 8/24/32
   a:=misimg(misb(s),xcellwidth,xcellheight);

   //copy s.cell(0) to "a"
   if not miscopyarea32(0,0,xcellwidth,xcellheight,area__make(0,0,xcellwidth-1,xcellheight-1),a,s) then goto skipend;

   //resize "s" to one cell dimensions
   if not missize(s,xcellwidth,xcellheight) then goto skipend;

   //copy "a" back to "s"
   if not miscopyarea32(0,0,xcellwidth,xcellheight,area__make(0,0,xcellwidth-1,xcellheight-1),s,a) then goto skipend;
   end;
end;

//update cell count to 1
mis__ai(s).count:=1;

//successful
result:=true;
skipend:
except;end;
//free
freeobj(@a);
end;

function mis__resizable(s:tobject):boolean;
begin
result:=(s<>nil) and (s is trawimage);
end;

function mis__retaindataonresize(s:tobject):boolean;//26jul2024: same as "mis__resizable()"
begin
result:=mis__resizable(s);
end;

function mis__rowsize4(ximagewidth,xbitsPERpixel:longint):longint;//rounds to nearest 4 bytes - 27may2025
begin
//calc
result:=(ximagewidth*xbitsPERpixel) div 8;
if ((result*8)<>(ximagewidth*xbitsPERpixel)) then inc(result);

//nearest 4 bytes
result:=int__round4(result);
end;

{$ifdef gui3}
function mis__reducecolors256(s:tobject;xMaxColorCount:longint):boolean;//17sep2025
label
   redo,skipend;

const
   dvLimit=240;

var
   ppal:array[0..255] of tcolor32;
   sbits,sw,sh,pdiv,pcount,plimit,sx,sy:longint;
   strans:boolean;
   sr32:pcolorrow32;
   sr24:pcolorrow24;
   sr8 :pcolorrow8;
   c32 :tcolor32;

   function padd:boolean;
   var
      p:longint;
   begin

   //defaults
   result:=false;

   //transparent colors goto into slot #0
   if (c32.a<=0) then
      begin

      result:=true;
      exit;

      end;

   //search to see if color already exists
   for p:=1 to (pcount-1) do if (c32.r=ppal[p].r) and (c32.g=ppal[p].g) and (c32.b=ppal[p].b) and (c32.a=ppal[p].a) then
      begin

      result:=true;
      break;

      end;

   //add
   if (not result) and (pcount<plimit) then
      begin

      ppal[pcount]:=c32;
      inc(pcount);
      result:=true;

      end;

   end;

   procedure r32;//read pixel
   begin

   if (sbits=32) then
      begin

      c32:=sr32[sx];

      end
   else if (sbits=24) then
      begin

      c32.r:=sr24[sx].r;
      c32.g:=sr24[sx].g;
      c32.b:=sr24[sx].b;
      c32.a:=255;

      end

   else if (sbits=8) then
      begin

      c32.r:=sr8[sx];
      c32.g:=c32.r;
      c32.b:=c32.r;
      c32.a:=255;

      end;

   end;

   procedure w32;//write pixel
   begin

   if (sbits=32) then
      begin

      sr32[sx]:=c32;

      end
   else if (sbits=24) then
      begin

      sr24[sx].r:=c32.r;
      sr24[sx].g:=c32.g;
      sr24[sx].b:=c32.b;

      end

   else if (sbits=8) then
      begin

      if (c32.g>c32.r) then c32.r:=c32.g;
      if (c32.b>c32.r) then c32.r:=c32.b;
      sr8[sx]:=c32.r;

      end;

   end;

   procedure s32;//shrink color bandwidth
   begin

   //all other colors go into remaining slots
   c32.r:=(c32.r div pdiv)*pdiv;
   c32.g:=(c32.g div pdiv)*pdiv;
   c32.b:=(c32.b div pdiv)*pdiv;
   if (c32.a<=127) then c32.a:=0 else c32.a:=255;

   end;

begin

//defaults
result:=false;

try
//check
if not misok82432(s,sbits,sw,sh) then goto skipend;

//init
plimit :=frcrange32(xMaxColorCount,1,256);
strans :=mask__hastransparency32(s);



//build palette (entries 0..255)
pdiv:=1;

redo:
pcount :=insint(1,strans);

for sy:=0 to (sh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;

for sx:=0 to (sw-1) do
begin

r32;
s32;

//pallete is full -> we need to shrink the color bandwidth and start over
if not padd then
   begin

   //used up all bandwidth shrinkage and palette still can't be built -> quit -> task failed
   if (pdiv>=dvlimit) then goto skipend;

   //try again by shrinking color bandwidth using "pdiv" -> increment by powers of two for fast division
   pdiv:=frcmax32(pdiv+low__aorb(1,10,pdiv>30),dvlimit);//smoother and faster - 25dec2022
   goto redo;
   end;

end;//sx

end;//sy

//finalise -> adjust image colors to new levels
for sy:=0 to (sh-1) do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;

for sx:=0 to (sw-1) do
begin

r32;
s32;
w32;

end;//sx

end;//sy

//successful
result:=true;
skipend:

except;end;
end;

function misokk82432(s:tobject):boolean;
var
   shasai:boolean;
   sbits,sw,sh:longint;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24) or (sbits=32));
end;

function misscan832(s:tobject;sy:longint;var sr8:pcolorrow8;var sr32:pcolorrow32):boolean;//14feb2022
var
   sw,sh:longint;
begin
//defaults
result:=false;

try
sr8:=nil;
sr32:=nil;
//check
if zznil(s,2101) then exit;
//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr8 :=(s as tbasicimage).prows8[sy];
   sr32:=(s as tbasicimage).prows32[sy];
   end
else if (s is twinbmp) then
   begin
   sr8 :=(s as twinbmp).prows8[sy];
   sr32:=(s as twinbmp).prows32[sy];
   end
else if (s is trawimage) then
   begin
   sr8 :=(s as trawimage).prows8[sy];
   sr32:=(s as trawimage).prows32[sy];
   end
else exit;
//successful
result:=(sr8<>nil) and (sr32<>nil);
except;end;
end;

function mis__countcolors257(s:tobject):longint;//limited color counter -> counts up to 257 colors - 14may2025
label
   skipend;
const
   psize=257;
var
   plist:array[0..(psize-1)] of tcolor32;
   sbits,sx,sy,sw,sh:longint;
   sr32:pcolorrow32;
   sr24:pcolorrow24;
   sr8 :pcolorrow8;
   c32 :tcolor32;
   c24 :tcolor24;

   function pfind(var pcount:longint):boolean;
   var
      p:longint;
   begin
   //defaults
   result:=false;

   //find
   for p:=0 to (pcount-1) do if (c32.r=plist[p].r) and (c32.g=plist[p].g) and (c32.b=plist[p].b) then
      begin
      result:=true;
      exit;
      end;//p

   //add
   if (pcount<psize) then
      begin
      plist[pcount]:=c32;
      inc(pcount);
      result:=true;
      end;
   end;
begin
//defaults
result:=0;

try
//check
if not misok82432(s,sbits,sw,sh) then goto skipend;

//get -> count colors
//.sy
for sy:=0 to (sh-1) do
begin

if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;

//8
if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c32.r:=sr8[sx];
   c32.g:=c32.r;
   c32.b:=c32.r;
   if not pfind(result) then goto skipend;
   end;//sx
   end
//24
else if (sbits=24) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c24:=sr24[sx];
   c32.r:=c24.r;
   c32.g:=c24.g;
   c32.b:=c24.b;
   if not pfind(result) then goto skipend;
   end;//sx
   end
//32
else if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   c32:=sr32[sx];
   if not pfind(result) then goto skipend;
   end;//sx
   end;

end;//sy

skipend:
except;end;
end;

function miscls(s:tobject;xcolor:longint):boolean;
begin
result:=misclsarea3(s,maxarea,xcolor,xcolor,clnone,clnone);
end;

function misclsarea(s:tobject;sarea:twinrect;xcolor:longint):boolean;
begin
result:=misclsarea3(s,sarea,xcolor,xcolor,clnone,clnone);
end;
{$endif}

function misclsarea3(s:tobject;sarea:twinrect;xcolor,xcolor2,xalpha,xalpha2:longint):boolean;
label
   skipdone,skipend;
var
  sr8 :pcolorrow8;
  sr16:pcolorrow16;
  sr24:pcolorrow24;
  sr32:pcolorrow32;
  sc8 :tcolor8;
  sc16:tcolor16;
  sc24,sc,sc2:tcolor24;
  sc32:tcolor32;
  dx,dy,sbits,sw,sh:longint;
  xpert:extended;
  xcolorok,xalphaok,shasai:boolean;
  da:twinrect;
  xa:byte;
begin
//defaults
result:=false;
sc8:=0;
sc16:=0;
xa:=0;

try
//check
if not misinfo8162432(s,sbits,sw,sh,shasai) then exit;

//range
if (sarea.right<sarea.left) or (sarea.bottom<sarea.top) or (sarea.bottom<0) or (sarea.top>=sh) or (sarea.right<0) or (sarea.left>=sw) then
   begin
   result:=true;
   exit;
   end;
da.left:=frcrange32(sarea.left,0,sw-1);
da.right:=frcrange32(sarea.right,0,sw-1);
da.top:=frcrange32(sarea.top,0,sh-1);
da.bottom:=frcrange32(sarea.bottom,0,sh-1);

//init
//.color
if (xcolor <>clnone) and (xcolor2=clnone) then xcolor2:=xcolor;
if (xcolor2<>clnone) and (xcolor =clnone) then xcolor:=xcolor2;
xcolorok:=(xcolor<>clnone) and (xcolor2<>clnone);
if xcolorok then
   begin
   sc:=int__c24(xcolor);
   sc2:=int__c24(xcolor2);
   end;
//.alpha
if (xalpha <>clnone) and (xalpha2=clnone) then xalpha2:=xalpha;
if (xalpha2<>clnone) and (xalpha =clnone) then xalpha:=xalpha2;
xalphaok:=(xalpha<>clnone) and (xalpha2<>clnone);
if xalphaok then
   begin
   xalpha:=frcrange32(xalpha,0,255);
   xalpha2:=frcrange32(xalpha2,0,255);
   end;
//check
if (not xcolorok) and (not xalphaok) then goto skipdone;
//get
for dy:=da.top to da.bottom do
begin
//.color gradient - optional
if xcolorok and ((xcolor<>xcolor2) or (dy=da.top)) then
   begin
   //.make color
   if (xcolor=xcolor2) then
      begin
      sc24.r:=sc.r;
      sc24.g:=sc.g;
      sc24.b:=sc.b;
      end
   else
      begin
      xpert:=(dy-da.top+1)/(da.bottom-da.top+1);
      sc24.r:=round( (sc.r*(1-xpert))+(sc2.r*xpert) );
      sc24.g:=round( (sc.g*(1-xpert))+(sc2.g*xpert) );
      sc24.b:=round( (sc.b*(1-xpert))+(sc2.b*xpert) );
      end;
   //.more bits
   case sbits of
   8:begin
      sc8:=sc24.r;
      if (sc24.g>sc8) then sc8:=sc24.g;
      if (sc24.b>sc8) then sc8:=sc24.b;
      end;
   16:sc16:=(sc24.r div 8) + (sc24.g div 8)*32 + (sc24.b div 8)*1024;
   32:begin
      sc32.r:=sc24.r;
      sc32.g:=sc24.g;
      sc32.b:=sc24.b;
      sc32.a:=255;//fully solid
      end;
   end;//case
   end;

//.alpha gradient - optional
//was: if xalphaok and (xalpha<>xalpha2) or (dy=da.top) then
if xalphaok and ((xalpha<>xalpha2) or (dy=da.top)) then//fixed error - 22apr2021
   begin
   //.make alpha
   if (xalpha=xalpha2) then
      begin
      xa:=xalpha;
      end
   else
      begin
      xpert:=(dy-da.top+1)/(da.bottom-da.top+1);
      xa:=byte(frcrange32(round( (xalpha*(1-xpert))+(xalpha2*xpert) ),0,255));
      end;
   end;
//.scan
if not misscan2432(s,dy,sr24,sr32) then goto skipend;

//.pixels
case sbits of
8 :begin
   if not xcolorok then goto skipdone;
   sr8:=pointer(sr24);
   for dx:=da.left to da.right do sr8[dx]:=sc8;
   end;
16:begin
   if not xcolorok then goto skipdone;
   sr16:=pointer(sr24);
   for dx:=da.left to da.right do sr16[dx]:=sc16;
   end;
24:begin
   if not xcolorok then goto skipdone;
   for dx:=da.left to da.right do sr24[dx]:=sc24;
   end;
32:begin
   //.c + a
   if xcolorok and xalphaok then
      begin
      sc32.a:=xa;
      for dx:=da.left to da.right do sr32[dx]:=sc32;
      end
   //.c only
   else if xcolorok then
      begin
      for dx:=da.left to da.right do sr32[dx]:=sc32;
      end
   //.a only
   else if xalphaok then
      begin
      for dx:=da.left to da.right do sr32[dx].a:=xa;
      end;
   end;
end;//case
end;//dy
//successful
skipdone:
result:=true;
skipend:
except;end;
end;

function mis__cls(s:tobject;r,g,b,a:byte):boolean;//04aug2024
begin
result:=mis__cls2(s,misarea(s),r,g,b,a);
end;

function mis__cls3(s:tobject;sa:twinrect;scolor32:tcolor32):boolean;//29jan2025
begin
result:=mis__cls2(s,sa,scolor32.r,scolor32.g,scolor32.b,scolor32.a);
end;

function mis__cls2(s:tobject;sa:twinrect;r,g,b,a:byte):boolean;//04aug2024
label
   skipdone,skipend;
var
  sr8 :pcolorrow8;
  sr24:pcolorrow24;
  sr32:pcolorrow32;
  c8  :tcolor8;
  c24 :tcolor24;
  c32 :tcolor32;
  sx,sy,sbits,sw,sh:longint;
begin
result:=false;

try
//check
if not misok82432(s,sbits,sw,sh) then exit;

if not mis__canarea(s,sa,sa) then
   begin
   result:=true;
   exit;
   end;

//init
c8:=r;
if (g>c8) then c8:=g;
if (b>c8) then c8:=b;

c24.r:=r;
c24.g:=g;
c24.b:=b;

c32.r:=r;
c32.g:=g;
c32.b:=b;
c32.a:=a;

//get
for sy:=sa.top to sa.bottom do
begin
if not misscan82432(s,sy,sr8,sr24,sr32) then goto skipend;

case sbits of
8 :for sx:=sa.left to sa.right do sr8[sx] :=c8;
24:for sx:=sa.left to sa.right do sr24[sx]:=c24;
32:for sx:=sa.left to sa.right do sr32[sx]:=c32;
end;

end;//sy

//successful
result:=true;
skipend:
except;end;
end;

function misarea(s:tobject):twinrect;
begin
result:=nilrect;
if zzok(s,7008) then result:=area__make(0,0,misw(s)-1,mish(s)-1);
end;

function miscopyarea32(ddx,ddy,ddw,ddh:currency;sa:twinrect;d,s:tobject):boolean;//can copy ALL 32bits of color
begin
result:=miscopyarea322(maxarea,ddx,ddy,ddw,ddh,sa,d,s,0,0);
end;

function miscopyarea321(da,sa:twinrect;d,s:tobject):boolean;//can copy ALL 32bits of color
begin
result:=miscopyarea32(da.left,da.top,da.right-da.left+1,da.bottom-da.top+1,sa,d,s);
end;

function miscopyarea322(da_clip:twinrect;ddx,ddy,ddw,ddh:currency;sa:twinrect;d,s:tobject;xscroll,yscroll:longint):boolean;//can copy ALL 32bits of color
begin
result:=miscopyarea323(da_clip,ddx,ddy,ddw,ddh,sa,d,s,xscroll,yscroll,false);
end;

function miscopyarea323(da_clip:twinrect;ddx,ddy,ddw,ddh:currency;sa:twinrect;d,s:tobject;xscroll,yscroll:longint;xmix32:boolean):boolean;//18nov2024: xmix32 mixes alpha colors into a lesser bit depth image e.g. drawing a 32 bit image onto a 24 bit one, can copy ALL 32bits of color
begin
result:=miscopyarea324(da_clip,ddx,ddy,ddw,ddh,sa,d,s,xscroll,yscroll,255,xmix32);
end;

function miscopyarea324(da_clip:twinrect;ddx,ddy,ddw,ddh:currency;sa:twinrect;d,s:tobject;xscroll,yscroll,xAlphaPower255:longint;xmix32:boolean):boolean;//18nov2024: xmix32 mixes alpha colors into a lesser bit depth image e.g. drawing a 32 bit image onto a 24 bit one, can copy ALL 32bits of color
label
   skipend;
var//Note: Speed optimised using x-pixel limiter "d1,d2", y-pixel limiter "d3,d4"
   //      and object caching "1x createtmp" and "2x createint" with a typical speed
   //      increase in PicWork of 45x, or a screen paint time originally of 3,485ms now 78ms
   //      with layer 2 image at 80,000px wide @ 1,000% zoom as of 06sep2017.
   //Note: s and d are required - 25jul2017
   //Note: da,sa are zero-based areas, e.g: da.left/right=0..[width-1],
   //Critical Note: must use "trunc" instead of "round" for correct rounding behaviour - 24SEP2011
   //Note: xmix32: blends or mixes 32 bit color pixels from "s" into "d" WHEN d is not 32 bit capable
   dr32,sr32:pcolorrow32;//25apr2020
   dr24,sr24:pcolorrow24;
   dr8,sr8:pcolorrow8;
   sc32:tcolor32;
   tmp24,sc24:tcolor24;
   sc8:tcolor8;
   mx,my:pdllongint;
   _mx,_my:tdynamicinteger;//mapper support
   p,daW,daH,saW,saH:longint;
   d1,d2,d3,d4:longint;//x-pixel(d) and y-pixel(d) speed optimisers -> represent ACTUAL d.area needed to be processed - 05sep2017
   //.image values
   sw,sh,sbits:longint;
   shasai:boolean;
   dw,dh,dbits:longint;
   dhasai:boolean;
   //.other
   dx,dy,sx,sy:longint;
   dx1,dx2,dy1,dy2:longint;
   bol1,xmirror,xflip:boolean;
   da:twinrect;

   function cint32(x:currency):longint;
   begin//Note: Clip a 64bit integer to a 32bit integer range
   if (x>max32) then x:=max32
   else if (x<min32) then x:=min32;
   result:=trunc(x);
   end;

   procedure mix32_24;
   begin
   if (sc32.a<=0) then sc24:=dr24[dx]
   else
      begin
      tmp24:=dr24[dx];
      sc24.r:=( (sc32.r*sc32.a) + (tmp24.r*(255-sc32.a)) ) div 256;//div 256 is FASTER thatn 255
      sc24.g:=( (sc32.g*sc32.a) + (tmp24.g*(255-sc32.a)) ) div 256;
      sc24.b:=( (sc32.b*sc32.a) + (tmp24.b*(255-sc32.a)) ) div 256;
      end;
   end;

   procedure mix32_8;
   begin
   //check
   if (sc32.a<=0) then exit;

   //mix
   sc32.r:=( (sc32.r*sc32.a) + (dr8[dx]*(255-sc32.a)) ) div 256;//div 256 is FASTER thatn 255
   end;

begin
//defaults
result:=false;
_mx   :=nil;
_my   :=nil;

try
//check
if (sa.right<sa.left) or (sa.bottom<sa.top) then goto skipend;
if not misinfo82432(s,sbits,sw,sh,shasai)   then goto skipend;
if not misinfo82432(d,dbits,dw,dh,dhasai)   then goto skipend;

//.mirror + flip
xmirror:=(ddw<0);if xmirror then ddw:=-ddw;
xflip  :=(ddh<0);if xflip   then ddh:=-ddh;
da.left:=cint32(ddx);
da.right:=cint32(ddx)+cint32(ddw-1);
da.top:=cint32(ddy);
da.bottom:=cint32(ddy)+cint32(ddh-1);

//.da_clip - limit to dimensions of "d" - 05sep2017
da_clip.left:=frcrange32(da_clip.left,0,dw-1);
da_clip.right:=frcrange32(da_clip.right,da_clip.left,dw-1);
da_clip.top:=frcrange32(da_clip.top,0,dH-1);
da_clip.bottom:=frcrange32(da_clip.bottom,0,dH-1);

//.optimise actual x-pixels scanned -> d1 + d2 -> 05sep2017
//.warning: Do not alter boundary handling below or failure will result - 27sep2017
d1:=largest32(largest32(da.left,da_clip.left),0);//range: 0..max32
d2:=smallest32(smallest32(da.right,da_clip.right),dw-1);//range: min32..dw-1
if (d2<d1) then goto skipend;

//.optimise actual y-pixels scanned -> d3 + d4 -> 05sep2017
//.warning: Do not alter boundary handling below or failure will result - 27sep2017
d3:=largest32(largest32(da.top,da_clip.top),0);//range: 0..max32
d4:=smallest32(smallest32(da.bottom,da_clip.bottom),dH-1);//range: min32..dh-1
if (d4<d3) then goto skipend;

//.xAlphaPower255
xAlphaPower255 :=frcrange32(xAlphaPower255,0,255);

//.other
daW:=low__posn(da.right-da.left)+1;
daH:=low__posn(da.bottom-da.top)+1;
saW:=low__posn(sa.right-sa.left)+1;
saH:=low__posn(sa.bottom-sa.top)+1;
dx1:=frcrange32(da.left,0,dw-1);
dx2:=frcrange32(da.right,0,dw-1);
dy1:=frcrange32(da.top,0,dh-1);
dy2:=frcrange32(da.bottom,0,dh-1);
//.check area -> do nothing
if (daw=0) or (dah=0) or (saw=0) or (sah=0) then goto skipend;
if (sa.right<sa.left) or (sa.bottom<sa.top) or (da.right<da.left) or (da.bottom<da.top) then goto skipend;
if (dx2<dx1) or (dy2<dy1) then goto skipend;

//.x-scroll
if (xscroll<>0) then
   begin
   xscroll:=-xscroll;//logic inversion -> match user expectation -> neg.vals=left, pos.vals=right
   bol1:=(xscroll<0);
   xscroll:=low__posn(xscroll);
   xscroll:=xscroll-((xscroll div saW)*saW);
   xscroll:=frcrange32(xscroll,0,saW-1);
   if bol1 then xscroll:=-xscroll;
   end;

//.y-scroll
if (yscroll<>0) then
   begin
   yscroll:=-yscroll;//logic inversion -> match user expectation -> neg.vals=up, pos.vals=down
   bol1:=(yscroll<0);
   yscroll:=low__posn(yscroll);
   yscroll:=yscroll-((yscroll div saH)*saH);
   yscroll:=frcrange32(yscroll,0,saH-1);
   if bol1 then yscroll:=-yscroll;
   end;

//.mx (mapped dx) - highly optimised - 06sep2017
if not low__createint(_mx,'copyareaxx_mx.'+intstr32(daW)+'.0.'+intstr32(sa.left)+'.'+intstr32(sa.right)+'.'+intstr32(saW),bol1) then goto skipend;
if not bol1 then
   begin
   //init
   _mx.setparams(daW,daW,0);
   mx:=_mx.core;
   //get
   for p:=0 to (daW-1) do
   begin
   mx[p]:=frcrange32(sa.left+trunc(p*(saW/daW)),sa.left,sa.right);//06apr2017
   end;//p
   end;
mx:=_mx.core;

//.my (mapped dy) - highly optimised - 06sep2017
if not low__createint(_my,'copyareaxx_my.'+intstr32(daH)+'.0.'+intstr32(sa.top)+'.'+intstr32(sa.bottom)+'.'+intstr32(saH),bol1) then goto skipend;
if not bol1 then
   begin
   //init
   _my.setparams(daH,daH,0);
   my:=_my.core;
   //get
   for p:=0 to (daH-1) do
   begin
   my[p]:=frcrange32(sa.top+trunc(p*(saH/daH)),sa.top,sa.bottom);//24SEP2011
   end;//p
   end;
my:=_my.core;

//-- Draw Color Pixels ---------------------------------------------------------
//dy
//...was: for dy:=da.top to da.bottom do if (dy>=0) and (dy<dH) and (dy>=da_clip.top) and (dy<=da_clip.bottom) then
for dy:=d3 to d4 do
   begin
   //.ar
   if xflip then sy:=my[(da.bottom-da.top)-(dy-da.top)] else sy:=my[dy-da.top];//zero base
   //.y-scroll
   if (yscroll<>0) then
      begin
      sy:=sy+yscroll;
      if (sy<sa.top) then sy:=sa.bottom-(-sy-sa.top) else if (sy>sa.bottom) then sy:=sa.top+(sy-sa.bottom);
      end;
   //.sy
   if (sy>=0) and (sy<sH) then
      begin
      if not misscan82432(d,dy,dr8,dr24,dr32)                     then goto skipend;//25apr2020, 28may2019
      if not misscan82432(s,sy,sr8,sr24,sr32)                     then goto skipend;//25apr2020,
      //dx - Note: xeven only updated at this stage for speed during "sselshowbits<>0" - 08jul2019
      //...was: for dx:=da.left to da.right do if (dx>=0) and (dx<dw) and (dx>=da_clip.left) and (dx<=da_clip.right) then
      for dx:=d1 to d2 do
         begin
         if xmirror then sx:=mx[(da.right-da.left)-(dx-da.left)] else sx:=mx[dx-da.left];//zero base
         //.x-scroll
         if (xscroll<>0) then
            begin
            sx:=sx+xscroll;
            if (sx<sa.left) then
               begin
               //.math quirk for "animation cell area" referencing - 25sep2017
               if (sx<=0) then sx:=sa.right-(-sx-sa.left) else sx:=sa.right-(sa.left-sx);
               end
            else if (sx>sa.right) then sx:=sa.left+(sx-sa.right);
            end;
         //.sx
         if (sx>=0) and (sx<sW) then
            begin
            //.32 + 32
            if (sbits=32) and (dbits=32) then
               begin

               sc32      :=sr32[sx];
               sc32.a    :=(sc32.a*xAlphaPower255) div 256;
               dr32[dx]  :=sc32;

               end
            //.32 + 24
            else if (sbits=32) and (dbits=24) then
               begin

               sc32      :=sr32[sx];
               sc32.a    :=(sc32.a*xAlphaPower255) div 256;

               if xmix32 then mix32_24
               else
                  begin
                  sc24.r:=sc32.r;
                  sc24.g:=sc32.g;
                  sc24.b:=sc32.b;
                  end;

               dr24[dx]  :=sc24;

               end
            //.32 + 8
            else if (sbits=32) and (dbits=8) then
               begin

               sc32      :=sr32[sx];
               if (sc32.g>sc32.r) then sc32.r:=sc32.g;
               if (sc32.b>sc32.r) then sc32.r:=sc32.b;

               sc32.a    :=(sc32.a*xAlphaPower255) div 256;

               if xmix32 then mix32_8;

               dr8[dx]:=sc32.r;

               end
            //.24 + 32
            else if (sbits=24) and (dbits=32) then
               begin

               sc24      :=sr24[sx];
               sc32.r    :=sc24.r;
               sc32.g    :=sc24.g;
               sc32.b    :=sc24.b;
               sc32.a    :=xAlphaPower255;
               dr32[dx]:=sc32;

               end
            //.24 + 24
            else if (sbits=24) and (dbits=24) then
               begin

               sc24:=sr24[sx];
               dr24[dx]:=sc24;

               end
            //.24 + 8
            else if (sbits=24) and (dbits=8) then
               begin

               sc24:=sr24[sx];
               if (sc24.g>sc24.r) then sc24.r:=sc24.g;
               if (sc24.b>sc24.r) then sc24.r:=sc24.b;
               dr8[dx]:=sc24.r;

               end
            //.8 + 32
            else if (sbits=8) and (dbits=32) then
               begin

               sc32.r    :=sr8[sx];
               sc32.g    :=sc32.r;
               sc32.b    :=sc32.r;
               sc32.a    :=xAlphaPower255;
               dr32[dx]  :=sc32;

               end
            //.8 + 24
            else if (sbits=8) and (dbits=24) then
               begin

               sc24.r    :=sr8[sx];
               sc24.g    :=sc24.r;
               sc24.b    :=sc24.r;
               dr24[dx]  :=sc24;

               end
            //.8 + 8
            else if (sbits=8) and (dbits=8) then
               begin

               sc8       :=sr8[sx];
               dr8[dx]   :=sc8;

               end;
            end;//sx
         end;//dx
      end;//sy
   end;//dy

//successful
result:=true;
skipend:
except;end;
//.free
low__freeint(_mx);
low__freeint(_my);
end;

function misinfo(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
if zznil(s,2085) then
   begin
   sbits  :=0;
   sw     :=0;
   sh     :=0;
   shasai :=false;
   result :=false;
   end
else
   begin
   sbits  :=misb(s);
   sw     :=misw(s);
   sh     :=mish(s);
   shasai :=mishasai(s);
   result :=(sw>=1) and (sh>=1) and (sbits>=1);
   end;
end;

function misinfo2432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=misinfo(s,sbits,sw,sh,shasai) and ((sbits=24) or (sbits=32));
end;

function misinfo82432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=misinfo(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24) or (sbits=32));
end;

function misinfo8162432(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=misinfo(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=16) or (sbits=24) or (sbits=32));
end;

function misinfo824(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
result:=misinfo(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24));
end;

function misokex(s:tobject;var sbits,sw,sh:longint;var shasai:boolean):boolean;
begin
//defaults
result:=false;
sbits:=0;
sw:=0;
sh:=0;
shasai:=false;

//check
if system_nographics then exit;//special debug mode - 10jun2019

//get
if zznil(s,2079) then exit
else if (s is tbasicimage) then
   begin
   sw     :=(s as tbasicimage).width;
   sh     :=(s as tbasicimage).height;
   sbits  :=(s as tbasicimage).bits;
   shasai :=true;
   end
else if (s is trawimage) then
   begin
   sw     :=(s as trawimage).width;
   sh     :=(s as trawimage).height;
   sbits  :=(s as trawimage).bits;
   shasai :=true;
   end
else if (s is twinbmp) then
   begin
   sw     :=(s as twinbmp).width;
   sh     :=(s as twinbmp).height;
   sbits  :=(s as twinbmp).bits;
   shasai :=true;
   end;

//set
result:=(sw>=1) and (sh>=1) and (sbits>=1);
end;

function misok824(s:tobject;var sbits,sw,sh:longint):boolean;
var
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24));
end;

function misok82432(s:tobject;var sbits,sw,sh:longint):boolean;
var
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=8) or (sbits=24) or (sbits=32));
end;

function misok2432(s:tobject;var sbits,sw,sh:longint):boolean;//01may2025
var
   shasai:boolean;
begin
result:=misokex(s,sbits,sw,sh,shasai) and ((sbits=24) or (sbits=32));
end;

function misscan2432(s:tobject;sy:longint;var sr24:pcolorrow24;var sr32:pcolorrow32):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
sr24:=nil;
sr32:=nil;

try
//check
if zznil(s,2100) then exit;

//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;

//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr24:=(s as tbasicimage).prows24[sy];
   sr32:=(s as tbasicimage).prows32[sy];
   end
else if (s is twinbmp) then
   begin
   sr24:=(s as twinbmp).prows24[sy];
   sr32:=(s as twinbmp).prows32[sy];
   end
else if (s is trawimage) then
   begin
   sr24:=(s as trawimage).prows24[sy];
   sr32:=(s as trawimage).prows32[sy];
   end
else exit;

//successful
result:=(sr24<>nil) and (sr32<>nil);
except;end;
end;

function misscan82432(s:tobject;sy:longint;var sr8:pcolorrow8;var sr24:pcolorrow24;var sr32:pcolorrow32):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
sr8:=nil;
sr24:=nil;
sr32:=nil;

//check
if zznil(s,2091) then exit;

//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;

//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr8 :=(s as tbasicimage).prows8[sy];
   sr24:=(s as tbasicimage).prows24[sy];
   sr32:=(s as tbasicimage).prows32[sy];
   end
else if (s is twinbmp) then
   begin
   sr8 :=(s as twinbmp).prows8[sy];
   sr24:=(s as twinbmp).prows24[sy];
   sr32:=(s as twinbmp).prows32[sy];
   end
else if (s is trawimage) then
   begin
   sr8 :=(s as trawimage).prows8[sy];
   sr24:=(s as trawimage).prows24[sy];
   sr32:=(s as trawimage).prows32[sy];
   end
else exit;

//successful
result:=(sr8<>nil) and (sr24<>nil) and (sr32<>nil);
end;

function misscan24(s:tobject;sy:longint;var sr24:pcolorrow24):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
sr24:=nil;

//check
if zznil(s,2093) then exit;

//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;

//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr24:=(s as tbasicimage).prows24[sy];
   end
else if (s is twinbmp) then
   begin
   sr24:=(s as twinbmp).prows24[sy];
   end
else if (s is trawimage) then
   begin
   sr24:=(s as trawimage).prows24[sy];
   end
else exit;

//successful
result:=(sr24<>nil);
end;

function misscan32(s:tobject;sy:longint;var sr32:pcolorrow32):boolean;//26jan2021
var
   sw,sh:longint;
begin
//defaults
result:=false;
sr32:=nil;

//check
if zznil(s,2099) then exit;

//init
sw:=misw(s);
sh:=mish(s);
if (sw<=0) or (sh<=0) then exit;

//range
if (sy<0) then sy:=0 else if (sy>=sh) then sy:=sh-1;

//get
if (s is tbasicimage) then
   begin
   sr32:=(s as tbasicimage).prows32[sy];
   end
else if (s is twinbmp) then
   begin
   sr32:=(s as twinbmp).prows32[sy];
   end
else if (s is trawimage) then
   begin
   sr32:=(s as trawimage).prows32[sy];
   end
else exit;

//successful
result:=(sr32<>nil);
end;


//mask procs -------------------------------------------------------------------

{$ifdef gui3}
function mask__empty(s:tobject):boolean;
var
   xmin,xmax:longint;
begin
result:=true;
if mask__range(s,xmin,xmax) then result:=(xmax<=0);
end;

function mask__setval(s:tobject;xval:longint):boolean;
label
   skipend;
var
   sx,sy,sw,sh,sbits:longint;
   sr32:pcolorrow32;
   sr8:pcolorrow8;
   v:byte;
begin
//defaults
result:=false;

try
//check
if not misok82432(s,sbits,sw,sh) then exit;
//.24
if (sbits=24) then//ignore
   begin
   result:=true;
   goto skipend;
   end;
//range
v:=frcrange32(xval,0,255);
//get
//.sy
for sy:=0 to (sh-1) do
begin
if not misscan832(s,sy,sr8,sr32) then goto skipend;
//.32
if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do sr32[sx].a:=v;
   end
//.8
else if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do sr8[sx]:=v;
   end;
end;//dy
//successful
result:=true;
skipend:
except;end;
end;

function mask__range(s:tobject;var xmin,xmax:longint):boolean;//15feb2022
var
   v0,v255,vother:boolean;
begin
result:=mask__range2(s,v0,v255,vother,xmin,xmax);
end;

function mask__range2(s:tobject;var v0,v255,vother:boolean;var xmin,xmax:longint):boolean;//15feb2022
label
   skipend;
var
   sx,sy,sw,sh,sbits:longint;
   sr32:pcolorrow32;
   sr8:pcolorrow8;
   v:byte;
begin
//defaults
result:=false;

try
v0     :=false;
v255   :=false;
vother :=false;
xmin   :=255;
xmax   :=0;

//check
if not misok82432(s,sbits,sw,sh) then exit;

//get
//.24
if (sbits=24) then
   begin
   xmin  :=255;
   xmax  :=255;
   v255  :=true;
   result:=true;
   goto skipend;
   end;

//get
//.sy
for sy:=0 to (sh-1) do
begin
if not misscan832(s,sy,sr8,sr32) then goto skipend;
//.32
if (sbits=32) then
   begin
   for sx:=0 to (sw-1) do
   begin
   v:=sr32[sx].a;
   if (v>xmax) then xmax:=v;
   if (v<xmin) then xmin:=v;
   case v of
   0   :v0:=true;
   255 :v255:=true;
   else vother:=true;
   end;//case
   end;//sx
   end
//.8
else if (sbits=8) then
   begin
   for sx:=0 to (sw-1) do
   begin
   v:=sr8[sx];
   if (v>xmax) then xmax:=v;
   if (v<xmin) then xmin:=v;
   case v of
   0   :v0:=true;
   255 :v255:=true;
   else vother:=true;
   end;//case
   end;//sx
   end;
//check
if (xmin<=0) and (xmax>=255) and v0 and v255 and vother then break;
end;//sy
//successful
result:=true;
skipend:
except;end;
end;

function mask__hasTransparency32(s:tobject):boolean;//one or more alpha values are below 255 - 27may2025
var
   bol1:boolean;
begin
result:=mask__hasTransparency322(s,bol1);
end;

function mask__hasTransparency322(s:tobject;var xsimple0255:boolean):boolean;//one or more alpha values are below 255 - 27may2025
var
   sx,sy,sw,sh,sbits:longint;
   sr32:pcolorrow32;
begin
//defaults
result      :=false;
xsimple0255 :=true;

try
//check
if (not misok82432(s,sbits,sw,sh)) or (sbits<>32) then exit;

//get
for sy:=0 to (sh-1) do
begin
if not misscan32(s,sy,sr32) then break;

for sx:=0 to (sw-1) do
begin

case sr32[sx].a of
0:result:=true;
1..254:begin
   result     :=true;
   xsimple0255:=false;
   break;
   end;
end;//case

end;//sx

//stop
if result and (not xsimple0255) then break;
end;//sy

except;end;
end;
{$endif}


//canvas procs -----------------------------------------------------------------

{$ifdef gui3}
function wincanvas__textwidth(x:hdc;const xval:string):longint;
begin
result:=wincanvas__textextent(x,xval).x;
end;

function wincanvas__textheight(x:hdc;const xval:string):longint;
begin
result:=wincanvas__textextent(x,xval).y;
end;

function wincanvas__textout(x:hdc;xtransparent:boolean;dx,dy:longint;const xval:string):boolean;
begin
result:=(x<>0);
if result then win____TextOut(x,dx,dy,pchar(xval),low__len(xval));
end;

function wincanvas__textextent(x:hdc;const xval:string):tpoint;
begin
//defaults
result.x:=0;
result.y:=0;
//get
if (x<>0) then win____GetTextExtentPoint(x,pchar(xval),low__len(xval),result);
end;

function wincanvas__textrect(x:hdc;xtransparent:boolean;xarea:twinrect;dx,dy:longint;const xval:string):boolean;
var
   xoptions:longint;
begin
result:=(x<>0);
xoptions:=ETO_CLIPPED;
if not xtransparent then inc(xoptions,ETO_OPAQUE);
if result then win____ExtTextOut(x,dx,dy,xoptions,@xarea,pchar(xval),low__len(xval),nil);
end;
{$endif}


//temp procs -------------------------------------------------------------------
function low__createimg24(var x:tbasicimage;xid:string;var xwascached:boolean):boolean;
var
   i,p:longint;
   _ms64:comp;

   function _init(x:longint):tbasicimage;
   begin
   result:=nil;

   try
   systmpstyle[x]:=2;//0=free, 1=available, 2=locked
   systmptime[x]:=add64(ms64,30000);//30s
   systmpid[x]:=xid;
   if zznil(systmpbmp[x],2122) then systmpbmp[x]:=misimg(24,1,1);
   result:=systmpbmp[x];
   except;end;
   end;
begin
//defaults
result:=false;

try
x:=nil;
xwascached:=false;
//find existing
for p:=0 to high(systmpstyle) do if (systmpstyle[p]=1) and (xid=systmpid[p]) then
   begin
   x:=_init(p);
   xwascached:=true;//signal to calling proc the int.list was cacched intact -> allows for optimisation at the calling proc's end - 06sep2017
   break;
   end;
//find new
if zznil(x,2123) then for p:=0 to high(systmpstyle) do if (systmpstyle[p]=0) then
   begin
   x:=_init(p);
   break;
   end;
//find oldest
if zznil(x,2124) then
   begin
   i:=-1;
   _ms64:=0;
   //find
   for p:=0 to high(systmpstyle) do if (systmpstyle[p]=1) and ((systmptime[p]<_ms64) or (_ms64=0)) then
      begin
      i:=p;
      _ms64:=systmptime[p];
      end;//p
   //get
   if (i>=0) then x:=_init(i);
   end;
//successful
result:=(x<>nil);
except;end;
end;

procedure low__freeimg(var x:tbasicimage);
var
   p:longint;
begin
try
if zzok(x,7003) then for p:=0 to high(systmpstyle) do if (x=systmpbmp[p]) then
   begin
   if (systmpstyle[p]=2) then//locked
      begin
      systmptime[p]:=add64(ms64,30000);//30s - hold onto this before trying to free it via "checktmp"
      systmpstyle[p]:=1;//unlock -> make this buffer available again
      x:=nil;
      end;
   break;
   end;//p
except;end;
end;

procedure low__checkimg;
begin
try
//init
inc(systmppos);
if (systmppos<0) or (systmppos>high(systmpstyle)) then systmppos:=0;
//shrink buffer
if (systmpstyle[systmppos]=1) and (ms64>=systmptime[systmppos]) and zzok(systmpbmp[systmppos],7005) and ((systmpbmp[systmppos].width>1) or (systmpbmp[systmppos].height>1)) then
   begin
   systmpstyle[systmppos]:=2;//lock
   try
   systmpid[systmppos]:='';//clear id - 06sep2017
   if (systmpbmp[systmppos].width>1) or (systmpbmp[systmppos].height>1) then systmpbmp[systmppos].sizeto(1,1);//23may2020
   except;end;
   systmpstyle[systmppos]:=1;//unlock
   end;
except;end;
end;

function low__createint(var x:tdynamicinteger;xid:string;var xwascached:boolean):boolean;
var
   _ms64:comp;
   i,p:longint;

   function _init(x:longint):tdynamicinteger;
   begin
   result:=nil;

   try
   sysintstyle[x]:=2;//0=free, 1=available, 2=locked
   sysinttime[x]:=add64(ms64,30000);//30s
   sysintid[x]:=xid;//set the id (duplicate id's are allowed)
   if zznil(sysintobj[x],2125) then sysintobj[x]:=tdynamicinteger.create;
   result:=sysintobj[x];
   except;end;
   end;
begin
//defaults
result:=false;

try
xwascached:=false;
x:=nil;
//find existing
for p:=0 to high(sysintstyle) do if (sysintstyle[p]=1) and (xid=sysintid[p]) then
   begin
   x:=_init(p);
   xwascached:=true;//signal to calling proc the int.list was cacched intact -> allows for optimisation at the calling proc's end - 06sep2017
   break;
   end;
//find new
if zznil(x,2126) then for p:=0 to high(sysintstyle) do if (sysintstyle[p]=0) then
   begin
   x:=_init(p);
   break;
   end;
//find oldest
if zznil(x,2127) then
   begin
   i:=-1;
   _ms64:=0;
   //find
   for p:=0 to high(sysintstyle) do if (sysintstyle[p]=1) and ((sysinttime[p]<_ms64) or (_ms64=0)) then
      begin
      i:=p;
      _ms64:=sysinttime[p];
      end;//p
   //get
   if (i>=0) then x:=_init(i);
   end;
//successful
result:=(x<>nil);
except;end;
end;

procedure low__freeint(var x:tdynamicinteger);
var
   p:longint;
begin
try
if (x<>nil) then for p:=0 to high(sysintstyle) do if (x=sysintobj[p]) then
   begin
   if (sysintstyle[p]=2) then//locked
      begin
      sysinttime[p]:=add64(ms64,30000);//30s - hold onto this before trying to free it via "checktmp"
      sysintstyle[p]:=1;//unlock -> make this buffer available again
      x:=nil;
      end;
   break;
   end;//p
except;end;
end;

procedure low__checkint;
begin
try
//init
inc(sysintpos);
if (sysintpos<0) or (sysintpos>high(sysintstyle)) then sysintpos:=0;
//shrink buffer
if (sysintstyle[sysintpos]=1) and (ms64>=sysinttime[sysintpos]) and zzok(sysintobj[sysintpos],7006) and (sysintobj[sysintpos].size>1) then
   begin
   sysintstyle[sysintpos]:=2;//lock
   sysintid[sysintpos]:='';//clear id - 06sep2017
   sysintobj[sysintpos].clear;
   sysintstyle[sysintpos]:=1;//unlock
   end;
except;end;
end;

function low__createbyte(var x:tdynamicbyte;xid:string;var xwascached:boolean):boolean;
var
   _ms64:comp;
   i,p:longint;

   function _init(x:longint):tdynamicbyte;
   begin
   result:=nil;
   try
   sysbytestyle[x]:=2;//0=free, 1=available, 2=locked
   sysbytetime[x]:=add64(ms64,30000);//30s
   sysbyteid[x]:=xid;//set the id (duplicate id's are allowed)
   if zznil(sysbyteobj[x],2128) then sysbyteobj[x]:=tdynamicbyte.create;
   result:=sysbyteobj[x];
   except;end;
   end;
begin
//defaults
result:=false;

try
xwascached:=false;
x:=nil;
//find existing
for p:=0 to high(sysbytestyle) do if (sysbytestyle[p]=1) and (xid=sysbyteid[p]) then
   begin
   x:=_init(p);
   xwascached:=true;//signal to calling proc the int.list was cacched intact -> allows for optimisation at the calling proc's end - 06sep2017
   break;
   end;
//find new
if zznil(x,2129) then for p:=0 to high(sysbytestyle) do if (sysbytestyle[p]=0) then
   begin
   x:=_init(p);
   break;
   end;
//find oldest
if zznil(x,2130) then
   begin
   i:=-1;
   _ms64:=0;
   //find
   for p:=0 to high(sysbytestyle) do if (sysbytestyle[p]=1) and ((sysbytetime[p]<_ms64) or (_ms64=0)) then
      begin
      i:=p;
      _ms64:=sysbytetime[p];
      end;//p
   //get
   if (i>=0) then x:=_init(i);
   end;
//successful
result:=(x<>nil);
except;end;
end;

procedure low__freebyte(var x:tdynamicbyte);
var
   p:longint;
begin
try
if (x<>nil) then for p:=0 to high(sysbytestyle) do if (x=sysbyteobj[p]) then
   begin
   if (sysbytestyle[p]=2) then//locked
      begin
      sysbytetime[p]:=add64(ms64,30000);//30s - hold onto this before trying to free it via "checktmp"
      sysbytestyle[p]:=1;//unlock -> make this buffer available again
      x:=nil;
      end;
   break;
   end;//p
except;end;
end;

procedure low__checkbyte;
begin
try
//init
inc(sysbytepos);
if (sysbytepos<0) or (sysbytepos>high(sysbytestyle)) then sysbytepos:=0;
//shrink buffer
if (sysbytestyle[sysbytepos]=1) and (ms64>=sysbytetime[sysbytepos]) and zzok(sysbyteobj[sysbytepos],7007) and (sysbyteobj[sysbytepos].size>1) then
   begin
   sysbytestyle[sysbytepos]:=2;//lock
   sysbyteid[sysbytepos]:='';//clear id - 06sep2017
   sysbyteobj[sysbytepos].clear;
   sysbytestyle[sysbytepos]:=1;//unlock
   end;
except;end;
end;


//## tbasicimage ###############################################################
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx//ggggggggggggggggggggggggggggg
constructor tbasicimage.create;//01NOV2011
begin
if classnameis('tbasicimage') then track__inc(satBasicimage,1);
zzadd(self);
inherited create;
//options
misaiclear(ai);
dtransparent:=true;
omovie:=false;
oaddress:='';
ocleanmask32bpp:=false;
rhavemovie:=false;
//vars
istable:=false;
idata:=str__new8;
irows:=str__new8;
ibits:=0;
iwidth:=0;
iheight:=0;
iprows8 :=nil;
iprows16:=nil;
iprows24:=nil;
iprows32:=nil;
//defaults
setparams(8,1,1);
//enable
istable:=true;
end;

destructor tbasicimage.destroy;//28NOV2010
begin
try
//disable
istable:=false;
//controls
iprows8 :=nil;
iprows16:=nil;
iprows24:=nil;
iprows32:=nil;
freeobj(@irows);
freeobj(@idata);
//destroy
inherited destroy;
if classnameis('tbasicimage') then track__inc(satBasicimage,-1);
except;end;
end;

function tbasicimage.copyfrom(s:tbasicimage):boolean;//09may2022, 09feb2022
label
   skipend;
begin
//defaults
result:=false;

try
//check
if (s=self) then
   begin
   result:=true;
   exit;
   end;
if (s=nil) then exit;
//get
//was: if not low__aicopy(ai,s.ai) then goto skipend;
if not low__aicopy(s.ai,ai) then goto skipend;//09may2022
dtransparent:=s.dtransparent;
omovie:=s.omovie;
oaddress:=s.oaddress;
ocleanmask32bpp:=s.ocleanmask32bpp;
rhavemovie:=s.rhavemovie;
setraw(misb(s),misw(s),mish(s),s.data);
//successful
result:=true;
skipend:
except;end;
end;

function tbasicimage.todata:tstr8;//19feb2022
label
   skipend;
var
   xresult:boolean;
   v8:tvars8;
   tmp:tstr8;//pointer only
begin
result:=nil;
xresult:=false;

try
//defaults
result:=str__new8;
v8:=nil;
//info
v8:=vnew;
if (ai.format<>'')        then v8.s['f']:=ai.format;
if (ai.subformat<>'')     then v8.s['s']:=ai.subformat;
if (ai.info<>'')          then v8.s['i']:=ai.info;
if (ai.map16<>'')         then v8.s['m']:=ai.map16;
if ai.transparent         then v8.b['t']:=ai.transparent;
if ai.syscolors           then v8.b['sc']:=ai.syscolors;
if ai.flip                then v8.b['fp']:=ai.flip;
if ai.mirror              then v8.b['mr']:=ai.mirror;
if (ai.delay<>0)          then v8.i['d']:=ai.delay;
if (ai.itemindex<>0)      then v8.i['i']:=ai.itemindex;
if (ai.count<>0)          then v8.i['c']:=ai.count;
if (ai.bpp<>0)            then v8.i['bp']:=ai.bpp;
if ai.binary              then v8.b['bin']:=ai.binary;
if (ai.hotspotX<>0)       then v8.i['hx']:=ai.hotspotX;
if (ai.hotspotY<>0)       then v8.i['hy']:=ai.hotspotY;
if ai.hotspotMANUAL       then v8.b['hm']:=ai.hotspotMANUAL;
if ai.owrite32bpp         then v8.b['w32']:=ai.owrite32bpp;
if ai.readB64             then v8.b['r64']:=ai.readB64;
if ai.readB128            then v8.b['r128']:=ai.readB128;
if ai.writeB64            then v8.b['w64']:=ai.writeB64;
if ai.writeB128           then v8.b['w128']:=ai.writeB128;
if (ai.iosplit<>0)        then v8.i['ios']:=ai.iosplit;
if (ai.cellwidth<>0)      then v8.i['cw']:=ai.cellwidth;
if (ai.cellheight<>0)     then v8.i['ch']:=ai.cellheight;
if ai.use32               then v8.b['u32']:=ai.use32;//22may2022
if dtransparent           then v8.b['dt']:=dtransparent;
if omovie                 then v8.b['mv']:=omovie;
if (oaddress<>'')         then v8.s['ad']:=oaddress;
if ocleanmask32bpp        then v8.b['c32']:=ocleanmask32bpp;
if rhavemovie             then v8.b['hmv']:=rhavemovie;
//.info
tmp:=v8.data;
result.addint4(0);
result.addint4(tmp.len);
result.add(tmp);
//.pixels
result.addint4(1);
result.addint4(12+idata.len);
result.addint4(bits);
result.addint4(width);
result.addint4(height);
result.add(idata);
//.finished
result.addint4(max32);
//successful
xresult:=true;
skipend:
except;end;
try
result.oautofree:=true;
if (not xresult) and (result<>nil) then result.clear;
freeobj(@v8);
except;end;
end;

function tbasicimage.fromdata(s:tstr8):boolean;//19feb2022
label
   redo,skipend;
var
   v8:tvars8;
   abits,xid,xpos,xlen:longint;
   xdata:tstr8;

   function xpull:boolean;
   label
      skipend;
   var
      b,w,h,slen:longint;
   begin
   //defaults
   result:=false;

   try
   //clear
   xdata.clear;
   //id
   if ((xpos+3)>=xlen) then goto skipend;
   xid:=s.int4[xpos];
   inc(xpos,4);
   //eof
   if (xid=max32) then
      begin
      result:=true;
      goto skipend;
      end;
   //slen
   if ((xpos+3)>=xlen) then goto skipend;
   slen:=s.int4[xpos];
   inc(xpos,4);
   //check
   if ((xpos+slen-1)>=xlen) then goto skipend;
   //data
   if not xdata.add3(s,xpos,slen) then goto skipend;
   inc(xpos,slen);
   //set
   case xid of
   0:v8.data:=xdata;
   1:begin
      b:=xdata.int4[0];//0..3
      w:=xdata.int4[4];//4..7
      h:=xdata.int4[8];//8..11
      if (b<0) or (w<=0) or (h<=0) then goto skipend;
      if not xdata.del3(0,12) then goto skipend;
      if not setraw(b,w,h,xdata) then goto skipend;
      end;
   else goto skipend;//error
   end;
   //successfsul
   result:=true;
   skipend:
   except;end;
   end;
begin
//defaults
result:=false;
abits:=bits;

try
v8:=nil;
xdata:=nil;
//check
if not str__lock(@s) then exit;
//init
xlen:=s.len;
xpos:=0;
v8:=vnew;
xdata:=str__new8;
//get
redo:
if not xpull then goto skipend;
if (xid<>max32) then goto redo;

//info
ai.format            :=v8.s['f'];
ai.subformat         :=v8.s['s'];
ai.info              :=v8.s['i'];
ai.map16             :=v8.s['m'];
ai.transparent       :=v8.b['t'];
ai.syscolors         :=v8.b['sc'];
ai.flip              :=v8.b['fp'];
ai.mirror            :=v8.b['mr'];
ai.delay             :=v8.i['d'];
ai.itemindex         :=v8.i['i'];
ai.count             :=v8.i['c'];
ai.bpp               :=v8.i['bp'];
ai.binary            :=v8.b['bin'];
ai.hotspotX          :=v8.i['hx'];
ai.hotspotY          :=v8.i['hy'];
ai.hotspotMANUAL     :=v8.b['hm'];
ai.owrite32bpp       :=v8.b['w32'];
ai.use32             :=v8.b['u32'];//22may2022
ai.readB64           :=v8.b['r64'];
ai.readB128          :=v8.b['r128'];
ai.writeB64          :=v8.b['w64'];
ai.writeB128         :=v8.b['w128'];
ai.iosplit           :=v8.i['ios'];
ai.cellwidth         :=v8.i['cw'];
ai.cellheight        :=v8.i['ch'];
dtransparent         :=v8.b['dt'];
omovie               :=v8.b['mv'];
oaddress             :=v8.s['ad'];
ocleanmask32bpp      :=v8.b['c32'];
rhavemovie           :=v8.b['hmv'];

//successful
result:=true;
skipend:
except;end;
try
freeobj(@v8);
str__free(@xdata);
str__uaf(@s);
//error
if not result then setparams(abits,1,1);
except;end;
end;

function tbasicimage.sizeto(dw,dh:longint):boolean;
begin
result:=setparams(ibits,dw,dh);
end;

function tbasicimage.setparams(dbits,dw,dh:longint):boolean;
var
   dy,dlen:longint;
begin
//defaults
result:=false;

try
//range
if (dbits<>8) and (dbits<>16) and (dbits<>24) and (dbits<>32) then dbits:=24;
if (dw<1) then dw:=1;
if (dh<1) then dh:=1;
//check
if (dbits=ibits) and (dw=iwidth) and (dh=iheight) then
   begin
   result:=true;
   exit;
   end;
//get
dlen:=(dbits div 8)*dw*dh;
if idata.setlen(dlen) then
   begin
   //init
   ibits:=dbits;
   iwidth:=dw;
   iheight:=dh;
   irows.setlen(dh*sizeof(pointer));
   iprows8 :=irows.prows8;
   iprows16:=irows.prows16;
   iprows24:=irows.prows24;
   iprows32:=irows.prows32;
   //get
   for dy:=0 to (dh-1) do
   begin
   case dbits of
   8 :iprows8[dy] :=ptr__shift(idata.core,dy*dw*1);
   16:iprows16[dy]:=ptr__shift(idata.core,dy*dw*2);
   24:iprows24[dy]:=ptr__shift(idata.core,dy*dw*3);
   32:iprows32[dy]:=ptr__shift(idata.core,dy*dw*4);
   end;
   end;//dy
   //successful
   result:=true;
   end;
except;end;
end;

function tbasicimage.setraw(dbits,dw,dh:longint;ddata:tstr8):boolean;
var
   p,xlen:longint;
   v:byte;
begin
//defaults
result:=false;

try
//size
setparams(dbits,dw,dh);
//lock
if not str__lock(@ddata) then exit;
//get
if (ddata<>nil) and (idata<>nil) then
   begin
   xlen:=frcmax32(idata.len,ddata.len);
   if (xlen>=1) then
      begin
      //was: for p:=0 to (xlen-1) do idata.pbytes[p]:=ddata.pbytes[p];
      //faster - 22apr2022
      for p:=0 to (xlen-1) do
      begin
      v:=ddata.pbytes[p];
      idata.pbytes[p]:=v;
      end;//p
      end;
   end;
result:=true;//19feb2022
except;end;
try;str__uaf(@ddata);except;end;
end;

function tbasicimage.getareadata(sa:twinrect):tstr8;
begin
result:=nil;

try
result:=str__newaf8;
str__lock(@result);
getarea(result,sa);
str__unlock(@result);
except;end;
end;

procedure tbasicimage.setareadata(sa:twinrect;sdata:tstr8);
begin
setarea(sdata,sa);
end;

function tbasicimage.getarea(ddata:tstr8;da:twinrect):boolean;//07dec2023
label
   skipend;
var
   a:tbasicimage;
begin
//defaults
result:=false;

try
a:=nil;
//lock
if not str__lock(@ddata) then exit;
ddata.clear;
//check
if not validarea(da) then goto skipend;
//get
a:=misimg(bits,da.right-da.left+1,da.bottom-da.top+1);//image of same bit depth as ourselves
result:=miscopyarea32(0,0,misw(a),mish(a),da,a,self) and ddata.addb(a.data);//copy area to this image and then return it's raw datastream - 07dec2023
skipend:
except;end;
try
str__uaf(@ddata);
freeobj(@a);
except;end;
end;

function tbasicimage.getareadata2(sa:twinrect):tstr8;
begin
result:=nil;

try
result:=str__newaf8;
str__lock(@result);
getarea_fast(result,sa);
str__unlock(@result);
except;end;
end;

function tbasicimage.getarea_fast(ddata:tstr8;da:twinrect):boolean;//07dec2023
label
   skipend;
var
   sstart,srowsize,drowsize,sw,sh,dy,dw,dh:longint;
begin
//defaults
result:=false;

try
//lock
if not str__lock(@ddata) then exit;
//ddata.clear;
//check
if not validarea(da) then goto skipend;
//range
sw:=width;
sh:=height;
da.left:=frcrange32(da.left,0,sw-1);
da.right:=frcrange32(da.right,da.left,sw-1);
da.top:=frcrange32(da.top,0,sh-1);
da.bottom:=frcrange32(da.bottom,da.top,sh-1);
dw:=da.right-da.left+1;
dh:=da.bottom-da.top+1;
sstart:=(bits div 8)*da.left;
srowsize:=(bits div 8)*sw;
drowsize:=(bits div 8)*dw;
//.size - presize for maximum speed
//ddata.minlen(dh*drowsize);
//ddata.count:=0;

if (ddata.len<>(dh*drowsize)) then ddata.setlen(dh*drowsize);
ddata.setcount(0);



//get
for dy:=da.top to da.bottom do
begin
if not ddata.add3(idata,(dy*srowsize)+sstart,drowsize) then goto skipend;
end;

//successful
result:=true;
skipend:
except;end;
try
if not result then ddata.clear;
str__uaf(@ddata);
except;end;
end;

function tbasicimage.setarea(ddata:tstr8;da:twinrect):boolean;//07dec2023
label
   skipend;
var
   a:tbasicimage;
begin
//defaults
result:=false;

try
a:=nil;
//lock
if not str__lock(@ddata) then exit;
//check
if (da.left>=width) or (da.right<0) or (da.top>=height) or (da.bottom<0) or (da.right<da.left) or (da.bottom<da.top) then
   begin
   result:=true;
   goto skipend;
   end;
//init
a:=misimg8(1,1);
//get
result:=a.setraw(bits,da.right-da.left+1,da.bottom-da.top+1,ddata) and miscopyarea32(da.left,da.top,da.right-da.left+1,da.bottom-da.top+1,misarea(a),self,a);
skipend:
except;end;
try
str__uaf(@ddata);
freeobj(@a);
except;end;
end;

function tbasicimage.findscanline(slayer,sy:longint):pointer;
begin
//defaults
result:=nil;
//check
if (iwidth<1) or (iheight<1) then exit;
//range
if (sy<0) then sy:=0 else if (sy>=iheight) then sy:=iheight-1;
//get
result:=ptr__shift(idata,sy*iwidth*(ibits div 8));
end;

//trawimage --------------------------------------------------------------------
constructor trawimage.create;
begin
if classnameis('trawimage') then track__inc(satrawimage,1);
inherited create;
//options
misaiclear(ai);
dtransparent:=true;
omovie:=false;
oaddress:='';
ocleanmask32bpp:=false;
rhavemovie:=false;
//vars
icore:=tdynamicstr8.create;
irows:=str__new8;
ifallback:=str__new8;
ibits  :=32;
iwidth :=0;//20mar2025
iheight:=0;
//defaults
setparams2(32,1,1,true);
zzadd(self);
end;

destructor trawimage.destroy;
begin
try
//vars
str__free(@ifallback);
str__free(@irows);
freeobj(@icore);
//self
inherited destroy;
if classnameis('trawimage') then track__inc(satrawimage,-1);
except;end;
end;

function trawimage.rowinfo(sy:longint):string;
begin
result:='none';
//for p:=0 to 99 do icore.items[p]:=str__new8;//xxxxxxxxxx
//if (sy>=0) and (sy<icore.count) and (icore.value[sy]<>nil) then result:=k64(icore.count)+'<<'+k64(str__len(cache__ptr(icore.value[sy])))+'<< len: '+k64(icore.value[sy].len)+', datalen: '+k64(icore.value[sy].datalen)+', ptr: '+k64(cardinal(icore.value[sy]));
if (sy>=0) and (sy<icore.count) and (icore.value[sy]<>nil) then result:='sy: '+k64(sy)+'>>'+k64(longint(icore))+'<<..'+k64(icore.count)+'<< len: '+k64(icore.value[sy].len)+', datalen: '+k64(icore.value[sy].datalen)+', ptr: '+k64(cardinal(icore.value[sy]));
end;

procedure trawimage.setbits(x:longint);
begin
setparams(x,iwidth,iheight);
end;

procedure trawimage.setwidth(x:longint);
begin
setparams(ibits,x,iheight);
end;

procedure trawimage.setheight(x:longint);
begin
setparams(ibits,iwidth,x);
end;

function trawimage.setparams(dbits,dw,dh:longint):boolean;
begin
result:=setparams2(dbits,dw,dh,false);
end;

function trawimage.setparams2(dbits,dw,dh:longint;dforce:boolean):boolean;//27dec2024
var
   drowlen:longint;

   procedure xcheckrows;
   var
      i:longint;
   begin
   for i:=0 to (dh-1) do if (icore.value[i].len<>drowlen) then icore.value[i].setlen(drowlen);
   end;
begin
//defaults
result:=false;

try
//range
if (dbits<>8) and (dbits<>16) and (dbits<>24) and (dbits<>32) then dbits:=32;
dw      :=frcmin32(dw,1);
dh      :=frcmin32(dh,1);
drowlen :=mis__rowsize4(dw,dbits);//27may2025

//get
if (dbits<>ibits) or (dw<>iwidth) or (dh<>iheight) or dforce then
   begin
   //ifallback
   ifallback.setlen(drowlen);

   //dh
   if (dh<>iheight) then icore.forcesize(dh);//25jul2024

   //check
   xcheckrows;

   //set
   iheight:=dh;
   iwidth :=dw;
   ibits  :=dbits;

   //sync
   xsync;

   //successful
   result:=true;
   end
else result:=true;
except;end;
end;

function trawimage.getscanline(sy:longint):pointer;
begin
if (sy<0) then sy:=0 else if (sy>=iheight) then sy:=iheight-1;
result:=pointer(icore.value[sy].core);
end;

procedure trawimage.xsync;
var
   dy:longint;
begin
try
//init
irows.setlen(iheight*sizeof(tpointer));
irows8 :=irows.core;
irows15:=irows.core;
irows16:=irows.core;
irows24:=irows.core;
irows32:=irows.core;

//get
for dy:=0 to (iheight-1) do irows32[dy]:=scanline[dy];
except;end;
end;


//## twinbmp ###################################################################
//xxxxxxxxxxxxxxxxxxxxxxxxxxx//bbbbbbbbbbbbbbbbbbbbbbb
constructor twinbmp.create;
begin
if classnameis('twinbmp') then track__inc(satWinbmp,1);
inherited create;

//vars
low__cls(@iinfo,sizeof(iinfo));

ifont       :=0;
ibrush      :=0;
ifontOLD    :=0;
ibrushOLD   :=0;

ihbitmapOLD :=0;
ihbitmap    :=0;

idc         :=0;
icore       :=nil;

ibits       :=32;
iwidth      :=1;
iheight     :=1;
irowsize    :=0;
irows       :=str__new8;

misaiclear(ai);

//defaults
zzadd(self);
setparams2(iwidth,iheight,ibits,true);
end;

destructor twinbmp.destroy;
begin
try
//image
xcreate(false);

if (ifontOLD<>0)  then win____deleteobject(win____selectobject(idc,ifontOLD));
if (ifont<>0)     then win____deleteobject(ifont);

if (ibrushOLD<>0) then win____deleteobject(win____selectobject(idc,ibrushOLD));
if (ibrush<>0)    then win____deleteobject(ibrush);

if (ihbitmap<>0) then win____deleteobject(ihbitmap);
if (idc<>0)      then win____deletedc(idc);

//vars
str__free(@irows);

//self
inherited destroy;
if classnameis('twinbmp') then track__inc(satWinbmp,-1);
except;end;
end;

procedure twinbmp.setwidth(x:longint);
begin
setparams(ibits,x,iheight);
end;

procedure twinbmp.setheight(x:longint);
begin
setparams(ibits,iwidth,x);
end;

procedure twinbmp.setbits(x:longint);
begin
setparams(x,iwidth,iheight);
end;

function twinbmp.bytes:comp;
begin
result:=mult64(iheight,irowsize);
end;

function twinbmp.setparams(dbits,dw,dh:longint):boolean;
begin
result:=setparams2(dbits,dw,dh,false);
end;

function twinbmp.setfont(xfontname:string;xsharp,xbold:boolean;xsize,xcolor,xbackcolor:longint):boolean;
begin
result:=setfont2(xfontname,xsharp,xbold,false,xsize,xcolor,xbackcolor);
end;

function twinbmp.setfont2(xfontname:string;xsharp,xbold,xtransparent:boolean;xsize,xcolor,xbackcolor:longint):boolean;//10oct2025
var
   b:tlogbrush;
   f:tlogfont;
   p:longint;
begin

//pass-thru
result:=true;

//filter
xcolor    :=int24__rgba0(xcolor);
xbackcolor:=int24__rgba0(xbackcolor);

//brush
low__cls(@b,sizeof(b));
b.lbstyle:=0;//solid
b.lbcolor:=xbackcolor;
b.lbhatch:=0;

//font
low__cls(@f,sizeof(f));

//.size
case (xsize>=0) of
true:f.lfHeight:=-win____MulDiv(xsize,system_screenlogpixels,72);
else f.lfHeight:=xsize;
end;//case

//.enforce safe font height range -> values of ~ "-1" can cause fatal error - 04sep2025
case f.lfHeight of
-3..-1 :f.lfHeight:=-4;
0..3   :f.lfHeight:=4;
end;//case

f.lfWidth         :=0;//font mapper chooses
f.lfEscapement    :=0;//straight fonts
f.lfOrientation   :=0;//no rotation
f.lfWeight        :=low__aorb(0,700,xbold);//400=normal, 700=bold
f.lfItalic        :=0;
f.lfUnderline     :=0;
f.lfStrikeOut     :=0;
f.lfCharSet       :=1;//DEFAULT_CHARSET=1, ANSI_CHARSET=0

for p:=1 to frcmax32(low__len(xfontname),1+high(f.lfFaceName)) do f.lfFaceName[p-1]:=char(xfontname[p-1+stroffset]);

f.lfQuality       :=low__aorb(DEFAULT_QUALITY,NONANTIALIASED_QUALITY,xsharp);//10oct2025
f.lfOutPrecision  :=0;//OUT_DEFAULT_PRECIS=0
f.lfClipPrecision :=0;//CLIP_DEFAULT_PRECIS=0
f.lfPitchAndFamily:=0;//DEFAULT_PITCH=0

//free
if (ifontOLD<>0) then win____deleteobject(win____selectobject(idc,ifontOLD));
if (ifont<>0)    then win____deleteobject(ifont);

//create
ifont     :=win____CreateFontIndirect(f);
ifontOLD  :=win____selectobject(idc,ifont);

//free
if (ibrushOLD<>0) then win____deleteobject(win____selectobject(idc,ibrushOLD));
if (ibrush<>0)    then win____deleteobject(ibrush);

//create
ibrush    :=win____CreateBrushIndirect(b);
ibrushOLD :=win____selectobject(idc,ibrush);

//colors
win____SetBkMode(idc, low__aorb(2,1,xtransparent) );//transparent=1, OPAQUE=2
win____SetBkColor(idc,xbackcolor);
win____SetTextColor(idc,xcolor);

end;

{$ifdef gui3}
function twinbmp.fontheight:longint;
begin
result:=wincanvas__textextent(dc,'aH#W!fq').y;
end;
{$endif}

function twinbmp.xcreate(xnew:boolean):boolean;
begin

//pass-thru
result:=true;

//init
if (idc=0) then idc:=win____CreateCompatibleDC(0);

//clean up
if (ihbitmapOLD<>0) then
   begin

   ihbitmap:=win____SelectObject(idc,ihbitmapOLD);
   win____deleteobject(ihbitmap);
   ihbitmap:=0;

   end;

//new
if xnew then
   begin

   ihbitmap     :=win____CreateDIBSection(idc,iinfo,DIB_RGB_COLORS,icore,0,0);
   ihbitmapOLD  :=win____SelectObject(idc,ihbitmap);

   end;

end;

function twinbmp.setparams2(dbits,dw,dh:longint;dforce:boolean):boolean;
var//Note: GDI only goes as far as 24bit, so alpha value for 32bit pixels are not used/persistent
   dy:longint;
begin

//defaults
result:=false;

try

//range
dw:=frcmin32(dw,1);
dh:=frcmin32(dh,1);
if (dbits<>8) and (dbits<>16) and (dbits<>24) and (dbits<>32) then dbits:=32;

//get
if (dw<>iwidth) or (dh<>iheight) or (dbits<>ibits) or dforce then
   begin

   //changed
   result  :=true;

   //init
   win____GdiFlush;

   iwidth  :=dw;
   iheight :=dh;
   ibits   :=dbits;
   irowsize:=mis__rowsize4(dw,dbits);//27may2025

   with iinfo do
   begin
   biSize          :=sizeof(iinfo);
   biWidth         :=iwidth;
   biHeight        :=-iheight;//top-down bitmap
   biPlanes        :=1;
   biBitCount      :=ibits;
   biCompression   :=0;//BI_RGB=0, BI_BITFIELDS=3
   biSizeImage     :=0;//zero OK for uncompressed images
   biXPelsPerMeter :=0;
   biYPelsPerMeter :=0;
   biClrUsed       :=0;//full table for the current bit depth
   biClrImportant  :=0;//all colors in table assumed important
   end;

   //get
   xcreate(true);

   //cache scanlines
   irows.setlen(iheight*sizeof(tpointer));
   irows8 :=irows.core;
   irows15:=irows.core;
   irows16:=irows.core;
   irows24:=irows.core;
   irows32:=irows.core;

   for dy:=0 to (iheight-1) do irows32[dy]:=ptr__shift(icore,dy*irowsize);

   end;

except;end;
end;

function twinbmp.getscanline(sy:longint):pointer;
begin
if (sy<0) then sy:=0 else if (sy>=iheight) then sy:=iheight-1;
result:=irows32[sy];
end;

function twinbmp.copyarea(sa:twinrect;s:hdc):boolean;
begin
result:=copyarea2(sa,sa,s);
end;

function twinbmp.copyarea2(da,sa:twinrect;s:hdc):boolean;
begin
result:=(s<>0) and (dc<>0) and win____StretchBlt(dc,da.left,da.top,da.right-da.left+1,da.bottom-da.top+1,  s,sa.left,sa.top,sa.right-sa.left+1,sa.bottom-sa.top+1,srcCopy);
end;

end.
