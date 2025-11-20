unit lio;

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
//## Library.................. disk/folder/file support (modernised legacy codebase)
//## Version.................. 1.00.350 (+1)
//## Items.................... 3
//## Last Updated ............ 05oct2025
//## Lines of Code............ 2,900+
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
//## | filecache__*           | family of procs   | 1.00.157  | 28sep2025   | Cache open file handles for faster repeat file IO operations, 17aug2025, 29apr2024, 12apr2024: created
//## | io__*                  | family of procs   | 1.00.060  | 05oct2025   | Disk, folder and file procs + 64bit file support - subset of Gossamer procs
//## | idisk__*               | family of procs   | 1.00.132  | 15mar2025   | Internal disk support "!:\" - 20jul2024: reintegrated into Gossamer
//## ==========================================================================================================================================================================================================================


type
   //.tfilecache
   pfilecache=^tfilecache;
   tfilecache=record
    init:boolean;
    //.time + used
    time_created:comp;//time this record was created
    time_idle:comp;//used for idle timeout detection
    //.name
    filenameREF:comp;
    filename:string;
    opencount:longint;
    usecount:longint;//increments each time the record is reused -> procs can detect if their record has been reused and abort
    //.handle to file
    filehandle:thandle;
    //.access
    read:boolean;
    write:boolean;
    //.info
    slot:longint;
    end;


var
   //.filecache
   system_filecache_limit       :longint=20;//0..20=file caching is off, 21..200=file caching is on - 29apr2024
   system_filecache_timer       :comp=0;
   system_filecache_slot        :array[0..199] of tfilecache;
   system_filecache_filecount   :comp=0;//count actual file opens
   system_filecache_count       :longint=0;//last slot open+1
   system_filecache_active      :longint=0;//exact number of slots open

   //internal disk support -----------------------------------------------------
   intdisk_inuse                :boolean=false;//false=not in use (default)
   intdisk_char                 :char='!';//e.g. "!:\"
   intdisk_label                :string='Samples';//volume label
   intdisk_name                 :array[0..199] of string;
   intdisk_data                 :array[0..199] of tobject;//nil by default - can be eitehr tstr8 or tstr9
   intdisk_date                 :array[0..199] of tdatetime;
   intdisk_readonly             :array[0..199] of boolean;


//win32 folder procs -----------------------------------------------------------
function io__findfolder(x:longint;var y:string):boolean;//17jan2007
function io__appdata:string;//out of date
function io__windrive:string;//14DEC2010
function io__winroot:string;//11DEC2010
function io__winsystem:string;//11DEC2010
function io__wintemp:string;//11DEC2010
function io__windesktop:string;//17MAY2013
function io__winstartup:string;
function io__winprograms:string;//start button > programs > - 11NOV2010
function io__winstartmenu:string;


//io procs ---------------------------------------------------------------------

function io__dates__filedatetime(x:tfiletime):tdatetime;
function io__dates__fileage(x:thandle):tdatetime;
function io__exename:string;
function io__safename(const x:string):string;//08apr2025, 07mar2021, 08mar2016
function io__safefilename(const x:string;allowpath:boolean):string;//08apr2025, 07mar2021, 08mar2016
function io__issafefilename(const x:string):boolean;//07mar2021, 10APR2010
function io__hack_dangerous_filepath_allow_mask(const x:string):boolean;
function io__hack_dangerous_filepath_deny_mask(const x:string):boolean;
function io__hack_dangerous_filepath(const x:string;xstrict_no_mask:boolean):boolean;
function io__makeportablefilename(const filename:string):string;//11sep2021, 06oct2020, 14APR2011
function io__readportablefilename(const filename:string):string;//11sep2021
function io__extractfileext(const x:string):string;//12apr2021
function io__extractfileext2(const x,xdefext:string;xuppercase:boolean):string;//12apr2021
function io__extractfileext3(const x,xdefext:string):string;//lowercase version - 15feb2022

function io__driveexists(const x:string):boolean;//true=drive has content - 01may2025, 17may2021, 16feb2016, 25feb2015, 17AUG2010
function io__drivetype(const x:string):string;//15apr2021, 05apr2021
function io__drivelabel(const x:string;xfancy:boolean):string;//17may2021, 05apr2021
function io__filesize64(const x:string):comp;//24dec2023
function io__filesize642(const xfilehandle:thandle):comp;//28sep2025
function io__filedateb(const x:string):tdatetime;//27jan2022
function io__filedate(const x:string;var xdate:tdatetime):boolean;//24dec2023, 27jan2022
function io__fileexists(const x:string):boolean;//27aug2025, 01may2025, 04apr2021, 15mar2020, 19may2019

function io__isfile(const x:string):boolean;
function io__local(const x:string):boolean;
function io__internal(const x:string):boolean;//21aug2025
function io__canshowfolder(const x:string):boolean;//18may2025
function io__canshowfile(const x:string):boolean;//18sep2025
function io__canEditWithNotepad(const x:string):boolean;//18sep2025
function io__canEditWithPaint(const x:string):boolean;//18sep2025

function io__remlastext(const x:string):string;//remove last extension
function io__readfileext(const x:string;fu:boolean):string;{Date: 24-DEC-2004, Superceeds "ExtractFileExt"}
function io__readfileext_low(const x:string):string;//30jan2022
function io__scandownto(const x:string;y,stopA,stopB:char;var a,b:string):boolean;
function io__faISfolder(x:longint):boolean;//05JUN2013

function io__validfilename(const x:string):boolean;//31mar2025
function io__remfile(const x:string):boolean;//31mar2025
procedure io__filesetattr(const x:string;xval:longint);//01may2025
function io__copyfile(const sf,df:string;var e:string):boolean;//16dec2024: upgraded to handle large files

function io__tofilestr2(const x,xdata:string):boolean;//fast and basic low-level
function io__tofilestr(const x,xdata:string;var e:string):boolean;//fast and basic low-level
function io__tofile(const x:string;xdata:pobject;var e:string):boolean;//31mar2025, 27sep2022, fast and basic low-level
function io__tofile64(const x:string;xdata:pobject;var e:string):boolean;//31mar2025, 27sep2022, fast and basic low-level
function io__tofileex64(const x:string;xdata:pobject;xfrom:comp;xreplace:boolean;var e:string):boolean;//30apr2024: flush file buffers for correct "nav__*" filesize info, 06feb2024, 22jan2024, 27sep2022, fast and basic low-level
function io__fromfilestrb(const x:string;var e:string):string;//30mar2022
function io__fromfilestr2(const x:string):string;//28aug2025
function io__fromfilestr(const x:string;var xdata,e:string):boolean;
function io__fromfile(const x:string;xdata:pobject;var e:string):boolean;//31mar2025
function io__fromfile64(const x:string;xdata:pobject;var e:string):boolean;//31mar2025
function io__fromfile641(const x:string;xdata:pobject;xappend:boolean;var e:string):boolean;//31mar2025, 04feb2024
function io__fromfile64b(const x:string;xdata:pobject;var e:string;var _filesize,_from:comp;_size:comp;var _date:tdatetime):boolean;//31mar2025, 24dec2023, 20oct2006
function io__fromfile64d(const x:string;xdata:pobject;xappend:boolean;var e:string;var _filesize:comp;_from:comp;_size:comp;var _date:tdatetime):boolean;//31mar2025, 06feb2024, 24dec2023, 20oct2006
function io__fromfile64c(const x:string;xdata:pobject;xappend:boolean;var e:string;var _filesize,_from:comp;_size:comp;var _date:tdatetime):boolean;//31mar2025, 11jan2025, 06feb2024, 24dec2023, 20oct2006
function io__fromfiletime(x:tfiletime):tdatetime;
function io__folderexists(const x:string):boolean;//01may2025, 15mar2020, 14dec2016
function io__deletefolder(x:string):boolean;//13feb2024
function io__makefolder2(const x:string):string;//01may2025
function io__makefolder(x:string):boolean;//01may2025, 15mar2020, 19may2019
function io__makefolderchain(x:string):boolean;//17aug2025, 11aug2025
function io__exemarker(x:tstr8):boolean;//14nov2023
function io__exemarkerb:string;//04oct2025
function io__hasmarker(x:pobject;const xremoveMarkerAndLeadingData:boolean):boolean;//04oct2025

function io__extractfilepath(const x:string):string;//04apr2021
function io__extractfilename(const x:string):string;//05apr2021
function io__renamefile(const s,d:string):boolean;//local only, soft check - 27nov2016
function io__shortfile(const xlongfilename:string):string;//translate long filenames to short filename, using MS api, for "MCI playback of filenames with 125+c" - 23FEB2008
function io__asfolder(const x:string):string;//enforces trailing "\"
function io__asfolderNIL(const x:string):string;//enforces trailing "\" AND permits NIL - 03apr2021, 10mar2014
function io__folderaslabel(x:string):string;


//file format procs ------------------------------------------------------------
function io__anyformatb(xdata:pobject):string;
function io__anyformat2b(xdata:pobject;xfrompos:longint):string;
function io__anyformat(xdata:pobject;var xformat:string):boolean;//returns EXT of any known format, image, sound, frame, etc - 14may2025, 20dec2024, 18nov2024, 30jan2021
function io__anyformat2(xdata:pobject;xfrompos:longint;var xformat:string):boolean;//returns EXT of any known format, image, sound, frame, etc - 24aug2025, 11jun2025, 14may2025, 20dec2024, 18nov2024, 30jan2021
function io__anyformata(const xdata:array of byte):string;//19feb2025, 25jan2025


//internal disk procs ----------------------------------------------------------

procedure idisk__init(const xnewlabel:string;const xteadata:array of byte);
function idisk__fullname(const x:string):string;
function idisk__findnext(var xpos:longint;xfolder:string;xfolders,xfiles:boolean;var xoutname,xoutnameonly:string;var xoutfolder,xoutfile:boolean;var xoutdate:tdatetime;var xoutsize:comp;var xoutreadonly:boolean):boolean;
function idisk__havescope(const xname:string):boolean;
function idisk__makefolder(xname:string;var e:string):boolean;
function idisk__folderexists(const xname:string):boolean;
function idisk__fileexists(const xname:string):boolean;
function idisk__find(const xname:string;xcreatenew:boolean;var xindex:longint):boolean;
function idisk__remfile(const xname:string):boolean;
function idisk__tofile(const xname:string;xdata:pobject;var e:string):boolean;//30sep2021
function idisk__tofile1(xname:string;xdata:pobject;xdecompressdata:boolean;var e:string):boolean;//30sep2021
function idisk__tofile2(const xname:string;const xdata:array of byte;var e:string):boolean;//14apr2021
function idisk__tofile21(const xname:string;const xdata:array of byte;xdecompressdata:boolean;var e:string):boolean;//14apr2021
function idisk__fromfile(xname:string;xdata:pobject;var e:string):boolean;


//filecache procs --------------------------------------------------------------
//caches open file handles (not file content)
//.init
function filecache__recok(x:pfilecache):boolean;
procedure filecache__initrec(x:pfilecache;xslot:longint);//used internally by system
function filecache__idletime:comp;
function filecache__enabled:boolean;
procedure filecache__setenable(const xenable:boolean);//28sep2025
function filecache__limit:longint;
function filecache__safefilename(const x:string):boolean;
//.find
function filecache__find(const x:string;xread,xwrite:boolean;var xslot:longint):boolean;//13apr2024: updated
function filecache__newslot:longint;
procedure filecache__inc_usecount(x:pfilecache);
//.close
procedure filecache__closeall;
procedure filecache__closeall_rightnow;
procedure filecache__closerec(x:pfilecache);
procedure filecache__closefile(var x:pfilecache);
procedure filecache__closeall_byname_rightnow(const x:string);
function filecache__remfile(const x:string):boolean;
//.open
function filecache__openfile_anyORread(const x:string;var v:pfilecache;var vmustclose:boolean;var e:string):boolean;//for info purposes such as filesize and filedate, not for reading/writing file content
function filecache__openfile_read(const x:string;var v:pfilecache;var e:string):boolean;
function filecache__openfile_write(const x:string;var v:pfilecache;var e:string):boolean;
function filecache__openfile_write2(const x:string;xremfile_first:boolean;var xfilecreated:boolean;var v:pfilecache;var e:string):boolean;//17aug2025
//.management
procedure filecache__managementevent;


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
function info__lio(xname:string):string;//information specific to this unit of code


implementation

uses lzip;


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__lio(xname:string):string;//information specific to this unit of code

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
if not m('lio.') then exit;

//get
if      (xname='ver')        then result:='1.00.350'
else if (xname='date')       then result:='05oct2025'
else if (xname='name')       then result:='IO'
else
   begin
   //nil
   end;

except;end;
end;


//win32 folder procs -----------------------------------------------------------

function io__findfolder(x:longint;var y:string):boolean;//17jan2007
var
   i:imalloc;
   a:pitemidlist;
   b:pchar;
   tmpfolder:string;
begin
//defaults
result:=false;

try
y:='';
a:=nil;
//process
if (win____SHGetMalloc(i)=NOERROR) then
   begin
   if (win____shgetspecialfolderlocation(0,x,a)=0) then
      begin
      //.size
      b:=pchar(makestrb(max_path,0));
      //.get
      if win____shgetpathfromidlist(a,b) then
         begin
         y:=io__asfolder(string(b));
         result:=(low__len(y)>=3);
         end;//if
      end;//if
   end;//if
except;end;
try;if (a<>nil) then i.free(a);except;end;
try
//-- Linux and robust Windows Support --
//Note: return a path regardless whether we are Windows or Linux, and wether it's supported
//      or not.
if not result then
   begin
   //fallback to "c:\windows\temp\"
   tmpfolder:=io__wintemp;
   if (tmpfolder='') then tmpfolder:='C:\WINDOWS\TEMP\';
   y:='';
   //get
   case x of
   CSIDL_DESKTOP:                y:=tmpfolder;
   CSIDL_COMMON_DESKTOPDIRECTORY:y:=tmpfolder;
   CSIDL_FAVORITES:              y:=tmpfolder;
   CSIDL_STARTMENU:              y:=tmpfolder;
   CSIDL_COMMON_STARTMENU:       y:=tmpfolder;
   CSIDL_PROGRAMS:               y:=tmpfolder;
   CSIDL_COMMON_PROGRAMS:        y:=tmpfolder;
   CSIDL_STARTUP:                y:=tmpfolder;
   CSIDL_COMMON_STARTUP:         y:=tmpfolder;
   CSIDL_RECENT:                 y:=tmpfolder;
   CSIDL_FONTS:                  y:=tmpfolder;
   CSIDL_APPDATA:                y:=tmpfolder;
   end;//case
   //set
   result:=(low__len(y)>=3);
   end;
except;end;
end;

function io__appdata:string;//out of date
begin
result:='';try;io__findfolder(CSIDL_APPDATA,result);except;end;
end;

function io__windrive:string;//14DEC2010
begin
result:='';try;result:=strcopy1(io__winroot,1,3);except;end;
end;

function io__winroot:string;//11dec2010
var
  a:pchar;
begin
result:='';

try
//process
//.size
a:=pchar(makestrb(max_path,0));
//.get
win____getwindowsdirectorya(a,MAX_PATH);
result:=io__asfolder(string(a));
except;end;
try;if (low__len(result)<3) then result:='C:\WINDOWS\';except;end;
end;

function io__winsystem:string;//11DEC2010
var
  a:pchar;
begin
result:='';

try
//process
//.size
a:=pchar(makestrb(max_path,0));
//.get
win____getsystemdirectorya(a,MAX_PATH);
result:=io__asfolder(string(a));
except;end;
try;if (low__len(result)<3) then result:=io__winroot+'SYSTEM32\';except;end;
end;

function io__wintemp:string;//11DEC2010
var
  a:pchar;
begin
//defaults
result:='';

try
//size
a:=pchar(makestrb(max_path,0));
//get
win____gettemppatha(max_path,a);
//set
result:=io__asfolder(string(a));
except;end;
try
//range
if (low__len(result)<3) then result:='C:\WINDOWS\TEMP\';//11DEC2010
io__makefolder(result);
except;end;
end;

function io__windesktop:string;//17MAY2013
begin
result:='';try;io__findfolder(csidl_desktop,result);except;end;
end;

function io__winstartup:string;
begin
io__findfolder(CSIDL_STARTUP,result);
end;

function io__winprograms:string;//start button > programs > - 11NOV2010
begin
io__findfolder(CSIDL_PROGRAMS,result);
end;

function io__winstartmenu:string;
begin
io__findfolder(CSIDL_STARTMENU,result);
end;


//io procs ---------------------------------------------------------------------

function io__dates__filedatetime(x:tfiletime):tdatetime;
var
   a:longint;
   c:tfiletime;
begin
//defaults
result:=date__now;

try
//process
win____filetimetolocalfiletime(x,c);
if win____filetimetodosdatetime(c,tint4(a).hi,tint4(a).lo) then result:=date__filedatetodatetime(a)
else result:=date__now;
except;end;
end;

function io__dates__fileage(x:thandle):tdatetime;
var
   a:tbyhandlefileinformation;
begin
result:=0;try;if (x=0) or (not win____getfileinformationbyhandle(x,a)) then result:=date__now else result:=io__dates__filedatetime(a.ftLastWriteTime);except;end;
end;

function io__exename:string;
begin
result:=low__param(0);
end;

function io__safename(const x:string):string;//08apr2025, 07mar2021, 08mar2016
begin
result:=io__safefilename(x,false);
end;

function io__safefilename(const x:string;allowpath:boolean):string;//08apr2025, 07mar2021, 08mar2016
var
   minp,p:longint;
   c:char;

   function isbinary(x:byte):boolean;
   begin
   result:=false;

   try
   case x of//31MAR2010
   32..255:result:=false;
   else result:=true;
   end;
   except;end;
   end;
begin
//defaults
result:='';

try
result:=x;
if (x='') then exit;
//get
if allowpath then
   begin
   //.get
   if (strcopy1(x,1,2)='\\') then minp:=3 else minp:=1;
   //.set
   for p:=(minp-1) to (low__len(result)-1) do
   begin
   c:=result[p+stroffset];
   if (c='/') then result[p+stroffset]:='\'
   else if isbinary(byte(c)) or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='$') then result[p+stroffset]:=pcSymSafe;
   //was: else if isbinary(byte(c)) or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='@') or (c='$') then result[p+stroffset]:=pcSymSafe;
   end;//p
   end
else
   begin
   //.set
   for p:=0 to (low__len(result)-1) do
   begin
   c:=result[p+stroffset];
   if isbinary(byte(c)) or (c='\') or (c='/') or (c=':') or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='@') or (c='$') then result[p+stroffset]:=pcSymSafe;
   end;//p
   end;
except;end;
end;

function io__issafefilename(const x:string):boolean;//07mar2021, 10APR2010
var
   p:longint;
   c:char;

   function isbinary(x:byte):boolean;
   begin
   result:=false;

   try
   case x of//31MAR2010
   32..255:result:=false;
   else result:=true;
   end;
   except;end;
   end;
begin
//defaults
result:=true;

try
//check
if (x='') then exit;
//set
for p:=0 to (low__len(x)-1) do
begin
c:=x[p+stroffset];
//was: if isbinary(byte(c)) or (c='\') or (c='/') or (c=':') or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='@') or (c='$') then
if isbinary(byte(c)) or (c='\') or (c='/') or (c=':') or (c=';') or (c='*') or (c='?') or (c='"') or (c='<') or (c='>') or (c='|') or (c='$') then
   begin
   result:=false;
   break;
   end;
end;//p
except;end;
end;

function io__hack_dangerous_filepath_allow_mask(const x:string):boolean;
begin
result:=io__hack_dangerous_filepath(x,false);
end;

function io__hack_dangerous_filepath_deny_mask(const x:string):boolean;
begin
result:=io__hack_dangerous_filepath(x,true);
end;

function io__hack_dangerous_filepath(const x:string;xstrict_no_mask:boolean):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//get
if (x<>'') then
   begin
   for p:=0 to (low__len(x)-1) do
   begin
   //check 1 - "..\" + "../"
   if (x[p+stroffset]='.') and ((strcopy0(x,p,3)='..\') or (strcopy0(x,p,3)='../')) then
      begin
      result:=true;
      break;
      end
   //check 2 - (..\) "..%5C" + "..%5c" AND (../) "..%2F" + "..%2f"
   else if (x[p+stroffset]='.') and ((strcopy0(x,p,5)='..%5C') or (strcopy0(x,p,5)='..%5c') or (strcopy0(x,p,5)='..%2F') or (strcopy0(x,p,5)='..%2f')) then
      begin
      result:=true;
      break;
      end
   //check 3 - ":" other than "(a-z/@):(\/)" e.g. "C:\" is ok, but "C::" is not - 02sep2016
   else if (p>=2) and (x[p+stroffset]=':') then
      begin
      result:=true;
      break;
      end
   //check 4 - none of these characters are allowed, ever - 02sep2016
   else if (x[p+stroffset]='?') or (x[p+stroffset]='<') or (x[p+stroffset]='>') or (x[p+stroffset]='|') then
      begin
      result:=true;
      break;
      end
   //optional check 5 - disallow file masking "*"
   else if xstrict_no_mask and (x[p+stroffset]='*') then
      begin
      result:=true;
      break;
      end;
   end;//p
   end;
except;end;
end;

function io__makeportablefilename(const filename:string):string;//11sep2021, 06oct2020, 14APR2011
var// "C:\...\" => exact static filename
   // "c:\...\" => also an exact static filename
   // "?:\...\" => relative dynamic filename (on same disk as EXE and thus will adapt) - 11sep2021, 14APR2011
   edrive,sdrive:string;
begin
result:=filename;
//get
if (low__len(result)>=2) and (strcopy1(result,2,1)=':') and (strcopy1(result,1,1)<>'/') and (strcopy1(result,1,1)<>'\') then
   begin
   edrive:=strcopy1(io__exename+'Z',1,1);//pad with "Z" incase app.exename is empty for some reason - 14APR2011
   sdrive:=strcopy1(result,1,1);
   //get - if on same drive as EXE then it's considered portable so make it "?:\...\"
   if strmatch(edrive,sdrive) then result:='?'+strcopy1(result,2,low__len(result));
   end;
end;

function io__readportablefilename(const filename:string):string;//11sep2021
var// "C:\...\" => STATIC, exact static filename
   // "c:\...\" => also an exact static filename
   // "?:\...\" => RELATIVE, dynamic filename (on same disk as EXE and thus will adapt) - 11sep2021, 14APR2011
   edrive:string;
begin
result:=filename;
//get
if (low__len(result)>=2) and (strcopy1(result,2,1)=':') and (strcopy1(result,1,1)<>'/') and (strcopy1(result,1,1)<>'\') then
   begin
   edrive:=strcopy1(io__exename+'Z',1,1);//pad with "Z" incase app.exename is empty for some reason - 14APR2011
   if (strcopy1(result,1,1)='?') then result:=edrive+strcopy1(result,2,low__len(result));
   end;
end;

function io__extractfileext(const x:string):string;//12apr2021
var
   p:longint;
begin
//defaults
result:='';

try
//get
if (x<>'') then
   begin
   for p:=low__len(x) downto 1 do
   begin
   if (strcopy1(x,p,1)='/') or (strcopy1(x,p,1)='\') then break
   else if (strcopy1(x,p,1)='.') then
      begin
      result:=strcopy1(x,p+1,low__len(x));
      break
      end;
   end;//p
   end;
except;end;
end;

function io__extractfileext2(const x,xdefext:string;xuppercase:boolean):string;//12apr2021
begin
result:=strdefb(io__extractfileext(x),xdefext);
if xuppercase then result:=strup(result);
end;

function io__extractfileext3(const x,xdefext:string):string;//lowercase version - 15feb2022
begin
result:=strlow(strdefb(io__extractfileext(x),xdefext));
end;

function io__driveexists(const x:string):boolean;//true=drive has content - 01may2025, 17may2021, 16feb2016, 25feb2015, 17AUG2010
var
   xdrive:string;
   orgerr,notused,volflags,serialno:dword;
begin
//defaults
result:=false;
orgerr:=0;

try
//check
if (x<>'') then xdrive:=x[stroffset]+':\' else exit;
//hack check
if io__hack_dangerous_filepath_deny_mask(xdrive) then exit;//17may2021
//check drive is in range
if not (  (xdrive[1+stroffset]=':') and ((xdrive[2+stroffset]='\') or (xdrive[2+stroffset]='/')) and ( (xdrive[0+stroffset]='!') or (xdrive[0+stroffset]='@') or (xdrive[0+stroffset]=intdisk_char) or ((xdrive[0+stroffset]>='a') and (xdrive[0+stroffset]<='z')) or ((xdrive[0+stroffset]>='A') and (xdrive[0+stroffset]<='Z')) )  ) then exit;
//get
if      (xdrive='@:\') then result:=false//no support for Name Network at this stage - nn.stable - 15mar2020
else if (xdrive=(intdisk_char+':\')) then result:=intdisk_inuse//internal disk
else
   begin
   try
   //fully qualified for maximum stability - 17may2021
   orgerr:=win____seterrormode(SEM_FAILCRITICALERRORS);//prevents the display of a prompt window asking for a FLOPPY or CD-DISK to be inserted as stated my MS - 04apr2021
   result:=boolean(win____getvolumeinformation(pchar(xdrive),nil,0,@serialno,notused,volflags,nil,0));
   except;end;
   win____seterrormode(orgerr);
   end;
except;end;
end;

function io__drivetype(const x:string):string;//15apr2021, 05apr2021
type
   tdrivetype2=(dtUnknown,dtNoDrive,dtFloppy,dtFixed,dtNetwork,dtCDROM,dtRAM);
var
   xdrive:string;
begin
//defaults
result:='';

try
//init
xdrive:=strup(strcopy1(x,1,1));
//get
if (xdrive<>'') then
   begin
   if      (xdrive='@')          then result:='nn'//name network
   else
      begin
      case tdrivetype2(win____getdrivetype(pchar(xdrive+':\'))) of
      dtFloppy:if (xdrive<='B') then result:='floppy' else result:='removable';
      dtFixed   :result:='fixed';
      dtNetwork :result:='network';
      dtCDROM   :result:='cd';
      dtRAM     :result:='ram';
      else       result:='fixed';
      end;//case
      end;//if
   end;
except;end;
end;

function io__drivelabel(const x:string;xfancy:boolean):string;//17may2021, 05apr2021
var//Note: Incorrectly returns UPPERCASE labels for removable disks - 30DEC2010
   xdrive,xlabel:string;
   p:longint;
   orgerr,notused,volflags,serialno:dword;
   buf:array[0..max_path] of char;
   buf2:array[0..max_path] of char;
begin
//defaults
result:='';
orgerr:=0;

try
//get
if (x<>'') then
   begin
   //init
   xdrive:=strcopy1(x,1,1)+':';
   xlabel:='';
   //label
   if io__driveexists(x) then
      begin
      //.internal disk
      if strmatch(strcopy1(x,1,1),intdisk_char) then xlabel:=intdisk_label
      //.standard disk drives "A-Z:\"
      else if ((x[0+stroffset]>='a') and (x[0+stroffset]<='z')) or ((x[0+stroffset]>='A') and (x[0+stroffset]<='Z')) then
         begin
         try
         //fully qualified for maximum stability - 17may2021
         orgerr:=win____seterrormode(SEM_FAILCRITICALERRORS);//prevents the display of a prompt window asking for a FLOPPY or CD-DISK to be inserted as stated my MS - 04apr2021
         fillchar(buf,sizeof(buf),0);
         fillchar(buf2,sizeof(buf2),0);
         buf[0]:=#$00;
         buf2[0]:=#$00;
         if boolean(win____getvolumeinformation(pchar(strcopy1(x,1,1)+':\'),buf,sizeof(buf),@serialno,notused,volflags,buf2,sizeof(buf2))) then setstring(xlabel,buf,pchar__strlen(buf));
         except;end;
         win____seterrormode(orgerr);
         end;
      end;
   //clean -> make more compatible with "Wine 5+" - 16apr2021
   if (xlabel<>'') then
      begin
      for p:=1 to low__len(xlabel) do if (strcopy1(xlabel,p,1)='?') or (strcopy1(xlabel,p,1)=#0) then
         begin
         xlabel:=strcopy1(xlabel,1,p-1);
         break;
         end;
      end;
   //set
   if xfancy then result:=xlabel+insstr(#32+'(',xlabel<>'')+xdrive+insstr(')',xlabel<>'') else result:=xlabel;
   end;
except;end;
end;

function io__filesize64(const x:string):comp;//24dec2023
var
   v:pfilecache;
   vmustclose:boolean;
   c:tcmp8;
   e:string;
begin
//defaults
result:=-1;//file not found
//get
if filecache__openfile_anyORread(x,v,vmustclose,e) then
   begin
   try
   c.ints[0]:=win____getfilesize(v.filehandle,@c.ints[1]);
   result:=c.val;
   except;end;
   if vmustclose then filecache__closefile(v);
   end;
end;

function io__filesize642(const xfilehandle:thandle):comp;//28sep2025
begin

case (xfilehandle<>0) of
true:tcmp8(result).ints[0]:=win____getfilesize(xfilehandle,@tcmp8(result).ints[1]);
else result:=-1;
end;//case

end;

function io__filedateb(const x:string):tdatetime;//27jan2022
begin
io__filedate(x,result);
end;

function io__filedate(const x:string;var xdate:tdatetime):boolean;//24dec2023, 27jan2022
label
   skipend;
var
   v:pfilecache;
   vmustclose:boolean;
   b:tbyhandlefileinformation;
   int1:longint;
   e:string;
begin
//defaults
result:=false;
xdate:=0;

//internal
if idisk__havescope(x) then
   begin
   if idisk__find(x,false,int1) and zzok(intdisk_data[int1],7023) then
      begin
      xdate:=intdisk_date[int1];
      result:=true;//ok
      end;
   goto skipend;
   end;

//get
if filecache__openfile_anyORread(x,v,vmustclose,e) then
   begin
   try
   if win____getfileinformationbyhandle(v.filehandle,b) then
      begin
      xdate:=io__fromfiletime(b.ftLastWriteTime);
      result:=true;//ok
      end;
   except;end;
   if vmustclose then filecache__closefile(v);
   end;

skipend:
end;

function io__fileexists(const x:string):boolean;//27aug2025, 01may2025, 04apr2021, 15mar2020, 19may2019

   function xfileexists:boolean;
   var
      h:thandle;
      f:TWin32FindData;
   begin

   //defaults
   result:=false;

   //init
   low__cls(@f,sizeof(f));//27aug2025

   //get
   h:=win____FindFirstFile(pchar(x),f);

   if (h<>INVALID_HANDLE_VALUE) then
      begin

      win____findclose(h);
      //set
      result:=((f.dwfileattributes and FILE_ATTRIBUTE_DIRECTORY)=0);

      end;

   end;
begin//soft check via low__driveexists

case idisk__havescope(x) of
true:result:=idisk__fileexists(x)
else result:=(x<>'') and io__local(x) and io__driveexists(x) and xfileexists;
end;//case

end;

function io__isfile(const x:string):boolean;
begin
result:=(strcopy1(x,low__len(x),1)<>'\') and (strcopy1(x,low__len(x),1)<>'/');
end;

function io__local(const x:string):boolean;
begin
result:=(strcopy1(x,1,1)<>'@');
end;

function io__internal(const x:string):boolean;//21aug2025
begin
result:=(strcopy1(x,1,1)='!');
end;

function io__canshowfolder(const x:string):boolean;//18may2025
begin
result:=(x<>'') and io__local(x) and (not io__internal(x));
end;

function io__canshowfile(const x:string):boolean;//18sep2025
begin
result:=(x<>'') and io__local(x) and (not io__internal(x));
end;

function io__canEditWithNotepad(const x:string):boolean;//18sep2025
begin
result:=io__canshowfile(x);
end;

function io__canEditWithPaint(const x:string):boolean;//18sep2025
begin
result:=io__canshowfile(x) and filter__matchlist( io__readfileext_low(x), 'bmp;dib;ico;gif;jpg;jpeg;jfif;jpe;png;tif;tiff;heic;hif;' );
end;

function io__remlastext(const x:string):string;//remove last extension
var
   p:longint;
begin
result:=x;

try
if (x<>'') then
   begin
   for p:=(low__len(x)-1) downto 0 do if (x[p+stroffset]='.') then
   begin
   result:=strcopy0(x,0,p);
   break;
   end;//p
   end;
except;end;
end;

function io__readfileext(const x:string;fu:boolean):string;{Date: 24-DEC-2004, Superceeds "ExtractFileExt"}
var//supports: "c:\windows\abc.RTF" and also "http://www.blaiz.net/abc/docs/index.RTF?abc=com"
   a,b:string;
begin
if io__scandownto(x,'.','/','\',a,result) then
   begin
   if io__scandownto(result,'?',#0,#0,a,b) then result:=a;
   if fu then result:=strup(result);
   end
else result:='';
end;

function io__readfileext_low(const x:string):string;//30jan2022
begin
result:=strlow(io__readfileext(x,false));
end;

function io__scandownto(const x:string;y,stopA,stopB:char;var a,b:string):boolean;
var
   xlen,p:longint;
   _stopA,_stopB:boolean;
begin
//defaults
result:=false;

try
a:='';
b:='';
_stopA:=(stopA<>#0);
_stopB:=(stopB<>#0);
//init
xlen:=low__len(x);
//check
if (xlen<=0) then exit;
//get
for p:=(xlen-1) downto 0 do
begin
if (_stopA and (x[p+stroffset]=stopA)) then break
else if (_stopB and (x[p+stroffset]=stopB)) then break
else if (x[p+stroffset]=y) then
   begin
   a:=strcopy0(x,0,p);
   b:=strcopy0(x,p+1,xlen);
   result:=true;
   break;
   end;
end;//p
except;end;
end;

function io__faISfolder(x:longint):boolean;//05JUN2013
begin//fast
result:=((x and faDirectory)>0);
end;

function io__validfilename(const x:string):boolean;//31mar2025
begin
result:=(io__extractfilename(x)<>'');
end;

function io__remfile(const x:string):boolean;//31mar2025
begin
if not io__validfilename(x) then result:=true
else if idisk__havescope(x) then result:=idisk__remfile(x)
else                             result:=filecache__remfile(x);
end;

procedure io__filesetattr(const x:string;xval:longint);//01may2025
begin
if io__validfilename(x) and (not idisk__havescope(x)) then
   begin
   if not win____SetFileAttributes(pchar(x),xval) then win____GetLastError;
   end;
end;

function io__copyfile(const sf,df:string;var e:string):boolean;//16dec2024: upgraded to handle large files
const
   xchunksize=5000000;//5Mb
label
   redo,skipend;
var
   xonce:boolean;
   xdata:tobject;
   dpos,spos,xfilesize:comp;
   xdate:tdatetime;
begin
//defaults
result:=false;
xonce:=true;
xdata:=nil;
e:=gecTaskfailed;

try
//check
if strmatch(sf,df) then
   begin
   result:=true;
   goto skipend;
   end;
//check
if not io__fileexists(sf) then
   begin
   e:=gecFilenotfound;
   goto skipend;
   end;

//get
xdata:=str__new8;
spos:=0;
redo:
//.read chunk from sf
dpos:=spos;
if not io__fromfile64b(sf,@xdata,e,xfilesize,spos,xchunksize,xdate) then goto skipend;

//.once -> remove df
if xonce then
   begin
   if not io__remfile(df) then
      begin
      e:=gecFileinuse;
      goto skipend;
      end;
   xonce:=false;
   end;

//.write chunk to df
if not io__tofileex64(df,@xdata,dpos,false,e) then goto skipend;

//.loop
if ((spos+1)<xfilesize) then goto redo;

//successful
result:=true;
skipend:
except;end;
try
str__free(@xdata);
//remove "df" if partially written
if (not result) and (not xonce) then io__remfile(df);
except;end;
end;

function io__tofilestr2(const x,xdata:string):boolean;//fast and basic low-level
var
   e:string;
begin
result:=io__tofilestr(x,xdata,e);
end;

function io__tofilestr(const x,xdata:string;var e:string):boolean;//fast and basic low-level
var
   a:tstr8;
begin
//defaults
result:=false;

try
a:=nil;
a:=str__new8;
//get
a.text:=xdata;
result:=io__tofile(x,@a,e);
except;end;
try;str__free(@a);except;end;
end;

function io__tofile(const x:string;xdata:pobject;var e:string):boolean;//31mar2025, 27sep2022, fast and basic low-level
var
   xfrom:comp;
begin
xfrom :=0;
result:=io__tofileex64(x,xdata,xfrom,true,e);
end;

function io__tofile64(const x:string;xdata:pobject;var e:string):boolean;//31mar2025, 27sep2022, fast and basic low-level
var
   xfrom:comp;
begin
xfrom :=0;
result:=io__tofileex64(x,xdata,xfrom,true,e);
end;

function io__tofileex64(const x:string;xdata:pobject;xfrom:comp;xreplace:boolean;var e:string):boolean;//30apr2024: flush file buffers for correct "nav__*" filesize info, 06feb2024, 22jan2024, 27sep2022, fast and basic low-level
label//xreplace=true=file is deleted and then written, false=file is written to/extended in size
   skipend;
const
   amax=maxword;//65K, was 32K
var
   a:array[0..amax] of byte;
   int1,xwritten,ylen,p,ap:longint;
   c:tcmp8;
   v:pfilecache;
   vok,xfilecreated:boolean;
begin
//defaults
result:=false;
e:=gecTaskfailed;
vok:=false;

try
//check
if not str__lock(xdata) then exit;

//check for empty filename - 31mar2025
if not io__validfilename(x) then
   begin
   e:=gecBadFileName;
   exit;
   end;

//internal
if idisk__havescope(x) then
   begin
   result:=idisk__tofile(x,xdata,e);
   goto skipend;
   end;

//init
ylen:=str__len(xdata);

//open or create file
vok:=filecache__openfile_write2(x,xreplace,xfilecreated,v,e);
if not vok then goto skipend;

//switch to replace mode if file was created
if xfilecreated then
   begin
   xreplace:=true;
   xfrom:=0;//22jan2024
   end;

//seek using _from
e:=gecOutOfDiskSpace;
c.val:=xfrom;
win____setfilepointer(v.filehandle,c.ints[0],@c.ints[1],0 {file_begin});

//init
p:=1;
ap:=0;
//.write - tstr8
if (ylen>=1) and (xdata^ is tstr8) then
   begin
   for p:=1 to ylen do
   begin
   //.fill
   a[ap]:=(xdata^ as tstr8).pbytes[p-1];
   //.store
   if (ap>=amax) or (p=yLEN) then
      begin
      if not win____writefile(v.filehandle,a,(ap+1),xwritten,nil) then goto skipend;
      if (xwritten<>(ap+1)) then goto skipend;
      ap:=-1;
      end;
   //.inc
   inc(ap);
   end;//p
   end
//.write - tstr9
else if (ylen>=1) and (xdata^ is tstr9) then
   begin
   while true do
   begin
   int1:=(xdata^ as tstr9).fastread(a,sizeof(a),p-1);
   if (int1>=1) then
      begin
      inc(p,int1);
      if not win____writefile(v.filehandle,a,int1,xwritten,nil) then goto skipend;
      if (xwritten<>int1) then goto skipend;
      end
   else break;
   end;//loop
   end;

//successful
result:=true;
skipend:
except;end;
try
//close file handle
if vok then
   begin
   //.flush the buffers so that a call to "nav__*" will show the correct file size when requested - 30apr2024
   if filecache__enabled then win____FlushFileBuffers(v.filehandle);

   //.close the file -> only if a single instance is open
   filecache__closefile(v);
   end;

//delete the file on failure for "xreplace=true" operations
if (not result) and xreplace then io__remfile(x);

//release buffer and optionally destroy it
str__unlockautofree(xdata);
except;end;
end;

function io__fromfilestrb(const x:string;var e:string):string;//30mar2022
begin
result:='';try;io__fromfilestr(x,result,e);except;end;
end;

function io__fromfilestr2(const x:string):string;//28aug2025
var
   e:string;
begin
result:='';try;io__fromfilestr(x,result,e);except;end;
end;

function io__fromfilestr(const x:string;var xdata,e:string):boolean;
var
   a:tstr8;
begin
//defaults
result:=false;

try
xdata:='';
a:=nil;
//get
a:=str__new8;
result:=io__fromfile(x,@a,e);
if result then xdata:=a.text;
except;end;
try;str__free(@a);except;end;
end;

function io__fromfile(const x:string;xdata:pobject;var e:string):boolean;//31mar2025
var
   _filesize,_from:comp;
   _date:tdatetime;
begin
_from :=0;
result:=io__fromfile64b(x,xdata,e,_filesize,_from,max32,_date);
end;

function io__fromfile64(const x:string;xdata:pobject;var e:string):boolean;//31mar2025
begin
result:=io__fromfile641(x,xdata,false,e);
end;

function io__fromfile641(const x:string;xdata:pobject;xappend:boolean;var e:string):boolean;//31mar2025, 04feb2024
var
   _filesize,_from:comp;
   _date:tdatetime;
begin
_from :=0;
result:=io__fromfile64c(x,xdata,xappend,e,_filesize,_from,max32,_date);
end;

function io__fromfile64b(const x:string;xdata:pobject;var e:string;var _filesize,_from:comp;_size:comp;var _date:tdatetime):boolean;//31mar2025, 24dec2023, 20oct2006
begin
result:=io__fromfile64c(x,xdata,false,e,_filesize,_from,_size,_date);
end;

function io__fromfile64d(const x:string;xdata:pobject;xappend:boolean;var e:string;var _filesize:comp;_from:comp;_size:comp;var _date:tdatetime):boolean;//31mar2025, 06feb2024, 24dec2023, 20oct2006
begin
result:=io__fromfile64c(x,xdata,xappend,e,_filesize,_from,_size,_date);
end;

function io__fromfile64c(const x:string;xdata:pobject;xappend:boolean;var e:string;var _filesize,_from:comp;_size:comp;var _date:tdatetime):boolean;//31mar2025, 11jan2025, 06feb2024, 24dec2023, 20oct2006
label
   skipend;
const
   amax=maxword;//65K, was 32K
var
   v:pfilecache;
   vok:boolean;
   a:array[0..amax] of byte;
   int1,xdatalen,_size32,i,p,ac:longint;
   c:tcmp8;

   function xfilesize:comp;
   var
      c:tcmp8;
   begin
   c.ints[0]:=win____getfilesize(v.filehandle,@c.ints[1]);
   result:=c.val;
   end;

begin
//defaults
result:=false;
vok:=false;

try
e:=gecTaskFailed;
_filesize:=0;

//check
if not str__lock(xdata) then exit;

//check for empty filename - 31mar2025
if not io__validfilename(x) then
   begin
   e:=gecFilenotfound;
   exit;
   end;

//init
if xappend then xdatalen:=str__len(xdata)
else
   begin
   xdatalen:=0;
   str__clear(xdata);
   end;

//internal
if idisk__havescope(x) then
   begin

   //find
   if not idisk__find(x,false,int1) then
      begin
      e:=gecFilenotfound;
      goto skipend;
      end;

   //get
   if zzok(intdisk_data[int1],7023) then
      begin
      _filesize:=str__len(@intdisk_data[int1]);
      if not str__add3(xdata,@intdisk_data[int1],restrict32(_from),restrict32(_size)) then
         begin
         e:=gecTaskfailed;
         goto skipend;
         end;
      _from:=frcmax64( add64(_from,restrict32(_size)) ,_filesize);//11jan2025
      end;

   //succesful
   result:=true;
   goto skipend;

   end;

//open
case filecache__openfile_read(x,v,e) of
true:vok:=true;
else goto skipend;
end;

//get file size
_filesize:=xfilesize;

//get file date
_date:=io__dates__fileage(v.filehandle);

//set the value of "_from"
if (_from<0) then _from:=0
else if (_from>=_filesize) then
   begin
   result:=true;
   goto skipend;
   end;

//seek using _from
c.val:=_from;
win____setfilepointer(v.filehandle,c.ints[0],@c.ints[1],0 {file_begin});

//set the value of size
if (_size=0) then//0=read NO data
   begin
   result:=true;
   goto skipend;
   end
else if (_size<0) then _size:=_filesize//-X..-1=read ALL data
else if (_size>_filesize) then _size:=_filesize;//1..X=read SPECIFIED data

//convert _size(64bit) into a fast 32bit int
_size32:=restrict32(_size);

//size check - ensure buffer is small enough to fit in ram
if (add64(xdatalen,_size32)>max32) then
   begin
   e:=gecOutofmemory;
   goto skipend;
   end;

//size the buffer
if not str__setlen(xdata,xdatalen+_size32) then
   begin
   e:=gecOutofmemory;
   goto skipend;
   end;


i:=0;

//.write
while true do
begin

//.get
win____readfile(v.filehandle,a,amax+1,ac,nil);

//.check
if (ac=0) then break;

//.fill
if (xdata^ is tstr8) then
   begin

   for p:=0 to frcmax32(ac-1,_size32-i-1) do//tested and passed - 17may2021
   begin

   inc(i);
   (xdata^ as tstr8).pbytes[xdatalen+i-1]:=a[p];

   end;//p

   end
else if (xdata^ is tstr9) then
   begin

   inc(i,(xdata^ as tstr9).fastwrite(a,frcmax32(ac,_size32-i),xdatalen+i));

   end;

//.quit
if (i>=_size32) then break;
end;//loop

//successful
_from:=add64(_from,i);

if (_filesize=_size) and (_from=0) then result:=(i=_size)//only for small files, BIG files can't always fit in RAM
else
   begin
   if (i<>_size32) then str__setlen(xdata,xdatalen+i);
   result:=(i>=1);
   end;

skipend:
except;end;
try

//close cache record
if vok then filecache__closefile(v);

//reset buffer on failure
if (not result) and (not xappend) then str__clear(xdata);

//release buffer and optionally destroy it
str__unlockautofree(xdata);

except;end;
end;

function io__fromfiletime(x:tfiletime):tdatetime;
var
   a:longint;
   c:tfiletime;
begin
win____filetimetolocalfiletime(x,c);
if win____filetimetodosdatetime(c,tint4(a).hi,tint4(a).lo) then result:=date__filedatetodatetime(a) else result:=date__now;
end;

function io__folderexists(const x:string):boolean;//01may2025, 15mar2020, 14dec2016
   function xexists:boolean;
   var
      c:longint;
   begin
   c:=win____GetFileAttributes(pchar(x));
   result:=(c<>-1) and ( (FILE_ATTRIBUTE_DIRECTORY and c) <>0 );
   end;
begin//soft check via low__driveexists
result:=(x<>'') and io__local(x) and io__driveexists(x) and xexists;
end;

function io__deletefolder(x:string):boolean;//13feb2024
begin//soft check via low__driveexists
result:=false;
try
//check
if (x='') then exit else x:=io__asfolder(x);
//get
if io__local(x) and io__driveexists(x) then result:=win____RemoveDirectory(pchar(x));
except;end;
end;

function io__makefolder2(const x:string):string;//01may2025
begin
result:=x;
if (result<>'') then
   begin
   result:=io__asfolder(result);
   io__makefolder(result);
   end;
end;

function io__makefolder(x:string):boolean;//01may2025, 15mar2020, 19may2019
begin//soft check via low__driveexists
//defaults
result:=false;

try
//check
if (x<>'') then x:=io__asfolder(x) else exit;

//get
if io__local(x) and io__driveexists(x) then
   begin
   result:=io__folderexists(x);
   if (not result) and (low__len(x)>3) then
      begin
      win____CreateDirectory(pchar(x),nil);
      result:=io__folderexists(x);
      end;
   end;
except;end;
end;

function io__makefolderchain(x:string):boolean;//17aug2025, 11aug2025
var
   p:longint;
   xfailed:boolean;
begin
//defaults
result:=false;

try
//check
if (x<>'') then x:=io__asfolder(x) else exit;

//get
result:=io__local(x) and io__folderexists(x);

//create all sub-folders from root-folder up - 17aug2025
if (not result) and io__local(x) and io__driveexists(x) then
   begin

   //init
   xfailed:=false;

   //get
   for p:=1 to low__len(x) do if (x[p-1+stroffset]='\') then
      begin

      if (not io__folderexists( strcopy1(x,1,p) )) and (not io__makefolder( strcopy1(x,1,p) )) then
         begin
         xfailed:=true;
         break;
         end;

      end;//p

   //successful
   result:=(not xfailed) and io__folderexists(x);

   end;

except;end;
end;

function io__exemarker(x:tstr8):boolean;//14nov2023
var
   z:string;
begin
//defaults
result:=false;

try
//check
if not str__lock(@x) then exit;
z:='';
//set - dynamically create the header, so that no complete trace is formed in the final EXE data stream, we can then search for this header without fear of it being repeated in the code by mistake! - 18MAY2010
x.sadd('[packed');
x.sadd('-marker]');
x.sadd('[id--');
//.id
z:=z+'1398435432908435908';
z:='__12435897'+z;
z:=z+'0-9132487211239084%%__';
z:=z+'~12@__Z';
//finalise
x.sadd(z);
x.sadd('--]');
//successful
result:=true;
except;end;
try;str__uaf(@x);except;end;
end;

function io__exemarkerb:string;//04oct2025
var
   x:tstr8;
begin

//defaults
result :='';
x      :=nil;

try
//init
x:=str__new8;

//get
io__exemarker(x);
result:=x.text;
except;end;

//free
str__free(@x);

end;

function io__hasmarker(x:pobject;const xremoveMarkerAndLeadingData:boolean):boolean;//04oct2025
var
   m:tstr8;
   i,p:longint;
begin

//defaults
result :=false;
m      :=nil;

//check
if not str__lock(x) then exit;

try
//init
m      :=str__new8;
io__exemarker(m);

//get
for p:=0 to (str__len(x)-1) do if (str__bytes0(x,p)=m.pbytes[0]) and (str__bytes0(x,p+1)=m.pbytes[1]) then
   begin

   result:=true;

   for i:=0 to pred(m.len) do if (str__bytes0(x,p+i)<>m.pbytes[i]) then
      begin

      //found marker
      result:=false;
      break;

      end;

   //delete leading data and marker
   if result then
      begin

      if xremoveMarkerAndLeadingData then str__del3( x, 0, p+m.len );
      break;

      end;

   end;//p

except;end;

//free
str__free(@m);
str__uaf(x);

end;

function io__extractfilepath(const x:string):string;//04apr2021
var
   p:longint;
begin
//defaults
result:='';

try
//get
if (x<>'') then
   begin
   for p:=low__len(x) downto 1 do if (strcopy1(x,p,1)='/') or (strcopy1(x,p,1)='\') then
      begin
      result:=strcopy1(x,1,p);
      break;
      end;
   end;
except;end;
end;

function io__extractfilename(const x:string):string;//05apr2021
var
   p:longint;
begin
result:='';

try
//defaults
result:=x;//allow default passthru -> this allows for instances with ONLY a filename present e.g. "aaaa.bcs"
//get
if (x<>'') then
   begin
   for p:=low__len(x) downto 1 do if (strcopy1(x,p,1)='/') or (strcopy1(x,p,1)='\') then
      begin
      result:=strcopy1(x,p+1,low__len(x));
      break;
      end;
   end;
except;end;
end;

function io__renamefile(const s,d:string):boolean;//local only, soft check - 27nov2016
begin
//defaults
result:=false;

try
if (s='') or (d='') then exit;
//hack check
if io__hack_dangerous_filepath_deny_mask(s) then exit;
if io__hack_dangerous_filepath_deny_mask(d) then exit;
//collision check
if strmatch(s,d) then
   begin
   result:=true;
   exit;
   end;
//get - Delphi renamefile
if io__fileexists(s) and (not io__fileexists(d)) then
   begin
   filecache__closeall_byname_rightnow(s);//close any open "s" instances - 12apr2024
   result:=win____MoveFile(pchar(s),pchar(d));
   end;
except;end;
end;

function io__shortfile(const xlongfilename:string):string;//translate long filenames to short filename, using MS api, for "MCI playback of filenames with 125+c" - 23FEB2008
var//Note: works only for existing filenames - short names accessed from disk system
  z:string;
  zlen:longint;
begin
result:='';

try
//defaults
result:=xlongfilename;
//get
low__setlen(z,max_path);
zlen:=win____getshortpathname(pchar(xlongfilename),pchar(z),max_path-1);
if (zlen>=1) then
   begin
   low__setlen(z,zlen);
   result:=z;
   end;
except;end;
end;

function io__asfolder(const x:string):string;//enforces trailing "\"
begin
if (strcopy1(x,low__len(x),1)<>'\') then result:=x+'\' else result:=x;
end;

function io__asfolderNIL(const x:string):string;//enforces trailing "\" AND permits NIL - 03apr2021, 10mar2014
begin
if (x='') then result:=''//nil
else if (not strmatch(strcopy1(x,2,2),':\')) and (not strmatch(strcopy1(x,2,2),':/')) and (strcopy1(x,1,1)<>'/') and (strcopy1(x,1,1)<>'\') then result:=x//straight pass-thru -> this allows for "home" to pass right thru unaffected - 31mar2021
else result:=io__asfolder(x);//as a folder in the format "?:\.....\" or "?:/...../" or "/..../" or "\...\"
end;

function io__folderaslabel(x:string):string;
var
   p:longint;
begin
//defaults
result:='';

try
//remove trailing slash
if (strcopy1(x,low__len(x),1)='/') or (strcopy1(x,low__len(x),1)='\') then strdel1(x,low__len(x),1);
//read down to next slash
if (x<>'') then for p:=low__len(x) downto 1 do if (strbyte1(x,p)=92) or (strbyte1(x,p)=47) then
   begin
   x:=strcopy1(x,p+1,low__len(x));
   break;
   end;
//set
result:=strdefb(x,'?');
except;end;
end;


//file format procs ------------------------------------------------------------

function io__anyformatb(xdata:pobject):string;
begin
io__anyformat2(xdata,0,result);
end;

function io__anyformat2b(xdata:pobject;xfrompos:longint):string;
begin
io__anyformat2(xdata,xfrompos,result);
end;

function io__anyformata(const xdata:array of byte):string;//19feb2025, 25jan2025
var
   b:tstr8;
begin
try
b:=str__new8;
b.aadd1(xdata,1,100);
result:=io__anyformatb(@b);
except;end;
str__free(@b);
end;

function io__anyformat(xdata:pobject;var xformat:string):boolean;//returns EXT of any known format, image, sound, frame, etc - 14may2025, 20dec2024, 18nov2024, 30jan2021
begin
result:=io__anyformat2(xdata,0,xformat);
end;

function io__anyformat2(xdata:pobject;xfrompos:longint;var xformat:string):boolean;//returns EXT of any known format, image, sound, frame, etc - 05oct2025, 24aug2025, 11jun2025, 14may2025, 20dec2024, 18nov2024, 30jan2021
label
   skipend;
var
   xdatalen:longint;

   function asame3(xfrom:longint;const x:array of byte;xcasesensitive:boolean):boolean;//20jul2024
   begin
   result:=str__asame3(xdata,xfrom+xfrompos,x,xcasesensitive);
   end;

   function i4(xpos:longint):longint;
   begin
   result:=str__int4(xdata,xpos+xfrompos);
   end;

   function w2(xpos:longint):byte;
   begin
   result:=str__wrd2(xdata,xpos+xfrompos);
   end;

   function xdib:boolean;//11jun2025
   begin
   result:=false;

   //header size
   case i4(0) of
   hsOS2:;
   hsW95:;
   hsV04_nocolorspace:;
   hsV04:;
   hsV05:;
   else  exit;
   end;

   //.planes
   if (w2(12)<>1) then exit;

   //.bits
   case w2(14) of
   1,4,8,16,24,32:;
   else exit;
   end;//case

   //.compression formats
   case i4(17) of
   BI_RGB:;
   BI_RLE8:;
   BI_RLE4:;
   BI_BITFIELDS:;
   BI_JPEG:;
   BI_PNG:;
   else   exit;
   end;

   //yes
   result:=true;
   end;

   function xfindval(xfrom,xsearchLen:longint;xfindVal:byte):boolean;
   var
      p:longint;
   begin

   //defaults
   result:=false;

   //find
   for p:=xfrom to frcmax32(xfrom+xsearchlen-1,xdatalen-1) do if (xfindVal=str__bytes0(xdata,p)) then
      begin

      result:=true;
      break;

      end;//p

   end;

   function xtep1:boolean;//orginal TEP format: "[T1..T6]...[~]...[data pixels]"
   begin

   result:=
   (
   asame3(0,[uuT,nn1],false) or
   asame3(0,[uuT,nn2],false) or
   asame3(0,[uuT,nn3],false) or
   asame3(0,[uuT,nn4],false) or
   asame3(0,[uuT,nn5],false) or
   asame3(0,[uuT,nn6],false)
   )
   and xfindval(0,300,ssSquiggle);

   end;

begin
//defaults
result:=false;
xformat:='';

try
//check
if not str__lock(xdata) then goto skipend;

xdatalen:=str__len(xdata);//05oct2025

if (xdatalen<=0) then goto skipend;

//images -----------------------------------------------------------------------
//.bmp
if      asame3(0,[uuB,uuM],true)                                        then xformat:='BMP'//'BM'
//.dib
else if xdib                                                            then xformat:='DIB'//raw DIB (excludes the leading 12 byte BMP header)
//.wmf
else if asame3(0,[215,205,198,154],true)                                then xformat:='WMF'
//.emf
else if asame3(0,[1,0,0,0],true)                                        then xformat:='EMF'
//.png
else if asame3(0,[137,80,78,71,13,10,26,10],true)                       then xformat:='PNG'//27jan2021
//.pngc
else if asame3(0,[uuP,uuN,uuG,ssDash,uuC,uuE,uuL,uuL,uuS,nn1],false)    then xformat:='PNGC'//PNG-CELLS1
//.jpg
else if asame3(0,[uuJ,uuF,uuI,uuF],false)                               then xformat:='JPG'//'JFIF'
else if asame3(0,[255,216,255],true)                                    then xformat:='JPG'//for ALL jpegs FF,D8,FF = first 3 reliably identical bytes
//.jpgt
else if asame3(0,[uuJ,uuP,uuG,uuT],false)                               then xformat:='JPGT'//transparent jpeg
//.jpge
else if asame3(0,[uuJ,uuP,uuG,ssDash,uuE,nn1],false)                    then xformat:='JPGE'//JPG-E1 -> enhanced jpeg v1 - 29jan2021
//.jpgc
else if asame3(0,[uuJ,uuP,uuG,ssDash,uuC,uuE,uuL,uuL,uuS,nn1],false)    then xformat:='JPGC'//JPG-CELLS1 - 29jan2021
//.ico
else if (asame3(0,[0,0,0,0],true) or asame3(0,[0,0,1,0],true)) and
        (not asame3(4,[0,0],true))                                      then xformat:='ICO'
//.cur
else if asame3(0,[0,0,2,0],true) and (not asame3(4,[0,0],true))         then xformat:='ICO'
//.ani
else if asame3(0,[uuR,uuI,uuF,uuF],false) and
        asame3(8,[uuA,uuC,uuO,uuN],false)                               then xformat:='ANI'//RIFF -> ANI (animated cursor)
//.san
else if asame3(0,[uuT,uuP,uuF,nn0, 4 ,uuT,uuS,uuA,uuN],true)            then xformat:='SAN'
//.pic8
else if asame3(0,[uuP,uuI,uuC,nn8],false)                               then xformat:='PIC8'//16sep2025
//.omi
else if asame3(0,[uuO,uuM,uuI],false)                                   then xformat:='OMI'
//.gif
else if asame3(0,[uuG,uuI,uuF],false)                                   then xformat:='GIF'
//.vbmp
else if asame3(0,[uuV,uuB,nn0,nn1],false)                               then xformat:='VBMP'
//.ppm
else if asame3(0,[uuP,nn3],false) or asame3(0,[uuP,nn6],false)          then xformat:='PPM'//3=ascii, 6=binary
//.pgm
else if asame3(0,[uuP,nn2],false) or asame3(0,[uuP,nn5],false)          then xformat:='PGM'//2=ascii, 5=binary
//.pbm
else if asame3(0,[uuP,nn1],false) or asame3(0,[uuP,nn4],false)          then xformat:='PBM'//1=ascii, 4=binary
//.pnm
else if asame3(0,[uuP,nn3],false) or asame3(0,[uuP,nn6],false)          then xformat:='PNM'//3=ascii, 6=binary -> need to look deeper to see if #10 or #32 is used for separators
//.xbm
else if asame3(0,[ssHash,uuD,uuE,uuF,uuI,uuN,uuE],false)                then xformat:='XBM'//#DEFINE
//.tep
else if xtep1                                                           then xformat:='TEP'//original v1 - 05sep2025

else if asame3(0,[uuT,uuE],false) and ( asame3(2,[nn1],true) or
        asame3(2,[nn2],true) or asame3(2,[nn3],true) or
        asame3(2,[nn4],true) or asame3(2,[nn5],true) or
        asame3(2,[nn6],true) )                                          then xformat:='TEP'
//.tea
else if asame3(0,[uuT,uuE,uuA,nn1,ssHash],false)                        then xformat:='TEA'//TEA1#
else if asame3(0,[uuT,uuE,uuA,nn2,ssHash],false)                        then xformat:='TEA'//TEA2# - 12apr2021
else if asame3(0,[uuT,uuE,uuA,nn3,ssHash],false)                        then xformat:='TEA'//TEA3# - 32 bit color - 18nov2024
//.tem
else if asame3(0,[uuT,uuE,uuM,nn1,ssHash],false)                        then xformat:='TEM'
//.teh
else if asame3(0,[uuT,uuE,uuH,nn1,ssHash],false)                        then xformat:='TEH'
//.teb
else if asame3(0,[uuT,uuE,uuB,nn1,ssHash],false)                        then xformat:='TEB'
//.tec
else if asame3(0,[uuT,uuE,uuC,nn1,ssHash],false)                        then xformat:='TEC'
//.t24
else if asame3(0,[uuA,uuC,uuE,uuG],false)                               then xformat:='T24'
//.anm
else if asame3(0,[uuA,uuN,uuM,ssColon],false)                           then xformat:='ANM'
//.aan
else if asame3(0,[uuA,uuA,uuN,ssHash],false)                            then xformat:='AAN'
//.aas
else if asame3(0,[ssHash,uuI,uuN,uuI,uuT],false)                        then xformat:='AAS'//it's a bit general - 29NOV2010
//.gr8
else if asame3(0,[uuG,uuR,nn8,ssColon],false)                           then xformat:='GR8'
//.bw1
else if asame3(0,[uuB,uuW,nn1,ssColon],false)                           then xformat:='BW1'//1bit binary blackANDwhite - fast read/write - 14JUL2013
//.lig
else if asame3(0,[uuL,uuI,uuG,ssHash],false)                            then xformat:='LIG'//rapid 4bit full color image encoder - 02dec2018
//.b12
else if asame3(0,[uuB,nn1,nn2,ssHash],false)                            then xformat:='B12'//12bit RGB - fast read/write - 23nov2018
//.b04
else if asame3(0,[uuB,nn0,nn4,ssHash],false)                            then xformat:='B04'//4bit RGB - fast read/write - 28nov2018
//.yuv
else if asame3(0,[uuY,uuU,uuV,ssColon],false)                           then xformat:='YUV'//16bit TV format - fast read/write - 10APR2012
//.raw24
else if asame3(0,[uuR,uuA,uuW,24],true)                                 then xformat:='RAW24'
//.img32:
else if asame3(0,[uuI,uuM,uuG,nn3,nn2,ssColon],false)                   then xformat:='IMG32'//26jul2024
//.tj32::
else if asame3(0,[uuT,uuJ,nn3,nn2,ssColon,ssColon],false)               then xformat:='TJ32'//27jul2024
//.tga "[2/10]...[24/32]" or "[3/11]...[8]"
else if (asame3(2,[2],true) or asame3(2,[10],true)) and (asame3(16,[24],true) or asame3(16,[32],true)) then xformat:='TGA'//24 or 32 bpp color image (10=RLE) - 20dec2024
else if (asame3(2,[3],true) or asame3(2,[11],true)) and asame3(16,[8],true)                            then xformat:='TGA'//8 bpp greyscale image (11=RLE)- 20dec2024


//audio ------------------------------------------------------------------------
//.mid
else if asame3(0,[uuM,uuT,uuH,uuD],false)                               then xformat:='MID'//MTHD
else if asame3(0,[uuR,uuI,uuF,uuF],false) and asame3(8,[uuR,uuM,uuI,uuD],false) then xformat:='MID'//RIFF -> RMID
//.wav
else if asame3(0,[uuR,uuI,uuF,uuF],false) and asame3(8,[uuW,uuA,uuV,uuE],false) then xformat:='WAV'//RIFF -> WAVE
//.mp3
else if asame3(0,[uuI,uuD,nn3,3],true) or//ID3+#3
        asame3(0,[uuI,uuD,nn3,2],true) or//ID3+#2
        asame3(0,[255,251,226,68],true) or//#255#251#226#68
        asame3(0,[255,251,178,4],true) or//#255#251#178#4 or #255#251#144#68
        asame3(0,[255,251,144,68],true)                                 then xformat:='MP3'

//Note: Magic number is for asf/wma/wmv data container and not the actual content format which can be audio or video
//.wma -> "30 26 B2 75 8E 66 CF 11" -> sourced from "https://en.wikipedia.org/wiki/List_of_file_signatures" - 24aug2025
else if asame3(0,[48,38,178,117,142,102,207,17],true)                   then xformat:='WMA'
//.wma -> "A6 D9 00 AA 00 62 CE 6C"
else if asame3(0,[166,217,0,170,0,98,206,108],true)                     then xformat:='WMA'

//.pcs - custom
else if asame3(0,[uuP,uuC,uuS,nn1,ssHash],false)                        then xformat:='PCS'//pc speaker sound
//.ssd - custom
else if asame3(0,[uuS,uuS,uuD,nn1,ssHash],false)                        then xformat:='SSD'//system sound

//encodings --------------------------------------------------------------------
//.b64
else if asame3(0,[uuB,nn6,nn4,ssColon],false)                           then xformat:='B64'//B64:

//.zip
else if asame3(0,[120,218],true) or asame3(0,[120,1],true) or
        asame3(0,[120,94],true)  or asame3(0,[120,156],true) or
        //pk zip format -> sourced from "https://en.wikipedia.org/wiki/List_of_file_signatures" - 24aug2025
        asame3(0,[80,75,3,4],true) or asame3(0,[80,75,5,6],true) or
        asame3(0,[80,75,7,8],true)                                      then xformat:='ZIP'//24aug2025

//.7z -> "37 7A BC AF 27 1C" -> sourced from "https://en.wikipedia.org/wiki/List_of_file_signatures" - 24aug2025
else if asame3(0,[55,122,188,175,39,28],true)                           then xformat:='7Z'

//.ioc
else if asame3(0,[uuC,ssExclaim,nn1],false)                             then xformat:='IOC'//compressed data header
//.ior
else if asame3(0,[uuC,ssExclaim,nn0],false)                             then xformat:='IOR'//raw data header (not compressed)
//.exe
else if asame3(0,[uuM,uuZ,uuP],false)                                   then xformat:='EXE'
//.dll
else if asame3(0,[uuM,uuZ,144],true)                                    then xformat:='DLL'
//.lnk
else if asame3(0,[uuL,0,0],true)                                        then xformat:='LNK'

//frames -----------------------------------------------------------------------
//sfm
else if asame3(0,[uuF,uuP,uuS,ssUnderscore,uuV,uuE,uuR,ssColon,ssSpace,uuV,nn0],false) then xformat:='SFM'//framer plus (v0) -> simple frame
//fps
else if asame3(0,[uuF,uuP,uuS,ssUnderscore,uuV,uuE,uuR,ssColon,ssSpace,uuV,nn1],false) then xformat:='FPS'//framer plus (v1) -> enhanced frame with LOGO support etc

//documents --------------------------------------------------------------------
//.bwp
else if asame3(0,[uuB,uuW,uuP,nn1],false)                               then xformat:='BWP'
//.bwd
else if asame3(0,[uuB,uuW,uuD,nn1],false)                               then xformat:='BWD'
//.rtf
else if asame3(0,[ssLCurlyBracket,ssbackslash,uuR,uuT,uuF,nn1,ssBackSlash],false) then xformat:='RTF'//22jun2022

//other ------------------------------------------------------------------------
else if asame3(0,[ssLSquarebracket,uuA,uuL,uuA,uuR,uuM,ssRSquarebracket],false) then xformat:='ALARMS'//08mar2022

else
   begin
   //nil
   end;

//successful
result:=(xformat<>'');
skipend:
except;end;
//free
str__uaf(xdata);
end;


//internal disk procs ----------------------------------------------------------

procedure idisk__init(const xnewlabel:string;const xteadata:array of byte);
var
   e:string;
begin
intdisk_inuse:=true;
//.label
if (xnewlabel<>'') then intdisk_label:=xnewlabel;
//.icon
case (sizeof(xteadata)>=2) of
true:idisk__tofile2('.be.tea',xteadata,e);
else idisk__remfile('.be.tea');
end;
end;

function idisk__fullname(const x:string):string;
begin
result:=x;
if (strcopy1(result,2,2)<>':\') then
   begin
   if ( strcopy1(result,1,3)<>(intdisk_char+':\') ) then result:=intdisk_char+':\'+result;
   end;
end;

function idisk__findnext(var xpos:longint;xfolder:string;xfolders,xfiles:boolean;var xoutname,xoutnameonly:string;var xoutfolder,xoutfile:boolean;var xoutdate:tdatetime;var xoutsize:comp;var xoutreadonly:boolean):boolean;
label//Supports single level of folders only -> all we need right now - 04apr2021
   skipend;
var
   dpos,xfolderlen,p,int1,int2:longint;
   str1:string;
   xisfile:boolean;
begin
//defaults
result:=false;
xoutname:='';
xoutnameonly:='';
xoutfolder:=false;
xoutfile:=false;
xoutdate:=date__now;
xoutsize:=0;
xoutreadonly:=false;

//range
if (xpos<0) then xpos:=0;
dpos:=xpos;

try
//check
if idisk__havescope(xfolder) then xfolder:=io__asfolder(xfolder) else goto skipend;

//init
xfolderlen:=low__len(xfolder);

//find
for p:=0 to high(intdisk_name) do
begin
dpos:=p+1;//inc
if (p>=xpos) then
   begin
   if (intdisk_name[p]<>'') then
      begin
      str1:=io__extractfilepath(intdisk_name[p]);
      if (str1<>'') then
         begin
         //init
         xisfile:=io__isfile(intdisk_name[p]);
         //get
         if (xfolders and (not xisfile) and strmatch(strcopy1(str1,1,xfolderlen),xfolder) and (low__len(str1)>xfolderlen)) or (xfiles and xisfile and strmatch(str1,xfolder)) then
            begin
            //get
            xoutname:=intdisk_name[p];
            xoutnameonly:='';
            case xisfile of
            true:begin//as a file
               if (xoutname<>'') then
                  begin
                  for int1:=low__len(xoutname) downto 1 do if (strcopy1(xoutname,int1,1)='\') or (strcopy1(xoutname,int1,1)='/') then
                     begin
                     xoutnameonly:=strcopy1(xoutname,int1+1,low__len(xoutname));
                     break;
                     end;
                  end;
               end;
            else begin//as a folder
               if (xoutname<>'') then
                  begin
                  int2:=0;
                  for int1:=low__len(xoutname) downto 1 do if (strcopy1(xoutname,int1,1)='\') or (strcopy1(xoutname,int1,1)='/') then
                     begin
                     inc(int2);
                     if (int2>=2) then
                        begin
                        xoutnameonly:=strcopy1(xoutname,int1+1,low__len(xoutname)-int1-1);//no slashes
                        break;
                        end;
                     end;
                  end;
               end;
            end;//case
            xoutfolder:=not xisfile;
            xoutfile:=xisfile;
            xoutdate:=intdisk_date[p];
            xoutreadonly:=intdisk_readonly[p];
            if xisfile and zzok(intdisk_data[p],1024) then xoutsize:=str__len(@intdisk_data[p]);
            //successful
            result:=true;
            //stop
            break;
            end;
         end;
      end;
   end;
end;//p

skipend:
except;end;
//range check
if (dpos>xpos) then xpos:=dpos;
end;

function idisk__havescope(const xname:string):boolean;
begin
result:=intdisk_inuse and (xname<>'') and (strcopy1(xname,1,1)=intdisk_char);
end;

function idisk__makefolder(xname:string;var e:string):boolean;
label
   skipend;
var
   xindex,int1,p:longint;
begin
//defaults
result:=false;
e:=gecTaskfailed;

try
//check
if idisk__havescope(xname) then xname:=io__asfolder(xname) else goto skipend;
//check - allow ONE folder level only e.g. "!:\Images\" -> or two slashes
int1:=0;
for p:=1 to low__len(xname) do if (strcopy1(xname,p,1)='\') or (strcopy1(xname,p,1)='/') then inc(int1);
if (int1>2) then goto skipend;
//get
if not idisk__find(xname,true,xindex) then goto skipend;
//successful
result:=true;
skipend:
except;end;
end;

function idisk__folderexists(const xname:string):boolean;
var
   int1:longint;
begin
result:=idisk__havescope(xname) and idisk__find(io__asfolder(xname),false,int1);
end;

function idisk__fileexists(const xname:string):boolean;
var
   int1:longint;
begin
result:=idisk__havescope(xname) and idisk__find(xname,false,int1);
end;

function idisk__find(const xname:string;xcreatenew:boolean;var xindex:longint):boolean;
var
   p:longint;
begin
//defaults
result:=false;
xindex:=0;

try
//check
if (not intdisk_inuse) or (xname='') then exit;

//find existing
for p:=0 to high(intdisk_name) do if (intdisk_name[p]<>'') and strmatch(intdisk_name[p],xname) then
   begin
   xindex:=p;
   result:=true;
   break;
   end;
   
//create new
if (not result) and xcreatenew then
   begin
   for p:=0 to high(intdisk_name) do if (intdisk_name[p]='') then
      begin
      result:=true;
      xindex:=p;
      intdisk_name[p]:=xname;
      if zznil(intdisk_data[p],2005) then intdisk_data[p]:=str__new9;//create data handler - 03apr2021
      intdisk_readonly[p]:=false;
      break;
      end;//p
   end;
except;end;
end;

function idisk__remfile(const xname:string):boolean;
label
   skipend;
var
   xindex:longint;
begin
//defaults
result:=false;

try
//check
if not intdisk_inuse then goto skipend;

//find
if idisk__find(xname,false,xindex) then
   begin
   //check
   if intdisk_readonly[xindex] then goto skipend;
   //delete
   if zzok(intdisk_data[xindex],1025) then str__clear(@intdisk_data[xindex]);
   intdisk_name[xindex]:='';
   end;
//successful
result:=true;
skipend:
except;end;
end;

function idisk__tofile(const xname:string;xdata:pobject;var e:string):boolean;//30sep2021
begin
result:=idisk__tofile1(xname,xdata,false,e);
end;

function idisk__tofile1(xname:string;xdata:pobject;xdecompressdata:boolean;var e:string):boolean;//30sep2021
label
   skipend;
var
   xindex:longint;
   b:tstr9;
begin
//defaults
result:=false;
e:=gecTaskfailed;
b:=nil;

try
//lock
//zzstr(xdata,83);
if not str__lock(xdata) then goto skipend;
//check
if not intdisk_inuse then goto skipend;
//init
xname:=idisk__fullname(xname);
//find
if not idisk__find(xname,true,xindex) then goto skipend;
//check
if intdisk_readonly[xindex] then
   begin
   e:=gecReadonly;
   goto skipend;
   end;
//write
if str__ok(@intdisk_data[xindex]) then
   begin
   str__clear(@intdisk_data[xindex]);
   if xdecompressdata and strmatch(io__anyformatb(xdata),'zip') then//not a zip archive but a compressed data stream
      begin
      b:=str__new9;//use a buffer to leave "xdata" unmodified
      str__add(@b,xdata);
      if not low__decompress(@b) then goto skipend;
      str__add(@intdisk_data[xindex],@b);
      end
   else str__add(@intdisk_data[xindex],xdata);
   end;
//.date
intdisk_date[xindex]:=date__now;
//successful
result:=true;
skipend:
except;end;
try
str__uaf(xdata);
str__free(@b);
except;end;
end;

function idisk__tofile2(const xname:string;const xdata:array of byte;var e:string):boolean;//14apr2021
begin
result:=idisk__tofile21(xname,xdata,false,e);
end;

function idisk__tofile21(const xname:string;const xdata:array of byte;xdecompressdata:boolean;var e:string):boolean;//14apr2021
var
   a:tstr9;
begin
result:=false;

try
a:=nil;
a:=str__new9;
str__aadd(@a,xdata);
result:=idisk__tofile1(xname,@a,xdecompressdata,e);
except;end;
try;str__free(@a);except;end;
end;

function idisk__fromfile(xname:string;xdata:pobject;var e:string):boolean;
label
   skipend;
var
   xindex:longint;
begin
//defaults
result:=false;
e:=gecTaskfailed;

try
//lock
//zzstr(xdata,84);
if not str__lock(xdata) then goto skipend;

//init
str__clear(xdata);
xname:=idisk__fullname(xname);

//check
if not intdisk_inuse then goto skipend;

//find
if not idisk__find(xname,false,xindex) then
   begin
   e:=gecFilenotfound;
   goto skipend;
   end;

//read
if zzok(intdisk_data[xindex],1027) then str__add(xdata,@intdisk_data[xindex]);

//successful
result:=true;
skipend:
except;end;
try;str__uaf(xdata);except;end;
end;


//filecache procs --------------------------------------------------------------
function filecache__recok(x:pfilecache):boolean;
begin
result:=(x<>nil) and x.init;
end;

procedure filecache__initrec(x:pfilecache;xslot:longint);//used internally by system
begin
//check
if (x=nil) then exit;

//clear
with x^ do
begin
init:=false;
time_created:=0;
time_idle:=0;
filehandle:=0;
filename:='';
filenameREF:=0;
opencount:=0;
usecount:=0;//only place this is set to zero again
read:=false;
write:=false;
slot:=xslot;
end;
end;

function filecache__idletime:comp;
begin
result:=add64(ms64,60000);//1 minute
end;

function filecache__enabled:boolean;
begin
result:=(system_filecache_limit>=21);
end;

procedure filecache__setenable(const xenable:boolean);//28sep2025
begin
system_filecache_limit:=frcmax32(low__aorb(20,high(system_filecache_slot)+1,xenable),high(system_filecache_slot)+1);
end;

function filecache__limit:longint;
begin
result:=system_filecache_limit;
end;

function filecache__safefilename(const x:string):boolean;
begin
result:=(x<>'') and (x[0+stroffset]<>'@') and (not io__hack_dangerous_filepath_deny_mask(x));
end;

procedure filecache__closeall;
var
   p:longint;
begin
for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init then system_filecache_slot[p].opencount:=0;
system_filecache_timer:=0;//act quickly
end;

procedure filecache__closeall_rightnow;
var
   p:longint;
begin
for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init then filecache__closerec(@system_filecache_slot[p]);
end;

procedure filecache__closeall_byname_rightnow(const x:string);
var
   p:longint;
   xref:comp;
begin
if (x<>'') and filecache__enabled then
   begin
   xref:=low__ref256u(x);
   for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init and (xref=system_filecache_slot[p].filenameREF) and strmatch(x,system_filecache_slot[p].filename) then filecache__closerec(@system_filecache_slot[p]);
   end;
end;

procedure filecache__closerec(x:pfilecache);
begin
if filecache__recok(x) then
   begin
   x.init:=false;
   if (x.filehandle>=1) then win____closehandle(x.filehandle);
   with x^ do
   begin
   time_created  :=0;
   time_idle     :=0;
   filehandle    :=0;
   filename      :='';
   filenameREF   :=0;
   opencount     :=0;
   read          :=false;
   write         :=false;
   end;
   //.inc usecount
   filecache__inc_usecount(x);
   end;
end;

procedure filecache__closefile(var x:pfilecache);
begin
if filecache__recok(x) then
   begin
   x.opencount:=frcmin32(x.opencount-1,0);
   if (x.opencount<=0) then system_filecache_timer:=0;//instruct management to act quickly
   //.not caching -> close file right now
   if not filecache__enabled then filecache__closerec(x);
   end;
end;

procedure filecache__inc_usecount(x:pfilecache);
begin
if filecache__recok(x) then
   begin
   //inc the "usecount" -> rolls between 1..max32, never hits zero - 12apr2024
   if (x^.usecount<max32) then inc(x^.usecount) else x^.usecount:=1;
   end;
end;

function filecache__newslot:longint;
var
   p:longint;
   xms64:comp;
begin
//defaults
result:=-1;

try
//new
if (result<0) then
   begin
   for p:=0 to (system_filecache_limit-1) do if not system_filecache_slot[p].init then
      begin
      result:=p;
      //.inc usecount
      filecache__inc_usecount(@system_filecache_slot[p]);
      //.stop
      break;
      end;
   end;

//oldest
if (result<0) then
   begin
   //.oldest with opencount=0
   if (result<0) then
      begin
      xms64:=0;
      for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init and (system_filecache_slot[p].opencount<=0) and ((system_filecache_slot[p].time_idle<xms64) or (xms64<=0)) then
         begin
         xms64:=system_filecache_slot[p].time_idle;
         result:=p;
         end;
      end;
   //.oldest regardless of opencount
   if (result<0) then
      begin
      xms64:=0;
      for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init and ((system_filecache_slot[p].time_idle<xms64) or (xms64<=0)) then
         begin
         xms64:=system_filecache_slot[p].time_idle;
         result:=p;
         end;
      end;
   //clear the slot
   if (result>=0) then filecache__closerec(@system_filecache_slot[result]);//auto increments the usecounter
   end;
except;end;

//emergency fallback - should never happen
if (result<0) then
   begin
   result:=0;
   //.inc usecount
   filecache__inc_usecount(@system_filecache_slot[result]);
   end;
end;

function filecache__find(const x:string;xread,xwrite:boolean;var xslot:longint):boolean;//13apr2024: updated
var//xread=false and xwrite=false -> returns any record without matching the read/write values - 13apr2024
   p:longint;
   xref:comp;
begin
//defaults
result:=false;
xslot:=0;

//check
if (x='') then exit;

//find
xref:=low__ref256u(x);
for p:=0 to (system_filecache_limit-1) do if system_filecache_slot[p].init and ((not xread) or system_filecache_slot[p].read) and ((not xwrite) or system_filecache_slot[p].write) and (xref=system_filecache_slot[p].filenameREF) and strmatch(x,system_filecache_slot[p].filename) then
   begin
   result:=true;
   xslot:=p;
   break;
   end;
end;

function filecache__remfile(const x:string):boolean;
begin
//defaults
result:=false;
//check
if not filecache__safefilename(x) then exit;

//close cached files -> any open instances MUST be closed regardless
filecache__closeall_byname_rightnow(x);

//file not found -> ok
if not io__fileexists(x) then
   begin
   result:=true;
   exit;
   end;

//delete the file
io__filesetattr(x,0);
win____deletefile(pchar(x));

//return result
result:=not io__fileexists(x);
end;

function filecache__openfile_anyORread(const x:string;var v:pfilecache;var vmustclose:boolean;var e:string):boolean;
var
   i:longint;
begin
//defaults
result:=false;
v:=nil;
vmustclose:=false;
e:=gecTaskfailed;

//exists in cache -> ignore read and write values
if (not result) and filecache__find(x,false,false,i) then
   begin
   system_filecache_slot[i].time_idle:=filecache__idletime;//keep record alive
   v:=@system_filecache_slot[i];
   if (system_filecache_slot[i].opencount<max32) then inc(system_filecache_slot[i].opencount);
   result:=true;
   end;

//open the file for reading
if (not result) then
   begin
   result:=filecache__openfile_read(x,v,e);
   if result then vmustclose:=true;
   end;
end;

function filecache__openfile_read(const x:string;var v:pfilecache;var e:string):boolean;
label
   redo,skipend;
var
   h:thandle;
   i:longint;

   function xopen_read:boolean;
   begin
   h:=win____createfile(pchar(x),generic_read,file_share_read or file_share_write,nil,open_existing,file_attribute_normal,0);
   if (h<=0) then h:=win____createfile(pchar(x),generic_read,file_share_read,nil,open_existing,file_attribute_normal,0);//fallback proc for readonly media -> in case it fails to open - 13apr2024
   result:=(h>=1);//13apr2024: updated
   end;

begin
//defaults
result:=false;
v:=nil;
e:=gecTaskfailed;

//check
if not filecache__safefilename(x) then
   begin
   e:=gecBadfilename;
   exit;
   end;

try
//exists in cache (read)
if (not result) and filecache__find(x,true,false,i) then
   begin
   system_filecache_slot[i].time_idle:=filecache__idletime;//keep record alive
   v:=@system_filecache_slot[i];
   if (system_filecache_slot[i].opencount<max32) then inc(system_filecache_slot[i].opencount);
   result:=true;
   end;

//create cache entry
if (not result) and io__fileexists(x) then
   begin
   //.inc open count
   if (system_filecache_filecount<max64) then system_filecache_filecount:=add64(system_filecache_filecount,1) else system_filecache_filecount:=1;

   //.open for reading
   if not xopen_read then
      begin
      //.close and try again
      filecache__closeall_byname_rightnow(x);
      if not xopen_read then
         begin
         e:=gecFileinuse;
         goto skipend;
         end;
      end;

   //.file is open
   if (h>=1) then
      begin
      i:=filecache__newslot;
      v:=@system_filecache_slot[i];
      with system_filecache_slot[i] do
      begin
      init          :=true;
      opencount     :=1;
      filehandle    :=h;//set the filehandle
      filename      :=x;
      filenameREF   :=low__ref256u(x);
      time_created  :=ms64;
      time_idle     :=filecache__idletime;//keep record alive
      read          :=true;
      write         :=false;
      end;//with
      //successful
      result:=true;
      end;
   end;

skipend:
except;end;
end;

function filecache__openfile_write(const x:string;var v:pfilecache;var e:string):boolean;
var
   bol1:boolean;
begin
result:=filecache__openfile_write2(x,false,bol1,v,e);
end;

function filecache__openfile_write2(const x:string;xremfile_first:boolean;var xfilecreated:boolean;var v:pfilecache;var e:string):boolean;//17aug2025
label
   skipend;
var
   h:thandle;
   i:longint;

   function xopen_write:boolean;
   var
      h2:thandle;
   begin
   //get
   case io__fileexists(x) of
   true:h:=win____createfile(pchar(x),generic_read or generic_write,file_share_read,nil,open_existing,file_attribute_normal,0);
   else begin

      //was: case io__makefolder(io__extractfilepath(x)) of//create folder
      case io__makefolderchain(io__extractfilepath(x)) of//make folder chain - 17aug2025
      true:begin//create file

         h2:=win____createfile(pchar(x),generic_read or generic_write,0,nil,create_always,file_attribute_normal,0);

         //.fallback mode
         if (h2>=1) then
            begin

            win____closehandle(h2);
//            h:=win____createfile(pchar(x),generic_read or generic_write,file_share_read,nil,open_existing,file_attribute_normal,0);
            h:=win____createfile(pchar(x),generic_read or generic_write,file_share_read,nil,open_existing,file_attribute_normal,0);
            if (h>=1) then xfilecreated:=true;

            end;

         end;

      else begin

         h:=0;
         e:=gecPathnotfound;

         end;
      end;//case

      end;
   end;//case
   //set
   result:=(h>=1);//updated 13apr2024
   end;
begin
//defaults
result:=false;
v:=nil;
e:=gecTaskfailed;
xfilecreated:=false;

//check
if not filecache__safefilename(x) then
   begin
   e:=gecBadfilename;
   exit;
   end;

try
//remfile_first
if xremfile_first and (not io__remfile(x)) then
   begin
   e:=gecFileinuse;
   goto skipend;
   end;

//exists in cache (write)
if (not result) and filecache__find(x,false,true,i) then
   begin
   system_filecache_slot[i].time_idle:=filecache__idletime;//keep record alive
   v:=@system_filecache_slot[i];
   if (system_filecache_slot[i].opencount<max32) then inc(system_filecache_slot[i].opencount);
   result:=true;
   end;

//create cache entry
if (not result) then
   begin
   //.inc open count
   if (system_filecache_filecount<max64) then system_filecache_filecount:=add64(system_filecache_filecount,1) else system_filecache_filecount:=1;

   //.open for writing
   if not xopen_write then
      begin
      //.close and try again
      filecache__closeall_byname_rightnow(x);
      if not xopen_write then
         begin
         e:=gecFileinuse;
         goto skipend;
         end;
      end;

   //.file is open
   if (h>=1) then
      begin
      i:=filecache__newslot;
      v:=@system_filecache_slot[i];
      with system_filecache_slot[i] do
      begin
      init          :=true;
      opencount     :=1;
      filehandle    :=h;
      filename      :=x;
      filenameREF   :=low__ref256u(x);
      time_created  :=ms64;
      time_idle     :=filecache__idletime;//keep record alive
      read          :=true;
      write         :=true;
      end;//with
      //successful
      result:=true;
      end;
   end;

skipend:
except;end;
end;

procedure filecache__managementevent;
var
   xcount,xactive,p:longint;
   xms64:comp;
begin
//defaults
xcount:=0;
xactive:=0;
//get
if msok(system_filecache_timer) then
   begin
   try
   //init
   xms64:=ms64;
   //get
   for p:=0 to (system_filecache_limit-1) do
   begin
   if system_filecache_slot[p].init then
      begin
      case (system_filecache_slot[p].opencount<=0) and (system_filecache_slot[p].time_idle<>0) and (xms64>system_filecache_slot[p].time_idle) of
      true:filecache__closerec(@system_filecache_slot[p]);//close record
      else begin
         xcount:=p+1;//upper boundary as defined by the highest active slot
         inc(xactive);//simply the number of slots open regardless of their position within the system pool
         end;
      end;//case
      end;//if
   end;//p
   except;end;
   //sync information vars
   system_filecache_count:=xcount;
   system_filecache_active:=xactive;
   //reset timer
   msset(system_filecache_timer,5000);
   end;//if
end;

end.
