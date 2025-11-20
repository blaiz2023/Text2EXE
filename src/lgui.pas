unit lgui;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses messages, windows, classes, forms, menus, graphics, controls, comctrls, stdctrls, extctrls, lwin, lwin2, lroot, lform, limg, lio;
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
//## Library.................. GUI (some advanced procs require compiler directive GUI4) (modernised legacy codebase)
//## Version.................. 1.00.790 (+30)
//## Items.................... 9
//## Last Updated ............ 12oct2025, 09oct2025, 03oct2025
//## Lines of Code............ 3,700+
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
//## | tappsettings           | tobject           | 1.00.030  | 09oct2025   | simple app settings handler with inbuilt io
//## | tgenericmainmenu       | tmainmenu         | 1.00.050  | 12oct2025   | code based version of tmainmenu - 03oct2025
//## | tgenericlist           | tobject           | 1.00.060  | 12oct2025   | code based list support for multi-item controls -> e.g. visible, enabled, tep(image) etc
//## | tgenericcontrol        | tcustomcontrol    | 1.00.090  | 12oct2025   | control base class
//## | tgenericstatus         | tgenericcontrol   | 1.00.030  | 12oct2025   | flicker free status bar - 03oct2025
//## | tgenerictoolbar        | tgenericcontrol   | 2.00.270  | 12oct2025   | toolbar with TEP (text picture image support) - 09oct2025, 05oct2025, 14nov2003
//## | tgenericgui            | tgenericcontrol   | 1.00.060  | 12oct2025   | lightweight interactive gui
//## | tgenericguiform        | tform             | 1.00.010  | 12oct2025   | lightwieght interactive gui on a form
//## | tsplash                | tobject           | 1.00.160  | 05oct2025   | simple splash/about window with text info
//## ==========================================================================================================================================================================================================================

type
  tcmdevent     =procedure(sender:tobject;const xcode:string) of object;
  tmouseevent   =procedure(sender:tobject) of object;

{tappsettings}
//6666666666666666666666666666666666
  tappsettings=class(tobject)
  private

   icore:tfastvars;
   idef :tfastvars;
   imodified:boolean;

   function gets(xname:string):string;
   procedure sets(xname,xval:string);
   function getb(xname:string):boolean;
   procedure setb(xname:string;xval:boolean);
   function geti(xname:string):longint;
   procedure seti(xname:string;xval:longint);
   function getds(xname:string):string;
   procedure setds(xname,xval:string);
   function getdb(xname:string):boolean;
   procedure setdb(xname:string;xval:boolean);
   function getdi(xname:string):longint;
   procedure setdi(xname:string;xval:longint);
   function geth(xname:string):boolean;//have value

  public

   //create
   constructor create; virtual;
   destructor destroy; override;

   //information
   property modified          :boolean     read imodified;

   //values
   property ds[xname:string]  :string      read getds     write setds;//default value when "s[xname]=nil"
   property db[xname:string]  :boolean     read getdb     write setdb;
   property di[xname:string]  :longint     read getdi     write setdi;

   property s[xname:string]   :string      read gets      write sets;
   property b[xname:string]   :boolean     read getb      write setb;
   property i[xname:string]   :longint     read geti      write seti;

   property h[xname:string]   :boolean     read geth;//have value

   //io
   function filename:string;
   function load:boolean;
   function save:boolean;
   procedure autosave;

  end;

{ttopmenu}
//5555555555555555555555555555555555

  tgenericmainmenu=class(tmainmenu)
  private

   icode        :array[0..199] of string;
   itop         :array[0..199] of boolean;
   icodecount   :longint;
   foncmd       :tcmdevent;

   function xnewcode:longint;
   procedure xonclick(sender:tobject);
   function xfindbycode(const xcode:string;var m:tmenuitem):boolean;
   function xfindbycode2(const xcode:string;var m:tmenuitem;var mtop:boolean):boolean;
   function getenabled(xcode:string):boolean;
   procedure setenabled(xcode:string;xval:boolean);
   function getchecked(xcode:string):boolean;
   procedure setchecked(xcode:string;xval:boolean);
   function gettop(xcode:string):boolean;
   procedure settopenabled(x:boolean);
   function gettopenabled:boolean;

  public

   //create
   constructor create(aowner:tcomponent); override;
   destructor destroy; override;
   function xsysitem(const xcode:string):boolean; virtual;

   //workers
   procedure addtop(const xcaption,xcode:string);
   procedure addtop2(const xcaption,xcode,xshortcut:string);
   procedure add(const xcaption,xcode:string);
   procedure add2(const xcaption,xcode,xshortcut:string);
   procedure tadd(const xcaption:string);
   procedure addsep;

   //values
   property enabled[xcode:string]   :boolean     read getenabled       write setenabled;
   property checked[xcode:string]   :boolean     read getchecked       write setchecked;
   property top[xcode:string]       :boolean     read gettop;
   property topenabled              :boolean     read gettopenabled    write settopenabled;

   //special system menus
   procedure xaddHelp;//12oct2025

   //events
   property oncmd                   :tcmdevent   read foncmd           write foncmd;

  end;

{tgenericlist}
//xxxxxxxxxxxxxxxxxxxxxxxx//lllllllllllllllllllllllll
   pgenericlistitem=^tgenericlistitem;
   tgenericlistitem=record

    code     :string;
    caption  :string;
    help     :string;
    tep      :string;
    visible  :boolean;
    enabled  :boolean;
    marked   :boolean;
    flash    :boolean;
    pert100  :longint;//used panel as a progress bar
    align    :longint;//0=left, 1=center, 2=right
    img      :tbasicimage;//03oct2025
    tag      :longint;
    oa       :twinrect;//outer area
    ia       :twinrect;//inner area
    width    :longint;
    str1     :string;
    val1     :longint

    end;

   tgenericlist=class(tobject)
   private

    icore        :array[0..59] of tgenericlistitem;
    icount       :longint;
    ichangeid    :longint;
    iitemindex   :longint;
    isepcode     :string;
    inilcode     :string;

    function getitem(xindex:longint):pgenericlistitem;

    function getvisible(xcode:string):boolean;
    procedure setvisible(xcode:string;xval:boolean);
    function getenabled(xcode:string):boolean;
    procedure setenabled(xcode:string;xval:boolean);
    function gettag(xcode:string):longint;
    procedure settag(xcode:string;xval:longint);
    function getalign(xcode:string):longint;
    procedure setalign(xcode:string;xval:longint);
    function getpert100(xcode:string):longint;
    procedure setpert100(xcode:string;xval:longint);
    function getmarked(xcode:string):boolean;
    procedure setmarked(xcode:string;xval:boolean);
    function getflash(xcode:string):boolean;
    procedure setflash(xcode:string;xval:boolean);
    function getcaption(xcode:string):string;
    procedure setcaption(xcode,xval:string);
    function gethelp(xcode:string):string;
    procedure sethelp(xcode,xval:string);
    function gettep(xcode:string):string;
    procedure settep(xcode,xval:string);
    procedure setitemindex(xindex:longint);

    function xfindbycode(const xcode:string;var xindex:longint):boolean;
    procedure xsettep(x:tbasicimage;const y:string);
    function xitemheight:longint;
    function xissep(const xindex:longint):boolean;
    function xcancmd(const xindex:longint):boolean;
    procedure xclearitem(var x:tgenericlistitem);
    function getitemcode:string;
    procedure setitemcode(xcode:string);
    procedure xchange;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;

    //information
    property count                        :longint            read icount;
    property items[xindex:longint]        :pgenericlistitem   read getitem;
    property itemcode                     :string             read getitemcode       write setitemcode;
    property itemindex                    :longint            read iitemindex        write setitemindex;
    function haveflash                    :boolean;

    //changed
    property changeid                     :longint            read ichangeid;
    procedure change;

    //add
    function add(const xcode,xcaption,xtep,xhelp:string):boolean;
    function add2(const xcode,xcaption:string;const xtea:array of byte;const xhelp:string):boolean;
    function addsep:boolean;

    //clear
    procedure clear;
    procedure Softclear;

    //findcode
    function findcode(const sx,sy:longint;var xcode:string):boolean;
    function findcodeb(const sx,sy:longint):string;

    //findindex
    function findindex(const sx,sy:longint;var xindex:longint):boolean;
    function findindexb(const sx,sy:longint):longint;


    //items
    property caption [xcode:string]        :string             read getcaption       write setcaption;
    property help    [xcode:string]        :string             read gethelp          write sethelp;
    property tep     [xcode:string]        :string             read gettep           write settep;
    property visible [xcode:string]        :boolean            read getvisible       write setvisible;
    property enabled [xcode:string]        :boolean            read getenabled       write setenabled;
    property marked  [xcode:string]        :boolean            read getmarked        write setmarked;
    property flash   [xcode:string]        :boolean            read getflash         write setflash;
    property pert100 [xcode:string]        :longint            read getpert100       write setpert100;
    property align   [xcode:string]        :longint            read getalign         write setalign;
    property tag     [xcode:string]        :longint            read gettag           write settag;

   end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//ccccccccccccccccccccccccccccc
{tgenericcontrol}
  tgenericcontrolinfo=record

     //core colors
     backcolor :longint;
     tintcolor :longint;

     //calculated colors
     tint      :longint;
     back      :longint;
     back0     :longint;

     text      :longint;
     textDis   :longint;
     hover     :longint;
     hover0    :longint;
     pert      :longint;
     pert0     :longint;
     mark      :longint;
     mark0     :longint;
     sep       :longint;
     sep0      :longint;
     line      :longint;
     line0     :longint;

     //font
     fontname  :string[50];
     fontsize  :longint;

     //support
     refcol    :longint;
     dark      :boolean;

     end;

  tgenericcontrol=class(tcustomcontrol)
  private

   icreated         :boolean;
   ibuffer          :twinbmp;//created on-the-fly when required
   ivscale          :single;
   ihscale          :single;
   ivpad            :longint;
   ihpad            :longint;
   ichangeid        :longint;

   imousedown       :boolean;
   imousedownstroke :boolean;
   imouseupstroke   :boolean;
   imousedownxy     :tpoint;
   imousemovexy     :tpoint;
   imousebutton     :longint;
   imousedragging   :boolean;

   ipaintref        :string;
   istart_owner     :tcomponent;

   foncmd           :tcmdevent;
   fonmouse         :tmouseevent;
   fonpaint         :tnotifyevent;

   function getvisible:boolean; virtual;
   procedure setvisible(x:boolean); virtual;
   function getenabled:boolean; virtual;
   procedure setenabled(x:boolean); virtual;
   function getleft:longint; virtual;
   procedure setleft(x:longint); virtual;
   function gettop:longint; virtual;
   procedure settop(x:longint); virtual;
   function getheight:longint; virtual;
   procedure setheight(x:longint); virtual;
   function getwidth:longint; virtual;
   procedure setwidth(x:longint); virtual;
   procedure setvscale(x:single); virtual;
   procedure sethscale(x:single); virtual;

   function getclientrect:trect; override;
   procedure setclientrect(x:trect); virtual;

   procedure wmerasebkgnd(var message: twmerasebkgnd); message wm_erasebkgnd;
   procedure wmmousemove(var message: twmmousemove); message wm_mousemove;
   procedure wmlbuttondn(var message: twmlbuttondown); message wm_lbuttondown;
   procedure wmlbuttonup(var message: twmlbuttonup); message wm_lbuttonup;
   function getbackcolor:longint; virtual;
   procedure setbackcolor(xcolor:longint); virtual;
   function gettintcolor:longint; virtual;
   procedure settintcolor(xcolor:longint); virtual;
   function getbuffer:twinbmp; virtual;
   procedure xinfocalc; virtual;
   procedure xshowhint(const x:string);

  public

   //info
   info:tgenericcontrolinfo;

   //create
   constructor create(xowner:tcomponent); override;
   procedure xcreate(xowner:tcomponent); virtual;
   procedure createfinish(const xstartTimer:boolean); virtual;
   destructor destroy; override;
   procedure xdestroy; virtual;
   procedure xstoptimer; virtual;
   procedure xfiltersize(var xnewwidth,xnewheight:longint); virtual;
   function xhaveflash:boolean; virtual;

   //paint
   function canpaint:boolean; virtual;
   procedure paintnow; virtual;
   procedure paint; override;//10oct2025
   function paintref:string; virtual;
   function mustpaint:boolean; virtual;
   function mustpaint2(const xreset:boolean):boolean; virtual;
   procedure _ontimer(sender:tobject); virtual;

   //paint buffer
   function havebuffer:boolean;
   function needbuffer:twinbmp;
   function needbuffer2(xsize:boolean):twinbmp;
   procedure freebuffer;
   property buffer                        :twinbmp      read getbuffer;

   //change
   procedure change; virtual;
   function changeid:longint; virtual;//internal for control
   function changeid2:longint; virtual;//external -> e.g. tgenericlist.changeid

   //mouse support
   function xcandrag:boolean; virtual;
   procedure xmousedn; virtual;
   procedure xmousemove; virtual;
   procedure xmouseup; virtual;
   procedure xmouseoff; virtual;
   property mousedown                     :boolean      read imousedown;
   property mousedownstroke               :boolean      read imousedownstroke;
   property mouseupstroke                 :boolean      read imouseupstroke;
   property mousedownxy                   :tpoint       read imousedownxy;
   property mousemovexy                   :tpoint       read imousemovexy;
   property mousebutton                   :longint      read imousebutton;
   property mousedragging                 :boolean      read imousedragging;
   
  published

   //size
   property align;
   property parent;
   property vscale                        :single       read ivscale          write setvscale;
   property hscale                        :single       read ihscale          write sethscale;
   property left                          :longint      read getleft          write setleft;
   property top                           :longint      read gettop           write settop;
   property height                        :longint      read getheight        write setheight;
   property width                         :longint      read getwidth         write setwidth;
   property clientrect                    :trect        read getclientrect    write setclientrect;
   procedure setbounds(xleft,xtop,xwidth,xheight:longint); override;

   //visual
   property visible                       :boolean      read getvisible       write setvisible;
   property enabled                       :boolean      read getenabled       write setenabled;

   property backcolor                     :longint      read getbackcolor     write setbackcolor;
   property tintcolor                     :longint      read gettintcolor     write settintcolor;

   //events
   property oncmd                         :tcmdevent    read foncmd            write foncmd;
   property onmouse                       :tmouseevent  read fonmouse          write fonmouse;
   property onpaint                       :tnotifyevent read fonpaint          write fonpaint;
  end;

{tgenericstatus}
  tgenericstatus=class(tgenericcontrol)
  private

   ilist         :tgenericlist;
   itext         :string;//displayed after any or all items
   itextalign    :longint;

   procedure settext(x:string);
   procedure setitextalign(xval:longint);
   procedure xmousemove; override;
   procedure xmouseup; override;

  public

   //create
   procedure xcreate(xowner:tcomponent); override;
   procedure xdestroy; override;
   procedure paint; override;//12oct2025
   procedure _ontimer(sender:tobject); override;
   function changeid2:longint; override;
   procedure xfiltersize(var xnewwidth,xnewheight:longint); override;
   function xhaveflash:boolean; override;

  published

   //list
   property list                          :tgenericlist read ilist;
   property l                             :tgenericlist read ilist;
   property text                          :string       read itext             write settext;
   property textalign                     :longint      read itextalign        write setitextalign;

   //add
   function add(const xwidth:longint;const xcaption,xcode,xhelp:string):boolean;

   //events
   property oncmd;

  end;

{tgenerictoolbar}
  tgenerictoolbar=class(tgenericcontrol)
  private

   ilist           :tgenericlist;
   ivspace         :longint;
   ihspace         :longint;
   iminitemwidth   :longint;

   procedure setminitemwidth(x:longint);

  public

   //create
   procedure xcreate(xowner:tcomponent); override;
   procedure xdestroy; override;
   function paintref:string; override;
   procedure paint; override;
   procedure _ontimer(sender:tobject); override;
   function xcandrag:boolean; override;
   procedure xmousedn; override;
   procedure xmousemove; override;
   procedure xmouseup; override;
   procedure xfiltersize(var xnewwidth,xnewheight:longint); override;
   function xhaveflash:boolean; override;
   function changeid2:longint; override;//19oct2025

   //list
   property list                          :tgenericlist read ilist;
   property l                             :tgenericlist read ilist;
   property minitemwidth                  :longint      read iminitemwidth    write setminitemwidth;

   function add(const xcode,xtep,xhelp:string):boolean;
   function add2(const xcode:string;const xtea:array of byte;const xhelp:string):boolean;
   function addsep:boolean;

   //events
   property oncmd;

  end;

{tgenericgui}
//xxxxxxxxxxxxxxxxxxx//iiiiiiiiiiiiiiiiiiiiii//????????????????????
  tgenericgui=class(tgenericcontrol)
  private

   ilist              :tgenericlist;
   iwrapwidth         :longint;//for buttons
   icontentwidth      :longint;
   icontentheight     :longint;
   ihoverindex        :longint;

   procedure setwrapwidth(x:longint);
   procedure bsetcaption(xcode,xval:string);
   function bgetcaption(xcode:string):string;
   procedure bsetenabled(xcode:string;xval:boolean);
   function bgetenabled(xcode:string):boolean;
   procedure bsetmarked(xcode:string;xval:boolean);
   function bgetmarked(xcode:string):boolean;

  public

   //create
   procedure xcreate(xowner:tcomponent); override;
   procedure xdestroy; override;
   function paintref:string; override;
   procedure paint; override;
   function xhaveflash:boolean; override;
   procedure xmousedn; override;
   procedure xmousemove; override;
   procedure xmouseup; override;

   //information
   property wrapwidth                     :longint      read iwrapwidth         write setwrapwidth;
   property contentheight                 :longint      read icontentheight;
   property contentwidth                  :longint      read icontentwidth;

   //add
   procedure title(const xcode,xcaption:string);
   procedure title2(const xcode,xcaption,xhelp:string);
   procedure line(const xcode,xcaption:string);
   procedure line2(const xcode,xcaption,xhelp:string);
   procedure button(const xcode,xcaption:string);
   procedure button2(const xcode,xcaption,xhelp:string);
   procedure nline;//new line
   procedure npart;//part line

   //clear
   procedure clear;

   //adjust
   property bcaption[xcode:string]        :string       read bgetcaption        write bsetcaption;
   property benabled[xcode:string]        :boolean      read bgetenabled        write bsetenabled;
   property bmarked[xcode:string]         :boolean      read bgetmarked         write bsetmarked;

   //support
   procedure xadd(const xtype,xcode,xcaption,xhelp:string);
   property list                          :tgenericlist read ilist;
   property l                             :tgenericlist read ilist;

  end;

{tgenericguiform}
  tgenericguiform=class(tform)
  private

   igui:tgenericgui;

   procedure _ontimer(sender:tobject);

  public

   constructor create(xowner:tcomponent); override;
   destructor destroy; override;

   property gui:tgenericgui read igui;

  end;

{tsplash}
  tsplash=class(tobject)
  private

   iwaiting:boolean;
   itextcolor:longint;
   itextscale,ivertscale,ihorzscale:single;
   iform:tform;
   iimage:twinbmp;

   procedure iform_onmousedown(sender: tobject; button: tmousebutton; shift: tshiftstate; x, y: integer);
   procedure iform_onclose(sender: tobject; var Action: TCloseAction);
   procedure iform_onkey(sender: tobject; var key: word; shift: tshiftstate);
   procedure iform_onpaint(sender:tobject);

  public

   //create
   constructor create(ximagedata:pobject;const xtextcolor:longint;const xtextscale,xhorzscale,xvertscale:single); virtual;
   destructor destroy; override;

   //workers
   procedure splash(xsplash,xfadeEffect:boolean);

  end;


var

   lgui_started                   :boolean=false;

   //special clipboard formats -------------------------------------------------
   cf_png                :word=0;//08aug2025
   cf_bwd                :word=0;//26sep2022
   cf_bwp                :word=0;


//start-stop procs -------------------------------------------------------------

procedure lgui__start;
procedure lgui__stop;


//dialog procs -----------------------------------------------------------------

procedure dialog__splash(const ximagedata:array of byte;const xtextcolor:longint;const xtextscale,xhorzscale,xvertscale:single;xsplash,xfadeEffect:boolean);
procedure dialog__splash2(ximagedata:pobject;const xtextcolor:longint;const xtextscale,xhorzscale,xvertscale:single;xsplash,xfadeEffect:boolean);


//gui procs --------------------------------------------------------------------

function gui__stdcursor(const x:tobject):boolean;


//misc procs -------------------------------------------------------------------

function controls_height_adjustable(x:tcontrol):boolean;
function controls_id(x:twincontrol):longint;
procedure controls_auto_size(sender:twincontrol;children:boolean;sp:byte);

function low__cursorcolor:longint;//04oct2025
function low__capcolor(sx,sy:longint;xfromcursor:boolean):longint;//04oct2025

function code__extractcmd(const xcode:string):string;
function code__cancmd(const xcode:string;var xoutcode:string):boolean;


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
function info__lgui(xname:string):string;//information specific to this unit of code

{$ifdef gui4}
procedure app__makecommon(xform:tform;var xsettings:tappsettings;var xmainmenu:tgenericmainmenu);
procedure app__start(xform:tform);
procedure app__stop(xform:tform;var xsettings:tappsettings);


//clipboard procs --------------------------------------------------------------
function clip__hasformat(xformat:uint):boolean;
function clip__opened(var xopened:boolean):boolean;//01sep2025
function clip__openedAndclear(var xopened:boolean):boolean;//01sep2025

function clip__cancopytext:boolean;//20mar2021
function clip__copytext(const xdata:string):boolean;//01sep2025, 26apr2025
function clip__copytext2(xdata:pobject):boolean;//01sep2025, 01jun2025, 26apr2025

function clip__canpastetext:boolean;//16mar2021
function clip__pastetext(var xdata:string):boolean;//01sep2025, 27apr2025
function clip__pastetextb:string;//27apr2025
function clip__pastetext2(xdata:pobject):boolean;//27apr2025

function clip__canpasteimage:boolean;//29apr2025
function clip__pasteimage(d:tobject):boolean;//12jun2025, 08jun2025, 01jun2025, 29apr2025

function clip__cancopyimage:boolean;//12apr2021
function clip__copyimage(s:tobject):boolean;//10jun2025, 09jun2025, 26apr2025

{$endif}



implementation

uses limg2 {$ifdef gui4}, main{$endif};


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__lgui(xname:string):string;//information specific to this unit of code

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
if not m('lgui.') then exit;

//get
if      (xname='ver')        then result:='1.00.790'
else if (xname='date')       then result:='12oct2025'
else if (xname='name')       then result:='GUI'
else
   begin
   //nil
   end;

except;end;
end;

{$ifdef gui4}
procedure app__makecommon(xform:tform;var xsettings:tappsettings;var xmainmenu:tgenericmainmenu);
begin

//defaults
xsettings         :=nil;
xmainmenu         :=nil;

//check
if (xform=nil) then
   begin

   showerror('Invalid app form');
   exit;

   end;

//load settings
xsettings:=tappsettings.create;

//titles
with xform do
begin

font.name         :=app__info('app.fontname');
font.size         :=strint32(app__info('app.fontsize'));
application.title :=app__info('name');
caption           :=app__info('name');

end;

//main menu
xmainmenu         :=tgenericmainmenu.create(xform);

end;

procedure app__start(xform:tform);
begin

//start
if (xform<>nil) then
   begin
   app__setmainform(xform);

   //add to form list
   app__addwndproc(xform.handle,nil,true);

   //hint
   xform.showhint:=true;

   end;

application.showhint          :=true;
application.hintpause         :=500;
application.hinthidepause     :=3000;
application.hintcolor         :=strint32(app__info('app.backcolor'));

//splash
app__splash('splash');

//show gui
xform.show;

end;

procedure app__stop(xform:tform;var xsettings:tappsettings);
begin

//controls
freeobj(@xsettings);

//remove from form list
if (xform<>nil) then app__delwndproc(xform.handle);

end;

{$endif}


//start-stop procs -------------------------------------------------------------
procedure lgui__start;
begin
try

//check
if lgui_started then exit else lgui_started:=true;


//special clipboard formats ----------------------------------------------------
try
cf_png:=win____registerclipboardformat('PNG');//08aug2025
cf_bwd:=win____registerclipboardformat('Blaiz Writer Document');
cf_bwp:=win____registerclipboardformat('Blaiz Word Processor Document');
except;end;


except;end;
end;

procedure lgui__stop;
begin
try

//check
if not lgui_started then exit else lgui_started:=false;



except;end;
end;


//gui procs --------------------------------------------------------------------

function gui__stdcursor(const x:tobject):boolean;
begin

result:=true;//pass-thru

if (x=nil) then exit
else if (x is tedit)       then (x as tedit).cursor        :=crIbeam
else if (x is tmemo)       then (x as tmemo).cursor        :=crIbeam
else if (x is trichedit)   then (x as trichedit).cursor    :=crIbeam
else if (x is twincontrol) then (x as twincontrol).cursor  :=crArrow
else if (x is tcustomform) then (x as tcustomform).cursor  :=crArrow;

end;


//dialog procs -----------------------------------------------------------------

procedure dialog__splash(const ximagedata:array of byte;const xtextcolor:longint;const xtextscale,xhorzscale,xvertscale:single;xsplash,xfadeEffect:boolean);
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
dialog__splash2(@a,xtextcolor,xtextscale,xhorzscale,xvertscale,xsplash,xfadeEffect);

except;end;

//free
str__free(@a);

end;

procedure dialog__splash2(ximagedata:pobject;const xtextcolor:longint;const xtextscale,xhorzscale,xvertscale:single;xsplash,xfadeEffect:boolean);
var
   a:tsplash;
begin

//defaults
a     :=nil;
try
a     :=tsplash.create(ximagedata,xtextcolor,xtextscale,xhorzscale,xvertscale);
a.splash(xsplash,xfadeEffect);
except;end;

//free
freeobj(@a);

end;


//misc procs -------------------------------------------------------------------

function controls_height_adjustable(x:tcontrol):boolean;
begin
result:=(x is tmemo) or (x is trichedit) or (x is tlistbox) or (x is tpagecontrol) or (x is ttabsheet) or (x is tpanel);
end;

function controls_id(x:twincontrol):longint;
begin
if (x<>nil) then result:=x.controlcount-1 else result:=0;
end;

procedure controls_auto_size(sender:twincontrol;children:boolean;sp:byte);
var
   cl,p3,p2,p,maxp,cw,ch,rx,ry,rw,rh:integer;
   x:tcontrol;
begin

//check
if (sender=nil) then exit;

//init
cw   :=sender.clientwidth;
ch   :=sender.clientheight;

//ttabsheet - sync all ttabsheets to "active" ttasbsheet
if (sender is ttabsheet) and ((sender as ttabsheet).pagecontrol.activepage<>nil) then
   begin
   cw  :=(sender as ttabsheet).pagecontrol.activepage.clientwidth;
   ch  :=(sender as ttabsheet).pagecontrol.activepage.clientheight;
   end;

maxp :=sender.controlcount-1;
rx   :=sp;
ry   :=0;
rw   :=cw-2*rx;
cl   :=0;

for p:=0 to maxp do for p2:=0 to maxp do if (sender.controls[p2].tag=p) then
   begin

   if (sender.controls[p2] is tlabel) or (sender.controls[p2] is tbutton) then
      begin

      inc(cl);
      if (cl>=2) then inc(ry,sp);

      end;

   //default height
   rh:=sender.controls[p2].height;

   //autoheight
   if (p=maxp) and controls_height_adjustable(sender.controls[p2]) then rh:=frcmin32(ch-ry,10);

   //size
   sender.controls[p2].setbounds(rx,ry,rw,rh);
   inc(ry,rh);

   //child controls}
   if children and (sender.controls[p2] is twincontrol) then controls_auto_size(sender.controls[p2] as twincontrol,children,sp);

   //stop
   break;

   end;//p

end;

function low__cursorcolor:longint;//04oct2025
begin
result:=low__capcolor(0,0,true);
end;

function low__capcolor(sx,sy:longint;xfromcursor:boolean):longint;//04oct2025
var
   a:twinbmp;
   b:tpoint;
   h:hwnd;
   dc:hdc;
   sa:twinrect;
begin
//defaults
result        :=0;
a             :=nil;
h             :=0;
dc            :=0;

try

//init
if xfromcursor then
   begin

   win____getcursorpos(b);
   sx:=b.x;
   sy:=b.y;

   end;

//range
sa  :=monitors__totalarea;
sx  :=frcrange32(sx ,sa.left ,sa.right);
sy  :=frcrange32(sy ,sa.top  ,sa.bottom);


//get
h        :=win____getdesktopwindow;
dc       :=win____getwindowdc(h);
a        :=miswin24(1,1);
a.copyarea2(misarea(a),area__make(sx,sy,sx,sy),dc);
result   :=c24__int( a.prows24[0][0] );

//reset
win____releasedc(h,dc);

except;end;

//free
freeobj(@a);

end;


//## tappsettings ##############################################################
//6666666666666666666666666666666666
constructor tappsettings.create;
begin

//self
inherited create;

//vars
icore         :=tfastvars.create;
idef          :=tfastvars.create;
imodified     :=false;

//load
load;

end;

destructor tappsettings.destroy;
begin
try

//controls
freeobj(@icore);
freeobj(@idef);

//self
inherited destroy;

except;end;
end;

function tappsettings.geth(xname:string):boolean;//have value
begin
result:=icore.found(xname);
end;

function tappsettings.getds(xname:string):string;
begin
result:=idef.s[xname];
end;

procedure tappsettings.setds(xname,xval:string);
begin
idef.s[xname]:=xval;
end;

function tappsettings.getdb(xname:string):boolean;
begin
result:=strbol(ds[xname]);
end;

procedure tappsettings.setdb(xname:string;xval:boolean);
begin
ds[xname]:=bolstr(xval);
end;

function tappsettings.getdi(xname:string):longint;
begin
result:=strint32(ds[xname]);
end;

procedure tappsettings.setdi(xname:string;xval:longint);
begin
ds[xname]:=intstr32(xval);
end;

function tappsettings.gets(xname:string):string;
begin
result:=icore.s[xname];
if (result='') then result:=idef.s[xname];
end;

procedure tappsettings.sets(xname,xval:string);
begin

if (xval='') then xval:=idef.s[xname];

if (icore.s[xname]<>xval) then
   begin
   imodified      :=true;
   icore.s[xname] :=xval;
   end;

end;

function tappsettings.getb(xname:string):boolean;
begin
result:=strbol(s[xname]);
end;

procedure tappsettings.setb(xname:string;xval:boolean);
begin
s[xname]:=bolstr(xval);
end;

function tappsettings.geti(xname:string):longint;
begin
result:=strint32(s[xname]);
end;

procedure tappsettings.seti(xname:string;xval:longint);
begin
s[xname]:=intstr32(xval);
end;

function tappsettings.filename:string;
begin
result:=app__settingsfile('settings.ini');
end;

function tappsettings.load:boolean;
var
   e:string;
begin
result:=icore.fromfile(filename,e);
if result then imodified:=false;
end;

function tappsettings.save:boolean;
var
   e:string;
begin
result:=icore.tofile(filename,e);
if result then imodified:=false;
end;

procedure tappsettings.autosave;
begin
if imodified then save;
end;


//## ttopmenu ##################################################################

//5555555555555555555555555555555555//xxxxxxxxxxxxxxxxxxxxxxx
constructor tgenericmainmenu.create(aowner:tcomponent);
var
   p:longint;
begin

//self
inherited create(aowner);

//vars
low__cls(@itop,sizeof(itop));
for p:=0 to high(icode) do icode[p]:='';
icodecount:=0;

//events
foncmd   :=nil;

end;

destructor tgenericmainmenu.destroy;
begin
try

//self
inherited destroy;

except;end;
end;

procedure tgenericmainmenu.xaddHelp;//12oct2025
begin

addtop('&Help','help');
add(app__info('name')+' Website','system:url.software');
add(app__info('author.name')+' - Portal','system:url.portal');
add('Contact Us','system:url.contact');
add('About','system:about');
tadd('Social Media');
add('GitHub','system:url.github');
add('SourceForge','system:url.sourceforge');
add('Mastodon','system:url.mastodon');
add('Facebook','system:url.facebook');
add('X/Twitter','system:url.twitter');
add('Instagram','system:url.instagram');

end;

function tgenericmainmenu.xsysitem(const xcode:string):boolean;
var
   v:string;
   v32:longint;

   function mv(const x:string):boolean;
   begin
   result:=strm(xcode,x,v,v32);
   end;

   function m(const x:string):boolean;
   begin
   result:=strmatch(x,xcode);
   end;

begin

//defaults
result :=true;
v      :='';
v32    :=0;

if m('system:help') then
   begin

   end
else if mv('system:url.')     then runlow( app__info('url.'+v), '')
else if m('system:about')     then app__splash('about')
else result:=false;

end;

function tgenericmainmenu.xnewcode:longint;
begin

if (icodecount<=high(icode)) then inc(icodecount);
result:=pred(icodecount);

end;

function tgenericmainmenu.xfindbycode(const xcode:string;var m:tmenuitem):boolean;
var
   mtop:boolean;
begin
result:=xfindbycode2(xcode,m,mtop);
end;

function tgenericmainmenu.xfindbycode2(const xcode:string;var m:tmenuitem;var mtop:boolean):boolean;
var
   a,b:tmenuitem;
   p,s:longint;

   function sa(const x:tmenuitem):boolean;
   begin

   result:=(x<>nil);
   if result then a:=x else a:=nil;

   end;

   function ma:boolean;
   begin

   result:=(a<>nil) and (a.tag>=0) and (a.tag<=high(icode)) and strmatch(xcode,icode[a.tag]);
   if result then m:=a;

   end;

begin

//defaults
result :=false;
m      :=nil;
mtop   :=false;

//top items (left to right)
for p:=0 to (items.count-1) do if sa(items[p]) then
   begin

   if ma then
      begin

      result :=true;
      mtop   :=true;
      exit;

      end;

   //sub items (top to bottom)
   b:=a;
   if (b<>nil) then for s:=0 to (b.count-1) do if sa(b.items[s]) and ma then
      begin

      result :=true;
      exit;

      end;//s

   end;//p

end;

procedure tgenericmainmenu.xonclick(sender:tobject);
var
   dcmd:string;
begin

if (sender is tmenuitem) and ((sender as tmenuitem).tag>=0) and ((sender as tmenuitem).tag<=high(icode)) and code__cancmd(icode[(sender as tmenuitem).tag],dcmd) then
   begin

   if xsysitem( dcmd ) then
      begin
      //nil
      end
   else if assigned(foncmd) then foncmd( self, dcmd );

   end;

end;

procedure tgenericmainmenu.addtop(const xcaption,xcode:string);
begin
addtop2(xcaption,xcode,'');
end;

procedure tgenericmainmenu.addtop2(const xcaption,xcode,xshortcut:string);
var
   a:tmenuitem;
begin

//get
a                  :=tmenuitem.create(self);
a.caption          :=xcaption;

case (xshortcut<>'') of
true:a.shortcut    :=TextToShortCut(xshortcut);
else a.shortcut    :=0;
end;

a.tag              :=xnewcode;
a.onclick          :=xonclick;
icode[a.tag]       :=xcode;
itop [a.tag]       :=true;

//set
items.add(a);

end;

procedure tgenericmainmenu.add(const xcaption,xcode:string);
begin
add2(xcaption,xcode,'');
end;

procedure tgenericmainmenu.add2(const xcaption,xcode,xshortcut:string);
var
   a:tmenuitem;
begin

//check
if (items.count<=0) then exit;

//get
a                  :=tmenuitem.create(self);
a.caption          :=xcaption;

case (xshortcut<>'') of
true:a.shortcut    :=TextToShortCut(xshortcut);
else a.shortcut    :=0;
end;

a.tag              :=xnewcode;
a.onclick          :=xonclick;
icode[a.tag]       :=xcode;
itop [a.tag]       :=false;

//set
items[items.count-1].add(a);

end;

procedure tgenericmainmenu.addsep;
begin
add('-','');
end;

procedure tgenericmainmenu.tadd(const xcaption:string);
var
   v:string;
begin

v:='----- '+xcaption+' -----';

add(v,v);
enabled[v]:=false;

end;

function tgenericmainmenu.getenabled(xcode:string):boolean;
var
   m:tmenuitem;
begin
if xfindbycode(xcode,m) then result:=m.enabled else result:=false;
end;

procedure tgenericmainmenu.setenabled(xcode:string;xval:boolean);
var
   m:tmenuitem;
begin
if xfindbycode(xcode,m) then m.enabled:=xval;
end;

function tgenericmainmenu.getchecked(xcode:string):boolean;
var
   m:tmenuitem;
begin
if xfindbycode(xcode,m) then result:=m.checked else result:=false;
end;

procedure tgenericmainmenu.setchecked(xcode:string;xval:boolean);
var
   m:tmenuitem;
begin
if xfindbycode(xcode,m) then m.checked:=xval;
end;

function tgenericmainmenu.gettop(xcode:string):boolean;
var
   m:tmenuitem;
begin
if not xfindbycode2(xcode,m,result) then result:=false;
end;

procedure tgenericmainmenu.settopenabled(x:boolean);
var
   p:longint;
begin
for p:=0 to (items.count-1) do items[p].enabled:=x;
end;

function tgenericmainmenu.gettopenabled:boolean;
var
   p:longint;
begin

result:=true;

for p:=0 to (items.count-1) do if not items[p].enabled then
   begin

   result:=false;
   break;

   end;//p

end;


//## tgenericlist ##############################################################

function code__extractcmd(const xcode:string):string;
var
   p:longint;
begin
if      strmatch(xcode,'nil')     then result:=''
else if strmatch(xcode,'**sep**') then result:=''
else if (xcode='')                then result:=''
else
   begin

   //get
   result:=xcode;

   //remove comment -> used to form a unique ID but perform the same command
   if (strcopy1(result,1,1)='{') then
      begin

      for p:=2 to low__len(result) do if (result[p]='}') then
         begin

         result:=strcopy1(result,p+1,low__len(result));
         break;

         end;//p

      end;

   end;

end;

function code__cancmd(const xcode:string;var xoutcode:string):boolean;
begin

xoutcode :=code__extractcmd(xcode);
result   :=(xoutcode<>'');

end;

//xxxxxxxxxxxxxxxxxxxxxxxx//lllllllllllllllllllllll
constructor tgenericlist.create;
var
   p:longint;
begin

//self
inherited create;

//vars
icount           :=0;
isepcode         :='**sep**';
inilcode         :='nil';
ichangeid        :=0;
iitemindex       :=-1;

for p:=0 to high(icore) do xclearitem( icore[p] );

end;

destructor tgenericlist.destroy;
var
   p:longint;
begin
try

//controls
for p:=0 to high(icore) do freeobj(@icore[p].img);

//self
inherited destroy;

except;end;
end;

procedure tgenericlist.xclearitem(var x:tgenericlistitem);
begin

with x do
begin

code     :='';
caption  :='';
help     :='';
tep      :='';
visible  :=false;
enabled  :=false;
marked   :=false;
flash    :=false;
pert100  :=0;
img      :=nil;
tag      :=0;
align    :=0;//left
oa       :=nilarea;
ia       :=nilarea;
width    :=0;

str1     :='';
val1     :=0;

end;

end;

procedure tgenericlist.xchange;
begin
change;
end;

procedure tgenericlist.change;
begin
low__irollone(ichangeid);
end;

function tgenericlist.getitem(xindex:longint):pgenericlistitem;
begin
result:=@icore[ frcrange32(xindex,0,pred(icount)) ];
end;

function tgenericlist.haveflash:boolean;
var
   p:longint;
begin

//defaults
result :=false;

//find
for p:=0 to pred(icount) do if icore[p].visible and icore[p].flash then
   begin

   result :=true;
   break;

   end;//p

end;

function tgenericlist.xfindbycode(const xcode:string;var xindex:longint):boolean;
var
   p:longint;
begin

//defaults
result :=false;
xindex :=0;

//find
if (xcode<>'') then for p:=0 to pred(icount) do if strmatch(xcode,icore[p].code) then
   begin

   result :=true;
   xindex :=p;
   break;

   end;//p

end;

function tgenericlist.findindex(const sx,sy:longint;var xindex:longint):boolean;
var
   p:longint;
begin

//defaults
result :=false;
xindex :=-1;

//find
for p:=0 to pred(icount) do if icore[p].visible and (not xissep(p)) and area__within(icore[p].oa,sx,sy) then
   begin

   result :=true;
   xindex :=p;
   break;

   end;//p

end;

function tgenericlist.findindexb(const sx,sy:longint):longint;
begin
findindex(sx,sy,result);
end;

function tgenericlist.findcode(const sx,sy:longint;var xcode:string):boolean;
var
   i:longint;
begin

if findindex(sx,sy,i) then xcode:=icore[i].code else xcode:='';
result:=(xcode<>'');

end;

function tgenericlist.findcodeb(const sx,sy:longint):string;
begin
findcode(sx,sy,result);
end;

procedure tgenericlist.xsettep(x:tbasicimage;const y:string);
var
   ydata:tstr8;
   yw,yh:longint;
   etmp,de:string;

   procedure xfailed;
   begin

   missize(x,1,1);
   mis__cls(x,255,255,255,0);

   end;

begin

if (x<>nil) then
   begin

   //defaults
   ydata       :=nil;

   try
   //init
   ydata       :=small__new8;
   ydata.text  :=y;

   //get
   if not io__anyformat(@ydata,de) then xfailed
   else if (de='TEP') then
      begin

      if not tep__fromdata(x,@ydata,etmp) then xfailed;

      end
   else if (de='TEA') then
      begin

      if not tea__fromdata322(x,@ydata,true,yw,yh)  then xfailed;

      end
   else xfailed;

   except;end;

   //free
   small__free8(@ydata);

   end;

end;

function tgenericlist.add(const xcode,xcaption,xtep,xhelp:string):boolean;
begin

//check
result:=(xcode<>'') and (icount<=high(icore));
if not result then exit;

try
//clear
xclearitem( icore[icount] );

//get
with icore[icount] do
begin

code     :=xcode;
caption  :=xcaption;
visible  :=true;
enabled  :=true;
help     :=xhelp;
tep      :=xtep;

end;

//get
if (not strmatch(xcode,isepcode)) and (xtep<>'') then
   begin

   if (icore[icount].img=nil) then icore[icount].img:=misimg32(1,1);
   xsettep(icore[icount].img,xtep);

   end;

//inc
inc(icount);

//change
change;

except;end;
end;

function tgenericlist.add2(const xcode,xcaption:string;const xtea:array of byte;const xhelp:string):boolean;
var
   a:tstr8;
begin

//defaults
result :=false;
a      :=nil;

try

//init
a      :=small__new8;
a.aadd(xtea);

//get
result:=add(xcode,xcaption,a.text,xhelp);

except;end;

//free
small__free8(@a);

end;

function tgenericlist.addsep:boolean;
begin
result:=add(isepcode,'','','');
end;

procedure tgenericlist.clear;
var
   p:longint;
begin

//clear items
if (icount>=1) then
   begin

   for p:=0 to pred(icount) do
   begin

   xclearitem( icore[p] );
   freeobj(@icore[p].img);

   end;//p

   end;

//reset
icount      :=0;
iitemindex  :=-1;

end;

procedure tgenericlist.Softclear;
begin

//reset
icount      :=0;
iitemindex  :=-1;

end;

function tgenericlist.xitemheight:longint;
var
   p:longint;
begin

result:=0;
for p:=0 to pred(icount) do if icore[p].visible and (not xissep(p)) then result:=largest32(result,mish(icore[p].img));

end;

function tgenericlist.xissep(const xindex:longint):boolean;
begin
result:=(xindex>=0) and (xindex<=pred(icount)) and strmatch(isepcode,icore[xindex].code);
end;

function tgenericlist.xcancmd(const xindex:longint):boolean;
var
   dcmd:string;
begin
result:=(xindex>=0) and (xindex<=pred(icount)) and code__cancmd(icore[xindex].code,dcmd);
end;

procedure tgenericlist.setitemindex(xindex:longint);
begin
if low__setint(iitemindex,frcrange32(xindex,-1,pred(icount))) then xchange;
end;

function tgenericlist.getitemcode:string;
begin
if (iitemindex>=0) and (iitemindex<=pred(icount)) then result:=icore[iitemindex].code;
end;

procedure tgenericlist.setitemcode(xcode:string);
begin
xfindbycode(xcode,iitemindex);
end;

function tgenericlist.getvisible(xcode:string):boolean;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].visible else result:=false;
end;

procedure tgenericlist.setvisible(xcode:string;xval:boolean);
var
   i:longint;
begin
if xfindbycode(xcode,i) and low__setbol(icore[i].visible,xval) then xchange;
end;

function tgenericlist.getenabled(xcode:string):boolean;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].enabled else result:=false;
end;

procedure tgenericlist.setenabled(xcode:string;xval:boolean);
var
   i:longint;
begin
if xfindbycode(xcode,i) and low__setbol(icore[i].enabled,xval) then xchange;
end;

function tgenericlist.getmarked(xcode:string):boolean;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].marked else result:=false;
end;

procedure tgenericlist.setmarked(xcode:string;xval:boolean);
var
   i:longint;
begin
if xfindbycode(xcode,i) and low__setbol(icore[i].marked,xval) then xchange;
end;

function tgenericlist.getflash(xcode:string):boolean;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].flash else result:=false;
end;

procedure tgenericlist.setflash(xcode:string;xval:boolean);
var
   i:longint;
begin
if xfindbycode(xcode,i) then icore[i].flash:=xval;
end;

function tgenericlist.getpert100(xcode:string):longint;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].pert100 else result:=0;
end;

procedure tgenericlist.setpert100(xcode:string;xval:longint);
var
   i:longint;
begin
if xfindbycode(xcode,i) and low__setint(icore[i].pert100,frcrange32(xval,0,100)) then xchange;
end;

function tgenericlist.gethelp(xcode:string):string;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].help else result:='';
end;

procedure tgenericlist.sethelp(xcode,xval:string);
var
   i:longint;
begin
if xfindbycode(xcode,i) then icore[i].help:=xval;
end;

function tgenericlist.getcaption(xcode:string):string;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].caption else result:='';
end;

procedure tgenericlist.setcaption(xcode,xval:string);
var
   i:longint;
begin
if xfindbycode(xcode,i) and low__setstr(icore[i].caption,xval) then xchange;
end;

function tgenericlist.gettag(xcode:string):longint;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].tag else result:=0;
end;

procedure tgenericlist.settag(xcode:string;xval:longint);
var
   i:longint;
begin
if xfindbycode(xcode,i) then icore[i].tag:=xval;
end;

function tgenericlist.getalign(xcode:string):longint;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].align else result:=0;
end;

procedure tgenericlist.setalign(xcode:string;xval:longint);
var
   i:longint;
begin
if xfindbycode(xcode,i) and low__setint(icore[i].align,frcrange32(xval,0,2)) then xchange;
end;

function tgenericlist.gettep(xcode:string):string;
var
   i:longint;
begin
if xfindbycode(xcode,i) then result:=icore[i].tep else result:='';
end;

procedure tgenericlist.settep(xcode,xval:string);
var
   i:longint;
begin

if xfindbycode(xcode,i) and low__setstr(icore[i].tep,xval) then
   begin

   xsettep(icore[i].img,xval);
   xchange;

   end;

end;


//## tgenericcontrol ###########################################################
//xxxxxxxxxxxxxxxxxxxx//cccccccccccccccc
constructor tgenericcontrol.create(xowner:tcomponent);
begin

//self
inherited create(xowner);
controlstyle    :=[csAcceptsControls, csCaptureMouse, csClickEvents, csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
istart_owner    :=xowner;
showhint        :=true;

//vars
icreated         :=false;
ibuffer          :=nil;
ivscale          :=1.0;
ihscale          :=1.0;
ivpad            :=0;
ihpad            :=0;
ichangeid        :=0;
imousedown       :=false;
ipaintref        :='';
foncmd           :=nil;
fonmouse         :=nil;
fonpaint         :=nil;
imousedown       :=false;
imousedownstroke :=false;
imouseupstroke   :=false;
imousedownxy.x   :=0;
imousedownxy.y   :=0;
imousemovexy.x   :=0;
imousemovexy.y   :=0;
imousebutton     :=0;//0=left, 1=center, 2=right
imousedragging   :=false;

low__cls(@info,sizeof(info));

info.fontname  :=app__info('app.fontname');
info.fontsize  :=strint32(app__info('app.fontsize'));
info.backcolor :=strint32(app__info('app.backcolor'));
info.tintcolor :=strint32(app__info('app.tintcolor'));

//xcreate
xcreate(xowner);

end;

procedure tgenericcontrol.xcreate(xowner:tcomponent);
begin
createfinish(true);
end;

procedure tgenericcontrol.createfinish(const xstartTimer:boolean);
begin

//icreated
icreated       :=true;

//info calc
xinfocalc;

//prime size
setbounds(0,0,1,1);

//timer
if xstartTimer then low__timerset(self,_ontimer,50);

//defaults
if (istart_owner is twincontrol) then parent:=(istart_owner as twincontrol);

bringtofront;
end;

destructor tgenericcontrol.destroy;
begin
try

//timer
xstoptimer;

//controls
xdestroy;
freeobj(@ibuffer);

//self
inherited destroy;

except;end;
end;

procedure tgenericcontrol.xdestroy;
begin
//nil
end;

function tgenericcontrol.xhaveflash:boolean;
begin
result:=false;
end;

procedure tgenericcontrol.xshowhint(const x:string);
var
   a:tmessage;
   z:string;
begin

if (x<>hint) then
   begin

   //get
   application.cancelhint;
   hint      :=x;

   //force display of control's hint - 12oct2025
   low__cls(@a,sizeof(a));
   twmmouse(a).xpos:=left;
   twmmouse(a).ypos:=top;
   application.hintmousemessage(self,a);

   end;

end;

procedure tgenericcontrol.xstoptimer;
begin
low__timerdel(self,_ontimer);
end;

procedure tgenericcontrol.change;
begin
low__irollone(ichangeid);
end;

function tgenericcontrol.changeid:longint;
begin
result:=ichangeid;
end;

function tgenericcontrol.changeid2:longint;
begin
result:=0;
end;

function tgenericcontrol.paintref:string;
var
   xflash:boolean;
begin

case xhaveflash of
true:xflash:=sysflash;
else xflash:=false;
end;//case

result:=
 bolstr(xflash)+
 bolstr(icreated)+bolstr(visible)+bolstr(enabled)+'|'+intstr32(trunc(1000*ivscale))+'|'+intstr32(trunc(1000*ihscale))+'|'+
 intstr32(info.backcolor)+'|'+intstr32(info.tintcolor)+'|'+intstr32(width)+'|'+intstr32(height)+'|'+
 intstr32(changeid)+'|'+intstr32(changeid2);

end;

function tgenericcontrol.mustpaint:boolean;
begin
result:=mustpaint2(true);
end;

function tgenericcontrol.mustpaint2(const xreset:boolean):boolean;
begin

case xreset of
true:result:=low__setstr(ipaintref,paintref);
else result:=(ipaintref<>paintref);
end;//case

end;

function tgenericcontrol.canpaint:boolean;
begin
result:=icreated and visible;
end;

procedure tgenericcontrol.paintnow;
begin

if canpaint then
   begin

   win____InvalidateRect(handle,nil,false);
   win____updatewindow(handle);

   end;

end;

procedure tgenericcontrol.paint;
begin
if assigned(fonpaint) then fonpaint(self);
end;

function tgenericcontrol.needbuffer:twinbmp;
begin
result:=needbuffer2(true);
end;

function tgenericcontrol.needbuffer2(xsize:boolean):twinbmp;
begin

if (ibuffer=nil) then ibuffer:=miswin24(1,1);
if xsize then missize(ibuffer,width,height);
result:=ibuffer;

end;

procedure tgenericcontrol.freebuffer;
begin

if (ibuffer<>nil) then freeobj(@ibuffer);

end;

function tgenericcontrol.havebuffer:boolean;
begin
result:=(ibuffer<>nil);
end;

function tgenericcontrol.getbuffer:twinbmp;
begin

needbuffer2(false);
result:=buffer;

end;

procedure tgenericcontrol._ontimer(sender:tobject);
begin
if mustpaint then paintnow;
end;

procedure tgenericcontrol.wmerasebkgnd(var message: twmerasebkgnd);
begin
message.result:=1;
end;

procedure tgenericcontrol.wmlbuttondn(var message: twmlbuttonup);
begin

inherited;//required

imousebutton      :=0;//0=left button
imousedownxy.x    :=message.xpos;
imousedownxy.y    :=message.ypos;
imousemovexy.x    :=message.xpos;
imousemovexy.y    :=message.ypos;
imousedownstroke  :=(not imousedown);
imousedown        :=true;
imousedragging    :=false;

xmousedn;
if assigned(fonmouse) then fonmouse(self);

end;

procedure tgenericcontrol.wmmousemove(var message: twmmousemove);
const
   xtrigger=3;
begin

inherited;//required

imousemovexy.x    :=message.xpos;
imousemovexy.y    :=message.ypos;

if mousedown and (not imousedragging) then
   begin

   if (imousemovexy.x<(imousedownxy.x-xtrigger)) or (imousemovexy.x>(imousedownxy.x+xtrigger)) or
      (imousemovexy.y<(imousedownxy.y-xtrigger)) or (imousemovexy.y>(imousedownxy.y+xtrigger)) then
      begin

      imousedragging:=xcandrag;

      end;

   end;

xmousemove;
if assigned(fonmouse) then fonmouse(self);

end;


procedure tgenericcontrol.wmlbuttonup(var message: twmlbuttonup);
begin

inherited;//required

imousemovexy.x    :=message.xpos;
imousemovexy.y    :=message.ypos;

xmouseoff;

end;

procedure tgenericcontrol.xmouseoff;
begin

imouseupstroke    :=imousedown;
imousedown        :=false;

xmouseup;
if assigned(fonmouse) then fonmouse(self);

imousedownstroke  :=false;
imouseupstroke    :=false;
imousedown        :=false;
imousedragging    :=false;

end;

function tgenericcontrol.xcandrag:boolean;
begin
result:=true;
end;

procedure tgenericcontrol.xmousemove;
begin
//nil
end;

procedure tgenericcontrol.xmousedn;
begin
//nil
end;

procedure tgenericcontrol.xmouseup;
begin
//nil
end;

function tgenericcontrol.getbackcolor:longint;
begin
result:=info.backcolor;
end;

procedure tgenericcontrol.setbackcolor(xcolor:longint);
begin
if low__setint(info.backcolor,xcolor) then xinfocalc;
end;

function tgenericcontrol.gettintcolor:longint;
begin
result:=info.tintcolor;
end;

procedure tgenericcontrol.settintcolor(xcolor:longint);
begin
if low__setint(info.tintcolor,xcolor) then xinfocalc;
end;

procedure tgenericcontrol.xinfocalc;

   procedure xtint(var xcolor:longint);
   begin

   case info.dark of
   true:xcolor:=int__splice24( 0.15, xcolor, info.tint);
   else xcolor:=int__splice24( 0.10, xcolor, info.tint);
   end;//case

   end;

begin

with info do
begin

back               :=int24__rgba0(backcolor);
tint               :=int24__rgba0(tintcolor);
dark               :=int__c8(back)<140;
refcol             :=low__aorb( 0, int_255_255_255, dark );

back               :=int__splice24( 0.015, back, refcol);
back0              :=int__splice24( 0.05, back, refcol);

pert               :=back;
pert0              :=int__splice24( 0.15, back, refcol);

text               :=int__splice24( 0.5, refcol, back);
textDis            :=int__splice24( 0.4, text, back);

mark               :=back;
mark0              :=int__splice24( 0.07, back, refcol);

hover              :=int__splice24( 0.05, back, refcol);
hover0             :=int__splice24( 0.10, back, refcol);

sep                :=int__splice24( 0.10, back, refcol);
sep0               :=int__splice24( 0.03, back, refcol);

line               :=int__splice24( 0.10, back, refcol);
line0              :=int__splice24( 0.03, back, refcol);

//.apply tints
if (info.tintcolor<>clnone) then
   begin

   xtint(mark);
   xtint(mark0);

   xtint(pert);
   xtint(pert0);

   end;

end;//with

//changed
change;

end;

function tgenericcontrol.getvisible:boolean;
begin
result:=inherited visible;
end;

procedure tgenericcontrol.setvisible(x:boolean);
begin

if (inherited visible<>x) then
   begin

   inherited visible:=x;
   change;

   end;

end;

function tgenericcontrol.getenabled:boolean;
begin
result:=inherited enabled;
end;

procedure tgenericcontrol.setenabled(x:boolean);
begin

if (inherited enabled<>x) then
   begin

   inherited enabled:=x;
   change;

   end;

end;

function tgenericcontrol.getleft:longint;
begin
result:=inherited left;
end;

procedure tgenericcontrol.setleft(x:longint);
begin
setbounds(x,top,width,height);
end;

function tgenericcontrol.gettop:longint;
begin
result:=inherited top;
end;

procedure tgenericcontrol.settop(x:longint);
begin
setbounds(left,x,width,height);
end;

function tgenericcontrol.getwidth:longint;
begin
result:=inherited width;
end;

procedure tgenericcontrol.setwidth(x:longint);
begin
setbounds(left,top,x,height);
end;

function tgenericcontrol.getheight:longint;
begin
result:=inherited height;
end;

procedure tgenericcontrol.setheight(x:longint);
begin
setbounds(left,top,width,x);
end;

function tgenericcontrol.getclientrect:trect;
begin

result.left    :=0;
result.top     :=0;
result.right   :=getwidth;
result.bottom  :=getheight;

end;

procedure tgenericcontrol.setclientrect(x:trect);
begin

setbounds(getleft, gettop, x.right-x.left, x.bottom-x.top );

end;

procedure tgenericcontrol.xfiltersize(var xnewwidth,xnewheight:longint);
begin

end;

procedure tgenericcontrol.setbounds(xleft,xtop,xwidth,xheight:longint);
begin

//range
xwidth    :=frcmin32(xwidth,0);
xheight   :=frcmin32(xheight,0);

//filter
xfilterSize(xwidth,xheight);

//range
xwidth    :=frcmin32(xwidth,0);
xheight   :=frcmin32(xheight,0);

//get
if (xleft<>getleft) or (xtop<>gettop) or (xwidth<>getwidth) or (xheight<>getheight) then
   begin

   inherited setbounds(xleft,xtop,xwidth,xheight);
   change;

   end;

end;

procedure tgenericcontrol.setvscale(x:single);
begin

if (x<=0) then x:=0.1;
if (ivscale<>x) then
   begin

   ivscale:=x;
   change;

   end;

end;

procedure tgenericcontrol.sethscale(x:single);
begin

if (x<=0) then x:=0.1;
if (ihscale<>x) then
   begin

   ihscale:=x;
   change;

   end;

end;


//## tgenericstatus ############################################################

procedure tgenericstatus.xcreate(xowner:tcomponent);
begin

//defaults
ilist         :=nil;
align         :=albottom;
itext         :='';
itextalign    :=0;
ivpad         :=5;
ihpad         :=5;
ilist         :=tgenericlist.create;

//self
inherited xcreate(xowner);

end;

procedure tgenericstatus.xdestroy;
begin
try

//controls
freeobj(@ilist);

except;end;
end;

function tgenericstatus.xhaveflash:boolean;
begin
result:=list.haveflash;
end;

procedure tgenericstatus.xfiltersize(var xnewwidth,xnewheight:longint);
begin

xnewheight:=trunc(24*ivscale) + (2*ivpad);

end;

function tgenericstatus.changeid2:longint;
begin
if (list<>nil) then result:=list.changeid else result:=0;
end;

procedure tgenericstatus.settext(x:string);
begin
if low__setstr(itext,x) then list.change;
end;

procedure tgenericstatus.setitextalign(xval:longint);
begin
if low__setint(itextalign,frcrange32(xval,0,2)) then list.change;
end;

function tgenericstatus.add(const xwidth:longint;const xcaption,xcode,xhelp:string):boolean;
begin

//get
result:=list.add(xcode,xcaption,'',xhelp);
if not result then exit;

with list.items[pred(list.count)]^ do
begin

width    :=frcmin32(xwidth,0);
align    :=1;//center

end;

//change
list.change;

end;

procedure tgenericstatus._ontimer(sender:tobject);
begin
try

//paint
if mustpaint then paintnow;

except;end;
end;

procedure tgenericstatus.xmousemove;
begin

list.itemindex:=list.findindexb(mousemovexy.x,mousemovexy.y);
xshowhint( insstr(list.items[list.itemindex].help,list.itemindex>=0) );

end;

procedure tgenericstatus.xmouseup;
var
   dcmd:string;
begin

if (mousebutton=0) and mouseupstroke and (list.itemindex>=0) and (list.itemindex<=pred(list.count)) and
   list.items[list.itemindex].visible and list.items[ilist.itemindex].enabled and
   code__cancmd(list.items[ilist.itemindex].code,dcmd) then
   begin

   if assigned(foncmd) then foncmd(self,dcmd);

   end;

end;

//???????????????????//xxxxxxxxxxxxx
procedure tgenericstatus.paint;//12oct2025, 10oct2025
const
   xgap=1;
var
   xwall,xdown,xenabled:boolean;
   v,tw,tx,dx,dy,p,th,cw,ch:longint;
   da:twinrect;

   procedure ds(const da:twinrect;const c0,c:longint);//draw shade
   begin
   misclsarea3(ibuffer,area__make(da.left,da.top,da.right,da.top+((da.bottom-da.top+1) div 2)),c0,c,255,255);
   misclsarea3(ibuffer,area__make(da.left,da.top+((da.bottom-da.top+1) div 2),da.right,da.bottom),c,c0,255,255);
   end;

   function xnextvisible(xfrom:longint):boolean;
   var
      p:longint;
   begin

   result:=(itext<>'');
   if (not result) and (xfrom>=0) and (xfrom<=pred(list.count)) then for p:=xfrom to pred(list.count) do if list.items[p].visible then
      begin

      result:=true;
      break;

      end;

   end;

begin
try

//init
needbuffer;
xenabled            :=enabled;
xdown               :=imousedown;
cw                  :=clientwidth;
ch                  :=height;
th                  :=wincanvas__textheight(ibuffer.dc,'W#hq');

//.font
ibuffer.setfont2(info.fontname,false,false,true,trunc(-ch*0.40),info.text,0);

//cls
miscls(ibuffer,info.back);

//draw

//.cells
dx   :=0;
dy   :=(ch-th) div 2;

for p:=0 to pred(list.count) do if list.items[p].visible then
   begin

   //init
   xwall                    :=xnextvisible(p+1);

   //calc cell area
   list.items[p].oa.left    :=dx;

   case xwall or (itext<>'') of
   true:list.items[p].oa.right   :=list.items[p].oa.left + trunc(list.items[p].width*ihscale) + (2*ihpad);
   else list.items[p].oa.right   :=cw-1;
   end;//case

   list.items[p].oa.top     :=0;
   list.items[p].oa.bottom  :=ch-1;
   tw                   :=wincanvas__textwidth(ibuffer.dc,list.items[p].caption);

   //marked
   if list.items[p].marked and ((not list.items[p].flash) or sysflash) then
      begin

      ds(list.items[p].oa,info.mark0,info.mark);

      end
   else if list.items[p].flash and sysflash and (list.items[p].pert100<=0) then
      begin

      ds(list.items[p].oa,info.mark0,info.mark);

      end;

   //pert100
   if (list.items[p].pert100>=1) and ((not list.items[p].flash) or sysflash)  then
      begin

      da         :=list.items[p].oa;
      da.right   :=frcrange32(da.left + trunc( (list.items[p].pert100/100)*(da.right-da.left+1) ),da.left,da.right);
      ds(da,info.pert0,info.pert);

      end;

   //draw text
   case list.items[p].align of
   1   :tx:=list.items[p].oa.left + frcmin32( ((list.items[p].oa.right-list.items[p].oa.left+1)-tw) div 2,ihpad);
   2   :tx:=list.items[p].oa.right - tw - ihpad;
   else tx:=list.items[p].oa.left + ihpad;
   end;//case

   wincanvas__textrect(ibuffer.dc,true,list.items[p].oa,tx,dy,list.items[p].caption);

   //inc
   inc(dx, list.items[p].oa.right - list.items[p].oa.left + 1 + xgap);

   //trailing cell wall
   if xwall then ds(area__make(dx-xgap,1,dx-xgap,ch-1),info.sep0,info.sep);

   end;

//.text (non-cell based)
if (itext<>'') then
   begin

   inc(dx, ihpad);

   //calc remaing area
   da.left    :=dx;
   da.right   :=cw-1;
   da.top     :=0;
   da.bottom  :=ch-1;
   tw         :=wincanvas__textwidth(ibuffer.dc,itext);

   //draw text
   case itextalign of
   1   :tx:=da.left + frcmin32( ((da.right-da.left+1)-tw) div 2,ihpad);
   2   :tx:=da.right - tw - ihpad;
   else tx:=da.left + ihpad;
   end;//case

   wincanvas__textrect(ibuffer.dc,true,da,tx,dy,itext);

   end;

//.top line
misclsarea3(ibuffer,area__make(0,0,cw-1,0),info.sep,info.sep,clnone,clnone);

//paint
win____stretchblt(canvas.handle,0,0,misw(ibuffer),mish(ibuffer),  ibuffer.dc,0,0,misw(ibuffer),mish(ibuffer),srcCopy);

except;end;
end;


//## tgenerictoolbar ###########################################################

procedure tgenerictoolbar.xcreate(xowner:tcomponent);
begin

//vars
ilist          :=nil;
ivspace        :=1;
ihspace        :=1;
ivpad          :=6;
ihpad          :=7;
iminitemwidth  :=20;
ilist          :=tgenericlist.create;
align         :=altop;

//self
inherited xcreate(xowner);

end;

procedure tgenerictoolbar.xdestroy;
begin
try

//controls
freeobj(@ilist);

except;end;
end;

function tgenerictoolbar.changeid2:longint;//19oct2025
begin
result:=list.changeid;
end;

function tgenerictoolbar.xhaveflash:boolean;
begin
result:=list.haveflash;
end;

function tgenerictoolbar.paintref:string;
begin
result:=(inherited paintref)+'|'+intstr32(list.itemindex);
end;

procedure tgenerictoolbar._ontimer(sender:tobject);
var
   a:tpoint;
begin

//check mouse status
if not mousedown then
   begin

   win____getcursorpos(a);
   a                :=tpoint( screentoclient(windows.tpoint(a)) );
   list.itemindex   :=list.findindexb(a.x,a.y);

   end;

//paint
if mustpaint then paintnow;

end;

procedure tgenerictoolbar.setminitemwidth(x:longint);
begin
if low__setint(iminitemwidth,frcmin32(x,0)) then change;
end;

function tgenerictoolbar.add(const xcode,xtep,xhelp:string):boolean;
begin

result:=list.add(xcode,'',xtep,xhelp);
if not result then exit;

end;

function tgenerictoolbar.add2(const xcode:string;const xtea:array of byte;const xhelp:string):boolean;
begin

result:=list.add2(xcode,'',xtea,xhelp);
if not result then exit;

end;

function tgenerictoolbar.addsep:boolean;
begin
result:=list.addsep;
end;

procedure tgenerictoolbar.xfiltersize(var xnewwidth,xnewheight:longint);
begin

xnewheight:=(2 * ivspace) + (2 * ivpad) + list.xitemheight;

end;

procedure tgenerictoolbar.paint;
var
   p,ih,cw,ch,dy,dx,dw,dh,mw:longint;
   xenabled,xdown:boolean;

   procedure ds(const da:twinrect;const c0,c:longint);//draw shade
   begin
   misclsarea3(ibuffer,area__make(da.left,da.top,da.right,da.top+((da.bottom-da.top+1) div 2)),c0,c,255,255);
   misclsarea3(ibuffer,area__make(da.left,da.top+((da.bottom-da.top+1) div 2),da.right,da.bottom),c,c0,255,255);
   end;

   procedure d(const xindex:longint);//draw item
   var
      xpower,ox:longint;
      xsepOK:boolean;
   begin

   //check
   if (xindex<0) or (xindex>pred(list.count)) then exit;

   //init
   xsepOK    :=list.xissep(xindex);
   ox        :=insint(1, (xdown and (xindex=list.itemindex)) or list.items[xindex].marked );

   case xsepOK or (list.items[p].enabled and xenabled) of
   true:xpower :=255;
   else xpower :=92;
   end;//case

   //focus highlight
   if ((not xsepOK) and (xindex=list.itemindex)) or list.items[xindex].marked then ds( low__shiftarea( area__grow2(list.items[xindex].oa,0,-2), ox, ox ),info.hover0,info.hover);

   //image
   if (not sysflash) or (not list.items[xindex].flash) then
      begin

      case (not xsepOK) of
      true:miscopyarea324(maxarea,ox+list.items[xindex].ia.left,ox+list.items[xindex].ia.top,list.items[xindex].ia.right-list.items[xindex].ia.left+1,list.items[xindex].ia.bottom-list.items[xindex].ia.top+1,misarea(list.items[xindex].img),ibuffer,list.items[xindex].img,0,0,xpower,true);
      else ds( area__make(list.items[xindex].ia.left,0,list.items[xindex].ia.left,ch-1),info.sep0,info.sep);
      end;//case

      end;

   end;

begin

//check
needbuffer;

//init
cw                  :=width;
ch                  :=height;
ih                  :=frcmin32(ch - (2*ivspace) ,0);//image height
xdown               :=mousedown;
xenabled            :=enabled;

//size items
dx:=ihspace;
dy:=ivspace;

for p:=0 to pred(list.count) do if list.items[p].visible then
   begin

   //.image
   case list.xissep(p) of
   true:begin

      dw:=4;
      dh:=1;
      mw:=1;

      end;
   else begin

      dw:=misw(list.items[p].img);
      dh:=mish(list.items[p].img);
      mw:=iminitemwidth;

      end;
   end;//case


   //.outer area
   list.items[p].oa.left    :=dx;
   list.items[p].oa.right   :=dx + (2*ihpad) + frcmin32(dw,mw) - 1;
   list.items[p].oa.top     :=dy;
   list.items[p].oa.bottom  :=ch - 1 - ivspace;

   //.inner area - image area to be rendered
   list.items[p].ia.left    :=dx + ( ((list.items[p].oa.right-list.items[p].oa.left+1) - dw) div 2);
   list.items[p].ia.right   :=list.items[p].ia.left + dw -1;
   list.items[p].ia.top     :=dy + ( ((list.items[p].oa.bottom-list.items[p].oa.top+1) - dh) div 2);
   list.items[p].ia.bottom  :=list.items[p].ia.top + dh -1;

   inc(dx, (list.items[p].oa.right-list.items[p].oa.left+1) );

   end;//p

//cls
ds(area__make(0,0,cw-1,ch-1),info.back0,info.back);

//draw items
for p:=0 to pred(list.count) do if list.items[p].visible then d(p);

//paint
win____stretchblt(canvas.handle,0,0,misw(ibuffer),mish(ibuffer),  ibuffer.dc,0,0,misw(ibuffer),mish(ibuffer),srcCopy);

end;

function tgenerictoolbar.xcandrag:boolean;
begin
result:=(list.findindexb(mousedownxy.x,mousedownxy.y)<>list.findindexb(mousemovexy.x,mousemovexy.y));
end;

procedure tgenerictoolbar.xmousedn;
begin

//check
if not mousedownstroke then exit;

//get
list.itemindex  :=list.findindexb(mousedownxy.x,mousedownxy.y);
change;

end;

procedure tgenerictoolbar.xmousemove;
begin

//update
if not mousedown then
   begin

   list.itemindex:=list.findindexb(mousemovexy.x,mousemovexy.y);
   xshowhint( insstr(list.items[list.itemindex].help,list.itemindex>=0) );

   end;

end;

procedure tgenerictoolbar.xmouseup;
var
   dcmd:string;
begin

//update
change;

//drag on - 0=off, 1=on, 2=ignore
if (not mousedragging) and enabled and (list.itemindex>=0) and (list.itemindex<=pred(list.count)) and
   list.items[list.itemindex].visible and list.items[list.itemindex].enabled and
   code__cancmd(list.items[list.itemindex].code,dcmd) then
   begin

   if assigned(foncmd) then foncmd( self, dcmd );

   end;

end;

//## tgenericgui ###############################################################

procedure tgenericgui.xcreate(xowner:tcomponent);
begin

//controls
ilist          :=tgenericlist.create;
iwrapwidth     :=300;
icontentheight :=0;
icontentwidth  :=0;
ihoverindex    :=-1;

//self
inherited xcreate(xowner);
align        :=alclient;

end;

procedure tgenericgui.xdestroy;
begin
try

//controls
freeobj(@ilist);

except;end;
end;

procedure tgenericgui.bsetcaption(xcode,xval:string);
begin
list.caption[xcode]:=xval;
end;

function tgenericgui.bgetcaption(xcode:string):string;
begin
result:=list.caption[xcode];
end;

procedure tgenericgui.bsetenabled(xcode:string;xval:boolean);
begin
list.enabled[xcode]:=xval;
end;

function tgenericgui.bgetenabled(xcode:string):boolean;
begin
result:=list.enabled[xcode];
end;

procedure tgenericgui.bsetmarked(xcode:string;xval:boolean);
begin
list.marked[xcode]:=xval;
end;

function tgenericgui.bgetmarked(xcode:string):boolean;
begin
result:=list.marked[xcode];
end;

procedure tgenericgui.setwrapwidth(x:longint);
begin
if low__setint(iwrapwidth,frcmin32(x,20)) then change;
end;

function tgenericgui.paintref:string;
begin
result:=intstr32(iwrapwidth)+'|'+intstr32(ihoverindex)+'|'+intstr32(list.itemindex)+'|'+(inherited paintref);
end;

procedure tgenericgui.xmousedn;
begin

list.itemindex :=list.findindexb(mousedownxy.x,mousedownxy.y);
ihoverindex    :=list.itemindex;

xshowhint( list.items[ihoverindex].help );

end;

procedure tgenericgui.xmousemove;
begin

if low__setint(ihoverindex,list.findindexb(mousemovexy.x,mousemovexy.y)) then xshowhint( list.items[ihoverindex].help );

end;

procedure tgenericgui.xmouseup;
var
   dcmd:string;
begin

ihoverindex    :=list.findindexb(mousemovexy.x,mousemovexy.y);

if mouseupstroke and (mousebutton=0) and (not list.xissep(ihoverindex)) and
   code__cancmd(list.items[ihoverindex].code,dcmd) then
   begin

   if assigned(foncmd) then foncmd( self, dcmd );

   end;

end;

function tgenericgui.xhaveflash:boolean;
begin
result:=ilist.haveflash;
end;

procedure tgenericgui.xadd(const xtype,xcode,xcaption,xhelp:string);
begin
list.add(strdefb(xcode,'nil'),xcaption,'',xhelp);
list.items[pred(list.count)].str1:=strdefb(xtype,'line');
end;

procedure tgenericgui.title(const xcode,xcaption:string);
begin
title2(xcode,xcaption,'');
end;

procedure tgenericgui.title2(const xcode,xcaption,xhelp:string);
begin
xadd('title',xcode,xcaption,xhelp);
end;

procedure tgenericgui.line(const xcode,xcaption:string);
begin
line2(xcode,xcaption,'');
end;

procedure tgenericgui.line2(const xcode,xcaption,xhelp:string);
begin
xadd('line',xcode,xcaption,xhelp);
end;

procedure tgenericgui.button(const xcode,xcaption:string);
begin
button2(xcode,xcaption,'');
end;

procedure tgenericgui.button2(const xcode,xcaption,xhelp:string);
begin
xadd('button',xcode,xcaption,xhelp);
end;

procedure tgenericgui.nline;//new line
begin
xadd('newline','','','');
end;

procedure tgenericgui.npart;//part line
begin
xadd('newline.part','','','');
end;

procedure tgenericgui.clear;
begin
list.clear;
end;

//xxxxxxxxxxxxxxxxxxxx//iiiiiiiiiiiiiiiiiiiiiiiiiiiiii//????????????????
procedure tgenericgui.paint;
const
   xmargin   =10;
   xbutHpad  =6;
var
   xcanfinishline,bol1,xdown,xenabled:boolean;
   ow,tw,xlastfont,xwidestline,dback0,dback,dtext,xtextheight,xtitleheight,xpartHeight,lh,xfontsize,v,tx,dx,dy,i,p,th,cw,ch:longint;
   da:twinrect;
   dref,dcmd,n:string;

   procedure ds(const da:twinrect;const c0,c:longint);//draw shade
   begin
   misclsarea3(ibuffer,area__make(da.left,da.top,da.right,da.top+((da.bottom-da.top+1) div 2)),c0,c,255,255);
   misclsarea3(ibuffer,area__make(da.left,da.top+((da.bottom-da.top+1) div 2),da.right,da.bottom),c,c0,255,255);
   end;

   procedure xfont(const denabled,dbold,dbutton:boolean;const dcap:string);
   begin

   if low__setstr(dref,bolstr(denabled)+bolstr(dbold)) then
      begin

      ibuffer.setfont2(info.fontname,false,dbold,true,xfontsize,low__aorb(info.textDis,info.text,denabled),0);

      end;

   tw                 :=wincanvas__textwidth(ibuffer.dc,dcap);
   ow                 :=tw;

   if dbutton then inc(ow,2*xbutHpad);

   end;

   procedure xdrawtext(const dcap:string);
   begin

   if ((dy+lh)>=0) and (dy<=ch) then
      begin

      if (dback<>info.back) or (dback0<>info.back) then ds( area__make(0,dy,cw-1,dy+lh-1), dback0, dback);

      wincanvas__textrect(ibuffer.dc,true,maxarea,dx, dy + ((lh-th) div 2) ,dcap);

      end;

   xwidestline        :=largest32(xwidestline,dx + tw );

   list.items[p].oa   :=area__make(dx,dy,dx+tw-1,dy+lh-1);
   list.items[p].ia   :=list.items[p].oa;

   end;

   procedure xdrawbutton(const dcap:string);
   begin

   if ((dy+lh)>=0) and (dy<=ch) then
      begin

      if (dback<>info.back) or (dback0<>info.back) then ds(area__make(dx,dy,dx+ow-1,dy+lh-1), dback0, dback);

      wincanvas__textrect(ibuffer.dc,true,maxarea,dx+ ((ow-tw) div 2), dy + ((lh-th) div 2) ,dcap);

      end;

   xwidestline        :=largest32(xwidestline,dx + ow );

   list.items[p].oa   :=area__make(dx,dy,dx+ow-1,dy+lh-1);
   list.items[p].ia   :=list.items[p].oa;

   end;

   procedure xfinishline;
   begin

   if xcanfinishline then
      begin

      xcanfinishline:=false;
      inc(dy,lh);
      dx:=xmargin;
      lh:=xtextHeight;

      end;

   end;

   procedure dhoverColor(const xtitle:boolean);
   var
      dcmd:string;
   begin

   case (ihoverindex=p) and list.items[p].enabled and code__cancmd(list.items[p].code,dcmd) of
   true:begin

      dback    :=info.hover;
      dback0   :=info.hover0;

      end;
   else begin

      case xtitle of
      true:begin

         dback    :=info.hover;
         dback0   :=info.hover;

         end;
      else begin

         dback    :=info.back;
         dback0   :=info.back;

         end;
      end;//case

      end;
   end;//case

   end;

begin
try

//init
needbuffer;
xenabled            :=enabled;
dref                :='';
xdown               :=imousedown;
cw                  :=clientwidth;
ch                  :=height;
xlastfont           :=0;
xfontsize           :=frcmin32( strint32(app__info('app.fontsize')), 6);

ibuffer.setfont2(info.fontname,false,false,true,xfontsize,info.text,0);

th                  :=wincanvas__textheight(ibuffer.dc,'W#hq');
xtitleHeight        :=trunc(th*1.8);
xtextHeight         :=trunc(th*1.5);
xpartHeight         :=trunc(th*0.5);
xwidestline         :=0;
xlastfont           :=0;
xcanfinishline      :=false;
tw                  :=0;
ow                  :=0;

//cls
miscls(ibuffer,info.back);

//draw items
dx  :=xmargin;
dy  :=0;

for p:=0 to pred(list.count) do
begin

n:=list.items[p].str1;

if (n='title') then
   begin

   xfinishline;

   if (p<>0) then inc(dy,xpartHeight);

   lh       :=xtitleHeight;

   dhoverColor(true);

   xfont( list.items[p].enabled,true,false,list.items[p].caption );
   xdrawtext( list.items[p].caption );

   inc(dy,xpartHeight);
   inc(dy,lh);

   xcanfinishline:=false;

   end
else if (n='line') then
   begin

   xfinishline;

   lh       :=xtextHeight;
   dhoverColor(false);

   xfont( list.items[p].enabled,false,false, list.items[p].caption );
   xdrawtext( list.items[p].caption );
   inc(dy,lh);

   xcanfinishline:=false;

   end
else if (n='button') then
   begin

   xfont( list.items[p].enabled,false,true, list.items[p].caption );

   if (dx>xmargin) and ((dx+ow)>iwrapwidth) then
      begin

      inc(dy,lh + xpartHeight);
      dx:=xmargin;

      end;

   case list.items[p].enabled and code__cancmd(list.items[p].code,dcmd) and ((ihoverindex=p) or (list.itemindex=p) or list.items[p].marked or (list.items[p].flash and sysflash)) of
   true:begin

      dback    :=info.hover;
      dback0   :=info.hover0;

      end;
   else begin

      dback    :=info.back;
      dback0   :=info.back0;

      end;
   end;//case
   
   dtext    :=info.text;

   xdrawbutton( list.items[p].caption );
   inc(dx, ow + (1*xmargin) );

   xcanfinishline:=true;

   end
else if (n='newline') then
   begin

   xfinishline;

   inc(dy,lh);
   lh:=xtextHeight;
   xcanfinishline:=false;

   end
else if (n='newpartline') then
   begin

   xfinishline;

   inc(dy,xpartHeight);
   lh:=xtextHeight;
   xcanfinishline:=false;

   end
else if (n='finishline') then
   begin

   xfinishline;

   end;


end;//p

//finalise
xfinishline;

//paint
win____stretchblt(canvas.handle,0,0,misw(ibuffer),mish(ibuffer),  ibuffer.dc,0,0,misw(ibuffer),mish(ibuffer),srcCopy);

//size
icontentheight :=dy+xpartHeight;
icontentwidth  :=xwidestline+xmargin;

except;end;
end;


//## tgenericguiform ###########################################################

constructor tgenericguiform.create(xowner:tcomponent);
begin

//self
inherited createnew(xowner);

borderstyle            :=bsSingle;
bordericons            :=[bisystemmenu];
vertscrollbar.visible  :=false;
horzscrollbar.visible  :=false;
caption                :='';
width                  :=50;
height                 :=50;


//controls
igui                   :=tgenericgui.create(self);
igui.backcolor         :=strint32(app__info('app.backcolor'));


//add to form list
app__addwndproc(handle,nil,true);

//timer
low__timerset(self,_ontimer,50);

show;

end;

destructor tgenericguiform.destroy;
begin
try

//timer
low__timerdel(self,_ontimer);

//remove
app__delwndproc(handle);

//self
inherited destroy;

except;end;
end;

procedure tgenericguiform._ontimer(sender:tobject);
begin

if (igui.contentheight<>clientheight) then clientheight :=igui.contentheight;
if (igui.contentwidth <>clientwidth ) then clientwidth  :=igui.contentwidth;

end;


//## splash ####################################################################

constructor tsplash.create(ximagedata:pobject;const xtextcolor:longint;const xtextscale,xhorzscale,xvertscale:single);
var
   e:string;
begin

//self
inherited create;

//vars
iwaiting                      :=false;

iform                         :=tform.create(nil);
iform.vertscrollbar.visible   :=false;
iform.horzscrollbar.visible   :=false;
iform.borderstyle             :=bssingle;
iform.bordericons             :=[bisystemmenu];
gui__stdcursor(iform);
itextcolor                    :=xtextcolor;
itextscale                    :=xtextscale;
ihorzscale                    :=xhorzscale;
ivertscale                    :=xvertscale;

try

iimage                        :=miswin32(1,1);
png__fromdata(iimage,ximagedata,e);

except;end;

//events
iform.onpaint                 :=iform_onpaint;
iform.onclose                 :=iform_onclose;
iform.onmousedown             :=iform_onmousedown;

end;

destructor tsplash.destroy;
begin
try

//controls
freeobj(@iform);
freeobj(@iimage);

//self
inherited destroy;

except;end;
end;

procedure tsplash.splash(xsplash,xfadeEffect:boolean);
const
   xSplashDelay  =1000;
   xFadeLimit    =20;
var
   sbits,sw,sh,p:longint;
   xref:comp;
begin
try

//check
if (not misok82432(iimage,sbits,sw,sh)) or (sw<=2) or (sh<=2) then exit;

//init
xfadeEffect  :=xfadeEffect and app__cansetwindowalpha;

case xsplash of
true:begin

   iform.bordericons:=[];
   iform.borderstyle:=bsnone;

   end;
else begin

   iform.bordericons:=[bisystemmenu];
   iform.borderstyle:=bssingle;

   end;
end;//case

iform.caption      :=translate('About');
iform.keypreview   :=true;
iform.onkeydown    :=iform_onkey;


//show
if xfadeEffect and (not xsplash) then
   begin

   //shrink form -> show -> hide to avoid initial full clientarea being momentarily visible even when alpha is set to 0
   iform.width:=1;
   iform.height:=1;
   form__centerByCursor(iform);
   iform.show;
   app__setwindowalpha(iform.handle,0);
   iform.hide;

   end;

//size
if xfadeEffect then app__setwindowalpha(iform.handle,0);

iform.clientwidth:=misw(iimage);
iform.clientheight:=mish(iimage);
form__centerByCursor(iform);
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

procedure tsplash.iform_onmousedown(sender: tobject; button: tmousebutton; shift: tshiftstate; x, y: integer);
begin

iwaiting:=false;

end;

procedure tsplash.iform_onclose(sender: tobject; var Action: TCloseAction);
begin

iwaiting:=false;

end;

procedure tsplash.iform_onkey(sender: tobject; var key: word; shift: tshiftstate);
begin

if (key=27) then
   begin

   iwaiting:=false;

   end;

end;

procedure tsplash.iform_onpaint(sender:tobject);
var
   xonce:boolean;
   th,dx,dy:longint;

   procedure ladd(x:string);
   begin

   iform.canvas.textout(dx,dy,x);
   dec(dy,th);

   end;

begin
try

//init
xonce    :=true;
iform.canvas.brush.style:=bsClear;
iform.canvas.font.name:='Sans Serif';
iform.canvas.font.size:=frcmin32( trunc(9*itextscale), 6 );
iform.canvas.font.style:=[fsBold];
iform.canvas.font.color:=itextcolor;
th       :=trunc(1.2*iform.canvas.textheight('#weravxckljaweWERLJKASDf'));
dx       :=trunc(10*itextscale) +trunc( (ihorzscale/100) * mish(iimage) );
dy       :=iform.clientheight-th-trunc(10*itextscale) - trunc( (ivertscale/100) * mish(iimage) );

//background
win____StretchBlt(iform.canvas.handle,0,0,misw(iimage),mish(iimage),  iimage.dc,0,0,misw(iimage),mish(iimage),srcCopy);

//text
if (app__info('splash.web')<>'') then ladd(app__info('splash.web'));
ladd('Copyright: '+app__info('copyright'));
ladd('Codebase: '+app__info('codebase'));
ladd('License: '+app__info('license'));
ladd('Version: '+app__info('ver'));

except;end;
end;



{$ifdef gui4}

//clipboard procs --------------------------------------------------------------
function clip__hasformat(xformat:uint):boolean;
begin
result:=win____IsClipboardFormatAvailable(xformat);
end;

function clip__opened(var xopened:boolean):boolean;//01sep2025
var
   p:longint;
begin

for p:=1 to 10 do
begin

xopened   :=win____OpenClipboard(app__mainformHandle);
result    :=xopened;

if result then break else win____sleep(1);

end;//p

end;

function clip__openedAndclear(var xopened:boolean):boolean;//01sep2025
var
   p,h:longint;
begin

for p:=1 to 10 do
begin

xopened   :=win____OpenClipboard(app__mainformHandle);
result    :=xopened and win____EmptyClipboard;

if result then break else win____sleep(1);

end;//p

end;

function clip__cancopytext:boolean;//20mar2021
begin
result:=true;
end;

function clip__copytext(const xdata:string):boolean;//01sep2025, 26apr2025
var
   d:tstr8;
   p,xlen:longint;
   xopened:boolean;

begin

//defaults
result      :=false;
xopened     :=false;
d           :=nil;
xlen        :=low__len(xdata);

try

//init
d:=str__new8;
d.makeglobal;

//get
if d.setlen(xlen+1) and clip__openedAndclear(xopened) then
   begin

   //get
   for p:=1 to xlen do d.pbytes[p-1]:=byte(xdata[p-1+stroffset]);
   d.pbytes[xlen]:=0;

   //set
   result:=(0<>win____setclipboarddata(CF_TEXT,d.handle));
   if result then d.ejectcore;

   end;

except;end;

//free
freeobj(@d);

//close clipboard
if xopened then win____CloseClipboard;

end;

function clip__copytext2(xdata:pobject):boolean;//01sep2025, 01jun2025, 26apr2025
var
   d:tstr8;
   xlen,p:longint;
   xopened:boolean;
begin
//defaults
result      :=false;
xopened     :=false;
d           :=nil;

try
//init
if str__lock(xdata) then
   begin

   d    :=str__new8;
   d.makeglobal;//15may2025
   xlen :=str__len(xdata);//01jun2025

   //get
   if d.setlen(xlen+1) and clip__openedAndclear(xopened) then
      begin

      //get
      for p:=0 to (xlen-1) do d.pbytes[p]:=str__pbytes0(xdata,p);
      d.pbytes[xlen]:=0;

      //set
      result:=(0<>win____setclipboarddata(CF_TEXT,d.handle));
      if result then d.ejectcore;

      end;

   end;

except;end;

//free
freeobj(@d);
str__uaf(xdata);

//close clipboard
if xopened then win____CloseClipboard;

end;

function clip__canpastetext:boolean;//16mar2021
begin
result:=clip__hasformat(cf_text);
end;

function clip__pastetext(var xdata:string):boolean;//01sep2025, 27apr2025
var
   h:thandle;
   xopened:boolean;
begin
//defaults
result   :=false;
xdata    :='';
xopened  :=false;

try

if clip__canpastetext and clip__opened(xopened) then
   begin

   //get
   h:=win____GetClipboardData(cf_text);

   try

   if (h<>0) then
      begin

      xdata:=pchar(win____globallock(h));
      result:=true;

      end;

   except;end;

   //unlock but DO NOT free -> the Clipboard owns this memory handler
   if (h<>0) then win____globalunlock(h);

   end;

except;end;

//close clipboard
if xopened then win____closeclipboard;

end;

function clip__pastetextb:string;//27apr2025
begin
clip__pastetext(result);
end;

function clip__pastetext2(xdata:pobject):boolean;//27apr2025
label
   skipend;
var
   h:thandle;
   xopened:boolean;
begin
//defaults
result  :=false;
xopened :=false;

try
//check
if     str__lock(xdata)  then str__clear(xdata) else goto skipend;
if not clip__canpastetext then goto skipend;

//get
if clip__opened(xopened) then
   begin

   //get
   h:=win____GetClipboardData(cf_text);

   try;result:=str__settext(xdata, pchar(win____globallock(h)) );except;end;

   //unlock but DO NOT free -> the Clipboard owns this memory handler
   win____globalunlock(h);

   end;


skipend:
except;end;

//clear on error
if not result then str__clear(xdata);

//free
str__uaf(xdata);

//close clipboard
if xopened then win____CloseClipboard;

end;

function clip__canpasteimage:boolean;//29apr2025
begin
result:=clip__hasformat(cf_png) or clip__hasformat(cf_dibv5) or clip__hasformat(cf_dib) or clip__hasformat(cf_bitmap);
end;

function clip__pasteimage(d:tobject):boolean;//12jun2025, 08jun2025, 01jun2025, 29apr2025
label
   skipend;
var
   e:string;
   a:tstr8;
   xopened:boolean;
   xbmp:tbitmapheader;
   xinfo:TBitmapInfoHeader;
   xdc:hdc;
   cbmp:hbitmap;
   dr32:pcolorrow32;
   dr24:pcolorrow24;
   dr8 :pcolorrow8;
   c24:tcolor24;
   c32:tcolor32;
   dpos,drowsize,xlen,sbits,dbits,dy,dx,dw,dh:longint;
   hmem:hglobal;
   hptr:pointer;
   hlist:pdlbyte;

   procedure xpull32;
   begin
   c32.b:=hlist[dpos+0];
   c32.g:=hlist[dpos+1];
   c32.r:=hlist[dpos+2];
   c32.a:=hlist[dpos+3];
   inc(dpos,4);
   end;

   procedure xpull24;
   begin
   c24.b:=hlist[dpos+0];
   c24.g:=hlist[dpos+1];
   c24.r:=hlist[dpos+2];
   inc(dpos,3);
   end;
begin
//defaults
result  :=false;
a       :=nil;
xdc     :=0;
hmem    :=0;
hptr    :=nil;
xopened :=false;

try

//check
if not clip__opened(xopened)   then goto skipend;
if not misokk82432(d)          then goto skipend;

//init
dbits  :=misb(d);
a      :=str__new8;

//png
if (not result) and clip__hasformat(cf_png) then
   begin
   try
   a.clear;
   a.makeglobalFROM( win____GetClipboardData(cf_png) , false);
   if (a.len>=1) then
      begin
      result:=png__fromdata(d,@a,e);
      a.ejectcore;
      end;
   except;end;
   end;

//dibv5
if (not result) and clip__hasformat(cf_dibv5) then
   begin
   try
   a.clear;
   a.makeglobalFROM( win____GetClipboardData(cf_dibv5) , false);
   if (a.len>=1) then
      begin
      result:=bmp32__fromdata2(d,@a,true);//allow the "dib_patch_12" mode
      a.ejectcore;
      end;
   except;end;
   end;

//dib
if (not result) and clip__hasformat(cf_dib) then
   begin
   try
   a.clear;
   a.makeglobalFROM( win____GetClipboardData(cf_dib) , false);
   if (a.len>=1) then
      begin
      result:=bmp32__fromdata(d,@a);
      a.ejectcore;
      end;
   except;end;
   end;

//bitmap
if (not result) and clip__hasformat(cf_bitmap) then
   begin
   //get handle to "hbitmap" in Clipboard
   cbmp:=win____GetClipboardData(cf_bitmap);
   if (cbmp=0) then goto skipend;

   low__cls(@xbmp,sizeof(xbmp));
   if (0=win____getobject(cbmp,sizeof(xbmp),@xbmp)) then goto skipend;

   dw   :=xbmp.bmwidth;
   dh   :=xbmp.bmheight;
   sbits:=32;//force as 32 bits - 01jun2025
   if (dw<1) or (dh<1) then goto skipend;

   low__cls(@xinfo,sizeof(xinfo));
   xinfo.bisize       :=sizeof(xinfo);
   xinfo.biwidth      :=dw;
   xinfo.biheight     :=dh;
   xinfo.biBitCount   :=sbits;
   xinfo.biPlanes     :=1;
   xinfo.biCompression:=0;

   xdc:=win____getdc(0);
   if (0=win____GetDIBits(xdc,cbmp,0,dh,nil,xinfo,DIB_RGB_COLORS)) then goto skipend;
   if (dw<=0) or (dh<=0) or ((sbits<>24) and (sbits<>32)) then goto skipend;

   //init
   drowsize  :=mis__rowsize4(dw,sbits);//27may2025
   xlen      :=dh * drowsize;

   //get pixels
   hmem:=win____GlobalAlloc(GMEM_MOVEABLE,xlen);
   hptr:=win____Globallock(hmem);
   hlist:=hptr;

   if (0=win____GetDIBits(xdc,cbmp,0,dh,hptr,xinfo,DIB_RGB_COLORS)) then goto skipend;

   //read pixels
   if not missize(d,dw,dh) then goto skipend;

   for dy:=0 to (dh-1) do
   begin
   if not misscan82432(d,dy,dr8,dr24,dr32) then goto skipend;

   dpos:=(dh-1-dy)*drowsize;

   //32 -> 32
   if (sbits=32) and (dbits=32) then
      begin
      for dx:=0 to (dw-1) do
      begin
      xpull32;
      dr32[dx]:=c32;
      end;
      end
   //32 -> 24
   else if (sbits=32) and (dbits=24) then
      begin
      for dx:=0 to (dw-1) do
      begin
      xpull32;
      c24.r:=c32.r;
      c24.g:=c32.g;
      c24.b:=c32.b;
      dr24[dx]:=c24;
      end;
      end
   //32 -> 8
   else if (sbits=32) and (dbits=8) then
      begin
      for dx:=0 to (dw-1) do
      begin
      xpull32;
      if (c32.g>c32.r) then c32.r:=c32.g;
      if (c32.b>c32.r) then c32.r:=c32.b;
      dr8[dx]:=c32.r;
      end;
      end
   //24 -> 32
   else if (sbits=24) and (dbits=32) then
      begin
      for dx:=0 to (dw-1) do
      begin
      xpull24;
      c32.r:=c24.r;
      c32.g:=c24.g;
      c32.b:=c24.b;
      c32.a:=255;
      dr32[dx]:=c32;
      end;
      end
   //24 -> 24
   else if (sbits=24) and (dbits=24) then
      begin
      for dx:=0 to (dw-1) do
      begin
      xpull24;
      dr24[dx]:=c24;
      end;
      end
   //24 -> 8
   else if (sbits=24) and (dbits=8) then
      begin
      for dx:=0 to (dw-1) do
      begin
      xpull24;
      if (c24.g>c24.r) then c24.r:=c24.g;
      if (c24.b>c24.r) then c24.r:=c24.b;
      dr8[dx]:=c24.r;
      end;
      end;
   end;//dy

   //detect an empty mask and convert to a visible mask
   if mask__empty(d) then mask__setval(d,255);

   //successful
   result:=true;
   end;

skipend:
except;end;
try

//clear on error
if not result then missize(d,1,1);

//free
if (hptr<>nil) then win____globalunlock(hmem);
if (hmem<>0)   then win____globalfree(hmem);
if (xdc<>0)    then win____deletedc(xdc);

//a
if (a<>nil) then a.ejectcore;//let go of global memory + unlock it -> only ever read-only from Clipboard supplied handle, so OK to eject an empty core - 09jun2025
str__free(@a);

//close clipboard
if xopened then win____CloseClipboard;

except;end;
end;

function clip__cancopyimage:boolean;//12apr2021
begin
result:=true;
end;

function clip__copyimage(s:tobject):boolean;//10jun2025, 09jun2025, 26apr2025
label
   skipend;
var
   e:string;
   d:tstr8;
   sbits,sw,sh:longint;
   xopened,shasai:boolean;
begin
//defaults
result      :=false;
xopened     :=false;
d           :=nil;

try
//open clipboard
if not clip__openedAndclear(xopened) then goto skipend;

//init
if not misinfo(s,sbits,sw,sh,shasai) then goto skipend;
d:=str__new8;

//write PNG - only if image has transparent pixels - MS Paint for Win11 requires PNG, whereas Gimp v2.10.34 accepts PNG/DIB
if mask__hasTransparency32(s) then
   begin
   d.makeglobal;
   if not png__todata(s,@d,e)                      then goto skipend;
   if (0=win____setclipboarddata(cf_png,d.handle)) then goto skipend;
   d.ejectcore;
   end;

//write DIBv5
d.makeglobal;
//if not bmp32__todata3(s,@d,false,hsV05,low__aorb(32,24,misb(s)=24)) then goto skipend;
if not bmp32__todata3(s,@d,false,hsV05,32)          then goto skipend;
if (0=win____setclipboarddata(cf_dibv5,d.handle))   then goto skipend;//11jun2025: fixed
d.ejectcore;

//write DIBv1
d.makeglobal;
if not bmp32__todata3(s,@d,false,hsW95,24)      then goto skipend;//use old V1 header which has no transparency for backward compatibility such as WordPad on Win11 - 09jun2025
if (0=win____setclipboarddata(cf_dib,d.handle)) then goto skipend;
d.ejectcore;

//successful
result:=true;
skipend:
except;end;

//free
freeobj(@d);

//close clipboard
if xopened then win____CloseClipboard;

end;
{$endif}


end.
