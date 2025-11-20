unit lform;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses {$ifdef gui4}sysutils, windows, forms, controls, classes, {$endif} lroot, lwin, lwin2 {$ifdef gui2}, limg, limg2{$endif};
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
//## Library.................. lightweight form and controls (modernised legacy codebase)
//## Version.................. 1.00.772 (+16)
//## Items.................... 11
//## Last Updated ............ 19oct2025, 13oct2025, 12oct2025, 10oct2025, 08oct2025, 05oct2025
//## Lines of Code............ 3,200+
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
//## | tlitestream            | tobject           | 1.00.010  | 05oct2025   | lite version of tstream
//## | tlitehandlestream      | tobject           | 1.00.010  | 05oct2025   | lite version of thandlestream
//## | tlitefilestream        | tobject           | 1.00.015  | 05oct2025   | lite version of tfilestream
//## | tlitewindow            | tobject           | 1.00.080  | 08oct2025   | Base layer for window/form controls - 05oct2025, 31aug2003
//## | tlitebutton            | tlitewindow       | 1.00.030  | 08oct2025   | lite version of tbutton
//## | tliteedit              | tlitewindow       | 1.00.050  | 08oct2025   | lite version of tedit
//## | tlitemenu              | tobject           | 1.00.071  | 12oct2025   | lite version of tpopupmenu - 05oct2025
//## | tliteRichEdit          | tlitewindow       | 1.00.095  | 08oct2025   | lite version of trichedit control - 05oct2025, 12aug2005
//## | tliteform              | tlitewindow       | 1.00.225  | 10oct2025   | lite version of tform - 08oct2025, 05oct2025, 02sep2003
//## | tlitesplash            | tobject           | 1.00.150  | 05oct2025   | lightweight splash/about window -> can run without delphi controls
//## | tpassdialog            | tliteform         | 1.00.050  | 13oct2025   | lightweight password entry dialog box with red shaded background
//## ==========================================================================================================================================================================================================================


const


   ReadError       = $0001;
   WriteError      = $0002;
   NoError         = $0000;

type

   tliteform                     =class;
   tlitewindow                   =class;
   tliteedit                     =class;
   tlitebutton                   =class;
   tlitestream                   =class;
   tonacceptevent                =function(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean of object;

   PEditStreamInfo=^TEditStreamInfo;
   TEditStreamInfo=record
    stream:TLiteStream;
    data:string;
    dataPos:Longint;
    end;

   TEditStreamCallBack=function (dwCookie:Longint;pbBuff:PByte;cb:Longint;var pcb:Longint):Longint;
   TEditStream=record
    dwCookie:Longint;
    dwError:Longint;
    pfnCallback:TEditStreamCallBack;
    end;

   TCharRange = record
    cpMin: Longint;
    cpMax: LongInt;
    end;

{tlitestream}
   tlitestream=class(tobject)
   private
    function getposition: longint;
    procedure setposition(pos: longint);
   protected
    procedure setsize(newsize: longint); virtual;
    function getsize: longint;
   public
    function read(var buffer; count: longint): longint; virtual; abstract;
    function write(const buffer; count: longint): longint; virtual; abstract;
    function seek(offset: longint; origin: word): longint; virtual; abstract;
    function copyfrom(source: tlitestream; count: longint): longint;
    property position: longint read getposition write setposition;
    property size: longint read getsize write setsize;
    function readbuffer(var buffer; count: longint):boolean;
    function writebuffer(const buffer; count: longint):boolean;
   end;

{tlitehandlestream}
   tlitehandlestream=class(tlitestream)
   private

    fhandle:longint;

   protected

    procedure setsize(newsize: longint); override;

   public

    //create
    constructor create(ahandle: longint);
    function read(var buffer; count: longint): longint; override;
    function write(const buffer; count: longint): longint; override;
    function seek(offset: longint; origin: word): longint; override;
    property handle:longint read fhandle;

   end;

{tlitefilestream}
   tlitefilestream=class(tlitehandlestream)
   public

    //create
    constructor create(const filename:string;mode:word);
    destructor destroy; override;

   end;

{tlitewindow}
   tlitewindow=class(tobject)
   private

    iclasscursor   :longint;//0=arrow, 1=text cursor
    ivisible       :boolean;
    ihandle        :hwnd;
    iclasswinproc  :pointer;
    fonclick       :tnotifyevent;
    foncancel      :tnotifyevent;
    fonenter       :tnotifyevent;

    procedure sethandle(x:hwnd);
    function getparent:hwnd;
    procedure setparent(x:hwnd);
    function getvisible:boolean;
    procedure setvisible(x:boolean);
    procedure settext(const x:string);
    function gettext:string;
    function getleft:longint;
    procedure setleft(const x:longint);
    function gettop:longint;
    procedure settop(const x:longint);
    function getwidth:longint;
    procedure setwidth(const x:longint);
    function getheight:longint;
    procedure setheight(const x:longint);
    function getclientwidth:longint;
    procedure setclientwidth(const x:longint);
    function getclientheight:longint;
    procedure setclientheight(const x:longint);
    function getclientrect:twinrect;
    procedure setclientrect(const x:twinrect);
    function getstyle:longint;
    procedure setstyle(const x:longint);
    function getbounds:twinrect;
    procedure xproc(x:tnotifyevent);

   public

    //vars
    tag:longint;
    odemandFullPaints:boolean;

    //create
    constructor create; virtual;
    constructor createclass(xclassname:string;xowner:hwnd); virtual;
    constructor createclass2(xclassname:string;xowner:hwnd;xmoreStyle:longint); virtual;
    destructor destroy; override;

    //handles
    function empty        :boolean;
    property handle       :hwnd         read ihandle            write sethandle;
    property parent       :hwnd         read getparent          write setparent;
    function focused      :boolean;
    procedure setfocus;

    //winproc handling and class handling
    function xwinproc0(h,m,w,l:longint):longint; virtual;//pre-wndproc
    function xwinproc(h,m,w,l:longint):longint; virtual;//main wndproc

    //paint
    function  area:twinrect;
    function  paintarea:twinrect;
    function canpaint:boolean;
    procedure paintnow;
    procedure paintnow2(xforce:boolean);//08oct2025

    //size
    procedure setbounds(const x,y,w,h:longint);
    procedure setboundsrect(x:twinrect);
    property bounds       :twinrect     read getbounds          write setboundsrect;
    property left         :longint      read getleft            write setleft;
    property top          :longint      read gettop             write settop;
    property width        :longint      read getwidth           write setwidth;
    property height       :longint      read getheight          write setheight;
    property clientrect   :twinrect     read getclientrect      write setclientrect;
    property clientwidth  :longint      read getclientwidth     write setclientwidth;
    property clientheight :longint      read getclientheight    write setclientheight;

    //visibility
    procedure show;
    procedure hide;
    property visible      :boolean      read getvisible         write setvisible;
    property style        :longint      read getstyle           write setstyle;
    procedure von;//visible=true

    //text
    property caption      :string       read gettext            write settext;
    property text         :string       read gettext            write settext;

    //events -> not all events available for all controls
    property onclick      :tnotifyevent read fonclick           write fonclick;
    property oncancel     :tnotifyevent read foncancel          write foncancel;
    property onenter      :tnotifyevent read fonenter           write fonenter;

    //support
    function xperform(msg:uint;wparam:wparam;lparam:lparam):lresult;
    procedure defaults;

    //makers
    function npass        :tliteedit;
    function nedit        :tliteedit;
    function nOK          :tlitebutton;
    function nCancel      :tlitebutton;

   end;

{tlitebutton}
   tlitebutton=class(tlitewindow)
   private

    function xwinproc0(h,m,w,l:longint):longint; override;

   public

    constructor createOK(xowner:hwnd);//OK label
    constructor createCancel(xowner:hwnd);//Cancel label
    constructor create(xowner:hwnd);

   end;

{tliteedit}
   tliteedit=class(tlitewindow)
   private

    function xwinproc0(h,m,w,l:longint):longint; override;

   public

    constructor createPassword(xowner:hwnd);
    constructor create(xowner:hwnd);

   end;

{tlitemenu}
   tlitemenu=class(tobject)
   private

    ihandle     :hmenu;
    icode       :array[0..29] of string;
    iid         :array[0..29] of longint;
    iclickcode  :string;
    fonpop      :tnotifyevent;
    foncode     :tnotifyevent;

    function xfindByCode(const xcode:string;var xindex:longint):boolean;
    function xfindCode(xid:longint;var xcode:string):boolean;
    procedure setenabled(xcode:string;xval:boolean);
    procedure setchecked(xcode:string;xval:boolean);
    function xcount:longint;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //values
    procedure add(const xlabel,xcode:string);
    procedure addsep;
    property enabled[xcode:string]    :boolean write setenabled;
    property checked[xcode:string]    :boolean write setchecked;
    property code                     :string  read iclickcode;//set when user selects a menu item

    //show
    procedure popnow(h:hwnd);
    procedure popup(x,y:longint;h:hwnd);

    //events
    property onpop                    :tnotifyevent read fonpop  write fonpop;
    property oncode                   :tnotifyevent read foncode write foncode;

   end;

{tliteRichEdit}
   tliteRichEdit=class(tlitewindow)
   private

    ictrldn       :boolean;
    ictrl         :boolean;
    imenu         :tlitemenu;
    iwordwrap     :boolean;
    fonchange     :tnotifyevent;

    procedure setwordwrap(x:boolean);
    procedure setmaxlength(x:longint);
    procedure setreadonly(x:boolean);
    function xwinproc0(h,m,w,l:longint):longint; override;

   public

    //events
    onESC:tnotifyevent;

    //create
    constructor create(xowner:hwnd); virtual;

   published

    property handle;
    property parent;

    property left;
    property top;
    property width;
    property height;
    property clientwidth;
    property clientheight;
    property clientrect;
    property bounds;

    function cancopytoclipboard:boolean;
    function copytoclipboard(var e:string):boolean;
    property text;
    property visible;
    property maxlength:integer write setmaxlength;
    property wordwrap:boolean read iwordwrap write setwordwrap;
    property menu:tlitemenu read imenu write imenu;
    property readonly:boolean write setreadonly;

    //restrictors - disable "ctrl" key to prevent "ctrl+a and ctrl+c" in locked mode (select all/copy)
    property ctrl:boolean read ictrl write ictrl;

    //io
    function fromfile(const x:string;var e:string):boolean;
    function fromstr(const x:string;var e:string):boolean;//08oct2025
    function fromstream(x:tlitestream;var e:string):boolean;

    function tofile(const x:string;var e:string):boolean;
    function tostr(var x,e:string;xrtfFormat:boolean):boolean;
    function tostream(x:tlitestream;var e:string;xrtfFormat:boolean):boolean;

    //events
    property onchange:tnotifyevent read fonchange write fonchange;

   end;

{tliteform}
   tliteform=class(tlitewindow)
   private

    iwaiting      :boolean;
    ipaintdc      :hdc;
    ipainttrycount:longint;
    ivisible      :boolean;
    imouseinfo:   tmouseinfo;
    ipmouseinfo   :pmouseinfo;
    fonwinproc    :twinproc;
    fonpaint      :tnotifyevent;
    fonclose      :tnotifyevent;
    fonclosequery :tclosequeryevent;
    fonresize     :tnotifyevent;
    fonmousedown  :tmouseevent;
    fonmousemove  :tmousemoveevent;
    fonmouseup    :tmouseevent;
    fonendsession :tnotifyevent;
    fonhalt       :tnotifyevent;
    fonaccept     :tonacceptevent;//18jun2021

    procedure msgxy(x:longint;var rx,ry:integer);
    procedure domouse(x:integer);
    procedure setmousecapture(x:boolean);
    function getmousecapture:boolean;
    property mousecapture:boolean read getmousecapture write setmousecapture;
    procedure xwmacceptfiles(const w:longint);//08oct2025
    procedure setcaption(x:string);
    function xwinproc0(h,m,w,l:longint):longint; override;

   public

    //events
    onesc:tnotifyevent;
    odemandFullPaints:boolean;//default=false=a form with MS controls, true=custom GUI paint with no MS controls

    //create
    constructor createSplash;
    constructor createAbout;
    constructor createPopup;
    constructor createForm(xacceptfiles,xMinMaxButtons:boolean);
    constructor create(dwstyle,dwexstyle:dword;phandle:hwnd;xPartOfGUI:boolean); virtual;
    destructor destroy; override;

    //information
    property caption:string write setcaption;

    //showwait
    procedure stopwait; virtual;
    procedure showwait; virtual;//08oct2025

    //paint
    property paintdc         :hdc                 read ipaintdc;
    procedure paintto(drect:twinrect;sdc:hdc;srect:twinrect;rop:dword);

    //other
    property mouseinfo:pmouseinfo read ipmouseinfo;

    //events
    property onwinproc       :twinproc            read fonwinproc      write fonwinproc;
    property onresize        :tnotifyevent        read fonresize       write fonresize;
    property onpaint         :tnotifyevent        read fonpaint        write fonpaint;
    property onclosequery    :tclosequeryevent    read fonclosequery   write fonclosequery;
    property onmousedown     :tmouseevent         read fonmousedown    write fonmousedown;
    property onmousemove     :tmousemoveevent     read fonmousemove    write fonmousemove;
    property onmouseup       :tmouseevent         read fonmouseup      write fonmouseup;
    property onclose         :tnotifyevent        read fonclose        write fonclose;{main system menu "close"}
    property onendsession    :tnotifyevent        read fonendsession   write fonendsession;{windows shutdown}
    property onhalt          :tnotifyevent        read fonhalt         write fonhalt;{close or windows shutdown}
    property onaccept        :tonacceptevent      read fonaccept       write fonaccept;

   published

    property handle;
    property parent;
    property visible;
    property text;

    property left;
    property top;
    property width;
    property height;
    property clientwidth;
    property clientheight;
    property clientrect;
    property bounds;

   end;


{tlitesplash}
{$ifdef gui2}
  tlitesplash=class(tobject)
  private

   iwaiting:boolean;
   iform:tliteform;
   iimage:twinbmp;

   function winproc(h,m,w,l:longint):lresult;

  public

   //create
   constructor create(ximagedata:pobject;xsplash:boolean); virtual;
   destructor destroy; override;

   //workers
   procedure splash(xsplash,xfadeEffect:boolean);

  end;
{$endif}

{tpassdialog}
  tpassdialog=class(tliteform)
  private

   iedit:tliteedit;
   iok,icancel:tlitebutton;
   iresult:boolean;
   itext:string;

   function xwinproc0(h,m,w,l:longint):longint; override;
   procedure __onclick(sender:tobject);
   procedure __oncancel(sender:tobject);
   procedure __onenter(sender:tobject);
   procedure __onpaint(sender:tobject);

  public

   //create
   constructor create; virtual;
   destructor destroy; override;
   procedure stopwait; override;

   //workers
   function execute(var xpassword:string):boolean;

  end;


//misc procs -------------------------------------------------------------------

procedure dialog__litesplash(const ximagedata:array of byte;xsplash,xfadeEffect:boolean);
procedure dialog__litesplash2(ximagedata:pobject;xsplash,xfadeEffect:boolean);

function form__monitorIndex(x:tobject):longint;
procedure form__centerByCursor(x:tobject);
procedure form__centerByMainForm(x:tobject);
procedure form__center(x:tobject;xmonitorindex:longint);
function form__brstyles(const xindex:longint;var xname,xcode:string):boolean;
procedure form__drawbrstyle(const s:twinbmp;const d:hdc;const cw,ch,xsize,xcolor:longint;const dexcludearea:twinrect;const xstyle:string);//13oct2025


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
function info__lform(xname:string):string;//information specific to this unit of code


implementation

uses lio;


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__lform(xname:string):string;//information specific to this unit of code

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
if not m('lform.') then exit;

//get
if      (xname='ver')        then result:='1.00.1122'
else if (xname='date')       then result:='13oct2025'
else if (xname='name')       then result:='Form'
else
   begin
   //nil
   end;

except;end;
end;


//misc procs -------------------------------------------------------------------

procedure dialog__litesplash(const ximagedata:array of byte;xsplash,xfadeEffect:boolean);
var
   a:tstr8;
begin

//defaults
a    :=nil;

try
//init
a    :=str__new8;
a.aadd(ximagedata);

//get
dialog__litesplash2(@a,xsplash,xfadeEffect);
except;end;

//free
str__free(@a);

end;

procedure dialog__litesplash2(ximagedata:pobject;xsplash,xfadeEffect:boolean);
{$ifdef gui2}
var
   a:tlitesplash;
begin

//defaults
a     :=nil;
try
a     :=tlitesplash.create(ximagedata,xsplash);
a.splash(xsplash,xfadeEffect);
except;end;

//free
freeobj(@a);
end;

{$else}
begin
//nil
end;
{$endif}

function form__monitorIndex(x:tobject):longint;
begin

if      (x=nil)             then result:=monitors__primaryindex
{$ifdef gui4}
else if (x is tform)        then result:=monitors__findBYarea( twinrect((x as tform).clientrect) )
{$endif}
else if (x is tliteform)    then result:=monitors__findBYarea( (x as tliteform).clientrect )
else                             result:=monitors__primaryindex;

end;

procedure form__centerByCursor(x:tobject);
begin
form__center(x, monitors__findBYcursor );
end;

procedure form__centerByMainForm(x:tobject);
begin
form__center(x, monitors__findBYarea( app__mainformArea ) );
end;

procedure form__center(x:tobject;xmonitorindex:longint);
var//note: xfromTop=optional=0=off, 1..N shifts form down from top of upper boundary
   //note: xmonitorindex=-1=off, 0..N=use this for area
   d:twinrect;
   dw,dh:longint;
begin


if      (x=nil) then exit
{$ifdef gui4}
else if (x is tform) then
   begin

   dw:=(x as tform).width;
   dh:=(x as tform).height;

   end
{$endif}
else if (x is tliteform) then
   begin

   dw:=(x as tliteform).width;
   dh:=(x as tliteform).height;

   end;

dw:=frcmin32(dw,1);
dh:=frcmin32(dh,1);

//set
if (xmonitorindex<0) then xmonitorindex:=gui__sysprogram_monitorindex;
d:=monitors__centerINarea_auto(dw,dh,xmonitorindex,true);

{$ifdef gui4}
if (x is tform)     then (x as tform).setbounds(d.left,d.top,d.right-d.left+1,d.bottom-d.top+1);
{$endif}
if (x is tliteform) then (x as tliteform).setbounds(d.left,d.top,d.right-d.left+1,d.bottom-d.top+1);

end;

function form__brstyles(const xindex:longint;var xname,xcode:string):boolean;

   procedure s(const n,c:string);
   begin

   xname   :=n;
   xcode   :=c;
   result  :=(n<>'') and (c<>'');

   end;

begin

case xindex of
0    :s('Flat'         ,'frm.999999');
1    :s('Bend'         ,'bend');
2    :s('Bend 2'       ,'bend2');
3    :s('Gradient'     ,'gradient');
4    :s('Gradient 2'   ,'gradient2');
5    :s('Sleek'        ,'frm.206099|809990');
6    :s('Sleek 2'      ,'frm.206099|709990|208050');
7    :s('Modern'       ,'frm.995099');
8    :s('Modern 2'     ,'frm.999950');
9    :s('Abstract'     ,'frm.100090|303030|997099');
10   :s('Abstract 2'   ,'frm.100090|604530|997099');
11   :s('Old World'    ,'frm.505099|509950');
12   :s('Traditional'  ,'frm.805099|209950');
13   :s('Inverse'      ,'frm.509950|505099');
14   :s('Inverse 2'    ,'frm.409940|204040|404099');
15   :s('Inverse 3'    ,'frm.309940|404040|304099');
16   :s('Edges'        ,'frm.339940|339940|379940');
17   :s('Edges 2'      ,'frm.209940|209940|209940|209940|259940');
18   :s('Formal'       ,'frm.154099|159940|659090|109999');
19   :s('Soft'         ,'frm.108099|109980|759090|109999');
20   :s('Soft 2'       ,'frm.108099|109980|859090');
21   :s('Plain'        ,'frm.959090|109999');
22   :s('Solo'         ,'frm.409090|105099|109950|409090');
23   :s('Solo 2'       ,'frm.105090|509090|105099|109950|409090');
24   :s('Solo 3'       ,'frm.105090|037090|459090|105099|109950|409090');
else  s('','');
end;//case

end;

procedure form__drawbrstyle(const s:twinbmp;const d:hdc;const cw,ch,xsize,xcolor:longint;const dexcludearea:twinrect;const xstyle:string);//13oct2025
label
   skipend;

var
   w,dw,dc0,dc,xpos,dwidth,dsize,sw,sh,p,v,c0,c:longint;
   vs:string;

   procedure da(const dx,dy,dw,dh:longint);
   begin
   win____stretchblt(d,dx,dy,dw,dh,s.dc,dx,dy,dw,dh,srcCopy);
   end;

   function xpullset(var xwidth,xcol,xcol2:longint):boolean;

      function v:longint;
      begin

      result:=frcrange32(strint32(strcopy1(xstyle,xpos,2)),0,99);
      if (result=0) or (result=99) then result:=100;
      inc(xpos,2);

      end;

   begin

   //defaults
   result:=true;

   //start
   if (xpos=1) and strmatch(strcopy1(xstyle,1,4),'frm.') then
      begin

      xpos:=5;

      end;

   //get
   if (xpos<5) then
      begin

      xwidth  :=frcmin32(xsize,1);
      xcol    :=c;
      xcol2   :=c;

      end
   else
      begin

      xwidth  :=frcmin32(trunc(xsize*(v/100)),1);
      xcol    :=int__splice24( v/100 ,0,c);
      xcol2   :=int__splice24( v/100 ,0,c);

      inc(xpos);//1 skip char

      end;

   end;

   procedure dfit;
   begin

   //draw around the exclusion area
   if validarea(dexcludearea) and (misw(s)=cw) and (mish(s)=ch) then
      begin

      //top
      if (dexcludearea.top>0) then da(0,0,cw,dexcludearea.top);

      //bottom
      if (dexcludearea.bottom<(ch-1)) then da(0,dexcludearea.bottom+1,cw,ch-dexcludearea.bottom-1);

      //left
      if (dexcludearea.left>0) then da(0,dexcludearea.top,dexcludearea.left,dexcludearea.bottom-dexcludearea.top+1);

      //right
      if (dexcludearea.right<(cw-1)) then da(dexcludearea.right+1,dexcludearea.top,cw-dexcludearea.right-1,dexcludearea.bottom-dexcludearea.top+1);

      end

   else win____stretchblt(d,0,0,cw,ch,s.dc,0,0,misw(s),mish(s),srcCopy);

   end;

   function m(const x:string):boolean;
   begin
   result:=strmatch(x,xstyle);
   end;

   function mv(const x:string):boolean;
   begin
   result:=strm(xstyle,x,vs,v);
   end;

   procedure bwh;
   begin
   missize(s,cw,ch);
   sw:=misw(s);
   sh:=mish(s);
   end;

   function ba:twinrect;
   begin
   result:=misarea(s);
   end;

   procedure dround(const da:twinrect;c0,c:longint);
   begin
   misclsarea3(s,area__make(da.left,da.top,da.right, da.top+((da.bottom-da.top+1) div 2) ),c0,c,255,255);
   misclsarea3(s,area__make(da.left, da.top+((da.bottom-da.top+1) div 2) ,da.right,da.bottom),c,c0,255,255);
   end;

   procedure dlinear(const da:twinrect;c0,c:longint);
   begin
   misclsarea3(s,da,c0,c,255,255);
   end;

   procedure dframe(da:twinrect;c:longint);
   var
      sr24:pcolorrow24;
      c24:tcolor24;
      dx,dy:longint;
   begin

   //safe range
   da.left   :=frcrange32(da.left     , 0         ,sw-1);
   da.right  :=frcrange32(da.right    , da.left   ,sw-1);
   da.top    :=frcrange32(da.top      , 0         ,sh-1);
   da.bottom :=frcrange32(da.bottom   , da.top    ,sh-1);

   //init
   c24:=int__c24(c);

   //top line
   misscan24(s,da.top,sr24);
   for dx:=da.left to da.right do sr24[dx]:=c24;

   //bottom line
   misscan24(s,da.bottom,sr24);
   for dx:=da.left to da.right do sr24[dx]:=c24;

   //left + right lines
   for dy:=da.top to da.bottom do
   begin

   misscan24(s,dy,sr24);

   sr24[da.left]  :=c24;
   sr24[da.right] :=c24;

   end;//dy

   end;

   procedure mc0(const xround:boolean);
   begin
   c0:=int__splice24( low__aorbD64(0.5,0.2,xround) ,c,0);
   end;

   procedure s2;
   begin
   if (strcopy1(xstyle,low__len(xstyle),1)='2') then low__swapint(c,c0);
   end;

begin

//check
if (s=nil) or (d=0) or (cw<=0) or (ch<=0) then exit;

try
//init
vs          :='';
v           :=0;
c           :=int24__rgba0(xcolor);
c0          :=c;
sw          :=1;
sh          :=1;
xpos        :=1;

//get
if m('bend') or m('bend2') then
   begin
   bwh;
   mc0(true);
   s2;
   dround(ba,c0,c);
   dfit;
   end
else if m('gradient') or m('gradient2') then
   begin
   bwh;
   mc0(false);
   s2;
   dlinear(ba,c,c0);
   dfit;
   end
else if mv('frm.') then
   begin

   //init
   bwh;
   dw:=0;

   //get
   while xpullset(w,dc0,dc) do
   begin

   for p:=0 to (w-1) do
   begin

   dframe( area__make(dw,dw,cw-1-dw,ch-1-dw), int__splice24(p/w,dc0,dc) );
   inc(dw);
   if (dw>=xsize) then break;

   end;//p

   if (dw>=xsize) then break;

   end;//loop

   dfit;

   end
else
   begin

   bwh;
   dlinear(ba,c,c);
   dfit;

   end;

except;end;
end;


//## tlitestream ###############################################################

function tlitestream.getposition: longint;
begin
  result := seek(0, 1);
end;

procedure tlitestream.setposition(pos: longint);
begin
  seek(pos, 0);
end;

function tlitestream.getsize: longint;
var
  pos: longint;
begin
  pos := seek(0, 1);
  result := seek(0, 2);
  seek(pos, 0);
end;

procedure tlitestream.setsize(newsize: longint);
begin
// default = do nothing  (read-only streams, etc)
end;

function tlitestream.readbuffer(var buffer; count: longint):boolean;
begin
try;result:=(count <> 0) and (read(buffer, count) <> count);except;end;
end;

function tlitestream.writebuffer(const buffer; count: longint):boolean;
begin
try;result:=(count <> 0) and (write(buffer, count) <> count);except;end;
end;

function tlitestream.copyfrom(source: tlitestream; count: longint): longint;
const
  maxbufsize = $f000;
var
  bufsize, n: integer;
  buffer: pchar;
begin
  if count = 0 then
  begin
    source.position := 0;
    count := source.getsize;
  end;
  result := count;
  if count > maxbufsize then bufsize := maxbufsize else bufsize := count;
  getmem(buffer, bufsize);
  try
    while count <> 0 do
    begin
      if count > bufsize then n := bufsize else n := count;
      source.readbuffer(buffer^, n);
      writebuffer(buffer^, n);
      dec(count, n);
    end;
  finally
    freemem(buffer, bufsize);
  end;
end;


//## tlitehandlestream #########################################################
constructor tlitehandlestream.create(ahandle:longint);
begin
fhandle:=ahandle;
end;

function tlitehandlestream.read(var buffer; count: longint): longint;
begin
if not win____readfile(fhandle, buffer, count, result, nil) then result:=0;
end;

function tlitehandlestream.write(const buffer; count: longint): longint;
begin
if not win____writefile(fhandle, buffer, count,result,nil) then result:=0;
end;

function tlitehandlestream.seek(offset: longint; origin: word): longint;
begin
result:=win____setfilepointer(fhandle, offset, nil, origin);
end;

procedure tlitehandlestream.setsize(newsize: longint);
begin

seek(newsize,sofrombeginning);
if not win____setendoffile(handle) then
   begin

   win____getlasterror;//flush

   end;

end;

//## tlitefilestream ###########################################################
constructor tlitefilestream.create(const filename:string;mode:word);
const
  AccessMode: array[0..2] of Integer = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of Integer = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin

case (mode=fmcreate) of
true:begin

   fhandle:=win____createfile(pchar(filename), GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

   end;
else begin

   fhandle:=win____CreateFile(PChar(FileName), AccessMode[Mode and 3],ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

   end;
end;//case

end;

destructor tlitefilestream.destroy;
begin
if (fhandle >= 0) then win____closehandle(fhandle);
end;


//## tlitewindow ###############################################################
constructor tlitewindow.create;
begin

//self
inherited create;

//vars
ivisible            :=false;
iclasscursor        :=0;
ihandle             :=0;
iclasswinproc       :=nil;
tag                 :=0;
odemandFullPaints   :=false;
fonclick            :=nil;
foncancel           :=nil;
fonenter            :=nil;

end;

constructor tlitewindow.createclass(xclassname:string;xowner:hwnd);
begin
createclass2(xclassname,xowner,0);
end;

constructor tlitewindow.createclass2(xclassname:string;xowner:hwnd;xmoreStyle:longint);
var
   xstyle:longint;
begin

//self
create;

//need to load the richedit.dll in order to use it - 08oct2025
if (xclassname='richedit') then win____LoadLibraryA(pchar('riched32.dll'));

//class cursor
if (xclassname='edit') or (xclassname='memo') or (xclassname='richedit') then iclasscursor:=1//text -> iBeam
else                                                                          iclasscursor:=0;//arrow

//style -> $8000=flat style
xstyle  :=$8000 or ws_border or ws_child or ws_visible;
if (xmoreStyle<>0) then xstyle:=xstyle or xmoreStyle;

handle  :=win____createwindowex(0,pchar(xclassname),'',xstyle,0,0,0,0,xowner,0,app__hinstance,nil);

//connect winproc and retain class specific winproc - 08oct2025
iclasswinproc :=pointer(win____getwindowlong(handle,gwl_wndproc));
app__addwndproc(handle,xwinproc,false);
win____setwindowlong(handle,gwl_wndproc,longint(@wproc__windowproc));

end;

destructor tlitewindow.destroy;
begin
try

//controls
if (ihandle<>0) then
   begin

   app__delwndproc(ihandle);
   win____destroywindow(ihandle);
   ihandle:=0;

   end;

//self
inherited destroy;

except;end;
end;

procedure tlitewindow.von;
begin
visible:=true;
end;

procedure tlitewindow.xproc(x:tnotifyevent);
begin
if assigned(x) then x(self);
end;

function tlitewindow.xwinproc(h,m,w,l:longint):longint;
begin

//custom handling
result:=xwinproc0(h,m,w,l);
if (result<>0) then exit;

//cursor
case m of
wm_setcursor:if app__usecustomcursor(wm_setcursor,l, low__aorb(system_arrowcursor,system_textcursor,iclasscursor=1) ) then exit;
end;

//root class handler
case (iclasswinproc<>nil) of
true:result:=win____callwindowproc(iclasswinproc,h,m,w,l);
else result:=win____defwindowproc(h,m,w,l);
end;//case

end;

function tlitewindow.xwinproc0(h,m,w,l:longint):longint;
begin

result:=0;

end;

procedure tlitewindow.setfocus;
begin
if not empty then win____SetFocus(handle);
end;

function tlitewindow.canpaint:boolean;
begin
result:=(ihandle<>0) and (not win____isiconic(ihandle)) and win____iswindowvisible(ihandle);
end;

function tlitewindow.area:twinrect;
begin

if win____getwindowrect(ihandle,result) then
   begin

   //convert to zero based area
   dec(result.right);
   dec(result.bottom);

   end
else result:=area__make(0,0,0,0);

end;

function tlitewindow.paintarea:twinrect;
begin

if win____GetClientRect(ihandle,result) then
   begin

   dec(result.right,result.left+1);//zero based
   result.left:=0;

   dec(result.bottom,result.top+1);
   result.top:=0;

   end
else result:=area__make(0,0,0,0);

end;

procedure tlitewindow.paintnow;
begin
paintnow2(false);
end;

procedure tlitewindow.paintnow2(xforce:boolean);//08oct2025
begin

if canpaint then
   begin

   win____InvalidateRect(ihandle,nil,false);

   //force immediate repaint
   if odemandFullPaints or xforce then win____updatewindow(ihandle);

   end;

end;

function tlitewindow.empty:boolean;
begin
result:=(ihandle<=0);
end;

procedure tlitewindow.defaults;
begin

ivisible   :=true;
visible    :=false;

setbounds(0,0,200,200);

text       :='';
tag        :=0;

end;

procedure tlitewindow.sethandle(x:hwnd);
begin

if low__setint(ihandle,x) then
   begin

   //hide
   ivisible:=true;
   visible:=false;

   end;

end;

function tlitewindow.getparent:hwnd;
begin
result:=win____getparent(handle);
end;

procedure tlitewindow.setparent(x:hwnd);
begin
if (not empty) and (x<>parent) then win____setparent(handle,x);
end;

function tlitewindow.getvisible:boolean;
begin
if empty then result:=false else result:=ivisible;
end;

procedure tlitewindow.setvisible(x:boolean);
begin

if low__setbol(ivisible,x) then
   begin

   case x of
   true:win____showwindow(handle,sw_shownormal);
   else win____showwindow(handle,sw_hide);
   end;//case

   end;

end;

procedure tlitewindow.show;
begin
if not visible then visible:=true;
end;

procedure tlitewindow.hide;
begin
if visible then visible:=false;
end;

procedure tlitewindow.settext(const x:string);
begin
if (x<>text) then xperform(wm_settext,0,longint(pchar(x)));
end;

function tlitewindow.gettext:string;
var
   len:longint;
begin

len:=xperform(wm_gettextlength,0,0);
setstring(result,pchar(nil),len);
if (len<>0) then xperform(wm_gettext,len+1,longint(result));

end;

function tlitewindow.xperform(msg:uint;wparam:wparam;lparam:lparam):lresult;
begin
result:=win____sendmessage(handle,msg,wparam,lparam);
end;

procedure tlitewindow.setbounds(const x,y,w,h:longint);
begin
if (not empty) then win____setwindowpos(handle,0,x,y,w,h,0);
end;

procedure tlitewindow.setboundsrect(x:twinrect);
begin
setbounds(x.left,x.top,x.right,x.bottom);
end;

function tlitewindow.getbounds:twinrect;
begin

if (not empty) then
   begin

   win____getwindowrect(handle,result);

   if (parent=0) then exit;

   win____screentoclient(parent,result.topleft);
   win____screentoclient(parent,result.bottomright);

   end;

end;

function tlitewindow.getclientrect:twinrect;
begin

case empty of
true:result:=area__make(0,0,0,0);
else win____getclientrect(handle,result);
end;//case

end;

procedure tlitewindow.setclientrect(const x:twinrect);
var
   a:twinrect;
begin

if (x.right<>clientwidth) or (x.bottom<>clientheight)then
   begin

   a         :=getbounds;
   a.right   :=x.right+(width-clientwidth);
   a.bottom  :=x.bottom+(height-clientheight);

   setbounds(a.left,a.top,a.right,a.bottom);

   end;

end;

function tlitewindow.getclientwidth:longint;
begin
result:=clientrect.right;
end;

procedure tlitewindow.setclientwidth(const x:longint);
var
   a:twinrect;
begin

if (x<>clientwidth) then
   begin

   a         :=getbounds;
   a.right   :=x+(width-clientwidth);
   a.bottom  :=height;

   setbounds(a.left,a.top,a.right,a.bottom);

   end;

end;

function tlitewindow.getclientheight:longint;
begin
result:=clientrect.bottom;
end;

procedure tlitewindow.setclientheight(const x:longint);
var
   a:twinrect;
begin

if (x<>clientheight) then
   begin

   a         :=getbounds;
   a.right   :=width;
   a.bottom  :=x+(height-clientheight);

   setbounds(a.left,a.top,a.right,a.bottom);

   end;

end;

function tlitewindow.getleft:longint;
begin
result:=getbounds.left;
end;

procedure tlitewindow.setleft(const x:longint);
var
   a:twinrect;
begin

if (x<>left) then
   begin
   a       :=getbounds;
   a.left  :=x;

   setbounds(a.left,a.top,a.right,a.bottom);

   end;

end;

function tlitewindow.gettop:longint;
begin
result:=getbounds.top;
end;

procedure tlitewindow.settop(const x:longint);
var
   a:twinrect;
begin

if (x<>top) then
   begin

   a      :=getbounds;
   a.top  :=x;

   setbounds(a.left,a.top,a.right,a.bottom);

   end;

end;

function tlitewindow.getwidth:longint;
begin
result:=getbounds.right-getbounds.left;
end;

procedure tlitewindow.setwidth(const x:longint);
var
   a:twinrect;
begin

if (x<>width) then
   begin

   a         :=getbounds;
   a.right   :=x;
   a.bottom  :=height;

   setbounds(a.left,a.top,a.right,a.bottom);

   end;

end;

function tlitewindow.getheight:longint;
begin
result:=getbounds.bottom-getbounds.top;
end;

procedure tlitewindow.setheight(const x:longint);
var
   a:twinrect;
begin

if (x<>height) then
   begin

   a         :=getbounds;
   a.right   :=width;
   a.bottom  :=x;

   setbounds(a.left,a.top,a.right,a.bottom);

   end;

end;

function tlitewindow.getstyle:longint;
begin
result:=win____getwindowlong(handle,gwl_style);
end;

procedure tlitewindow.setstyle(const x:longint);
begin

if (x<>style) then
   begin

   win____setwindowlong(handle,gwl_style,x);
   win____sendmessage(handle,cm_recreatewnd,0,0);

   end;

end;

function tlitewindow.focused:boolean;
begin
result:=(not empty) and (win____getfocus=handle);
end;

//makers -----------------------------------------------------------------------

function tlitewindow.npass:tliteedit;
begin
result:=tliteedit.createPassword(handle);
end;

function tlitewindow.nedit:tliteedit;
begin
result:=tliteedit.create(handle);
end;

function tlitewindow.nOK:tlitebutton;
begin
result:=tlitebutton.createOK(handle);
end;

function tlitewindow.nCancel:tlitebutton;
begin
result:=tlitebutton.createCancel(handle);
end;


//## tlitemenu #################################################################

constructor tlitemenu.create;
var
   p:longint;
begin

//self
inherited create;

//vars
fonpop      :=nil;
iclickcode  :='';

for p:=0 to high(iid) do
begin

icode[p]    :='';
iid  [p]    :=0;

end;//p

//create
ihandle:=win____createpopupmenu;

end;

destructor tlitemenu.destroy;
begin
try

//controls
if (ihandle<>0) then
   begin

   app__delwndproc(ihandle);
   win____destroymenu(ihandle);
   ihandle:=0;

   end;

//self
inherited destroy;

except;end;
end;

procedure tlitemenu.addsep;
begin
add('-','');
end;

procedure tlitemenu.add(const xlabel,xcode:string);
var
   m:twinmenuiteminfo;
   i:longint;
begin

//get
i               :=xcount;
low__cls(@m,sizeof(m));
m.cbsize        :=sizeof(twinmenuiteminfo);
m.fmask         :=1 or 2 or 8 or $10;//checkmarks, type and data etc
if (xlabel='-') then m.ftype:=m.ftype or mft_separator;
m.wid           :=xcount+10;//avoid zero
m.hsubmenu      :=0;
m.hbmpchecked   :=0;
m.hbmpunchecked :=0;
m.dwtypedata    :=pchar(xlabel);

win____insertmenuitem(ihandle,-1,true,m);

//set
if (i>=0) and (i<=high(iid)) then
   begin

   iid[i]    :=m.wid;
   icode[i]  :=xcode;

   end;

end;

function tlitemenu.xfindCode(xid:longint;var xcode:string):boolean;
var
   p:longint;
begin

//defaults
result :=false;
xcode  :='';

//find
for p:=0 to frcmax32(high(iid),pred(xcount)) do if (xid=iid[p]) then
   begin

   result :=true;
   xcode  :=icode[p];
   break;

   end;

end;

function tlitemenu.xfindByCode(const xcode:string;var xindex:longint):boolean;
var
   i:longint;
begin

//defaults
result :=false;
xindex :=0;

//check
if (xcode='') then exit;

//find
for i:=0 to frcmax32(high(icode),pred(xcount)) do if strmatch(xcode,icode[i]) then
   begin

   result :=true;
   xindex :=i;
   break;

   end;//i

end;

function tlitemenu.xcount:longint;
begin
result:=win____getmenuitemcount(ihandle);//04oct2025
end;

procedure tlitemenu.setenabled(xcode:string;xval:boolean);//08oct2025
var
   v,i:longint;
begin

if xfindByCode(xcode,i) then
   begin

   v:=1024;//1024=by position in the menu
   if not xval then v:=v or 2;

   win____enablemenuitem(ihandle,i,v);

   end;

end;

procedure tlitemenu.setchecked(xcode:string;xval:boolean);//08oct2025
var
   v,i:longint;
begin

if xfindByCode(xcode,i) then
   begin

   v:=1024;//1024=by position in the menu
   if not xval then v:=v or 2;

   win____checkmenuitem(ihandle,i,v);

   end;

end;

procedure tlitemenu.popnow(h:hwnd);
var
   a:tpoint;
begin

win____GetCursorPos(a);
popup(a.x,a.y,h);

end;

procedure tlitemenu.popup(x,y:longint;h:hwnd);
var
   xid:longint;
begin

if assigned(fonpop) then fonpop(self);
xid:=longint( win____trackpopupmenu(ihandle,256,x,y,0,h,nil));//256=return value of item selected by user
if assigned(foncode) and xfindCode(xid,iclickcode) then foncode(self);

end;


//## tlitebutton ###############################################################

constructor tlitebutton.createOK(xowner:hwnd);
begin
create(xowner);
caption:='OK';
end;

constructor tlitebutton.createCancel(xowner:hwnd);
begin
create(xowner);
caption:='Cancel';
end;

constructor tlitebutton.create(xowner:hwnd);
begin

inherited createclass('button',xowner);
win____sendmessage(handle, $00F4, 0, 1);

end;

function tlitebutton.xwinproc0(h,m,w,l:longint):longint;
begin

result:=0;

case m of
wm_lbuttonup,wm_mbuttonup,wm_rbuttonup:xproc(fonclick);
end;//case

end;


//## tliteedit #################################################################

constructor tliteedit.createPassword(xowner:hwnd);
begin

create(xowner);
win____sendmessage(handle, em_setpasswordchar, ssasterisk, 0);

end;

constructor tliteedit.create(xowner:hwnd);
begin

inherited createclass2('edit',xowner,es_autohscroll);

end;

function tliteedit.xwinproc0(h,m,w,l:longint):longint;
begin

result:=0;

case m of
wm_keyup:begin

   case w of
   13:xproc(fonenter);
   27:xproc(foncancel);
   end;//case

   end;
end;//case

end;


//## tliteRichEdit #############################################################

function rtf__streamload(dwcookie:longint;pbbuff:pbyte;cb:longint;var pcb:longint):longint;stdcall;
var
   b:peditstreaminfo;
   buffer,pbuff:pchar;
   streaminfo:peditstreaminfo;
   x:string;
begin

//defaults
result  :=noerror;
b       :=peditstreaminfo(pointer(dwcookie));

try
//init
buffer  :=stralloc(cb + 1);
cb      := cb div 2;
pcb     := 0;
pbuff   := buffer + cb;

//read
try

case (b.stream=nil) of
false:begin

   pcb:=b.stream.read(buffer^,cb);
   if (pcb>0) then
      begin
      pbuff[pcb]:=#0;
      if (pbuff[pcb-1]=#13) then pbuff[pcb-1]:=#0;
      move(buffer^,pbbuff^,pcb);
      end;

      end;
else begin

   x:=strcopy1(b.data,b.datapos,cb);
   pcb:=length(x);
   move(pchar(x)^,pbbuff^,pcb);
   b.datapos:=b.datapos+pcb;{inc}

   end;
end;//case

except;result:=readerror;end;

//free
str__dispose(buffer);

except;end;
end;

function rtf__streamsave(dwcookie:longint;pbbuff:pbyte;cb:longint;var pcb:longint):longint;stdcall;
var
   b:peditstreaminfo;
begin

//defaults
result  :=noerror;
b       :=peditstreaminfo(pointer(dwcookie));

try
//init
pcb     :=0;

case (b.stream=nil) of
false:pcb:=b.stream.write(pchar(pbbuff)^,cb);
true:begin

     b.data:=b.data+copy(pchar(pbbuff),1,cb);//{date: 27-feb-2004}
     pcb:=cb;

     end;
end;//case

except;result:=writeerror;end;
end;

constructor tliterichedit.create(xowner:hwnd);
begin

imenu         :=nil;
ictrldn       :=false;
ictrl         :=true;

inherited createclass2('richedit',xowner,es_multiline or es_autovscroll or ws_vscroll);

end;

procedure tliterichedit.setreadonly(x:boolean);
begin
win____sendmessage(handle,em_setreadonly,longint(x),0);
end;

function tliterichedit.xwinproc0(h,m,w,l:longint):longint;
begin

//defaults
result:=0;

//get
case m of

//onchange
258:if assigned(fonchange) then fonchange(self);

//mouse
wm_lbuttondown,wm_mbuttondown,wm_rbuttondown:begin

   //display menu
   if (m=wm_rbuttondown) and (imenu<>nil) then imenu.popnow(win____GetParent(handle));

   end;
wm_mousemove:begin
   end;
wm_lbuttonup,wm_mbuttonup,wm_rbuttonup:begin
   end;

wm_keyup:begin

   case w of
   17:ictrldn:=false;
   27:xproc(onESC);//08oct2025, 17nov2007
   end;

   end;
wm_keydown:begin

   case w of
   17:ictrldn:=true;
   else begin

      //blockers
      if (ictrldn and (not ictrl)) then
         begin

         case w of
         45,65,67:result:=1;//ban "ctrl+insert(copy)/ctrl+a(select all)/ctrl+c(copy)"
         end;//case

         end;
      end;//begin

   end;//case
   end;

end;//case

end;

procedure tliterichedit.setmaxlength(x:longint);
begin
win____sendmessage(handle,em_exlimittext,0,longint(x));
end;

procedure tliterichedit.setwordwrap(x:boolean);
begin

if (not empty) and (x<>wordwrap) then iwordwrap:=x;//not yet functional//????????

end;

function tliterichedit.cancopytoclipboard:boolean;
var
   a:tcharrange;
begin

//init
a.cpmin:=0;
a.cpmax:=0;
xperform(em_exgetsel,0,longint(@a));

//successful
result:=(a.cpmin>=0) and (a.cpmax>a.cpmin);

end;

function tliterichedit.copytoclipboard(var e:string):boolean;
begin

//defaults
result         :=false;
e              :=gecTaskfailed;
if not cancopytoclipboard then exit;

//get
result:=(0=win____sendmessage(handle,wm_copy,0,0));

end;

{
function tliterichedit.canpastefromclipboard:boolean;
var
   x:integer;
begin
try
//no
result:=false;
//process
x:=sendmessage(handle,em_canpaste,cf_text,0);
if (x=0) then
   begin
   x:=sendmessage(handle,em_canpaste,0,0);
   if (x=0) then exit;
   end;//end of if
//yes
result:=true;
except;end;
end;

{
function tliterichedit.pastefromclipboard:boolean;
var
   x:integer;
begin
try
//error
result:=false;
//check
ierrormessage:=gecunexpectederror;
if not canpastefromclipboard then exit;
//process
x:=sendmessage(handle,em_pastespecial,0,0);//rtf
if (x<>0) then x:=sendmessage(handle,em_pastespecial,cf_text,0);
//successful
result:=(x=0);
except;end;
end;
{}//xxxxxxxxxxxx

function tliterichedit.fromstr(const x:string;var e:string):boolean;//08oct2025
label
     skipend;
var
   editstream:teditstream;
   position:longint;
   streaminfo:teditstreaminfo;
begin

//defaults
result :=false;

try
//init
streaminfo.data     :=x;
streaminfo.datapos  :=1;
streaminfo.stream   :=nil;

with editstream do
begin

dwcookie            :=longint(pointer(@streaminfo));
pfncallback         :=@rtf__streamload;
dwerror             :=0;

end;

//stream rtf by default
win____sendmessage(handle,em_streamin,sf_rtf,longint(@editstream));

//on error -> fallback to plain text
if (editstream.dwerror<>0) then
   begin

   streaminfo.datapos:=1;
   win____sendmessage(handle,em_streamin,sf_text,longint(@editstream));

   end;

//successful
e             :=gecunknownformat;
result        :=(editstream.dwerror=0);

skipend:
except;end;
end;

function tliterichedit.fromstream(x:tlitestream;var e:string):boolean;
label
     skipend;
var
   editstream:teditstream;
   position:longint;
   texttype:longint;
   streaminfo:teditstreaminfo;
   plaint:boolean;
begin

//defaults
result        :=false;
e             :=gecTaskfailed;
if (x=nil) then exit;

try
//init
plaint             :=false;//10oct2025
streaminfo.stream  :=x;

with editstream do
begin

dwcookie           :=longint(pointer(@streaminfo));
pfncallback        :=@rtf__streamload;
dwerror            :=0;

end;

position           :=x.position;

//texttype
case plaint of
true:texttype:=sf_text;
else texttype:=sf_rtf;
end;//case

//stream
win____sendmessage(handle,em_streamin,texttype,longint(@editstream));

//switch formats and try again
if (editstream.dwerror<>0) then
   begin

   plaint:=not plaint;
   case plaint of
   true:texttype:=sf_text;
   else texttype:=sf_rtf;
   end;//case

   x.position:=position;
   win____sendmessage(handle,em_streamin,texttype,longint(@editstream));

   end;

//successful
e             :=gecunknownformat;
result        :=(editstream.dwerror=0);

skipend:
except;end;
end;

function tliterichedit.fromfile(const x:string;var e:string):boolean;
label
     skipend;
var
   a:tlitefilestream;
begin
//defaults
result        :=false;
a             :=nil;
e             :=gecfilenotfound;

try
//check
if not io__fileexists(x) then exit;

//open
e             :=gecfileinuse;
a             :=tlitefilestream.create(x,fmopenread+fmsharedenynone);

//read
result:=fromstream(a,e);

skipend:
except;end;

//free
freeobj(@a);

end;

function tliterichedit.tostr(var x,e:string;xrtfFormat:boolean):boolean;
var
   editstream:teditstream;
   texttype:longint;
   streaminfo:teditstreaminfo;
begin

//defaults
result        :=false;
e             :=gecTaskfailed;

try
//init
x                 :='';
streaminfo.stream :=nil;
streaminfo.data   :='';

with editstream do
begin

dwcookie    :=longint(pointer(@streaminfo));
pfncallback :=@rtf__streamsave;
dwerror     :=0;

end;

//texttype
case xrtfFormat of
true:texttype:=sf_rtf;
else texttype:=sf_text;
end;//case

//get
win____sendmessage(handle,em_streamout,texttype,longint(@editstream));

//successful
result:=(editstream.dwerror=0);
if result then x:=streaminfo.data;

except;end;
end;

function tliterichedit.tostream(x:tlitestream;var e:string;xrtfFormat:boolean):boolean;
label
     skipend;
var
   editstream:teditstream;
   texttype:longint;
   streaminfo:teditstreaminfo;
begin

//defaults
result        :=false;
e             :=gecTaskfailed;
if (x=nil) then exit;

try
//init
streaminfo.stream:=x;

//get
with editstream do
begin

dwcookie     :=longint(pointer(@streaminfo));
pfncallback  :=@rtf__streamsave;
dwerror      :=0;

end;

//texttype
case xrtfFormat of
true:texttype:=sf_rtf;
else texttype:=sf_text;
end;//case

//stream
case (x is tlitefilestream) of
true:e:=gecoutofdiskspace;
else e:=gecoutofmemory;
end;//case

win____sendmessage(handle,em_streamout,texttype,longint(@editstream));

//successful}
result:=(editstream.dwerror=0);

skipend:
except;end;
end;

function tliterichedit.tofile(const x:string;var e:string):boolean;
label
     skipend;
var
   a:tlitefilestream;
begin

//defaults
result        :=false;
a             :=nil;
e             :=gecTaskfailed;

try
//check
if not io__fileexists(x) then goto skipend;

//delete
e             :=gecfileinuse;
if not io__remfile(x) then goto skipend;

//open
e             :=gecbadfilename;
a             :=tlitefilestream.create(x,fmcreate);

//save
if not tostream(a,e,strmatch(io__extractfileext(x),'rtf')) then goto skipend;

//successful
result:=true;

skipend:
except;end;

//free
freeobj(@a);

end;


//## tliteform #################################################################

constructor tliteform.createSplash;
begin
create(ws_popup,ws_ex_controlparent,app__mainformhandle,true);
end;

constructor tliteform.createAbout;
begin
create(WS_SYSMENU or WS_OVERLAPPED,ws_ex_controlparent,app__mainformhandle,true);//tite caption with only the "close" option (no min or max) - 05oct2025
end;

constructor tliteform.createPopup;
begin
create(ws_default,ws_ex_default,0,false);
end;

constructor tliteform.createForm(xacceptfiles,xMinMaxButtons:boolean);
var
   s,s2:longint;
begin

s  :=ws_group or ws_overlapped or ws_caption or ws_thickframe or ws_popup;
s2 :=ws_ex_controlparent;

//WS_TILEDWINDOW => show title caption with min,max and close buttons for the EXE Viewer - 05oct2025
if xMinMaxButtons then s:=s or ws_tiledwindow;

//xacceptfiles
if xacceptfiles   then s2:=s2 or WS_EX_ACCEPTFILES;

//get
create(s,s2,app__mainformhandle,true);

end;

constructor tliteform.create(dwstyle,dwexstyle:dword;phandle:hwnd;xPartOfGUI:boolean);
var
   a:twndclassexa;
   ha:atom;
   da:twinrect;
   i,sw,sh:longint;
begin

//self
inherited create;

//vars
with imouseinfo do
begin

down    :=false;
button  :=mbleft;
shift   :=[];
x       :=0;
y       :=0;
lx      :=0;
ly      :=0;

end;

//default styles
if (dwstyle=-1)            then dwstyle   :=ws_popup or ws_sysmenu or ws_group;
if (dwexstyle=-1)          then dwexstyle :=0;

//other
ipmouseinfo        :=@imouseinfo;
iwaiting           :=false;
tag                :=0;
ihandle            :=0;
ivisible           :=false;
ipainttrycount     :=0;
odemandFullPaints  :=false;//06oct2025

//init
low__cls(@a,sizeof(a));
a.cbsize           :=sizeof(twndclassex);
a.style            :=0;
a.lpfnwndproc      :=@wproc__windowproc;//standard
a.cbclsextra       :=0;
a.cbwndextra       :=0;
a.hinstance        :=app__hinstance;
a.hicon            :=win____loadicon(app__hinstance,'mainicon');
a.hCursor          :=system_arrowcursor;
a.hbrbackground    :=win____getstockobject(gray_brush);;
a.lpszmenuname     :=nil;
a.lpszclassname    :=pchar('liteform');
a.hiconsm          :=0;

//regisitor twndclassex
ha                 :=win____registerclassexA(a);

//borderless frame with taskbar icon/menu/minimizable/restorable}
ihandle            :=win____createwindowex(dwexstyle,pchar('liteform'),'',dwstyle,0,0,100,100,phandle,0,app__hinstance,nil);

//place our form handle on the formlist for message interception
app__addwndproc(ihandle,xwinproc,xPartOfGUI);

//.create message handler if not already active
app__wproc;

//size and center form
i   :=form__monitorindex(self);
da  :=monitors__workarea_auto(i);
sw  :=da.right-da.left+1;
sh  :=da.bottom-da.top+1;
setbounds( sw div 4, sh div 4, sw div 2, sh div 2 );
form__center(self, i);

end;

destructor tliteform.destroy;
begin
try

//self
inherited destroy;

except;end;
end;

function tliteform.xwinproc0(h,m,w,l:longint):longint;
const
   xpaintRetryLimit=10;
var
   a:tcloseaction;
   b:boolean;
   c:tmsgconv;
   ps:tpaintstruct;
   da:twinrect;
   tmpdc:hdc;
   xpaintfull,xmustfull:boolean;

   procedure r1;
   begin
   result:=1;
   end;

begin
try

//defaults
result:=0;

if assigned(fonwinproc) then
   begin

   result:=fonwinproc(h,m,w,l);
   if (result<>0) then exit;

   end;

//get
case m of
wm_command:begin

   xperform(wm_syscommand,w,l);
   r1;

   end;
wm_syscommand:;

//mouse
wm_lbuttondown,wm_mbuttondown,wm_rbuttondown:begin

   if imouseinfo.down then exit;

   imouseinfo.down :=true;
   mousecapture    :=true;

   msgxy(l,imouseinfo.x,imouseinfo.y);

   case m of
   wm_lbuttondown:imouseinfo.button:=mbleft;
   wm_mbuttondown:imouseinfo.button:=mbmiddle;
   wm_rbuttondown:imouseinfo.button:=mbright;
   end;//case

   domouse(lfmdown);

   imouseinfo.lx:=imouseinfo.x;
   imouseinfo.ly:=imouseinfo.y;

   end;
wm_mousemove:begin

   msgxy(l,imouseinfo.x,imouseinfo.y);
   domouse(lfmmove);

   end;
wm_lbuttonup,wm_mbuttonup,wm_rbuttonup:begin

   if not imouseinfo.down then exit;

   msgxy(l,imouseinfo.x,imouseinfo.y);

   domouse(lfmup);

   imouseinfo.lx     :=imouseinfo.x;
   imouseinfo.ly     :=imouseinfo.y;
   mousecapture      :=false;
   imouseinfo.down   :=false;

   end;

//size
wm_sizing:;
wm_size:begin

   if assigned(fonresize) then fonresize(self);
   paintnow;

   end;

//paint
wm_paint:begin

   //init
   tmpdc          :=win____beginpaint(handle,ps);
   xmustfull      :=false;

   //get
   ipaintdc       :=tmpdc;
   da             :=paintarea;

   case odemandFullPaints of
   true:xpaintfull :=(ipainttrycount>=xpaintRetryLimit) or ((ps.rcPaint.left<=da.left) and (ps.rcPaint.top<=da.top) and (ps.rcPaint.right>=(1+da.right)) and (ps.rcPaint.bottom>=(1+da.bottom)));
   else xpaintfull :=true;//disables full paint checking
   end;//case


   if (clientwidth>=1) and (clientheight>=1) then
      begin

      if assigned(fonpaint) then fonpaint(self)

      end;

   //set
   win____endpaint(handle,ps);
   if (ipaintdc=tmpdc) then ipaintdc:=0;

   //attempt to force a full repaint of entire form - 05oct2025
   case (not xpaintfull) and xmustfull of
   true:begin

      if (ipainttrycount<xpaintRetryLimit) then
         begin

         inc(ipainttrycount);
         paintnow;

         end;

      end;
   else ipainttrycount:=0;//reset
   end;//case

   r1;

   end;

//close / destroy
wm_queryendsession:begin

   b:=lroot_canclose;
   if assigned(fonclosequery) then fonclosequery(self,b);
   result:=longint(b);

   end;
wm_endsession:begin

   if assigned(fonendsession) then fonendsession(self);
   if assigned(fonhalt) then fonhalt(self);
   r1;

   end;
wm_close:begin

   xproc(fonclose);
   xproc(fonhalt);
   r1;

   end;
wm_destroy:;
wm_keyup:begin

   //??????????????????????if (w=27) then xproc(onsec);

   end;

wm_erasebkgnd:r1;

wm_dropfiles:begin

   xwmacceptfiles(w);
   r1;

   end;

end;//case

except;end;
end;

procedure tliteform.stopwait;
begin
iwaiting:=false;
end;

procedure tliteform.showwait;//08oct2025
begin

form__centerByCursor(self);
show;
app__makemodal(handle,true);

//wait -> absorb any lingering keystrokes or mouse events - 05oct2025
app__processallmessages;
iwaiting     :=true;

while true do
begin

if not iwaiting then break;
app__processmessages;
win____sleep(50);

end;//loop

//hide
app__makemodal(handle,false);
win____ShowWindow( handle, sw_hide );

end;

procedure tliteform.setmousecapture(x:boolean);
begin
if (mousecapture<>x) then app__setcapturehwnd( insint(ihandle,x) );
end;

function tliteform.getmousecapture:boolean;
begin
result:=(system_capturehwnd=ihandle);
end;

procedure tliteform.domouse(x:integer);
begin

case x of
lfmdown :if assigned(fonmousedown) then fonmousedown(self,imouseinfo.button,  imouseinfo.shift,  imouseinfo.x, imouseinfo.y);
lfmmove :if assigned(fonmousemove) then fonmousemove(self,imouseinfo.shift,   imouseinfo.x,      imouseinfo.y              );
lfmup   :if assigned(fonmouseup)   then fonmouseup  (self,imouseinfo.button,  imouseinfo.shift,  imouseinfo.x, imouseinfo.y);
end;//case

end;

procedure tliteform.setcaption(x:string);
begin
if (ihandle<>0) then win____setwindowtext(ihandle,pchar(x));
end;

procedure tliteform.xwmacceptfiles(const w:longint);//08oct2025
const
   flimit=1024;
var
   p,count:longint;
   f:array [0..flimit] of char;
   ffolder,fstr:string;
begin
try

//init
fillchar(f,sizeof(f),#0);//23APR2011

//find out how many files we're accepting
count:=win____dragqueryfile(w,-1,f,flimit);

//query Windows one at a time for the file name
for p:=0 to (count-1) do
begin

//check
if not app__running then break;

//.start
win____dragqueryfile(w,p,f,flimit);

//.filename
fstr:=fromnullstr(@f,sizeof(f));

//.foldername
case io__folderexists(fstr) of
true:begin//dropped item is a folder

   ffolder:=io__asfolder(fstr);
   fstr:=ffolder;//ensure supplied filename is converted to a folder - 24APR2011

   end;
else ffolder:=io__asfolder(io__extractfilepath(fstr));//dropped item is a file
end;//case

//.set
case assigned(fonaccept) of
true:if not fonaccept(self,ffolder,fstr,p,count) then break;
else break;
end;//case

end;

except;end;

//let Windows know that we're done
win____dragfinish(w);

end;


procedure tliteform.msgxy(x:longint;var rx,ry:integer);
var
   a:tmsgconv;
begin

a.lparam   :=x;
rx         :=a.lparamlo;
ry         :=a.lparamhi;

end;

procedure tliteform.paintto(drect:twinrect;sdc:hdc;srect:twinrect;rop:dword);
var
   tmpdc:hdc;
   newdc:boolean;
begin
try

//init
tmpdc  :=ipaintdc;
newdc  :=false;

if (tmpdc=0) then
   begin

   tmpdc:=win____getdc(handle);
   newdc:=true;

   end;

//get
win____stretchblt(tmpdc,drect.left,drect.top,drect.right,drect.bottom,sdc,srect.left,srect.top,srect.right,srect.bottom,rop);

except;end;

//free paint dc
if newdc then win____releasedc(handle,tmpdc);

end;


//## tlitesplash ###############################################################
{$ifdef gui2}
constructor tlitesplash.create(ximagedata:pobject;xsplash:boolean);
var
   e:string;
begin

//self
inherited create;

//vars
iwaiting                      :=false;

case xsplash of
true:iform  :=tliteform.createSplash;
else iform  :=tliteform.createAbout;
end;//case

try

iimage                        :=miswin32(1,1);
png__fromdata(iimage,ximagedata,e);

except;end;

//events
iform.onwinproc:=winproc;

end;

destructor tlitesplash.destroy;
begin
try

//controls
freeobj(@iform);
freeobj(@iimage);

//self
inherited destroy;

except;end;
end;

procedure tlitesplash.splash(xsplash,xfadeEffect:boolean);
const
   xSplashDelay  =1000;
   xFadeLimit    =20;
var
   xref:comp;
   sbits,sw,sh,p:longint;
begin
try

//check
if (not misok82432(iimage,sbits,sw,sh)) or (sw<=2) or (sh<=2) then exit;

//init
xfadeEffect  :=xfadeEffect and app__cansetwindowalpha;

//center
iform.clientwidth  :=misw(iimage);
iform.clientheight :=mish(iimage);
iform.caption      :=translate('About');
form__centerByCursor(iform);

//show
if xfadeEffect and (not xsplash) then
   begin

   //shrink form -> show -> hide to avoid initial full clientarea being momentarily visible even when alpha is set to 0
   iform.width:=1;
   iform.height:=1;
   iform.show;
   app__setwindowalpha(iform.handle,0);
   iform.hide;

   end;

if xfadeEffect then app__setwindowalpha(iform.handle,0);
iform.clientwidth:=misw(iimage);
iform.clientheight:=mish(iimage);
iform.show;
app__makemodal(iform.handle,true);

//fade in
if xfadeEffect then
   begin

   for p:=1 to xFadeLimit do
   begin
   app__setwindowalpha(iform.handle,p*(255 div xFadeLimit));
   app__processallmessages;
   win____sleep(15);
   end;//p

   app__setwindowalpha(iform.handle,255);

   end;

//wait -> absorb any lingering keystrokes or mouse events - 05oct2025
app__processallmessages;
iwaiting     :=true;
xref         :=add64(ms64,xSplashDelay);

while true do
begin

if xsplash and (ms64>=xref) then break;
if not iwaiting             then break;

app__processmessages;
win____sleep(50);

end;//loop

//hide
app__makemodal(iform.handle,false);
win____ShowWindow( iform.handle, sw_hide );

except;end;
end;

function tlitesplash.winproc(h,m,w,l:longint):lresult;
var
   dc:tbasic_handle;
   ps:tpaintstruct;

   procedure r1;
   begin
   result:=1;
   end;

begin

result:=0;

case m of

wm_paint:begin

   //check
   if (h=0) then exit;

   //check #2
   if win____isiconic(h) or (not win____iswindowvisible(h)) then
      begin
      win____beginpaint(h,ps);
      win____endpaint(h,ps);
      exit;
      end;

   //paint
   dc:=win____beginpaint(h,ps);

   win____StretchBlt(dc,0,0,misw(iimage),mish(iimage),  iimage.dc,0,0,misw(iimage),mish(iimage),srcCopy);

   //stop
   win____endpaint(h,ps);

   //handled
   r1;

   end;

//.mouse down events -> prevents previous double click action from prematurely closing the about window
wm_lbuttondown,wm_mbuttondown,wm_rbuttondown:iwaiting:=false;

wm_close:begin

   iwaiting:=false;
   r1;

   end;

wm_keyup:begin

   case w of
   27:begin

      iwaiting:=false;
      r1;

      end;
   end;

   end;
end;//case

end;
{$endif}


//## tpassdialog ###############################################################

constructor tpassdialog.create;
const
   vpad=10;
   hpad=20;
var
   w:longint;
begin

//self
inherited createAbout;

//controls
iedit        :=npass;
iok          :=nok;
icancel      :=ncancel;

//size
clientwidth  :=400;
text         :='Password Required';

iedit.setbounds(hpad,2*vpad,clientwidth-(2*hpad),vpad+20);
iedit.von;

w            :=90;
iok.setbounds(iedit.left+iedit.width-w,iedit.top+iedit.height+vpad,w,32);
iok.von;

clientheight :=iok.top+iok.height+vpad;

w            :=iok.width;
icancel.setbounds(iok.left-w-20,iok.top,w,iok.height);
icancel.von;

//events
iok.onclick       :=__onclick;
icancel.onclick   :=__onclick;
iedit.oncancel    :=__oncancel;
iedit.onenter     :=__onenter;
onpaint           :=__onpaint;

end;

destructor tpassdialog.destroy;
begin
try

//controls
freeobj(@iedit);
freeobj(@icancel);
freeobj(@iok);

//self
inherited destroy;

except;end;
end;

function tpassdialog.xwinproc0(h,m,w,l:longint):longint;

   procedure r1;
   begin
   result:=1;
   end;

begin

//defaults
result:=0;

//get
case m of
wm_keyup:if (w=27) then
   begin

   stopwait;
   r1;

   end;

wm_close:begin

   stopwait;
   r1;

   end;

end;//case

//fallback
if (result=0) then inherited xwinproc0(h,m,w,l);

end;

procedure tpassdialog.stopwait;
begin
itext:=iedit.text;//fetch text before closing window -> once window closes, text is lost - 08oct2025
inherited stopwait;
end;

procedure tpassdialog.__oncancel(sender:tobject);
begin
__onclick(icancel);
end;

procedure tpassdialog.__onenter(sender:tobject);
begin
__onclick(iok);
end;

procedure tpassdialog.__onclick(sender:tobject);
begin

if (sender=iok) or (sender=icancel) then
   begin

   iresult:=(sender=iok);
   stopwait;

   end;

end;

function tpassdialog.execute(var xpassword:string):boolean;
begin

//init
iresult      :=false;
iedit.text   :=xpassword;
itext        :=xpassword;
iedit.setfocus;

//prompt for input
showwait;

//get
result  :=iresult;
if result then xpassword:=itext;

end;

procedure tpassdialog.__onpaint(sender:tobject);//draw red shaded background
var
   a:twinbmp;
   cw,ch:longint;
begin

//defaults
a     :=nil;

try
//init
cw    :=clientwidth;
ch    :=clientheight;
a     :=miswin24(4,ch);

//draw
misclsarea3(a,area__make(0,0,cw-1,ch div 2),180,255,255,255);
misclsarea3(a,area__make(0,ch div 2,cw-1,ch-1),255,180,255,255);

//paint
win____stretchblt(paintdc,0,0,clientwidth,clientheight,a.dc,0,0,misw(a),mish(a),srcCopy);

except;end;

//free
freeobj(@a);

end;

end.
