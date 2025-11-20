unit lnet;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses lwin, lwin2, lroot;
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
//## Library.................. network (modernised legacy codebase)
//## Version.................. 1.00.005
//## Items.................... 1
//## Last Updated ............ 05oct2025
//## Lines of Code............ 200+
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
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | net__*                 | family of procs   | 1.00.005  | 05oct2025   | subset of Gossamer procs
//## ==========================================================================================================================================================================================================================

var
   lnet_started        :boolean=false;
   system_net_session  :boolean=false;
   system_net_sesinfo  :TWSAData;
   system_net_sock     :tdynamicinteger=nil;



//network procs ----------------------------------------------------------------

function net__makesession:boolean;
procedure net__closesession;
function net__onmessage(m,w,l:longint):longint;
function net__onraw(m,w,l:longint):longint;
function net__decodestrb(x:string):string;
procedure net__decodestr(var x:string);//12jun2006


//start-stop procs -------------------------------------------------------------
procedure lnet__start;
procedure lnet__stop;


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
function info__lnet(xname:string):string;//information specific to this unit of code


implementation


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__lnet(xname:string):string;//information specific to this unit of code

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
if not m('lnet.') then exit;

//get
if      (xname='ver')        then result:='1.00.005'
else if (xname='date')       then result:='05oct2025'
else if (xname='name')       then result:='Network'
else
   begin
   //nil
   end;

except;end;
end;


//start-stop procs -------------------------------------------------------------
procedure lnet__start;
begin
try
//check
if lnet_started then exit else lnet_started:=true;


except;end;
end;

procedure lnet__stop;
begin
try
//check
if not lnet_started then exit else lnet_started:=false;

net__closesession;

//.this buffer is left running in the program and ONLY destoyed here -> once it's running not safe to shrink/remove it
if (system_net_sock<>nil) then freeobj(@system_net_sock);

except;end;
end;


//network procs ----------------------------------------------------------------
function net__makesession:boolean;
begin
//defaults
result:=system_net_session;

try
//get
if not system_net_session then
   begin
   //.create BEFORE enabling session, else code may reference it before it's setup
   if (system_net_sock=nil) then system_net_sock:=tdynamicinteger.create;
   //.session
//   system_net_session:=(0=net____WSAStartup(winsocketVersion,system_net_sesinfo));
//   system_net_session:=(0=net____WSAStartup($0202,system_net_sesinfo));
   system_net_session:=(0=net____WSAStartup($1009,system_net_sesinfo));

   //.bring windows message handling online - note: this may already be active, hence why "system_net_sock" was created above
   if system_net_session then
      begin
      app__wproc;
      result:=true;
      end;
   end;
except;end;
end;

procedure net__closesession;
begin
if system_net_session then
   begin
   system_net_session:=false;
   net____WSACleanup;
   end;
//net__closeall;
end;

function net__onmessage(m,w,l:longint):longint;
begin
//defaults
result:=0;
end;

function net__onraw(m,w,l:longint):longint;
begin
//defaults
result:=0;
end;

function net__decodestrb(x:string):string;
begin
result:='';

try
result:=x;
net__decodestr(result);
except;end;
end;

procedure net__decodestr(var x:string);//12jun2006
var
   v,xp,xlen,p:longint;
begin
try
//init
xlen:=low__len(x);
if (xlen=0) then exit;
//get
xp:=0;
p:=1;
repeat
v:=byte(x[p-1+stroffset]);
//decide
if (v=sspercentage) then
   begin
   x[p-1+stroffset+xp]:=char(low__hexint2(strcopy1(x,p+1,2)));
   xp:=xp-2;
   p:=p+2;
   end
else if (v=ssplus) then x[p-1+stroffset+xp]:=#32
else x[p-1+stroffset+xp]:=x[p-1+stroffset];
//inc
inc(p);
until (p>xlen);
//.size
x:=strcopy1(x,1,xlen+xp);
except;end;
end;

end.
