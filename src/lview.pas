unit lview;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses {$ifdef gui4}sysutils, windows, forms, controls, classes, {$endif} lroot, lwin, lwin2, lform {$ifdef gui2}, limg, limg2{$endif};
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
//## Version.................. 1.00.352 (+16)
//## Items.................... 1
//## Last Updated ............ 19oct2025, 13oct2025, 12oct2025, 10oct2025, 08oct2025, 05oct2025, 17nov2007, 26aug2007
//## Lines of Code............ 1,000+
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
//## | texeviewer             | tobject           | 1.00.350  | 19oct2025   | Text2EXE exe viewer handler - 17nov2007, 26aug2007
//## ==========================================================================================================================================================================================================================


const
   t2eProgramName  ='Text2EXE';
   t2eVersion      ='1.00.1500';//for EXE Viewer: 05oct2025, 17nov2007, 12aug2005
   t2eWidth        =700;
   t2eHeight       =650;
   t2eBRColor      =252 + 216*256 + 163*256*256;
   t2eBGColor      =255 + 255*256 + 244*256*256;
   t2eBorder       =42;
   t2eBRStyle      ='Sleek';

type

{texeviewer}
   texeviewer=class(tobject)
   private

    icursorimage,isplashimage,iaboutimage:tstr8;
    imaingui,ilocked,icancopy,iautotitle:boolean;
    ibrstyle,iauthor,ipassword:string;
    ibrcolor,ibgcolor,iborder:longint;
    imenu:tlitemenu;
    iform:tliteform;
    irichedit:tliterichedit;

    procedure _onclose(sender:tobject);
    procedure _onpaint(sender:tobject);
    procedure _onresize(sender:tobject);
    procedure formmousedown(sender: tobject; button: tmousebutton; shift: tshiftstate; x, y: integer);
    procedure setborder(x:integer);
    procedure setbrstyle(x:string);
    procedure setbgcolor(x:integer);
    procedure setbrcolor(x:longint);
    procedure xupdatemenu(sender:tobject);
    procedure _onactivate(sender:tobject);
    procedure _onesc(sender:tobject);
    procedure _oncode(sender:tobject);
    procedure xprocesskeystrokes;
    procedure xexeViewerLoad;//05oct2025
    procedure xcmd(sender:tobject;const xcode:string);

   public

    //create
    constructor create(dmaingui:boolean); virtual;//05oct2025
    destructor destroy; override;

    //core
    property form      :tliteform        read iform;
    property richedit  :tliterichedit    read irichedit;

    //information
    property maingui:boolean             read imaingui;

    //user options
    property password  :string           read ipassword       write ipassword;
    property bgcolor   :integer          read ibgcolor        write setbgcolor;
    property brcolor   :longint          read ibrcolor        write setbrcolor;
    property brstyle   :string           read ibrstyle        write setbrstyle;
    property border    :integer          read iborder         write setborder;
    property author    :string           read iauthor         write iauthor;
    property cancopy   :boolean          read icancopy        write icancopy;
    property autotitle :boolean          read iautotitle      write iautotitle;
    //saveas
    function cansaveas:boolean;
    procedure saveas(const xdesktop:boolean);//08oct2025

    //options
    procedure info;//author and software details

    function cansplash:boolean;//optional graphical splash screen on startup
    procedure splash;
    procedure splash__setimagedata(xdata:pobject);
    property splashimage:tstr8 read isplashimage;

    function canabout:boolean;//optional about branding graphic on "right click > about"
    procedure about;
    procedure about__setimagedata(xdata:pobject);
    property aboutimage:tstr8 read iaboutimage;

    function cancursor:boolean;//optional custom cursor -> static and animated
    procedure cursor__setimagedata(xdata:pobject);
    property cursorimage:tstr8 read icursorimage;

    procedure clear;

    //io
    function readfromexe(const x:string;var e:string;var xpasstoEdit,xpasstoView:boolean):boolean;
    function readfromstr(x:string;var e:string;var xpasstoEdit,xpasstoView:boolean):boolean;
    function writetostr(var x,e:string;const xfilenameForRef:string;xpasstoEdit,xpasstoView,xpromptforPassword:boolean):boolean;

    //support
    function xcanreplaceexe(const x:string;var e:string):boolean;

   end;

implementation

uses lio;


//## ttextgui ##################################################################

constructor texeviewer.create(dmaingui:boolean);
var
   a,x,l:longint;
   e:string;
begin

//self
inherited create;

//vars
imaingui          :=dmaingui;
isplashimage      :=str__new8;
iaboutimage       :=str__new8;
icursorimage      :=str__new8;
icancopy          :=true;
iautotitle        :=true;
iborder           :=0;
ibgcolor          :=0;//background color
ibrcolor          :=0;//border color
ibrstyle          :='';
iform             :=nil;
iform             :=tliteform.createForm(imaingui,not imaingui);
imenu             :=tlitemenu.create;

imenu.add('&Copy'             ,'copy');
imenu.addsep;
imenu.add('&About'            ,'about');
imenu.add('Auth&or'           ,'author');
imenu.add('Save a&s'          ,'saveas');
imenu.add('Save to &Desktop'  ,'saveas.desktop');
imenu.addsep;
imenu.add('E&xit',            'exit');

irichedit         :=tliterichedit.create(iform.handle);
irichedit.bounds  :=iform.clientrect;
irichedit.menu    :=imenu;
irichedit.visible :=true;
irichedit.readonly:=not imaingui;//04oct2025

//events
iform.onpaint     :=_onpaint;      
iform.onresize    :=_onresize;
iform.onclose     :=_onclose;
iform.onmousedown :=formmousedown;
iform.onesc       :=_onesc;
irichedit.onesc   :=_onesc;
imenu.onpop       :=xupdatemenu;
imenu.oncode      :=_oncode;

//richedit
irichedit.maxlength:=0;

//.force RichEdit control to accept large document sizes by force feeding it 1.2Mb of text
if imaingui then
   begin

   irichedit.fromstr( makestrb(409600*3,llA), e );//1.2288mb
   irichedit.fromstr('',e);

   end;


//start
clear;
_onresize(self);

//exeViewerLoad
if not imaingui then xexeViewerLoad;

end;

destructor texeviewer.destroy;
begin
try

//main form
if not imaingui then app__setmainform(nil);

//controls
freeobj(@imenu);
freeobj(@irichedit);
freeobj(@iform);
str__free(@iaboutimage);
str__free(@isplashimage);
str__free(@icursorimage);

//self
inherited destroy;

except;end;
end;

function texeviewer.xcanreplaceexe(const x:string;var e:string):boolean;
label
   skipend;
var
   etmp:string;
   xdata:tstr8;
   p:longint;
begin

//defaults
result :=true;
e      :=gecAProgramexistswiththatname + rcode + gecuseanother;
xdata  := nil;

//check
if not io__fileexists(x)                        then exit;
if not strmatch(io__readfileext(x,false),'exe') then exit;

try
//init
xdata  :=str__new8;

//read the exe and search for io__exemarker -> if present pressume it's safe to replace
if not io__fromfile(x,@xdata,etmp)      then goto skipend;

//it's a match -> ok to replace
if io__hasmarker(@xdata,false)          then goto skipend;

//error -> exe is unknown to us and therefore it's unsafe to replace it - 04oct2025
result        :=false;

skipend:
except;end;

//free
str__free(@xdata);

end;

function texeviewer.cansaveas:boolean;
begin
result:=not imaingui;
end;

procedure texeviewer.xcmd(sender:tobject;const xcode:string);
var
   e:string;

   function m(const x:string):boolean;
   begin
   result:=strmatch(x,xcode);
   end;

begin

if m('copy') then
   begin

   if not irichedit.copytoclipboard(e) then showerror(e);

   end
else if m('author')             then info
else if m('about')              then about
else if m('saveas')             then saveas(false)
else if m('saveas.desktop')     then saveas(true)
else if m('exit')               then app__halt;

end;

procedure texeviewer.saveas(const xdesktop:boolean);//08oct2025
label
   redo;
var
   df,xfilterlist,e:string;
begin

//check
if not cansaveas then exit;

//init
case xdesktop of
true:df:=io__windesktop+io__extractfilename(io__exename);
else df:=io__exename;
end;//case

xfilterlist:=dialog__mask('Text2EXE Documents','*.exe');

//get
redo:

if dialog__save(df,xfilterlist) then
   begin

   if xcanreplaceexe(df,e) then
      begin

      if not io__copyfile(io__exename,df,e) then
         begin

         showerror(e);
         goto redo;

         end;

      end
   else
      begin

      showerror(e);
      goto redo;

      end;

   end;

end;

procedure texeviewer.clear;
var
   n,v,e:string;
   p:longint;
begin

iform.text        :='';
irichedit.fromstr('',e);
border            :=t2eBorder;
bgcolor           :=t2eBGColor;
brcolor           :=t2eBRColor;
brstyle           :='flat';

for p:=0 to max16 do
begin

case form__brstyles(p,n,v) of
true:if strmatch(n,t2eBRStyle) then
   begin

   brstyle:=v;
   break;

   end;
else break;
end;//case

end;//p

iauthor           :='';
ipassword         :='';

isplashimage.clear;
iaboutimage.clear;
icursorimage.clear;

iform.width       :=t2eWidth;
iform.height      :=t2eHeight;

app__setcustomcursor(nil);

end;

procedure texeviewer.xexeViewerLoad;//05oct2025
var
   e:string;
   bol1,bol2:boolean;
begin

app__setmainform(form);

if not readfromexe( io__exename, e, bol1, bol2 ) then
   begin

   if not strmatch(e,gecTaskCancelled) then showerror(e);
   app__halt;
   exit;

   end;

richedit.ctrl:=cancopy;

splash;//05oct2025

form__centerByCursor(form);
form.show;

end;

procedure texeviewer._onesc(sender:tobject);
begin//close program

if (not imaingui) and (not ilocked) then xcmd(self,'exit');

end;

procedure texeviewer._oncode(sender:tobject);
begin

if (sender=imenu) then xcmd(imenu,imenu.code);

end;

function texeviewer.readfromexe(const x:string;var e:string;var xpasstoEdit,xpasstoView:boolean):boolean;
label
   skipend;
var
   xdata:tstr8;
begin

//defaults
result        :=false;
e             :=gecTaskfailed;
xdata         :=nil;
xpasstoEdit   :=false;
xpasstoView   :=false;

try
//init
xdata         :=str__new8;

//read
if not io__fromfile(x,@xdata,e)             then goto skipend;

//split on io__exemarker
e:=gecunknownformat;
if not io__hasmarker(@xdata,true)           then goto skipend;

//read
if not readfromstr(xdata.text,e,xpasstoEdit,xpasstoView)  then goto skipend;

//successful
result:=true;
skipend:

except;end;

//free
str__free(@xdata);

end;

function texeviewer.readfromstr(x:string;var e:string;var xpasstoEdit,xpasstoView:boolean):boolean;
label
   skipend;
var
   s:tstr8;
   dl,xpos:integer;
   dpassword,n,v:string;
   dautotitle:boolean;
   w,h:integer;
   c:twinrect;

   function r:boolean;
   begin
   result:=str__pullval(xpos,x,n,v);
   end;

begin

//defaults
result        :=false;
e             :=gecunknownformat;
xpos          :=1;
s             :=nil;
w             :=t2eWidth;
h             :=t2eHeight;
dpassword     :='';
xpasstoEdit   :=false;
xpasstoView   :=false;
dautotitle    :=false;

try
//init
s             :=str__new8;

//dencrypt to view
if (strcopy1(x,1,4)='TBTA') then
   begin

   //prompt for password
   if not dialog__password(dpassword) then
      begin

      e:=gecTaskcancelled;
      goto skipend;

      end;

   //decrypt
   s.text:=strcopy1(x,5,low__len(x));
   if not low__encrypt(s,dpassword,1000,false,e) then
      begin

      e:=gecAccessdenied;
      goto skipend;

      end;

   //get
   xpasstoView:=true;
   xpasstoEdit:=true;
   x:=s.text;
   s.clear;
   end;


//header
if (strcopy1(x,1,4)<>'TTE2') then goto skipend;

//other
e             :=gecdatacorrupt;

//decrypt
x             :=str__ecap2( strcopy1(x, 5,low__len(x)) ,false,true);
if (x='') then goto skipend;

//decompress
s.text        :=x;

low__decompress(@s);

x             :=s.text;
s.clear;

//init
e             :=gecUnknownFormat;

if not r then goto skipend;
if (n<>'head') or (v<>'v2') then goto skipend;

//get
while r do
begin

//.prompt for editing password
if (n='passhash') then
   begin

   //ask host -> editing permission based on password-hash match
   if imaingui and (v<>'') then
      begin

      e:=gecaccessdenied;

      //prompt user for password
      case (dpassword<>'') or dialog__password(dpassword) of
      true:if (v<>str__makehash(dpassword)) then goto skipend;
      else begin

         e:=gecTaskCancelled;
         goto skipend;

         end;
      end;//case

      end;

   xpasstoEdit:=true;
   end

else if (n='start')      then clear

else if (n='title')      then iform.text:=v
else if (n='cancopy')    then icancopy:=strbol(v)
else if (n='autotitle')  then dautotitle:=strbol(v)//13oct2025
else if (n='width')      then w:=frcmin32( strint32(v) ,1)
else if (n='height')     then h:=frcmin32( strint32(v) ,1)

else if (n='bgcolor')    then bgcolor:=strint32(v)
else if (n='brcolor')    then brcolor:=strint32(v)
else if (n='brstyle')    then brstyle:=v//10oct2025
else if (n='brsize')     then border:=strint32(v)

else if (n='author')     then iauthor:=v
else if (n='doctext')    then
   begin

   if not irichedit.fromstr(v,e) then goto skipend;

   end

else if (n='splash')     then isplashimage.text :=v
else if (n='about')      then iaboutimage.text  :=v
else if (n='cursor')     then icursorimage.text :=v

end;//loop

//size
c             :=iform.bounds;
c.right       :=w;
c.bottom      :=h;
iform.bounds  :=c;

app__setcustomcursor( @icursorimage );


//retain password for editing
if imaingui then ipassword:=dpassword;

iautotitle:=dautotitle;

//successful
result:=true;
skipend:

except;end;

//free
str__free(@s);

end;

function texeviewer.writetostr(var x,e:string;const xfilenameForRef:string;xpasstoEdit,xpasstoView,xpromptforPassword:boolean):boolean;
label
   skipend;
var
   dtitle,dpassword,v:string;
   s:tstr8;

   function w(const xname,xval:string):boolean;
   begin
   result:=str__addval(x,xname,xval);
   end;

begin

//defaults
result         :=false;
e              :=gecTaskfailed;
s              :=nil;
x              :='';
v              :='';
dpassword      :=password;

try

//require a password to save
if (xpasstoEdit or xpasstoView) and (dpassword='') then
   begin

   if xpromptforPassword then
      begin

      dialog__password(dpassword);
      if (dpassword='') then goto skipend;

      //set
      ipassword:=dpassword;

      end
   else dpassword:='default';//set

   end;

//get
if not w('head'     ,'v2')                   then goto skipend;

//.optional password hash for editing permission - 13oct2025
if xpasstoEdit and (dpassword<>'') then
   begin

   if not w('passhash' ,str__makehash(dpassword)) then goto skipend;

   end;

if not w('start'     ,'')                     then goto skipend;

case iautotitle and (xfilenameForRef<>'') of
true:begin

   dtitle:=io__remlastext(io__extractfilename(xfilenameForRef));
   if not w('title',dtitle)       then goto skipend;
   iform.text:=dtitle;

   end;
else if not w('title',iform.text) then goto skipend;
end;//case

if not w('cancopy'   ,bolstr(icancopy))       then goto skipend;
if not w('autotitle' ,bolstr(iautotitle))     then goto skipend;
if not w('width'     ,intstr32(iform.width))  then goto skipend;
if not w('height'    ,intstr32(iform.height)) then goto skipend;
if not w('bgcolor'   ,intstr32(bgcolor))      then goto skipend;
if not w('brcolor'   ,intstr32(brcolor))      then goto skipend;
if not w('brsize'    ,intstr32(border))       then goto skipend;
if not w('brstyle'   ,brstyle)                then goto skipend;
if not w('author'    ,iauthor)                then goto skipend;

//document text (as rtf)
if not irichedit.tostr(v,e,true)            then goto skipend;
if not w('doctext'  ,v)                     then goto skipend;
v:='';

//splash imagedata - optional
if not w('splash'   ,isplashimage.text)      then goto skipend;

//about imagedata - optional
if not w('about'    ,iaboutimage.text)        then goto skipend;

//cursor imagedata - optional
if not w('cursor'   ,icursorimage.text)       then goto skipend;

//compress
s        :=str__new8;
s.text   :=x;
low__compress(@s);
x        :=s.text;
s.clear;

//v2 header + encrypted data
x:='TTE2' + str__ecap2(x,true,true);

//encrypt to view
if xpasstoView and (dpassword<>'') then
   begin
   s.text:=x;
   if not low__encrypt(s,dpassword,1000,true,e) then goto skipend;
   x:='TBTA'+s.text;
   s.clear;
   end;

//successful
result:=true;
skipend:

except;end;

//free
str__free(@s);

end;

procedure texeviewer._onpaint(sender:tobject);
var
   a:twinbmp;
begin

//defaults
a           :=nil;

try

//get
a           :=miswin24(1,1);
form__drawbrstyle(a,iform.paintdc,iform.clientwidth,iform.clientheight,border,brcolor,area__make(richedit.left,richedit.top,richedit.left+richedit.width-1,richedit.top+richedit.height-1),brstyle);

except;end;

//free
freeobj(@a);

end;

procedure texeviewer._onresize(sender:tobject);
var
   a:twinrect;
   by:longint;
begin

//check
if (iform=nil) or (irichedit=nil) then exit;

by                :=iborder;

a                 :=iform.clientrect;

a.left            :=a.left+by;
a.top             :=a.top+by;
a.right           :=a.right-2*by;
a.bottom          :=a.bottom-2*by;

irichedit.bounds  :=a;

end;

procedure texeviewer.setborder(x:longint);
begin

if low__setint( iborder, frcrange32(x,0,255) ) then
   begin

   _onresize(self);
   iform.paintnow;

   end;

end;

procedure texeviewer.setbrstyle(x:string);
var
   p:longint;
   dv,n,v:string;
begin

dv:='';

for p:=0 to max16 do
begin

case form__brstyles(p,n,v) of
true:if strmatch(v,x) then
   begin

   dv:=v;
   break;

   end;
else break;
end;

end;//p

ibrstyle:=dv;
iform.paintnow;

end;

procedure texeviewer.setbgcolor(x:longint);
var
   a:wparam;
begin

if (x<0) then a:=-x else a:=0;

win____sendmessage( irichedit.handle, em_setbkgndcolor, a, x );

ibgcolor:=x;

end;

procedure texeviewer.setbrcolor(x:longint);
begin

ibrcolor:=x;
iform.paintnow;

end;

procedure texeviewer.formmousedown(sender:tobject;button:tmousebutton;shift:tshiftstate;x,y:integer);
begin

if (imenu<>nil) then imenu.popnow(iform.handle);

end;

procedure texeviewer.xupdatemenu(sender:tobject);
var
   ok:boolean;
begin

//init
ok:=not imaingui;

//links
imenu.enabled['copy']           :=icancopy and irichedit.cancopytoclipboard;
imenu.enabled['author']         :=true;
imenu.enabled['about']          :=canabout;
imenu.enabled['exit']           :=ok;
imenu.enabled['saveas']         :=cansaveas;
imenu.enabled['saveas.desktop'] :=cansaveas;

end;

procedure texeviewer.xprocesskeystrokes;
begin

win____sleep(250);//must be 100ms or higher for this to work
if not imaingui then app__processmessages;

end;

function texeviewer.cancursor:boolean;
begin
result:=(str__len(@icursorimage)>=2);
end;

procedure texeviewer.cursor__setimagedata(xdata:pobject);
begin

str__clear(@icursorimage);
str__add(@icursorimage,xdata);
app__setcustomcursor(@icursorimage);

end;

function texeviewer.cansplash:boolean;
begin
result:=(str__len(@isplashimage)>=2);
end;

procedure texeviewer.splash;
begin
if cansplash then dialog__litesplash2(@isplashimage,true,true);
end;

procedure texeviewer.splash__setimagedata(xdata:pobject);
begin
str__clear(@isplashimage);
str__add(@isplashimage,xdata);
end;

function texeviewer.canabout:boolean;
begin
result:=(str__len(@iaboutimage)>=2);
end;

procedure texeviewer.about;
begin
if canabout then dialog__litesplash2(@iaboutimage,false,false);
end;

procedure texeviewer.about__setimagedata(xdata:pobject);
begin
str__clear(@iaboutimage);
str__add(@iaboutimage,xdata);
end;

procedure texeviewer.info;
var
   y,x:string;
   p,maxp:integer;
begin
try
ilocked :=true;
x       :='';
y       :=strdefb( stripwhitespace_lt(author),'( no details )');

//about the author
x:=x+strup('author')+rcode;
x:=x+'======'+rcode;
x:=x+y+rcode;
x:=x+rcode+rcode;


//about the software
x:=x+strup('software')+rcode;
x:=x+'========'+rcode;
x:=x+'Generated by '+t2eprogramname+' v'+t2eversion+rcode;
x:=x+'© '+low__yearstr(2025)+#32+app__info('author.name')+rcode;
x:=x+app__info('url.portal')+rcode;

//show
showbasic(x);

except;end;
try
//.absorb keystrokes
xprocesskeystrokes;
ilocked:=false;
except;end;
end;

procedure texeviewer._onactivate(sender:tobject);
begin
if (sender=iform) then win____sendmessage(irichedit.handle,wm_setfocus,0,0);
end;

procedure texeviewer._onclose(sender:tobject);
begin
if not imaingui then app__halt;
end;


end.
