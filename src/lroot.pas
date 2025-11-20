unit lroot;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses {$ifdef gui4}forms, windows, classes, graphics,{$endif} lwin, lwin2;
{$ifdef d3laz} const stroffset=1; {$else} const stroffset=0; {$endif}  {0 or 1 based string index handling}
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
//## Library.................. root (modernised legacy codebase)
//## Version.................. 1.00.3835 (+1)
//## Items.................... 32
//## Last Updated ............ 12oct2025, 10oct2025, 08oct2025, 05oct2025
//## Lines of Code............ 21,200+
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
//## | app__*                 | family of procs   | 1.00.122  | 05oct2025   | App related procs for legacy apps
//## | dialog__*              | family of procs   | 1.00.072  | 12oct2025   | MS Dialogs - 10oct2025
//## | monitors__*            | family of procs   | 1.00.432  | 26sep2025   | Multi-monitor support - 18feb2025, 06jan2025, 05dec2024
//## | low__*                 | low level procs   | 1.00.179  | 29sep2025   | Support procs - 03sep2025, 25jul2025, 01apr2025, 06jan2025, 01may2024
//## | float__*, int__*       | family of procs   | 1.00.052  | 12dec2024   | Float and integer string-to-number and number-to-string conversion routines - 12dec2024: float__tostr_divby(),  01nov2024
//## | block__*               | family of procs   | 1.00.095  | 17apr2024   | Block based memory management procs
//## | str__*                 | family of procs   | 1.00.240  | 30aug2025   | Procs for working with both tstr8 and tstr9 objects, 04may2025, 17apr2025, 16mar2025, 22nov2024, 11aug2024: str__pbytes0 and str__setpbytes0, 25jul2024: str__tob64/fromb64, 17apr2024
//## | mem__*                 | family of procs   | 1.00.052  | 01sep2025   | Heap based management procs - 27aug2025, 27aug2025, 17apr2024
//## | filter__*              | family of procs   | 1.00.020  | 18sep2025   | Complex mask procs - 04nov2019
//## | twproc                 | tobject           | 1.00.021  | 04may2024   | Window based window message handler - 09feb2024: fixed destroy(), 23dec2023
//## | tstr8                  | tobjectex         | 1.00.790  | 29aug2025   | 8bit binary memory handler - memory as one chunk - 28may2025, 15may2025, 25feb2024: splice() proc, 26dec2023, 27dec2022, 20mar2022, 27dec2021, 28jul2021, 30apr2021, 14feb2021, 28jan2021, 21aug2020
//## | tstr9                  | tobjectex         | 1.00.268  | 15mar2025   | 8bit binary memory handler - memory as a stream of randomly allocated memory blocks - 07mar2024: softclear2(), 25feb2024: splice() proc, 07feb2024: Optimised for speed, 04feb2024: Created
//## | tvars8                 | tobject           | 1.00.245  | 12may2025   | 8bit binary replacement for "tdynamicvars" and "tdynamictext" -> simple, fast, and lighter with full binary support (no string used) - 28jun2024, 26jun2024: updated, 15jan2024, 31jan2022, 02jan2022, 16aug2020
//## | tfastvars              | tobject           | 1.00.112  | 19aug2025   | Faster version of tvars8 (10x faster) and simpler - 12oct2024, 12oct2024: dedicated getdata/setdata procs for IN ORDER processing of items, 24aug2024, 24mar2024: fixed ilimit (was: max-1 => now: max+1) 07feb2024: updated, 12jan2024: support for tstr9 in sfoundB() proc, 25dec2023
//## | tdynamiclist           | tobject           | 1.00.120  | 25jul2024   | Base class for dynamic arrays/lists of differing structures: byte, word, longint, currency, pointer etc. - 25jul2024: forcesize() proc, 09feb2024: removed "protected" for "public", 08aug2017
//## | tdynamicbyte           | tdynamiclist      | 1.00.010  | 09feb2024   | Dynamic array of byte (1b/item) - 09feb2024: removed "protected" for "public", 21jun2006
//## | tdynamicword           | tdynamiclist      | 1.00.012  | 10aug2024   | Dynamic array of word (2b/item) - 10aug2024: removed "protected" for "public",
//## | tdynamicinteger        | tdynamiclist      | 1.00.023  | 09feb2024   | Dynamic array of longint (4b/item) - 09feb2024: removed "protected" for "public", 10jan2012
//## | tdynamicdatetime       | tdynamiclist      | 1.00.010  | 09feb2024   | Dynamic array of tdatetime (8b/item) - 09feb2024: removed "protected" for "public", 25dec2023, 21jun2006
//## | tdynamiccurrency       | tdynamiclist      | 1.00.014  | 09feb2024   | Dynamic array of currency (8b/item) - 09feb2024: removed "protected" for "public", 21jun2006
//## | tdynamiccomp           | tdynamiclist      | 1.00.010  | 09feb2024   | Dynamic array of comp (8b/item) - 09feb2024: removed "protected" for "public", 20oct2012
//## | tdynamicpointer        | tdynamiclist      | 1.00.010  | 09feb2024   | Dynamic array of pointer - 09feb2024: removed "protected" for "public", 21jun2006
//## | tdynamicstring         | tdynamiclist      | 1.00.050  | 01may2025   | Dynamic array of string - 09feb2024: removed "protected" for "public", 29jul2017, 6oct2005
//## | tlitestrings           | tobjectex         | 1.00.170  | 07sep2015   | Dynamic array of STRING, lite and fast for best RAM usage
//## | tdynamicname           | tdynamicstring    | 1.00.025  | 31mar2024   | Dynamic array of STRING with quick lookup system - 31mar2024: updated with comp and to fit new code, 05apr2005: created
//## | tdynamicnamelist       | tdynamicname      | 1.00.045  | 09apr2024   | Dynamically tracks a list of names - 09apr2024: find(), 08feb2020: updated, 30aug2007: created
//## | tdynamicvars           | tobject           | 1.00.200  | 09apr2024   | Dynamic list of name/value pairs, large capacity, rapid lookup system - 09apr2024: added/removed procs to be more inline with tfastvars, 15jun2019: updated, 20oct2018: updated, 13apr2018: updated, 04JUL2013: created
//## | tdynamicstr8           | tdynamiclist      | 1.00.040  | 25jul2024   | Dynamic array of tstr8 - 25jul2024: isnil(), 09feb2024: removed "protected" for "public", 01jan2024, 28dec2023
//## | tdynamicstr9           | tobjectex         | 1.00.155  | 17feb2024   | Dynamic array of tstr9 using memory blocks, 17feb2024: created
//## | tintlist               | tobjectex         | 1.00.155  | 20feb2024   | Dynamic array of longint/pointer using memory blocks, 20feb2024: mincount() fixed, 17feb2024: created
//## | tcmplist               | tobjectex         | 1.00.055  | 18jun2025   | Dynamic array of comp/double/datetime using memory blocks, 18jun2025: fixed index tracking, 20feb2024, 20feb2024: mincount() fixed, 17feb2024: created
//## | tmemstr                | tstream           | 1.00.030  | 25jul2024   | tstringstream replacement - accepts tstr8 and tstr9 handlers -> for compatibility with Lazarus stream based handlers
//## ==========================================================================================================================================================================================================================


var
   //tdynamiclist and others - global "incsize" override for intial creation, allows for easy coordinated INCSIZE increase e.g. "incsize=10,000" for much better RAM usage - 22MAY2010
   globaloverride_incSIZE:longint=0;//set to 1 or higher to override controls (used when object is first created)


type
   pdaytable=^tdaytable;
   tdaytable=array[1..12] of word;


const

   //memory block size
   system_blocksize               =8192;//do not set below 4096 -> required by tintlist/tstr9 for a large data range

   //message loop sleep delay in milliseconds
   system_timerinterval          =15;//15 ms - 28apr2024


   rcode          =#13#10;
   r10            =#10;

   pcRefsep       ='_';
   pcSymSafe      ='-';//used to replace unsafe filename characters

   crc_seed       =-306674912;//was $edb88320 - avoid constant range error
   crc_against    =-1;//was $ffffffff

   //.12bit unsigned range
   min12          =0;
   max12          =4095;
   //.16bit unsigned range
   min16          =0;
   max16          =65535;//16bit
   //.32bit signed range
   min32          =-2147483647-1;//makes -2147483648 -> avoids constant range error
   max32          =2147483647;
   //.64bit signed range
   min64          =-999999999999999999.0;//18 whole digits - 1 million terabytes
   max64          = 999999999999999999.0;//18 whole digits - 1 million terabytes

   maxword        =max16;
   maxport        =max16;
   maxpointer     =(max32 div sizeof(pointer))-1;
   maxrow         =(max16*10);//safe range (0..655,350) - 28dec2023
   maxpixel       =max32 div 50;//safe even for large color sets such as "tcolor96" - 29apr2020


   //special message handlers --------------------------------------------------
   wm_onmessage_net     =WM_USER + $0001;//route window message for socket based communications to the net__* subsystem
   wm_onmessage_mm      =WM_USER + $0002;//multimedia message -> route to snd unit - 22jun2024
   wm_onmessage_wave    =WM_USER + $0003;//wave message -> route to snd unit
   wm_onmessage_netraw  =WM_USER + $0004;//raw/unmanaged networking - 04apr2025
   wm_onmessage_nn      =WM_USER + $0005;//route window message for socket based communications to the nn__* subsystem - 01oct2025


   //app run styles ------------------------------------------------------------
   rsMustBoot =-1;
   rsBooting  =0;
   rsUnknown  =1;
   rsConsole  =2;
   rsService  =3;
   rsGUI      =4;
   rsMax      =4;

   
   //liteform ------------------------------------------------------------------
   lfmDown    =0;
   lfmMove    =1;
   lfmUp      =2;


   //TBT encryption ------------------------------------------------------------
   tbtFeedback =0;
   tbtEncode   =1;
   tbtDecode   =2;


   //ecap support --------------------------------------------------------------
   glseEncrypt      =0;
   glseDecrypt      =1;
   glseTextEncrypt  =2;
   glseTextDecrypt  =3;
   glseEDK          ='2-13-09afdklJ*[q-02490-9123poasdr90q34[9q2u3-[9234[9u0w3689yq28901iojIOJHPIae;riqu58pq5uq9531asdo';


   //colors --------------------------------------------------------------------
   clTopLeft      =-1;
   clBotLeft      =-2;
   clnone         =255+(255*256)+(255*256*256)+(31*256*256*256);
   clBlack        =$000000;
   clMaroon       =$000080;
   clGreen        =$008000;
   clOlive        =$008080;
   clNavy         =$800000;
   clPurple       =$800080;
   clTeal         =$808000;
   clGray         =$808080;
   clSilver       =$C0C0C0;
   clRed          =$0000FF;
   clLime         =$00FF00;
   clYellow       =$00FFFF;
   clBlue         =$FF0000;
   clFuchsia      =$FF00FF;
   clAqua         =$FFFF00;
   clLtGray       =$C0C0C0;
   clDkGray       =$808080;
   clWhite        =$FFFFFF;
   clDefault      =$20000000;


   //MessageBox ----------------------------------------------------------------
   mbCustom           =$0;
   mbError            =$10;
   mbInformation      =$40;
   mbWarning          =$30;
   mbrYes             =6;
   mbrNo              =7;

   MB_OK              = $00000000;
   MB_OKCANCEL        = $00000001;
   MB_ABORTRETRYIGNORE = $00000002;
   MB_YESNOCANCEL     = $00000003;
   MB_YESNO           = $00000004;
   MB_RETRYCANCEL     = $00000005;

   //.bitmap header sizes and their meanings
   hsOS2              =12;
   hsW95              =40;
   hsV04_nocolorspace =56;//Gimp
   hsV04              =108;
   hsV05              =124;

   //.bitmap compression formats
   BI_RGB 	  =0;//uncompressed
   BI_RLE8 	  =1;//run-length encoded (RLE) format for bitmaps with 8 bpp.
   BI_RLE4        =2;//run-length encoded (RLE) format for bitmaps with 4 bpp
   BI_BITFIELDS   =3;//variable bit color encoding, using 3xDWORD "bit-masks" that tell decoder where each color component's data is stored
   BI_JPEG        =4;//jpeg image
   BI_PNG         =5;//png image

   //.common integer values
   int_255_255_255=255 + (255*256) + (255*256*256);
   int_240_240_240=240 + (240*256) + (240*256*256);
   int_192_192_192=192 + (192*256) + (192*256*256);
   int_128_128_128=128 + (128*256) + (128*256*256);
   int_127_127_127=127 + (127*256) + (127*256*256);
   int_64_64_64   =64  + (64*256)  + (64*256*256);
   int_32_32_32   =32  + (32*256)  + (32*256*256);
   int_20_20_20   =20  + (20*256)  + (20*256*256);
   int_10_10_10   =10  + (10*256)  + (10*256*256);
   int_1_1_1      =1   + (1*256)   + (1*256*256);
   int_1_0_0      =1   + (0*256)   + (0*256*256);
   int_0_1_0      =0   + (1*256)   + (0*256*256);
   int_0_0_1      =0   + (0*256)   + (1*256*256);


   //G.E.C. -->> General Error Codes v1.00.028, 22jun2005
   gecFeaturedisabled        ='Feature disabled';  
   gecFailedtoencrypt        ='Failed to encrypt';//20jun2016
   gecFileInUse              ='File in use / access denied';//translate('File in use / access denied')
   gecFolderInUse            ='Folder in use / access denied';//translate('Folder in use / access denied');//20par2025
   gecNotFound               ='Not found';//translate('Not found')
   gecBadFileName            ='Bad file name';//translate('Bad file name')
   gecFileNotFound           ='File not found';//translate('File not found')
   gecUnknownFormat          ='Unknown format';//translate('Unknown format')
   gecTaskCancelled          ='Task cancelled';//translate('Task cancelled')
   gecPathNotFound           ='Path not found';//translate('Path not found')
   gecOutOfMemory            ='Out of memory';//translate('Out of memory')
   gecIndexOutOfRange        ='Index out of range';//translate('Index out of range')
   gecUnexpectedError        ='Unexpected error';//translate('Unexpected error')
   gecDataCorrupt            ='Data corrupt';//translate('Data corrupt')
   gecUnsupportedFormat      ='Unsupported format';//translate('Unsupported format')
   gecAccessDenied           ='Access Denied';{04/11/2002}//translate('Access Denied')
   gecOutOfDiskSpace         ='Out of disk space';//translate('Out of disk space')
   gecAProgramExistsWithThatName='An app exists with that name';//translate('An app exists with that name')
   gecUseAnother             ='Use another';//translate('Use another')
   gecSendToFailed           ='Send to failed';//translate('Send to failed')
   gecCapacityReached        ='Capacity reached';//translate('Capacity reached')
   gecNoFilesFound           ='No files found';//translate('No files found')
   gecUnsupportedEncoding    ='Unsupported encoding';//translate('Unsupported encoding')
   gecUnsupportedDecoding    ='Unsupported decoding';//translate('Unsupported decoding')
   gecEmpty                  ='Empty';//translate('Empty')
   gecLocked                 ='Locked';//translate('Locked')
   gecTaskFailed             ='Task failed';//translate('Task failed')
   gecTaskSuccessful         ='Task successful';//translate('Task successful')
   //.New 16/08/2002
   gecVirusWarning           ='Virus Warning - Tampering detected';//translate('Virus Warning - Tampering detected')
   gecTaskTimedOut           ='Task Timed Out';//translate('Task Timed Out')
   gecIncorrectUnlockInformation='Incorrect Unlock Information';//Translate('Incorrect Unlock Information');
   gecOk                     ='OK';//translate('OK');
   gecReadOnly               ='Read Only';//translate('Read Only');
   gecRepeat                 ='Repeat';//translte('Repeat');
   gecBusy                   ='Busy';//translate('Busy');
   gecReady                  ='Ready';//translate('Ready');
   gecWorking                ='Working';//translate('Working');
   gecSearching              ='Searching';//translate('Searching');
   gecNoFurtherMatchesFound  ='No further matches found';//translate('No further matches found');
   gecAccessGranted          ='Access Granted';//Translate('Access Granted') - [bait]
   gecFailed                 ='Failed';//Translate('Failed') - [bait]
   gecDeleted                ='Deleted';//Translate('Deleted') - [bait]
   gecSkipped                ='Skipped';//Translate('Skipped') - [bait]
   gecEXTnotAllowed          ='Extension not allowed';//Translate('Extension not allowed') - [bait]
   gecSaved                  ='Saved';//Translate('Saved')
   gecNoContent              ='No content';//Translate('No content present') - [bait]
   gecSyntaxError            ='Invalid syntax';//translate('Invalid syntax') - [bait]
   gecUnterminatedLine       ='Unterminated line';//translate('Unterminated line') - [bait]
   gecUnterminatedString     ='Unterminated string';//translate('Unterminated string') - [bait]
   gecUndefinedObject        ='Undefined Object';//translate('Undefined Object') - [bait]
   gecPrivilegesModified     ='Privileges Modified';//Translate('Privileges Modified') - [bait]
   gecConnectionFailed       ='Connection Failed';//translate('Connection Failed');
   gecTimedOut               ='Timed Out';//translate('Timed Out');
   //.new 03DEC2009
   gecNoPrinter              ='No Printer';

   
   //base64 - references
   base64:array[0..64] of byte=(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47,61);
   base64r:array[0..255] of byte=(113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,110,113,113,113,111,100,101,102,103,104,105,106,107,108,109,113,113,113,112,113,113,113,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,113,113,113,113,113,113,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113);

   //months
   system_month:array[1..12] of string=('January','February','March','April','May','June','July','August','September','October','November','December');
   system_month_abrv:array[1..12] of string=('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
   //days
   system_dayOfweek:array[1..7] of string=('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
   system_dayOfweek_abrv:array[1..7] of string=('Sun','Mon','Tue','Wed','Thu','Fri','Sat');


   //File Extension Codes
   fesep          =';';//main separator -> "bat;bmp;exe;txt+bwd+bwp;ico;"
   fesepX         ='+';//sub-separator for instances where multiple extensions are specified for a single type e.g. "txt+bwd+bwp"
   feany          ='*';//special
   febat          ='bat';
   fec2p          ='c2p';//Claude 2 product - 12jan2022
   fec2v          ='c2v';//Claude 2 values - 24jan2022
   feini          ='ini';//24jan2022
   fetxt          ='txt';
   febwd          ='bwd';
   febwp          ='bwp';
   fesfef         ='sfef';//small file encrypter file
   fehtm          ='htm';//20aug2024
   fehtml         ='html';
   fexml          ='xml';
   fetep          ='tep';
   fetea          ='tea';
   febmp          ='bmp';
   fedib          ='dib';//14may2025
   feimg32        ='img32';//26jul2024
   fesan          ='san';//16sep2025
   fepic8         ='pic8';//16sep2025
   fetj32         ='tj32';//27jul2024
   fegif          ='gif';
   fetga          ='tga';//20dec2024
   feppm          ='ppm';//02jan2025
   fepgm          ='pgm';//02jan2025
   fepbm          ='pbm';//02jan2025
   fepnm          ='pnm';//02jan2025
   fexbm          ='xbm';//02jan2025
   fejpg          ='jpg';
   fejif          ='jif';
   fejpeg         ='jpeg';
   fepng          ='png';
   feico          ='ico';//15feb2022
   fecur          ='cur';
   feani          ='ani';
   feres          ='res';//05may2025
   febcs          ='bcs';//blaiz color scheme
   febvid         ='bvid';//basic video
   feAU22         ='au22';//raw audio
   feAU44         ='au44';//raw audio
   feAU48         ='au48';//raw audio
   fevmt          ='vmt';//video magic track - 06jul2021
   fevmp          ='vmp';//video magic project - 06jul2021
   femjpeg        ='mjpeg';//motion jpeg - supported by VLC - 20jun2021
   femp4          ='mp4';
   fewebm         ='webm';
   feabr          ='abr';//Abra Cadabra project - 01aug2021
   feaccp         ='accp';//Animated Cursor Creator Project - 07feb2022
   feAlarms       ='alarms';//08mar2022
   feReminders    ='reminders';//09mar2022
   feM3U          ='m3u';//20mar2022 - playlist
   feFootnote     ='footnote';//21mar2022
   feCursorScript ='cscript';//17may2022
   feQuoter       ='quoter';//24dec2022
   feQuoter2      ='quoter2';//10jan2022
   fezip          ='zip';//10feb2023
   feexe          ='exe';//14nov2023
   fepas          ='pas';//23jul2024
   fedpr          ='dpr';//20mar2025
   fec3           ='c3';//20aug2024 - Claude3 code file
   feref3         ='ref3';//20aug2024 - Claude3 ref file
   fenupkg        ='nupkg';//31mar2025
   femap          ='map';//19may2025
   //.midi formats
   femid          ='mid';
   femidi         ='midi';
   fermi          ='rmi';

   //Note: for an extension to work with tbasicnav ( popopen, popsave dlgs etc) it must exist in "io__findext()" - 23jul2024

   //.combinations
   feallfiles     =feany;
   fealldocs      =fetxt+fesepX+febwd+fesepX+febwp;
   feallimgs      =fepng+fesepX+
                   fegif+fesepX+
                   {$ifdef jpeg}fejpg+fesepX+fejif+fesepX+fejpeg+fesepX+{$endif}
                   febmp+fesepX+
                   fedib+fesepX+
                   feico+fesepX+fecur+fesepX+feani+fesepX+
                   fetga+fesepX+
                   feppm+fesepX+
                   fepgm+fesepX+
                   fepbm+fesepX+
                   fepnm+fesepX+
                   fexbm+fesepX+
                   fetea+fesepX+
                   feimg32+fesepX+
                   fesan+fesepX+//16sep2025
                   {$ifdef gamecore}fepic8+fesepX+{$endif}//16sep2025
                   {$ifdef jpeg}fetj32+{$endif} '';
   feallcurs      =fecur+fesepX+feani;
   feallcurs2     =fecur+fesepX+feani+fesepX+feico+fesepX+fepng+fesepX+fegif+fesepX+fesan+fesepX+fetea+fesepX+feimg32{$ifdef gamecore}+fesepX+fepic8{$endif};//29may2025, 22may2022
   fealljpgs      ={$ifdef jpeg}fejpg+fesepX+fejif+fesepX+fejpeg+{$endif} '';
   febrowserimgs  =fepng+fesepX+
                   fegif+fesepX+
                   {$ifdef jpeg}fejpg+fesepX+fejif+fesepX+fejpeg+fesepX+{$endif}
                   feico+fesepX+
                   febmp+fesepX+//29may2025, 18mar2025
                   '';

   felosslessimgs =febmp+fesepX+//11apr2025
                   fedib+fesepX+//14may2025
                   fepng+fesepX+
                   fetga+fesepX+
                   feppm+fesepX+
                   fepnm+fesepX+
                   fetea+fesepX+
                   feimg32+fesepX+
                   fesan+fesepX+
                   {$ifdef gamecore}fepic8+fesepX+{$endif}//16sep2025
                   '';

   //Preformatted File Extension Codes
   peany          =feany+fesep;//special
   pebat          =febat+fesep;
   pec2p          =fec2p+fesep;
   pec2v          =fec2v+fesep;
   peini          =feini+fesep;
   petxt          =fetxt+fesep;
   pebwd          =febwd+fesep;
   pebwp          =febwp+fesep;
   pesfef         =fesfef+fesep;
   pexml          =fexml+fesep;
   pehtml         =fehtml+fesep;
   petep          =fetep+fesep;
   petea          =fetea+fesep;
   pebmp          =febmp+fesep;
   pedib          =fedib+fesep;
   peimg32        =feimg32+fesep;
   pesan          =fesan+fesep;
   pepic8         =fepic8+fesep;
   petj32         =fetj32+fesep;
   pegif          =fegif+fesep;
   petga          =fetga+fesep;
   peppm          =feppm+fesep;
   pepgm          =fepgm+fesep;
   pepbm          =fepbm+fesep;
   pepnm          =fepnm+fesep;
   pexbm          =fexbm+fesep;
   pejpg          =fejpg+fesep;
   pejif          =fejif+fesep;
   pejpeg         =fejpeg+fesep;
   pepng          =fepng+fesep;
   peico          =feico+fesep;
   pecur          =fecur+fesep;
   peani          =feani+fesep;
   peres          =feres+fesep;
   pebvid         =febvid+fesep;
   peAU44_48_22   =feAU44+fesep+feAU48+fesep+feAU22;
   pevmt          =fevmt+fesep;
   pevmp          =fevmp+fesep;
   peabr          =feabr+fesep;
   peaccp         =feaccp+fesep;
   peAlarms       =feAlarms+fesep;//08mar2022
   peReminders    =feReminders+fesep;//09mar2022
   peM3U          =feM3U+fesep;//20mar2022
   peFootnote     =feFootnote+fesep;//21mar2022
   peCursorScript =feCursorScript+fesep;//17may2022
   peQuoter       =feQuoter+fesep;//24dec2022
   peQuoter2      =feQuoter2+fesep;
   pemjpeg        =femjpeg+fesep;
   peallfiles     =feallfiles+fesep;
   pealldocs      =fealldocs+fesep;
   peallimgs      =feallimgs+fesep;
   pelosslessimgs =felosslessimgs+fesep;
   peallcurs      =feallcurs+fesep;
   peallcurs2     =feallcurs2+fesep;
   pealljpgs      ={$ifdef jpeg}fealljpgs+fesep+{$endif}'';
   pebrowserimgs  =febrowserimgs+fesep;
   pebrowserallimgs=febrowserimgs+fesep+
                   fepng+fesep+
                   fegif+fesep+
                   {$ifdef jpeg}fejpg+fesep+fejif+fesep+fejpeg+fesep+{$endif}
                   feico+fesep+
                   febmp+fesep+//18mar2025
                   '';
   pebcs          =febcs+fesep;
   pezip          =fezip+fesep;
   peexe          =feexe+fesep;
   pepas          =fepas+fesep;
   pedpr          =fedpr+fesep;
   pec3           =fec3+fesep;
   peref3         =feref3+fesep;
   penupkg        =fenupkg+fesep;
   pemap          =femap+fesep;
   //.midi formats
   pemid          =femid+fesep;
   pemidi         =femidi+fesep;
   permi          =fermi+fesep;


   //System Stats Counters -----------------------------------------------------
   track_limit           =200;

   track_Overview_start   =1;
   track_Overview_finish  =22+track_Overview_start;

   track_Core_start       =track_Overview_finish+3;//allow for blank line and title
   track_Core_finish      =56+track_Core_start;

   track_GUI_start        =track_Core_finish+3;//allow for blank line and title
   track_GUI_finish       =31+track_GUI_start;

   track_endof_overview  =track_Overview_finish;
   track_endof_core      =track_Core_finish;
   track_endof_gui       =track_GUI_finish;

   //.overview -> use "track__inc()" proc
   satUpTime           =0+track_Overview_start;
   satDPIawareV2       =1+track_Overview_start;
   satGUIresources     =2+track_Overview_start;
   satDLLload          =3+track_Overview_start;
   satAPIload          =4+track_Overview_start;
   satAPIcalls         =5+track_Overview_start;
   satMemory           =6+track_Overview_start;
   satMemoryCount      =7+track_Overview_start;
   satMemoryCreateCount=8+track_Overview_start;
   satMemoryFreeCount  =9+track_Overview_start;

   satErrors           =10+track_Overview_start;
   satMaskcapture      =11+track_Overview_start;
   satPartpaint        =12+track_Overview_start;
   satFullpaint        =13+track_Overview_start;
   satPartalign        =14+track_Overview_start;
   satFullalign        =15+track_Overview_start;
   satDragcount        =16+track_Overview_start;
   satDragcapture      =17+track_Overview_start;
   satDragpaint        =18+track_Overview_start;
   satSizecount        =19+track_Overview_start;
   satSysFont          =20+track_Overview_start;
   satTotalCore        =21+track_Overview_start;//sources value from "satCoreTotal"
   satTotalGUI         =22+track_Overview_start;//sources value from "satGUITotal"

   //.core
   satCoreTotal        =0+track_Core_start;
   satObjectex         =1+track_Core_start;
   satSmall8           =2+track_Core_start;
   satStr8             =3+track_Core_start;
   satMask8            =4+track_Core_start;
   satBmp              =5+track_Core_start;
   satWinbmp           =6+track_Core_start;
   satBasicimage       =7+track_Core_start;
   satBWP              =8+track_Core_start;
   satDynlist          =9+track_Core_start;
   satDynbyte          =10+track_Core_start;
   satDynint           =11+track_Core_start;
   satDynstr           =12+track_Core_start;
   satFrame            =13+track_Core_start;//31jan2021
   satMidi             =14+track_Core_start;//07feb2021
   satMidiopen         =15+track_Core_start;//07feb2021
   satMidiblocks       =16+track_Core_start;
   satThread           =17+track_Core_start;
   satTimer            =18+track_Core_start;//19feb2021
   satVars8            =19+track_Core_start;//01may2021
   satJpegimage        =20+track_Core_start;//01may2021
   satFile             =21+track_Core_start;//was tfilestream - 24dec2023
   satPstring          =22+track_Core_start;
   satWave             =23+track_Core_start;
   satWaveopen         =24+track_Core_start;
   satDyndate          =25+track_Core_start;
   satDynstr8          =26+track_Core_start;//28dec2023
   satDyncur           =27+track_Core_start;
   satDyncomp          =28+track_Core_start;
   satDynptr           =29+track_Core_start;//04feb2024
   satStr9             =30+track_Core_start;//04feb2024
   satDynstr9          =31+track_Core_start;//07feb2024
   satBlock            =32+track_Core_start;//17feb2024
   satDynname          =33+track_Core_start;//31mar2024
   satDynnamelist      =34+track_Core_start;//31mar2024
   satDynvars          =35+track_Core_start;//09apr2024
   satNV               =36+track_Core_start;//09apr2024
   satAudio            =37+track_Core_start;//22jun2024
   satMM               =38+track_Core_start;//22jun2024
   satChimes           =39+track_Core_start;//22jun2024
   satSnd32            =40+track_Core_start;//22jun2024
   satFastvars         =41+track_Core_start;//28jun2024
   satNetmore          =42+track_Core_start;//28jun2024
   satRawimage         =43+track_Core_start;//25jul2024
   satRegion           =44+track_Core_start;//01aug2024
   satGifsupport       =45+track_Core_start;//04aug2024
   satDynword          =46+track_Core_start;//10aug2024
   satSpell            =47+track_Core_start;
   satPlaylist         =48+track_Core_start;
   satHashtable        =49+track_Core_start;
   satNetbasic         =50+track_Core_start;
   satWproc            =51+track_Core_start;
   satIntlist          =52+track_Core_start;
   satCmplist          =53+track_Core_start;
   satTBT              =54+track_Core_start;
   satBasicapp         =55+track_Core_start;
   satImageexts        =56+track_Core_start;

   //.gui
   satGuiTotal         =0+track_GUI_start;
   satSystem           =1+track_GUI_start;
   satControl          =2+track_GUI_start;
   satTitle            =3+track_GUI_start;
   satEdit             =4+track_GUI_start;
   satToolbar          =5+track_GUI_start;
   satScroll           =6+track_GUI_start;
   satNav              =7+track_GUI_start;
   satSplash           =8+track_GUI_start;
   satHelp             =9+track_GUI_start;
   satColmatrix        =10+track_GUI_start;
   satColor            =11+track_GUI_start;
   satInfo             =12+track_GUI_start;
   satMenu             =13+track_GUI_start;
   satCols             =14+track_GUI_start;
   satSetcolor         =15+track_GUI_start;
   satScrollbar        =16+track_GUI_start;
   satImgview          =17+track_GUI_start;//17dec2024
   satBwpbar           =18+track_GUI_start;
   satCells            =19+track_GUI_start;
   satJump             =20+track_GUI_start;
   satGrad             =21+track_GUI_start;
   satStatus           =22+track_GUI_start;
   satBreak            =23+track_GUI_start;
   satInt              =24+track_GUI_start;
   satSet              =25+track_GUI_start;
   satSel              =26+track_GUI_start;
   satTEA              =27+track_GUI_start;
   satColors           =28+track_GUI_start;
   satMainhelp         =29+track_GUI_start;
   satTick             =30+track_GUI_start;
   satOther            =31+track_GUI_start;//16nov2023


   //-- Easy access chars and symbols for use with BYTE arrays -----------------
   //Access ASCII values under Delphi 10+ which no longer supports 8 bit characters
   //numbers 0-9
   nn0 = 48;
   nn1 = 49;
   nn2 = 50;
   nn3 = 51;
   nn4 = 52;
   nn5 = 53;
   nn6 = 54;
   nn7 = 55;
   nn8 = 56;
   nn9 = 57;
   //uppercase letters A-Z
   uuA = 65;
   uuB = 66;
   uuC = 67;
   uuD = 68;
   uuE = 69;
   uuF = 70;
   uuG = 71;
   uuH = 72;
   uuI = 73;
   uuJ = 74;
   uuK = 75;
   uuL = 76;
   uuM = 77;
   uuN = 78;
   uuO = 79;
   uuP = 80;
   uuQ = 81;
   uuR = 82;
   uuS = 83;
   uuT = 84;
   uuU = 85;
   uuV = 86;
   uuW = 87;
   uuX = 88;
   uuY = 89;
   uuZ = 90;
   //lowercase letters a-z
   lla = 97;
   llb = 98;
   llc = 99;
   lld = 100;
   lle = 101;
   llf = 102;
   llg = 103;
   llh = 104;
   lli = 105;
   llj = 106;
   llk = 107;
   lll = 108;
   llm = 109;
   lln = 110;
   llo = 111;
   llp = 112;
   llq = 113;
   llr = 114;
   lls = 115;
   llt = 116;
   llu = 117;
   llv = 118;
   llw = 119;
   llx = 120;
   lly = 121;
   llz = 122;

   //special values
   vvUppertolower = llA-uuA;//difference to shift an uppercase char to a lowercase one

   //common symbols
   ssdollar = 36;//"$" - 10jan2023
   sspipe = 124;//"|"
   sshash = 35;
   sspert = 37;//"%" - 01apr2024
   ssasterisk = 42;
   ssdash =45;
   ssslash = 47;
   ssbackslash = 92;
   sscolon = 58;
   sssemicolon = 59;
   ssplus = 43;
   sscomma = 44;
   ssminus = 45;//06jul2022
   ssat = 64;
   ssdot = 46;
   ssexclaim = 33;
   ssmorethan = 62;
   sslessthan = 60;
   ssequal    = 61;
   ssquestion = 63;
   ssunderscore =  95;
   ssspace = 32;
   ssspace2 = 160;//05feb2023
   ss10 = 10;
   ss13 = 13;
   ss9 = 9;
   ssTab = 9;
   sspower=94;//"^"
   ssdoublequote=34;
   sspercentage=37;//"%"
   ssampersand=38;//"&"
   sssinglequote=39;
   sssinglequotefancy=96;
   ssLSquarebracket=91;//"["
   ssRSquarebracket=93;//"]"
   ssLRoundbracket=40;//"("
   ssRRoundbracket=41;//")"
   ssLCurlyBracket=123;//"{"
   ssRCurlyBracket=125;//"}"
   ssSquiggle=126;//"~"
   ssCopyright=169;
   ssRegistered=174;

   //days between 1/1/0001 and 12/31/1899
   date__datedelta    =693594;
   date__secsperday   =24 * 60 * 60;
   date__msperday     =date__secsperday * 1000;
   date__FMSecsPerDay:single  = date__msperday;
   date__IMSecsPerDay:longint = date__msperday;
   date__monthdays:array [boolean] of tdaytable =((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));

type

   tslowms64=record
     ms    :comp;
     scan  :longint;
     end;

   pobject           =^tobject;
   tpointer          =^pointer;

   tnotifyevent      =procedure(sender:tobject) of object;
   tevent            =tnotifyevent;//procedure(sender:tobject) of object;
   tstr8             =class;
   tdynamicbyte      =class;
   tdynamicword      =class;
   tdynamicinteger   =class;
   tdynamiccurrency  =class;
   tdynamiccomp      =class;
   tdynamicstring    =class;
   twinmsg           =function(m,w,l:longint):longint of object;//07jul2025
   twinproc          =function(h,m,w,l:longint):longint of object;//03oct2025
   tinfofunc         =function(xmame:string):string;
   tproc             =procedure;

{$ifdef gui4}
   tdragstartevent   =procedure(sender:tobject;shift:classes.tshiftstate;x,y:integer;var allow:boolean) of object;
{$else}
   tdragstartevent   =procedure(sender:tobject;shift:tshiftstate;x,y:integer;var allow:boolean) of object;
{$endif}


   ttimestamp=record
    time:longint;//number of milliseconds since midnight
    date:longint;//one plus number of days since 1/1/0001
    end;

   //crc__* proc support - 21aug2025
   pseedcrc32=^tseedcrc32;
   tseedcrc32=record
      ref     :array[0..255] of longint;
      val     :longint;
      xresult :longint;
      end;

   //.color
   pcolor8       =^tcolor8;      tcolor8 =byte;
   pcolor16      =^tcolor16;     tcolor16=word;
   pcolor24      =^tcolor24;     tcolor24=packed record b:byte;g:byte;r:byte;end;//shoulde be packed for safety - 27SEP2011
   pcolor32      =^tcolor32;     tcolor32=packed record b:byte;g:byte;r:byte;a:byte;end;
   pcolor40      =^tcolor40;     tcolor40=packed record b:byte;g:byte;r:byte;a:byte;c:byte;end;//18nov2024
   pcolor96      =^tcolor96;     tcolor96=packed record v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11:byte;end;//12b => 6px for 15/16bit image - 19apr2020
   //.row
   pcolorrow8    =^tcolorrow8;   tcolorrow8 =array[0..maxpixel] of tcolor8;
   pcolorrow16   =^tcolorrow16;  tcolorrow16=array[0..maxpixel] of tcolor16;
   pcolorrow24   =^tcolorrow24;  tcolorrow24=array[0..maxpixel] of tcolor24;
   pcolorrow32   =^tcolorrow32;  tcolorrow32=array[0..maxpixel] of tcolor32;
   pcolorrow96   =^tcolorrow96;  tcolorrow96=array[0..maxpixel] of tcolor96;
   //.rows
   pcolorrows8   =^tcolorrows8 ; tcolorrows8 =array[0..maxrow] of pcolorrow8;
   pcolorrows16  =^tcolorrows16; tcolorrows16=array[0..maxrow] of pcolorrow16;
   pcolorrows24  =^tcolorrows24; tcolorrows24=array[0..maxrow] of pcolorrow24;
   pcolorrows32  =^tcolorrows32; tcolorrows32=array[0..maxrow] of pcolorrow32;
   pcolorrows96  =^tcolorrows96; tcolorrows96=array[0..maxrow] of pcolorrow96;

   tlistrows24   =array[word] of pcolorrow24;

   //.reference arrays
   pbitboolean   =^tbitboolean;  tbitboolean=set of 0..7;
   pdlbitboolean =^tdlbitboolean;tdlbitboolean=array[0..((max32 div sizeof(tbitboolean))-1)] of tbitboolean;
   pdlbyte       =^tdlbyte;      tdlbyte=array[0..((max32 div sizeof(byte))-1)] of byte;
   pdlchar       =^tdlchar;      tdlchar=array[0..((max32 div sizeof(char))-1)] of char;
   pdlsmallint   =^tdlsmallint;  tdlsmallint=array[0..((max32 div sizeof(smallint))-1)] of smallint;
   pdlword       =^tdlword;      tdlword=array[0..((max32 div sizeof(word))-1)] of word;
   pbilongint    =^tbilongint;   tbilongint=array[0..1] of longint;
   pdlbilongint  =^tdlbilongint; tdlbilongint=array[0..((max32 div sizeof(tbilongint))-1)] of tbilongint;
   pdllongint    =^tdllongint;   tdllongint=array[0..((max32 div sizeof(longint))-1)] of longint;
   pdlpoint      =^tdlpoint;     tdlpoint=array[0..((max32 div sizeof(tpoint))-1)] of tpoint;
   pdlcurrency   =^tdlcurrency;  tdlcurrency=array[0..((max32 div sizeof(currency))-1)] of currency;
   pdlcomp       =^tdlcomp;      tdlcomp=array[0..((max32 div sizeof(comp))-1)] of comp;
   pdldouble     =^tdldouble;    tdldouble=array[0..((max32 div sizeof(double))-1)] of double;
   pdldatetime   =^tdldatetime;  tdldatetime=array[0..((max32 div sizeof(tdatetime))-1)] of tdatetime;
   pdlrect       =^tdlrect;      tdlrect=array[0..((max32 div sizeof(twinrect))-1)] of twinrect;
   pdlstring     =^tdlstring;    tdlstring=array[0..((max32 div 32)-1)] of pstring;
   pdlpointer    =^tdlpointer;   tdlpointer=array[0..((max32 div sizeof(pointer))-1)] of pointer;
   pdlobject     =^tdlobject;    tdlobject=array[0..((max32 div sizeof(pobject))-1)] of tobject;
   pdlstr8       =^tdlstr8;      tdlstr8=array[0..((max32 div sizeof(pointer))-1)] of tstr8;


   //.conversion records
   longrec = packed record
    lo, wi:word;
    end;


   pbit8=^tbit8;
   tbit8=packed record//01may2020 - char discontinued due to Unicode in D10
    case longint of
    0:(bits:tbitboolean);
    1:(val:byte);
    2:(s:shortint);
    end;

   pbyt1=^tbyt1;
   tbyt1=packed record
    case longint of
    0:(val:byte);
    1:(b:byte);
    2:(s:shortint);
    3:(bits:set of 0..7);
    4:(bol:boolean);
    end;

   pwrd2=^twrd2;
   twrd2=packed record
    case longint of
    0:(val:word);
    1:(si:smallint);
    3:(bytes:array [0..1] of byte);
    4:(bits:set of 0..15);
    5:(lo,hi:byte);//01may2025
    end;

   pint4=^tint4;
   tint4=packed record
    case longint of
    0:(r,g,b,a:byte);
    1:(val:longint);
    2:(bytes:array [0..3] of byte);
    3:(wrds:array [0..1] of word);
    4:(bols:array [0..3] of bytebool);
    5:(sint:array[0..1] of smallint);
    6:(short:array[0..3] of shortint);
    7:(bits:set of 0..31);
    8:(b0,b1,b2,b3:byte);//26dec2024
    9:(bgra32:tcolor32);//03feb2025 - clearly marked as different, tint4.r/g/b/a stores in RGBA order which is different to tcolor32 which stores in BGRA order
    10:(bgr24:tcolor24;ca:byte);//03feb2025 - clearly marked as different, tint4.r/g/b stores in RGB order which is different to tcolor24 which stores in BGR order
    11:(lo,hi:word);//01may2025
    end;

   pcmp8=^tcmp8;
   tcmp8=packed record
    case longint of
    0:(val:comp);
    1:(cur:currency);
    2:(dbl:double);
    3:(bytes:array[0..7] of byte);
    4:(wrds:array[0..3] of word);
    5:(ints:array[0..1] of longint);
    6:(bits:set of 0..63);
    7:(datetime:tdatetime);
    end;

   pcur8=^tcur8;
   tcur8=packed record
    case longint of
    0:(val:currency);
    1:(cmp:comp);
    2:(dbl:double);
    3:(bytes:array[0..7] of byte);
    4:(wrds:array[0..3] of word);
    5:(ints:array[0..1] of longint);
    6:(bits:set of 0..63);
    7:(datetime:tdatetime);
    end;

   pext10=^text10;
   text10=packed record
    case longint of
    0:(val:extended);
    1:(bytes:array[0..9] of byte);
    2:(wrds:array[0..4] of word);
    3:(bits:set of 0..79);
    end;

   plistptr=^tlistptr;
   tlistptr=record
     count:longint;
     bytes:pdlbyte;
     end;


{tobjectex}
   tobjectex=class(tobject)
   private

   public
    //"__cacheptr" is reserved for use by "cache__ptr()" proc -> 10feb2024
    __cacheptr:tobject;
    constructor create; virtual;
    destructor destroy; override;
   end;

{twproc}
   twproc=class(tobject)
   private
    iwindow:hwnd;
   public
    //create
    constructor create;
    destructor destroy; override;
    //information
    property window:hwnd read iwindow;
   end;


{tintlist}
   tintlist=class(tobjectex)//limit of 4,194,304 items when system_blocksize=8192 - 17feb2024
   private
    iroot:pdlpointer;
    igetmin,igetmax,isetmin,isetmax,iblocksize,irootcount,icount,irootlimit,iblocklimit,ilimit:longint;
    igetmem,isetmem:pointer;
    procedure setcount(x:longint);
    function getvalue(x:longint):longint;
    procedure setvalue(x:longint;xval:longint);
    function getptr(x:longint):pointer;
    procedure setptr(x:longint;xval:pointer);
   public
    constructor create; virtual;
    destructor destroy; override;
    //information
    function mem:longint;//memory size in bytes used
    function mem_predict(xcount:comp):comp;//info proc used to predict value of mem
    property limit:longint read ilimit;
    property count:longint read icount write setcount;
    property rootcount:longint read irootcount;
    property rootlimit:longint read irootlimit;//tier 1 limit (iroot)
    property blocklimit:longint read iblocklimit;//tier 2 limit (child of iroot)
    function fastinfo(xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;//15feb2024
    //workers
    procedure clear;
    function mincount(xcount:longint):boolean;//fixed 20feb2024
    property value[x:longint]:longint read getvalue write setvalue;
    property int[x:longint]:longint read getvalue write setvalue;
    property ptr[x:longint]:pointer read getptr write setptr;
   end;

{tcmplist}
   tcmplist=class(tobjectex)//limit of ?????????????? items when system_blocksize=8192 - 17feb2024
   private
    iroot:pdlpointer;
    igetmin,igetmax,isetmin,isetmax,iblocksize,irootcount,icount,irootlimit,iblocklimit,ilimit:longint;
    igetmem,isetmem:pointer;
    procedure setcount(x:longint);
    function getvalue(x:longint):comp;
    procedure setvalue(x:longint;xval:comp);
    function getdbl(x:longint):double;
    procedure setdbl(x:longint;xval:double);
    function getdate(x:longint):tdatetime;
    procedure setdate(x:longint;xval:tdatetime);
   public
    constructor create; virtual;
    destructor destroy; override;
    //information
    function mem:longint;//memory size in bytes used
    property limit:longint read ilimit;
    property count:longint read icount write setcount;
    property rootcount:longint read irootcount;
    property rootlimit:longint read irootlimit;//tier 1 limit (iroot)
    property blocklimit:longint read iblocklimit;//tier 2 limit (child of iroot)
    function fastinfo(xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;//15feb2024
    //workers
    procedure clear;
    function mincount(xcount:longint):boolean;//fixed 20feb2024
    property value[x:longint]:comp read getvalue write setvalue;
    property cmp[x:longint]:comp read getvalue write setvalue;
    property dbl[x:longint]:double read getdbl write setdbl;
    property date[x:longint]:tdatetime read getdate write setdate;
   end;

{tstr8 - 8bit binary string -> replacement for Delphi 10's lack of 8bit native string - 29apr2020}
   tstr8=class(tobjectex)
   private
    iownmemory,iglobal:boolean;//default=false=local memory in use, true=global memory in use
    idata:pointer;
    ifloatsize,ilockcount,idatalen,icount:longint;//datalen=size of allocated memory | count=size of memory in use by user
    ichars :pdlchar;
    ibytes :pdlbyte;
    iints4 :pdllongint;
    irows8 :pcolorrows8;
    irows15:pcolorrows16;
    irows16:pcolorrows16;
    irows24:pcolorrows24;
    irows32:pcolorrows32;


    procedure setfloatsize(x:longint);//29aug2025
    function getbytes(x:longint):byte;
    procedure setbytes(x:longint;xval:byte);
    function getbytes1(x:longint):byte;//1-based
    procedure setbytes1(x:longint;xval:byte);
    function getchars(x:longint):char;
    procedure setchars(x:longint;xval:char);

    //get + set support --------------------------------------------------------
    function getc8(xpos:longint):tcolor8;
    function getc24(xpos:longint):tcolor24;
    function getc32(xpos:longint):tcolor32;
    function getc40(xpos:longint):tcolor40;
    function getcmp8(xpos:longint):comp;
    function getcur8(xpos:longint):currency;
    function getint4(xpos:longint):longint;
    function getint4i(xindex:longint):longint;
    function getint4R(xpos:longint):longint;
    function getint3(xpos:longint):longint;
    function getsml2(xpos:longint):smallint;//28jul2021
    function getwrd2(xpos:longint):word;
    function getwrd2R(xpos:longint):word;
    function getbyt1(xpos:longint):byte;
    function getbol1(xpos:longint):boolean;
    function getchr1(xpos:longint):char;
    function getstr(xpos,xlen:longint):string;//0-based - fixed - 16aug2020
    function getstr1(xpos,xlen:longint):string;//1-based
    function getnullstr(xpos,xlen:longint):string;//20mar2022
    function getnullstr1(xpos,xlen:longint):string;//20mar2022
    function gettext:string;
    procedure settext(const x:string);
    function gettextarray:string;
    procedure setc8(xpos:longint;xval:tcolor8);
    procedure setc24(xpos:longint;xval:tcolor24);
    procedure setc32(xpos:longint;xval:tcolor32);
    procedure setc40(xpos:longint;xval:tcolor40);
    procedure setcmp8(xpos:longint;xval:comp);
    procedure setcur8(xpos:longint;xval:currency);
    procedure setint4(xpos:longint;xval:longint);
    procedure setint4i(xindex:longint;xval:longint);
    procedure setint4R(xpos:longint;xval:longint);
    procedure setint3(xpos:longint;xval:longint);
    procedure setsml2(xpos:longint;xval:smallint);
    procedure setwrd2(xpos:longint;xval:word);
    procedure setwrd2R(xpos:longint;xval:word);
    procedure setbyt1(xpos:longint;xval:byte);
    procedure setbol1(xpos:longint;xval:boolean);
    procedure setchr1(xpos:longint;xval:char);
    procedure setstr(xpos:longint;xlen:longint;xval:string);//0-based
    procedure setstr1(xpos:longint;xlen:longint;xval:string);//1-based

    //replace support ----------------------------------------------------------
    procedure setreplace(x:tstr8);
    procedure setreplacecmp8(x:comp);
    procedure setreplacecur8(x:currency);
    procedure setreplaceint4(x:longint);
    procedure setreplacewrd2(x:word);
    procedure setreplacebyt1(x:byte);
    procedure setreplacebol1(x:boolean);
    procedure setreplacechr1(x:char);
    procedure setreplacestr(x:string);

    //.ease of use support
    procedure setbdata(x:tstr8);
    function getbdata:tstr8;
    procedure setbappend(x:tstr8);

    //.general support
    procedure xsyncvars;
    function gethandle:hglobal;//19may2025: fixed reference to "nil"
   public
    //ease of use support options
    oautofree:boolean;//default=false
    otestlock1:boolean;//debug only - 09may2021

    //misc
    tag1:longint;
    tag2:longint;
    tag3:longint;
    tag4:longint;
    seekpos:longint;

    //create
    constructor create(xlen:longint); virtual;
    destructor destroy; override;
    function xresize(x:longint;xsetcount:boolean):boolean;//29aug2025
    function copyfrom(s:tstr8):boolean;//09feb2022

    //lock - disables "oautofree" whilst many layers are working on same object - 19aug2020
    procedure lock;
    procedure unlock;
    property lockcount:longint read ilockcount;

    //information
    property core:pointer read idata;//read-only
    property handle:hglobal read gethandle;//for global memory only
    property ownmemory:boolean read iownmemory;
    property global:boolean read iglobal;
    property datalen:longint read idatalen;//actual internal size of data buffer - 25sep2020
    property len:longint read icount;
    property count:longint read icount;
    property floatsize:longint read ifloatsize write setfloatsize;
    property chars[x:longint]:char read getchars write setchars;
    property bytes[x:longint]:byte read getbytes write setbytes;//0-based
    property bytes1[x:longint]:byte read getbytes1 write setbytes1;//1-based
    function scanline(xfrom:longint):pointer;

    //.rapid access -> no range checking
    property pbytes:pdlbyte       read ibytes;
    property pints4 :pdllongint   read iints4;
    property prows8 :pcolorrows8  read irows8;
    property prows16:pcolorrows16 read irows16;
    property prows24:pcolorrows24 read irows24;
    property prows32:pcolorrows32 read irows32;
    function maplist:tlistptr;//26apr2021, 07apr2021

    //workers
    function clear:boolean;
    function setlen(x:longint):boolean;
    function minlen(x:longint):boolean;//atleast this length - 21mar2025: fixed
    procedure setcount(x:longint);//07dec2023
    function fill(xfrom,xto:longint;xval:byte):boolean;
    function del(xfrom,xto:longint):boolean;
    function del3(xfrom,xlen:longint):boolean;//27jan2021

    //.local/global memory support - 15may2025
    function makelocal:boolean;
    function makeglobal:boolean;
    function makeglobalFROM(xmem:hglobal;xownmemory:boolean):boolean;
    function ejectcore:boolean;

    //.object support
    function add(var x:tstr8):boolean;
    function addb(x:tstr8):boolean;
    function add2(var x:tstr8;xfrom,xto:longint):boolean;
    function add3(var x:tstr8;xfrom,xlen:longint):boolean;
    function add31(var x:tstr8;xfrom1,xlen:longint):boolean;//28jul2021
    function ins(var x:tstr8;xpos:longint):boolean;
    function ins2(var x:tstr8;xpos,xfrom,xto:longint):boolean;//26apr2021
    function _ins2(x:pobject;xpos,xfrom,xto:longint):boolean;//08feb2024: tstr9 support, 22apr2022, 27apr2021, 26apr2021
    function owr(var x:tstr8;xpos:longint):boolean;//overwrite -> enlarge if required - 01oct2020
    function owr2(var x:tstr8;xpos,xfrom,xto:longint):boolean;

    //.swappers
    function swap(s:tstr8):boolean;//27dec2021

    //.array support
    function aadd(const x:array of byte):boolean;
    function aadd1(const x:array of byte;xpos1,xlen:longint):boolean;//1based - 19aug2020
    function aadd2(const x:array of byte;xfrom,xto:longint):boolean;
    function ains(const x:array of byte;xpos:longint):boolean;
    function ains2(const x:array of byte;xpos,xfrom,xto:longint):boolean;
    function padd(x:pdlbyte;xsize:longint):boolean;//15feb2024
    function pins2(x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;//07feb2022

    //.add number support -> always append to end of data
    function addcmp8(xval:comp):boolean;
    function addcur8(xval:currency):boolean;
    function addRGBA4(r,g,b,a:byte):boolean;
    function addRGB3(r,g,b:byte):boolean;
    function addint4(xval:longint):boolean;
    function addint4R(xval:longint):boolean;
    function addint3(xval:longint):boolean;
    function addwrd2(xval:word):boolean;
    function addwrd2R(xval:word):boolean;
    function addsmi2(xval:smallint):boolean;//01aug2021
    function addbyt1(xval:byte):boolean;
    function addbol1(xval:boolean):boolean;
    function addchr1(xval:char):boolean;
    function addstr(xval:string):boolean;
    function addrec(a:pointer;asize:longint):boolean;//07feb2022

    //.insert number support -> insert at specified position (0-based)
    function insbyt1(xval:byte;xpos:longint):boolean;
    function insbol1(xval:boolean;xpos:longint):boolean;
    function insint4(xval,xpos:longint):boolean;

    //.string support
    function sadd(const x:string):boolean;//26dec2023, 27apr2021
    function sadd2(const x:string;xfrom,xto:longint):boolean;//26dec2023, 27apr2021
    function sadd3(const x:string;xfrom,xlen:longint):boolean;//26dec2023, 27apr2021
    function sins(const x:string;xpos:longint):boolean;//27apr2021
    function sins2(const x:string;xpos,xfrom,xto:longint):boolean;

    //.push support -> insert data at position "pos" and inc pos to new position
    function pushcmp8(var xpos:longint;xval:comp):boolean;
    function pushcur8(var xpos:longint;xval:currency):boolean;
    function pushint4(var xpos:longint;xval:longint):boolean;
    function pushint4R(var xpos:longint;xval:longint):boolean;
    function pushint3(var xpos:longint;xval:longint):boolean;//range: 0..16777215
    function pushwrd2(var xpos:longint;xval:word):boolean;
    function pushwrd2R(var xpos:longint;xval:word):boolean;
    function pushbyt1(var xpos:longint;xval:byte):boolean;
    function pushbol1(var xpos:longint;xval:boolean):boolean;
    function pushchr1(var xpos:longint;xval:char):boolean;//WARNING: Unicode conversion possible -> use only 0-127 chars????
    function pushstr(var xpos:longint;xval:string):boolean;

    //.get/set support
    property c8[xpos:longint] :tcolor8  read getc8  write setc8;
    property c24[xpos:longint]:tcolor24 read getc24 write setc24;
    property c32[xpos:longint]:tcolor32 read getc32 write setc32;
    property c40[xpos:longint]:tcolor40 read getc40 write setc40;
    property cmp8[xpos:longint]:comp read getcmp8 write setcmp8;
    property cur8[xpos:longint]:currency read getcur8 write setcur8;
    property int4[xpos:longint]:longint read getint4 write setint4;
    property int4i[xindex:longint]:longint read getint4i write setint4i;
    property int4R[xpos:longint]:longint read getint4R write setint4R;
    property int3[xpos:longint]:longint read getint3 write setint3;//range: 0..16777215
    property sml2[xpos:longint]:smallint read getsml2 write setsml2;//28jul2021
    property wrd2[xpos:longint]:word read getwrd2 write setwrd2;
    property wrd2R[xpos:longint]:word read getwrd2R write setwrd2R;
    property byt1[xpos:longint]:byte read getbyt1 write setbyt1;
    property bol1[xpos:longint]:boolean read getbol1 write setbol1;
    property chr1[xpos:longint]:char read getchr1 write setchr1;
    property str[xpos:longint;xlen:longint]:string read getstr write setstr;//0-based
    property str1[xpos:longint;xlen:longint]:string read getstr1 write setstr1;//1-based
    property nullstr[xpos:longint;xlen:longint]:string read getnullstr;//0-based
    property nullstr1[xpos:longint;xlen:longint]:string read getnullstr1;//1-based
    function setarray(xpos:longint;const xval:array of byte):boolean;
    property text :string read gettext write settext;//use carefully -> D10 uses unicode
    property textarray:string read gettextarray;

    //.replace support
    property replace:tstr8 write setreplace;
    property replacecmp8:comp write setreplacecmp8;
    property replacecur8:currency write setreplacecur8;
    property replaceint4:longint write setreplaceint4;
    property replacewrd2:word write setreplacewrd2;
    property replacebyt1:byte write setreplacebyt1;
    property replacebol1:boolean write setreplacebol1;
    property replacechr1:char write setreplacechr1;
    property replacestr:string write setreplacestr;

    //.writeto structures - 28jul2021
    function writeto1(a:pointer;asize,xfrom1,xlen:longint):boolean;
    function writeto1b(a:pointer;asize:longint;var xfrom1:longint;xlen:longint):boolean;
    function writeto(a:pointer;asize,xfrom0,xlen:longint):boolean;//28jul2021

    //.logic support
    function empty:boolean;
    function notempty:boolean;
    function same(var x:tstr8):boolean;
    function same2(xfrom:longint;var x:tstr8):boolean;
    function asame(const x:array of byte):boolean;
    function asame2(xfrom:longint;const x:array of byte):boolean;
    function asame3(xfrom:longint;const x:array of byte;xcasesensitive:boolean):boolean;
    function asame4(xfrom,xmin,xmax:longint;const x:array of byte;xcasesensitive:boolean):boolean;

    //.converters
    function uppercase:boolean;
    function uppercase1(xpos1,xlen:longint):boolean;
    function lowercase:boolean;
    function lowercase1(xpos1,xlen:longint):boolean;

    //.data block support
    function datpush(n:longint;x:tstr8):boolean;//27jun2022
    function datpull(var xpos,n:longint;x:tstr8):boolean;//27jun2022

    //.ease of use point of access
    property bdata:tstr8 read getbdata write setbdata;
    property bappend:tstr8 write setbappend;

    //.other
    function splice(xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;//25feb2024
   end;

{tstr9 - 8bit binary str spread over multiple memory blocks to ensure maximum memory reuse/reliability}
   tstr9=class(tobjectex)
   private
    ilist:tintlist;
    ilockcount,iblockcount,iblocksize,idatalen,ilen,ilen2,imem:longint;
    igetmin,igetmax,isetmin,isetmax:longint;
    igetmem,isetmem:pdlbyte;
    function getv(xpos:longint):byte;
    procedure setv(xpos:longint;v:byte);
    function getv1(xpos:longint):byte;
    procedure setv1(xpos:longint;v:byte);
    function getchar(xpos:longint):char;
    procedure setchar(xpos:longint;v:char);
    //get + set support --------------------------------------------------------
    function getc8(xpos:longint):tcolor8;
    function getc24(xpos:longint):tcolor24;
    function getc32(xpos:longint):tcolor32;
    function getc40(xpos:longint):tcolor40;
    function getcmp8(xpos:longint):comp;
    function getcur8(xpos:longint):currency;
    function getint4(xpos:longint):longint;
    function getint4i(xindex:longint):longint;
    function getint4R(xpos:longint):longint;
    function getint3(xpos:longint):longint;
    function getsml2(xpos:longint):smallint;//28jul2021
    function getwrd2(xpos:longint):word;
    function getwrd2R(xpos:longint):word;
    function getbyt1(xpos:longint):byte;
    function getbol1(xpos:longint):boolean;
    function getchr1(xpos:longint):char;
    function getstr(xpos,xlen:longint):string;//0-based - fixed - 16aug2020
    function getstr1(xpos,xlen:longint):string;//1-based
    function getnullstr(xpos,xlen:longint):string;//20mar2022
    function getnullstr1(xpos,xlen:longint):string;//20mar2022
    function gettext:string;
    procedure settext(const x:string);
    function gettextarray:string;
    procedure setc8(xpos:longint;xval:tcolor8);
    procedure setc24(xpos:longint;xval:tcolor24);
    procedure setc32(xpos:longint;xval:tcolor32);
    procedure setc40(xpos:longint;xval:tcolor40);
    procedure setcmp8(xpos:longint;xval:comp);
    procedure setcur8(xpos:longint;xval:currency);
    procedure setint4(xpos:longint;xval:longint);
    procedure setint4i(xindex:longint;xval:longint);
    procedure setint4R(xpos:longint;xval:longint);
    procedure setint3(xpos:longint;xval:longint);
    procedure setsml2(xpos:longint;xval:smallint);
    procedure setwrd2(xpos:longint;xval:word);
    procedure setwrd2R(xpos:longint;xval:word);
    procedure setbyt1(xpos:longint;xval:byte);
    procedure setbol1(xpos:longint;xval:boolean);
    procedure setchr1(xpos:longint;xval:char);
    procedure setstr(xpos:longint;xlen:longint;xval:string);//0-based
    procedure setstr1(xpos:longint;xlen:longint;xval:string);//1-based
   public
    //ease of use support options
    oautofree:boolean;//default=false
    //misc
    tag1:longint;
    tag2:longint;
    tag3:longint;
    tag4:longint;
    seekpos:longint;
    //create
    constructor create(xlen:longint); virtual;
    destructor destroy; override;
    //lock - disables "oautofree" whilst many layers are working on same object - 04feb2020
    procedure lock;
    procedure unlock;
    property lockcount:longint read ilockcount;
    //information
    property len:longint read ilen;//length of data
    property datalen:longint read idatalen;
    property mem:longint read imem;//size of allocated memory
    function mem_predict(xlen:comp):comp;//info proc used to predict value of mem
    //workers
    function softclear:boolean;
    function softclear2(xmaxlen:longint):boolean;//07mar2024
    function clear:boolean;
    function setlen(x:longint):boolean;
    function minlen(x:longint):boolean;//atleast this length, 29feb2024: updated
    property chars[x:longint]:char read getchar write setchar;
    property pbytes[x:longint]:byte read getv write setv;//0-based
    property bytes[x:longint]:byte read getv write setv;//0-based
    property bytes1[x:longint]:byte read getv1 write setv1;//1-based
    function del3(xfrom,xlen:longint):boolean;//06feb2024
    function del(xfrom,xto:longint):boolean;//06feb2024
    //.fast support
    function splice(xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;
    function fastinfo(xpos:longint;var xmem:pdlbyte;var xmin,xmax:longint):boolean;//15feb2024
    function fastadd(var x:array of byte;xsize:longint):longint;
    function fastwrite(var x:array of byte;xsize,xpos:longint):longint;
    function fastread(var x:array of byte;xsize,xpos:longint):longint;
    //.object support
    function add(x:pobject):boolean;
    function addb(x:tobject):boolean;
    function add2(x:pobject;xfrom,xto:longint):boolean;
    function add3(x:pobject;xfrom,xlen:longint):boolean;
    function add31(x:pobject;xfrom1,xlen:longint):boolean;
    function ins(x:pobject;xpos:longint):boolean;
    function ins2(x:pobject;xpos,xfrom,xto:longint):boolean;//79% native speed of tstr8.ins2 which uses a single block of memory
    function owr(x:pobject;xpos:longint):boolean;//overwrite -> enlarge if required
    function owr2(x:pobject;xpos,xfrom,xto:longint):boolean;
    //.array support
    function aadd(const x:array of byte):boolean;
    function aadd1(const x:array of byte;xpos1,xlen:longint):boolean;//1based
    function aadd2(const x:array of byte;xfrom,xto:longint):boolean;
    function ains(const x:array of byte;xpos:longint):boolean;
    function ains2(const x:array of byte;xpos,xfrom,xto:longint):boolean;
    function padd(x:pdlbyte;xsize:longint):boolean;//15feb2024
    function pins2(x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;//07feb2022
    //.add number support -> always append to end of data
    function addcmp8(xval:comp):boolean;
    function addcur8(xval:currency):boolean;
    function addRGBA4(r,g,b,a:byte):boolean;
    function addRGB3(r,g,b:byte):boolean;
    function addint4(xval:longint):boolean;
    function addint4R(xval:longint):boolean;
    function addint3(xval:longint):boolean;
    function addwrd2(xval:word):boolean;
    function addwrd2R(xval:word):boolean;
    function addsmi2(xval:smallint):boolean;//01aug2021
    function addbyt1(xval:byte):boolean;
    function addbol1(xval:boolean):boolean;
    function addchr1(xval:char):boolean;
    function addstr(xval:string):boolean;
    function addrec(a:pointer;asize:longint):boolean;
    //.string support
    function sadd(const x:string):boolean;
    function sadd2(const x:string;xfrom,xto:longint):boolean;
    function sadd3(const x:string;xfrom,xlen:longint):boolean;
    function sins(const x:string;xpos:longint):boolean;
    function sins2(const x:string;xpos,xfrom,xto:longint):boolean;
    //.writeto structures - 26jul2024
    function writeto1(a:pointer;asize,xfrom1,xlen:longint):boolean;
    function writeto1b(a:pointer;asize:longint;var xfrom1:longint;xlen:longint):boolean;
    function writeto(a:pointer;asize,xfrom0,xlen:longint):boolean;//28jul2021
    //.logic support
    function empty:boolean;
    function notempty:boolean;
    function same(x:pobject):boolean;
    function same2(xfrom:longint;x:pobject):boolean;
    function asame(const x:array of byte):boolean;
    function asame2(xfrom:longint;const x:array of byte):boolean;
    function asame3(xfrom:longint;const x:array of byte;xcasesensitive:boolean):boolean;
    function asame4(xfrom,xmin,xmax:longint;const x:array of byte;xcasesensitive:boolean):boolean;
    //.get/set support
    property c8[xpos:longint] :tcolor8  read getc8  write setc8;
    property c24[xpos:longint]:tcolor24 read getc24 write setc24;
    property c32[xpos:longint]:tcolor32 read getc32 write setc32;
    property c40[xpos:longint]:tcolor40 read getc40 write setc40;
    property cmp8[xpos:longint]:comp read getcmp8 write setcmp8;
    property cur8[xpos:longint]:currency read getcur8 write setcur8;
    property int4[xpos:longint]:longint read getint4 write setint4;
    property int4i[xindex:longint]:longint read getint4i write setint4i;
    property int4R[xpos:longint]:longint read getint4R write setint4R;
    property int3[xpos:longint]:longint read getint3 write setint3;//range: 0..16777215
    property sml2[xpos:longint]:smallint read getsml2 write setsml2;
    property wrd2[xpos:longint]:word read getwrd2 write setwrd2;
    property wrd2R[xpos:longint]:word read getwrd2R write setwrd2R;
    property byt1[xpos:longint]:byte read getbyt1 write setbyt1;
    property bol1[xpos:longint]:boolean read getbol1 write setbol1;
    property chr1[xpos:longint]:char read getchr1 write setchr1;
    property str[xpos:longint;xlen:longint]:string read getstr write setstr;//0-based
    property str1[xpos:longint;xlen:longint]:string read getstr1 write setstr1;//1-based
    property nullstr[xpos:longint;xlen:longint]:string read getnullstr;//0-based
    property nullstr1[xpos:longint;xlen:longint]:string read getnullstr1;//1-based
    function setarray(xpos:longint;const xval:array of byte):boolean;
    property text:string read gettext write settext;
    property textarray:string read gettextarray;
    //support
    function xshiftup(spos,slen:longint):boolean;//29feb2024: fixed min range
   end;

{tmemstr}
{$ifdef laz}
   tmemstr=class(tstream)//tstringstream replacement -> does not reset/corrupt data on multiple writes/reads
   private
    iposition:longint;
    idata:tobject;//accepts tstr8 and tstr9 handlers
   protected
    procedure setsize(newsize:longint); override;
   public
    //create
    constructor create(_ptr:tobject); virtual;
    destructor destroy; override;
    //workers
    function read(var x;xlen:longint):longint; override;
    function write(const x;xlen:longint):longint; override;
    function seek(offset:longint;origin:word):longint; override;
    function readstring(count:longint):string;
    procedure writestring(const x:string);
   end;
{$endif}

{tvars8}
   tvars8=class(tobject)
   private
    icore:tstr8;
    function getb(xname:string):boolean;
    procedure setb(xname:string;xval:boolean);
    function geti(xname:string):longint;
    procedure seti(xname:string;xval:longint);
    function geti64(xname:string):comp;
    procedure seti64(xname:string;xval:comp);
    function getdt64(xname:string):tdatetime;
    procedure setdt64(xname:string;xval:tdatetime);//31jan2022
    function getc(xname:string):currency;
    procedure setc(xname:string;xval:currency);
    function gets(xname:string):string;
    procedure sets(xname,xvalue:string);
    function getd(xname:string):tstr8;//28jun2024: optimised, 27apr2021
    procedure setd(xname:string;xvalue:tstr8);
    function xfind(xname:string;var xpos,nlen,dlen,blen:longint):boolean;
    function xnext(var xfrom,xpos,nlen,dlen,blen:longint):boolean;
    procedure xsets(xname,xvalue:string);
    procedure xsetd(xname:string;xvalue:tstr8);//28jun2024: updated
    function gettext:string;
    procedure settext(const x:string);
    function getdata:tstr8;
    procedure setdata(xdata:tstr8);
    function getbinary(hdr:string):tstr8;
    procedure setbinary(hdr:string;xval:tstr8);
   public
    //options
    ofullcompatibility:boolean;//default=true=accepts 1. "name:" or 2. "name: value" or 3. "name:value" or 4. "name...(last non-space)" -> previously only accepted options 1 and 2, false=revert back to options 1 and 2 only
    //create
    constructor create; virtual;
    destructor destroy; override;
    property core:tstr8 read icore;//use carefully - 09oct2020
    //workers
    procedure clear;
    //information
    function len:longint;
    function found(xname:string):boolean;
    property b[xname:string]:boolean read getb write setb;
    property i[xname:string]:longint read geti write seti;
    property i64[xname:string]:comp read geti64 write seti64;
    property dt64[xname:string]:tdatetime read getdt64 write setdt64;//31jan2022
    property c[xname:string]:currency read getc write setc;
    property value[xname:string]:string read gets write sets;//support text only
    property s[xname:string]:string read gets write sets;//support text only
    property d[xname:string]:tstr8 read getd write setd;//supports binary data
    //.fast "d" access - 28dec2021
    function dget(xname:string;xdata:tstr8):boolean;
    //default value handlers
    function bdef(xname:string;xdefval:boolean):boolean;
    function idef(xname:string;xdefval:longint):longint;
    function idef2(xname:string;xdefval,xmin,xmax:longint):longint;
    function idef64(xname:string;xdefval:comp):comp;
    function idef642(xname:string;xdefval,xmin,xmax:comp):comp;
    function sdef(xname,xdefval:string):string;
    //special setters -> return TRUE if new value set else FALSE - 25mar2021
    function bok(xname:string;xval:boolean):boolean;
    function iok(xname:string;xval:longint):boolean;
    function i64ok(xname:string;xval:comp):boolean;
    function cok(xname:string;xval:currency):boolean;
    function sok(xname,xval:string):boolean;
    //workers
    property text:string read gettext write settext;
    property data:tstr8 read getdata write setdata;
    property binary[hdr:string]:tstr8 read getbinary write setbinary;
    function xnextname(var xpos:longint;var xname:string):boolean;
    function findcount:longint;//10jan2022
    function xdel(xname:string):boolean;//02jan2022
    //io
    function tofile(x:string;var e:string):boolean;//12may2025
    function fromfile(x:string;var e:string):boolean;//12may2025
   end;

{tfastvars}
   tfastvars=class(tobject)//10x or more faster than "tvars8"
   private
    icount,ilimit:longint;
    vnref1:array[0..999] of longint;
    vnref2:array[0..999] of longint;
    vn:array[0..999] of string;
    vb:array[0..999] of boolean;
    vi:array[0..999] of longint;
    vc:array[0..999] of comp;
    vs:array[0..999] of string;
    vm:array[0..999] of byte;
    function xmakename(xname:string;var xindex:longint):boolean;
    function getb(xname:string):boolean;
    function geti(xname:string):longint;
    function getc(xname:string):comp;
    function gets(xname:string):string;
    function getdt(xname:string):tdatetime;
    procedure setb(xname:string;x:boolean);
    procedure seti(xname:string;x:longint);
    procedure setc(xname:string;x:comp);
    procedure sets(xname:string;x:string);
    procedure setdt(xname:string;xval:tdatetime);//20aug2024
    function getchecked(xname:string):boolean;//12jan2024
    procedure setchecked(xname:string;x:boolean);
    function getn(xindex:longint):string;
    procedure setdata(xdata:tstr8);//20aug2024: upgraded to handle more data variations, e.g. "name: value" or "name:value" or "name   " -> originally only the first instance was accepted, now all 3 are
    function getdata:tstr8;
    procedure settext(const x:string);
    function gettext:string;
    procedure setnettext(x:string);
    function getv(xindex:longint):string;
    procedure setv(xindex:longint;x:string);//22aug2024
   public
    //options
    ofullcompatibility:boolean;//defaults=true
    oincludecomments:boolean;//defaults=true
    //create
    constructor create; virtual;
    destructor destroy; override;
    //information
    property limit:longint read ilimit;
    property count:longint read icount;
    //workers
    procedure clear;
    function find(xname:string;var xindex:longint):boolean;
    //found
    function found(xname:string):boolean;
    function sfound(xname:string;var x:string):boolean;
    function sfound8(xname:string;x:pobject;xappend:boolean;var xlen:longint):boolean;
    //values
    property b[x:string]:boolean read getb write setb;
    property i[x:string]:longint read geti write seti;
    property c[x:string]:comp read getc write setc;
    property s[x:string]:string read gets write sets;
    property dt[xname:string]:tdatetime read getdt write setdt;//20aug2024
    property n[x:longint]:string read getn;//name
    property v[x:longint]:string read getv write setv;//value
    //.html support
    property checked[x:string]:boolean read getchecked write setchecked;//uses string storage "s[x]"
    //inc
    //.32bit longint
    procedure iinc(xname:string);
    procedure iinc2(xname:string;xval:longint);
    //.64bit comp
    procedure cinc(xname:string);
    procedure cinc2(xname:string;xval:comp);
    //io
    property nettext:string write setnettext;//reads in POST data from a web stream
    property text:string read gettext write settext;
    property data:tstr8 read getdata write setdata;
    function tofile(x:string;var e:string):boolean;
    function fromfile(x:string;var e:string):boolean;
   end;

{tdynamiclist}
   tdynamiclistevent=procedure(sender:tobject;index:longint) of object;
   tdynamiclistswapevent=procedure(sender:tobject;x,y:longint) of object;
   tdynamiclist=class(tobject)
   private
    procedure setcount(x:longint);
    procedure setsize(x:longint);
    procedure setbpi(x:longint);//bytes per item
    procedure setincsize(x:longint);
    function notify(s,f:longint;_event:tdynamiclistevent):boolean;
   public
    //internal vars - do not reference directly - for use by other class types
    itextsupported:boolean;
    icore:pointer;
    icount,iincsize,ilimit,ibpi,isize:longint;
    ilockedBPI:boolean;
    //vars
    freesorted:boolean;//destroys "sorted" object if TRUE
    sorted:tdynamicinteger;
    //user vars
    utag:longint;
    //events
    oncreateitem:tdynamiclistevent;
    onfreeitem:tdynamiclistevent;
    onswapitems:tdynamiclistswapevent;
    //internal - 07feb2021
    property _textsupported:boolean read itextsupported write itextsupported;
    property _size:longint read isize write isize;
    //create
    constructor create; virtual;
    destructor destroy; override;
    procedure _createsupport; virtual;
    procedure _destroysupport; virtual;
    //workers
    procedure clear; virtual;
    //.add
    function add:boolean;
    function addrange(_count:longint):boolean;
    //.delete
    function _del(x:longint):boolean;//2nd copy - 20oct2018
    function del(x:longint):boolean;
    function delrange(s,_count:longint):boolean;
    //.insert
    function ins(x:longint):boolean;
    function insrange(s,_count:longint):boolean;
    function swap(x,y:longint):boolean;
    function setparams(_count,_size,_bpi:longint):boolean;
    //limits
    function forcesize(x:longint):boolean;//sets both SIZE and COUNT making all elements immediately available - 25jul2024
    property count:longint read icount write setcount;
    property size:longint read isize write setsize;
    function atleast(_size:longint):boolean; virtual;
    property bpi:longint read ibpi write setbpi;//bytes per item
    property limit:longint read ilimit;
    property incsize:longint read iincsize write setincsize;
    function findvalue(_start:longint;_value:pointer):longint;
    function sindex(x:longint):longint;
    //sort
    procedure sort(_asc:boolean);
    procedure nosort;
    procedure nullsort;
    //core
    property core:pointer read icore;
    //support
    procedure _oncreateitem(sender:tobject;index:longint); virtual;
    procedure _onfreeitem(sender:tobject;index:longint); virtual;
    function _setparams(_count,_size,_bpi:longint;_notify:boolean):boolean; virtual;
    procedure shift(s,by:longint); virtual;
    procedure _init; virtual;
    procedure _corehandle; virtual;
    procedure _sort(_asc:boolean); virtual;
   end;

{tdynamicbyte}
   tdynamicbyte=class(tdynamiclist)
   private
    iitems:pdlbyte;
    ibits:pdlbitboolean;
    function getvalue(_index:longint):byte;
    procedure setvalue(_index:longint;_value:byte);
    function getsvalue(_index:longint):byte;
    procedure setsvalue(_index:longint;_value:byte);
   public
    constructor create; override;//01may2019
    destructor destroy; override;//01may2019
    property value[x:longint]:byte read getvalue write setvalue;
    property svalue[x:longint]:byte read getsvalue write setsvalue;
    property items:pdlBYTE read iitems;
    property bits:pdlBITBOOLEAN read ibits;
    function find(_start:longint;_value:byte):longint;
    //support
    procedure _init; override;
    procedure _corehandle; override;
    procedure _sort(_asc:boolean); override;
    procedure __sort(a:pdlBYTE;b:pdllongint;l,r:longint;_asc:boolean);
   end;

{tdynamicword}
    tdynamicword=class(tdynamiclist)
    private
     iitems:pdlWORD;
     function getvalue(_index:integer):word;
     procedure setvalue(_index:integer;_value:word);
     function getsvalue(_index:integer):word;
     procedure setsvalue(_index:integer;_value:word);
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     property value[x:integer]:word read getvalue write setvalue;
     property svalue[x:integer]:word read getsvalue write setsvalue;
     property items:pdlWORD read iitems;
     function find(_start:integer;_value:word):integer;
     //support
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlWORD;b:pdlLONGINT;l,r:integer;_asc:boolean);
    end;

{tdynamicinteger}
   tdynamicinteger=class(tdynamiclist)//09feb2022
   private
    iitems:pdllongint;
    function getvalue(_index:longint):longint;
    procedure setvalue(_index:longint;_value:longint);
    function getsvalue(_index:longint):longint;
    procedure setsvalue(_index:longint;_value:longint);
   public
    constructor create; override;//01may2019
    destructor destroy; override;//01may2019
    function copyfrom(s:tdynamicinteger):boolean;//09feb2022
    property value[x:longint]:longint read getvalue write setvalue;
    property svalue[x:longint]:longint read getsvalue write setsvalue;
    property items:pdllongint read iitems;
    function find(_start:longint;_value:longint):longint;
    //support
    procedure _init; override;
    procedure _corehandle; override;
    procedure _sort(_asc:boolean); override;
    procedure __sort(a:pdllongint;b:pdllongint;l,r:longint;_asc:boolean);
   end;

{tdynamicpoint}
    tdynamicpoint=class(tdynamiclist)
    private
     iitems:pdlPOINT;
     function getvalue(_index:integer):tpoint;
     procedure setvalue(_index:integer;_value:tpoint);
     function getsvalue(_index:integer):tpoint;
     procedure setsvalue(_index:integer;_value:tpoint);
     procedure _init; override;
     procedure _corehandle; override;
    protected
     procedure _sort(_asc:boolean); override;
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     property value[x:integer]:tpoint read getvalue write setvalue;
     property svalue[x:integer]:tpoint read getsvalue write setsvalue;
     property items:pdlPOINT read iitems;
     function find(_start:integer;_value:tpoint):integer;
     //support
     function areaTOTAL(var x1,y1,x2,y2:integer):boolean;//18OCT2011
     function areaTOTALEX(var a:twinrect):boolean;//18OCT2011
    end;

{tdynamicdatetime}
    tdynamicdatetime=class(tdynamiclist)
    private
     iitems:pdlDATETIME;
     function getvalue(_index:longint):tdatetime;
     procedure setvalue(_index:longint;_value:tdatetime);
     function getsvalue(_index:longint):tdatetime;
     procedure setsvalue(_index:longint;_value:tdatetime);
    public
     constructor create; override;
     destructor destroy; override;
     property value[x:longint]:tdatetime read getvalue write setvalue;
     property svalue[x:longint]:tdatetime read getsvalue write setsvalue;
     property items:pdlDATETIME read iitems;
     function find(_start:longint;_value:tdatetime):longint;
     //support
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlDATETIME;b:pdllongint;l,r:longint;_asc:boolean);
    end;

{tdynamiccurrency}
    tdynamiccurrency=class(tdynamiclist)
    private
     iitems:pdlCURRENCY;
     function getvalue(_index:longint):currency;
     procedure setvalue(_index:longint;_value:currency);
     function getsvalue(_index:longint):currency;
     procedure setsvalue(_index:longint;_value:currency);
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     property value[x:longint]:currency read getvalue write setvalue;
     property svalue[x:longint]:currency read getsvalue write setsvalue;
     property items:pdlCURRENCY read iitems;
     function find(_start:longint;_value:currency):longint;
     //support
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlCURRENCY;b:pdllongint;l,r:longint;_asc:boolean);
    end;

{tdynamiccomp}
    tdynamiccomp=class(tdynamiclist)//20OCT2012
    private
     iitems:pdlCOMP;
     function getvalue(_index:longint):comp;
     procedure setvalue(_index:longint;_value:comp);
     function getsvalue(_index:longint):comp;
     procedure setsvalue(_index:longint;_value:comp);
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     property value[x:longint]:comp read getvalue write setvalue;
     property svalue[x:longint]:comp read getsvalue write setsvalue;
     property items:pdlCOMP read iitems;
     function find(_start:longint;_value:comp):longint;
     //support
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlCOMP;b:pdlLONGINT;l,r:longint;_asc:boolean);
    end;

{tdynamicpointer}
    tdynamicpointer=class(tdynamiclist)
    private
     iitems:pdlPOINTER;
     function getvalue(_index:longint):pointer;
     procedure setvalue(_index:longint;_value:pointer);
     function getsvalue(_index:longint):pointer;
     procedure setsvalue(_index:longint;_value:pointer);
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     property value[x:longint]:pointer read getvalue write setvalue;
     property svalue[x:longint]:pointer read getsvalue write setsvalue;
     property items:pdlPOINTER read iitems;
     function find(_start:longint;_value:pointer):longint;
     //support
     procedure _init; override;
     procedure _corehandle; override;
    end;

{tdynamicstring}
    tdynamicstring=class(tdynamiclist)//09feb2022
    private
     iitems:pdlstring;
     function getvalue(_index:longint):string;
     procedure setvalue(_index:longint;_value:string); virtual;
     function getsvalue(_index:longint):string;
     procedure setsvalue(_index:longint;_value:string);
     function gettext:string;
     procedure settext(const x:string);
     function getstext:string;
    public
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     function copyfrom(s:tdynamicstring):boolean;//09feb2022
     property text:string read gettext write settext;
     property stext:string read getstext;
     property value[x:longint]:string read getvalue write setvalue;
     property svalue[x:longint]:string read getsvalue write setsvalue;
     property items:pdlstring read iitems;
     function find(_start:longint;_value:string;_casesensitive:boolean):longint;//01may2025
     //support
     procedure _oncreateitem(sender:tobject;index:longint); override;
     procedure _onfreeitem(sender:tobject;index:longint); override;
     procedure _init; override;
     procedure _corehandle; override;
     procedure _sort(_asc:boolean); override;
     procedure __sort(a:pdlstring;b:pdllongint;l,r:longint;_asc:boolean);
    end;

{tlitestrings}
    tlitestrings=class(tobjectex)
    private
     idata:tdynamicstring;
     ipos,ilen:tdynamicinteger;
     ibytes,icount,isharecount:integer;
     function getvalue(_index:integer):string;
     procedure setvalue(_index:integer;_value:string);//fixed - 30apr2015
     function gettext:string;
     procedure settext(const x:string);
     procedure setsize(x:integer);
     procedure setcount(x:integer);
     function getsize:integer;
    public
     //create
     constructor create;
     destructor destroy; override;
     //information
     property count:integer read icount write setcount;
     property size:integer read getsize write setsize;
     property bytes:integer read ibytes;//07sep2015
     function atleast(_size:integer):boolean;
     function setparams(_count,_size:integer):boolean;
     //workers
     procedure clear;//clean reset - 09DEC2011
     procedure flush;//fast clear and retains size - 07sep2015
     function find(_start:integer;_value:string;_casesensitive:boolean):integer;
     property text:string read gettext write settext;
     property value[x:integer]:string read getvalue write setvalue;
    end;

{tdynamicname}
    tdynamicname=class(tdynamicstring)
    private
     iref:tdynamiccomp;
     function _setparams(_count,_size,_bpi:longint;_notify:boolean):boolean; override;
     procedure setvalue(_index:longint;_value:string); override;
     procedure shift(s,by:longint); override;
    public
     //create
     constructor create; override;//01may2019
     destructor destroy; override;//01may2019
     procedure _createsupport; override;
     procedure _destroysupport; override;
     //other
     function findfast(_start:longint;_value:string):longint;
     procedure sync(x:longint);
     //internal
     property ref:tdynamiccomp read iref;
    end;

{tdynamicnamelist}
    tdynamicnamelist=class(tdynamicname)
    private
     iactive:longint;
    public
     //vars
     delshrink:boolean;
     //create
     constructor create; override;
     destructor destroy; override;
     property active:longint read iactive;
     procedure clear; override;
     function add(x:string):longint;
     function addb(x:string;newonly:boolean):longint;
     function addex(x:string;newonly:boolean;var isnewitem:boolean):longint;
     function addonce(x:string):boolean;//true=non-existent and added, false=already exists
     function addonce2(x:string;var xindex:longint):boolean;//08feb2020
     function del(x:string):boolean;
     function have(x:string):boolean;
     function find(x:string;var xindex:longint):boolean;//09apr2024
     function replace(x,y:string):boolean;//can't prevent duplications if this proc is used
     procedure delindex(x:longint);//30AUG2007
    end;

{tdynamicvars}
    tdynamicvars=class(tobject)
    private
     function getcount:longint;
     function getvalue(n:string):string;
     procedure setvalue(n,v:string);
     function getvaluei(x:longint):string;
     function getvaluelen(x:longint):longint;//20oct2018
     function getname(x:longint):string;
     function _find(n,v:string;_newedit:boolean):longint;
     procedure setincsize(x:longint);
     function getincsize:longint;
     function getb(x:string):boolean;
     procedure setb(x:string;y:boolean);
     function getd(x:string):double;
     procedure setd(x:string;y:double);
     function getc(x:string):currency;
     procedure setc(x:string;y:currency);
     function geti64(x:string):comp;
     procedure seti64(x:string;y:comp);
     function geti(x:string):longint;
     procedure seti(x:string;y:longint);
     function getpt(x:string):tpoint;//09JUN2010
     procedure setpt(x:string;y:tpoint);//09JUN2010
     function getnc(x:string):currency;
     function getni(x:string):longint;
     function getni64(x:string):comp;
     function getvalueiptr(x:longint):pstring;
     function getbytes:longint;//13apr2018
    protected
     inamesREF:tdynamiccomp;
     inames:tdynamicstring;
     ivalues:tdynamicstring;
    public
     //vars
     debug:boolean;
     debugtitle:string;
     //create
     constructor create; virtual;
     destructor destroy; override;
     //wrappers
     property s[x:string]:string read getvalue write setvalue;//22SEP2007
     property b[x:string]:boolean read getb write setb;//boolean
     property i[x:string]:longint read geti write seti;//longint
     property ni[x:string]:longint read getni;//numercial comma longint - slow
     property i64[x:string]:comp read geti64 write seti64;//comp - 15jun2019
     property ni64[x:string]:comp read getni64;//numercial comma comp - slow
     property d[x:string]:double read getd write setd;//currency
     property c[x:string]:currency read getc write setc;//currency
     property nc[x:string]:currency read getnc;//numercial comma currency - slow
     property pt[x:string]:tpoint read getpt write setpt;//point - 09JUN2010
     procedure roll(x:string;by:currency);
     property n[x:longint]:string read getname;//name
     property v[x:longint]:string read getvaluei;//value
     //other
     property bytes:longint read getbytes;//13apr2018
     procedure clear; virtual;
     function new(n,v:string):longint;
     function find(n:string;var i:longint):boolean;
     function find2(n:string):longint;
     function found(n:string):boolean;
     property value[n:string]:string read getvalue write setvalue;
     property valuei[x:longint]:string read getvaluei;
     property valuelen[x:longint]:longint read getvaluelen;
     property valueiptr[x:longint]:pstring read getvalueiptr;
     property name[x:longint]:string read getname;
     property count:longint read getcount;
     property incsize:longint read getincsize write setincsize;
     procedure copyfrom(x:tdynamicvars);
     procedure copyvars(x:tdynamicvars;i,e:string);
     procedure delete(x:longint);
     procedure remove(x:longint);//20oct2018
     function rename(sn,dn:string;var e:string):boolean;//22oct2018
     //sort
     procedure sortbyNAME(_asc:boolean);//12jul2016
     procedure sortbyVALUE(_asc,_asnumbers:boolean);//04JUL2013
     procedure sortbyVALUEEX(_asc,_asnumbers,_commentsattop:boolean);//04JUL2013
     //internal
     property namesREF:tdynamiccomp read inamesREF;
     property names:tdynamicstring read inames;
     property values:tdynamicstring read ivalues;
    end;

{tdynamicstr8}
   tdynamicstr8=class(tdynamiclist)
   private
    ifallback:tstr8;
    iitems:pdlSTR8;
    function getvalue(_index:longint):tstr8;
    procedure setvalue(_index:longint;_value:tstr8);
    function getsvalue(_index:longint):tstr8;
    procedure setsvalue(_index:longint;_value:tstr8);
   public
    constructor create; override;
    destructor destroy; override;
    property _fallback:tstr8 read ifallback;//read only
    property value[x:longint]:tstr8 read getvalue write setvalue;
    property svalue[x:longint]:tstr8 read getsvalue write setsvalue;
    property items:pdlSTR8 read iitems;
    function find(_start:longint;_value:tstr8):longint;
    function isnil(_index:longint):boolean;//25jul2024
    //support
    procedure _init; override;
    procedure _corehandle; override;
    procedure _oncreateitem(sender:tobject;index:longint); override;
    procedure _onfreeitem(sender:tobject;index:longint); override;
   end;

{ttbt}
   ttbt=class(tobjectex)
   private
    ipassword,ikeyrandom,ikey:string;//fixed length string of 1000 chars
    ikeymodified:boolean;
    ipower:integer;
    function keyinit:boolean;
    function keyid(x:tstr8;var id:integer):boolean;
    procedure setpassword(x:string);
    procedure setpower(x:integer);
   public
    //options
    obreath:boolean;//default=true=application.processmessage, false=do not use "application.processmessages" - 02mar2015
    //create
    constructor create;
    destructor destroy; override;
    //workers
    property power:integer read ipower write setpower;
    property password:string read ipassword write setpassword;
    function encode(s,d:tstr8;var e:string):boolean;
    function encode4(s,d:tstr8;var e:string):boolean;//14nov2023
    function encodeLITE4(s:tstr8;e:string):boolean;
    function decode(s,d:tstr8;var e:string):boolean;//14nov2023
    function decodeLITE(s:tstr8;var e:string):boolean;//uses minimal RAM - 02JAN2012
    //internal
    function frs(s,d:tstr8;m:byte):boolean;//feedback randomisation of string - 16sep2017, 16nov2016
   end;

   
var
//1111111111111111111111111111111//????????????????????????

   //app control ---------------------------------------------------------------
   lroot_runstyle                 :longint=rsMustBoot;
   lroot_canclose                 :boolean=true;
   lroot_mustclose                :boolean=false;
   vimultimonitor                 :boolean=false;
   vizoom                         :longint=1;
   system_eventdriven             :boolean=false;//true=Windows event list driven, false=internally driven
   system_monitorindex            :longint=0;
   system_capturehwnd             :hwnd=0;
   system_info_app                :tinfofunc=nil;

   //.ia based suppression - 21dec2024
   system_ia_useroptions_suppress_all      :boolean=false;
   system_ia_useroptions_suppress_masklist :string='';

   //.windows message support
   system_wproc                   :twproc=nil;//windows message handler
   system_message_count           :longint=0;

   //.monitor support - 26nov2024 ----------------------------------------------
   system_monitors_dpiAwareV2                 :boolean=false;//true=Windows will not bitmap stretch our windows as it's up to us to perform the scaling required -> late Win10 onwards - 27nov2024
   system_monitors_init                       :boolean=false;
   system_monitors_count                      :longint=0;//number of monitors on the system
   system_monitors_activecount                :longint=0;//number of monitors plugged in
   system_monitors_primaryindex               :longint=0;//index to primary monitor record
   system_monitors_hmonitor                   :array[0..99] of hmonitor;//handle to monitor
   system_monitors_area                       :array[0..99] of twinrect;
   system_monitors_workarea                   :array[0..99] of twinrect;
   system_monitors_primary                    :array[0..99] of boolean;
   system_monitors_scale                      :array[0..99] of longint;//normal=100
   system_monitors_totalarea                  :twinrect;
   system_monitors_totalworkarea              :twinrect;


   //system support ------------------------------------------------------------
   system_timer500                :comp=0;
   system_formhandle              :longint=0;
   system_formhandleACTIVE        :longint=0;
   system_mainform                :tobject=nil;

   //.system close support
   syslist                        :array[0..39] of tobject;
   sysclose_count                 :longint=0;//low level version in addition to basicsystem.closelocked (count) - 03apr2021
   systimer_enabled               :boolean=true;
   syswait_focus                  :tobject=nil;//used for tbasicsystem.xshowwait to set/detect if it's the main tbasicsystem in use, and whether to cancel any showing dialog windows etc -> prevents 2 or more simultanous tbasicsystem's from locking in a cyclic "xshowwait()" reference stall or unexpected behaviour - 03apr2021


   //turbo ---------------------------------------------------------------------
   system_turbo                   :boolean=false;//false=idling, true=working/powering through tasks
   system_turboref                :comp=0;

   system_realtimeSYNCING         :boolean=false;//requires app to be run as Administrator to achieve "realtime" priority
   system_realtime64              :comp=0;//determines whether realtime mode should be ON or OFF
   system_realtime642             :comp=0;//time cycle before re-syncing realtime mode (incase Task Manager manually overrides us) - 25mar2022


   //system timer --------------------------------------------------------------
   //.normal timer control - 30sep2021
   systimer64             :comp=0;//normal timer - (16ms/turbo) or (30-500ms/normal)
   systimer1000           :comp=0;
   systimerTICK           :comp=0;
   systimerLAG            :comp=0;
   systimerlasttick       :comp=0;
   systimerlastlag        :comp=0;
   systimerlagref         :comp=0;
   //..events
   systimer_owner        :array[0..199] of tobject;
   systimer_event        :array[0..199] of tnotifyevent;
   systimer_busy         :array[0..199] of boolean;
   systimer_delay        :array[0..199] of comp;
   systimer_ref64        :array[0..199] of comp;
   //.high speed timer in use status - for all subsystems that adapt to higher speed timing cycles - 30sep2021
   sysfasttiminginuse    :boolean=false;


   //system cursor support -----------------------------------------------------
   system_cursorname     :string='';
   system_cursorcolor1   :longint=0;
   system_cursorcolor2   :longint=0;
   system_cursorsize     :longint=0;
   system_cursorref64    :comp=0;


   //memory tracking -----------------------------------------------------------
   system_memory_bytes            :comp=0;
   system_memory_count            :comp=0;
   system_memory_createcount      :comp=0;
   system_memory_freecount        :comp=0;


   //64bit system timer --------------------------------------------------------
   system_ms64_divval             :comp=0;//15aug2025
   system_ns64_divval             :comp=0;//15aug2025

   //.64bit less demanding version
   system_slowms64                :tslowms64=(ms:0;scan:0);

   //.system flash support
   sysflash                       :boolean=false;
   sysflash_timer                 :comp=0;

   
   //crc32 support -------------------------------------------------------------
   sys_crc32                      :array[0..255] of longint;
   sys_initcrc32                  :boolean=false;


   //misc support --------------------------------------------------------------
   p4INT32                        :array[0..32] of longint;
   p8CMP256                       :array[0..256] of comp;

   //.boot time
   system_nographics              :boolean=false;//true=disable graphic procs (mainly for debug)
   system_boot                    :comp=0;//ms
   system_boot_date               :tdatetime=0;

   //.fallback vars
   system_root_str8               :tstr8=nil;
   system_root_str9               :tstr9=nil;

   //.os version information - 26apr2025
   system_osid     :longint=0;
   system_osmajver :longint=0;
   system_osminver :longint=0;
   system_osbuild  :longint=0;
   system_osstr    :string='';
   system_osWin9X  :boolean=false;//26sep2025, 01jun2025

   //.printer list
   system_printerlist            :tdynamicstring=nil;
   system_printerserv            :tdynamicstring=nil;
   system_printerattr            :tdynamicinteger=nil;
   system_printer_devicetimeout  :tdynamicinteger=nil;
   system_printer_retrytimeout   :tdynamicinteger=nil;

   //.font list
   system_fontlist_screen        :tdynamicstring=nil;
   system_fontlist_printer       :tdynamicstring=nil;


   //small support for optimisation - 29aug2025 --------------------------------
   system_small_use8             :array[0..99] of boolean;
   system_small_str8             :array[0..99] of tstr8;

   //system message links - 07jul2025
   systemmessage__mm_wom_done    :twinmsg=nil;
   systemmessage__nn             :twinmsg=nil;//01oct2025

   //form support
   system_formIsPartOfGUI        :array[0..29] of boolean;
   system_formlist               :array[0..29] of thandle;
   system_formlist_wndproc       :array[0..29] of twinproc;

   //custom cursor - app wide - 05oct2025
   system_arrowcursor            :hcursor=0;
   system_textcursor             :hcursor=0;
   system_customcursor           :hcursor=0;//none

   //color dialog
   system_coldlg_clist :array[0..15] of tcolor32;//required by MS color dialog


//info procs -------------------------------------------------------------------

procedure app__boot(xEventDriven,xFileCache,xGUImode:boolean;xAppInfoProc:tinfofunc;xAppCreate,xAppDestroy:tproc);//02oct2025
procedure app__addwndproc(x:thandle;xwndproc:twinproc;xpartOfGUI:boolean);//12oct2025
procedure app__delwndproc(x:thandle);
function app__running:boolean;
procedure app__halt;

function app__rootfolder:string;//14feb2025
function app__subfolder(xsubfolder:string):string;
function app__subfolder2(xsubfolder:string;xalongsideexe:boolean):string;
function app__folder3(xsubfolder:string;xcreate,xalongsideexe:boolean):string;//15jan2024
function app__settingsfile(xname:string):string;

procedure app__setmainform(x:tobject);
function app__mainform:tobject;
function app__mainformHandle:longint;
function app__mainformArea:twinrect;
function app__mainformShowing:boolean;
function app__cansetwindowalpha:boolean;
function app__setwindowalpha(xwindow:hwnd;xalpha:longint):boolean;//27nov2024: sets the alpha level of window, also automatically upgrades window's extended style to support alpha values
procedure app__makemodal(const x:hwnd;xmakemodal:boolean);
procedure app__showall(const xshowForms,xincludeMainForm:boolean);//04oct2025
function app__formCount(const xmustBePartOfGUI:boolean):longint;
function app__handle:longint;
function app__hinstance:longint;

procedure app__setcapturehwnd(x:hwnd);
function app__wproc:twproc;//auto makes the windows message handler
procedure app__timers;
function app__iskeyksg(var msg:tmsg):boolean;
procedure app__reloadcursorifsizehaschanged;
function app__usecustomcursor(const msg,lparam:longint;const defcursor:hcursor):boolean;//use at the "wm_setcursor" message level
procedure app__setcustomcursorFromFile(const xfilename:string);
procedure app__setcustomcursor(xdata:pobject);
function app__processmessages:boolean;
function app__processallmessages:boolean;//05oct2025
function wproc__windowproc(h:tbasic_handle;m:tbasic_message;w:tbasic_wparam;l:tbasic_lparam):lresult; stdcall;//07jul2025, 17jun2025

//.turbo mode
procedure app__turbo;
procedure app__shortturbo(xms:comp);//doesn't shorten any existing turbo, but sets a small delay when none exist, or a short one already exists - 05jan2024
function app__turbook:boolean;

//.realtime mode
function app__realtimeOK:boolean;
procedure app__realtime;
procedure app__realtimeSYNC;//internally called by system procs - 19apr2022

procedure app__waitms(xms:longint);
procedure app__waitsec(xsec:longint);
function app__uptime:comp;
function app__uptimegreater(x:comp):boolean;
function app__uptimestr:string;

function app__info(xname:string):string;
function info__lroot(xname:string):string;//information specific to this unit of code
function info__rootfind(xname:string):string;//central point from which to find the requested information - 08aug2025, 09apr2024
function info__mode:longint;


//small procs ------------------------------------------------------------------

function small__new8:tstr8;
function small__new82(const xtext:string):tstr8;
function small__new83(var x:tstr8;const xtext:string):boolean;
function small__free8(x:pobject):boolean;


//track procs ------------------------------------------------------------------

function pok(x:pobject):boolean;//06feb2024
procedure track__inc(xindex,xcreate:longint);
procedure zzadd(x:tobject);
function zzfind(x:tobject;var xindex:longint):boolean;
procedure zzdel(x:tobject);
function zzok(x:tobject;xid:longint):boolean;
function zzok2(x:tobject):boolean;
function zznil(x:tobject;xid:longint):boolean;
function zznil2(x:tobject):boolean;//12feb202
function zzimg(x:tobject):boolean;//12feb2202
function zzobj(x:tobject;xid:longint):tobject;
function zzobj2(x:tobject;xsatlabel,xid:longint):tobject;
function zzvars(x:tvars8;xid:longint):tvars8;
function zzstr(x:tstr8;xid:longint):tstr8;


//memory management procs ------------------------------------------------------

//heap based memory
function mem__create32(xsize:longint):pointer;//32bit
function mem__create(xsize:comp):pointer;
function mem__free(var xptr:pointer):boolean;//thread safe
function mem__free2(xptr:pointer):longint;
function mem__size(xptr:pointer):comp;//get size of memory
function mem__resize32(xptr:pointer;xnewsize:longint):pointer;//32bit
function mem__resize(xptr:pointer;xnewsize:comp):pointer;//thread safe - 26aug2026
function mem__resize2(xptr:pointer;xnewsize:comp;var xoutptr:pointer):boolean;//thread safe - 26aug2026
function mem__resize3(xptr:pointer;xnewsize:comp;xclearnewbytes:boolean;var xoutptr:pointer):boolean;//thread safe - 26aug2026

//global memory
function global__create(xsize:comp):pointer;//19may2025
procedure global__free(var xptr:pointer);//01sep2025
function global__size(xptr:pointer):comp;
function global__resize(xptr:pointer;xnewsize:comp):pointer;//19may2025: fixed
function global__resize2(xptr:pointer;xnewsize:comp;var xoutptr:pointer):boolean;//26aug2025

//other
procedure mem__newpstring(var z:pstring);//29NOV2011
procedure mem__despstring(var z:pstring);//29NOV2011


//pointer procs ----------------------------------------------------------------
function ptr__shift(xstart:pointer;xshift:longint):pointer;
function ptr__copy(const s:pointer;var d):boolean;


//bitwise procs ----------------------------------------------------------------

function bit__true32(xvalue:longint;xindex:longint):boolean;
function bit__hasval32(xvalue,xhasthisval:longint):boolean;
function bit__findfirst32(xvalue:longint):longint;//find first on bit (1) - 08jun2025
function bit__findcount32(xvalue:longint):longint;//count number of on bits (1) - 08jun2025


//dialog procs -----------------------------------------------------------------

function dialog__password(var xpassword:string):boolean;//08oct2025
function dialog__color(var xcolor:longint):boolean;//08oct2025
function dialog__mask(const xlabel,xmasklist:string):string;

function dialog__open(var xfilename,xfilterlist:string):boolean;//10oct2025
function dialog__open2(var xfilename,xfilterlist:string;const xtitle:string):boolean;//10oct2025

function dialog__save(var xfilename,xfilterlist:string):boolean;//10oct2025
function dialog__save2(var xfilename,xfilterlist:string;const xtitle:string):boolean;//12oct2025, 10oct2025

//.support
function dialog__readfilter(const xfilterlist:string;var xindex:longint;var xdefext,xlist:string):boolean;//10oct2025
function dialog__updateFilterList(var xfilterlist:string;const dindex:longint):boolean;//10oct2025


//misc procs -------------------------------------------------------------------

procedure StrDispose(Str: PChar);
function StrAlloc(Size: Cardinal): PChar;
function translate(const x:string):string;
function low__closecount:longint;
procedure low__closelock;
procedure low__closeunlock;
function debugging:boolean;
function low__fireevent(xsender:tobject;x:tevent):boolean;
procedure runLOW(fDOC,fPARMS:string);//stress tested on Win98/WinXP - 27NOV2011, 06JAN2011
function vnew:tvars8;
function freeobj(x:pobject):boolean;//01sep2025, 22jun2024: Updated for GUI support, 09feb2024: Added support for "._rtmp" & mustnil, 02feb2021, 05may2020, 05DEC2011, 14JAN2011, 15OCT2004
function low__comparearray(const a,b:array of byte):boolean;//27jan2021
function low__cls(x:pointer;xsize:longint):boolean;



//filter procs -----------------------------------------------------------------
function filter__sort(const xfilterlist:string):string;
function filter__match(const xline,xmask:string):boolean;//16sep2025, 04nov2019
function filter__matchb(const xline,xmask:string):boolean;//16sep2025, 04nov2019
function filter__matchlist(const xline,xmasklist:string):boolean;//04oct2020


//string and number procs ------------------------------------------------------

procedure low__swapint(var x,y:longint);
function low__size(x:comp;xstyle:string;xpoints:longint;xsym:boolean):string;//01apr2024:plus support, 10feb2024: created
function low__mbPLUS(x:comp;sym:boolean):string;//01apr2024: created
function low__bDOT(x:comp;sym:boolean):string;
function low__b(x:comp;sym:boolean):string;//fixed - 30jan2016
function low__kb(x:comp;sym:boolean):string;
function low__kbb(x:comp;p:longint;sym:boolean):string;
function low__mb(x:comp;sym:boolean):string;
function low__mbb(x:comp;p:longint;sym:boolean):string;
function low__gb(x:comp;sym:boolean):string;
function low__gbb(x:comp;p:longint;sym:boolean):string;
function low__mbAUTO(x:comp;sym:boolean):string;//auto range - 10feb2024, 08DEC2011, 14NOV2010
function low__mbAUTO2(x:comp;p:longint;sym:boolean):string;//auto range - 10feb2024, 08DEC2011, 14NOV2010

function strm(const sfullname,spartialname:string;var vs:string;var v:longint):boolean;//partial string match with result as string/longint - 05oct2025
function str__makehash(const x:string):string;//13oct2025
function str__addval(var xdatastream:string;const xname,xval:string):boolean;//05oct2025
function str__pullval(var xpos:longint;const xdatastream:string;var xname,xval:string):boolean;//05oct2025
procedure str__dispose(Str: PChar);
function str__alloc(Size: Cardinal): PChar;
function str__to32(const x:string):longint;//02oct2025, 21jun2024, 29AUG2007
function str__from32(x:longint):string;//02oct2025, 21jun2024, 29AUG2007

function swapcharsb(const x:string;a,b:char):string;
procedure swapchars(var x:string;a,b:char);//20JAN2011

function low__findchar(const x:string;c:char):longint;//27feb2021, 14SEP2007
function low__havechar(const x:string;c:char):boolean;//27feb2021, 02FEB2008
function low__havecharb(x:string;c:char):boolean;//09mar2021
function low__findchars(const x:string;const c:array of char):longint;//03jan2025
function low__havechars(const x:string;const c:array of char):boolean;//03jan2025
function low__havecharsb(x:string;c:array of char):boolean;//03jan2025

function swapstrsb(const x,a,b:string):string;
function swapstrs(var x:string;a,b:string):boolean;
function stripwhitespace_lt(const x:string):string;//strips leading and trailing white space
function stripwhitespace(const x:string;xstriptrailing:boolean):string;

function low__point(const x,y:longint):tpoint;//09apr2024
function low__hexint2(const x2:string):longint;//26dec2023

function low__nextline0(xdata,xlineout:tstr8;var xpos:longint):boolean;//07apr2025, 31mar2025, 17oct2018
function low__nextline1(const xdata:string;var xlineout:string;xdatalen:longint;var xpos:longint):boolean;//31mar2025, 20mar2025, 17oct2018

function low__splitstr(const s:string;ssplitval:byte;var dn,dv:string):boolean;//02mar2025
function low__splitto(s:string;d:tfastvars;ssep:string):boolean;//13jan2024
function low__ref32u(const x:string):longint;//1..32 - 25dec2023, 04feb2023
function low__ref256(const x:string):comp;//01may2025: never 0 for valid input, 28dec2023
function low__ref256U(const x:string):comp;//01may2025: never 0 for valid input, 28dec2023

function low__insd64(x:double;y:boolean):double;//06jul2025
function low__insint(x:longint;y:boolean):longint;
function insbol(x,y:boolean):boolean;//05jul2025
function insint(x:longint;y:boolean):longint;
function insint32(x:longint;y:boolean):longint;
function insint64(x:comp;y:boolean):comp;
function low__inscmp(x:comp;y:boolean):comp;

function low__setstr(var xdata:string;xnewvalue:string):boolean;
function low__setcmp(var xdata:comp;xnewvalue:comp):boolean;//10mar2021
function low__setdbl(var xdata:double;xnewvalue:double):boolean;//01sep2025
function low__setint(var xdata:longint;xnewvalue:longint):boolean;
function low__setbyt(var xdata:byte;xnewvalue:byte):boolean;//01feb2025
function low__setbol(var xdata:boolean;xnewvalue:boolean):boolean;
procedure low__divmod(dividend:longint;divisor:word;var result,remainder:word);

function low__aorb(a,b:longint;xuseb:boolean):longint;
function low__aorbD64(a,b:double;xuseb:boolean):double;//04sep2025
function low__aorb32(a,b:longint;xuseb:boolean):longint;//27aug2024
function low__aorb64(a,b:comp;xuseb:boolean):comp;//27aug2024
function low__aorbrect(a,b:twinrect;xuseb:boolean):twinrect;//25nov2023
function low__aorbbyte(a,b:byte;xuseb:boolean):byte;//11feb2023
function low__aorbcur(a,b:currency;xuseb:boolean):currency;//07oct2022
function low__aorbcomp(a,b:comp;xuseb:boolean):comp;//19feb2024

function low__yes(x:boolean):string;//16sep2022
function low__enabled(x:boolean):string;//29apr2024
function low__aorbstr8(a,b:tstr8;xuseb:boolean):tstr8;//06dec2023
function low__aorbvars8(a,b:tvars8;xuseb:boolean):tvars8;//06dec2023
function low__aorbstr(a,b:string;xuseb:boolean):string;
function low__aorbobj(a,b:tobject;xuseb:boolean):tobject;//08may2025
function low__aorbchar(a,b:char;xuseb:boolean):char;
function low__aorbbol(a,b:boolean;xuseb:boolean):boolean;
procedure low__toggle(var x:boolean);

function frcmin64(x,min:comp):comp;//24jan2016
function frcmax64(x,max:comp):comp;//24jan2016
function frcrange64(x,min,max:comp):comp;//24jan2016
function frcrange642(var x:comp;xmin,xmax:comp):boolean;//20dec2023
function smallest64(a,b:comp):comp;
function largest64(a,b:comp):comp;
function strint32(x:string):longint;//01nov2024
function intstr32(x:longint):string;//01nov2024

function sign32(xpositive:boolean):longint;//29jul2025
procedure inc32(var x:longint;xby:longint);
procedure dec32(var x:longint;xby:longint);
procedure inc64(var x:comp;xby:comp);
procedure dec64(var x:comp;xby:comp);
procedure inc132(var x:longint);
procedure dec132(var x:longint);
procedure inc164(var x:comp);
procedure dec164(var x:comp);
function strint64(x:string):comp;//01nov2024, 05jun2021, 28jan2017
function intstr64(x:comp):string;//01nov2024, 30jan2017
function int__tostr(x:extended):string;

function int__fromstr(x:string):comp;
function int__byteX(xindex,x:longint):byte;
function int__byte0(x:longint):byte;
function int__byte1(x:longint):byte;
function int__byte2(x:longint):byte;
function int__byte3(x:longint):byte;
function int__round4(x:longint):longint;//round X up to nearest 4 - 26apr2025
function float__tostr_divby(xvalue,xdivby:extended):string;//12dec2024
function float__tostr(x:extended):string;//31oct2024: system independent
function float__tostr2(x:extended;xsep:byte):string;//31oct2024: system independent
function float__tostr3(x:extended;xsep:byte;xallowdecimal:boolean):string;//31oct2024: system independent
function float__fromstr(x:string):extended;//31oct2024: system independent
function float__fromstr2(x:string;xsep:byte):extended;//31oct2024: system independent
function float__fromstr3(x:string;xsep:byte;xallowdecimal:boolean):extended;//01nov2024, 31oct2024: system independent
function strdec(x:string;y:byte;xcomma:boolean):string;
function curdec(x:currency;y:byte;xcomma:boolean):string;
function curstrex(x:currency;sep:string):string;//01aug2017, 07SEP2007
function curcomma(x:currency):string;{same as "Thousands" but for "double"}
function low__remcharb(x:string;c:char):string;//26apr2019
function low__remchar(var x:string;c:char):boolean;//26apr2019
function low__rembinary(var x:string):boolean;//07apr2020
function low__digpad20(v:comp;s:longint):string;//1 -> 01
function low__digpad11(v,s:longint):string;//1 -> 01

procedure low__int3toRGB(x:longint;var r,g,b:byte);

function low__intr(x:longint):longint;//reverse longint
function low__wrdr(x:word):word;//reverse word
function low__posn(x:longint):longint;
function low__sign(x:longint):longint;//returns 0, 1 or -1 - 22jul2024
procedure low__iroll(var x:longint;by:longint);//continuous incrementer with safe auto. reset
function low__irollone(var x:longint):longint;//14jul2025, 06jan2025
function low__irollone64(var x:comp):comp;//25jul2025
procedure low__croll(var x:currency;by:currency);//continuous incrementer with safe auto. reset
procedure low__roll64(var x:comp;by:comp);//continuous incrementer with safe auto. reset to user specified value - 05feb2016
function low__nrw(x,y,r:longint):boolean;//number within range
function low__setobj(var xdata:tobject;xnewvalue:tobject):boolean;//28jun2024, 15mar2021
function low__iseven(x:longint):boolean;
function low__even(x:longint):boolean;

function frcrange2(var x:longint;xmin,xmax:longint):boolean;//20dec2023, 29apr2020
function smallest32(a,b:longint):longint;
function largest32(a,b:longint):longint;
function smallestD64(a,b:double):double;//21jul2025
function largestD64(a,b:double):double;
function largestarea32(s,d:twinrect):twinrect;//25dec2024
function cfrcrange32(x,min,max:currency):currency;//date: 02-APR-2004

function frcmin32(x,min:longint):longint;
function frcmax32(x,max:longint):longint;
function frcrange32(x,min,max:longint):longint;
function frcminD64(x,min:double):double;//05jul2025
function frcmaxD64(x,max:double):double;
function frcrangeD64(x,min,max:double):double;
function floattostrex2(x:extended):string;//19DEC2007
function floattostrex(x:extended;dig:byte):string;//07NOV20210
function strtofloatex(x:string):extended;//triggers less errors (x=nil now covered)
function restrict64(x:comp):comp;//24jan2016
function restrict32(x:comp):longint;//limit32 - 24jul2025, 24jan2016
function fr64(x,xmin,xmax:extended):extended;
function f64(x:extended):string;//25jan2025
function f642(x:extended;xdigcount:longint):string;//25jan2025
function k64(x:comp):string;//converts 64bit number into a string with commas -> handles full 64bit whole number range of min64..max64 - 24jan2016
function k642(x:comp;xsep:boolean):string;//handles full 64bit whole number range of min64..max64 - 24jan2016
function mult64(xval,xval2:comp):comp;//multiply
function add64(xval,xval2:comp):comp;//add
function sub64(xval,xval2:comp):comp;//subtract
function div64(xval,xdivby:comp):comp;//28dec2021, this proc performs proper "comp division" -> fixes Delphi's "comp" division error -> which raises POINTER EXCEPTION and MEMORY ERRORS when used at speed and repeatedly - 13jul2021, 19apr2021
function add32(xval,xval2:comp):longint;//01sep2025
function sub32(xval,xval2:comp):longint;//30sep2022, subtract
function div32(xval,xdivby:comp):longint;//proper "comp division" - 19apr2021
function pert32(xval,xlimit:comp):longint;

function strbol(x:string):boolean;//27aug2024, 02aug2024
function bolstr(x:boolean):string;
function strint(x:string):longint;//skip over pluses "+" - 22jan2022, skip over commas - 05jun2021, date: 16aug2020, 25mar2016 v1.00.50 / 10DEC2009, v1.00.045

function strlow(const x:string):string;//make string lowercase - 26apr2025
function strup(const x:string):string;//make string uppercase - 26apr2025
function strmatch(const a,b:string):boolean;//01may2025, 26apr2025
function strmatch2(const a,b:string;xcasesensitive:boolean):boolean;//01may2025, 26apr2025
function strmatch32(const a,b:string):longint;//26apr2025: replaces "comparestr"
function low__param(x:longint):string;//01mar2024

function strcopy0(const x:string;xpos,xlen:longint):string;//0based always -> forward compatible with D10 - 02may2020
function strcopy0b(x:string;xpos,xlen:longint):string;//0based always -> forward compatible with D10 - 02may2020
function strcopy1(const x:string;xpos,xlen:longint):string;//1based always -> backward compatible with D3 - 02may2020
function strcopy1b(x:string;xpos,xlen:longint):string;//1based always -> backward compatible with D3 - 02may2020

function insstr(const x:string;y:boolean):string;
procedure strdef(var x:string;const xdef:string);//set new value, default to "xdef" if xnew is nil
function strdefb(const x,xdef:string):string;
function pchar__strlen(str:pchar):cardinal; assembler;
function low__len(const x:string):longint;
function strdel0(var x:string;xpos,xlen:longint):boolean;//0based
function strdel1(var x:string;xpos,xlen:longint):boolean;//1based
function strbyte0(const x:string;xpos:longint):byte;//0based always -> backward compatible with D3 - 02may2020
function strbyte0b(x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
function strbyte1(const x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
function strbyte1b(x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
function low__setlen(var x:string;xlen:longint):boolean;
function makestr(var x:string;xlen:longint;xfillchar:byte):boolean;
function makestrb(xlen:longint;xfillchar:byte):string;


//block memory management procs ------------------------------------------------
//Note: These procs assume fixed memory blocks defined by "system_blocksize", typically 8192 bytes.
//      Controls such as tstr9 and tintlist use block based memory for maximum stability and
//      scalability by reducing/almost elmininating memory fragmentation.
function block__fastinfo(x:pobject;xpos:longint;var xmem:pdlbyte;var xmin,xmax:longint):boolean;//for supported controls (tstr9, tintlist etc) returns the memory block pointer in the byte array form "pdlbyte" referenced by the control's item index -> this provides an optimisation layer, as not every item index has to lookup it's memory block
function block__fastptr(x:pobject;xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;
function block__size:longint;//returns the system block size as defined by "system_blocksize"
procedure block__cls(x:pointer);//sets the memory block to all zeros
function block__new:pointer;//creates a new memory block and returns a pointer to it
procedure block__free(var x:pointer);//frees the memory block and sets the pointer to nil
procedure block__freeb(x:pointer);//frees the memory block and does NOT flush the pointer to nil


//binary string procs ----------------------------------------------------------
//.info
function str__info(x:pobject;var xstyle:longint):boolean;
function str__info2(x:pobject):longint;
function str__c8(x:pobject;xpos:longint):tcolor8;
function str__c24(x:pobject;xpos:longint):tcolor24;
function str__c32(x:pobject;xpos:longint):tcolor32;
function str__ok(x:pobject):boolean;
function str__lock(x:pobject):boolean;
function str__lock2(x,x2:pobject):boolean;
function str__lock3(x,x2,x3:pobject):boolean;//17dec2024
function str__unlock(x:pobject):boolean;
procedure str__unlockautofree(x:pobject);
procedure str__uaf(x:pobject);//short version of "str__unlockautofree"
procedure str__uaf2(x,x2:pobject);
procedure str__uaf3(x,x2,x3:pobject);//17dec2024
procedure str__autofree(x:pobject);
procedure str__af(x:pobject);//same as str__autofree
//.new
function str__newsametype(x:pobject):tobject;
function str__new8:tstr8;
function str__new9:tstr9;
function str__new8b(const xval:string):tstr8;
function str__new9b(const xval:string):tstr9;
function str__new8c(x:pobject):tstr8;//assigns value of "x" to new str handler object - 28jun2024
function str__new9c(x:pobject):tstr9;
function str__newlen8(xlen:longint):tstr8;//22jun2024
function str__newlen9(xlen:longint):tstr9;//22jun2024
function str__newaf8:tstr8;//autofree
function str__newaf9:tstr9;//autofree
function str__newaf8b(const xval:string):tstr8;//autofree
function str__newaf9b(const xval:string):tstr9;//autofree
//.workers
function str__equal(s,s2:pobject):boolean;
function str__mem(x:pobject):longint;
function str__datalen(x:pobject):longint;
function str__len(x:pobject):longint;
function str__minlen(x:pobject;xnewlen:longint):boolean;//29feb2024: created
function str__setlen(x:pobject;xnewlen:longint):boolean;
function str__splice(x:pobject;xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;
procedure str__clear(x:pobject);
procedure str__softclear(x:pobject);//retain data block but reset len to 0
procedure str__softclear2(x:pobject;xmaxlen:longint);
procedure str__free(x:pobject);
procedure str__free2(x,x2:pobject);
procedure str__free3(x,x2,x3:pobject);
//.multi-part web form (post data)
function str__multipart_nextitem(x:pobject;var xpos:longint;var xboundary,xname,xfilename,xcontenttype:string;xoutdata:pobject):boolean;//03apr2025
//.object support
function str__add(x,xadd:pobject):boolean;
function str__add2(x,xadd:pobject;xfrom,xto:longint):boolean;
function str__add3(x,xadd:pobject;xfrom,xlen:longint):boolean;
function str__add31(x,xadd:pobject;xfrom1,xlen:longint):boolean;
function str__addrec(x:pobject;xrec:pointer;xrecsize:longint):boolean;//20feb2024, 07feb2022
function str__insstr(x:pobject;xadd:string;xpos:longint):boolean;//18aug2024
function str__ins(x,xadd:pobject;xpos:longint):boolean;
function str__ins2(x,xadd:pobject;xpos,xfrom,xto:longint):boolean;
function str__del3(x:pobject;xfrom,xlen:longint):boolean;//06feb2024
function str__del(x:pobject;xfrom,xto:longint):boolean;//06feb2024
function str__is8(x:pobject):boolean;//x is tstr8
function str__is9(x:pobject):boolean;//x is tstr9
function str__as8(x:pobject):tstr8;//use with care
function str__as9(x:pobject):tstr9;//use with care
function str__as8f(x:pobject):tstr8;//uses fallback var instead of failure - 30aug2025
function str__as9f(x:pobject):tstr9;//uses fallback var instead of failure - 30aug2025
//.array procs
function str__asame2(x:pobject;xfrom:longint;const xlist:array of byte):boolean;
function str__asame3(x:pobject;xfrom:longint;const xlist:array of byte;xcasesensitive:boolean):boolean;//20jul2024
function str__aadd(x:pobject;const xlist:array of byte):boolean;//20jul2024
function str__addbyt1(x:pobject;xval:longint):boolean;
function str__addbol1(x:pobject;xval:boolean):boolean;
function str__addchr1(x:pobject;xval:char):boolean;
function str__addsmi2(x:pobject;xval:smallint):boolean;
function str__addwrd2(x:pobject;xval:word):boolean;
function str__addint4(x:pobject;xval:longint):boolean;
//..pdl support -> direct memory support
function str__padd(s:pobject;x:pdlbyte;xsize:longint):boolean;//15feb2024
function str__pins2(s:pobject;x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;
//.write to structure procs
function str__writeto1(x:pobject;a:pointer;asize,xfrom1,xlen:longint):boolean;
function str__writeto1b(x:pobject;a:pointer;asize:longint;var xfrom1:longint;xlen:longint):boolean;
function str__writeto(x:pobject;a:pointer;asize,xfrom0,xlen:longint):boolean;
//.string procs
function fromnullstr(a:pointer;asize:longint):string;
function str__nullstr(x:pobject):string;//07oct2025
function str__nextline0(xdata,xlineout:pobject;var xpos:longint):boolean;//07apr2025, 31mar2025, 17oct2018
procedure str__stripwhitespace_lt(s:pobject);//strips leading and trailing white space - 16mar2025
procedure str__stripwhitespace(s:pobject;xstriptrailing:boolean);
function str__sadd(x:pobject;const xdata:string):boolean;
function str__remchar(x:pobject;y:byte):boolean;//29feb2024: created
function str__text(x:pobject):string;
function str__settext(x:pobject;const xtext:string):boolean;
function str__settextb(x:pobject;const xtext:string):boolean;
function str__str0(x:pobject;xpos,xlen:longint):string;
function str__str1(x:pobject;xpos,xlen:longint):string;
function bcopy1(x:tstr8;xpos1,xlen:longint):tstr8;//fixed - 26apr2021
function str__copy81(x:tobject;xpos1,xlen:longint):tstr8;//28jun2024
function str__copy91(x:tobject;xpos1,xlen:longint):tstr9;//28jun2024
function str__sml2(x:pobject;xpos:longint):smallint;
function str__seekpos(x:pobject):longint;
function str__tag1(x:pobject):longint;
function str__tag2(x:pobject):longint;
function str__tag3(x:pobject):longint;
function str__tag4(x:pobject):longint;
function str__setseekpos(x:pobject;xval:longint):boolean;
function str__settag1(x:pobject;xval:longint):boolean;
function str__settag2(x:pobject;xval:longint):boolean;
function str__settag3(x:pobject;xval:longint):boolean;
function str__settag4(x:pobject;xval:longint):boolean;
function str__pbytes0(x:pobject;xpos:longint):byte;//NOT limited by "len", but can write all the way upto internal datalen (e.g. set via str__minlen)
function str__bytes0(x:pobject;xpos:longint):byte;//limited by actual "len" that must be set using "str__setlen"
function str__bytes1(x:pobject;xpos:longint):byte;//limited by actual "len" that must be set using "str__setlen"
procedure str__setpbytes0(x:pobject;xpos:longint;xval:byte);//NOT limited by "len", but can write all the way upto internal datalen (e.g. set via str__minlen)
procedure str__setbytes0(x:pobject;xpos:longint;xval:byte);//limited by actual "len" that must be set using "str__setlen"
procedure str__setbytes1(x:pobject;xpos:longint;xval:byte);//limited by actual "len" that must be set using "str__setlen"
//.move support
function str__moveto(s:pobject;var d;spos,ssize:longint):longint;//move memory from "s" to buffer "d" - 04may2025
function str__movefrom(s:pobject;const d;ssize:longint):longint;//move memory from buffer "d" to "s" - 04may2025

function  str__byt1(x:pobject;xpos:longint):byte;
procedure str__setbyt1(x:pobject;xpos:longint;xval:byte);
function  str__wrd2(x:pobject;xpos:longint):word;
procedure str__setwrd2(x:pobject;xpos:longint;xval:word);
function  str__int4(x:pobject;xpos:longint):longint;
procedure str__setint4(x:pobject;xpos,xval:longint);//22nov2024

//.base64 conversion procs
function str__tob64(s,d:pobject;linelength:longint):boolean;//to base64
function str__tob642(s,d:pobject;xpos1,linelength:longint):boolean;//25jul2024: support for tstr8 and tstr9, 13jan2024: uses #10 return codes
function str__tob643(s,d:pobject;xpos1,linelength:longint;r13,r10,xincludetrailingrcode:boolean):boolean;//03apr2024: r13 and r10, 25jul2024: support for tstr8 and tstr9, 13jan2024: uses #10 return codes
function str__fromb64(s,d:pobject):boolean;//25jul2024: support for tstr8 and tstr9
function str__fromb642(s,d:pobject;xpos1:longint):boolean;

//.other / older procs
function bgetstr1(x:tobject;xpos1,xlen:longint):string;
function _blen(x:tobject):longint;//does NOT destroy "x", keeps "x"
procedure bdel1(x:tobject;xpos1,xlen:longint);
function bcopystr1(const x:string;xpos1,xlen:longint):tstr8;
function bcopystrall(const x:string):tstr8;
function bcopyarray(const x:array of byte):tstr8;
function bnew2(var x:tstr8):boolean;//21mar2022
function bnewlen(xlen:longint):tstr8;
function bnewstr(const xtext:string):tstr8;
function breuse(var x:tstr8;const xtext:string):tstr8;//also acts as a pass-thru - 24aug2025, 05jul2022
function bnewfrom(xdata:tstr8):tstr8;


//timing procs -----------------------------------------------------------------
function ns64:comp;//64 bit nanosecond counter

function ms64:comp;//64 bit millisecond counter
function ms64str:string;//06NOV2010

function fastms64:comp;//07sep2025
function fastms64str:string;

function slowms64:comp;//slower, less demanding version of ms64 - 14sep2025, 31aug2025
function slowms64str:string;//slower, less demanding version of ms64 - 14sep2025, 31aug2025

function msok(var xref:comp):boolean;
function msset(var xref:comp;xdelay:comp):boolean;
function mswaiting(var xref:comp):boolean;//still valid, the timer is waiting to expire


//timer procs ------------------------------------------------------------------

function low__timerfound(xowner:tobject;x:tnotifyevent):boolean;
function low__timerset(xowner:tobject;x:tnotifyevent;xdelay:comp):boolean;//auto create/maintain a timer
function low__timerdelay(xowner:tobject;x:tnotifyevent;xnewdelay:comp):boolean;//set new delay of existing timer (if deleted, it won't be auto-created) - 19feb2021
function low__timerfinddelay(xowner:tobject;x:tnotifyevent;var xdelay:comp):boolean;
function low__timerdel(xowner:tobject;x:tnotifyevent):boolean;//delete timer


//compression procs (standard ZIP - 26jan2021) ---------------------------------
function low__compress(x:pobject):boolean;
function low__decompress(x:pobject):boolean;


//date and time procs ----------------------------------------------------------
function low__uptime(x:comp;xforcehr,xforcemin,xforcesec,xshowsec,xshowms:boolean;const xsep:string):string;//28apr2024: changed 'dy' to 'd', 01apr2024: xforcesec, xshowsec/xshowms pos swapped, fixed - 09feb2024, 27dec2021, fixed 10mar2021, 22feb2021, 22jun2018, 03MAY2011, 07SEP2007
function low__uptime2(x:comp;xforcehr,xforcemin,xforcesec,xshowsec,xshowms:boolean;const xsep,xsep2:string):string;//15aug2025
function low__monthdayfilter0(xdayOfmonth,xmonth,xyear:longint):longint;
function low__monthdaycount0(xmonth,xyear:longint):longint;
function low__year(xmin:longint):longint;
function low__yearstr(xmin:longint):string;
function low__dhmslabel(xms:comp):string;//days hours minutes and seconds from milliseconds - 06feb2023
function low__dateinminutes(x:tdatetime):longint;//date in minutes (always >0)
function low__dateascode(x:tdatetime):string;//tight as - 17oct2018
function low__SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;
function low__gmt(x:tdatetime):string;//gtm for webservers - 01feb2024
procedure low__gmtOFFSET(var h,m,factor:longint);
function low__makeetag(x:tdatetime):string;//high speed version - 25dec2023
function low__makeetag2(x:tdatetime;xboundary:string):string;//high speed version - 31mar2024, 25dec2023
function low__datetimename(x:tdatetime):string;//12feb2023
function low__datename(x:tdatetime):string;
function low__datetimename2(x:tdatetime):string;//10feb2023
function low__safedate(x:tdatetime):tdatetime;
procedure low__decodedate2(x:tdatetime;var y,m,d:word);//safe range
procedure low__decodetime2(x:tdatetime;var h,min,s,ms:word);//safe range
function low__encodedate2(y,m,d:word):tdatetime;
function low__encodetime2(h,min,s,ms:word):tdatetime;
function low__dayofweek(x:tdatetime):longint;//01feb2024
function low__dayofweek1(x:tdatetime):longint;
function low__dayofweek0(x:tdatetime):longint;
function low__dayofweekstr(x:tdatetime;xfullname:boolean):string;
function low__month1(x:longint;xfullname:boolean):string;//08mar2022
function low__month0(x:longint;xfullname:boolean):string;//08mar2022
function low__weekday1(x:longint;xfullname:boolean):string;//08mar2022
function low__weekday0(x:longint;xfullname:boolean):string;//08mar2022
function low__datestr(xdate:tdatetime;xformat:longint;xfullname:boolean):string;//09mar2022
function low__timestr(xdate:tdatetime;xformat:longint):string;//29sep2025
function low__leapyear(xyear:longint):boolean;
function low__datetoday(x:tdatetime):longint;
function low__datetosec(x:tdatetime):comp;
function low__date1(xyear,xmonth1,xday1:longint;xformat:longint;xfullname:boolean):string;
function low__date0(xyear,xmonth,xday:longint;xformat:longint;xfullname:boolean):string;//03sep2025
function low__time0(xhour,xminute:longint;xsep,xsep2:string;xuppercase,xshow24:boolean):string;
function low__hour0(xhour:longint;xsep:string;xuppercase,xshowAMPM,xshow24:boolean):string;

function date__date:tdatetime;
function date__time:tdatetime;
function date__now:tdatetime;
function date__filedatetodatetime(xfiledate:longint):tdatetime;
function date__isleapyear(year:word):boolean;
function date__encodedate(xyear,xmonth,xday:longint):tdatetime;//05may2025
function date__encodetime(xhour,xmin,xsec,xmsec:longint):tdatetime;
procedure date__decodetime(time:tdatetime;var hour,min,sec,msec:word);
function date__dayofweek(date:tdatetime):longint;
function date__datetimetotimestamp(datetime:tdatetime):ttimestamp;
function date__timestamptodatetime(const timestamp:ttimestamp):tdatetime;


//zero checkers ----------------------------------------------------------------
function nozero__int32(xdebugID,x:longint):longint;
function nozero__int64(xdebugID:longint;x:comp):comp;
function nozero__byt(xdebugID:longint;x:byte):byte;
function nozero__dbl(xdebugID:longint;x:double):double;
function nozero__ext(xdebugID:longint;x:extended):extended;
function nozero__cur(xdebugID:longint;x:currency):currency;
function nozero__sig(xdebugID:longint;x:single):single;
function nozero__rel(xdebugID:longint;x:real):real;


//logic helpers procs ----------------------------------------------------------
//special note: low__true* and low__or* designed to execute ALL input values fully
//note: force predictable logic and proc execution by forcing ALL supplied inbound values to be fully processed BEFORE a result is returned, thus allowing for muiltiple and combined dynamic value processing and yet yeilding stable and consistent output
function low__true1(v1:boolean):boolean;
function low__true2(v1,v2:boolean):boolean;//all must be TRUE to return TRUE
function low__true3(v1,v2,v3:boolean):boolean;
function low__true4(v1,v2,v3,v4:boolean):boolean;
function low__true5(v1,v2,v3,v4,v5:boolean):boolean;
function low__or2(v1,v2:boolean):boolean;//only one must be TRUE to return TRUE
function low__or3(v1,v2,v3:boolean):boolean;//only one must be TRUE to return TRUE


//crc32 procs ------------------------------------------------------------------
function crc32__createseed(var x:tseedcrc32;xseed:longint):boolean;//21aug2025
function crc32__encode(var x:tseedcrc32;xdata:tstr8):longint;//21aug2025

procedure low__initcrc32;
procedure low__crc32inc(var _crc32:longint;x:byte);//23may2020, 31-DEC-2006
procedure low__crc32(var _crc32:longint;x:tstr8;s,f:longint);//27mar2007: updated, 31dec2006
function low__crc32c(x:tstr8;s,f:longint):longint;
function low__crc32b(x:tstr8):longint;
function low__crc32nonzero(x:tstr8):longint;//02SEP2010
function low__crc32seedable(x:tstr8;xseed:longint):longint;//14jan2018


//simple message procs ---------------------------------------------------------
function showquery(const x:string):boolean;//03oct2025
function showYNC(const x:string):byte;
function showbasic(const x:string):boolean;//18jun2025
function showtext(const x:string):boolean;//12jun2025
function showtext2(const x:string;xsec:longint):boolean;//26apr2025
function showlow(const x:string):boolean;
function showerror(const x:string):boolean;
function showerror2(const x:string;xsec:longint):boolean;//08oct2025


//area procs -------------------------------------------------------------------

{$ifdef gui3}
function low__shiftarea(xarea:twinrect;xshiftx,xshifty:longint):twinrect;//always shift
function low__shiftarea2(xarea:twinrect;xshiftx,xshifty:longint;xvalidcheck:boolean):twinrect;//xvalidcheck=true=shift only if valid area, false=shift always
function area__within(const z:twinrect;const x,y:longint):boolean;
function area__grow(const x:twinrect;const xby:longint):twinrect;//07apr2021
function area__grow2(const x:twinrect;const xby,yby:longint):twinrect;//14jul2025
{$endif}

function area__make(const xleft,xtop,xright,xbottom:longint):twinrect;
function nilrect:twinrect;
function nilarea:twinrect;//25jul2021
function maxarea:twinrect;//02dec2023, 27jul2021
function validarea(x:twinrect):boolean;//26jul2021


//multi-monitor procs ----------------------------------------------------------
//.multi-monitor support
procedure monitors__sync;//06jan2025, 26nov2024
function monitors__count:longint;
function monitors__primaryindex:longint;
procedure monitors__info(xindex:longint);
function monitors__dpiAwareV2:boolean;
function monitors__scale(xindex:longint):longint;//27nov2024
function monitors__area(xindex:longint):twinrect;
function monitors__workarea(xindex:longint):twinrect;
function monitors__totalarea:twinrect;
function monitors__totalworkarea:twinrect;
function monitors__primaryarea:twinrect;
function monitors__primaryworkarea:twinrect;
function monitors__findBYarea(s:twinrect):longint;
function monitors__findBYpoint(s:tpoint):longint;
function monitors__findBYcursor:longint;
function monitors__area_auto(xindex:longint):twinrect;
function monitors__workarea_auto(xindex:longint):twinrect;
function monitors__centerINarea_auto(sw,sh,xindex:longint;xworkarea:boolean):twinrect;
//procedure monitors__centerformINarea_auto(x:tcustomform;xmonitorindex,xfromTop,dw,dh:longint);
function monitors__areawidth_auto(xindex:longint):longint;
function monitors__areaheight_auto(xindex:longint):longint;
function monitors__workareawidth_auto(xindex:longint):longint;
function monitors__workareaheight_auto(xindex:longint):longint;
function monitors__screenwidth_auto:longint;
function monitors__screenheight_auto:longint;
function monitors__workareatotalwidth:longint;
function monitors__workareatotalheight:longint;
function monitors__areatotalwidth:longint;
function monitors__areatotalheight:longint;


//sound procs ------------------------------------------------------------------
function snd__onmessage_mm(m,w,l:longint):longint;
function snd__onmessage_wave(m,w,l:longint):longint;


//gui support ------------------------------------------------------------------
function gui__vimultimonitor:boolean;
function gui__sysprogram_monitorindex:longint;
procedure gui__zoom(var aw,ah:longint);


//encryption procs -------------------------------------------------------------

//.lightweight string encryption
function str__ecapkey:string;
function str__ecap(const x:string;xencrypt:boolean):string;
function str__ecap2(x:string;xencrypt,xbin:boolean):string;
function str__stdencrypt(const x:string;ekey:string;mode1:longint):string;//03oct2025

//.tbt encryption engine
function low__encrypt2(s,d:tstr8;xpass:string;xpower:longint;xencrypt:boolean;var e:string):boolean;
function low__encrypt(s:tstr8;xpass:string;xpower:longint;xencrypt:boolean;var e:string):boolean;
function low__encryptRETAINONFAIL(s:tstr8;xpass:string;xpower:longint;xencrypt:boolean;var e:string):boolean;//14nov20223


implementation

uses lzip, lio, lnet, lform {$ifdef gui2}, limg{$endif} {$ifdef gui4}, lgui, ljpeg{$endif} {$ifdef gui3}, main{$endif};


//info procs -------------------------------------------------------------------

procedure app__boot(xEventDriven,xFileCache,xGUImode:boolean;xAppInfoProc:tinfofunc;xAppCreate,xAppDestroy:tproc);//02oct2025
var
   p:longint;
   xver:tosversioninfo;
   xshowing:boolean;
   xshowRef:string;
   v64:comp;

   procedure sv(const xvarname:string);
   begin
   if (app__info(xvarname)='') then showerror('App value "'+xvarname+'" is missing');
   end;

begin
try

//start ------------------------------------------------------------------------
if (lroot_runstyle=rsMustBoot) then lroot_runstyle:=rsBooting else exit;


//.dynamic link to app's main informtion proc
system_info_app:=xAppInfoProc;


//------------------------------------------------------------------------------
//-- Thread Safe Memory --------------------------------------------------------

//init dynamic loading for Win32 api calls
win__init;

//start com system -> required on some systems to be loaded
win____CoInitializeEx(nil,2);

//Enable Delphi 3 thread safe memory handling
IsMultiThread :=true;

//warn if system is running statically link Win32 procs
if win____emergencyfallback_engaged then
   begin

   showerror('Warning:'+rcode+rcode+'Codebase is running in emergency fallback mode and is not Windows 95/98 compatible.');

   end;


//default cursor
system_arrowcursor      :=win____loadcursor(0,IDC_ARROW);
system_textcursor       :=win____loadcursor(0,IDC_IBEAM);


//check app procs
if not assigned(xAppInfoProc) then showerror('App has no info() proc defined');
if not assigned(xAppCreate)   then showerror('App has no create() proc defined');
if not assigned(xAppDestroy)  then showerror('App has no destroy() proc defined');


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


//critical - make app DPI aware per monitor V2 - for Win10 (late) and Win 11 - 27nov2024
if win__ok(vwin2____SetProcessDpiAwarenessContext) then system_monitors_dpiAwareV2:=(0<>win2____SetProcessDpiAwarenessContext(-4));

//init
system_eventdriven:=xeventdriven;
filecache__setenable(xFileCache);//28sep2025


//multi-monitor information - 26nov2024
monitors__sync;
system_monitorindex:=monitors__findBYcursor;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//ref arrays -------------------------------------------------------------------
try
//.int32
for p:=0 to high(p4INT32) do p4INT32[p]:=p*p*p*p;
//.cmp256
for p:=0 to high(p8CMP256) do p8CMP256[p]:=mult64(p*p,p*p);
except;end;


//init system vars and procs that may be required in a unit's start proc -------
randomize;
system_boot        :=ms64;
system_boot_date   :=date__now;


//.system vars
low__cls(@system_formIsPartOfGUI,sizeof(system_formIsPartOfGUI));
low__cls(@system_formlist,sizeof(system_formlist));
low__cls(@system_formlist_wndproc,sizeof(system_formlist_wndproc));


//os version info
low__cls(@xver,sizeof(xver));
xver.dwOSVersionInfoSize:=sizeof(xver);
if win____GetVersionEx(xver) then
   begin
   system_osid     :=xver.dwPlatformId;
   system_osmajver :=xver.dwMajorVersion;//Note: tops out at v6.2 according to MS, unless the app is "manifested" for higher versions
   system_osminver :=xver.dwMinorVersion;
   system_osbuild  :=xver.dwBuildNumber;
   system_osstr    :=intstr32(system_osid)+'.'+intstr32(system_osmajver)+'.'+intstr32(system_osminver)+'.'+intstr32(system_osbuild);
   system_osWin9X  :=(system_osmajver<=4);//Windows95..98..ME = v4.*
   end;


//timers -----------------------------------------------------------------------
v64:=slowms64;

for p:=0 to high(systimer_event) do
begin

systimer_owner[p]  :=nil;
systimer_event[p]  :=nil;
systimer_busy[p]   :=false;
systimer_delay[p]  :=0;//off
systimer_ref64[p]  :=v64;

end;//p


//small and fast support -------------------------------------------------------
low__cls(@system_small_use8,sizeof(system_small_use8));
low__cls(@system_small_str8,sizeof(system_small_str8));


//check system vars ------------------------------------------------------------
sv('height');
sv('width');
sv('app.fontsize');
sv('app.fontname');
sv('app.backcolor');
sv('app.tintcolor');


//start units ------------------------------------------------------------------

//load units in expected order
lwin__start;

{$ifdef gui2}
limg__start;
lnet__start;
{$endif}

{$ifdef gui4}
lgui__start;
{$endif}

//.start system timer -> basic timer using the Windows event queue -> this timer
// acts as a basic action pump, allowing passive checkers and procs to activate when
// required, performing actions indirectly and without direct user interaction.
if system_eventdriven then win____settimer(app__wproc.window,1,system_timerinterval,nil);


//done
lroot_runstyle:=rsGUI;


//create app
if assigned(xAppCreate) then xAppCreate;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// App is now running ----------------------------------------------------------

xshowRef:='';

while true do
begin

v64:=ms64;

//.sync less demanding timer proc "slowms64"
system_slowms64.scan :=0;
system_slowms64.ms   :=ms64;

//.close
if lroot_mustclose and lroot_canclose then break;

//.messages
if not app__processmessages then win____waitmessage;//don't switch to wait mode if we're not running, e.g. shuting down etc - 28apr2024

//.timers
if (v64>=system_timer500) then
   begin

   system_turbo := (v64>=system_turboref);

   //fileache - 12apr2024
   filecache__managementevent;


   //show or hide sub-forms
   if (app__mainform<>nil)  and (app__formcount(true)>=2) then
      begin

      xshowing:=app__mainformShowing;
      if low__setstr(xshowRef, bolstr(xshowing) ) then app__showall(xshowing,false);

      end;


   //reset
   system_timer500:=add64(v64,500);

   end;

//.system flash
if (v64>=sysflash_timer) then
   begin

   sysflash       :=not sysflash;
   sysflash_timer :=add64(v64,700);

   end;

//.timers
app__timers;

//.run normally when not in turbo mode
if (not system_turbo) then app__waitms(system_timerinterval);

end;

// App has now stopped running -------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//.stop system timer
if system_eventdriven and (system_wproc<>nil) then win____killtimer(app__wproc.window,1);

//.windows message proc
if (system_wproc<>nil) then freeobj(@system_wproc);


//destroy app
if assigned(xAppDestroy) then xAppDestroy;


//shut units in expected order

{$ifdef gui4}
lgui__stop;
{$endif}

{$ifdef gui2}
lnet__stop;
limg__stop;
{$endif}

lwin__stop;


//.font list
freeobj(@system_fontlist_screen);
freeobj(@system_fontlist_printer);

//.printer list
freeobj(@system_printerlist);
freeobj(@system_printerserv);
freeobj(@system_printerattr);
freeobj(@system_printer_devicetimeout);
freeobj(@system_printer_retrytimeout);

//.system_small_strs
for p:=0 to high(system_small_str8) do str__free(@system_small_str8[p]);

//.fallback vars
freeobj(@system_root_str8);
freeobj(@system_root_str9);

//app is finished

except;end;
end;

procedure app__halt;
begin
lroot_mustclose:=true;
end;

function app__running:boolean;
begin
result:=(lroot_runstyle>rsBooting) and ( (not lroot_mustclose) or (not lroot_canclose) );
end;

function app__rootfolder:string;//14feb2025
begin
result:=io__asfolder(io__extractfilepath(io__exename));
end;

function app__subfolder(xsubfolder:string):string;
begin
result:=app__subfolder2(xsubfolder,false);
end;

function app__subfolder2(xsubfolder:string;xalongsideexe:boolean):string;
begin
result:=app__folder3(xsubfolder,true,xalongsideexe);
end;

function app__folder3(xsubfolder:string;xcreate,xalongsideexe:boolean):string;//15jan2024
begin

//xalongsideexe=false="exe path\", true="exe path\<exe name>_storage\"
result:=io__asfolder(io__extractfilepath(io__exename));
if not xalongsideexe then result:=io__asfolder(result+io__extractfilename(io__exename)+'_storage');

//subfolder
if (xsubfolder<>'') then result:=io__asfolder(result+xsubfolder);

//create
if xcreate then io__makefolder(result);

end;

function app__settingsfile(xname:string):string;
begin
result:=app__subfolder('settings')+io__extractfilename(xname);
end;

procedure app__setmainform(x:tobject);
begin
system_mainform:=x;
end;

function app__mainform:tobject;
begin
result:=system_mainform;
end;

function app__mainformHandle:longint;
begin

//defautls
result:=0;

//get
{$ifdef gui}
if (system_mainform<>nil) then
   begin

   {$ifdef gui4}
   if      (system_mainform is tform)         then result:=(system_mainform as tform).handle;
   if (system_mainform is tcustomform)        then result:=(system_mainform as tcustomform).handle;
   {$endif}
   
   if (system_mainform is tliteform)          then result:=(system_mainform as tliteform).handle;

   end;
{$endif}

end;

function app__mainformArea:twinrect;
var
   h:longint;
begin

//defautls
result:=nilrect;

//get
{$ifdef gui}
if (system_mainform<>nil) then
   begin

   h:=app__mainformHandle;
   if (h<>0) then win____GetWindowRect(h,result);

   end;
{$endif}

end;

function app__mainformShowing:boolean;
var
   h:longint;
begin

//defautls
result:=false;

{$ifdef gui}
if (system_mainform<>nil) then
   begin

   h:=app__mainformHandle;
   result:=(h<>0) and win____IsWindowVisible(h) and (not win____isiconic(h));

   end;
{$endif}

end;

function app__cansetwindowalpha:boolean;
begin
result:=win__ok(vwin2____SetLayeredWindowAttributes);
end;

function app__setwindowalpha(xwindow:hwnd;xalpha:longint):boolean;//27nov2024: sets the alpha level of window, also automatically upgrades window's extended style to support alpha values
label//dwFlags: LWA_ALPHA=2, LWA_COLORKEY=1
   skipend;
var
   v:longint;
begin
//defaults
result:=false;

try
//range
xalpha:=frcrange32(xalpha,20,255);

//check
if (xwindow=0) then goto skipend;

//get
if app__cansetwindowalpha then
   begin
   //ensure window has "WS_EX_LAYERED" in its extended window style
   v:=win____GetWindowLong(xwindow,GWL_EXSTYLE);
   if not bit__hasval32(v,WS_EX_LAYERED) then
      begin
      v:=v or WS_EX_LAYERED;
      if (0=win____SetWindowLong(xwindow,GWL_EXSTYLE,v)) then goto skipend;
      end;

   //set alpha value
   if not win__ok(vwin2____SetLayeredWindowAttributes) then goto skipend;
   if (0=win2____SetLayeredWindowAttributes(xwindow,0,byte(xalpha),2)) then goto skipend;

   //successful
   result:=true;
   end;

skipend:
except;end;
end;

procedure app__makemodal(const x:hwnd;xmakemodal:boolean);
var
   p:longint;
begin

for p:=0 to high(system_formIsPartOfGUI) do if (system_formlist[p]<>0) and system_formIsPartOfGUI[p] and (system_formlist[p]<>x) then
   begin

   win____EnableWindow( system_formlist[p], not xmakemodal );

   end;//p

end;

procedure app__showall(const xshowForms,xincludeMainForm:boolean);//04oct2025
var
   p,xcludeMainForm:longint;
begin

if xincludeMainForm then xcludeMainForm:=0 else xcludeMainForm:=app__mainformhandle;

for p:=0 to high(system_formIsPartOfGUI) do if (system_formlist[p]<>0) and system_formIsPartOfGUI[p] and (system_formlist[p]<>xcludeMainForm) then
   begin

   win____ShowWindow( system_formlist[p], low__aorb(sw_hide,SW_RESTORE,xshowForms) );

   end;//p

end;

function app__formCount(const xmustBePartOfGUI:boolean):longint;
var
   p:longint;
begin

result:=0;
for p:=0 to high(system_formIsPartOfGUI) do if (system_formlist[p]<>0) and ( system_formIsPartOfGUI[p] or (not xmustBePartOfGUI) ) then inc(result);

end;

function app__handle:longint;
begin
result:=win____GetModuleHandle(nil);
end;

function app__hinstance:longint;
begin
result:=win____GetModuleHandle(nil);
end;

procedure app__addwndproc(x:thandle;xwndproc:twinproc;xpartOfGUI:boolean);//12oct2025
var
   i,p:longint;
begin

//check
if (x=0) then exit;

//init
i:=-1;

//find existing
for p:=0 to high(system_formlist) do if (x=system_formlist[p]) then
   begin

   i:=p;
   break;

   end;

//find new
if (i<0) then for p:=0 to high(system_formlist) do if (system_formlist[p]=0) then
   begin

   i:=p;
   break;

   end;

//set -> place form handle on the formlist for message interception
if (i>=0) then
   begin

   system_formIsPartOfGUI[i]   :=xpartOfGUI;
   system_formlist[i]          :=x;
   system_formlist_wndproc[i]  :=xwndproc;

   end;

end;

procedure app__delwndproc(x:thandle);
var
   p:longint;
begin

//place form handle on the formlist for message interception
if (x<>0) then for p:=0 to high(system_formlist) do if (system_formlist[p]=0) then
   begin

   system_formlist_wndproc[p]  :=nil;
   system_formlist[p]          :=0;
   system_formIsPartOfGUI[p]   :=false;
   break;

   end;

end;

procedure app__setcapturehwnd(x:hwnd);
begin

win____releasecapture;
system_capturehwnd:=0;

if (x<>0) then
   begin

   win____SetCapture(x);
   system_capturehwnd:=X;

   end;

end;

function app__wproc:twproc;//auto makes the windows message handler
begin
result:=system_wproc;

try
if (result=nil) then
   begin
   system_wproc:=twproc.create;
   result:=system_wproc;
   end;
except;end;
end;

procedure app__timers;
var
   tmp64,d64,v64:comp;
   p:longint;
begin
try

//shutdown - thread safe - 30sep2021
if lroot_mustclose and lroot_canclose then exit;


//normal timers ----------------------------------------------------------------
v64            :=fastms64;//16ms accuracy

//.normal timers
if (v64>=systimer64) then
   begin

   //sync realtime - 25mar2022
   app__realtimeSYNC;

   //lag
   if (systimerLAGref<>0) then
      begin

      tmp64:=sub64(v64,systimerLAGref);
      if (tmp64>systimerlastLAG) then systimerlastLAG:=tmp64;

      end;

    systimerLAGref:=v64;

   //tick counter
   systimerlasttick:=systimerlasttick+1;

   if (v64>=systimer1000) then
      begin

      systimer1000      :=v64+1000;
      systimerTICK      :=systimerlasttick;
      systimerlasttick  :=0;
      systimerLAG       :=systimerlastlag;//07oct2021
      systimerlastlag   :=0;

      end;

   //speed + events
   d64:=100;

   for p:=0 to high(systimer_event) do if assigned(systimer_event[p]) then
      begin

      //smallest system delay
      if (systimer_delay[p]>=1) and (systimer_delay[p]<d64) then d64:=systimer_delay[p];

      //fire timer event
      if (systimer_delay[p]>=1) and (v64>=systimer_ref64[p]) and (not systimer_busy[p]) then
         begin

         //Critical Note: This is the only pointer other than within "gossgui__start" that a timer's busy state is modified -> all other timer procs work around it - 19feb2021
         systimer_busy[p]:=true;//lock the timer
         systimer_ref64[p]:=v64+systimer_delay[p];
         try;systimer_event[p](nil);except;end;
         systimer_busy[p]:=false;//unlock the timer (even if it has been deleted)

         end;

      end;//p

   //.min delay for normal timers is 30ms
   d64:=div64(d64,2);//divide smallest delay in half for a better, rounder delay
   if (d64<30) then d64:=30;

   //.turbo mode is on
   if app__turboOK then d64:=1;

   //.finalise speed
   systimer64:=v64+d64;

   end;//p

//.reload CURSOR whenever we are NOT running the default system cursor -> Changes to the size of the Windows cursor causes damaging distortion to a ready loaded and active cursor, thus ANY custom based cursor MUST be reloaded to allow for windows to resample the cursor at the new system dimensions - 28may2022
if (slowms64>=system_cursorref64) then
   begin

   app__reloadcursorifsizehaschanged;
   system_cursorref64:=slowms64+10000;//10s

   end;

except;end;
end;

procedure app__reloadcursorifsizehaschanged;
begin
//was: if (not strmatch(system_cursorname,'default')) and (system_cursorsize<>strint32(reg__readval(0,'Control Panel\Cursors\CursorBaseSize',true))) then app__loadcursor(false);
end;

function app__iskeyksg(var msg:tmsg):boolean;
var
   h:hwnd;
begin

//defaults
result:=false;

//get
if (msg.message>=WM_KEYFIRST) and (msg.message<=WM_KEYLAST) and (0=win____GetCapture) then
   begin

   h:=msg.hwnd;

   if (app__mainformhandle<>0) then h:=app__mainformhandle;

   if win____sendmessage(h, CN_BASE + msg.message, msg.WParam, msg.LParam) <> 0 then result:=true;
   end;

end;

procedure app__setcustomcursorFromFile(const xfilename:string);
var
   x:tstr8;
   e:string;
begin

//defaults
x:=nil;

try
//init
x:=str__new8;

//get
case (xfilename<>'') and io__fromfile(xfilename,@x,e) and (x.len>=1) of
true:app__setcustomcursor(@x)
else app__setcustomcursor(nil);
end;//case

except;end;

//free
str__free(@x);

end;

procedure app__setcustomcursor(xdata:pobject);
label
   skipend;
var
   xok:boolean;
   df,e:string;
   p:longint;
begin

//defaults
xok :=false;
df  :='';

try
//init
if not str__lock(xdata) then goto skipend;
if (str__len(xdata)<=0) then goto skipend;

//get
df  :=io__wintemp+'tmpcur.cur';
if not io__tofile(df,xdata,e) then
   begin

   //fallback to our own folder
   df  :=io__extractfilepath( io__exename ) +'tmpcur.cur';
   if not io__tofile(df,xdata,e) then goto skipend;

   end;

//set
system_customcursor:=win____loadcursorfromfile( pchar(df) );

//successful
xok:=true;

skipend:

//no custom cursor on error
if not xok then system_customcursor:=0;

//sync delphi screen cursors
{$ifdef gui4}
screen.cursors[-2]:=low__aorb(system_arrowcursor, system_customcursor, system_customcursor<>0 );//arrow
screen.cursors[-4]:=low__aorb(system_textcursor,  system_customcursor, system_customcursor<>0 );//text cursor - Ibeam
{$endif}

except;end;

//free
str__uaf(xdata);

//remove temp file
if (df<>'') then io__remfile(df);

end;

function app__usecustomcursor(const msg,lparam:longint;const defcursor:hcursor):boolean;//use at the "wm_setcursor" message level
begin

if (msg=wm_setcursor) and ((tint4(lparam).bytes[0]=htclient) or (tint4(lparam).bytes[0]=htcaption)) then
   begin

   if (system_customcursor<>0) then
      begin

      result:=true;
      win____setcursor(system_customcursor);

      end

   else if (defcursor<>0) then
      begin

      result:=true;
      win____setcursor(defcursor);

      end

   else result:=false;

   end

else result:=false;

end;

function app__processmessages:boolean;
label
   redo;
var
   xhandled:boolean;
   msg:tmsg;
   v64:comp;
begin

//defaults
result :=false;
v64    :=ms64;

//get
redo:
if win____peekmessage(msg,0,0,0,PM_REMOVE) then
   begin
   result:=true;//13mar2022

   if (msg.message=WM_QUIT) then lroot_mustclose:=true
   else
      begin

      //not handled
      xhandled:=false;


      //send keystrokes to delphi app structure - 05oct2025
      if app__iskeyksg(msg) then xhandled:=true;


      //custom cursor
      if app__usecustomcursor(msg.message,msg.lparam,system_arrowcursor) then xhandled:=true;

      
      //default handler
      if not xhandled then
         begin
         win____translatemessage(msg);
         win____dispatchmessage(msg);
         end;

      //loop - process multiple message for upto just less than 2ms - 30sep2021
      if ((ms64-v64)<=5) then goto redo;

      end;
   end;

end;

function app__processallmessages:boolean;//05oct2025
begin

//defaults
result:=false;

//get
while true do
begin

case app__processmessages of
true:result:=true;
else break;
end;//case

end;//loop

end;

procedure app__turbo;
begin
system_turbo:=true;
msset(system_turboref,5000);
end;

procedure app__shortturbo(xms:comp);//doesn't shorten any existing turbo, but sets a small delay when none exist, or a short one already exists - 05jan2024
begin
xms:=add64(ms64,xms);
if (xms>system_turboref) then
   begin
   system_turbo:=true;
   system_turboref:=xms;
   end;
end;

function app__turbook:boolean;
begin
result:=system_turbo or mswaiting(system_turboref);
end;

function app__realtimeOK:boolean;
begin
result:=(system_realtime64>=slowms64);
end;

procedure app__realtime;
var
   bol1:boolean;
begin
//get
bol1:=app__realtimeOK;
system_realtime64:=slowms64+5000;//turn on realtime for 5s
//sync immediately
if not bol1 then
   begin
   system_realtime642:=0;
   app__realtimeSYNC;
   end;
end;

procedure app__realtimeSYNC;//internally called by system procs - 19apr2022
label//Special Note: Realtime mode can only be achivied when program is "Run as Administrator" - 19apr2022
   skipend;
var
   sv,dv:dword;
   st,dt:longint;
begin
try
//check
if system_realtimeSYNCING then exit else system_realtimeSYNCING:=true;
if (system_realtime642>slowms64) then goto skipend else system_realtime642:=slowms64+5000;
//get
sv:=win____getpriorityclass(win____getcurrentprocess);
st:=win____getthreadpriority(win____getcurrentprocess);

if app__realtimeOK then
   begin
   dv:=REALTIME_PRIORITY_CLASS;//process
   dt:=THREAD_PRIORITY_TIME_CRITICAL;//thread
   end
else
   begin
   dv:=NORMAL_PRIORITY_CLASS;
   dt:=THREAD_PRIORITY_NORMAL;
   end;

//set
if (sv<>dv) or (st<>dt) then
   begin
   win____setpriorityclass(win____getcurrentprocess,dv);
   win____setthreadpriority(win____getcurrentprocess,dt);
   end;
skipend:
except;end;
try;system_realtimeSYNCING:=false;except;end;
end;

procedure app__waitms(xms:longint);
begin
if (xms>=1) and app__running then win____sleep(xms);
end;

procedure app__waitsec(xsec:longint);
begin
if (xsec>=1) then app__waitms(xsec*1000);
end;

function app__uptime:comp;
begin
result:=sub64(ms64,system_boot);
end;

function app__uptimegreater(x:comp):boolean;
begin//true when "app__uptime>= x"
result:=(app__uptime>=x);
end;

function app__uptimestr:string;
begin
result:=low__uptime(app__uptime,false,false,true,true,true,#32);
end;

function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__lroot(xname:string):string;//information specific to this unit of code

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

//check -> xname must be "lroot.*"
if not m('lroot.') then exit;

//get
if      (xname='ver')        then result:='1.00.3805'
else if (xname='date')       then result:='12oct2025'
else if (xname='name')       then result:='Root'
else if (xname='mode.int')   then result:=intstr32(info__mode)
else if (xname='mode')       then
   begin
   case info__mode of
   1:result:='Console App';
   2:result:='Windows Service';
   3:result:='GUI App';
   else result:='Unknown';
   end;//case
   end
else
   begin
   //nil
   end;

except;end;
end;

function info__rootfind(xname:string):string;//central point from which to find the requested information - 08aug2025, 09apr2024
var
   v:longint;

   function vbuildno(x:string):longint;//add build number
   var
      p:longint;
   begin
   result:=0;

   if (x<>'') then
      begin
      for p:=low__len(x) downto 1 do if (x[p-1+stroffset]='.') then
         begin
         result:=strint(strcopy1(x,p+1,low__len(x)));
         break;
         end;//p
      end;
   end;
begin
//defaults
result:='';

//get
//.app
if (result='') then
   begin

   if assigned(system_info_app) then result:=system_info_app(xname);

   //.fallback to internal defaults for key values - 08aug2025
//   if (result='') then result:=app__valuedefaults(xname);
   end;

if (result='') then result:=info__lroot(xname);
if (result='') then result:=info__lform(xname);
if (result='') then result:=info__lio(xname);
if (result='') then result:=info__lnet(xname);
if (result='') then result:=info__lwin(xname);
{}

{$ifdef gui2}
if (result='') then result:=info__limg(xname);
{$endif}

{$ifdef snd}
//if (result='') then result:=info__snd(xname);//16jun2025
{$endif}

{$ifdef gui4}
if (result='') then result:=info__lgui(xname);
{$endif}

if (result='') then result:=info__lzip(xname);//05may2025

{$ifdef jpeg}
if (result='') then result:=info__jpg(xname);//05may2025
{$endif}


//global values
if (result='') then
   begin
   //init
   xname:=strlow(xname);

   //get
   if      (xname='mode.int')         then result:=info__rootfind('lroot.'+xname)
   else if (xname='mode')             then result:=info__rootfind('lroot.'+xname)
   else if (xname='legacy.build')     then
      begin
      v:=
      vbuildno(app__info('lroot.ver'))+
      vbuildno(app__info('lio.ver'))+
      vbuildno(app__info('limg.ver'))+
      vbuildno(app__info('lnet.ver'))+
      vbuildno(app__info('lwin.ver'))+
      vbuildno(app__info('lwina.ver'))+//28aug2025
      vbuildno(app__info('lsnd.ver'))+
      vbuildno(app__info('lgui.ver'))+
      vbuildno(app__info('lzip.ver'))+
      vbuildno(app__info('ljpg.ver'))+
      0;
      //set
      result:=intstr64(v);
      end
   else if (xname='codebase.ver')     then result:='1.00.'+app__info('legacy.build')
   else if (xname='codebase')         then result:='Legacy Modernised v'+app__info('codebase.ver');//19oct2025
   end;

end;

function info__mode:longint;
begin

case lroot_runstyle of
rsConsole  :result:=1;
rsService  :result:=2;
rsGUI      :result:=3;
else        result:=0;//unknown
end;//case

end;


//small procs ------------------------------------------------------------------

function small__new8:tstr8;
begin
small__new83(result,'');
end;

function small__new82(const xtext:string):tstr8;
begin
small__new83(result,xtext);
end;

function small__new83(var x:tstr8;const xtext:string):boolean;
var
   p:longint;
begin

//defaults
result :=false;
x      :=nil;

//get
for p:=0 to high(system_small_str8) do if not system_small_use8[p] then
   begin

   //track
   track__inc(satSmall8,1);

   //mark in use
   system_small_use8[p]:=true;

   //init
   if (system_small_str8[p]=nil) then
      begin

      system_small_str8[p]:=str__new8;
      system_small_str8[p].floatsize:=5000;

      //keep locked so no procs close it by mistake
      str__lock(@system_small_str8[p]);

      end;

   //get
   result :=true;
   x      :=system_small_str8[p];

   if (xtext<>'') then x.text:=xtext;

   //stop
   break;

   end;//p

//fallback
if not result then
   begin

   result       :=true;
   x            :=str__new8;
   x.text       :=xtext;
   x.floatsize  :=5000;

   end;

end;

function small__free8(x:pobject):boolean;
var
   p:longint;
begin

//pass-thru
result:=true;

//check
if not str__ok(x) then exit;

//get
for p:=0 to high(system_small_str8) do if (x^=system_small_str8[p]) then
   begin

   //reset
   system_small_str8[p].floatsize:=5000;
   system_small_str8[p].setlen(0);

   //clear caller's pointer
   x^:=nil;

   //mark not in use
   system_small_use8[p]:=false;

   //track
   track__inc(satSmall8,-1);

   //stop
   break;

   end;

//fallback
if str__ok(x) then freeobj(x);

end;


//timing procs -----------------------------------------------------------------

function ms64:comp;//15aug2025
begin

//init
if (system_ms64_divval<=0) then
   begin

   win____QueryPerformanceFrequency(system_ms64_divval);
   if (system_ms64_divval>1000) then system_ms64_divval:=frcmin64(div64(system_ms64_divval,1000),1);

   end;

//get
win____QueryPerformanceCounter(result);
result           :=result/system_ms64_divval;

system_slowms64.ms   :=result;//auto-sync the ms63 timer
system_slowms64.scan :=0;

end;

function ms64str:string;//06NOV2010
begin
result:=floattostrex2(ms64);
end;

function fastms64:comp;
begin
result:=ms64;
end;

function fastms64str:string;
begin
result:=ms64str;
end;

function slowms64:comp;//slower, less demanding version of ms64 - 14sep2025, 31aug2025
begin

if (system_slowms64.ms<=0) then result:=ms64
else
   begin

   inc(system_slowms64.scan);
   if (system_slowms64.scan>=100) then
      begin

      system_slowms64.scan  :=0;
      system_slowms64.ms    :=ms64;

      end;

   result:=system_slowms64.ms;
   end;

end;

function slowms64str:string;//14sep2025
begin
result:=floattostrex2(slowms64);
end;

function ns64:comp;//15aug2025
begin

//init
if (system_ns64_divval<=0) then
   begin

   win____QueryPerformanceFrequency(system_ns64_divval);
   if (system_ns64_divval>1000000) then system_ns64_divval:=frcmin64(div64(system_ns64_divval,1000000),1);

   end;

//get
win____QueryPerformanceCounter(result);
result:=result/system_ns64_divval;

end;

function nowmin:longint;//03mar2022
var
   h,min,sec,ms:word;
begin
result:=0;

try
low__decodetime2(date__now,h,min,sec,ms);//h=0..23, min=0..59
h:=frcrange32(h,0,23);
min:=frcrange32(min,0,59);
result:=frcrange32((h*60)+min,0,1439);
except;end;
end;

function msok(var xref:comp):boolean;
begin
result:=(ms64>=xref);
end;

function msset(var xref:comp;xdelay:comp):boolean;
begin
result:=true;//pass-thru
xref:=add64(ms64,xdelay);
end;

function mswaiting(var xref:comp):boolean;//still valid, the timer is waiting to expire
begin
result:=(xref>=ms64);
end;


//compression procs ------------------------------------------------------------

function low__compress(x:pobject):boolean;
begin
result:=zip__compress(x,true,true);
end;

function low__decompress(x:pobject):boolean;
begin
result:=zip__compress(x,false,true);
end;


//timer procs ------------------------------------------------------------------
function low__timerfound(xowner:tobject;x:tnotifyevent):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//check
if not assigned(x) then exit;
//find
for p:=0 to high(systimer_event) do if (xowner=systimer_owner[p]) and (@x=@systimer_event[p]) then
   begin
   result:=true;
   break;
   end;
except;end;
end;

function low__timerset(xowner:tobject;x:tnotifyevent;xdelay:comp):boolean;
var//Note: accepts "xowner=nil" but beware this timer will not be unique if more than one instance the object etc is used
   pnew,p:longint;
begin
//defaults
result:=false;
pnew:=-1;

try
//check
if not assigned(x) then exit;
//existing
for p:=0 to high(systimer_event) do
begin
if (xowner=systimer_owner[p]) and (@x=@systimer_event[p]) then
   begin
   systimer_delay[p]:=xdelay;
   if (sub64(systimer_ref64[p],slowms64)>xdelay) then systimer_ref64[p]:=slowms64;//fast reset incase last was a long delay - 05may2021
   result:=true;
   break;
   end
else if (pnew<0) and (not assigned(systimer_event[p])) and (not systimer_busy[p]) then pnew:=p;
end;//p
//new
if (not result) and (pnew>=0) then
   begin
   systimer_owner[pnew]:=xowner;//required as "tnotifyevents" on an object are NOT unique between instances of the same object - 19feb2021
   systimer_event[pnew]:=x;
   systimer_delay[pnew]:=xdelay;
   systimer_ref64[pnew]:=slowms64;//fast reset incase last was a long delay
   track__inc(satTimer,1);
   result:=true;
   end;
except;end;
end;

function low__timerdelay(xowner:tobject;x:tnotifyevent;xnewdelay:comp):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//check
if not assigned(x) then exit;
//find
for p:=0 to high(systimer_event) do if (xowner=systimer_owner[p]) and (@x=@systimer_event[p]) then
   begin
   systimer_delay[p]:=xnewdelay;
   if (sub64(systimer_ref64[p],slowms64)>xnewdelay) then systimer_ref64[p]:=slowms64;//fast reset incase last was a long delay - 05may2021
   result:=true;
   break;
   end;
except;end;
end;

function low__timerfinddelay(xowner:tobject;x:tnotifyevent;var xdelay:comp):boolean;
var
   p:longint;
begin
//defaults
result:=false;
xdelay:=0;

try
//check
if not assigned(x) then exit;
//find
for p:=0 to high(systimer_event) do if (xowner=systimer_owner[p]) and (@x=@systimer_event[p]) then
   begin
   xdelay:=systimer_delay[p];
   result:=true;
   break;
   end;
except;end;
end;

function low__timerdel(xowner:tobject;x:tnotifyevent):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//check
if not assigned(x) then exit;
//get
for p:=0 to high(systimer_event) do if (xowner=systimer_owner[p]) and (@x=@systimer_event[p]) then//works even when the timer is currently locked mid-way through firing the "_event()" proc - 19feb2021
   begin
   systimer_owner[p]:=nil;
   systimer_event[p]:=nil;
   systimer_delay[p]:=0;//off
   result:=true;
   track__inc(satTimer,-1);
   break;
   end;//p
except;end;
end;


//date and time procs ----------------------------------------------------------

function low__uptime(x:comp;xforcehr,xforcemin,xforcesec,xshowsec,xshowms:boolean;const xsep:string):string;//28apr2024: changed 'dy' to 'd', 01apr2024: xforcesec, xshowsec/xshowms pos swapped, fixed - 09feb2024, 27dec2021, fixed 10mar2021, 22feb2021, 22jun2018, 03MAY2011, 07SEP2007
begin
result:=low__uptime2(x,xforcehr,xforcemin,xforcesec,xshowsec,xshowms,xsep,'');
end;

function low__uptime2(x:comp;xforcehr,xforcemin,xforcesec,xshowsec,xshowms:boolean;const xsep,xsep2:string):string;//15aug2025
const//Show: days, hours, min, sec - 09feb2024, 03MAY2011
     //Note: x is time in milliseconds
   oneday  =86400000;
   onehour =3600000;
   onemin  =60000;
   onesec  =1000;
var
   dy,h,m,s,ms:comp;
   ok:boolean;
begin
//defaults
result :='';
ok     :=false;
dy     :=0;
h      :=0;
m      :=0;
s      :=0;
ms     :=0;

try
//range
x:=frcrange64(x,0,max64);

//get
if (x>=0) then
   begin
   //.day
   dy:=div64(x,oneday);
   x:=sub64(x,mult64(dy,oneday));
   //.hour
   h:=div64(x,onehour);
   if (h>23) then h:=23;//24feb2021
   x:=sub64(x,mult64(h,onehour));
   //.minute
   m:=div64(x,onemin);
   if (m>59) then m:=59;//24feb2021
   x:=sub64(x,mult64(m,onemin));
   //.second
   s:=div64(x,onesec);
   if (s>59) then s:=59;//24feb2021
   x:=sub64(x,mult64(s,onesec));
   //.ms
   ms:=x;
   if (ms>999) then ms:=999;//24feb2021
   end;

//set
if (dy>=1) or ok then
   begin
   result:=result+insstr(xsep,low__len(result)>=1)+low__digpad20(dy,1)+xsep2+'d';//28apr2024: changed 'dy' to 'd', 02MAY2011
   ok:=true;
   end;
if (h>=1) or ok or xforcehr then
   begin
   result:=result+insstr(xsep,low__len(result)>=1)+low__digpad20(h,2)+xsep2+'h';
   ok:=true;
   end;
if (m>=1) or ok or xforcemin then
   begin
   result:=result+insstr(xsep,low__len(result)>=1)+low__digpad20(m,2)+xsep2+'m';
   ok:=true;
   end;
if (xshowsec or xshowms) and ((s>=1) or ok or xforcesec) then//01apr2024: xforcesec, fixed - 27dec2021
   begin
   result:=result+insstr(xsep,low__len(result)>=1)+low__digpad20(s,2)+xsep2+'s';
   ok:=true;
   end;
if xshowms then//fixed - 27dec2021
   begin
   //enforce range
   result:=result+insstr(xsep,low__len(result)>=1)+low__digpad20(ms,low__insint(3,ok))+xsep2+'ms';
   //ok:=true;
   end;
except;end;
end;

function low__dhmslabel(xms:comp):string;//days hours minutes and seconds from milliseconds - 06feb2023
var
   xok:boolean;
   y:comp;
   v:string;
begin
//defaults
result:='0s';

try
//check
if (xms<0) then exit;
//init
xms:=div64(xms,1000);//ms -> seconds
xok:=false;
v:='';
//get
if xok or (xms>=86400) then
   begin
   y:=div64(xms,86400);
   xms:=sub64(xms,mult64(y,86400));
   xok:=true;
   v:=v+intstr64(y)+'d ';
   end;
if xok or (xms>=3600) then
   begin
   y:=div64(xms,3600);
   xms:=sub64(xms,mult64(y,3600));
   xok:=true;
   v:=v+insstr('0',(y<=9) and (v<>''))+intstr64(y)+'h ';//19may20223
   end;
if xok or (xms>=60) then
   begin
   y:=div64(xms,60);
   xms:=sub64(xms,mult64(y,60));
   //xok:=true;
   v:=v+insstr('0',(y<=9) and (v<>''))+intstr64(y)+'m ';//19may20223
   end;
v:=v+intstr64(xms)+'s';
//set
result:=v;
except;end;
end;

function low__monthdaycount0(xmonth,xyear:longint):longint;
begin//xmonth=0..11 => Jan..Dec
//defaults
result:=31;
//get
case xmonth of
0,2,4,6,7,9,11 :result:=31;//Jan31, Mar31, May31, Jul31, Aug31, Oct31, Dec31
3,5,8,10       :result:=30;//Apr30, Jun30, Sep30, Nov30
1              :result:=low__aorb(28,29,low__leapyear(xyear));//Feb28 but Feb29 on a leap year - 09mar2022
end;
end;

function low__monthdayfilter0(xdayOfmonth,xmonth,xyear:longint):longint;
begin//Note: xdayOfmonth=0..30, xmonth=0..11, xyear=0..N, actual year - e.g. 2022 is really 2022
result:=frcrange32(xdayOfmonth,0,low__monthdaycount0(xmonth,xyear)-1);
end;

function low__year(xmin:longint):longint;
var
   y,m,d:word;
begin
result:=xmin;

try
low__decodedate2(date__now,y,m,d);
if (y>xmin) then result:=y;
except;end;
end;

function low__yearstr(xmin:longint):string;
begin
result:=intstr32(low__year(xmin));
end;

function low__gmt(x:tdatetime):string;//gtm for webservers
var
   y,m,d,hr,min,sec,msec:word;
begin
//get
low__decodedate2(x,y,m,d);
low__decodetime2(x,hr,min,sec,msec);
//set
result:=low__weekday1(low__dayofweek(x),false)+', '+low__digpad11(d,2)+#32+low__month1(m,false)+#32+low__digpad11(y,4)+#32+low__digpad11(hr,2)+':'+low__digpad11(min,2)+':'+low__digpad11(sec,2)+' GMT';
end;

function low__dateinminutes(x:tdatetime):longint;//date in minutes (always >0)
begin//30% faster
result:=round(x*1440);
if (result<1) then result:=1;
end;

function low__dateascode(x:tdatetime):string;//tight as - 17oct2018
var
   h,s,ms,y,min,m,d:word;
begin
//init
low__decodedate2(x,y,m,d);
low__decodetime2(x,h,min,s,ms);
//get
result:=
 low__digpad11(y,4)+low__digpad11(m,2)+low__digpad11(d,2)+
 low__digpad11(h,2)+low__digpad11(min,2)+low__digpad11(s,2)+
 low__digpad11(ms,3);
end;

function low__SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;
begin
with systemtime do result:=low__encodedate2(wYear,wMonth,wDay)+low__encodetime2(wHour,wMinute,wSecond,wMilliSeconds);
end;

procedure low__gmtOFFSET(var h,m,factor:longint);
var//Confirmed using 02-JUL-2005 (all GMT offsets are correct - no summer daylight timings)
   a,b:longint;
   sys:tsystemtime;
begin
try
//defaults
h:=0;
m:=0;
factor:=1;
//get
win____getsystemtime(sys);
a:=low__dateinminutes(date__now);
b:=low__dateinminutes(low__SystemTimeToDateTime(sys));
//calc
a:=a-b;
if (a<0) then
   begin
   a:=-a;
   factor:=-1;
   end
else if (a=0) then factor:=0;
h:=a div 60;
dec(a,h*60);
m:=a;
except;end;
end;

function low__makeetag(x:tdatetime):string;//high speed version - 25dec2023
begin
result:=low__makeetag2(x,'"');
end;

function low__makeetag2(x:tdatetime;xboundary:string):string;//high speed version - 31mar2024, 25dec2023
var
   y,m,d,hr,min,sec,msec:word;
begin
//init
low__decodedate2(x,y,m,d);
low__decodetime2(x,hr,min,sec,msec);
//get
result:=xboundary+intstr32(low__dayofweek(x))+'-'+intstr32(d)+'-'+intstr32(m)+'-'+intstr32(y)+'-'+intstr32(hr)+'-'+intstr32(min)+'-'+intstr32(sec)+'-'+intstr32(msec)+xboundary;
end;

function low__datetimename(x:tdatetime):string;//12feb2023
var
   y,m,d:word;
   h,min,s,ms:word;
begin
//init
low__decodedate2(x,y,m,d);
low__decodetime2(x,h,min,s,ms);
//get
result:=low__digpad11(y,4)+'-'+low__digpad11(m,2)+'-'+low__digpad11(d,2)+'--'+low__digpad11(h,2)+'-'+low__digpad11(min,2)+'-'+low__digpad11(s,2)+'-'+low__digpad11(ms,4);
end;

function low__datename(x:tdatetime):string;
var
   y,m,d:word;
begin
//init
low__decodedate2(x,y,m,d);
//get
result:=low__digpad11(y,4)+'-'+low__digpad11(m,2)+'-'+low__digpad11(d,2);
end;

function low__datetimename2(x:tdatetime):string;//10feb2023
var
   y,m,d:word;
   h,min,s,ms:word;
begin
//init
low__decodedate2(x,y,m,d);
low__decodetime2(x,h,min,s,ms);
//get
result:=low__digpad11(y,4)+low__digpad11(m,2)+low__digpad11(d,2)+'_'+low__digpad11(h,2)+low__digpad11(min,2)+low__digpad11(s,2)+low__digpad11(ms,4);
end;

function low__safedate(x:tdatetime):tdatetime;
begin
result:=x;
if (result<-693593) then result:=-693593 else if (result>9000000) then result:=9000000;
end;

function date__date:tdatetime;
var
   s:tsystemtime;
begin
win____GetLocalTime(s);
with s do result:=date__encodedate(wYear,wMonth,wDay);
end;

function date__time:tdatetime;
var
   s:tsystemtime;
begin
win____GetLocalTime(s);
with s do result:=date__encodetime(wHour,wMinute,wSecond,wMilliSeconds);
end;

function date__now:tdatetime;
begin
result:=date__date+date__time;
end;

function date__filedatetodatetime(xfiledate:longint):tdatetime;
begin
result:=
 date__encodedate( tint4(xfiledate).Hi shr 9 + 1980, tint4(xfiledate).Hi shr 5 and 15, tint4(xfiledate).Hi and 31) +
 date__encodetime( tint4(xfiledate).Lo shr 11      , tint4(xfiledate).Lo shr 5 and 63, tint4(xfiledate).Lo and 31 shl 1, 0);
end;

function date__encodedate(xyear,xmonth,xday:longint):tdatetime;//05may2025
var
   i:longint;
   d:pdaytable;
begin
//defaults
result   :=0;

//range
xyear :=frcrange32(xyear,1,9999);
xmonth:=frcrange32(xmonth,1,12);
d     :=@date__monthdays[date__isleapyear(xyear)];
xday  :=frcrange32(xday,1,d^[xmonth]);

//get
for i:=1 to (xmonth-1) do inc(xday,d^[i]);
i:=xyear-1;//fixed 05may2025
result:=(i*365) + (i div 4) - (i div 100) +(i div 400) + xday - date__datedelta;
end;

procedure date__decodedate(date:tdatetime;var year, month, day:word);
const
   D1   = 365;
   D4   = D1 * 4 + 1;
   D100 = D4 * 25 - 1;
   D400 = D100 * 4 + 1;
var
  y,m,d,i:word;
  t:longint;
  dtable:pdaytable;
begin
t:=date__datetimetotimestamp(date).date;
if (t<=0) then
   begin
   year :=0;
   month:=0;
   day  :=0;
   end
else
   begin
   dec(t);
   y:=1;

   while (t>=d400) do
   begin
   dec(t,d400);
   inc(y,400);
   end;

   low__divmod(t,d100,i,d);
   if (i=4) then
      begin
      dec(i);
      inc(d,d100);
      end;

    inc(y,i*100);

    low__divmod(d,d4,i,d);
    inc(y,i*4);

    low__divmod(d,d1,i,d);

    if (i=4) then
       begin
       dec(i);
       inc(d,d1);
       end;

    inc(y,i);

    dtable:=@date__monthdays[date__isleapyear(y)];

    m:=1;
    while true do
    begin
    i:=dtable^[m];
    if (d<i) then break;
    dec(d,i);
    inc(m);
    end;

    year :=y;
    month:=m;
    day  :=d+1;
    end;//if

end;

function date__encodetime(xhour,xmin,xsec,xmsec:longint):tdatetime;
begin
//defaults
result:=0;

//range
xhour:=frcrange32(xhour,0,23);
xmin :=frcrange32(xmin ,0,59);
xsec :=frcrange32(xsec ,0,59);
xmsec:=frcrange32(xmsec,0,999);

//get
result:=( (xhour*3600000) + (xmin*60000) + (xsec*1000) + xmsec ) / date__msperday;
end;

procedure date__decodetime(time:tdatetime;var hour,min,sec,msec:word);
var
   mincount,mscount:word;
begin
low__divmod(date__datetimetotimestamp(time).time,60000,mincount,mscount);
low__divmod(mincount,60,hour,min);
low__divmod(mscount,1000,sec,msec);
end;

function date__dayofweek(date:tdatetime):longint;
begin
result:=date__datetimetotimestamp(date).date mod 7 + 1;
end;

function date__datetimetotimestamp(datetime:tdatetime):ttimestamp;
asm
        MOV     ECX,EAX
        FLD     datetime
        FMUL    date__FMSecsPerDay
        SUB     ESP,8
        FISTP   QWORD PTR [ESP]
        FWAIT
        POP     EAX
        POP     EDX
        OR      EDX,EDX
        JNS     @@1
        NEG     EDX
        NEG     EAX
        SBB     EDX,0
        DIV     date__IMSecsPerDay
        NEG     EAX
        JMP     @@2
@@1:    DIV     date__IMSecsPerDay
@@2:    ADD     EAX,date__DateDelta
        MOV     [ECX].TTimeStamp.Time,EDX
        MOV     [ECX].TTimeStamp.Date,EAX
end;

function date__timestamptodatetime(const timestamp: ttimestamp):tdatetime;
asm
        MOV     ECX,[EAX].TTimeStamp.Time
        MOV     EAX,[EAX].TTimeStamp.Date
        SUB     EAX,date__DateDelta
        IMUL    date__IMSecsPerDay
        OR      EDX,EDX
        JNS     @@1
        SUB     EAX,ECX
        SBB     EDX,0
        JMP     @@2
@@1:    ADD     EAX,ECX
        ADC     EDX,0
@@2:    PUSH    EDX
        PUSH    EAX
        FILD    QWORD PTR [ESP]
        FDIV    date__FMSecsPerDay
        ADD     ESP,8
end;

function date__isleapyear(year:word):boolean;
begin
result := (year mod 4 = 0) and ((year mod 100 <> 0) or (year mod 400 = 0));
end;

procedure low__decodedate2(x:tdatetime;var y,m,d:word);//safe range
begin
date__decodedate(low__safedate(x),y,m,d);
end;

procedure low__decodetime2(x:tdatetime;var h,min,s,ms:word);//safe range
begin
date__decodetime(low__safedate(x),h,min,s,ms);
end;

function low__encodedate2(y,m,d:word):tdatetime;
begin
result:=date__encodedate(y,m,d);
end;

function low__encodetime2(h,min,s,ms:word):tdatetime;
begin
result:=date__encodetime(h,min,s,ms);
end;

function low__dayofweek(x:tdatetime):longint;//01feb2024
begin
result:=date__dayofweek(low__safedate(x));
end;

function low__dayofweek1(x:tdatetime):longint;
begin
result:=frcrange32(low__dayofweek(x),1,7);
end;

function low__dayofweek0(x:tdatetime):longint;
begin
result:=frcrange32(low__dayofweek(x)-1,0,6);
end;

function low__dayofweekstr(x:tdatetime;xfullname:boolean):string;
begin
result:=low__weekday1(low__dayofweek1(x),xfullname);
end;

function low__month1(x:longint;xfullname:boolean):string;//08mar2022
begin
result:=low__month0(x-1,xfullname);
end;

function low__month0(x:longint;xfullname:boolean):string;//08mar2022
begin//note: x=1..12
x:=frcrange32(x,0,11);

case xfullname of
true:result:=system_month[x+1];
else result:=system_month_abrv[x+1];
end;
end;

function low__weekday1(x:longint;xfullname:boolean):string;//08mar2022
begin//note: x=1..7
result:=low__weekday0(x-1,xfullname);
end;

function low__weekday0(x:longint;xfullname:boolean):string;//08mar2022
begin
x:=frcrange32(x,0,11);

case xfullname of
true:result:=system_dayOfweek[x+1];
else result:=system_dayOfweek_abrv[x+1];//0..11 -> 1..12
end;
end;

function low__leapyear(xyear:longint):boolean;
begin//Note: leap years are: 2024, 2028 and 2032 - when Feb has 29 days instead of the usual 28 days
result:=(xyear=((xyear div 4)*4));
end;

function low__datetoday(x:tdatetime):longint;
const
   dim:array[1..12] of byte=(31,28,31,30,31,30,31,31,30,31,30,31);
var
   y,m,d:word;
   dy,dm:longint;
begin
//defaults
result:=0;

try
//init
low__decodedate2(x,y,m,d);//1 based
//range
y:=frcrange32(y,0,9999);
m:=frcrange32(m,low(dim),high(dim));
//get
for dy:=0 to y do
begin
for dm:=1 to 12 do
begin
if (dy=y) and (dm>=m) then break;
inc(result,dim[dm]);
if (dm=2) and low__leapyear(dy) then inc(result);
end;//dm
end;//dy
//day
inc(result,d);
except;end;
end;

function low__datetosec(x:tdatetime):comp;
const
   dmin=60;
   dhour=3600;
   dday=24*dhour;
var
   h,m,s,ms:word;
begin
//defaults
result:=0;

try
//init
low__decodetime2(x,h,m,s,ms);
//days
result:=mult64(low__datetoday(x),dday);
//time
result:=add64( add64( mult64(frcmin32(h-1,0),dhour) , mult64(frcmin32(m-1,0),dmin) ) ,s);
except;end;
end;

function low__datestr(xdate:tdatetime;xformat:longint;xfullname:boolean):string;//09mar2022
var
   y,m,d:word;
begin
//init
low__decodedate2(xdate,y,m,d);
//get
result:=low__date1(y,m,d,xformat,xfullname);
end;

function low__date1(xyear,xmonth1,xday1:longint;xformat:longint;xfullname:boolean):string;
begin
result:=low__date0(xyear,xmonth1-1,xday1-1,xformat,xfullname);
end;

function low__date0(xyear,xmonth,xday:longint;xformat:longint;xfullname:boolean):string;//03sep2025
var
   xmonthstr,xth:string;
begin

//range
xday       :=1+frcrange32(xday,0,30);
xmonth     :=1+frcrange32(xmonth,0,11);
xmonthstr  :=low__month1(xmonth,xfullname);

//init
case xday of
1,21,31:xth:='st';
2,22:xth:='nd';
3,23:xth:='rd';
else xth:='th';
end;

//get
case frcrange32(xformat,0,4) of
1:result:=low__digpad11(xday,1)+xth+#32+xmonthstr+insstr(#32+low__digpad11(xyear,4),xyear>=0);
2:result:=xmonthstr+#32+low__digpad11(xday,1)+insstr(', '+low__digpad11(xyear,4),xyear>=0);
3:result:=xmonthstr+#32+low__digpad11(xday,1)+xth+insstr(', '+low__digpad11(xyear,4),xyear>=0);
4:result:=low__digpad11(xday,2)+#32+xmonthstr+insstr(#32+low__digpad11(xyear,4),xyear>=0);//03sep2025
else result:=low__digpad11(xday,1)+#32+xmonthstr+insstr(#32+low__digpad11(xyear,4),xyear>=0);
end;//case

end;

function low__timestr(xdate:tdatetime;xformat:longint):string;//29sep2025
var
   h,m,s,ms:word;
begin

//init
low__decodetime2(xdate,h,m,s,ms);

//get
case xformat of
0   :result:=low__time0(h,m,':',#32,true,false);
else result:=low__time0(h,m,':',#32,true,false);
end;//case

end;

function low__time0(xhour,xminute:longint;xsep,xsep2:string;xuppercase,xshow24:boolean):string;
var
   dPM:boolean;
   xampm:string;
begin
//defaults
result:='';

try
//range
xhour:=frcrange32(xhour,0,23);
xminute:=frcrange32(xminute,0,59);
xsep:=strdefb(xsep,':');
xsep2:=strdefb(xsep2,#32);
//get
case xshow24 of
true:result:=low__digpad11(xhour,2)+xsep+low__digpad11(xminute,2);
else begin
   //get
   dPM:=(xhour>=12);
   case xhour of
   13..23:dec(xhour,12);
   24:xhour:=12;//never used - 28feb2022
   0:xhour:=12;//"0:00" -> "12:00am"
   end;
   xampm:=low__aorbstr('am','pm',dPM);
   if xuppercase then xampm:=strup(xampm);
   //set
   result:=low__digpad11(xhour,1)+xsep+low__digpad11(xminute,2)+xsep2+xampm;
   end;
end;//case
except;end;
end;

function low__hour0(xhour:longint;xsep:string;xuppercase,xshowAMPM,xshow24:boolean):string;
var
   dPM:boolean;
   xampm:string;
begin
//defaults
result:='';

try
//range
xhour:=frcrange32(xhour,0,23);
xsep:=strdefb(xsep,#32);
//get
case xshow24 of
true:result:=low__digpad11(xhour,2);
else begin
   //get
   dPM:=(xhour>=12);
   case xhour of
   13..23:dec(xhour,12);
   24:xhour:=12;//never used - 28feb2022
   0:xhour:=12;//"0:00" -> "12:00am"
   end;
   if xshowAMPM then
      begin
      xampm:=low__aorbstr('am','pm',dPM);
      if xuppercase then xampm:=strup(xampm);
      end
   else xampm:='';
   //set
   result:=low__digpad11(xhour,1)+insstr(xsep+xampm,xshowAMPM);
   end;
end;//case
except;end;
end;


//track procs ------------------------------------------------------------------

function pok(x:pobject):boolean;//06feb2024
begin
result:=(x<>nil) and (x^<>nil);
end;

procedure track__inc(xindex,xcreate:longint);
begin

//nil

end;

procedure zzadd(x:tobject);
begin
//nil
end;

function zzfind(x:tobject;var xindex:longint):boolean;
begin
result:=false;
xindex:=0;
end;

procedure zzdel(x:tobject);
begin
//nil
end;

function zzok(x:tobject;xid:longint):boolean;
begin
result:=(x<>nil);
if result then zzobj2(x,-1,xid);
end;

function zzok2(x:tobject):boolean;
begin
result:=(x<>nil);
end;

function zznil(x:tobject;xid:longint):boolean;
begin
result:=(x=nil);
if not result then zzobj2(x,-1,xid);
end;

function zznil2(x:tobject):boolean;//12feb202
begin
result:=(x=nil);
end;

function zzimg(x:tobject):boolean;//12feb2202
begin
result:=(x<>nil);// and (x is tbasicimage);
end;

function zzobj(x:tobject;xid:longint):tobject;
begin
result:=zzobj2(x,-1,xid);
end;

function zzobj2(x:tobject;xsatlabel,xid:longint):tobject;
begin
result:=x;
end;

function zzvars(x:tvars8;xid:longint):tvars8;
begin
result:=x;
//zzobj2(x,satVars8,xid);
end;

function zzstr(x:tstr8;xid:longint):tstr8;
begin
result:=x;
//zzobj2(x,satStr8,xid);
end;


//## tobjectex #################################################################
constructor tobjectex.create;
begin
__cacheptr:=nil;
if classnameis('tobjectex') then track__inc(satObjectex,1);
zzadd(self);
inherited create;
end;

destructor tobjectex.destroy;
begin
inherited destroy;
if classnameis('tobjectex') then track__inc(satObjectex,-1);
//note: zzdel() is fired during "freeobj()" - 04may2021
end;


//## twproc ####################################################################
function wproc__windowproc(h:tbasic_handle;m:tbasic_message;w:tbasic_wparam;l:tbasic_lparam):lresult; stdcall;//07jul2025, 17jun2025
label
   skipend;
var
   p:longint;
   xok:boolean;
begin

//defaults
result:=0;


try
//track the number of inbound messages
if (system_message_count<max32) then inc(system_message_count) else system_message_count:=0;


//--------------------------------------------------------------------------------
//-- system messages -------------------------------------------------------------

//permit these message links even while app is shutting down - 07jul2025
case m of
MM_WOM_DONE:if assigned(systemmessage__mm_wom_done) then result:=systemmessage__mm_wom_done(m,w,l);
end;

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------


//check
if lroot_mustclose and lroot_canclose then exit;//it must be assumed the app has already destroyed it's core support structure, e.g. vars/object and references

//decide
if      (m=wm_onmessage_net)    and system_net_session then result:=net__onmessage(m,w,l)
else if (m=wm_onmessage_nn)     and system_net_session then
   begin

   if assigned(systemmessage__nn) then result:=systemmessage__nn(m,w,l);

   end

else if (m=wm_onmessage_netraw) and system_net_session then result:=net__onraw(m,w,l)//04apr2025
{$ifdef snd}//17jun2025
else if (m=wm_onmessage_mm)                    then result:=snd__onmessage_mm(m,w,l)
else if (m=wm_onmessage_wave)                  then result:=snd__onmessage_wave(m,w,l)
{$endif}

else
   begin

   //init
   xok:=true;

   //detect changes in monitor settings and setup - 18feb2025: updated to include "WM_SETTINGCHANGE"
   if (m=WM_DISPLAYCHANGE) or (m=WM_SETTINGCHANGE) then monitors__sync;

   //pass message onto subsystem
   if (h<>0) then for p:=0 to high(system_formlist) do if (h=system_formlist[p]) then
      begin

      //pass message and control over to form.wndproc handler
      if assigned(system_formlist_wndproc[p]) then
         begin

         result :=system_formlist_wndproc[p](h,m,w,l);
         xok    :=false;

         end;

      //stop
      break;

      end;

   //fallback proc
   if xok then result:=win____defwindowproc(h,m,w,l);

   end;

skipend:
except;end;
end;

constructor twproc.create;
const
   xclassname='wproc';//22dec2023
var
   a:twndclass;
begin
try
//self
if classnameis('twproc') then track__inc(satWproc,1);
zzadd(self);
inherited create;
//make class
with a do
begin
style           :=0;
lpfnWndProc     :=@wproc__windowproc;
cbClsExtra      :=0;
cbWndExtra      :=0;
hInstance       :=0;
hIcon           :=0;
hCursor         :=0;
hbrBackground   :=0;
lpszMenuName    :=nil;
lpszClassName   :=pchar(xclassname);
end;
//register class
win____registerclassa(a);
//make window
iwindow:=win____createwindow(pchar(xclassname),'',0,0,0,0,0,0,0,hinstance,nil);
except;end;
end;

destructor twproc.destroy;
begin
try
win____destroywindow(iwindow);
iwindow:=0;
inherited destroy;
if classnameis('twproc') then track__inc(satWproc,-1);
except;end;
end;


//## tintlist ##################################################################
constructor tintlist.create;
begin
if classnameis('tintlist') then track__inc(satIntlist,1);
inherited create;
iblocksize:=block__size;
irootlimit:=iblocksize div 4;//stores pointers to memory blocks
iblocklimit:=iblocksize div 4;//stores list of longint's (4 bytes each) in memory blocks
ilimit:=restrict32(mult64(irootlimit,iblocklimit));
icount:=0;
irootcount:=0;
iroot:=nil;
igetmin:=-1;
igetmax:=-2;
isetmin:=-1;
isetmax:=-2;
end;

destructor tintlist.destroy;
begin
try
clear;
inherited destroy;
if classnameis('tintlist') then track__inc(satIntlist,-1);
except;end;
end;

function tintlist.mem:longint;
begin
if (iroot<>nil) then result:=(irootcount+1)*iblocksize else result:=0;
end;

function tintlist.mem_predict(xcount:comp):comp;
var
   xrootcount:comp;
begin
if (xcount<=0) then xrootcount:=0 else xrootcount:=add64(div64(xcount,irootlimit),1);
result:=mult64(add64(xrootcount,1),iblocksize);
end;

procedure tintlist.clear;
begin
setcount(0);
end;

function tintlist.mincount(xcount:longint):boolean;//fixed 20feb2024
begin
if (xcount>icount) then setcount(xcount);
result:=(xcount<=icount);
end;

procedure tintlist.setcount(x:longint);
label
   skipend;
var
   a:pointer;
   p,xnewrootcount,xoldrootcount,xnewcount,xoldcount:longint;

   function xblockcount(xcount:longint):longint;
   begin
   if (xcount<=0) then result:=0 else result:=(xcount div irootlimit)+1;
   end;
begin
//range
xoldcount:=icount;
xnewcount:=frcrange32(x,0,ilimit);

//check
if (xnewcount=xoldcount) then exit;

//reset cache vars
igetmin:=-1;
igetmax:=-2;
isetmin:=-1;
isetmax:=-2;

//init
xoldrootcount:=irootcount;
xnewrootcount:=xblockcount(xnewcount);

try
//check 2
if (xnewrootcount=xoldrootcount) then goto skipend;//already done -> just need to update the icount var

//enlarge
if (xnewrootcount>xoldrootcount) and (xnewrootcount>=1) then
   begin
   //root
   if (iroot=nil) then
      begin
      iroot:=block__new;
      block__cls(iroot);
      end;

   //root slots
   for p:=frcmin32(xoldrootcount-1,0) to (xnewrootcount-1) do if (iroot[p]=nil) then
      begin
      a:=block__new;
      if (a<>nil) then
         begin
         block__cls(a);
         iroot[p]:=a;
         end;
      end;
   end

//shrink
else if (xnewrootcount<xoldrootcount) and (xoldrootcount>=1) then
   begin
   //root slots
   if (iroot<>nil) then
      begin
      for p:=(xoldrootcount-1) downto frcmin32(xnewrootcount-1,0) do if (iroot[p]<>nil) then block__free(iroot[p]);
      end;

   //root
   if (xnewcount<=0) then
      begin
      a:=iroot;
      iroot:=nil;//set to nil before freeing memory
      block__freeb(a);
      end;
   end;

skipend:
except;end;
try
//set
irootcount:=xnewrootcount;
icount:=xnewcount;
except;end;
end;

function tintlist.fastinfo(xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;//15feb2024
var
   xrootindex:longint;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;

try
//get
if (xpos>=0) and (xpos<icount) and (iroot<>nil) then
   begin
   xrootindex:=xpos div irootlimit;
   xmem:=iroot[xrootindex];
   if (xmem<>nil) then
      begin
      xmin:=xrootindex*iblocklimit;
      xmax:=((xrootindex+1)*iblocklimit)-1;
      //.limit max for last block using datastream length - 15feb2024
      if (xmax>=icount) then xmax:=icount-1;
      //successful
      result:=(xmem<>nil);
      end;
   end;
except;end;
end;

function tintlist.getvalue(x:longint):longint;
begin
result:=0;
if (x>=igetmin) and (x<=igetmax)                                      then result:=pdllongint(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdllongint(igetmem)[x-igetmin];
end;

procedure tintlist.setvalue(x:longint;xval:longint);
begin
if (x>=isetmin) and (x<=isetmax) then pdllongint(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdllongint(isetmem)[x-isetmin]:=xval;
   end;
end;

function tintlist.getptr(x:longint):pointer;
begin
if (x>=igetmin) and (x<=igetmax)                                      then result:=pdlpointer(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdlpointer(igetmem)[x-igetmin]
else                                                                       result:=nil;
end;

procedure tintlist.setptr(x:longint;xval:pointer);
begin
if (x>=isetmin) and (x<=isetmax) then pdlpointer(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdlpointer(isetmem)[x-isetmin]:=xval;
   end;
end;


//## tcmplist ##################################################################
constructor tcmplist.create;
begin
if classnameis('tcmplist') then track__inc(satCmplist,1);
inherited create;
iblocksize:=block__size;
irootlimit:=iblocksize div 4;//stores pointers to memory blocks
iblocklimit:=iblocksize div 8;//stores list of comp's (8 bytes each) in memory blocks
ilimit:=restrict32(mult64(irootlimit,iblocklimit));
icount:=0;
irootcount:=0;
iroot:=nil;
igetmin:=-1;
igetmax:=-2;
isetmin:=-1;
isetmax:=-2;
end;

destructor tcmplist.destroy;
begin
try
clear;
inherited destroy;
if classnameis('tcmplist') then track__inc(satCmplist,-1);
except;end;
end;

function tcmplist.mem:longint;
begin
if (iroot<>nil) then result:=(irootcount+1)*iblocksize else result:=0;
end;

procedure tcmplist.clear;
begin
setcount(0);
end;

function tcmplist.mincount(xcount:longint):boolean;//fixed 20feb2024
begin
if (xcount>icount) then setcount(xcount);
result:=(xcount<=icount);
end;

procedure tcmplist.setcount(x:longint);
label
   skipend;
var
   p,xrootcount,xcount:longint;
begin
//range
xcount:=frcrange32(x,0,ilimit);
xrootcount:=irootcount;

try
//check
//.count
if (xcount=icount) then exit;

//.rootcount
xrootcount:=xcount div iblocklimit;//18jun2025: fixed, was irootlimit
if (xcount>(xrootcount*iblocklimit)) then xrootcount:=frcrange32(xrootcount+1,0,irootlimit);
if (irootcount=xrootcount) then goto skipend;

//.reset fastinfo vars
igetmin:=-1;
igetmax:=-2;
isetmin:=-1;
isetmax:=-2;

//get
if (xrootcount>irootcount) then
   begin

   //root
   if (iroot=nil) then
      begin
      iroot:=block__new;
      low__cls(iroot,iblocksize);
      end;

   //slots
   for p:=irootcount to (xrootcount-1) do if (iroot[p]=nil) then
      begin
      iroot[p]:=block__new;;
      block__cls(iroot[p]);
      end;

   end
else if (xrootcount<irootcount) then
   begin

   //root
   if (iroot=nil) then goto skipend;

   //slots
   for p:=(irootcount-1) downto xrootcount do if (iroot[p]<>nil) then block__free(iroot[p]);

   //root
   if (xcount<=0) then
      begin
      block__freeb(iroot);
      iroot:=nil;
      end;

   end;

skipend:
except;end;
try
//set
irootcount:=xrootcount;
icount:=xcount;
except;end;
end;

function tcmplist.fastinfo(xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;//18jun2025, 15feb2024
var
   xrootindex:longint;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;

//get
if (xpos>=0) and (xpos<icount) and (iroot<>nil) then
   begin
   xrootindex:=xpos div iblocklimit;//18jun2025: fixed, was irootlimit
   xmem:=iroot[xrootindex];

   if (xmem<>nil) then
      begin
      xmin:=xrootindex*iblocklimit;
      xmax:=xmin + (iblocklimit-1);

      //.limit max for last block using datastream length - 15feb2024
      if (xmax>=icount) then xmax:=icount-1;

      //successful
      result:=true;
      end;
   end;

end;

function tcmplist.getvalue(x:longint):comp;
begin
if (x>=igetmin) and (x<=igetmax)                                                       then result:=pdlcomp(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and (iroot<>nil) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdlcomp(igetmem)[x-igetmin]
else                                                                                        result:=0;
end;

procedure tcmplist.setvalue(x:longint;xval:comp);
begin
if (x>=isetmin) and (x<=isetmax) then pdlcomp(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdlcomp(isetmem)[x-isetmin]:=xval;
   end;
end;

function tcmplist.getdbl(x:longint):double;
begin
if (x>=igetmin) and (x<=igetmax)                                                       then result:=pdldouble(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and (iroot<>nil) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdldouble(igetmem)[x-igetmin]
else                                                                                        result:=0;
end;

procedure tcmplist.setdbl(x:longint;xval:double);
begin
if (x>=isetmin) and (x<=isetmax) then pdldouble(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdldouble(isetmem)[x-isetmin]:=xval;
   end;
end;

function tcmplist.getdate(x:longint):tdatetime;
begin
if (x>=igetmin) and (x<=igetmax)                                                       then result:=pdldatetime(igetmem)[x-igetmin]
else if (x>=0) and (x<icount) and (iroot<>nil) and fastinfo(x,igetmem,igetmin,igetmax) then result:=pdldatetime(igetmem)[x-igetmin]
else                                                                                        result:=0;
end;

procedure tcmplist.setdate(x:longint;xval:tdatetime);
begin
if (x>=isetmin) and (x<=isetmax) then pdldatetime(isetmem)[x-isetmin]:=xval
else if (x>=0) and (x<ilimit) then
   begin
   if (x>=icount) then setcount(x+1);
   if fastinfo(x,isetmem,isetmin,isetmax) then pdldatetime(isetmem)[x-isetmin]:=xval;
   end;
end;


//## tstr8 #####################################################################
constructor tstr8.create(xlen:longint);
begin
if classnameis('tstr8') then track__inc(satStr8,1);
inherited create;
otestlock1 :=false;
oautofree  :=false;
ifloatsize :=0;
ilockcount :=0;
iownmemory :=true;
iglobal    :=false;
idata      :=nil;
idatalen   :=0;
icount     :=0;
ibytes     :=idata;
ichars     :=idata;
iints4     :=idata;
irows8     :=idata;
irows15    :=idata;
irows16    :=idata;
irows24    :=idata;
irows32    :=idata;
tag1       :=0;
tag2       :=0;
tag3       :=0;
tag4       :=0;
seekpos    :=0;
xresize(xlen,true);
end;

destructor tstr8.destroy;
begin
try
//free
if iownmemory then
   begin
   case iglobal of
   true:global__free(idata);
   else mem__free(idata);//26aug2025
   end;//case
   end;

inherited destroy;
if classnameis('tstr8') then track__inc(satStr8,-1);
except;end;
end;

function tstr8.splice(xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;//25feb2024
begin
//defaults
result:=false;
xoutmem:=nil;
xoutlen:=0;

//check
if (xpos<0) or (xpos>=icount) or (xlen<=0) or (idata=nil) then exit;

//get
xoutmem:=ptr__shift(idata,xpos);
xoutlen:=icount-xpos;
if (xoutlen>xlen) then xoutlen:=xlen;
//successful
result:=(xoutmem<>nil) and (xoutlen>=1);
end;

function tstr8.copyfrom(s:tstr8):boolean;//09feb2022
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
if (s=nil) or (not str__lock(@s)) then exit;
//clear
clear;
//get
oautofree:=s.oautofree;
otestlock1:=s.otestlock1;
add(s);
except;end;
try;str__uaf(@s);except;end;
end;

function tstr8.maplist:tlistptr;//26apr2021, 07apr2021
begin
result.count:=len;
result.bytes:=idata;
//was: result.bytes:=@idata^;
//was: result.bytes:=idata;
//was: result.bytes:=@core^;
//was: result.bytes:=core;//<-- Not sure if this caused the intermittent CRASHING of Gossamer, duplicate fix at "low__maplist2"
end;

procedure tstr8.lock;
begin
inc(ilockcount);
end;

procedure tstr8.unlock;
begin
ilockcount:=frcmin32(ilockcount-1,0);
end;

function tstr8.writeto1(a:pointer;asize,xfrom1,xlen:longint):boolean;
begin
result:=writeto(a,asize,xfrom1-1,xlen);
end;

function tstr8.writeto1b(a:pointer;asize:longint;var xfrom1:longint;xlen:longint):boolean;
begin
xlen:=frcrange32(xlen,0,frcmin32(asize,0));//fixed - 22may2022
result:=writeto(a,asize,xfrom1-1,xlen);
if result then inc(xfrom1,xlen)
end;

function tstr8.writeto(a:pointer;asize,xfrom0,xlen:longint):boolean;//28jul2021
var
   sp,slen,p:longint;
   b:pdlBYTE;
   v:byte;
begin
//defaults
result:=false;

try
//check
if not iownmemory then exit;
if (a=nil) then exit;

//init
slen:=len;//our length
fillchar(a^,asize,0);
b:=a;
xlen:=frcmax32(xlen,asize);
if (xlen<=0) then
   begin
   result:=true;
   exit;
   end;

//get
sp:=xfrom0;
for p:=0 to (xlen-1) do
begin
if (sp>=0) then
   begin
   //was: if (sp<slen) then b[p]:=pbytes[sp] else break;
   //faster - 22apr2022
   if (sp<slen) then
      begin
      v:=pbytes[sp];
      b[p]:=v;
      end
   else break;
   end;
inc(sp);
end;

//successful
result:=true;
except;end;
end;

procedure tstr8.setfloatsize(x:longint);//29aug2025
begin//0..100 Mb
ifloatsize:=frcrange32(x,0,100000000);
end;

procedure tstr8.setbdata(x:tstr8);//27apr2021
begin
clear;
add(x);
end;

procedure tstr8.setbappend(x:tstr8);//27apr2021
begin
add(x);
end;

function tstr8.getbdata:tstr8;//27apr2021, 28jan2021
begin
result:=str__new8;
if (result<>nil) then
   begin
   result.add(self);
   result.oautofree:=true;
   end;
end;

function tstr8.datpush(n:longint;x:tstr8):boolean;//27jun2022
begin
addint4(n);
if str__lock(@x) then result:=addint4(x.len) and add(x) else result:=addint4(0);
str__uaf(@x);
end;

function tstr8.datpull(var xpos,n:longint;x:tstr8):boolean;//27jun2022
label
   skipend;
var
   int1,xlen:longint;
begin
//defaults
result:=false;

try
n:=-1;
//range
if (xpos<0) then xpos:=0;
//check
if str__lock(@x) then x.clear;
if ((xpos+7)>=icount) then goto skipend;
//get
n   :=int4[xpos]; inc(xpos,4);
xlen:=int4[xpos]; inc(xpos,4);
int1:=xpos;
inc(xpos,xlen);//inc over data EVEN if an error occurs - 27jun2022
//.read data
if (xlen>=1) and (x<>nil) then x.add3(self,int1,xlen);
//successful
result:=true;
skipend:
except;end;
try;str__unlockautofree(@x);except;end;
end;

function tstr8.empty:boolean;
begin
result:=(icount<=0);
end;

function tstr8.notempty:boolean;
begin
result:=(icount>=1);
end;

function tstr8.uppercase:boolean;
begin
result:=uppercase1(1,len);
end;

function tstr8.uppercase1(xpos1,xlen:longint):boolean;
var
   p:longint;
begin
//defaults
result:=false;

//check
if not iownmemory then exit;

try
xlen:=frcmax32(xlen,len);
//get
if (xpos1>=1) and (xpos1<=xlen) and (xlen>=1) and (ibytes<>nil) then
   begin
   for p:=xpos1 to xlen do if (ibytes[p-1]>=97) and (ibytes[p-1]<=122) then
      begin
      ibytes[p-1]:=byte(ibytes[p-1]-32);
      result:=true;
      end;//p
   end;
except;end;
end;

function tstr8.lowercase:boolean;
begin
result:=lowercase1(1,len);
end;

function tstr8.lowercase1(xpos1,xlen:longint):boolean;
var
   p:longint;
begin
//defaults
result:=false;

//check
if not iownmemory then exit;

try
xlen:=frcmax32(xlen,len);
//get
if (xpos1>=1) and (xpos1<=xlen) and (xlen>=1) and (ibytes<>nil) then
   begin
   for p:=xpos1 to xlen do if (ibytes[p-1]>=65) and (ibytes[p-1]<=90) then
      begin
      ibytes[p-1]:=byte(ibytes[p-1]+32);
      result:=true;
      end;//p
   end;
except;end;
end;

function tstr8.swap(s:tstr8):boolean;//27dec2021
var
   t:tstr8;
begin
//defaults
result:=false;

//check
if (not iownmemory) or ( (s=nil) or (not s.ownmemory) ) then exit;

try
t:=nil;
//check
if not str__lock(@s) then exit;
//init
t:=str__new8;
//self -> t
t.add(self);
//s -> self
clear;
add(s);
//t -> s
s.clear;
s.add(t);
//successful
result:=true;
except;end;
try;str__uaf(@s);except;end;
end;

function tstr8.same(var x:tstr8):boolean;
begin
result:=same2(0,x);
end;

function tstr8.same2(xfrom:longint;var x:tstr8):boolean;
label
   skipend;
var
   i,p:longint;
begin
//defaults
result:=false;

try
//check
if (x=idata) then
   begin
   result:=true;
   exit;
   end;
//get
if str__lock(@x) then
   begin
   //init
   if (xfrom<0) then xfrom:=0;
   //get
   if (x.count>=1) and (x.pbytes<>nil) then
      begin
      //check
      if (ibytes=nil) then goto skipend;
      //get
      for p:=0 to (x.count-1) do
      begin
      i:=xfrom+p;
      if (i>=icount) or (ibytes[i]<>x.pbytes[p]) then goto skipend;
      end;//p
      end;
   //successful
   result:=true;
   end;
skipend:
except;end;
//free
str__uaf(@x);
end;

function tstr8.asame(const x:array of byte):boolean;
begin
result:=asame3(0,x,true);
end;

function tstr8.asame2(xfrom:longint;const x:array of byte):boolean;
begin
result:=asame3(xfrom,x,true);
end;

function tstr8.asame3(xfrom:longint;const x:array of byte;xcasesensitive:boolean):boolean;
begin
result:=asame4(xfrom,low(x),high(x),x,xcasesensitive);
end;

function tstr8.asame4(xfrom,xmin,xmax:longint;const x:array of byte;xcasesensitive:boolean):boolean;
label
   skipend;
var
   i,p:longint;
   sv,v:byte;
begin
//defaults
result:=false;

try
//check
if (sizeof(x)=0) or (ibytes=nil) then exit;
//range
if (xfrom<0) then xfrom:=0;
//init
xmin:=frcrange32(xmin,low(x),high(x));
xmax:=frcrange32(xmax,low(x),high(x));
if (xmin>xmax) then exit;
//get
for p:=xmin to xmax do
begin
i:=xfrom+(p-xmin);
if (i>=icount) or (i<0) then goto skipend//22aug2020
else if xcasesensitive and (x[p]<>ibytes[i]) then goto skipend
else
   begin
   sv:=x[p];
   v:=ibytes[i];
   if (sv>=65) and (sv<=90) then inc(sv,32);
   if (v>=65)  and (v<=90)  then inc(v,32);
   if (sv<>v) then goto skipend;
   end;
end;//p
//successful
result:=true;
skipend:
except;end;
end;

function tstr8.gethandle:hglobal;//19may2025: fixed reference to "nil"
begin
if iglobal and (idata<>nil) then result:=win____GlobalHandle(idata) else result:=0;
end;

function tstr8.makelocal:boolean;
begin
result:=true;//pass-thru

//free previous
setlen(0);
ejectcore;

//get
iownmemory :=true;
iglobal    :=false;
xsyncvars;
end;

function tstr8.makeglobal:boolean;
begin
result:=true;//pass-thru

//free previous
ifloatsize:=0;//01sep2025
setlen(0);
ejectcore;

//get
iownmemory :=true;
iglobal    :=true;
xsyncvars;
end;

function tstr8.makeglobalFROM(xmem:hglobal;xownmemory:boolean):boolean;
begin
result:=true;//pass-thru

//free previous
setlen(0);
ejectcore;

//get
iownmemory :=xownmemory;
iglobal    :=true;
if (xmem<>0)    then idata:=win____GlobalLock(xmem)              else idata:=nil;//get pointer to memory block
if (idata<>nil) then idatalen:=restrict32( global__size(idata) ) else idatalen:=0;
icount     :=idatalen;
xsyncvars;

//track
if iownmemory then system_memory_bytes:=add64(system_memory_bytes,idatalen);
end;

function tstr8.ejectcore:boolean;
begin

//pass-thru
result:=true;

//track
if iownmemory then system_memory_bytes:=sub64(system_memory_bytes,idatalen);

//disown
if iglobal and (handle<>0) then win____GlobalUnlock(handle);//unlock global memory

iownmemory:=true;
idata     :=nil;
idatalen  :=0;
icount    :=0;
xsyncvars;

end;

function tstr8.xresize(x:longint;xsetcount:boolean):boolean;//29aug2025
var
   int1,dnew,xnew,xold:longint;
begin
//defaults
result:=false;

//check
if not iownmemory then exit;

try
//init
xold         :=frcrange32(idatalen,0,max32);
xnew         :=frcrange32(x,0,max32);
dnew         :=xnew;

//float size -> when engaged, resizes the memory buffer less often by retaining data and adjust size vars - 29aug2025
if (ifloatsize>=1) then
   begin

   //enlarge
   if (dnew>=xold) then dnew:=restrict32( add64(dnew,ifloatsize) )

   //shrink
   else if not (dnew < (xold-(2*ifloatsize))  ) then dnew:=xold;

   end;

//get
if (dnew<>xold) then
   begin

   //get - 26aug2025
   case iglobal of
   true:if not global__resize2(idata,dnew,idata) then
      begin

      dnew:=xold;
      xnew:=xold;

      end;

   else if not mem__resize2(idata,dnew,idata) then
      begin

      dnew:=xold;//revert back to previous size if allocation fails - 27apr2021
      xnew:=xold;

      end;

   end;//case

   //set
   idatalen :=dnew;
   xsyncvars;
   end;

//sync
case xsetcount of
true:icount:=xnew;
else icount:=frcrange32(icount,0,xnew);
end;

//successful
result:=true;//27apr2021
except;end;
end;

procedure tstr8.xsyncvars;
begin
ibytes   :=idata;
ichars   :=idata;
iints4   :=idata;
irows8   :=idata;
irows15  :=idata;
irows16  :=idata;
irows24  :=idata;
irows32  :=idata;
end;

function tstr8.clear:boolean;
begin
result:=setlen(0);
end;

procedure tstr8.setcount(x:longint);//07dec2023
begin
icount:=frcrange32(x,0,idatalen);
end;

function tstr8.setlen(x:longint):boolean;
begin
result:=xresize(x,true);
end;

function tstr8.minlen(x:longint):boolean;//atleast this length - 21mar2025: fixed
var
   int1:longint;
begin
//defaults
result:=false;

try
//get
x:=frcrange32(x,0,max32);

if (x>idatalen) then
   begin
   //check
   if not iownmemory then exit;

   //get
   case largest32(idatalen,x) of
   0..100      :int1:=100;//100b
   101..1000   :int1:=1000;//1K
   1001..10000 :int1:=10000;//10K - 11jan2022
   10001..100000:int1:=100000;//100K
   else         int1:=1000000;//1M
   end;//case

   result:=xresize(x+int1,false);//requested len + some more for extra speed - 29apr2020
   end
else result:=true;//27apr2021

//enlarge - 21mar2025: fixed "icount/len" update failure
if (x>icount) then icount:=frcrange32(x,0,idatalen);
except;end;
end;

function tstr8.fill(xfrom,xto:longint;xval:byte):boolean;
var
   p:longint;
begin
result:=(ibytes<>nil) and iownmemory;
try
if result and (xfrom<=xto) and (icount>=1) and frcrange2(xfrom,0,icount-1) and frcrange2(xto,xfrom,icount-1) then
   begin
   for p:=xfrom to xto do ibytes[p]:=xval;
   end;
except;end;
end;

function tstr8.del3(xfrom,xlen:longint):boolean;//27jan2021
begin
result:=del(xfrom,xfrom+xlen-1);
end;

function tstr8.del(xfrom,xto:longint):boolean;//27apr2021
var
   p,int1:longint;
   v:byte;
begin
//defaults
result:=true;//pass-thru

//check
if not iownmemory then
   begin
   result:=false;
   exit;
   end;

try
//check
if (icount<=0) or (xfrom>xto) or (xto<0) or (xfrom>=icount) then exit;
//get
if frcrange2(xfrom,0,icount-1) and frcrange2(xto,xfrom,icount-1) then
   begin
   //shift down
   int1:=xto+1;
   //was: if (int1<icount) and (ibytes<>nil) then for p:=int1 to (icount-1) do ibytes[xfrom+p-int1]:=ibytes[p];
   if (int1<icount) and (ibytes<>nil) then
      begin
      //assigning value using "v" SPEEDS things up - 22apr2022
      for p:=int1 to (icount-1) do
      begin
      v:=ibytes[p];
      ibytes[xfrom+p-int1]:=v;
      end;//p
      end;
   //resize
   result:=xresize(icount-(xto-xfrom+1),true);//27apr2021
   end;
except;end;
end;

//object support ---------------------------------------------------------------
function tstr8.add(var x:tstr8):boolean;//27apr2021
begin
result:=ins2(x,icount,0,max32);
end;

function tstr8.addb(x:tstr8):boolean;
begin
result:=add(x);
end;

function tstr8.add2(var x:tstr8;xfrom,xto:longint):boolean;//27apr2021
begin
result:=ins2(x,icount,xfrom,xto);
end;

function tstr8.add3(var x:tstr8;xfrom,xlen:longint):boolean;//27apr2021
begin
if (xlen>=1) then result:=ins2(x,icount,xfrom,xfrom+xlen-1) else result:=true;
end;

function tstr8.add31(var x:tstr8;xfrom1,xlen:longint):boolean;//28jul2021
begin
if (xlen>=1) then result:=ins2(x,icount,(xfrom1-1),(xfrom1-1)+xlen-1) else result:=true;
end;

function tstr8.ins(var x:tstr8;xpos:longint):boolean;//27apr2021
begin
result:=ins2(x,xpos,0,max32);
end;

function tstr8.ins2(var x:tstr8;xpos,xfrom,xto:longint):boolean;//22apr2022, 27apr2021, 26apr2021
begin
result:=_ins2(@x,xpos,xfrom,xto);
end;

function tstr8._ins2(x:pobject;xpos,xfrom,xto:longint):boolean;//08feb2024: tstr9 support, 22apr2022, 27apr2021, 26apr2021
label
   skipend;
var
   smin,smax,dcount,p,int1:longint;
   smem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;

try
//check
if not iownmemory then exit;

//check
if (not str__ok(x)) or (x=@self) then
   begin
   result:=true;
   exit;
   end;
//init
xpos:=frcrange32(xpos,0,icount);//allow to write past end
//check
int1:=str__len(x);
if (int1=0) then//06jul2021
   begin
   result:=true;
   goto skipend;
   end;
if (int1<=0) or (xfrom>xto) or (xto<0) or (xfrom>=int1) then goto skipend;
//init
xfrom:=frcrange32(xfrom,0,int1-1);
xto:=frcrange32(xto,xfrom,int1-1);
dcount:=icount+(xto-xfrom+1);//always means to increase the size - 26apr2021
//check
if not minlen(dcount) then goto skipend;//27apr2021
//shift up
if (xpos<icount) and (ibytes<>nil) then//27apr2021
   begin
   int1:=xto-xfrom+1;
   //was: for p:=(dcount-1) downto (xpos+int1) do ibytes[p]:=ibytes[p-int1];
   //assigning value indirectly using "v" SPEEDS things up drastically - 22apr2022
   for p:=(dcount-1) downto (xpos+int1) do
   begin
   v:=ibytes[p-int1];
   ibytes[p]:=v;
   end;//p
   end;
//copy + size
if (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=x.pbytes[p];
   //assigning value indirectly using "v" SPEEDS things up drastically - 22apr2022
   if (x^ is tstr8) then
      begin
      for p:=xfrom to xto do
      begin
      v:=(x^ as tstr8).pbytes[p];
      ibytes[xpos+p-xfrom]:=v;
      end;//p
      end
   else if (x^ is tstr9) then
      begin
      smax:=-2;
      for p:=xfrom to xto do
      begin
      if (p>smax) and (not block__fastinfo(x,p,smem,smin,smax)) then goto skipend;
      v:=smem[p-smin];
      ibytes[xpos+p-xfrom]:=v;
      end;//p
      end;
   end;
icount:=dcount;
//successful
result:=true;
skipend:
except;end;
try;str__autofree(x);except;end;
end;

function tstr8.owr(var x:tstr8;xpos:longint):boolean;//overwrite -> enlarge if required - 27apr2021, 01oct2020
begin
result:=owr2(x,xpos,0,max32);
end;

function tstr8.owr2(var x:tstr8;xpos,xfrom,xto:longint):boolean;//22apr2022
label
   skipend;
var
   dcount,p,int1:longint;
   v:byte;
begin
//defaults
result:=false;

try
//check
if not iownmemory then exit;

//check
if zznil(x,2251) or (x=idata) then
   begin
   result:=true;
   exit;
   end;
//init
xpos:=frcmin32(xpos,0);
//check
int1:=x.count;
if (int1<=0) or (xfrom>xto) or (xto<0) or (xfrom>=int1) then
   begin
   result:=true;//27apr2021
   goto skipend;
   end;
//init
xfrom:=frcrange32(xfrom,0,int1-1);
xto:=frcrange32(xto,xfrom,int1-1);
dcount:=xpos+(xto-xfrom+1);
//check
if not minlen(dcount) then goto skipend;
//copy + size
if (ibytes<>nil) and (x.pbytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=x.pbytes[p];
   //local var "v" makes things FASTER - 22apr2022
   for p:=xfrom to xto do
   begin
   v:=x.pbytes[p];
   ibytes[xpos+p-xfrom]:=v;
   end;//p
   end;
icount:=largest32(dcount,icount);
//successful
result:=true;
skipend:
except;end;
//free
str__autofree(@x);
end;

//array support ----------------------------------------------------------------
function tstr8.aadd(const x:array of byte):boolean;//27apr2021
begin
result:=ains2(x,icount,0,max32);
end;

function tstr8.aadd1(const x:array of byte;xpos1,xlen:longint):boolean;//1based - 27apr2021, 19aug2020
begin
result:=ains2(x,icount,xpos1-1,xpos1-1+xlen);
end;

function tstr8.aadd2(const x:array of byte;xfrom,xto:longint):boolean;//27apr2021
begin
result:=ains2(x,icount,xfrom,xto);
end;

function tstr8.ains(const x:array of byte;xpos:longint):boolean;//27apr2021
begin
result:=ains2(x,xpos,0,max32);
end;

function tstr8.ains2(const x:array of byte;xpos,xfrom,xto:longint):boolean;//26apr2021
var
   dcount,p,int1:longint;
   v:byte;
begin
//defaults
result:=false;

try
//check
if (xto<xfrom) then exit;
//range
xfrom:=frcrange32(xfrom,low(x),high(x));
xto  :=frcrange32(xto  ,low(x),high(x));
if (xto<xfrom) then exit;
//init
xpos:=frcrange32(xpos,0,icount);//allow to write past end
dcount:=icount+(xto-xfrom+1);
minlen(dcount);
//shift up
if (xpos<icount) and (ibytes<>nil) then//27apr2021
   begin
   int1:=xto-xfrom+1;
   //was: for p:=(dcount-1) downto (xpos+int1) do ibytes[p]:=ibytes[p-int1];
   //faster - 22apr2022
   for p:=(dcount-1) downto (xpos+int1) do
   begin
   v:=ibytes[p-int1];
   ibytes[p]:=v;
   end;//p
   end;
//copy + size
if (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=x[p];
   //faster - 22apr2022
   for p:=xfrom to xto do
   begin
   v:=x[p];
   ibytes[xpos+p-xfrom]:=v;
   end;//p
   end;
icount:=dcount;
//successful
result:=true;
except;end;
end;

function tstr8.padd(x:pdlbyte;xsize:longint):boolean;//15feb2024
begin
if (xsize<=0) then result:=true else result:=pins2(x,xsize,icount,0,xsize-1);
end;

function tstr8.pins2(x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;//07feb2022
var
   dcount,p,int1:longint;
   v:byte;
begin
//defaults
result:=false;

try
//check
if (x=nil) or (xcount<=0) then
   begin
   result:=true;
   exit;
   end;
if (xto<xfrom) then exit;
//range
xfrom:=frcrange32(xfrom,0,xcount-1);
xto  :=frcrange32(xto  ,0,xcount-1);
if (xto<xfrom) then exit;
//init
xpos:=frcrange32(xpos,0,icount);//allow to write past end
dcount:=icount+(xto-xfrom+1);
minlen(dcount);
//shift up
if (xpos<icount) and (ibytes<>nil) then//27apr2021
   begin
   int1:=xto-xfrom+1;
   //was: for p:=(dcount-1) downto (xpos+int1) do ibytes[p]:=ibytes[p-int1];
   //faster - 22apr2022
   for p:=(dcount-1) downto (xpos+int1) do
   begin
   v:=ibytes[p-int1];
   ibytes[p]:=v;
   end;//p
   end;
//copy + size
if (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=x[p];
   //faster - 22apr2022
   for p:=xfrom to xto do
   begin
   v:=x[p];
   ibytes[xpos+p-xfrom]:=v;
   end;//p
   end;
icount:=dcount;
//successful
result:=true;
except;end;
end;

function tstr8.insbyt1(xval:byte;xpos:longint):boolean;
begin
result:=ains2([xval],xpos,0,0);
end;

function tstr8.insbol1(xval:boolean;xpos:longint):boolean;
begin
if xval then result:=ains2([1],xpos,0,0) else result:=ains2([0],xpos,0,0);
end;

function tstr8.insint4(xval,xpos:longint):boolean;
var
   a:tint4;
begin
a.val:=xval;result:=ains2([a.bytes[0],a.bytes[1],a.bytes[2],a.bytes[3]],xpos,0,3);
end;

//string support ---------------------------------------------------------------
function tstr8.sadd(const x:string):boolean;//26dec2023, 27apr2021
begin
result:=sins2(x,icount,0,max32);
end;

function tstr8.sadd2(const x:string;xfrom,xto:longint):boolean;//26dec2023, 27apr2021
begin
result:=sins2(x,icount,xfrom,xto);
end;

function tstr8.sadd3(const x:string;xfrom,xlen:longint):boolean;//26dec2023, 27apr2021
begin
if (xlen>=1) then result:=sins2(x,icount,xfrom,xfrom+xlen-1) else result:=true;
end;

function tstr8.sins(const x:string;xpos:longint):boolean;//27apr2021
begin
result:=sins2(x,xpos,0,max32);
end;

function tstr8.sins2(const x:string;xpos,xfrom,xto:longint):boolean;
label
   skipend;
var//Always zero based for "xfrom" and "xto"
   xlen,dcount,p,int1:longint;
   v:byte;
begin
//defaults
result:=false;

try
//check
xlen:=low__len(x);
if (xlen<=0) then
   begin
   result:=true;
   exit;
   end;
//check #2
if (xto<xfrom) then exit;//27apr2021
//range
xfrom:=frcrange32(xfrom,0,xlen-1);
xto  :=frcrange32(xto  ,0,xlen-1);
if (xto<xfrom) then exit;
//init
xpos:=frcrange32(xpos,0,icount);//allow to write past end
dcount:=icount+(xto-xfrom+1);
//check
if not minlen(dcount) then goto skipend;
//shift up
if (xpos<icount) and (ibytes<>nil) then//27apr2021
   begin
   int1:=xto-xfrom+1;
   //was: for p:=(dcount-1) downto (xpos+int1) do ibytes[p]:=ibytes[p-int1];
   //faster - 22apr2022
   for p:=(dcount-1) downto (xpos+int1) do
   begin
   v:=ibytes[p-int1];;
   ibytes[p]:=v;
   end;//p
   end;
//copy + size
if (ibytes<>nil) then//27apr2021
   begin
   //was: for p:=xfrom to xto do ibytes[xpos+p-xfrom]:=byte(x[p+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
   //faster - 22apr2022
   for p:=xfrom to xto do
   begin
   v:=byte(x[p+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
   ibytes[xpos+p-xfrom]:=v;
   end;//p
   end;
icount:=dcount;
//successful
result:=true;
skipend:
except;end;
end;

//push support -----------------------------------------------------------------
function tstr8.pushcmp8(var xpos:longint;xval:comp):boolean;
begin
result:=ains(tcmp8(xval).bytes,xpos);
if result then inc(xpos,8);
end;

function tstr8.pushcur8(var xpos:longint;xval:currency):boolean;
begin
result:=ains(tcur8(xval).bytes,xpos);
if result then inc(xpos,8);
end;

function tstr8.pushint4(var xpos:longint;xval:longint):boolean;
begin
result:=ains(tint4(xval).bytes,xpos);
if result then inc(xpos,4);
end;

function tstr8.pushint4R(var xpos:longint;xval:longint):boolean;
begin
xval:=low__intr(xval);//swap round
result:=ains(tint4(xval).bytes,xpos);
if result then inc(xpos,4);
end;

function tstr8.pushint3(var xpos:longint;xval:longint):boolean;
var
   r,g,b:byte;
begin
low__int3toRGB(xval,r,g,b);
result:=ains([r,g,b],xpos);
if result then inc(xpos,3);
end;

function tstr8.pushwrd2(var xpos:longint;xval:word):boolean;
begin
result:=ains(twrd2(xval).bytes,xpos);
if result then inc(xpos,2);
end;

function tstr8.pushwrd2R(var xpos:longint;xval:word):boolean;
begin
xval:=low__wrdr(xval);
result:=ains(twrd2(xval).bytes,xpos);
if result then inc(xpos,2);
end;

function tstr8.pushbyt1(var xpos:longint;xval:byte):boolean;
begin
result:=ains([xval],xpos);
if result then inc(xpos,1);
end;

function tstr8.pushbol1(var xpos:longint;xval:boolean):boolean;
begin
if xval then result:=ains([1],xpos) else result:=ains([0],xpos);
if result then inc(xpos,1);
end;

function tstr8.pushchr1(var xpos:longint;xval:char):boolean;
begin
result:=ains([byte(xval)],xpos);
if result then inc(xpos,1);
end;

function tstr8.pushstr(var xpos:longint;xval:string):boolean;
begin
result:=sins(xval,xpos);
if result then inc(xpos,low__len(xval));
end;

//add support ------------------------------------------------------------------
function tstr8.addcmp8(xval:comp):boolean;
begin
result:=aadd(tcmp8(xval).bytes);
end;

function tstr8.addcur8(xval:currency):boolean;
begin
result:=aadd(tcur8(xval).bytes);
end;

function tstr8.addRGBA4(r,g,b,a:byte):boolean;
begin
result:=aadd([r,g,b,a]);
end;

function tstr8.addRGB3(r,g,b:byte):boolean;
begin
result:=aadd([r,g,b]);
end;

function tstr8.addint4(xval:longint):boolean;
begin
result:=aadd(tint4(xval).bytes);
end;

function tstr8.addint4R(xval:longint):boolean;
begin
xval:=low__intr(xval);//swap round
result:=aadd(tint4(xval).bytes);
end;

function tstr8.addint3(xval:longint):boolean;
var
   r,g,b:byte;
begin
low__int3toRGB(xval,r,g,b);
result:=aadd([r,g,b]);
end;

function tstr8.addwrd2(xval:word):boolean;
begin
result:=aadd(twrd2(xval).bytes);//16aug2020
end;

function tstr8.addwrd2R(xval:word):boolean;
begin
xval:=low__wrdr(xval);//swap round
result:=aadd(twrd2(xval).bytes);//16aug2020
end;

function tstr8.addsmi2(xval:smallint):boolean;//01aug2021
var
   a:twrd2;
begin
a.si:=xval;
result:=aadd([a.bytes[0],a.bytes[1]]);
end;

function tstr8.addbyt1(xval:byte):boolean;
begin
result:=aadd([xval]);
end;

function tstr8.addbol1(xval:boolean):boolean;//21aug2020
begin
if xval then result:=aadd([1]) else result:=aadd([0]);
end;

function tstr8.addchr1(xval:char):boolean;
begin
result:=aadd([byte(xval)]);
end;

function tstr8.addstr(xval:string):boolean;
begin
result:=sadd(xval);
end;

function tstr8.addrec(a:pointer;asize:longint):boolean;//07feb2022
begin
result:=pins2(pdlbyte(a),asize,icount,0,asize-1);
end;

//get support ------------------------------------------------------------------
function tstr8.getc8(xpos:longint):tcolor8;
begin
if (xpos>=0) and (xpos<icount) and (ibytes<>nil) then result:=ibytes[xpos] else result:=0;
end;

function tstr8.getc24(xpos:longint):tcolor24;
begin
if (xpos>=0) and ((xpos+2)<icount) and (ibytes<>nil) then
   begin
   result.b:=ibytes[xpos+0];
   result.g:=ibytes[xpos+1];
   result.r:=ibytes[xpos+2];
   end
else
   begin
   result.b:=0;
   result.g:=0;
   result.r:=0;
   end;
end;

function tstr8.getc32(xpos:longint):tcolor32;
begin
if (xpos>=0) and ((xpos+3)<icount) and (ibytes<>nil) then
   begin
   result.b:=ibytes[xpos+0];
   result.g:=ibytes[xpos+1];
   result.r:=ibytes[xpos+2];
   result.a:=ibytes[xpos+3];
   end
else
   begin
   result.b:=0;
   result.g:=0;
   result.r:=0;
   result.a:=255;
   end;
end;

function tstr8.getc40(xpos:longint):tcolor40;
begin
if (xpos>=0) and ((xpos+4)<icount) and (ibytes<>nil) then
   begin
   result.b:=ibytes[xpos+0];
   result.g:=ibytes[xpos+1];
   result.r:=ibytes[xpos+2];
   result.a:=ibytes[xpos+3];
   result.c:=ibytes[xpos+4];
   end
else
   begin
   result.b:=0;
   result.g:=0;
   result.r:=0;
   result.a:=255;
   result.c:=0;
   end;
end;

function tstr8.getcmp8(xpos:longint):comp;
var
   a:tcmp8;
begin
if (xpos>=0) and ((xpos+7)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   a.bytes[2]:=ibytes[xpos+2];
   a.bytes[3]:=ibytes[xpos+3];
   a.bytes[4]:=ibytes[xpos+4];
   a.bytes[5]:=ibytes[xpos+5];
   a.bytes[6]:=ibytes[xpos+6];
   a.bytes[7]:=ibytes[xpos+7];
   result:=a.val;
   end
else result:=0;
end;

function tstr8.getcur8(xpos:longint):currency;
var
   a:tcur8;
begin
if (xpos>=0) and ((xpos+7)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   a.bytes[2]:=ibytes[xpos+2];
   a.bytes[3]:=ibytes[xpos+3];
   a.bytes[4]:=ibytes[xpos+4];
   a.bytes[5]:=ibytes[xpos+5];
   a.bytes[6]:=ibytes[xpos+6];
   a.bytes[7]:=ibytes[xpos+7];
   result:=a.val;
   end
else result:=0;
end;

function tstr8.getint4(xpos:longint):longint;
var
   a:tint4;
begin
if (xpos>=0) and ((xpos+3)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   a.bytes[2]:=ibytes[xpos+2];
   a.bytes[3]:=ibytes[xpos+3];
   result:=a.val;
   end
else result:=0;
end;

function tstr8.getint4i(xindex:longint):longint;
begin
result:=getint4(xindex*4);
end;

function tstr8.getint4R(xpos:longint):longint;//14feb2021
var
   a:tint4;
begin
if (xpos>=0) and ((xpos+3)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+3];//swap round
   a.bytes[1]:=ibytes[xpos+2];
   a.bytes[2]:=ibytes[xpos+1];
   a.bytes[3]:=ibytes[xpos+0];
   result:=a.val;
   end
else result:=0;
end;

function tstr8.getint3(xpos:longint):longint;
begin
if (xpos>=0) and ((xpos+2)<icount) and (ibytes<>nil) then result:=ibytes[xpos+0]+(ibytes[xpos+1]*256)+(ibytes[xpos+2]*256*256) else result:=0;
end;

function tstr8.getsml2(xpos:longint):smallint;//28jul2021
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   result:=a.si;
   end
else result:=0;
end;

function tstr8.getwrd2(xpos:longint):word;
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+0];
   a.bytes[1]:=ibytes[xpos+1];
   result:=a.val;
   end
else result:=0;
end;

function tstr8.getwrd2R(xpos:longint):word;//14feb2021
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<icount) and (ibytes<>nil) then
   begin
   a.bytes[0]:=ibytes[xpos+1];//swap round
   a.bytes[1]:=ibytes[xpos+0];
   result:=a.val;
   end
else result:=0;
end;

function tstr8.getbyt1(xpos:longint):byte;
begin
if (xpos>=0) and (xpos<icount) and (ibytes<>nil) then result:=ibytes[xpos] else result:=0;
end;

function tstr8.getbol1(xpos:longint):boolean;
begin
if (xpos>=0) and (xpos<icount) and (ibytes<>nil) then result:=(ibytes[xpos]<>0) else result:=false;
end;

function tstr8.getchr1(xpos:longint):char;
begin
if (xpos>=0) and (xpos<icount) and (ibytes<>nil) then result:=char(ibytes[xpos]) else result:=#0;
end;

function tstr8.getstr(xpos,xlen:longint):string;//fixed - 16aug2020
var
   dlen,p:longint;
begin
result:='';

try
if (xlen>=1) and (xpos>=0) and (xpos<icount) and (ibytes<>nil) then
   begin
   dlen:=frcmax32(xlen,icount-xpos);
   if (dlen>=1) then
      begin
      low__setlen(result,dlen);
      for p:=xpos to (xpos+dlen-1) do result[p-xpos+stroffset]:=char(ibytes[p]);
      end;
   end;
except;end;
end;

function tstr8.getstr1(xpos,xlen:longint):string;
begin
result:=getstr(xpos-1,xlen);
end;

function tstr8.getnullstr(xpos,xlen:longint):string;//20mar2022
var
   dcount,dlen,p:longint;
   v:byte;
begin
result:='';

try
if (xlen>=1) and (xpos>=0) and (xpos<icount) and (ibytes<>nil) then
   begin
   dlen:=frcmax32(xlen,icount-xpos);
   if (dlen>=1) then
      begin
      low__setlen(result,dlen);
      dcount:=0;
      for p:=xpos to (xpos+dlen-1) do
      begin
      if (ibytes[p]=0) then
         begin
         if (dcount<>dlen) then low__setlen(result,dcount);
         break;
         end;
      //was: result[p-xpos+stroffset]:=char(ibytes[p]);
      v:=ibytes[p];
      result[p-xpos+stroffset]:=char(v);
      inc(dcount);
      end;//p
      end;
   end;
except;end;
end;

function tstr8.getnullstr1(xpos,xlen:longint):string;//20mar2022
begin
result:=getnullstr(xpos-1,xlen);
end;

function tstr8.gettext:string;
var
   p:longint;
   v:byte;
begin
result:='';

try
if (icount>=1) and (ibytes<>nil) then//27apr2021
   begin
   low__setlen(result,icount);
   //was: for p:=0 to (icount-1) do result[p+stroffset]:=char(ibytes[p]);//27apr2021
   //faster - 22apr2022
   for p:=0 to (icount-1) do
   begin
   v:=ibytes[p];
   result[p+stroffset]:=char(v);//27apr2021
   end;//p
   end;
except;end;
end;

procedure tstr8.settext(const x:string);
var
   xlen,p:longint;
   v:byte;
begin
try
xlen:=low__len(x);

setlen(xlen);

if (xlen>=1) and (ibytes<>nil) then//27apr2021
   begin

   //was: for p:=1 to xlen do ibytes[p-1]:=byte(x[p-1+stroffset]);//force 8bit conversion
   //faster - 22apr2022
   for p:=1 to xlen do
   begin
   v:=byte(x[p-1+stroffset]);
   ibytes[p-1]:=v;//force 8bit conversion
   end;//p

   end;

except;end;
end;

function tstr8.gettextarray:string;
label
   skipend;
var
   a,aline:tstr8;
   xmax,p:longint;
begin
//defaults
result:='';

try
a:=nil;
aline:=nil;
//check
if (icount<=0) or (ibytes=nil) then goto skipend;
//init
a:=str__new8;
aline:=str__new8;
xmax:=icount-1;
//get
for p:=0 to xmax do
begin
aline.sadd(intstr32(ibytes[p])+insstr(',',p<xmax));
if (aline.count>=1010) then
   begin
   aline.sadd(rcode);
   a.add(aline);
   aline.clear;
   end;
end;//p
//.finalise
if (aline.count>=1) then
   begin
   a.add(aline);
   aline.clear;
   end;
//set
result:=':array[0..'+intstr32(icount-1)+'] of byte=('+rcode+a.text+');';//cleaned 02mar2022
skipend:
except;end;
try
str__free(@a);
str__free(@aline);
except;end;
end;

//set support ------------------------------------------------------------------
procedure tstr8.setcmp8(xpos:longint;xval:comp);
var
   a:tcmp8;
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+8)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
ibytes[xpos+2]:=a.bytes[2];
ibytes[xpos+3]:=a.bytes[3];
ibytes[xpos+4]:=a.bytes[4];
ibytes[xpos+5]:=a.bytes[5];
ibytes[xpos+6]:=a.bytes[6];
ibytes[xpos+7]:=a.bytes[7];
icount:=frcmin32(icount,xpos+8);//10may2020
end;

procedure tstr8.setcur8(xpos:longint;xval:currency);
var
   a:tcur8;
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+8)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
ibytes[xpos+2]:=a.bytes[2];
ibytes[xpos+3]:=a.bytes[3];
ibytes[xpos+4]:=a.bytes[4];
ibytes[xpos+5]:=a.bytes[5];
ibytes[xpos+6]:=a.bytes[6];
ibytes[xpos+7]:=a.bytes[7];
icount:=frcmin32(icount,xpos+8);//10may2020
end;

procedure tstr8.setint4(xpos:longint;xval:longint);
var
   a:tint4;
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+4)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
ibytes[xpos+2]:=a.bytes[2];
ibytes[xpos+3]:=a.bytes[3];
icount:=frcmin32(icount,xpos+4);//10may2020
end;

procedure tstr8.setc8(xpos:longint;xval:tcolor8);
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+1)) or (ibytes=nil) then exit;
ibytes[xpos+0]:=xval;
icount:=frcmin32(icount,xpos+1);
end;

procedure tstr8.setc24(xpos:longint;xval:tcolor24);
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+3)) or (ibytes=nil) then exit;
ibytes[xpos+0]:=xval.b;
ibytes[xpos+1]:=xval.g;
ibytes[xpos+2]:=xval.r;
icount:=frcmin32(icount,xpos+3);
end;

procedure tstr8.setc32(xpos:longint;xval:tcolor32);
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+4)) or (ibytes=nil) then exit;
ibytes[xpos+0]:=xval.b;
ibytes[xpos+1]:=xval.g;
ibytes[xpos+2]:=xval.r;
ibytes[xpos+3]:=xval.a;
icount:=frcmin32(icount,xpos+4);
end;

procedure tstr8.setc40(xpos:longint;xval:tcolor40);
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+5)) or (ibytes=nil) then exit;
ibytes[xpos+0]:=xval.b;
ibytes[xpos+1]:=xval.g;
ibytes[xpos+2]:=xval.r;
ibytes[xpos+3]:=xval.a;
ibytes[xpos+4]:=xval.c;
icount:=frcmin32(icount,xpos+5);
end;

procedure tstr8.setint4i(xindex:longint;xval:longint);
begin
setint4(xindex*4,xval);
end;

procedure tstr8.setint4R(xpos:longint;xval:longint);
var
   a:tint4;
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+4)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[3];//swap round
ibytes[xpos+1]:=a.bytes[2];
ibytes[xpos+2]:=a.bytes[1];
ibytes[xpos+3]:=a.bytes[0];
icount:=frcmin32(icount,xpos+4);//10may2020
end;

procedure tstr8.setint3(xpos:longint;xval:longint);
var
   r,g,b:byte;
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+3)) or (ibytes=nil) then exit;
low__int3toRGB(xval,r,g,b);
ibytes[xpos+0]:=r;
ibytes[xpos+1]:=g;
ibytes[xpos+2]:=b;
icount:=frcmin32(icount,xpos+3);//10may2020
end;

procedure tstr8.setsml2(xpos:longint;xval:smallint);
var
   a:twrd2;
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+2)) or (ibytes=nil) then exit;
a.si:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
icount:=frcmin32(icount,xpos+2);//10may2020
end;

procedure tstr8.setwrd2(xpos:longint;xval:word);
var
   a:twrd2;
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+2)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[0];
ibytes[xpos+1]:=a.bytes[1];
icount:=frcmin32(icount,xpos+2);//10may2020
end;

procedure tstr8.setwrd2R(xpos:longint;xval:word);
var
   a:twrd2;
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+2)) or (ibytes=nil) then exit;
a.val:=xval;
ibytes[xpos+0]:=a.bytes[1];//swap round
ibytes[xpos+1]:=a.bytes[0];
icount:=frcmin32(icount,xpos+2);//10may2020
end;

procedure tstr8.setbyt1(xpos:longint;xval:byte);
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+1)) or (ibytes=nil) then exit;
ibytes[xpos]:=xval;
icount:=frcmin32(icount,xpos+1);//10may2020
end;

procedure tstr8.setbol1(xpos:longint;xval:boolean);
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+1)) or (ibytes=nil) then exit;
if xval then ibytes[xpos]:=1 else ibytes[xpos]:=0;
icount:=frcmin32(icount,xpos+1);//10may2020
end;

procedure tstr8.setchr1(xpos:longint;xval:char);
begin
if (xpos<0) then xpos:=0;
if (not minlen(xpos+1)) or (ibytes=nil) then exit;
ibytes[xpos]:=byte(xval);
icount:=frcmin32(icount,xpos+1);//10may2020
end;

procedure tstr8.setstr(xpos:longint;xlen:longint;xval:string);
var
   xminlen,p:longint;
   v:byte;
begin
try
if (xpos<0) then xpos:=0;
if (xlen<=0) or (xval='') then exit;
xlen:=frcmax32(xlen,low__len(xval));
xminlen:=xpos+xlen;
if (not minlen(xminlen)) or (ibytes=nil) then exit;
//was: ERROR: for p:=xpos to (xpos+xlen-1) do ibytes[p]:=ord(xval[p+stroffset]);
//was: for p:=0 to (xlen-1) do ibytes[xpos+p]:=ord(xval[p+stroffset]);
for p:=0 to (xlen-1) do
begin
v:=ord(xval[p+stroffset]);
ibytes[xpos+p]:=v;
end;//p
icount:=frcmin32(icount,xminlen);//10may2020
except;end;
end;

procedure tstr8.setstr1(xpos:longint;xlen:longint;xval:string);
begin
setstr(xpos-1,xlen,xval);
end;

function tstr8.setarray(xpos:longint;const xval:array of byte):boolean;
var
   xminlen,xmin,xmax,p:longint;
   v:byte;
begin
//defaults
result:=false;

try
//get
if (xpos<0) then xpos:=0;
xmin:=low(xval);
xmax:=high(xval);
xminlen:=xpos+(xmax-xmin+1);
if (not minlen(xminlen)) or (ibytes=nil) then exit;
//was: for p:=xmin to xmax do ibytes[xpos+(p-xmin)]:=xval[p];
for p:=xmin to xmax do
begin
v:=xval[p];
ibytes[xpos+(p-xmin)]:=v;
end;//p
icount:=frcmin32(icount,xminlen);//10may2020
//successful
result:=true;
except;end;
end;

function tstr8.scanline(xfrom:longint):pointer;
begin
//defaults
result:=nil;

try
if (icount<=0) then exit;
//get
if (xfrom<0) then xfrom:=0 else if (xfrom>=icount) then xfrom:=icount-1;
if (ibytes<>nil) then result:=tpointer(@ibytes[xfrom]);
except;end;
end;

function tstr8.getbytes(x:longint):byte;//0-based
begin
if (x>=0) and (x<icount) and (ibytes<>nil) then result:=ibytes[x] else result:=0;
end;

procedure tstr8.setbytes(x:longint;xval:byte);
begin
if (x>=0) and (x<icount) and (ibytes<>nil) then ibytes[x]:=xval;
end;

function tstr8.getbytes1(x:longint):byte;//1-based
begin
if (x>=1) and (x<=icount) and (ibytes<>nil) then result:=ibytes[x-1] else result:=0;
end;

procedure tstr8.setbytes1(x:longint;xval:byte);
begin
if (x>=1) and (x<=icount) and (ibytes<>nil) then ibytes[x-1]:=xval;
end;

function tstr8.getchars(x:longint):char;//D10 uses unicode here - 27apr2021
begin
if (x>=0) and (x<icount) and (ibytes<>nil) then result:=char(ibytes[x]) else result:=#0;
end;

procedure tstr8.setchars(x:longint;xval:char);//D10 uses unicode here
begin
if (x>=0) and (x<icount) and (ibytes<>nil) then ibytes[x]:=byte(xval);
end;

//replace support --------------------------------------------------------------
procedure tstr8.setreplace(x:tstr8);
begin
clear;
add(x);
end;

procedure tstr8.setreplacecmp8(x:comp);
begin
clear;
setcmp8(0,x);
end;

procedure tstr8.setreplacecur8(x:currency);
begin
clear;
setcur8(0,x);
end;

procedure tstr8.setreplaceint4(x:longint);
begin
clear;
setint4(0,x);
end;

procedure tstr8.setreplacewrd2(x:word);
begin
clear;
setwrd2(0,x);
end;

procedure tstr8.setreplacebyt1(x:byte);
begin
clear;
setbyt1(0,x);
end;

procedure tstr8.setreplacebol1(x:boolean);
begin
clear;
setbol1(0,x);
end;

procedure tstr8.setreplacechr1(x:char);
begin
clear;
setchr1(0,x);
end;

procedure tstr8.setreplacestr(x:string);
begin
clear;
setstr(0,low__len(x),x);
end;


//## tstr9 #####################################################################
constructor tstr9.create(xlen:longint);
begin
if classnameis('tstr9') then track__inc(satStr9,1);
oautofree:=false;
igetmin:=-1;
igetmax:=-2;
ilen:=0;
ilen2:=0;//real length
idatalen:=0;
imem:=0;
iblockcount:=0;
iblocksize:=block__size;
ilockcount:=0;
ilist:=nil;
ilist:=tintlist.create;//tdynamicpointer.create;
ilist.ptr[0]:=nil;//make sure 1st item always exists
inherited create;
tag1:=0;
tag2:=0;
tag3:=0;
tag4:=0;
seekpos:=0;
setlen(xlen);
end;

destructor tstr9.destroy;
begin
try
setlen(0);
freeobj(@ilist);
inherited destroy;
if classnameis('tstr9') then track__inc(satStr9,-1);
except;end;
end;

function tstr9.empty:boolean;
begin
result:=(ilen<=0);
end;

function tstr9.notempty:boolean;
begin
result:=(ilen>=1);
end;

procedure tstr9.lock;
begin
inc(ilockcount);
end;

procedure tstr9.unlock;
begin
ilockcount:=frcmin32(ilockcount-1,0);
end;

function tstr9.writeto1(a:pointer;asize,xfrom1,xlen:longint):boolean;
begin
result:=writeto(a,asize,xfrom1-1,xlen);
end;

function tstr9.writeto1b(a:pointer;asize:longint;var xfrom1:longint;xlen:longint):boolean;
begin
result:=false;

try
xlen:=frcrange32(xlen,0,frcmin32(asize,0));
result:=writeto(a,asize,xfrom1-1,xlen);
if result then inc(xfrom1,xlen)
except;end;
end;

function tstr9.writeto(a:pointer;asize,xfrom0,xlen:longint):boolean;//26jul2024
var
   sp,slen,p:longint;
   b:pdlBYTE;
   v:byte;
begin
//defaults
result:=false;

try
//check
if (a=nil) then exit;
//init
slen:=len;//our length
fillchar(a^,asize,0);
b:=a;
xlen:=frcmax32(xlen,asize);
if (xlen<=0) then
   begin
   result:=true;
   exit;
   end;
//get
sp:=xfrom0;
for p:=0 to (xlen-1) do
begin
if (sp>=0) then
   begin
   //was: if (sp<slen) then b[p]:=pbytes[sp] else break;
   //faster - 22apr2022
   if (sp<slen) then
      begin
      v:=pbytes[sp];
      b[p]:=v;
      end
   else break;
   end;
inc(sp);
end;
//successful
result:=true;
except;end;
end;

function tstr9.splice(xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;
var
   xmin,xmax:longint;
begin
//defaults
result:=false;
xoutmem:=nil;
xoutlen:=0;

//check
if (xpos<0) or (xpos>=ilen) or (xlen<=0) then exit;

//get
if fastinfo(xpos,xoutmem,xmin,xmax) then
   begin
   xoutmem:=ptr__shift(xoutmem,xpos-xmin);
   xoutlen:=xmax-xpos+1;
   if (xoutlen>xlen) then xoutlen:=xlen;
   //successful
   result:=(xoutmem<>nil) and (xoutlen>=1);
   end;
end;

function tstr9.fastinfo(xpos:longint;var xmem:pdlbyte;var xmin,xmax:longint):boolean;//15feb2024
var
   i:longint;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;
//get
if (xpos>=0) and (xpos<ilen) then
   begin
   //set
   i:=xpos div iblocksize;
   xmem:=ilist.ptr[i];
   xmin:=i*iblocksize;
   xmax:=xmin+iblocksize-1;
   //.limit max for last block using datastream length - 15feb2024
   if (xmax>=ilen) then xmax:=ilen-1;
   //successful
   result:=(xmem<>nil);
   end;
end;

function tstr9.fastadd(var x:array of byte;xsize:longint):longint;
begin
result:=fastwrite(x,xsize,ilen);
end;

function tstr9.fastwrite(var x:array of byte;xsize,xpos:longint):longint;
label
   skipend;
var
   vmin,vmax,i:longint;
   vmem:pdlbyte;
begin
//defaults
result:=0;

try
//range
if (xpos<0) then xpos:=0;

//check
if (xsize<=0) then goto skipend;

//init
vmin:=-1;
vmax:=-1;

//size
if not minlen(xpos+xsize) then goto skipend;

//get
for i:=0 to (xsize-1) do
begin
if (xpos>vmax) and (not fastinfo(xpos,vmem,vmin,vmax)) then goto skipend;
vmem[xpos-vmin]:=x[i];
//.inc
inc(xpos);
inc(result);
end;//i

skipend:
except;end;
end;

function tstr9.fastread(var x:array of byte;xsize,xpos:longint):longint;
label
   skipend;
var
   vmin,vmax,i:longint;
   vmem:pdlbyte;
begin
//defaults
result:=0;

try
//check
if (xsize<=0) or (xpos<0) or (xpos>=ilen) then goto skipend;

//init
vmin:=-1;
vmax:=-1;

//get
for i:=0 to (xsize-1) do
begin
if (xpos>vmax) and (not fastinfo(xpos,vmem,vmin,vmax)) then goto skipend;
if (xpos<ilen) then
   begin
   x[i]:=vmem[xpos-vmin];
   inc(result);
   end
else break;
//.inc
inc(xpos);
end;//i

skipend:
except;end;
end;

function tstr9.getv(xpos:longint):byte;
begin
if (xpos<=igetmax) and (xpos>=igetmin)         then result:=igetmem[xpos-igetmin]
else if fastinfo(xpos,igetmem,igetmin,igetmax) then result:=igetmem[xpos-igetmin]
else
   begin
   result :=0;
   igetmin:=-1;
   igetmax:=-2;//off
   end;
end;

procedure tstr9.setv(xpos:longint;v:byte);
begin
if (xpos<=isetmax) and (xpos>=isetmin)         then isetmem[xpos-isetmin]:=v
else if fastinfo(xpos,isetmem,isetmin,isetmax) then isetmem[xpos-isetmin]:=v
else
   begin
   isetmin:=-1;
   isetmax:=-2;//off
   end;
end;

function tstr9.getv1(xpos:longint):byte;
begin
result:=getv(xpos-1);
end;

procedure tstr9.setv1(xpos:longint;v:byte);
begin
setv(xpos-1,v);
end;

function tstr9.getchar(xpos:longint):char;
begin
result:=char(getv(xpos));
end;

procedure tstr9.setchar(xpos:longint;v:char);
begin
setv(xpos,byte(v));
end;

function tstr9.clear:boolean;
begin
result:=setlen(0);
end;

function tstr9.softclear:boolean;
begin
ilen:=0;
result:=true;
end;

function tstr9.softclear2(xmaxlen:longint):boolean;
begin
if (ilen>xmaxlen) then setlen(xmaxlen);
ilen:=0;
result:=true;
end;

function tstr9.setlen(x:longint):boolean;
var//Note: x is new length
   a:pointer;
   p,xnewlen:longint;
begin
//defaults
result:=false;
//range
xnewlen:=frcmin32(x,0);
//check
if (xnewlen<=0) then
   begin
   if (ilen<=0) and (ilen2<=0) then exit;
   end
else if (xnewlen=ilen) then exit;

try
//reset cache vars
igetmin:=-1;//off
igetmax:=-2;//off
isetmin:=-1;//off
isetmax:=-2;//off

try
//clear
if (xnewlen<=0) and ((ilen2>=1) or (ilist.count>=1)) then
   begin
//   lastlog:=lastlog+'clear: '+k64(ilen2)+'..'+k64(xnewlen)+rcode;//xxxxxxxxxxxxxxxx
   for p:=(ilist.count-1) downto 0 do if (ilist.ptr[p]<>nil) then
      begin
      a:=ilist.ptr[p];
      ilist.ptr[p]:=nil;//set to nil before freeing object
      block__freeb(a);
      end;
   ilist.clear;
   end
//more
else if (xnewlen>=1) and (xnewlen>ilen2) then
   begin
//   lastlog:=lastlog+'more: '+k64(ilen2)+'..'+k64(xnewlen)+rcode;//xxxxxxxxxxxxxxxx
   ilist.mincount((xnewlen div iblocksize)+1);
   for p:=(ilen2 div iblocksize) to (xnewlen div iblocksize) do if (ilist.ptr[p]=nil) then ilist.ptr[p]:=block__new;//keep going even if out-of-memory
   end
//less
else if (ilen2>=1) and (xnewlen<ilen2) then
   begin
//   lastlog:=lastlog+'less: '+k64(ilen2)+'..'+k64(xnewlen)+rcode;//xxxxxxxxxxxxxxxx
   for p:=(ilen2 div iblocksize) downto ((xnewlen div iblocksize)+1) do if (ilist.ptr[p]<>nil) then
      begin
      a:=ilist.ptr[p];
      ilist.ptr[p]:=nil;//set to nil before freeing object
      block__freeb(a);
      end;
   end;

except;end;

//set
ilen2:=xnewlen;
ilen:=xnewlen;
if (ilen2<=0) then idatalen:=0 else idatalen:=((xnewlen div iblocksize)+1)*iblocksize;//23feb2024: corrected
imem:=idatalen + ilist.mem;

//successful
result:=true;
except;end;
end;

function tstr9.mem_predict(xlen:comp):comp;
begin
xlen:=frcmin64(xlen,0);
if (xlen<=0) then result:=0 else result:=mult64( add64( div64(xlen,iblocksize) ,1) ,iblocksize);
if (ilist<>nil) then result:=add64(result, ilist.mem_predict(add64(div64(xlen,iblocksize),1)) );
end;

function tstr9.minlen(x:longint):boolean;//atleast this length, 29feb2024: updated
begin
//defaults
result:=true;
//get
if (x>ilen) then
   begin
   //reset cache vars
   igetmin:=-1;//off
   igetmax:=-2;//off
   isetmin:=-1;//off
   isetmax:=-2;//off
   //enlarge
   if (x>idatalen) then result:=setlen(x) else ilen:=x;
   end;
end;

function tstr9.xshiftup(spos,slen:longint):boolean;//29feb2024: fixed min range
label
   skipend;
var
   smin,dmin,smax,dmax,xlen,p:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;
try
xlen:=ilen;

//check
if (xlen<=0) or (slen<=0) then
   begin
   result:=true;
   goto skipend;
   end;

//check
if (spos<0) or (spos>=xlen) then goto skipend;

//init
smax:=-2;
smin:=-1;
dmax:=-2;
dmin:=-1;

//get
for p:=(xlen-1) downto (spos+slen) do
begin
if (((p-slen)<smin) or ((p-slen)>smax)) and (not block__fastinfo(@self,p-slen,smem,smin,smax)) then goto skipend;
if ((p<dmin) or (p>dmax))               and (not block__fastinfo(@self,p,     dmem,dmin,dmax)) then goto skipend;
v:=smem[p-slen-smin];
dmem[p-dmin]:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;

//object support ---------------------------------------------------------------
function tstr9.add(x:pobject):boolean;
begin
result:=ins2(x,ilen,0,max32);
end;

function tstr9.addb(x:tobject):boolean;
begin
result:=add(@x);
end;

function tstr9.add2(x:pobject;xfrom,xto:longint):boolean;
begin
result:=ins2(x,ilen,xfrom,xto);
end;

function tstr9.add3(x:pobject;xfrom,xlen:longint):boolean;
begin
if (xlen>=1) then result:=ins2(x,ilen,xfrom,xfrom+xlen-1) else result:=true;
end;

function tstr9.add31(x:pobject;xfrom1,xlen:longint):boolean;
begin
if (xlen>=1) then result:=ins2(x,ilen,(xfrom1-1),(xfrom1-1)+xlen-1) else result:=true;
end;

function tstr9.ins(x:pobject;xpos:longint):boolean;
begin
result:=ins2(x,xpos,0,max32);
end;

function tstr9.ins2(x:pobject;xpos,xfrom,xto:longint):boolean;//79% native speed of tstr8.ins2 which uses a single block of memory
label
   skipend;
var
   smin,dmin,smax,dmax,slen,dlen,p,int1:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;

try
//check
if not pok(x) then
   begin
   result:=true;
   exit;
   end;

//init
slen:=ilen;
xpos:=frcrange32(xpos,0,slen);//allow to write past end

//check
int1:=str__len(x);
if (int1=0) then//06jul2021
   begin
   result:=true;
   goto skipend;
   end;
if (int1<=0) or (xfrom>xto) or (xto<0) or (xfrom>=int1) then goto skipend;

//init
xfrom:=frcrange32(xfrom,0,int1-1);
xto:=frcrange32(xto,xfrom,int1-1);
dlen:=ilen+(xto-xfrom+1);//always means to increase the size

//check
if not minlen(dlen) then goto skipend;

//shift up
if (xpos<slen) and (not xshiftup(xpos,xto-xfrom+1)) then goto skipend;

//copy + size
if (x^ is tstr8) then
   begin
   //init
   dmax:=-2;
   //get
   smem:=(x^ as tstr8).core;
   for p:=xfrom to xto do
   begin
   v:=smem[p];
   if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
   dmem[xpos+p-xfrom-dmin]:=v;
   end;//p
   end
else if (x^ is tstr9) then
   begin
   //init
   smax:=-2;
   smin:=-1;
   dmax:=-2;
   dmin:=-1;
   //get
   for p:=xfrom to xto do
   begin
   if (p>smax)              and (not block__fastinfo(x,p,smem,smin,smax))                then goto skipend;
   if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
   v:=smem[p-smin];
   dmem[xpos+p-xfrom-dmin]:=v;
   end;//p
   end;

//successful
result:=true;
skipend:
except;end;
try;str__autofree(x);except;end;
end;

function tstr9.owr(x:pobject;xpos:longint):boolean;//overwrite -> enlarge if required - 27apr2021, 01oct2020
begin
result:=owr2(x,xpos,0,max32);
end;

function tstr9.owr2(x:pobject;xpos,xfrom,xto:longint):boolean;//22apr2022
label
   skipend;
var
   smin,dmin,smax,dmax,dlen,p,int1:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;

try
//check
if not pok(x) then
   begin
   result:=true;
   exit;
   end;

//init
xpos:=frcmin32(xpos,0);

//check
int1:=str__len(x);
if (int1<=0) or (xfrom>xto) or (xto<0) or (xfrom>=int1) then
   begin
   result:=true;//27apr2021
   goto skipend;
   end;

//init
xfrom:=frcrange32(xfrom,0,int1-1);
xto:=frcrange32(xto,xfrom,int1-1);
dlen:=xpos+(xto-xfrom+1);

//check
if not minlen(dlen) then goto skipend;

//copy + size
if (x^ is tstr8) then
   begin
   if ((x^ as tstr8).pbytes<>nil) then
      begin
      //init
      dmax:=-2;
      //get
      smem:=(x^ as tstr8).core;
      for p:=xfrom to xto do
      begin
      v:=smem[p];
      if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
      dmem[xpos+p-xfrom-dmin]:=v;
      end;//p
      end;
   end
else if (x^ is tstr9) then
   begin
   //init
   smax:=-2;
   dmax:=-2;
   //get
   for p:=xfrom to xto do
   begin
   if (p>smax)              and (not block__fastinfo(x,p,smem,smin,smax))              then goto skipend;
   if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
   v:=smem[p-smin];
   dmem[xpos+p-xfrom-dmin]:=v;
   end;//p
   end;

//successful
result:=true;
skipend:
except;end;
try;str__autofree(x);except;end;
end;

//array support ----------------------------------------------------------------
function tstr9.aadd(const x:array of byte):boolean;
begin
result:=ains2(x,ilen,0,max32);
end;

function tstr9.aadd1(const x:array of byte;xpos1,xlen:longint):boolean;
begin
result:=ains2(x,ilen,xpos1-1,xpos1-1+xlen);
end;

function tstr9.aadd2(const x:array of byte;xfrom,xto:longint):boolean;
begin
result:=ains2(x,ilen,xfrom,xto);
end;

function tstr9.ains(const x:array of byte;xpos:longint):boolean;
begin
result:=ains2(x,xpos,0,max32);
end;

function tstr9.ains2(const x:array of byte;xpos,xfrom,xto:longint):boolean;
label
   skipend;
var
   dmin,dmax,slen,dlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;

try

//check
if (xto<xfrom) then goto skipend;

//range
xfrom:=frcrange32(xfrom,low(x),high(x));
xto  :=frcrange32(xto  ,low(x),high(x));
if (xto<xfrom) then goto skipend;

//init
xpos:=frcrange32(xpos,0,ilen);//allow to write past end
slen:=ilen;
dlen:=slen+(xto-xfrom+1);

//check
if not minlen(dlen) then goto skipend;

//shift up
if (xpos<slen) and (not xshiftup(xpos,xto-xfrom+1)) then goto skipend;

//copy + size
dmax:=-2;
for p:=xfrom to xto do
begin
v:=x[p];
if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-xfrom-dmin]:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;

function tstr9.padd(x:pdlbyte;xsize:longint):boolean;//15feb2024
begin
if (xsize<=0) then result:=true else result:=pins2(x,xsize,ilen,0,xsize-1);
end;

function tstr9.pins2(x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;
label
   skipend;
var
   dmin,dmax,slen,dlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;

try
//check
if (x=nil) or (xcount<=0) then
   begin
   result:=true;
   exit;
   end;
if (xto<xfrom) then exit;

//range
xfrom:=frcrange32(xfrom,0,xcount-1);
xto  :=frcrange32(xto  ,0,xcount-1);
if (xto<xfrom) then exit;

//init
xpos:=frcrange32(xpos,0,ilen);//allow to write past end
slen:=ilen;
dlen:=slen+(xto-xfrom+1);
minlen(dlen);

//shift up
if (xpos<slen) and (not xshiftup(xpos,xto-xfrom+1)) then goto skipend;

//copy + size
dmax:=-2;

for p:=xfrom to xto do
begin
v:=x[p];
if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-xfrom-dmin]:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;

//string support ---------------------------------------------------------------
function tstr9.sadd(const x:string):boolean;
begin
result:=sins2(x,ilen,0,max32);
end;

function tstr9.sadd2(const x:string;xfrom,xto:longint):boolean;
begin
result:=sins2(x,ilen,xfrom,xto);
end;

function tstr9.sadd3(const x:string;xfrom,xlen:longint):boolean;
begin
if (xlen>=1) then result:=sins2(x,ilen,xfrom,xfrom+xlen-1) else result:=true;
end;

function tstr9.sins(const x:string;xpos:longint):boolean;
begin
result:=sins2(x,xpos,0,max32);
end;

function tstr9.sins2(const x:string;xpos,xfrom,xto:longint):boolean;
label
   skipend;
var//Always zero based for "xfrom" and "xto"
   dmin,dmax,xlen,slen,dlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;

try
//check
xlen:=low__len(x);
if (xlen<=0) then
   begin
   result:=true;
   exit;
   end;

//check #2
if (xto<xfrom) then exit;

//range
xfrom:=frcrange32(xfrom,0,xlen-1);
xto  :=frcrange32(xto  ,0,xlen-1);
if (xto<xfrom) then exit;

//init
xpos:=frcrange32(xpos,0,ilen);//allow to write past end
slen:=ilen;
dlen:=slen+(xto-xfrom+1);

//check
if not minlen(dlen) then goto skipend;

//shift up
if (xpos<slen) and (not xshiftup(xpos,xto-xfrom+1)) then goto skipend;

//copy + size
dmax:=-2;
for p:=xfrom to xto do
begin
v:=byte(x[p+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
if ((xpos+p-xfrom)>dmax) and (not block__fastinfo(@self,xpos+p-xfrom,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-xfrom-dmin]:=v;
end;//p

//successful
result:=true;
skipend:
except;end;
end;

function tstr9.same(x:pobject):boolean;
begin
result:=same2(0,x);
end;

function tstr9.same2(xfrom:longint;x:pobject):boolean;
label
   skipend;
var
   i,p:longint;
begin
//defaults
result:=false;

try
//check
if (x=nil) or (x^=nil) then exit;
//get
if str__lock(x) then
   begin
   //init
   if (xfrom<0) then xfrom:=0;
   //get
   if (x^ is tstr8) and (str__len(x)>=1) and ((x^ as tstr8).pbytes<>nil) then
      begin
      //get
      for p:=0 to (str__len(x)-1) do
      begin
      i:=xfrom+p;
      if (i>=ilen) or (getv(i)<>(x^ as tstr8).pbytes[p]) then goto skipend;
      end;//p
      end
   else if (x^ is tstr9) and (str__len(x)>=1) then
      begin
      //get
      for p:=0 to (str__len(x)-1) do
      begin
      i:=xfrom+p;
      if (i>=ilen) or (getv(i)<>(x^ as tstr9).bytes[p]) then goto skipend;
      end;//p
      end;
   //successful
   result:=true;
   end;
skipend:
except;end;
try;str__uaf(x);except;end;
end;

function tstr9.asame(const x:array of byte):boolean;
begin
result:=asame3(0,x,true);
end;

function tstr9.asame2(xfrom:longint;const x:array of byte):boolean;
begin
result:=asame3(xfrom,x,true);
end;

function tstr9.asame3(xfrom:longint;const x:array of byte;xcasesensitive:boolean):boolean;
begin
result:=asame4(xfrom,low(x),high(x),x,xcasesensitive);
end;

function tstr9.asame4(xfrom,xmin,xmax:longint;const x:array of byte;xcasesensitive:boolean):boolean;
label
   skipend;
var
   i,p:longint;
   sv,v:byte;
begin
result:=false;

try
//check
if (sizeof(x)=0) or (ilen=0) then exit;
//range
if (xfrom<0) then xfrom:=0;
//init
xmin:=frcrange32(xmin,low(x),high(x));
xmax:=frcrange32(xmax,low(x),high(x));
if (xmin>xmax) then exit;
//get
for p:=xmin to xmax do
begin
i:=xfrom+(p-xmin);
if (i>=ilen) or (i<0) then goto skipend//22aug2020
else if xcasesensitive and (x[p]<>getv(i)) then goto skipend
else
   begin
   sv:=x[p];
   v:=getv(i);
   if (sv>=65) and (sv<=90) then inc(sv,32);
   if (v>=65)  and (v<=90)  then inc(v,32);
   if (sv<>v) then goto skipend;
   end;
end;//p
//successful
result:=true;
skipend:
except;end;
end;

function tstr9.del3(xfrom,xlen:longint):boolean;//06feb2024
begin
result:=del(xfrom,xfrom+xlen-1);
end;

function tstr9.del(xfrom,xto:longint):boolean;//06feb2024
label
   skipend;
var
   smin,dmin,smax,dmax,p,int1:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=true;//pass-thru

try
//check
if (ilen<=0) or (xfrom>xto) or (xto<0) or (xfrom>=ilen) then exit;
//get
if frcrange2(xfrom,0,ilen-1) and frcrange2(xto,xfrom,ilen-1) then
   begin
   //shift down
   int1:=xto+1;
   if (int1<ilen) then
      begin
      //init
      smax:=-2;
      dmax:=-2;
      //get
      for p:=int1 to (ilen-1) do
      begin
      if (p>smax) and (not block__fastinfo(@self,p,smem,smin,smax)) then goto skipend;
      v:=smem[p-smin];

      if ((xfrom+p-int1)>dmax) and (not block__fastinfo(@self,xfrom+p-int1,dmem,dmin,dmax)) then goto skipend;
      dmem[xfrom+p-int1-dmin]:=v;
      end;//p
      end;
   //resize
   result:=setlen(ilen-(xto-xfrom+1));
   end;
skipend:
except;end;
end;

//add support ------------------------------------------------------------------
function tstr9.addcmp8(xval:comp):boolean;
begin
result:=aadd(tcmp8(xval).bytes);
end;

function tstr9.addcur8(xval:currency):boolean;
begin
result:=aadd(tcur8(xval).bytes);
end;

function tstr9.addRGBA4(r,g,b,a:byte):boolean;
begin
result:=aadd([r,g,b,a]);
end;

function tstr9.addRGB3(r,g,b:byte):boolean;
begin
result:=aadd([r,g,b]);
end;

function tstr9.addint4(xval:longint):boolean;
begin
result:=aadd(tint4(xval).bytes);
end;

function tstr9.addint4R(xval:longint):boolean;
begin
xval:=low__intr(xval);//swap round
result:=aadd(tint4(xval).bytes);
end;

function tstr9.addint3(xval:longint):boolean;
var
   r,g,b:byte;
begin
low__int3toRGB(xval,r,g,b);
result:=aadd([r,g,b]);
end;

function tstr9.addwrd2(xval:word):boolean;
begin
result:=aadd(twrd2(xval).bytes);//16aug2020
end;

function tstr9.addwrd2R(xval:word):boolean;
begin
xval:=low__wrdr(xval);//swap round
result:=aadd(twrd2(xval).bytes);//16aug2020
end;

function tstr9.addsmi2(xval:smallint):boolean;//01aug2021
var
   a:twrd2;
begin
a.si:=xval;
result:=aadd([a.bytes[0],a.bytes[1]]);
end;

function tstr9.addbyt1(xval:byte):boolean;
begin
result:=aadd([xval]);
end;

function tstr9.addbol1(xval:boolean):boolean;//21aug2020
begin
if xval then result:=aadd([1]) else result:=aadd([0]);
end;

function tstr9.addchr1(xval:char):boolean;
begin
result:=aadd([byte(xval)]);
end;

function tstr9.addstr(xval:string):boolean;
begin
result:=false;try;result:=sadd(xval);except;end;
end;

function tstr9.addrec(a:pointer;asize:longint):boolean;//07feb2022
begin
result:=pins2(pdlbyte(a),asize,ilen,0,asize-1);
end;

//get support ------------------------------------------------------------------
function tstr9.getc8(xpos:longint):tcolor8;
begin
if (xpos>=0) and (xpos<ilen) then result:=bytes[xpos] else result:=0;
end;

function tstr9.getc24(xpos:longint):tcolor24;
begin
if (xpos>=0) and ((xpos+2)<ilen) then
   begin
   result.b:=bytes[xpos+0];
   result.g:=bytes[xpos+1];
   result.r:=bytes[xpos+2];
   end
else
   begin
   result.b:=0;
   result.g:=0;
   result.r:=0;
   end;
end;

function tstr9.getc32(xpos:longint):tcolor32;
begin
if (xpos>=0) and ((xpos+3)<ilen) then
   begin
   result.b:=bytes[xpos+0];
   result.g:=bytes[xpos+1];
   result.r:=bytes[xpos+2];
   result.a:=bytes[xpos+3];
   end
else
   begin
   result.b:=0;
   result.g:=0;
   result.r:=0;
   result.a:=255;
   end;
end;

function tstr9.getc40(xpos:longint):tcolor40;
begin
if (xpos>=0) and ((xpos+4)<ilen) then
   begin
   result.b:=bytes[xpos+0];
   result.g:=bytes[xpos+1];
   result.r:=bytes[xpos+2];
   result.a:=bytes[xpos+3];
   result.c:=bytes[xpos+4];
   end
else
   begin
   result.b:=0;
   result.g:=0;
   result.r:=0;
   result.a:=255;
   result.c:=0;
   end;
end;

function tstr9.getcmp8(xpos:longint):comp;
var
   a:tcmp8;
begin
if (xpos>=0) and ((xpos+7)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   a.bytes[2]:=bytes[xpos+2];
   a.bytes[3]:=bytes[xpos+3];
   a.bytes[4]:=bytes[xpos+4];
   a.bytes[5]:=bytes[xpos+5];
   a.bytes[6]:=bytes[xpos+6];
   a.bytes[7]:=bytes[xpos+7];
   result:=a.val;
   end
else result:=0;
end;

function tstr9.getcur8(xpos:longint):currency;
var
   a:tcur8;
begin
if (xpos>=0) and ((xpos+7)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   a.bytes[2]:=bytes[xpos+2];
   a.bytes[3]:=bytes[xpos+3];
   a.bytes[4]:=bytes[xpos+4];
   a.bytes[5]:=bytes[xpos+5];
   a.bytes[6]:=bytes[xpos+6];
   a.bytes[7]:=bytes[xpos+7];
   result:=a.val;
   end
else result:=0;
end;

function tstr9.getint4(xpos:longint):longint;
var
   a:tint4;
begin
if (xpos>=0) and ((xpos+3)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   a.bytes[2]:=bytes[xpos+2];
   a.bytes[3]:=bytes[xpos+3];
   result:=a.val;
   end
else result:=0;
end;

function tstr9.getint4i(xindex:longint):longint;
begin
result:=getint4(xindex*4);
end;

function tstr9.getint4R(xpos:longint):longint;//14feb2021
var
   a:tint4;
begin
if (xpos>=0) and ((xpos+3)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+3];//swap round
   a.bytes[1]:=bytes[xpos+2];
   a.bytes[2]:=bytes[xpos+1];
   a.bytes[3]:=bytes[xpos+0];
   result:=a.val;
   end
else result:=0;
end;

function tstr9.getint3(xpos:longint):longint;
begin
if (xpos>=0) and ((xpos+2)<ilen) then result:=bytes[xpos+0]+(bytes[xpos+1]*256)+(bytes[xpos+2]*256*256) else result:=0;
end;

function tstr9.getsml2(xpos:longint):smallint;//28jul2021
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   result:=a.si;
   end
else result:=0;
end;

function tstr9.getwrd2(xpos:longint):word;
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+0];
   a.bytes[1]:=bytes[xpos+1];
   result:=a.val;
   end
else result:=0;
end;

function tstr9.getwrd2R(xpos:longint):word;//14feb2021
var
   a:twrd2;
begin
if (xpos>=0) and ((xpos+1)<ilen) then
   begin
   a.bytes[0]:=bytes[xpos+1];//swap round
   a.bytes[1]:=bytes[xpos+0];
   result:=a.val;
   end
else result:=0;
end;

function tstr9.getbyt1(xpos:longint):byte;
begin
if (xpos>=0) and (xpos<ilen) then result:=bytes[xpos] else result:=0;
end;

function tstr9.getbol1(xpos:longint):boolean;
begin
if (xpos>=0) and (xpos<ilen) then result:=(bytes[xpos]<>0) else result:=false;
end;

function tstr9.getchr1(xpos:longint):char;
begin
if (xpos>=0) and (xpos<ilen) then result:=char(bytes[xpos]) else result:=#0;
end;

function tstr9.getstr(xpos,xlen:longint):string;//fixed - 16aug2020
var
   dlen,p:longint;
begin
result:='';

try
if (xlen>=1) and (xpos>=0) and (xpos<ilen) then
   begin
   dlen:=frcmax32(xlen,ilen-xpos);
   if (dlen>=1) then
      begin
      low__setlen(result,dlen);
      for p:=xpos to (xpos+dlen-1) do result[p-xpos+stroffset]:=char(bytes[p]);
      end;
   end;
except;end;
end;

function tstr9.getstr1(xpos,xlen:longint):string;
begin
result:=getstr(xpos-1,xlen);
end;

function tstr9.getnullstr(xpos,xlen:longint):string;//20mar2022
var
   dcount,dlen,p:longint;
   v:byte;
begin
result:='';

try
if (xlen>=1) and (xpos>=0) and (xpos<ilen) then
   begin
   dlen:=frcmax32(xlen,ilen-xpos);
   if (dlen>=1) then
      begin
      low__setlen(result,dlen);
      dcount:=0;
      for p:=xpos to (xpos+dlen-1) do
      begin
      if (bytes[p]=0) then
         begin
         if (dcount<>dlen) then low__setlen(result,dcount);
         break;
         end;
      //was: result[p-xpos+stroffset]:=char(ibytes[p]);
      v:=bytes[p];
      result[p-xpos+stroffset]:=char(v);
      inc(dcount);
      end;//p
      end;
   end;
except;end;
end;

function tstr9.getnullstr1(xpos,xlen:longint):string;//20mar2022
begin
result:=getnullstr(xpos-1,xlen);
end;

function tstr9.gettext:string;
label
   skipend;
var
   smin,smax,p:longint;
   smem:pdlbyte;
   v:byte;
begin
//defaults
result:='';

try
//get
if (ilen>=1) then
   begin
   //init
   smax:=-2;
   low__setlen(result,ilen);
   //get
   for p:=0 to (ilen-1) do
   begin
   if (p>smax) and (not block__fastinfo(@self,p,smem,smin,smax)) then goto skipend;
   v:=smem[p-smin];
   result[p+stroffset]:=char(v);
   end;//p
   end;
skipend:
except;end;
end;

function tstr9.gettextarray:string;
label
   skipend;
var
   a,aline:tstr8;
   smin,smax,xmax,p:longint;
   smem:pdlbyte;
   v:byte;
begin
//defaults
result:='';

try
a:=nil;
aline:=nil;
//check
if (ilen<=0) then goto skipend;
//init
a:=str__new8;
aline:=str__new8;
xmax:=ilen-1;
smax:=-2;
//get
for p:=0 to xmax do
begin
if (p>smax) and (not block__fastinfo(@self,p,smem,smin,smax)) then goto skipend;
v:=smem[p-smin];
aline.sadd(intstr32(v)+insstr(',',p<xmax));
if (aline.count>=1010) then
   begin
   aline.sadd(rcode);
   a.add(aline);
   aline.clear;
   end;
end;//p
//.finalise
if (aline.count>=1) then
   begin
   a.add(aline);
   aline.clear;
   end;
//set
result:=':array[0..'+intstr32(ilen-1)+'] of byte=('+rcode+a.text+');';//cleaned 02mar2022
skipend:
except;end;
try
str__free(@a);
str__free(@aline);
except;end;
end;

//set support ------------------------------------------------------------------
procedure tstr9.setc8(xpos:longint;xval:tcolor8);
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+1) then exit;
bytes[xpos]:=xval;
end;

procedure tstr9.setc24(xpos:longint;xval:tcolor24);
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+3) then exit;
bytes[xpos+0]:=xval.b;
bytes[xpos+1]:=xval.g;
bytes[xpos+2]:=xval.r;
end;

procedure tstr9.setc32(xpos:longint;xval:tcolor32);
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+4) then exit;
bytes[xpos+0]:=xval.b;
bytes[xpos+1]:=xval.g;
bytes[xpos+2]:=xval.r;
bytes[xpos+3]:=xval.a;
end;

procedure tstr9.setc40(xpos:longint;xval:tcolor40);
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+5) then exit;
bytes[xpos+0]:=xval.b;
bytes[xpos+1]:=xval.g;
bytes[xpos+2]:=xval.r;
bytes[xpos+3]:=xval.a;
bytes[xpos+4]:=xval.c;
end;

procedure tstr9.setcmp8(xpos:longint;xval:comp);
var
   a:tcmp8;
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+8) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
bytes[xpos+2]:=a.bytes[2];
bytes[xpos+3]:=a.bytes[3];
bytes[xpos+4]:=a.bytes[4];
bytes[xpos+5]:=a.bytes[5];
bytes[xpos+6]:=a.bytes[6];
bytes[xpos+7]:=a.bytes[7];
end;

procedure tstr9.setcur8(xpos:longint;xval:currency);
var
   a:tcur8;
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+8) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
bytes[xpos+2]:=a.bytes[2];
bytes[xpos+3]:=a.bytes[3];
bytes[xpos+4]:=a.bytes[4];
bytes[xpos+5]:=a.bytes[5];
bytes[xpos+6]:=a.bytes[6];
bytes[xpos+7]:=a.bytes[7];
end;

procedure tstr9.setint4(xpos:longint;xval:longint);
var
   a:tint4;
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+4) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
bytes[xpos+2]:=a.bytes[2];
bytes[xpos+3]:=a.bytes[3];
end;

procedure tstr9.setint4i(xindex:longint;xval:longint);
begin
setint4(xindex*4,xval);
end;

procedure tstr9.setint4R(xpos:longint;xval:longint);
var
   a:tint4;
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+4) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[3];//swap round
bytes[xpos+1]:=a.bytes[2];
bytes[xpos+2]:=a.bytes[1];
bytes[xpos+3]:=a.bytes[0];
end;

procedure tstr9.setint3(xpos:longint;xval:longint);
var
   r,g,b:byte;
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+3) then exit;
low__int3toRGB(xval,r,g,b);
bytes[xpos+0]:=r;
bytes[xpos+1]:=g;
bytes[xpos+2]:=b;
end;

procedure tstr9.setsml2(xpos:longint;xval:smallint);
var
   a:twrd2;
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+2) then exit;
a.si:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
end;

procedure tstr9.setwrd2(xpos:longint;xval:word);
var
   a:twrd2;
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+2) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[0];
bytes[xpos+1]:=a.bytes[1];
end;

procedure tstr9.setwrd2R(xpos:longint;xval:word);
var
   a:twrd2;
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+2) then exit;
a.val:=xval;
bytes[xpos+0]:=a.bytes[1];//swap round
bytes[xpos+1]:=a.bytes[0];
end;

procedure tstr9.setbyt1(xpos:longint;xval:byte);
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+1) then exit;
bytes[xpos]:=xval;
end;

procedure tstr9.setbol1(xpos:longint;xval:boolean);
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+1) then exit;
if xval then bytes[xpos]:=1 else bytes[xpos]:=0;
end;

procedure tstr9.setchr1(xpos:longint;xval:char);
begin
if (xpos<0) then xpos:=0;
if not minlen(xpos+1) then exit;
bytes[xpos]:=byte(xval);
end;

procedure tstr9.setstr(xpos:longint;xlen:longint;xval:string);
label
   skipend;
var
   dmin,dmax,xminlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
try
if (xpos<0) then xpos:=0;
if (xlen<=0) or (xval='') then exit;
xlen:=frcmax32(xlen,low__len(xval));
xminlen:=xpos+xlen;
if not minlen(xminlen) then exit;
dmax:=-2;
//was: ERROR: for p:=xpos to (xpos+xlen-1) do ibytes[p]:=ord(xval[p+stroffset]);
//was: for p:=0 to (xlen-1) do ibytes[xpos+p]:=ord(xval[p+stroffset]);
for p:=0 to (xlen-1) do
begin
v:=ord(xval[p+stroffset]);
if ((xpos+p)>dmax) and (not block__fastinfo(@self,xpos+p,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-dmin]:=v;
end;//p
skipend:
except;end;
end;

procedure tstr9.setstr1(xpos:longint;xlen:longint;xval:string);
begin
setstr(xpos-1,xlen,xval);
end;

function tstr9.setarray(xpos:longint;const xval:array of byte):boolean;
label
   skipend;
var
   dmin,dmax,xminlen,xmin,xmax,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;

try
//get
if (xpos<0) then xpos:=0;
xmin:=low(xval);
xmax:=high(xval);
xminlen:=xpos+(xmax-xmin+1);
if not minlen(xminlen) then exit;
dmax:=-2;
//was: for p:=xmin to xmax do ibytes[xpos+(p-xmin)]:=xval[p];
for p:=xmin to xmax do
begin
v:=xval[p];
if ((xpos+p-xmin)>dmax) and (not block__fastinfo(@self,xpos+p-xmin,dmem,dmin,dmax)) then goto skipend;
dmem[xpos+p-xmin-dmin]:=v;
end;//p
//successful
result:=true;
skipend:
except;end;
end;

procedure tstr9.settext(const x:string);
label
   skipend;
var
   dmin,dmax,xlen,p:longint;
   dmem:pdlbyte;
   v:byte;
begin
try
xlen:=low__len(x);
setlen(xlen);
if (xlen>=1) then
   begin
   //init
   dmax:=-2;
   //get
   for p:=1 to xlen do
   begin
   v:=byte(x[p-1+stroffset]);
   if ((p-1)>dmax) and (not block__fastinfo(@self,p-1,dmem,dmin,dmax)) then goto skipend;
   dmem[p-1-dmin]:=v;
   end;//p
   end;
skipend:
except;end;
end;


//## tmemstr ###################################################################
{$ifdef laz}
constructor tmemstr.create(_ptr:tobject);
begin
if classnameis('tmemstr') then track__inc(satOther,1);
inherited create;
idata:=_ptr;
iposition:=0;
end;

destructor tmemstr.destroy;
begin
inherited destroy;
if classnameis('tmemstr') then track__inc(satOther,-1);
end;

function tmemstr.read(var x;xlen:longint):longint;
var
   p:longint;
   d:pdlbyte;
begin
result:=0;

try
//set
if str__ok(@idata) then
   begin
   result:=str__len(@idata)-iposition;
   if (result>xlen) then result:=xlen;

   if (result>=1) then
      begin
      d:=addr(x);
      for p:=iposition to (iposition+result-1) do d[p-iposition]:=str__bytes0(@idata,p);
      end;

   inc(iposition,result);
   end;
except;end;
end;

function tmemstr.write(const x;xlen:longint):longint;
var
   p:longint;
   d:pdlbyte;
begin
result:=0;

try
//set
if str__ok(@idata) then
  begin
  result:=xlen;
  str__setlen(@idata,iposition+result);
  if (result>=1) then
     begin
     d:=addr(x);
     for p:=0 to (result-1) do str__setbytes0(@idata,iposition+p,d[p]);
     end;

  inc(iposition,result);
  end;
except;end;
end;

function tmemstr.seek(offset:longint;origin:word):longint;
begin
result:=0;

try
//check
if not str__ok(@idata) then
   begin
   iposition:=0;
   exit;
   end;

//set
case Origin of
soFromBeginning :iposition:=offset;
soFromCurrent   :iposition:=iposition+offset;
soFromEnd       :iposition:=str__len(@idata)-offset;
end;

//range
iposition:=frcrange32(iposition,0,str__len(@idata));

//return result
result:=iposition;
except;end;
end;

function tmemstr.readstring(count:longint):string;
var
  len:longint;
begin
//defaults
result:='';

try
//check
if not str__ok(@idata) then exit;

//get
len:=str__len(@idata)-iposition;
if (len>count) then len:=count;
result:=str__str1(@idata,iposition+1,len);
inc(iposition,len);
except;end;
end;

procedure tmemstr.writestring(const x:string);
begin
try;str__settextb(@idata,x);except;end;
end;

procedure tmemstr.setsize(newsize:longint);
begin
if str__ok(@idata) then
   begin
   str__setlen(@idata,newsize);
   if (iposition>newsize) then iposition:=newsize;
   end;
end;
{$endif}


//## tvars8 ####################################################################
constructor tvars8.create;
begin

if classnameis('tvars8') then track__inc(satVars8,1);
zzadd(self);

inherited create;

icore:=str__new8;
ofullcompatibility:=true;//now accepts 4 input modes: 1. "name:", 2. "name: value", 3. "name:value" and 4. "name.....(last non-space)"

end;

destructor tvars8.destroy;
begin
try

str__free(@icore);

inherited destroy;
if classnameis('tvars8') then track__inc(satVars8,-1);

except;end;
end;

function tvars8.tofile(x:string;var e:string):boolean;//12may2025
var
   b:tstr8;
begin
//defaults
result:=false;
e:=gecTaskfailed;
b:=nil;

try
//get
b:=str__new8;
b.text:=text;
result:=io__tofile(x,@b,e);
except;end;
//free
str__free(@b);
end;

function tvars8.fromfile(x:string;var e:string):boolean;//12may2025
var
   b:tstr8;
begin
//defaults
result:=false;
e:=gecTaskfailed;
b:=nil;

try
//get
b:=str__new8;
if io__fromfile(x,@b,e) then
   begin
   text:=b.text;
   result:=true;
   end;
except;end;
//free
str__free(@b);
end;

function tvars8.len:longint;
begin
result:=icore.len;
end;

procedure tvars8.clear;
begin
icore.clear;
end;

function tvars8.bdef(xname:string;xdefval:boolean):boolean;
begin
if found(xname) then result:=b[xname] else result:=xdefval;
end;

function tvars8.idef(xname:string;xdefval:longint):longint;
begin
if found(xname) then result:=i[xname] else result:=xdefval;
end;

function tvars8.idef2(xname:string;xdefval,xmin,xmax:longint):longint;
begin
if found(xname) then result:=i[xname] else result:=xdefval;
//range
result:=frcrange32(result,xmin,xmax);
end;

function tvars8.idef64(xname:string;xdefval:comp):comp;
begin
if found(xname) then result:=i64[xname] else result:=xdefval;
end;

function tvars8.idef642(xname:string;xdefval,xmin,xmax:comp):comp;
begin
if found(xname) then result:=i64[xname] else result:=xdefval;
//range
result:=frcrange64(result,xmin,xmax);
end;

function tvars8.sdef(xname,xdefval:string):string;
begin
if found(xname) then result:=s[xname] else result:=xdefval;
end;

function tvars8.getb(xname:string):boolean;
begin
result:=(i[xname]<>0);
end;

procedure tvars8.setb(xname:string;xval:boolean);
begin
if xval then xsets(xname,'1') else xsets(xname,'0');
end;

function tvars8.geti(xname:string):longint;
begin
result:=strint(value[xname]);
end;

procedure tvars8.seti(xname:string;xval:longint);
begin
xsets(xname,intstr32(xval));
end;

function tvars8.geti64(xname:string):comp;
begin
result:=strint64(value[xname]);
end;

procedure tvars8.seti64(xname:string;xval:comp);
begin
xsets(xname,intstr64(xval));
end;

function tvars8.getdt64(xname:string):tdatetime;
var
   y,m,d,hh,mm,ss,ms:word;
   a:tstr8;
begin
//defaults
result:=0;

try
//init
a:=nil;
a:=str__new8;
//get
a.text:=gets(xname);
if (a.len>=8) then
   begin
   ms:=frcrange32(a.wrd2[7],0,999);//7..8
   ss:=frcrange32(a.byt1[6],0,59);//6
   mm:=frcrange32(a.byt1[5],0,59);//5
   hh:=frcrange32(a.byt1[4],0,23);//4
   d:=frcrange32(a.byt1[3],1,31);//3
   m:=frcrange32(a.byt1[2],1,12);//2
   y:=a.wrd2[0];
   //set
   result:=low__safedate(low__encodedate2(y,m,d)+low__encodetime2(hh,mm,ss,ms));
   end;
except;end;
try;str__free(@a);except;end;
end;

procedure tvars8.setdt64(xname:string;xval:tdatetime);//31jan2022
var
   y,m,d,hh,mm,ss,ms:word;
   a:tstr8;
begin
try
a:=nil;
a:=str__new8;
low__decodedate2(xval,y,m,d);
low__decodetime2(xval,hh,mm,ss,ms);
a.wrd2[7]:=frcrange32(ms,0,999);//7..8
a.byt1[6]:=frcrange32(ss,0,59);//6
a.byt1[5]:=frcrange32(mm,0,59);//5
a.byt1[4]:=frcrange32(hh,0,23);//4
a.byt1[3]:=frcrange32(d,1,31);//3
a.byt1[2]:=frcrange32(m,1,12);//2
a.wrd2[0]:=y;//0..1
xsets(xname,a.text);
except;end;
try;str__free(@a);except;end;
end;

function tvars8.getc(xname:string):currency;
begin
result:=strtofloatex(value[xname]);
end;

procedure tvars8.setc(xname:string;xval:currency);
begin
xsets(xname,floattostrex2(xval));
end;

function tvars8.gets(xname:string):string;
var
   xpos,nlen,dlen,blen:longint;
begin
if xfind(xname,xpos,nlen,dlen,blen) and zzok(icore,7075) then result:=icore.str[xpos+16+nlen,dlen] else result:='';
end;

procedure tvars8.sets(xname,xvalue:string);
begin
xsets(xname,xvalue);
end;

function tvars8.getd(xname:string):tstr8;//28jun2024: optimised, 27apr2021
var
   xpos,nlen,dlen,blen:longint;
begin
result:=str__new8;
if (result<>nil) then
   begin
   if xfind(xname,xpos,nlen,dlen,blen) then str__add31(@result,@icore,(xpos+1)+16+nlen,dlen);
   result.oautofree:=true;
   end;
end;

function tvars8.dget(xname:string;xdata:tstr8):boolean;//2dec2021
var
   xpos,nlen,dlen,blen:longint;
begin
result:=false;

try
if not str__lock(@xdata) then exit;
if xfind(xname,xpos,nlen,dlen,blen) then
   begin
   xdata.clear;
   xdata.add3(icore,(xpos+0)+16+nlen,dlen);
   result:=true;
   end;
except;end;
try
if not result then xdata.clear;
str__uaf(@xdata);
except;end;
end;

procedure tvars8.setd(xname:string;xvalue:tstr8);
begin
xsetd(xname,xvalue);
end;

function tvars8.bok(xname:string;xval:boolean):boolean;
begin
result:=(xval<>b[xname]);
if result then b[xname]:=xval;
end;

function tvars8.iok(xname:string;xval:longint):boolean;
begin
result:=(xval<>i[xname]);
if result then i[xname]:=xval;
end;

function tvars8.i64ok(xname:string;xval:comp):boolean;
begin
result:=(xval<>i64[xname]);
if result then i64[xname]:=xval;
end;

function tvars8.cok(xname:string;xval:currency):boolean;
begin
result:=(xval<>c[xname]);
if result then c[xname]:=xval;
end;

function tvars8.sok(xname,xval:string):boolean;
begin
result:=(xval<>s[xname]);
if result then s[xname]:=xval;
end;

function tvars8.found(xname:string):boolean;
var
   xpos,nlen,dlen,blen:longint;
begin
result:=xfind(xname,xpos,nlen,dlen,blen);
end;

function tvars8.xfind(xname:string;var xpos,nlen,dlen,blen:longint):boolean;
label
   redo;
var
   xlen:longint;
   v:tint4;
   c,nref:tcur8;
   lb:pdlbyte;
begin
//defaults
result:=false;

try
xpos:=0;
nlen:=0;
dlen:=0;
blen:=0;
//check
if zznil(icore,2266) or (icore.pbytes=nil) then exit;//27apr2021
//init
xlen:=icore.len;
lb:=icore.pbytes;
nref.val:=low__ref256u(xname);
//find
redo:
if ((xpos+15)<xlen) then
   begin
   //nlen/4 - name length
   v.bytes[0]:=lb[xpos+0];
   v.bytes[1]:=lb[xpos+1];
   v.bytes[2]:=lb[xpos+2];
   v.bytes[3]:=lb[xpos+3];
   if (v.val<0) then v.val:=0;
   nlen:=v.val;
   //dlen/4 - data length
   v.bytes[0]:=lb[xpos+4];
   v.bytes[1]:=lb[xpos+5];
   v.bytes[2]:=lb[xpos+6];
   v.bytes[3]:=lb[xpos+7];
   if (v.val<0) then v.val:=0;
   dlen:=v.val;
   //nref/8
   c.bytes[0]:=lb[xpos+8];
   c.bytes[1]:=lb[xpos+9];
   c.bytes[2]:=lb[xpos+10];
   c.bytes[3]:=lb[xpos+11];
   c.bytes[4]:=lb[xpos+12];
   c.bytes[5]:=lb[xpos+13];
   c.bytes[6]:=lb[xpos+14];
   c.bytes[7]:=lb[xpos+15];
   //blen - block length "16 + <name> + <data>"
   blen:=16+nlen+dlen;
   //name
   case (c.ints[0]=nref.ints[0]) and (c.ints[1]=nref.ints[1]) and strmatch(xname,icore.str[xpos+16,nlen]) of
   true:result:=true;
   else begin//inc to next block
      inc(xpos,blen);
      goto redo;
      end;
   end;//case
   end;
except;end;
end;

function tvars8.xnext(var xfrom,xpos,nlen,dlen,blen:longint):boolean;
var
   xlen:longint;
   v:tint4;
   lb:pdlbyte;
begin
//defaults
result:=false;

try
if (xfrom<0) then xfrom:=0;
xpos:=0;
nlen:=0;
dlen:=0;
blen:=0;
//check
if zznil(icore,2269) or (icore.pbytes=nil) then exit;//27apr2021
//init
xlen:=icore.len;
lb:=icore.pbytes;
//find
if ((xfrom+15)<xlen) then
   begin
   //nlen/4 - name length
   v.bytes[0]:=lb[xfrom+0];
   v.bytes[1]:=lb[xfrom+1];
   v.bytes[2]:=lb[xfrom+2];
   v.bytes[3]:=lb[xfrom+3];
   if (v.val<0) then v.val:=0;
   nlen:=v.val;
   //dlen/4 - data length
   v.bytes[0]:=lb[xfrom+4];
   v.bytes[1]:=lb[xfrom+5];
   v.bytes[2]:=lb[xfrom+6];
   v.bytes[3]:=lb[xfrom+7];
   if (v.val<0) then v.val:=0;
   dlen:=v.val;
   //blen - block length "16 + <name> + <data>"
   blen:=16+nlen+dlen;
   //name
   xpos:=xfrom;
   inc(xfrom,blen);
   //successful
   result:=true;
   end;
except;end;
end;

function tvars8.xnextname(var xpos:longint;var xname:string):boolean;
var
   nlen,dlen,blen,xlen:longint;
   v:tint4;
   lb:pdlbyte;
begin
//defaults
result:=false;

try
xname:='';
if (xpos<0) then xpos:=0;
//check
if zznil(icore,2270) or (icore.pbytes=nil) then exit;//27apr2021
//init
xlen:=icore.len;
lb:=icore.pbytes;
//get
if ((xpos+15)<xlen) then
   begin
   //nlen/4 - name length
   v.bytes[0]:=lb[xpos+0];
   v.bytes[1]:=lb[xpos+1];
   v.bytes[2]:=lb[xpos+2];
   v.bytes[3]:=lb[xpos+3];
   if (v.val<0) then v.val:=0;
   nlen:=v.val;
   //dlen/4 - data length
   v.bytes[0]:=lb[xpos+4];
   v.bytes[1]:=lb[xpos+5];
   v.bytes[2]:=lb[xpos+6];
   v.bytes[3]:=lb[xpos+7];
   if (v.val<0) then v.val:=0;
   dlen:=v.val;
   //nref/8
   {
   c.bytes[0]:=lb[xpos+8];
   c.bytes[1]:=lb[xpos+9];
   c.bytes[2]:=lb[xpos+10];
   c.bytes[3]:=lb[xpos+11];
   c.bytes[4]:=lb[xpos+12];
   c.bytes[5]:=lb[xpos+13];
   c.bytes[6]:=lb[xpos+14];
   c.bytes[7]:=lb[xpos+15];
   }
   //blen - block length "16 + <name> + <data>"
   blen:=16+nlen+dlen;
   //name
   xname:=icore.str[xpos+16,nlen];
   //inc
   inc(xpos,blen);
   //successful
   result:=true;
   end;
except;end;
end;

function tvars8.findcount:longint;//10jan2023
label
   redo;
var
   str1:string;
   xpos:longint;
begin
result:=0;
xpos:=0;
redo:
if xnextname(xpos,str1) then
   begin
   inc(result);
   goto redo;
   end;
end;

function tvars8.xdel(xname:string):boolean;//02jan2022
var
   xpos,nlen,dlen,blen:longint;
begin
if (xname<>'') and (not zznil(icore,2271)) and xfind(xname,xpos,nlen,dlen,blen) then
   begin
   bdel1(icore,xpos+1,blen);
   result:=true;
   end
else result:=false;
end;

procedure tvars8.xsets(xname,xvalue:string);
label
   skipend;
var
   p,xpos,xlen,nlen,dlen,blen:longint;
   v:tint4;
   nref:tcur8;
   lb:pdlbyte;
begin
try
//check
if (xname='') or zznil(icore,2271) then goto skipend;
//delete existing
if xfind(xname,xpos,nlen,dlen,blen) then bdel1(icore,xpos+1,blen);
//init
nlen:=low__len(xname);
dlen:=low__len(xvalue);
xpos:=_blen(icore);
blen:=16+nlen+dlen;
xlen:=xpos+blen;
nref.val:=low__ref256u(xname);
//size
if (icore.len<>xlen) and (not icore.setlen(xlen)) then exit;//27apr2021
//check
if (icore.pbytes=nil) then exit;//27apr2021
//init
lb:=icore.pbytes;
//nlen/4
v.val:=nlen;
lb[xpos+0]:=v.bytes[0];
lb[xpos+1]:=v.bytes[1];
lb[xpos+2]:=v.bytes[2];
lb[xpos+3]:=v.bytes[3];
//dlen/4
v.val:=dlen;
lb[xpos+4]:=v.bytes[0];
lb[xpos+5]:=v.bytes[1];
lb[xpos+6]:=v.bytes[2];
lb[xpos+7]:=v.bytes[3];
//nref/8
lb[xpos+8]:=nref.bytes[0];
lb[xpos+9]:=nref.bytes[1];
lb[xpos+10]:=nref.bytes[2];
lb[xpos+11]:=nref.bytes[3];
lb[xpos+12]:=nref.bytes[4];
lb[xpos+13]:=nref.bytes[5];
lb[xpos+14]:=nref.bytes[6];
lb[xpos+15]:=nref.bytes[7];
//name
for p:=1 to nlen do lb[xpos+15+p]:=byte(xname[p-1+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
//data
if (dlen>=1) then
   begin
   for p:=1 to dlen do lb[xpos+15+nlen+p]:=byte(xvalue[p-1+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
   end;
skipend:
except;end;
end;

procedure tvars8.xsetd(xname:string;xvalue:tstr8);//28jun2024: updated
label
   skipend;
var
   p,xpos,xlen,nlen,dlen,blen:longint;
   v:tint4;
   nref:tcur8;
   sb,lb:pdlbyte;
   v8:byte;
begin
try
str__lock(@xvalue);
//check
if (xname='') or zznil(icore,2272) or (icore=xvalue) then goto skipend;
//delete existing
if xfind(xname,xpos,nlen,dlen,blen) then bdel1(icore,xpos+1,blen);
//init
nlen:=low__len(xname);
dlen:=_blen(xvalue);
xpos:=_blen(icore);
blen:=16+nlen+dlen;
xlen:=xpos+blen;
nref.val:=low__ref256u(xname);
//size
if (icore.len<>xlen) and (not icore.setlen(xlen)) then goto skipend;
//check
if (icore.pbytes=nil) then goto skipend;
//init
lb:=icore.pbytes;
//nlen/4
v.val:=nlen;
lb[xpos+0]:=v.bytes[0];
lb[xpos+1]:=v.bytes[1];
lb[xpos+2]:=v.bytes[2];
lb[xpos+3]:=v.bytes[3];
//dlen/4
v.val:=dlen;
lb[xpos+4]:=v.bytes[0];
lb[xpos+5]:=v.bytes[1];
lb[xpos+6]:=v.bytes[2];
lb[xpos+7]:=v.bytes[3];
//nref/8
lb[xpos+8]:=nref.bytes[0];
lb[xpos+9]:=nref.bytes[1];
lb[xpos+10]:=nref.bytes[2];
lb[xpos+11]:=nref.bytes[3];
lb[xpos+12]:=nref.bytes[4];
lb[xpos+13]:=nref.bytes[5];
lb[xpos+14]:=nref.bytes[6];
lb[xpos+15]:=nref.bytes[7];
//name
for p:=1 to nlen do lb[xpos+15+p]:=byte(xname[p-1+stroffset]);//force 8bit conversion from unicode to 8bit binary - 02may2020
//data
if (dlen>=1) then
   begin
   sb:=xvalue.pbytes;
   //was: for p:=1 to dlen do lb[xpos+15+nlen+p]:=sb[p-1];
   //faster - 22apr2022
   for p:=1 to dlen do
   begin
   v8:=sb[p-1];
   lb[xpos+15+nlen+p]:=v8;
   end;//p
   end;
skipend:
except;end;
try;str__uaf(@xvalue);except;end;
end;

function tvars8.gettext:string;
var
   a:tstr8;
begin
result:='';

try
a:=nil;
a:=data;
if (a<>nil) then result:=a.text;
except;end;
try;str__autofree(@a);except;end;
end;

procedure tvars8.settext(const x:string);
begin
data:=bcopystr1(x,1,max32);
end;

function tvars8.getdata:tstr8;
label
   redo;
var
   xfrom,xpos,nlen,dlen,blen:longint;
begin
result:=nil;

try
//defaults
result:=str__newaf8;
//init
xfrom:=0;
//get
redo:
if (result<>nil) and zzok(icore,7076) and xnext(xfrom,xpos,nlen,dlen,blen) then
   begin
   result.sadd(icore.str[xpos+16,nlen]+': '+icore.str[xpos+16+nlen,dlen]+r10);
   goto redo;
   end;
except;end;
end;

procedure tvars8.setdata(xdata:tstr8);//20aug2024: upgraded to handle more data variations, e.g. "name: value" or "name:value" or "name   " -> originally only the first instance was accepted, now all 3 are
label
   redo;
var
   xline:tstr8;
   pmax,xlen,p,xpos:longint;
   lb:pdlbyte;
   xok:boolean;
begin
try
//init
xline:=nil;
clear;
//check
if zznil(xdata,2077) or (icore=xdata) then exit;
//init
str__lock(@xdata);
xline:=str__new8;
xpos:=0;
//get
redo:
if low__nextline0(xdata,xline,xpos) then
   begin
   xlen:=xline.len;
   pmax:=xline.len-1;
   if (pmax>=0) and (xline.pbytes<>nil) then//27apr2021
      begin
      //init
      xok:=false;
      lb:=xline.pbytes;

      //scan for "name: value" divider ":"
      for p:=0 to pmax do if (lb[p]=ssColon) then
         begin

         //"name:"
         if (p=pmax) then
            begin
            xok:=true;
            xsets(xline.str[0,p],'');
            break;
            end

         //"name: value"
         else if (p<pmax) and (lb[p+1]=ssSpace) then
            begin
            xok:=true;
            xsets(xline.str[0,p],xline.str[p+2,pmax+1]);
            break;
            end

         //"name:value"
         else if ofullcompatibility then
            begin
            xok:=true;
            xsets(xline.str[0,p],xline.str[p+1,pmax+1]);
            break;
            end

         else break;

         end;//p

      //"name:value" not found, switch to "name....(last non-space)" where name terminates on last non-space (scans right-to-left)
      if (not xok) and ofullcompatibility then
         begin
         for p:=pmax downto 0 do if (lb[p]<>ssSpace) then
            begin
            xok:=true;
            xsets(xline.str[0,p+1],'');
            break;
            end;
         end;

      end;//pmax

   //fetch next line
   goto redo;
   end;
except;end;
try
str__free(@xline);
str__uaf(@xdata);
except;end;
end;

function tvars8.getbinary(hdr:string):tstr8;
label
   skipend,redo;
const
   nMAXSIZE=high(word);
var
   xfrom,xpos,nlen,dlen,blen:longint;
begin
result:=nil;

try
//defaults
result:=str__newaf8;
//init
xfrom:=0;
//hdr
if (hdr<>'') and (not result.sadd(hdr)) then goto skipend;
//get
redo:
if xnext(xfrom,xpos,nlen,dlen,blen) then
   begin
   //nlen+vlen
   if (nlen>nMAXSIZE) then nlen:=nMAXSIZE;
   if not result.addwrd2(nlen) then goto skipend;
   if not result.addint4(dlen) then goto skipend;
   //name
   if not result.add3(icore,xpos+16,nlen) then goto skipend;
   //data
   if not result.add3(icore,xpos+16+nlen,dlen) then goto skipend;
   //loop
   goto redo;
   end;
skipend:
except;end;
end;

procedure tvars8.setbinary(hdr:string;xval:tstr8);
label
   skipend,redo;
var
   xlen,xpos:longint;
   aname,aval:tstr8;

   function apull:boolean;
   var
      nlen,vlen:longint;
   begin
   //defaults
   result:=false;
   //check
   if (xpos>=xlen) then exit;
   //init
   nlen:=xval.wrd2[xpos+0];//0..1
   vlen:=xval.int4[xpos+2];//2..5
   if (nlen<=0) or (vlen<0) then exit;
   //get
   aname.clear;
   aname.add3(xval,xpos+6,nlen);
   aval.clear;
   if (vlen>=1) then aval.add3(xval,xpos+6+nlen,vlen);
   //inc
   inc(xpos,6+nlen+vlen);
   //successful
   result:=true;
   end;
begin
try
//defaults
clear;
aname:=nil;
aval:=nil;
//check
if zznil(xval,2278) or (icore=xval) then exit;
//init
str__lock(@xval);
aname:=str__new8;
aval:=str__new8;
xpos:=0;
xlen:=xval.len;
//hdr
if (hdr<>'') then
   begin
   aval.add3(xval,0,low__len(hdr));
   if not strmatch(hdr,aval.text) then goto skipend;
   inc(xpos,low__len(hdr));
   end;
//name+value sets
redo:
if apull then
   begin
   xsetd(aname.text,aval);
   goto redo;
   end;
skipend:
except;end;
try
str__free(@aname);
str__free(@aval);
str__uaf(@xval);
except;end;
end;


//## tfastvars #################################################################
constructor tfastvars.create;
begin
//self
if classnameis('tfastvars') then track__inc(satFastvars,1);
zzadd(self);
inherited create;

//vars
ilimit:=high(vn)+1;//24mar2024: fixed
ofullcompatibility:=true;//21aug2024: new
oincludecomments:=true;//24aug2024: new

//clear
clear;
end;

destructor tfastvars.destroy;
begin
try
//self
inherited destroy;
if classnameis('tfastvars') then track__inc(satFastvars,-1);
except;end;
end;

function tfastvars.tofile(x:string;var e:string):boolean;
var
   b:tstr8;
begin
result:=false;
e:=gecTaskfailed;
b:=nil;

try
b:=str__new8;
b.text:=text;
result:=io__tofile(x,@b,e);
except;end;
try;str__free(@b);except;end;
end;

function tfastvars.fromfile(x:string;var e:string):boolean;
var
   b:tstr8;
begin
result:=false;
e:=gecTaskfailed;
b:=nil;

try
b:=str__new8;
if io__fromfile(x,@b,e) then
   begin
   text:=b.text;
   result:=true;
   end;
except;end;
try;str__free(@b);except;end;
end;

procedure tfastvars.setdata(xdata:tstr8);//20aug2024: upgraded to handle more data variations, e.g. "name: value" or "name:value" or "name   " -> originally only the first instance was accepted, now all 3 are
label
   redo;
var
   xline:tstr8;
   pmax,xlen,p,xpos:longint;
   lb:pdlbyte;
   xok:boolean;
begin
try
//init
xline:=nil;
clear;

//check
if zznil(xdata,2077) then exit;

//init
str__lock(@xdata);
xline:=str__new8;
xpos:=0;

//get
redo:
if low__nextline0(xdata,xline,xpos) then
   begin
   xlen:=xline.len;
   pmax:=xline.len-1;
   if (pmax>=0) and (xline.pbytes<>nil) then//27apr2021
      begin
      //init
      xok:=false;
      lb:=xline.pbytes;

      //scan for "name: value" divider ":"
      for p:=0 to pmax do if (lb[p]=ssColon) then
         begin

         //"name:"
         if (p=pmax) then
            begin
            xok:=true;
            sets(xline.str[0,p],'');
            break;
            end

         //"name: value"
         else if (p<pmax) and (lb[p+1]=ssSpace) then
            begin
            xok:=true;
            sets(xline.str[0,p],xline.str[p+2,pmax+1]);
            break;
            end

         //"name:value"
         else if ofullcompatibility then
            begin
            xok:=true;
            sets(xline.str[0,p],xline.str[p+1,pmax+1]);
            break;
            end

         else break;

         end;//p

      //"name:value" not found, switch to "name....(last non-space)" where name terminates on last non-space (scans right-to-left)
      if (not xok) and ofullcompatibility then
         begin

         for p:=pmax downto 0 do if (lb[p]<>ssSpace) then
            begin
            xok:=true;
            sets(xline.str[0,p+1],'');
            break;
            end;

         end;

      end;//pmax

   //fetch next line
   goto redo;
   end;
except;end;

//free
str__free(@xline);
str__uaf(@xdata);

end;

function tfastvars.getdata:tstr8;
var
   p:longint;
begin
result :=nil;

try
//defaults
result :=str__newaf8;

//get
for p:=0 to (icount-1) do if (vnref1[p]<>0) or (vnref2[p]<>0) then
   begin

   case vm[p] of
   1   :result.sadd(n[p]+': '+bolstr(vb[p])+r10);
   2   :result.sadd(n[p]+': '+intstr32(vi[p])+r10);
   3   :result.sadd(n[p]+': '+intstr64(vc[p])+r10);
   else result.sadd(n[p]+': '+vs[p]+r10);
   end;//case

   end;//p

except;end;
end;

procedure tfastvars.settext(const x:string);
begin
data:=bcopystr1(x,1,max32);
end;

function tfastvars.gettext:string;
var
   a:tvars8;
   p:longint;
   bol1:boolean;
begin

//defaults
result :='';
a      :=nil;

try
//init
a     :=vnew;
bol1  :=false;

//get
for p:=0 to (icount-1) do if (vnref1[p]<>0) or (vnref2[p]<>0) then
   begin

   case vm[p] of
   1   :a.b[vn[p]]    :=vb[p];
   2   :a.i[vn[p]]    :=vi[p];
   3   :a.i64[vn[p]]  :=vc[p];
   else a.s[vn[p]]    :=vs[p];
   end;//case

   bol1:=true;

   end;//p

//set
if bol1 then result:=a.text;

except;end;

//free
freeobj(@a);

end;

procedure tfastvars.setnettext(x:string);
var
   xname,xvalue:string;
   v,c,xlen,o,t,p:longint;
begin
try
//init
xlen:=low__len(x);
xname:='';
xvalue:='';
t:=1;

//clear
clear;

//get
c:=ssequal;
for p:=1 to xlen do
begin
v:=byte(x[p-1+stroffset]);
if (v=c) or (p=xlen) then
   begin
   //get
   if (v=c) then o:=0 else o:=1;
   xvalue:=strcopy1(x,t,p-t+o);
   t:=p+1;
   //set
   if (c=ssequal) then
       begin
       net__decodestr(xvalue);
       xname:=xvalue;
       c:=ssampersand;
       end
    else
       begin
       //set
//       if storerawvalue then value[_name+'_raw']:=tmp;//28FEB2008
       net__decodestr(xvalue);
       s[xname]:=xvalue;
       //reset
       xname:='';
       c:=ssequal;
       end;
   end;
end;//p
except;end;
end;

procedure tfastvars.clear;
var
   p:longint;
begin
icount:=0;
for p:=0 to (ilimit-1) do
begin
vnref1[p]:=0;
vnref2[p]:=0;
vn[p]:='';
vb[p]:=false;
vi[p]:=0;
vc[p]:=0;
vs[p]:='';
vm[p]:=0;
end;//p
end;

function tfastvars.xmakename(xname:string;var xindex:longint):boolean;//20aug2024: update to check "vn[p]" with xname
var
   ni,nref1,nref2,p:longint;
   c:tcur8;
begin
result:=false;
xindex:=0;

//check
if (xname='') then exit;
if (not oincludecomments) and (strcopy1(xname,1,2)='//') then exit;//24aug2024

try
//init
c.val:=low__ref256u(xname);
nref1:=c.ints[0];
nref2:=c.ints[1];
ni:=-1;

//get
for p:=0 to (ilimit-1) do
begin
if (vnref1[p]=nref1) and (vnref2[p]=nref2) and strmatch(vn[p],xname) then
   begin
   xindex:=p;
   result:=true;
   break;
   end
else if (ni=-1) and (vnref1[p]=0) and (vnref2[p]=0) then ni:=p;
end;//p

//new
if (not result) and (ni>=0) then
   begin
   xindex         :=ni;
   vn[xindex]     :=xname;
   vnref1[xindex] :=nref1;
   vnref2[xindex] :=nref2;
   result:=true;
   end;

//count
if result and (xindex>=icount) then icount:=xindex+1;
except;end;
end;

function tfastvars.find(xname:string;var xindex:longint):boolean;
var
   nref1,nref2,p:longint;
   c:tcur8;
begin
result:=false;
xindex:=0;

//check
if (xname='') then exit;

try
//init
c.val:=low__ref256u(xname);
nref1:=c.ints[0];
nref2:=c.ints[1];

//get
for p:=0 to (ilimit-1) do
begin
if (vnref1[p]=nref1) and (vnref2[p]=nref2) and strmatch(vn[p],xname) then
   begin
   xindex:=p;
   result:=true;
   break;
   end;
end;//p

except;end;
end;

function tfastvars.found(xname:string):boolean;
var
   xindex:longint;
begin
result:=find(xname,xindex);
end;

function tfastvars.sfound(xname:string;var x:string):boolean;
var
   xindex:longint;
begin
result:=find(xname,xindex);
x:='';

try;if result then x:=vs[xindex] else x:='';except;end;
end;

function tfastvars.sfound8(xname:string;x:pobject;xappend:boolean;var xlen:longint):boolean;
var
   xindex:longint;
begin
result:=false;
xlen:=0;

try
if str__lock(x) and find(xname,xindex) then
   begin
   xlen:=low__len(vs[xindex]);
   if not xappend then str__clear(x);
   result:=str__sadd(x,vs[xindex]);
   end;
except;end;
//free
str__uaf(x);
end;

function tfastvars.getb(xname:string):boolean;
var
   xindex:longint;
begin
result:=false;

try
if find(xname,xindex) then
   begin
   case vm[xindex] of
   1:result:=vb[xindex];
   2:result:=(vi[xindex]>=1);
   3:result:=(vc[xindex]>=1);
   else result:=(strint64(vs[xindex])>=1);
   end;//case
   end;
except;end;
end;

function tfastvars.geti(xname:string):longint;
var
   xindex:longint;
begin
result:=0;

try
if find(xname,xindex) then
   begin
   case vm[xindex] of
   1:if vb[xindex] then result:=1;
   2:result:=vi[xindex];
   3:result:=restrict32(vc[xindex]);
   else result:=restrict32(strint64(vs[xindex]));
   end;//case
   end;
except;end;
end;

function tfastvars.getc(xname:string):comp;
var
   xindex:longint;
begin
result:=0;

try
if find(xname,xindex) then
   begin
   case vm[xindex] of
   1:if vb[xindex] then result:=1;
   2:result:=vi[xindex];
   3:result:=vc[xindex];
   else result:=strint64(vs[xindex]);
   end;//case
   end;
except;end;
end;

function tfastvars.gets(xname:string):string;
var
   xindex:longint;
begin
result:='';

try
if find(xname,xindex) then
   begin
   case vm[xindex] of
   1:if vb[xindex] then result:='1' else result:='0';
   2:result:=intstr32(vi[xindex]);
   3:result:=intstr64(vc[xindex]);
   else result:=vs[xindex];
   end;//case
   end;
except;end;
end;

function tfastvars.getn(xindex:longint):string;
begin
result:='';

try;if (xindex>=0) and (xindex<ilimit) and ((vnref1[xindex]<>0) or (vnref2[xindex]<>0)) then result:=vn[xindex];except;end;
end;

function tfastvars.getv(xindex:longint):string;
begin
result:='';

try;if (xindex>=0) and (xindex<ilimit) and ((vnref1[xindex]<>0) or (vnref2[xindex]<>0)) then result:=vs[xindex];except;end;
end;

procedure tfastvars.setv(xindex:longint;x:string);//22aug2024
begin
try;if (xindex>=0) and (xindex<ilimit) and ((vnref1[xindex]<>0) or (vnref2[xindex]<>0)) then vs[xindex]:=x;except;end;
end;

function tfastvars.getchecked(xname:string):boolean;//12jan2024
begin
result:=strmatch(s[xname],'on');
end;

procedure tfastvars.setchecked(xname:string;x:boolean);
begin
s[xname]:=insstr('on',x);
end;

procedure tfastvars.setb(xname:string;x:boolean);
var
   xindex:longint;
begin
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=x;
   vi[xindex]:=0;
   vc[xindex]:=0;
   vs[xindex]:='';
   vm[xindex]:=1;//1=boolean, 2=longint, 3=comp, 4=string
   end;
end;

procedure tfastvars.seti(xname:string;x:longint);
var
   xindex:longint;
begin
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   vi[xindex]:=x;
   vc[xindex]:=0;
   vs[xindex]:='';
   vm[xindex]:=2;//1=boolean, 2=longint, 3=comp, 4=string
   end;
end;

procedure tfastvars.setc(xname:string;x:comp);
var
   xindex:longint;
begin
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   vi[xindex]:=0;
   vc[xindex]:=x;
   vs[xindex]:='';
   vm[xindex]:=3;//1=boolean, 2=longint, 3=comp, 4=string
   end;
end;

procedure tfastvars.sets(xname:string;x:string);
var
   xindex:longint;
begin
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   vi[xindex]:=0;
   vc[xindex]:=0;
   try;vs[xindex]:=x;except;end;
   vm[xindex]:=4;//1=boolean, 2=longint, 3=comp, 4=string
   end;
end;

function tfastvars.getdt(xname:string):tdatetime;//20aug2024
var
   y,m,d,hh,mm,ss,ms:word;
   int1,lp,p,vcount:longint;
   str1,v:string;
begin
result:=0;

try
//init
y:=2000;
m:=1;
d:=1;
hh:=0;
mm:=0;
ss:=0;
ms:=0;

//get
v:=gets(xname)+'-';//trailing dash
vcount:=0;
lp:=1;

for p:=1 to low__len(v) do
begin
if (v[p-1+stroffset]='-') then
   begin
   str1:=strcopy1(v,lp,p-lp);
   int1:=strint(str1);

   case vcount of
   0:y :=frcrange32(int1,1900,max32);
   1:m :=frcrange32(int1,1,12);//confirmed: 1..12
   2:d :=frcrange32(int1,1,31);//confirmed: 1..31
   3:hh:=frcrange32(int1,0,23);
   4:mm:=frcrange32(int1,0,59);
   5:ss:=frcrange32(int1,0,59);
   6:begin
      ms:=frcrange32(int1,0,999);
      break;
      end;
   end;//case

   //inc
   lp:=p+1;
   inc(vcount);
   end;
end;//p

//set
result:=low__safedate( low__encodedate2(y,m,d) + low__encodetime2(hh,mm,ss,ms) );
except;end;
end;

procedure tfastvars.setdt(xname:string;xval:tdatetime);//20aug2024
var
   y,m,d,hh,mm,ss,ms:word;
begin
try
low__decodedate2(xval,y,m,d);
low__decodetime2(xval,hh,mm,ss,ms);
sets(xname,intstr32(y)+'-'+intstr32(m)+'-'+intstr32(d)+'-'+intstr32(hh)+'-'+intstr32(mm)+'-'+intstr32(ss)+'-'+intstr32(ms));
except;end;
end;

procedure tfastvars.iinc(xname:string);
begin
iinc2(xname,1);
end;

procedure tfastvars.iinc2(xname:string;xval:longint);
var
   xindex:longint;
begin
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   low__iroll(vi[xindex],xval);
   vc[xindex]:=0;
   vs[xindex]:='';
   vm[xindex]:=2;//1=boolean, 2=longint, 3=comp, 4=string
   end;
end;

procedure tfastvars.cinc(xname:string);
begin
cinc2(xname,1);
end;

procedure tfastvars.cinc2(xname:string;xval:comp);
var
   xindex:longint;
begin
if xmakename(xname,xindex) then
   begin
   vb[xindex]:=false;
   vi[xindex]:=0;
   low__roll64(vc[xindex],xval);
   vs[xindex]:='';
   vm[xindex]:=3;//1=boolean, 2=longint, 3=comp, 4=string
   end;
end;


//## tdynamiclist ##############################################################
constructor tdynamiclist.create;
begin
//self
if classnameis('tdynamiclist') then track__inc(satDynlist,1);
zzadd(self);
inherited create;
//sd
//vars
sorted:=nil;
icore:=nil;
ilockedBPI:=false;
isize:=0;
icount:=0;
ibpi:=1;
ilimit:=max32;
if (globaloverride_incSIZE>=1) then iincsize:=globaloverride_incSIZE else iincsize:=200;//22MAY2010
freesorted:=true;
//defaults
_createsupport;
_init;
_corehandle;
end;

destructor tdynamiclist.destroy;
begin
try
//clear
clear;
//controls
_destroysupport;
mem__free(icore);
if freesorted and (sorted<>nil) then freeobj(@sorted);
//self
inherited destroy;
if classnameis('tdynamiclist') then track__inc(satDynlist,-1);
except;end;
end;

procedure tdynamiclist._createsupport;
begin
//nil
end;

procedure tdynamiclist._destroysupport;
begin
//nil
end;

procedure tdynamiclist.nosort;
begin
try;if (sorted<>nil) then freeobj(@sorted);except;end;
end;

procedure tdynamiclist.nullsort;
var
   p:longint;
begin
try
//check
if (sorted=nil) then
   begin
   freesorted:=true;
   sorted:=tdynamicinteger.create;
   end;
//process
//.sync "sorted" object
sorted.size:=size;
sorted.count:=count;
//.fill with default "non-sorted" map list
for p:=0 to (count-1) do sorted.items[p]:=p;
except;end;
end;

procedure tdynamiclist.sort(_asc:boolean);
begin
try
//init
nullsort;
//get
if (count>=1) then _sort(_asc);
except;end;
end;

procedure tdynamiclist._sort(_asc:boolean);
begin
{nil}
end;

procedure tdynamiclist._init;
begin
try;_setparams(0,0,1,false);except;end;
end;

procedure tdynamiclist._corehandle;
begin
{nil}
end;

procedure tdynamiclist._oncreateitem(sender:tobject;index:longint);
begin
try;if assigned(oncreateitem) then oncreateitem(self,index);except;end;
end;

procedure tdynamiclist._onfreeitem(sender:tobject;index:longint);
begin
try;if assigned(onfreeitem) then onfreeitem(self,index);except;end;
end;

procedure tdynamiclist.setincsize(x:longint);
begin
iincsize:=frcmin32(x,1);
end;

procedure tdynamiclist.clear;
begin
size:=0;
end;

function tdynamiclist.notify(s,f:longint;_event:tdynamiclistevent):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//no range checking (isize may be undefined at this stage, assume s & f are within range)
if (s<0) or (f<0) or (s>f) then exit;
//process
for p:=s to f do if assigned(_event) then _event(self,p);
//successful
result:=true;
except;end;
end;

procedure tdynamiclist.shift(s,by:longint);
var
   p:longint;
begin
try
if (by>=1) then for p:=(isize-1) downto (s+by) do swap(p,p-by)
else if (by<=-1) then for p:=s to (isize-1) do swap(p,p+by);
except;end;
end;

function tdynamiclist.swap(x,y:longint):boolean;
var
   a:byte;
   b:pdlBYTE;
   p:longint;
begin
//defaults
result:=false;
try
//check
if (x<0) or (x>=isize) or (y<0) or (y>=isize) then exit;
if assigned(onswapitems) then onswapitems(self,x,y)
else
    begin
    //init
    b:=icore;
    x:=x*ibpi;
    y:=y*ibpi;
    //get (swap values byte-by-byte)
    for p:=0 to (ibpi-1) do
    begin
    //1
    a:=b[x+p];
    //2
    b[x+p]:=b[y+p];
    //3
    b[y+p]:=a;
    end;//p
    end;
//successful
result:=true;
except;end;
end;

function tdynamiclist.setparams(_count,_size,_bpi:longint):boolean;
begin
result:=_setparams(_count,_size,_bpi,true);
end;

function tdynamiclist._setparams(_count,_size,_bpi:longint;_notify:boolean):boolean;
label
     skipend;
var
   a:pointer;
   _oldsize,_limit:longint;
begin
//defaults
result:=false;

try
//enforce range
if ilockedBPI then _bpi:=ibpi else _bpi:=frcmin32(_bpi,1);

_limit   :=(max32 div nozero__int32(1000002,_bpi))-1;
_size    :=frcrange32(_size,0,_limit);
_oldsize :=frcrange32(isize,0,_limit)*ibpi;

//get
//.size
if (_size<>isize) then
   begin

   a:=icore;

   //.enlarge
   if (_size>isize) then
      begin

      //was: mem__reallocmemCLEAR(icore,_oldsize,_size*_bpi,3);
      if not mem__resize3(icore,(_size*_bpi),true,icore) then _size:=_oldsize;//revert on failure

      //.update core handle
      if (a<>icore) then _corehandle;
      if _notify then notify(isize,_size-1,_oncreateitem);

      end

   //.shrink
   else if (_size<isize) then
      begin

      if _notify then notify(_size,isize-1,_onfreeitem);

      mem__resize3(icore,(_size*_bpi),false,icore);

      //.update core handle
      if (a<>icore) then _corehandle;

      end;

   end;

//set
ilimit  :=_limit;
isize   :=_size;
icount  :=frcrange32(_count,0,_size);
ibpi    :=_bpi;

//successful
result:=true;
skipend:
except;end;
end;

function tdynamiclist.atleast(_size:longint):boolean;
begin
if (_size>=size) then result:=_setparams(count,((_size div nozero__int32(1000003,incsize))+1)*incsize,bpi,true) else result:=true;
end;

function tdynamiclist.addrange(_count:longint):boolean;
var
   newsize,newcount:longint;
begin
//defaults
result:=false;

try
//check
if (_count<=0) then exit;
//prepare
newsize:=isize;
newcount:=icount+_count;
//check
if (newcount>ilimit) then exit;
if (newcount>newsize) then
   begin
   newsize:=newcount+iincsize;
   if (newsize>ilimit) then newsize:=ilimit;
   end;
//process
result:=setparams(newcount,newsize,bpi) and (newcount>=icount);
except;end;
end;

function tdynamiclist.add:boolean;
begin
result:=addrange(1);
end;

function tdynamiclist.delrange(s,_count:longint):boolean;
begin
//defaults
result:=false;

try
//check
if (s<0) or (s>=isize) then exit;
_count:=frcrange32(_count,0,isize-s);
if (_count<=0) then exit;
//process
//.free
if not notify(s,s+_count-1,_onfreeitem) then exit;
//.shift down by "_count"
shift(s+_count,-_count);
//.shrink
if not _setparams(count-_count,isize-_count,bpi,false) then exit;
//successful
result:=true;
except;end;
end;

function tdynamiclist._del(x:longint):boolean;//2nd copy - 20oct2018
begin
result:=delrange(x,1);
end;

function tdynamiclist.del(x:longint):boolean;
begin
result:=delrange(x,1);
end;

function tdynamiclist.insrange(s,_count:longint):boolean;
var
   _oldsize:longint;
begin
//defaults
result:=false;

try
//check
_count:=frcmin32(_count,0);
if (_count<=0) or (s<0) or (s>=isize) then exit;
if ((isize+_count)>ilimit) then exit;

//get
//.enlarge
_oldsize :=isize*bpi;
inc(isize,_count);
inc(icount,_count);
//was: mem__reallocmemCLEAR(icore,_oldsize,isize*bpi,5);
mem__resize3(icore,(isize*bpi),true,icore);

//.shift up by "_count"
shift(s,_count);

//.new
if not notify(s,s+_count-1,_oncreateitem) then exit;

//successful
result:=true;
except;end;
end;

function tdynamiclist.ins(x:longint):boolean;
begin
result:=insrange(x,1);
end;

function tdynamiclist.forcesize(x:longint):boolean;//25jul2024
begin
x:=frcmin32(x,0);
setparams(x,x,bpi);
result:=(x=size) and (x=count);
end;

procedure tdynamiclist.setcount(x:longint);
begin
setparams(x,size,bpi);
end;

procedure tdynamiclist.setsize(x:longint);
begin
setparams(count,x,bpi);
end;

procedure tdynamiclist.setbpi(x:longint);//bytes per item
begin
setparams(count,size,x);
end;

function tdynamiclist.findvalue(_start:longint;_value:pointer):longint;
var
   a,b:pdlBYTE;
   maxp2,ai,p2,p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) or (_value=nil) then exit;
//init
a:=core;
b:=_value;
maxp2:=ibpi-1;
//get
for p:=_start to (icount-1) do
    begin
    ai:=p*ibpi;
    p2:=0;
    repeat
    if (a[ai+p2]<>b[p2]) then break;
    inc(p2);
    until (p2>maxp2);
    if (p2>maxp2) then
       begin
       result:=p;
       exit;
       end;//p2
    end;//p
except;end;
end;

function tdynamiclist.sindex(x:longint):longint;
begin//sorted index
if zznil(sorted,2280) or (x>=sorted.count) then result:=x else result:=sorted.value[x];
end;

//######################## tdynamicword ########################################
constructor tdynamicword.create;//01may2019
begin
if classnameis('tdynamicword') then track__inc(satDynword,1);
inherited create;
end;

destructor tdynamicword.destroy;//01may2019
begin
if classnameis('tdynamicword') then track__inc(satDynword,-1);
inherited destroy;
end;

procedure tdynamicword._init;
begin
try
_setparams(0,0,2,false);
ilockedBPI:=true;
itextsupported:=true;
except;end;
end;

procedure tdynamicword._corehandle;
begin
iitems:=core;
end;

function tdynamicword.getvalue(_index:integer):word;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;

procedure tdynamicword.setvalue(_index:integer;_value:word);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;

function tdynamicword.getsvalue(_index:integer):word;
begin
result:=value[sindex(_index)];
end;

procedure tdynamicword.setsvalue(_index:integer;_value:word);
begin
value[sindex(_index)]:=_value;
end;

function tdynamicword.find(_start:integer;_value:word):integer;
var
   p:integer;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;
except;end;
end;

procedure tdynamicword._sort(_asc:boolean);
begin
__sort(items,sorted.items,0,count-1,_asc);
end;

procedure tdynamicword.__sort(a:pdlWORD;b:pdlLONGINT;l,r:integer;_asc:boolean);
var
  p:word;
  tmp,i,j:integer;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamicinteger ###########################################################
constructor tdynamicinteger.create;//01may2019
begin
if classnameis('tdynamicinteger') then track__inc(satDynint,1);
inherited create;
end;

destructor tdynamicinteger.destroy;//01may2019
begin
inherited destroy;
if classnameis('tdynamicinteger') then track__inc(satDynint,-1);
end;

procedure tdynamicinteger._init;
begin
_setparams(0,0,4,false);
ilockedBPI:=true;
itextsupported:=true;
end;

function tdynamicinteger.copyfrom(s:tdynamicinteger):boolean;
var
   p,xcount:longint;
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
freesorted:=s.freesorted;
utag:=s.utag;
xcount:=s.count;
size:=s.size;
count:=xcount;
for p:=(xcount-1) downto 0 do value[p]:=s.value[p];
if (s.sorted=nil) then
   begin
   if (sorted<>nil) then nosort;
   end
else
   begin
   nullsort;
   for p:=(s.sorted.count-1) downto 0 do sorted.value[p]:=s.sorted.value[p];
   end;
except;end;
end;

procedure tdynamicinteger._corehandle;
begin
iitems:=core;
end;

function tdynamicinteger.getvalue(_index:longint):longint;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;

procedure tdynamicinteger.setvalue(_index:longint;_value:longint);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;

function tdynamicinteger.getsvalue(_index:longint):longint;
begin
result:=value[sindex(_index)];
end;

procedure tdynamicinteger.setsvalue(_index:longint;_value:longint);
begin
value[sindex(_index)]:=_value;
end;

function tdynamicinteger.find(_start:longint;_value:longint):longint;
var
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;//p
except;end;
end;

procedure tdynamicinteger._sort(_asc:boolean);
begin
__sort(items,sorted.items,0,count-1,_asc);
end;

procedure tdynamicinteger.__sort(a:pdllongint;b:pdllongint;l,r:longint;_asc:boolean);
var
  p,tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamicpoint #############################################################
constructor tdynamicpoint.create;//01may2019
begin
if classnameis('tdynamicpoint') then track__inc(satOther,1);
inherited create;
end;

destructor tdynamicpoint.destroy;//01may2019
begin
if classnameis('tdynamicpoint') then track__inc(satOther,-1);
inherited destroy;
end;

procedure tdynamicpoint._init;
begin
_setparams(0,0,sizeof(tpoint),false);
ilockedBPI:=true;
//itextsupported:=true;
end;

procedure tdynamicpoint._corehandle;
begin
iitems:=core;
end;

procedure tdynamicpoint._sort(_asc:boolean);
begin
//nil
end;

function tdynamicpoint.getvalue(_index:integer):tpoint;
begin
//.check
if (_index<0) or (_index>=count) then result:=low__point(0,0) else result:=items[_index];
end;

procedure tdynamicpoint.setvalue(_index:integer;_value:tpoint);
begin
//.check
if (_index<0) then exit
else if (_index>=size) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;

function tdynamicpoint.getsvalue(_index:integer):tpoint;
begin
result:=value[sindex(_index)];
end;

procedure tdynamicpoint.setsvalue(_index:integer;_value:tpoint);
begin
value[sindex(_index)]:=_value;
end;

function tdynamicpoint.find(_start:integer;_value:tpoint):integer;
var
   p:integer;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p].x=_value.x) and (iitems[p].y=_value.y) then
    begin
    result:=p;
    break;
    end;
except;end;
end;

function tdynamicpoint.areaTOTAL(var x1,y1,x2,y2:integer):boolean;//18OCT2011
var
   p,sx,sy:integer;
begin
//defaults
result:=false;
x1:=0;
x2:=0;
y1:=0;
y2:=0;

try
//check
if (count<=0) then exit;
//get
for p:=0 to (count-1) do
begin
sx:=items[p].x;
sy:=items[p].y;
//.x
if (sx<x1) then x1:=sx;
if (sx>x2) then x2:=sx;
//.y
if (sy<y1) then y1:=sy;
if (sy>y2) then y2:=sy;
end;
//successful
result:=true;
except;end;
end;

function tdynamicpoint.areaTOTALEX(var a:twinrect):boolean;//18OCT2011
begin
result:=areaTOTAL(a.left,a.top,a.right,a.bottom);
end;

//## tdynamicdatetime ##########################################################
constructor tdynamicdatetime.create;
begin
if classnameis('tdynamicdatetime') then track__inc(satDyndate,1);
inherited create;
end;

destructor tdynamicdatetime.destroy;
begin
inherited destroy;
if classnameis('tdynamicdatetime') then track__inc(satDyndate,-1);
end;

procedure tdynamicdatetime._init;
begin
_setparams(0,0,8,false);
ilockedBPI:=true;
itextsupported:=true;
end;

procedure tdynamicdatetime._corehandle;
begin
iitems:=core;
end;

function tdynamicdatetime.getvalue(_index:longint):tdatetime;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;

procedure tdynamicdatetime.setvalue(_index:longint;_value:tdatetime);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;

function tdynamicdatetime.getsvalue(_index:longint):tdatetime;
begin
result:=value[sindex(_index)];
end;

procedure tdynamicdatetime.setsvalue(_index:longint;_value:tdatetime);
begin
value[sindex(_index)]:=_value;
end;

function tdynamicdatetime.find(_start:longint;_value:tdatetime):longint;
var//* Uses "2xInteger for QUICK comparision".
   //* Direct "Double" comparison is upto 3-4 times slower.
   a:pdlbilongint;
   b:pbilongint;
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//prepare
a:=core;
b:=@_value;
//process
for p:=_start to (icount-1) do if (a[p][0]=b[0]) and (a[p][1]=b[1]) then
    begin
    result:=p;
    break;
    end;
except;end;
end;

procedure tdynamicdatetime._sort(_asc:boolean);
begin
__sort(items,sorted.items,0,count-1,_asc);
end;

procedure tdynamicdatetime.__sort(a:pdlDATETIME;b:pdllongint;l,r:longint;_asc:boolean);
var
  p:tdatetime;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamicbyte ##############################################################
constructor tdynamicbyte.create;//01may2019
begin
if classnameis('tdynamicbyte') then track__inc(satDynbyte,1);
inherited create;
end;

destructor tdynamicbyte.destroy;//01may2019
begin
inherited destroy;
if classnameis('tdynamicbyte') then track__inc(satDynbyte,-1);
end;

procedure tdynamicbyte._init;
begin
_setparams(0,0,1,false);
ilockedBPI:=true;
itextsupported:=true;
end;

procedure tdynamicbyte._corehandle;
begin
iitems:=core;
ibits:=core;
end;

function tdynamicbyte.getvalue(_index:longint):byte;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;

procedure tdynamicbyte.setvalue(_index:longint;_value:byte);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;

function tdynamicbyte.getsvalue(_index:longint):byte;
begin
result:=value[sindex(_index)];
end;

procedure tdynamicbyte.setsvalue(_index:longint;_value:byte);
begin
value[sindex(_index)]:=_value;
end;

function tdynamicbyte.find(_start:longint;_value:byte):longint;
var
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;//p
except;end;
end;

procedure tdynamicbyte._sort(_asc:boolean);
begin
__sort(items,sorted.items,0,count-1,_asc);
end;

procedure tdynamicbyte.__sort(a:pdlbyte;b:pdllongint;l,r:longint;_asc:boolean);
var
  p:byte;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamiccurrency ##########################################################
constructor tdynamiccurrency.create;//01may2019
begin
if classnameis('tdynamiccurrency') then track__inc(satDyncur,1);
inherited create;
end;

destructor tdynamiccurrency.destroy;//01may2019
begin
inherited destroy;
if classnameis('tdynamiccurrency') then track__inc(satDyncur,-1);
end;

procedure tdynamiccurrency._init;
begin
_setparams(0,0,8,false);
ilockedBPI:=true;
itextsupported:=true;
end;

procedure tdynamiccurrency._corehandle;
begin
iitems:=core;
end;

function tdynamiccurrency.getvalue(_index:longint):currency;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;

procedure tdynamiccurrency.setvalue(_index:longint;_value:currency);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;

function tdynamiccurrency.getsvalue(_index:longint):currency;
begin
result:=value[sindex(_index)];
end;

procedure tdynamiccurrency.setsvalue(_index:longint;_value:currency);
begin
value[sindex(_index)]:=_value;
end;

function tdynamiccurrency.find(_start:longint;_value:currency):longint;
var//* Uses "2xInteger for QUICK comparision".
   //* Direct "Currency" comparison is upto 3-4 times slower.
   a:pdlbilongint;
   b:pbilongint;
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//prepare
a:=core;
b:=@_value;
//process
for p:=_start to (icount-1) do if (a[p][0]=b[0]) and (a[p][1]=b[1]) then
    begin
    result:=p;
    break;
    end;
except;end;
end;

procedure tdynamiccurrency._sort(_asc:boolean);
begin
__sort(items,sorted.items,0,count-1,_asc);
end;

procedure tdynamiccurrency.__sort(a:pdlCURRENCY;b:pdllongint;l,r:longint;_asc:boolean);
var
  p:currency;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamiccomp ##############################################################
constructor tdynamiccomp.create;//01may2019
begin
if classnameis('tdynamiccomp') then track__inc(satDyncomp,1);
inherited create;
end;

destructor tdynamiccomp.destroy;//01may2019
begin
inherited destroy;
if classnameis('tdynamiccomp') then track__inc(satDyncomp,-1);
end;

procedure tdynamiccomp._init;
begin
_setparams(0,0,8,false);
ilockedBPI:=true;
itextsupported:=true;
end;

procedure tdynamiccomp._corehandle;
begin
iitems:=core;
end;

function tdynamiccomp.getvalue(_index:longint):comp;
begin
//.check
if (_index<0) or (_index>=count) then result:=0
else result:=items[_index];
end;

procedure tdynamiccomp.setvalue(_index:longint;_value:comp);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;

function tdynamiccomp.getsvalue(_index:longint):comp;
begin
result:=value[sindex(_index)];
end;

procedure tdynamiccomp.setsvalue(_index:longint;_value:comp);
begin
value[sindex(_index)]:=_value;
end;

function tdynamiccomp.find(_start:longint;_value:comp):longint;
var//* Uses "2xInteger for QUICK comparision".
   a:pdlBILONGINT;
   b:pBILONGINT;
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//prepare
a:=core;
b:=@_value;
//process
for p:=_start to (icount-1) do if (a[p][0]=b[0]) and (a[p][1]=b[1]) then
    begin
    result:=p;
    break;
    end;
except;end;
end;

procedure tdynamiccomp._sort(_asc:boolean);
begin
__sort(items,sorted.items,0,count-1,_asc);
end;

procedure tdynamiccomp.__sort(a:pdlCOMP;b:pdlLONGINT;l,r:longint;_asc:boolean);
var
  p:comp;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (a^[b^[I]]<P) do inc(I);
     while (a^[b^[J]]>P) do dec(J);
     end
  else
     begin
     while (a^[b^[I]]>P) do inc(I);
     while (a^[b^[J]]<P) do dec(J);
     end;
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;

//## tdynamicpointer ###########################################################
constructor tdynamicpointer.create;//01may2019
begin
if classnameis('tdynamicpointer') then track__inc(satDynptr,1);
inherited create;
end;

destructor tdynamicpointer.destroy;//01may2019
begin
if classnameis('tdynamicpointer') then track__inc(satDynptr,-1);
inherited destroy;
end;

procedure tdynamicpointer._init;
begin
_setparams(0,0,4,false);
ilockedBPI:=true;
itextsupported:=true;
end;

procedure tdynamicpointer._corehandle;
begin
iitems:=core;
end;

function tdynamicpointer.getvalue(_index:longint):pointer;
begin
//.check
if (_index<0) or (_index>=count) then result:=nil
else result:=items[_index];
end;

procedure tdynamicpointer.setvalue(_index:longint;_value:pointer);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]:=_value;
end;

function tdynamicpointer.getsvalue(_index:longint):pointer;
begin
result:=value[sindex(_index)];
end;

procedure tdynamicpointer.setsvalue(_index:longint;_value:pointer);
begin
value[sindex(_index)]:=_value;
end;

function tdynamicpointer.find(_start:longint;_value:pointer):longint;
var
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;
except;end;
end;

//## tdynamicstring ############################################################
constructor tdynamicstring.create;//01may2019
begin
if classnameis('tdynamicstring') then track__inc(satDynstr,1);
inherited create;
end;

destructor tdynamicstring.destroy;//01may2019
begin
inherited destroy;
if classnameis('tdynamicstring') then track__inc(satDynstr,-1);
end;

function tdynamicstring.copyfrom(s:tdynamicstring):boolean;
var
   p,xcount:longint;
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
freesorted:=s.freesorted;
utag:=s.utag;
xcount:=s.count;
size:=s.size;
count:=xcount;
for p:=(xcount-1) downto 0 do value[p]:=s.value[p];
if (s.sorted=nil) then
   begin
   if (sorted<>nil) then nosort;
   end
else
   begin
   nullsort;
   for p:=(s.sorted.count-1) downto 0 do sorted.value[p]:=s.sorted.value[p];
   end;
except;end;
end;

function tdynamicstring.gettext:string;
var
   a:tstr8;
   p:longint;
begin
//defaults
result:='';

try
a:=nil;
//get
a:=str__new8;
for p:=0 to (count-1) do a.sadd(value[p]+rcode);
//set
result:=a.text;
except;end;
try;str__free(@a);except;end;
end;

procedure tdynamicstring.settext(const x:string);
var
   xdata,xline:tstr8;
   p:longint;
begin
try
//defaults
xdata:=nil;
xline:=nil;
p:=0;
//clear
clear;
//init
xdata:=bnewstr(x);
xline:=str__new8;
//get
while low__nextline0(xdata,xline,p) do value[count]:=xline.text;
except;end;
//free
str__free(@xdata);
str__free(@xline);
end;

function tdynamicstring.getstext:string;
var
   a:tstr8;
   p:longint;
begin
//defaults
result:='';

try
a:=nil;
//get
a:=str__new8;
for p:=0 to (count-1) do a.sadd(svalue[p]+rcode);
//set
result:=a.text;
except;end;
try;str__free(@a);except;end;
end;

procedure tdynamicstring._init;
begin
_setparams(0,0,4,false);
ilockedBPI:=true;
end;

procedure tdynamicstring._corehandle;
begin
iitems:=core;
end;

procedure tdynamicstring._oncreateitem(sender:tobject;index:longint);
begin
try
mem__newpstring(iitems[index]);//29NOV2011
inherited;
except;end;
end;

procedure tdynamicstring._onfreeitem(sender:tobject;index:longint);
begin
try
inherited;
mem__despstring(iitems[index]);//29NOV2011
except;end;
end;

function tdynamicstring.getvalue(_index:longint):string;
begin
if (_index<0) or (_index>=count) then result:='' else result:=items[_index]^;
end;

procedure tdynamicstring.setvalue(_index:longint;_value:string);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]^:=_value;
end;

function tdynamicstring.getsvalue(_index:longint):string;
begin
result:=value[sindex(_index)];
end;

procedure tdynamicstring.setsvalue(_index:longint;_value:string);
begin
value[sindex(_index)]:=_value;
end;

function tdynamicstring.find(_start:longint;_value:string;_casesensitive:boolean):longint;//01may2025
var
   p:longint;
begin
//defaults
result:=-1;

//get
if (_start>=0) and (_start<count) then for p:=_start to (icount-1) do if strmatch2(iitems[p]^,_value,_casesensitive) then
   begin
   result:=p;
   break;
   end;//p
end;

procedure tdynamicstring._sort(_asc:boolean);
begin
__sort(items,sorted.items,0,count-1,_asc);
end;

procedure tdynamicstring.__sort(a:pdlstring;b:pdllongint;l,r:longint;_asc:boolean);
var
  p:pstring;
  tmp,i,j:longint;
begin
try
repeat
I := L;
J := R;
P := a^[b^[(L + R) shr 1]];
  repeat
  if _asc then
     begin
     while (strmatch32(a^[b^[I]]^,p^)<0) do inc(I);
     while (strmatch32(a^[b^[J]]^,p^)>0) do dec(J);
     end
  else
     begin
     while (strmatch32(a^[b^[I]]^,p^)>0) do inc(I);
     while (strmatch32(a^[b^[J]]^,p^)<0) do dec(J);
     end;
  if I <= J then
     begin
     tmp:=b^[i];
     b^[i]:=b^[j];
     b^[j]:=tmp;
     inc(I);
     dec(J);
     end;
  until I > J;
if L < J then __sort(a,b,L,J,_asc);
L := I;
until I >= R;
except;end;
end;


//## tlitestrings ##############################################################
constructor tlitestrings.create;
begin
//track
if classnameis('tlitestrings') then track__inc(satDynstr,1);
//self
inherited create;
//vars
isharecount:=100;//share ONE string between "100" user "value[x]" strings
icount:=0;
ibytes:=0;
//controls
idata:=tdynamicstring.create;
ipos:=tdynamicinteger.create;
ilen:=tdynamicinteger.create;
end;

destructor tlitestrings.destroy;
begin
try
//controls
freeobj(@idata);
freeobj(@ipos);
freeobj(@ilen);
//self
inherited destroy;
//track
if classnameis('tlitestrings') then track__inc(satDynstr,-1);
except;end;
end;

function tlitestrings.atleast(_size:longint):boolean;
begin
if (_size>=ilen.size) then result:=setparams(icount,_size+1000) else result:=true;
end;

function tlitestrings.setparams(_count,_size:longint):boolean;
begin
//defaults
result:=false;

try
//range
_size:=frcmin32(_size,0);

//set
if (_size<>ilen.size) then
   begin
   ilen.size:=_size;
   ipos.size:=_size;
   //.data.size - 07sep2015
   if (_size<=0) then idata.size:=0 else idata.size:=(_size div nozero__int32(1000004,isharecount))+1;
   end;//end of if

//vars
icount:=frcrange32(_count,0,_size);

//successful
result:=true;
except;end;
end;

procedure tlitestrings.setsize(x:longint);
begin
setparams(count,x);
end;

procedure tlitestrings.setcount(x:longint);
begin
setparams(x,size);
end;

procedure tlitestrings.flush;//fast clear and retains size - 07sep2015
var
   p:longint;
begin
try
//vars
icount:=0;
ibytes:=0;
//refs
for p:=0 to (ilen.size-1) do
begin
ilen.items[p]:=0;
ipos.items[p]:=0;
end;
//data
for p:=0 to (idata.size-1) do idata.items[p]^:='';
except;end;
end;

procedure tlitestrings.clear;
begin
ibytes:=0;
icount:=0;
ipos.clear;
ilen.clear;
idata.clear;
end;

function tlitestrings.gettext:string;
var
   a:tstr9;
   p,len:longint;
begin
//defaults
result :='';
len    :=0;
a      :=nil;

try
//get
a:=str__new9;
for p:=0 to (icount-1) do a.sadd(value[p]+rcode);

//set
result:=a.text;
except;end;
//free
str__free(@a);
end;

procedure tlitestrings.settext(const x:string);
var
   xdata,xline:tstr8;
   p:longint;
begin
try
//defaults
xdata:=nil;
xline:=nil;
p    :=0;

//clear
clear;

//init
xdata:=bnewstr(x);
xline:=str__new8;

//get
while low__nextline0(xdata,xline,p) do value[icount]:=xline.text;
except;end;

//free
str__free(@xdata);
str__free(@xline);
end;

function tlitestrings.find(_start:integer;_value:string;_casesensitive:boolean):integer;
var
   p:integer;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=icount) then exit;

//find
if _casesensitive then
   begin
   for p:=_start to (icount-1) do if strmatch(value[p],_value) then
      begin
      result:=p;
      break;
      end;//p
   end
else
   begin
   for p:=_start to (icount-1) do if strmatch(value[p],_value) then
      begin
      result:=p;
      break;
      end;//p
   end;
except;end;
end;

function tlitestrings.getsize:integer;
begin
result:=ilen.size;
end;

function tlitestrings.getvalue(_index:integer):string;
begin
//defaults
result:='';

try
if (_index<0) or (_index>=icount) then result:=''
else if (ilen.items[_index]<=0) or (ipos.items[_index]<=0) then result:=''
//.get - extract "value" sub-string
else result:=strcopy1(idata.items[_index div nozero__int32(1000005,isharecount)]^,ipos.items[_index],ilen.items[_index]);
except;end;
end;

procedure tlitestrings.setvalue(_index:integer;_value:string);
var
   _index2,minp,p,opos,len,posCHANGE:integer;
begin
try
//-- get
//check
if (_index<0) then exit;

//count
if (_index>=icount) then icount:=_index+1;

//size
if (_index>=ilen.size) then setparams(icount,_index+500);

//-- set
//init
len:=low__len(_value);
_index2:=_index div nozero__int32(1000006,isharecount);

//new - append to end of "data.string"
if (ipos.items[_index]<=0) then
   begin

   if (len>=1) then//ignore empty strings, no setup required for these
      begin
      ipos.items[_index]:=low__len(idata.items[_index2]^)+1;
      ilen.items[_index]:=len;
      idata.items[_index2]^:=idata.items[_index2]^+_value;
      inc(ibytes,len);//07sep2014
      end;

   end
//edit - adjust the current "data.string" and update all items that have a "ipos" greater than current item's
else
   begin
   //init
   opos:=ipos.items[_index];
   posCHANGE:=len-ilen.items[_index];
   minp:=(_index div nozero__int32(1000007,isharecount))*isharecount;

   //adjust "dp.string"
   idata.items[_index2]^:=strcopy1(idata.items[_index2]^,1,opos-1)+_value+strcopy1(idata.items[_index2]^,opos+ilen.items[_index],low__len(idata.items[_index2]^));

   //adjust current item's "ilen"
   ilen.items[_index]:=len;
   if (len=0) then ipos.items[_index]:=0;//item is deleted

   //adjust all other item's "ipos"                                            //after current item's old position
   //upper range limit "isize-1" implemented on 30apr2015 to fix upper range overrun which produced "invalid pointer operation" and mysterious behaviour - 30apr2015
   if (posCHANGE<>0) then for p:=minp to frcmax32((minp+isharecount-1),ilen.size-1) do if (p<>_index) and (ipos.items[p]>=1) and (ipos.items[p]>opos) then inc(ipos.items[p],posCHANGE);

   //.stats
   ibytes:=frcmin32(ibytes+posCHANGE,0);//07sep2014
   end;
except;end;
end;

//## tdynamicname ##############################################################
constructor tdynamicname.create;//01may2019
begin
if classnameis('tdynamicname') then track__inc(satDynname,1);
inherited create;
end;

destructor tdynamicname.destroy;//01may2019
begin
if classnameis('tdynamicname') then track__inc(satDynname,-1);
inherited destroy;
end;

procedure tdynamicname._createsupport;
begin
try
//controls
iref:=tdynamiccomp.create;
except;end;
end;

procedure tdynamicname._destroysupport;
begin
try
//controls
freeObj(@iref);
except;end;
end;

procedure tdynamicname.shift(s,by:longint);
begin
inherited shift(s,by);iref.shift(s,by);
end;

function tdynamicname._setparams(_count,_size,_bpi:longint;_notify:boolean):boolean;
begin
result:=(inherited _setparams(_count,_size,_bpi,_notify)) and iref._setparams(_count,_size,_bpi,_notify);
end;

procedure tdynamicname.setvalue(_index:longint;_value:string);
begin
//.check
if (_index<0) then exit
else if (_index>=isize) and (not atleast(_index)) then exit;
//.count
if (_index>=icount) then icount:=_index+1;
//.set
items[_index]^:=_value;
sync(_index);
end;

function tdynamicname.findfast(_start:longint;_value:string):longint;
var
   vREF:comp;
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//prepare
vREF:=low__ref256U(_value);
//process
p:=_start-1;
while TRUE do
begin
p:=iref.find(p+1,vREF);
if (p=-1) or (p>=size) then break
else if strmatch(iitems[p]^,_value) then
    begin
    result:=p;
    break;
    end;
end;
except;end;
end;

procedure tdynamicname.sync(x:longint);
begin
iref.value[x]:=low__ref256U(items[x]^);
end;

//## tdynamicnamelist ##########################################################
constructor tdynamicnamelist.create;
begin
if classnameis('tdynamicnamelist') then track__inc(satDynnamelist,1);
//self
inherited create;
//vars
delshrink:=false;
iactive:=0;
end;

destructor tdynamicnamelist.destroy;
begin
if classnameis('tdynamicnamelist') then track__inc(satDynnamelist,-1);
inherited destroy;
end;

procedure tdynamicnamelist.clear;
begin
inherited clear;
iactive:=0;
end;

function tdynamicnamelist.add(x:string):longint;
begin
result:=addb(x,true);
end;

function tdynamicnamelist.addb(x:string;newonly:boolean):longint;
var
   isnewitem:boolean;
begin
result:=addex(x,newonly,isnewitem);
end;

function tdynamicnamelist.addex(x:string;newonly:boolean;var isnewitem:boolean):longint;
var
   p:longint;
begin
//defaults
result:=-1;
isnewitem:=false;

try
//get
if (x<>'') then
   begin
   //.find
   p:=findfast(0,x);
   if newonly and (p>=0) then exit;
   //.new
   if (p=-1) then
      begin
      p:=findfast(0,'');
      if (p=-1) then p:=count;
      //.set
      value[p]:=x;
      isnewitem:=true;
      inc(iactive);
      end;
   //successful
   result:=p;
   end;
except;end;
end;

function tdynamicnamelist.addonce(x:string):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//get
if (x<>'') and (not have(x)) then
   begin
   p:=findfast(0,'');
   if (p=-1) then p:=count;
   value[p]:=x;
   inc(iactive);
   //successful
   result:=true;
   end;
except;end;
end;

function tdynamicnamelist.addonce2(x:string;var xindex:longint):boolean;//08feb2020
begin//Note: Always returns xindex (new or otherwise), but also returns
//          (a) false=if "x" already exists and (b) true=if "x" did not exist and was added
//defaults
result:=false;
xindex:=-1;

try
//check
if (x='') then exit;

//get
//.return index of existing item (0..N)
xindex:=findfast(0,x);
//.add item if it doesn't already exist (-1)
if (xindex<0) then
   begin
   xindex:=count;
   value[xindex]:=x;
   inc(iactive);
   //successful
   result:=true;
   end;
except;end;
end;

function tdynamicnamelist.replace(x,y:string):boolean;//can't prevent duplications if this proc is used
var
   p:longint;
begin
//defaults
result:=false;

try
//get
if (x<>'') and (y<>'') and have(x) then
   begin
   p:=findfast(0,x);
   if (p>=0) then
      begin
      value[p]:=y;
      result:=true;
      end;
   end;
except;end;
end;

function tdynamicnamelist.del(x:string):boolean;
var
   p:longint;
begin
//defaults
result:=false;

try
//get
if (x<>'') then
   begin
   p:=findfast(0,x);
   if (p>=0) then
      begin
      if delshrink then (inherited del(p)) else value[p]:='';
      iactive:=frcmin32(iactive-1,0);
      result:=true;
      end;
   end;
except;end;
end;

procedure tdynamicnamelist.delindex(x:longint);//30AUG2007
begin
if delshrink then (inherited del(x)) else value[x]:='';
end;

function tdynamicnamelist.have(x:string):boolean;
begin
if (x='') then result:=false else result:=(findfast(0,x)>=0);
end;

function tdynamicnamelist.find(x:string;var xindex:longint):boolean;//09apr2024
begin
if (x<>'') then
   begin
   xindex:=findfast(0,x);
   result:=(xindex>=0);
   end
else
   begin
   xindex:=0;
   result:=false
   end;
end;

//## tdynamicvars ##############################################################
constructor tdynamicvars.create;
begin
if classnameis('tdynamicvars') then track__inc(satDynvars,1);
zzadd(self);
//self
inherited create;
//controls
inamesREF:=tdynamiccomp.create;//09apr2024
inames:=tdynamicstring.create;
ivalues:=tdynamicstring.create;
//.incsize
if (globaloverride_incSIZE>=1) then incsize:=globaloverride_incSIZE else incsize:=10;//22MAY2010
end;

destructor tdynamicvars.destroy;
begin
if classnameis('tdynamicvars') then track__inc(satDynvars,-1);
try
//controls
freeObj(@inamesREF);
freeObj(@inames);
freeObj(@ivalues);
//self
inherited destroy;
//sd
except;end;
end;

function tdynamicvars.getbytes:longint;//13apr2018
var
   p:longint;
begin
result:=frcmin32(inamesREF.count,0)*8;
if (inames.count>=1) then for p:=(inames.count-1) downto 0 do inc(result,low__len(inames.items[p]^));
if (ivalues.count>=1) then for p:=(ivalues.count-1) downto 0 do inc(result,low__len(ivalues.items[p]^));
end;

procedure tdynamicvars.sortbyVALUE(_asc,_asnumbers:boolean);//04JUL2013
begin
sortbyVALUEEX(_asc,true,false);
end;

procedure tdynamicvars.sortbyVALUEEX(_asc,_asnumbers,_commentsattop:boolean);//04JUL2013
var
   z:string;
   dcount,ncount,p,i:longint;
   n,v:tdynamicstring;
   vi:tdynamicinteger;
begin
//defaults
n:=nil;
v:=nil;
vi:=nil;
z:='';
dcount:=0;
i:=0;

try
//init
ncount:=names.count;
if (ncount<=0) then exit;//nothing to do
n:=tdynamicstring.create;
v:=tdynamicstring.create;
vi:=tdynamicinteger.create;
n.setparams(ncount,ncount,0);
v.setparams(ncount,ncount,0);
vi.setparams(ncount,ncount,0);
//get
//.make a FAST copy
for p:=0 to (ncount-1) do
begin
n.items[p]^:=names.items[p]^;
v.items[p]^:=values.items[p]^;
try;vi.items[p]:=strint(values.items[p]^);except;end;
end;
//.sort that copy
case _asnumbers of
true:vi.sort(_asc);
else v.sort(_asc);
end;
//set
//.shift ALL comments "//" to top of list
if _commentsattop then for p:=0 to (n.count-1) do if (strcopy1(n.items[p]^,1,2)='//') then
   begin
   names.items[dcount]^:=n.items[p]^;
   values.items[dcount]^:=v.items[p]^;
   inc(dcount);
   end;
//.by value
for p:=0 to (n.count-1) do
begin
case _asnumbers of
true:i:=vi.sorted.items[p];
else i:=v.sorted.items[p];
end;
if (not _commentsattop) or (strcopy1(n.items[i]^,1,2)<>'//') then
   begin
   names.items[dcount]^:=n.items[i]^;
   values.items[dcount]^:=v.items[i]^;
   inc(dcount);
   end;
end;
//.namesREF
for p:=0 to (names.count-1) do namesREF.items[p]:=low__ref256U(names.items[p]^);
except;end;
try
freeobj(@n);
freeobj(@v);
freeobj(@vi);
except;end;
end;

procedure tdynamicvars.sortbyNAME(_asc:boolean);//12jul2016
var
   ncount,p,i:longint;
   n,v:tdynamicstring;
begin
try
//defaults
n:=nil;
v:=nil;
//init
ncount:=names.count;
if (ncount<=0) then exit;//nothing to do
n:=tdynamicstring.create;
v:=tdynamicstring.create;
n.setparams(ncount,ncount,0);
v.setparams(ncount,ncount,0);
//get
//.make a FAST copy
for p:=0 to (ncount-1) do
begin
n.items[p]^:=names.items[p]^;
v.items[p]^:=values.items[p]^;
end;
//.sort copy
n.sort(_asc);
//set
for p:=0 to (ncount-1) do
begin
i:=n.sorted.items[p];
namesREF.items[p]:=low__ref256U(n.items[i]^);
names.items[p]^:=n.items[i]^;
values.items[p]^:=v.items[i]^;
end;//p
except;end;
try
freeobj(@n);
freeobj(@v);
except;end;
end;

procedure tdynamicvars.roll(x:string;by:currency);
var
   a:currency;
begin
a:=c[x];
low__croll(a,by);
c[x]:=a;
end;

function tdynamicvars.getb(x:string):boolean;
begin
result:=(i[x]<>0);
end;

procedure tdynamicvars.setb(x:string;y:boolean);
begin
c[x]:=longint(y);
end;

function tdynamicvars.getd(x:string):double;
begin
result:=strtofloatex(value[x]);
end;

procedure tdynamicvars.setd(x:string;y:double);
begin
value[x]:=floattostrex2(y);
end;

function tdynamicvars.getnc(x:string):currency;
begin
result:=strtofloatex(swapstrsb(value[x],',',''));
end;

function tdynamicvars.getc(x:string):currency;
begin
result:=strtofloatex(value[x]);
end;

procedure tdynamicvars.setc(x:string;y:currency);
begin
value[x]:=floattostrex2(y);
end;

function tdynamicvars.getni64(x:string):comp;
begin
result:=strint64(swapstrsb(value[x],',',''));
end;

function tdynamicvars.geti64(x:string):comp;
begin
result:=strint64(value[x]);
end;

procedure tdynamicvars.seti64(x:string;y:comp);
begin
value[x]:=intstr64(y);
end;

function tdynamicvars.getni(x:string):longint;
begin
result:=strint(swapstrsb(value[x],',',''));
end;

function tdynamicvars.geti(x:string):longint;
begin
result:=strint(value[x]);
end;

procedure tdynamicvars.seti(x:string;y:longint);
begin
c[x]:=y;
end;

function tdynamicvars.getpt(x:string):tpoint;//09JUN2010
var
   a,b:string;
   p:longint;
begin
//defaults
result:=low__point(0,0);

try
//get
a:=value[x];
b:='';
for p:=1 to low__len(a) do if (a[p-1+stroffset]='|') then
   begin
   b:=strcopy1(a,p+1,low__len(a));
   a:=strcopy1(a,1,p-1);
   break;
   end;
//set
result:=low__point(strint(a),strint(b));
except;end;
end;

procedure tdynamicvars.setpt(x:string;y:tpoint);//09JUN2010
begin
value[x]:=intstr32(y.x)+'|'+intstr32(y.y);
end;

procedure tdynamicvars.copyfrom(x:tdynamicvars);
var
   p:longint;
begin
for p:=0 to (x.count-1) do value[x.name[p]]:=x.valuei[p];
end;

procedure tdynamicvars.copyvars(x:tdynamicvars;i,e:string);
var
   p:longint;
   n:string;
begin
for p:=0 to (x.count-1) do
begin
n:=x.n[p];
if filter__match(n,i) and ((e='') or (not filter__match(n,e))) then value[n]:=x.v[p];
end;//p
end;

function tdynamicvars.getincsize:longint;
begin
result:=inames.incsize;
end;

procedure tdynamicvars.setincsize(x:longint);
begin
x:=frcmin32(x,1);
inamesREF.incsize:=x;
inames.incsize:=x;
ivalues.incsize:=x;
end;

function tdynamicvars.getcount:longint;
begin
result:=inames.count;
end;

function tdynamicvars.new(n,v:string):longint;
begin
result:=_find(n,v,true);
end;

function tdynamicvars.find(n:string;var i:longint):boolean;
begin
i:=find2(n);result:=(i>=0);
end;

function tdynamicvars.find2(n:string):longint;
begin
result:=_find(n,'',false);
end;

function tdynamicvars.found(n:string):boolean;
var
   int1:longint;
begin
result:=find(n,int1);
end;

function tdynamicvars._find(n,v:string;_newedit:boolean):longint;
var
   i:longint;
   nREF:currency;
begin
//defaults
result:=-1;
if (n='') then exit;

try
//init - "uppercase" restriction removed from "n" on 14NOV2010
nREF:=low__ref256U(n);//now using "ref256U()" - 14NOV2010

//get
i:=0;
repeat
i:=inamesREF.find(i,nREF);
if (i<>-1) and strmatch(inames.items[i]^,n) then
   begin
   result:=i;
   break;
   end;
if (i<>-1) then inc(i);
until (i=-1);
//.new/edit
if _newedit then
    begin
    if (result=-1) then
       begin
       //.new empty
       result:=inamesREF.find(0,0);
       //.new
       if (result=-1) then result:=inamesREF.count;
       end;
    inamesREF.value[result]:=nREF;
    inames.value[result]:=n;
    ivalues.value[result]:=v;
    end;
except;end;
end;

procedure tdynamicvars.delete(x:longint);
begin
if (x>=0) and (x<count) then
   begin
   inamesREF.value[x]:=0;
   inames.value[x]:='';
   ivalues.value[x]:='';
   end;
end;

procedure tdynamicvars.remove(x:longint);//20oct2018
begin
if (x>=0) and (x<count) then
   begin
   inamesREF._del(x);
   inames._del(x);
   ivalues._del(x);
   end;
end;

function tdynamicvars.rename(sn,dn:string;var e:string):boolean;//22oct2018
label
   skipend;
var
   si:longint;
begin
//defaults
result:=false;
e:=gecTaskfailed;

try
//check
if (sn='') or (dn='') then
   begin
   e:=gecFilenotfound;
   goto skipend;
   end;
if not find(sn,si) then
   begin
   e:=gecFilenotfound;
   goto skipend;
   end;
if strmatch(sn,dn) then//nothing to do -> skip
   begin
   result:=true;
   goto skipend;
   end;
if found(dn) then
   begin
   e:=gecFileinuse;
   goto skipend;
   end;
//get
inames.value[si]:=dn;
inamesREF.value[si]:=low__ref256U(dn);//now using "ref256U()" - 14NOV2010
//successful
result:=true;
skipend:
except;end;
end;

function tdynamicvars.getname(x:longint):string;
begin
if (x<0) or (x>=inames.count) then result:='' else result:=inames.value[x];
end;

function tdynamicvars.getvaluei(x:longint):string;
begin
if (x<0) or (x>=inames.count) then result:='' else result:=ivalues.value[x];
end;

function tdynamicvars.getvaluelen(x:longint):longint;//20oct2018
begin
if (x<0) or (x>=inames.count) then result:=0 else result:=low__len(ivalues.items[x]^);
end;

function tdynamicvars.getvalueiptr(x:longint):pstring;
begin
if (x<0) or (x>=inames.count) then result:=nil else result:=ivalues.items[x];
end;

function tdynamicvars.getvalue(n:string):string;
var
   p:longint;
begin
p:=_find(n,'',false);
if (p=-1) then result:='' else result:=ivalues.value[p];
end;

procedure tdynamicvars.setvalue(n,v:string);
begin
_find(n,v,true);
end;

procedure tdynamicvars.clear;
begin
inamesREF.clear;
inames.clear;
ivalues.clear;
end;


//## tdynamicstr8 ##############################################################
constructor tdynamicstr8.create;//28dec2023
begin
if classnameis('tdynamicstr8') then track__inc(satDynstr8,1);
inherited create;
ifallback:=str__new8;
end;

destructor tdynamicstr8.destroy;
begin
try
str__free(@ifallback);
inherited destroy;
if classnameis('tdynamicstr8') then track__inc(satDynstr8,-1);
except;end;
end;

procedure tdynamicstr8._init;
begin
_setparams(0,0,sizeof(pointer),false);
ilockedBPI:=true;
end;

procedure tdynamicstr8._corehandle;
begin
iitems:=core;
end;

procedure tdynamicstr8._oncreateitem(sender:tobject;index:longint);
begin
iitems[index]:=str__new8;
inherited;
end;

procedure tdynamicstr8._onfreeitem(sender:tobject;index:longint);
begin
inherited;
str__free(@iitems[index]);
end;

function tdynamicstr8.getvalue(_index:longint):tstr8;
begin
result:=nil;

try
if (_index>=0) and (_index<count) then result:=items[_index] else result:=nil;
if (result=nil) then
   begin
   if (ifallback.len<>0) then ifallback.clear;
   result:=ifallback;
   end;
except;end;
end;

function tdynamicstr8.isnil(_index:longint):boolean;//25jul2024
begin
result:=(_index<0) or (_index>=count) or (items[_index]=nil);
end;

procedure tdynamicstr8.setvalue(_index:longint;_value:tstr8);//accepts "_value=nil" which creates the index item and clears it's contents
label
   skipend;
begin
try
//lock
str__lock(@_value);
//get
if (_index>=0) then
   begin
   //set
   if (_index>=isize) and (not atleast(_index)) then goto skipend;
   //count
   if (_index>=icount) then icount:=_index+1;
   //set
   if (items[_index]<>nil) then
      begin
      items[_index].clear;
      if (_value<>nil) then items[_index].add(_value);
      end;
   end;
skipend:
except;end;
try;str__uaf(@_value);except;end;
end;

function tdynamicstr8.getsvalue(_index:longint):tstr8;
begin
result:=value[sindex(_index)];
end;

procedure tdynamicstr8.setsvalue(_index:longint;_value:tstr8);
begin
if str__lock(@_value) then value[sindex(_index)].add(_value);
str__uaf(@_value);
end;

function tdynamicstr8.find(_start:longint;_value:tstr8):longint;
var
   p:longint;
begin
//defaults
result:=-1;

try
//check
if (_start<0) or (_start>=count) then exit;
//process
for p:=_start to (icount-1) do if (iitems[p]=_value) then
    begin
    result:=p;
    break;
    end;
except;end;
end;


//global memory procs ----------------------------------------------------------
function global__create(xsize:comp):pointer;//19may2025
var
   h:hglobal;
begin

//defaults
result:=nil;

//get
if (xsize>=1) then
   begin

   h:=win____GlobalAlloc(GMEM_MOVEABLE, restrict32(xsize) );
   if (h<>0) then result:=win____GlobalLock(h);

   if (result<>nil) then
      begin

      system_memory_bytes:=add64( system_memory_bytes, global__size(result) );
      inc64(system_memory_count,1);

      low__irollone64(system_memory_createcount);

      end;

   end;

end;

procedure global__free(var xptr:pointer);//01sep2025
var
   h:hglobal;
begin

if (xptr<>nil) then
   begin

   //free
   h:=win____GlobalHandle(xptr);

   if (h<>0) then
      begin

      //track
      system_memory_bytes:=sub64(system_memory_bytes,global__size(xptr));
      dec64(system_memory_count,1);

      //free
      win____GlobalUnlock(h);
      win____GlobalFree(h);

      end;

   //set to nil
   xptr:=nil;

   low__irollone64(system_memory_freecount);
   end;

end;

function global__resize(xptr:pointer;xnewsize:comp):pointer;
begin
global__resize2(xptr,xnewsize,result);
end;

function global__resize2(xptr:pointer;xnewsize:comp;var xoutptr:pointer):boolean;//26aug2025
var
   h:hglobal;
   xoldsize:comp;
begin

//filter
xnewsize:=restrict32(xnewsize);

//reallocate existing memory
if (xptr<>nil) and (xnewsize>=1) then
   begin

   xoldsize:=global__size(xptr);

   //MS -> if it fails, original memory and pointer remain valid - 26aug2025
   h:=win____GlobalHandle(xptr);
   if (h<>0) then win____GlobalUnlock(h);

   h:=win____GlobalReAlloc(h, restrict32(xnewsize), GMEM_MOVEABLE);
   if (h<>0) then xoutptr:=win____GlobalLock(h) else xoutptr:=nil;

   if (xoutptr<>nil) then
      begin

      system_memory_bytes:=add64(system_memory_bytes,xnewsize);
      system_memory_bytes:=sub64(system_memory_bytes,xoldsize);

      result:=true;

      end

   else
      begin

      //keep previous
      h:=win____GlobalHandle(xptr);
      if (h<>0) then xoutptr:=win____GlobalLock(h) else xoutptr:=nil;

      result  :=false;

      end;

   end

//free existing memory
else if (xptr<>nil) and (xnewsize<=0) then
   begin

   global__free(xptr);
   xoutptr :=nil;
   result  :=true;

   end

//create new memory
else if (xptr=nil) and (xnewsize>=1) then
   begin

   xoutptr :=global__create(xnewsize);
   result  :=(xoutptr<>nil);

   end

//do nothing
else
   begin

   xoutptr :=xptr;
   result  :=false;

   end;

end;

function global__size(xptr:pointer):comp;
var
   h:hglobal;
begin

h:=win____GlobalHandle(xptr);
if (h<>0) then result:=win____GlobalSize(h) else result:=0;

end;


//memory management procs ------------------------------------------------------

function mem__create32(xsize:longint):pointer;
begin
result:=mem__create(xsize);
end;

function mem__create(xsize:comp):pointer;
var
   xsize32:longint;
begin

xsize32:=restrict32(xsize);

if (xsize>=1) then
   begin

   result:=win____HeapAlloc(win____getprocessheap,0,xsize32);

   if (result<>nil) then
      begin

      system_memory_bytes:=add64(system_memory_bytes,xsize32);
      inc64(system_memory_count,1);

      low__irollone64(system_memory_createcount);

      end;

   end
else result:=nil;

end;

function mem__free(var xptr:pointer):boolean;//thread safe
var
   xoldsize:comp;
begin

//MS -> xptr can be nil and still be valid
xoldsize:=mem__size(xptr);

result:=(xptr<>nil) and win____HeapFree(win____getprocessheap,0,xptr);

if result then
   begin

   system_memory_bytes:=sub64(system_memory_bytes, xoldsize );
   dec64(system_memory_count,1);
   xptr:=nil;

   low__irollone64(system_memory_freecount);

   end;

end;

function mem__free2(xptr:pointer):longint;
begin

result:=0;
mem__free(xptr);

end;

function mem__size(xptr:pointer):comp;
begin

case (xptr<>nil) of
true:result:=frcmin64( win____heapsize(win____getprocessheap, 0, xptr)  ,0);
else result:=0
end;//case

end;

function mem__resize32(xptr:pointer;xnewsize:longint):pointer;
begin
mem__resize3(xptr,xnewsize,false,result);
end;

function mem__resize(xptr:pointer;xnewsize:comp):pointer;//thread safe - 26aug2026
begin
mem__resize3(xptr,xnewsize,false,result);
end;

function mem__resize2(xptr:pointer;xnewsize:comp;var xoutptr:pointer):boolean;//thread safe - 26aug2026
begin
result:=mem__resize3(xptr,xnewsize,false,xoutptr);
end;

function mem__resize3(xptr:pointer;xnewsize:comp;xclearnewbytes:boolean;var xoutptr:pointer):boolean;//thread safe - 26aug2026
var
   xoldsize:comp;
   xnewsize32,p:longint;
begin

xnewsize32:=restrict32(xnewsize);

//reallocate existing memory
if (xptr<>nil) and (xnewsize>=1) then
   begin

   xoldsize:=mem__size(xptr);

   //MS -> if it fails, original memory and pointer remain valid - 26aug2025
   xoutptr:=win____HeapReAlloc( win____getprocessheap, 0, xptr, xnewsize32 );

   if (xoutptr<>nil) then
      begin

      //clear newly allocated bytes
      if xclearnewbytes and (xnewsize32>xoldsize) then
         begin

         for p:=restrict32(xoldsize) to (xnewsize32-1) do pdlbyte(xoutptr)[p]:=0;

         end;//p

      //track
      system_memory_bytes:=add64( system_memory_bytes, xnewsize32 );
      system_memory_bytes:=sub64( system_memory_bytes, xoldsize );

      result:=true;

      end

   else
      begin

      xoutptr :=xptr;//keep previous
      result  :=false;

      end;

   end

//free existing memory
else if (xptr<>nil) and (xnewsize<=0) then
   begin

   mem__free(xptr);
   xoutptr :=nil;
   result  :=true;

   end

//create new memory
else if (xptr=nil) and (xnewsize>=1) then
   begin

   xoutptr :=mem__create(xnewsize);//allocate new memory
   result  :=(xoutptr<>nil);

   end

//do nothing
else
   begin

   xoutptr :=xptr;
   result  :=false;

   end;

end;

procedure mem__newpstring(var z:pstring);//29NOV2011
begin
track__inc(satPstring,1);
system.new(z);
end;

procedure mem__despstring(var z:pstring);//29NOV2011
begin
system.dispose(z);
track__inc(satPstring,-1);
end;


//pointer procs ----------------------------------------------------------------

function ptr__shift(xstart:pointer;xshift:longint):pointer;
begin
//32bit only -> cardinal only supports 0..2.1 Gb
result:=pointer(cardinal(xstart)+xshift);
end;

function ptr__copy(const s:pointer;var d):boolean;
begin
result:=true;
tpointer(d):=tpointer(s);
end;


//bitwise procs ----------------------------------------------------------------

function bit__true32(xvalue:longint;xindex:longint):boolean;
begin
if (xindex<0) then xindex:=0 else if (xindex>31) then xindex:=31;
result:=((xvalue and (1 shl xindex))<>0);
end;

function bit__hasval32(xvalue,xhasthisval:longint):boolean;
var
   p:longint;
begin
result:=true;

for p:=0 to 31 do if bit__true32(xhasthisval,p) and (not bit__true32(xvalue,p)) then
   begin
   result:=false;
   break;
   end;//p
end;

function bit__findfirst32(xvalue:longint):longint;//find first on bit (1) - 08jun2025
var
   p:longint;
begin
result:=0;
for p:=0 to 31 do if bit__true32(xvalue,p) then
   begin
   result:=p;
   break;
   end;
end;

function bit__findcount32(xvalue:longint):longint;//count number of on bits (1) - 08jun2025
var
   p:longint;
begin
result:=0;
for p:=0 to 31 do if bit__true32(xvalue,p) then inc(result);
end;


//dialog procs -----------------------------------------------------------------

function dialog__password(var xpassword:string):boolean;//08oct2025
var
   a:tpassdialog;
begin

//defaults
result :=false;
a      :=nil;

try
//init
a      :=tpassdialog.create;

//get
result :=a.execute(xpassword);

except;end;

//free
freeobj(@a);

end;

function dialog__color(var xcolor:longint):boolean;//08oct2025
var
   clist:array[0..15] of tcolor32;//required by MS color dialog
   z:tchoosecolor;
   v:tfastvars;
   p:longint;
begin

//defaults
result :=false;
v      :=nil;

try
//init
low__cls(@z,sizeof(z));

//get color list
v      :=tfastvars.create;
v.text :=io__fromfilestr2( app__settingsfile('syscol16.ini') );
for p:=0 to high(clist) do clist[p]:=int__c32(v.i['col.'+intstr32(p)]);

//prompt
z.lStructSize    :=sizeof(z);
z.hWndOwner      :=app__mainformHandle;//required -> tracks which monitor to display on - 06oct2025
z.flags          :=CC_RGBINIT or CC_FULLOPEN or CC_ANYCOLOR;
z.rgbResult      :=xcolor;
z.lpCustColors   :=@clist;

//get
result:=win____ChooseColor(z);
if result then xcolor:=z.rgbResult;

//set color list
v.clear;
for p:=0 to high(clist) do v.i['col.'+intstr32(p)]:=c32__int(clist[p]);
io__tofilestr2( app__settingsfile('syscol16.ini'), v.text );

except;end;

//free
freeobj(@v);

end;

function dialog__mask(const xlabel,xmasklist:string):string;
begin

case (xmasklist<>'') of
true:result:=xlabel+' ('+xmasklist+')'+#0+xmasklist+#0;
else result:='';
end;//case

end;

function dialog__open(var xfilename,xfilterlist:string):boolean;//10oct2025
begin
result:=dialog__open2(xfilename,xfilterlist,'');
end;

function dialog__open2(var xfilename,xfilterlist:string;const xtitle:string):boolean;//10oct2025
var
   a:tobject;
   dinitfolder,dext,dlist:string;
   p,dindex:longint;
   derror:boolean;
   z:topenfilename;
   zfilename:tstr8;

begin

//defaults
result            :=false;
a                 :=nil;
derror            :=false;
zfilename         :=nil;

try
//folder fallback
dinitfolder:=io__extractfilepath(xfilename);
if not io__folderexists(dinitfolder) then dinitfolder:=io__extractfilepath(io__exename);
if not io__folderexists(dinitfolder) then dinitfolder:=io__windrive;


//init
dialog__readfilter(xfilterlist,dindex,dext,dlist);
if (dlist='') then dlist:=#0#0#0 else dlist:=dlist+#0;

low__cls(@z,sizeof(z));

zfilename         :=str__new8;
zfilename.setlen(1+max16);
zfilename.fill(0,zfilename.len-1,0);//fill with null chars

z.lStructSize     :=sizeof(z);
z.hWndOwner       :=app__mainformHandle;//required -> tracks which monitor to display on - 06oct2025
z.lpstrFile       :=zfilename.core;
z.nMaxFile        :=zfilename.len;
z.flags           :=OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST or OFN_LONGNAMES or OFN_HIDEREADONLY;
z.lpstrFilter     :=pchar(dlist);
z.nFilterIndex    :=dindex;
z.lpstrInitialDir :=pchar(dinitfolder);
z.lpstrDefExt     :=pchar(dext);

if (xtitle<>'') then z.lpstrTitle:=pchar(xtitle);

//get
result:=win____GetOpenFileName(z);

if result then
   begin

   //get filename
   xfilename:=str__nullstr(@zfilename);

   //update filterlist to include the "filterIndex" used by user -> remembered for next time
   dialog__updateFilterList(xfilterlist,z.nFilterIndex);

   end;

except;derror:=true;end;

//free
freeobj(@zfilename);

end;

function dialog__save(var xfilename,xfilterlist:string):boolean;//10oct2025
begin
result:=dialog__save2(xfilename,xfilterlist,'');
end;

function dialog__save2(var xfilename,xfilterlist:string;const xtitle:string):boolean;//12oct2025, 10oct2025
label
   redo;
var
   a:tobject;
   dfilename,dinitfolder,dext,dlist:string;
   p,dindex:longint;
   derror:boolean;
   z:topenfilename;
   zfilename:tstr8;

begin

//defaults
result            :=false;
a                 :=nil;
derror            :=false;
zfilename         :=nil;

redo:
try
//fallback filename -> must have a name for the file -> else dialog fails to display
dfilename:=xfilename;
if (io__extractfilename(dfilename)='') then dfilename:=dfilename+'Untitled';

//folder fallback
dinitfolder:=io__extractfilepath(dfilename);
if not io__folderexists(dinitfolder) then dinitfolder:=io__extractfilepath(io__exename);
if not io__folderexists(dinitfolder) then dinitfolder:=io__windrive;

//init
dialog__readfilter(xfilterlist,dindex,dext,dlist);
if (dlist='') then dlist:=#0#0#0 else dlist:=dlist+#0;

low__cls(@z,sizeof(z));

zfilename         :=str__new8;
zfilename.setlen(1+max16);
zfilename.fill(0,zfilename.len-1,0);//fill with null chars

for p:=1 to frcmax32(low__len(dfilename),zfilename.len-2) do zfilename.pbytes[p-1]:=byte(dfilename[p-1+stroffset]);

z.lStructSize     :=sizeof(z);
z.hWndOwner       :=app__mainformHandle;//required -> tracks which monitor to display on - 06oct2025
z.lpstrFile       :=zfilename.core;
z.nMaxFile        :=zfilename.len;
z.flags           :=OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_HIDEREADONLY;
z.lpstrFilter     :=pchar(dlist);
z.nFilterIndex    :=dindex;
z.lpstrInitialDir :=pchar(dinitfolder);
z.lpstrDefExt     :=pchar(dext);

if (xtitle<>'') then z.lpstrTitle:=pchar(xtitle);

//get
result:=win____GetSaveFileName(z);

if result then
   begin

   //get filename
   xfilename:=str__nullstr(@zfilename);

   //update filterlist to include the "filterIndex" used by user -> remembered for next time
   dialog__updateFilterList(xfilterlist,z.nFilterIndex);

   //enforce filter file extension
   dialog__readfilter(xfilterlist,dindex,dext,dlist);

   if (dext<>'') and (not strmatch(dext,io__readfileext(xfilename,false))) then xfilename:=xfilename+'.'+dext;

   end;

except;derror:=true;end;

//free
freeobj(@zfilename);

//prompt replace
if result and io__fileexists(xfilename) then
   begin

   if not showquery( io__extractfilename(xfilename) + rcode + rcode + translate('Replace existing file?') ) then goto redo;

   end;

end;

function dialog__readfilter(const xfilterlist:string;var xindex:longint;var xdefext,xlist:string):boolean;//10oct2025
label
   redo;

const
   xsep=#0;

var
   vlen,findex,dcount,p,p2:longint;
   str1:string;
   donce:boolean;

   function v(const xindex:longint):char;
   begin
   if (xindex<1) or (xindex>vlen) then result:=xsep else result:=xlist[xindex-1+stroffset];
   end;

begin

//pass-thru
result        :=true;
donce         :=true;
dcount        :=0;
findex        :=1;
xindex        :=1;
xdefext       :='';
xlist         :=xfilterlist;

//find "xindex" value
if low__splitstr(xfilterlist,ssQuestion,str1,xlist) then xindex:=frcmin32(strint32(str1),1);

//extract default extension from filterlist -> over allow by +1
vlen          :=low__len(xlist);
findex        :=xindex;

redo:

for p:=1 to (vlen+1) do if (v(p)=xsep) then
   begin
   inc(dcount);
   if ( (2*findex) = dcount ) then
      begin

      for p2:=p downto 1 do if (v(p2)='.') or (v(p2)='*') or (v(p2)=')') then
         begin

         xdefext:=strcopy1(xlist,p2+1,p-p2-1);
         break;

         end;//p2

      break;

      end;

   end;//p

//we have no "defext" so use first extension
if ((xdefext='') or (xdefext='*') or (xdefext='*.*')) and donce then
   begin

   donce    :=false;
   dcount   :=0;
   findex   :=1;
   goto     redo;

   end;

end;

function dialog__updateFilterList(var xfilterlist:string;const dindex:longint):boolean;
var
   xindex:longint;
   xdefext,xlist:string;
begin

//pass-thru
result:=true;

dialog__readfilter(xfilterlist,xindex,xdefext,xlist);
xfilterlist:=intstr32(frcmin32(dindex,1))+'?'+xlist;

end;


//misc procs -------------------------------------------------------------------

procedure StrDispose(Str: PChar);
begin
  if Str <> nil then
  begin
    Dec(Str, SizeOf(Cardinal));
    FreeMem(Str, Cardinal(Pointer(Str)^));
  end;
end;

function StrAlloc(Size: Cardinal): PChar;
begin
  Inc(Size, SizeOf(Cardinal));
  GetMem(Result, Size);
  Cardinal(Pointer(Result)^) := Size;
  Inc(Result, SizeOf(Cardinal));
end;


function translate(const x:string):string;
begin
result:=x;
end;

function low__closecount:longint;
var
   p:longint;
begin
//defaults
result:=sysclose_count;

//try;for p:=0 to high(syslist) do if zzok(syslist[p],1030) and (syslist[p] is tbasicsystem) then inc(result,(syslist[p] as tbasicsystem).closelocked);except;end;
end;

procedure low__closelock;
begin
if (sysclose_count<max32) then inc(sysclose_count,1);
end;

procedure low__closeunlock;
begin
if (sysclose_count>min32) then sysclose_count:=frcmin32(sysclose_count-1,0);
end;

function debugging:boolean;
begin
{$ifdef debug}result:=true;{$else}result:=false;{$endif}
end;

function low__fireevent(xsender:tobject;x:tevent):boolean;
begin
result:=false;
try
if assigned(x) then
   begin
   x(xsender);
   result:=true;
   end;
except;end;
end;

procedure runLOW(fDOC,fPARMS:string);//stress tested on Win98/WinXP - 27NOV2011, 06JAN2011
begin
try;win____shellexecute(0,nil,pchar(fDoc),pchar(fPARMS),nil,1);except;end;
end;

function vnew:tvars8;
begin
result:=tvars8.create;
end;

function freeobj(x:pobject):boolean;//01sep2025, 22jun2024: Updated for GUI support, 09feb2024: Added support for "._rtmp" & mustnil, 02feb2021, 05may2020, 05DEC2011, 14JAN2011, 15OCT2004
var
   xmustnil:boolean;
begin//Note: as a function this proc supports inline processing -> e.g. if a and b and freeobj() and d then -> which uses LESS code

//pass-thru
result:=true;

try
//check
if (x=nil) or (x^=nil)  then exit;

//-- shutdown handlers ---------------------------------------------------------

//mustnil - Special case when the pointer refers to the "_rtmp" var on the object itself. This is used by "str__ptr()" to
//          cache the pointer of a floating tstr8/tstr9 object, from a call like "low__tofile64('myfile.dat',str__ptr(vars8.data),e)".
//          A call to "vars8.data" returns a tstr8 object with data, which must be destroyed by the proc it's passed to, in this case low__tofile64.
//          It is not safe to pass this directly, so tstr__ptr() stores it in "_rtmp" on the object in question - 09feb2024

xmustnil:=true;
if (x^ is tobjectex) and (x=@(x^ as tobjectex).__cacheptr) then xmustnil:=false;

//free the object
x^.free;
zzdel(x^);//Note: Must immediately follow the object's "free" proc - 04may2021

//safe to set the owner var to nil
if xmustnil then x^:=nil;

except;end;
end;

function low__comparearray(const a,b:array of byte):boolean;//27jan2021
var
   ai,bi,va,vb,p:longint;
begin
//defaults
result:=false;

//get
if (sizeof(a)=sizeof(b)) then
   begin
   //init
   result:=true;
   ai:=low(a);
   bi:=low(b);
   //get
   for p:=1 to sizeof(a) do
   begin
   va:=a[ai];
   vb:=b[bi];
   if (va>=97) and (va<=122) then dec(va,32);
   if (vb>=97) and (vb<=122) then dec(vb,32);
   if (va<>vb) then
      begin
      result:=false;
      break;
      end;
   //inc
   inc(ai);
   inc(bi);
   end;//p
   end;
end;

function low__cls(x:pointer;xsize:longint):boolean;
begin
result:=(x<>nil);
if result then fillchar(x^,xsize,0);
end;


//filter procs -----------------------------------------------------------------

function filter__sort(const xfilterlist:string):string;
var
   a:tdynamicstring;
   p:longint;
   xout:string;

   function mi(const x:string):boolean;
   begin

   result:=low__havechar(x,fesepX);

   end;

   function sa(const x:string):boolean;
   begin

   result:=(x<>'');
   if result then xout:=xout+x+fesep;

   end;

begin

//defaults
result   :='';
xout     :='';
a        :=nil;

try
//init
a        :=tdynamicstring.create;
a.text   :=swapcharsb(xfilterlist,fesep,#10);
a.sort(true);

//multi-items -> not sorted order
for p:=0 to pred(a.count) do if mi(a.value[p]) and sa(a.value[p]) then a.value[p]:='';

//single-items -> in sorted order
for p:=0 to pred(a.count) do if (a.svalue[p]<>feany) and sa(a.svalue[p]) then a.svalue[p]:='';

//remaining items -> e.g. feany
for p:=0 to pred(a.count) do if sa(a.svalue[p]) then a.svalue[p]:='';

//get
result:=xout;

except;end;

//free
freeobj(@a);

end;

function filter__match(const xline,xmask:string):boolean;//18sep2025, 04nov2019
label//Handles semi-complex masks (upto two "*" allowed in a xmask - 04nov2019
     //Superfast: between 20,000 (short ~14c) to 4,000 (long ~160c) comparisons/sec -> Intel atom 1.33Ghz
     //Accepts masks:
     // exact='aaaaaaaaaaa', two-part='aaaaaa*aaaaaa', tri-part='aaa*aaa*aaa',
     // start='aaa*' or 'aaa*aaa*', end='*aaaa' or '*aaa*aaa', any='**' or '*'
   skipend;
var
   fs,fm,fe:string;
   fmlen,xpos,xpos2,xlen,p:longint;
   fexact,bol1:boolean;
begin
//defaults
result:=false;

try
//check
if (xmask='') then exit;
xlen:=low__len(xline);
if (xlen<=0) then exit;
//init
fs:=xmask;
fm:='';
fe:='';
fexact:=true;
//.fs
if (fs<>'') then for p:=1 to low__len(fs) do if (fs[p-1+stroffset]='*') then
   begin
   fe:=strcopy1(fs,p+1,low__len(fs));
   fs:=strcopy1(fs,1,p-1);
   fexact:=false;
   break;
   end;
//.fe
if (fe<>'') then for p:=low__len(fe) downto 1 do if (fe[p-1+stroffset]='*') then
   begin
   fm:=strcopy1(fe,1,p-1);
   strdel1(fe,1,p);
   fexact:=false;
   break;
   end;
//find
xpos:=1;

//.fexact
if fexact and (not strmatch(fs,xline)) then goto skipend;
//.fs
if (fs<>'') then
   begin
   if not strmatch(fs,strcopy1(xline,1,low__len(fs))) then goto skipend;
   xpos:=low__len(fs)+1;
   end;
//.fe
if (fe<>'') then
   begin
   xpos2:=low__len(xline)-low__len(fe)+1;
   if (xpos2<xpos) then goto skipend;
   if not strmatch(fe,strcopy1(xline,xpos2,low__len(fe))) then goto skipend;
   dec(xlen,low__len(fe));
   end;
//.fm
if (fm<>'') then
   begin
   fmlen:=low__len(fm);
   xpos2:=xlen-fmlen+1;
   if (xpos2<xpos) then goto skipend;
   bol1:=false;
   for p:=xpos to xpos2 do if strmatch(fm,strcopy1(xline,p,fmlen)) then//faster than "c1/c2" + comparetext (200% faster) - 04nov2019
      begin
      bol1:=true;
      break;
      end;//p
   if not bol1 then goto skipend;
   end;
//successful
result:=true;
skipend:
except;end;
end;

function filter__matchb(const xline,xmask:string):boolean;//18sep2025, 04nov2019
begin
result:=filter__match(xline,xmask);
end;

function filter__matchlist(const xline,xmasklist:string):boolean;//18sep2025, 04oct2020
var//Note: masklist => "*.bmp;*.jpg;*.jpeg" etc
   lp,p,xlen:longint;
   str1:string;
   bol1:boolean;
begin
//defaults
result:=false;

try
//init
xlen:=low__len(xmasklist);
if (xlen<=0) then exit;
//get
lp:=1;
for p:=1 to xlen do
begin
bol1:=(xmasklist[p-1+stroffset]=fesep);//fesep=";"
if bol1 or (p=xlen) then
   begin
   //init
   if bol1 then str1:=strcopy1(xmasklist,lp,p-lp) else str1:=strcopy1(xmasklist,lp,p-lp+1);
   lp:=p+1;
   //get
   if (str1<>'') and filter__match(xline,str1) then
      begin
      result:=true;
      break;
      end;
   end;
end;//p
except;end;
end;


//string and number procs ------------------------------------------------------

procedure low__swapint(var x,y:longint);
var
   z:longint;
begin
z:=x;
x:=y;
y:=z;
end;

function low__size(x:comp;xstyle:string;xpoints:longint;xsym:boolean):string;//01apr2024:plus support, 10feb2024: created
var
   xorgstyle,vneg,v,vp,s:string;
   vlen:longint;

   procedure xdiv(xdivfactor:longint;xsymbol:string);
   label
      skipend;
   begin
   try
   //range
   xdivfactor:=frcmin32(xdivfactor,0);
   //get
   s:=xsymbol;
   if (xdivfactor<=0) then goto skipend;
   //set
   vp:=strcopy1(v,vlen-frcmin32(xdivfactor-1,0),vlen);
   vp:=strcopy1(strcopy1('000000000000',1,xdivfactor-low__len(vp))+vp,1,xpoints);
   if (xdivfactor>=1) then
      begin
      strdel1(v,vlen-(xdivfactor-1),vlen);
      vlen:=low__len(v);
      if (strbyte1(v,vlen)=ssComma) then strdel1(v,vlen,1);
      if (v='') then v:='0';
      end;
   skipend:
   except;end;
   end;
begin
//defaults
result:='0';

try
//init
xpoints:=frcrange32(xpoints,0,3);
xstyle:=strlow(xstyle);
xorgstyle:=xstyle;
v:=k64(x);
vlen:=low__len(v);
vp:='';
vneg:='';

//minus
if (strbyte1(v,1)=ssdash) then
   begin
   vneg:='-';
   strdel1(v,1,1);
   vlen:=low__len(v);
   end;

//automatic style
if (xstyle='?') or (xstyle='mb+') then
   begin
   if      (vlen<=3)  then xstyle:='b'
   else if (vlen<=7)  then xstyle:='kb'
   else if (vlen<=11) then xstyle:='mb'
   else if (vlen<=15) then xstyle:='gb'
   else if (vlen<=19) then xstyle:='tb'
   else if (vlen<=23) then xstyle:='pb'
   else                    xstyle:='eb';

   //.plus -> force to this unit and above - 01apr2024
   if      (xorgstyle='kb+') and (vlen<=3)  then xstyle:='kb'
   else if (xorgstyle='mb+') and (vlen<=7)  then xstyle:='mb'
   else if (xorgstyle='gb+') and (vlen<=11) then xstyle:='gb'
   else if (xorgstyle='tb+') and (vlen<=15) then xstyle:='tb'
   else if (xorgstyle='pb+') and (vlen<=19) then xstyle:='pb'
   else if (xorgstyle='eb+') and (vlen<=23) then xstyle:='eb';
   end;

//get
if      (xstyle='kb') then xdiv(3,'KB')
else if (xstyle='mb') then xdiv(6+1,'MB')
else if (xstyle='gb') then xdiv(9+2,'GB')
else if (xstyle='tb') then xdiv(12+3,'TB')
else if (xstyle='pb') then xdiv(15+4,'PB')
else if (xstyle='eb') then xdiv(18+5,'EB')
else                       xdiv(0,'b');

//set
result:=vneg+v+insstr('.'+vp,vp<>'')+insstr(#32+s,xsym);
except;end;
end;

function low__mbPLUS(x:comp;sym:boolean):string;//01apr2024: created
begin
result:=low__size(x,'mb+',3,sym);
end;

function low__bDOT(x:comp;sym:boolean):string;
begin
result:=low__size(x,'b',0,sym);
swapchars(result,',','.');
end;

function low__b(x:comp;sym:boolean):string;//fixed - 30jan2016
begin
result:=low__size(x,'b',0,sym);
end;

function low__kb(x:comp;sym:boolean):string;
begin
result:=low__size(x,'kb',3,sym);
end;

function low__kbb(x:comp;p:longint;sym:boolean):string;
begin
result:=low__size(x,'kb',p,sym);
end;

function low__mb(x:comp;sym:boolean):string;
begin
result:=low__size(x,'mb',3,sym);
end;

function low__mbb(x:comp;p:longint;sym:boolean):string;
begin
result:=low__size(x,'mb',p,sym);
end;

function low__gb(x:comp;sym:boolean):string;
begin
result:=low__size(x,'gb',3,sym);
end;

function low__gbb(x:comp;p:longint;sym:boolean):string;
begin
result:=low__size(x,'gb',p,sym);
end;

function low__mbAUTO(x:comp;sym:boolean):string;//auto range - 10feb2024, 08DEC2011, 14NOV2010
begin
result:=low__size(x,'?',3,sym);
end;

function low__mbAUTO2(x:comp;p:longint;sym:boolean):string;//auto range - 10feb2024, 08DEC2011, 14NOV2010
begin
result:=low__size(x,'?',p,sym);
end;

function str__ecapkey:string;
const//generate random key
   map='asdfklj4imzxhmewro982489alkt9[1239-12,as[023aeoi43q[9';
var
   maxp,p:longint;
   x:string;
begin

//init
maxp :=10+random(41);//10-50
x    :=strcopy1(map,1,maxp);

//get
for p:=1 to maxp do x[p-1+stroffset]:=map[1+random(50)];

//set
result:=x;

end;

function str__ecap(const x:string;xencrypt:boolean):string;
begin
result:=str__ecap2(x,xencrypt,false);
end;

function str__ecap2(x:string;xencrypt,xbin:boolean):string;
var//encrypt/decrypt caption - valid input range 14-255
   klen:longint;
   z,k:string;
   ee,dd:byte;
begin

//defaults
result :='';

//check
if (x='') then exit;

try
//ascii/binary
case xbin of
true:begin

   ee:=glseEncrypt;
   dd:=glseDecrypt;

   end;
else begin

   ee:=glseTextEncrypt;
   dd:=glseTextDecrypt;

   end;
end;//case

//get
case xencrypt of
true:begin//encrypt

    //generate key
    k     :=str__ecapkey;
    klen  :=low__len(k);

    //get
    z:=str__stdencrypt(x,k,ee);

    //header - kLlength(1),Key(10-50),eData(0..X)}
    z:=char(14+klen)+str__stdencrypt(k,glseEDK,dd)+z;

    //filter
    if not xbin then swapstrs(z,#39,#39+#39);

    //return result}
    result:=z;

    end;
else begin//decrypt

   //filter
   if not xbin then swapstrs(x,#39+#39,#39);

   //klength
   klen:=byte(x[0+stroffset])-14;

   //init
   k:=strcopy1(x,2,klen);
   z:=strcopy1(x,klen+2,low__len(x));

   //decrypt
   k:=str__stdencrypt(k,glseEDK,ee);
   z:=str__stdencrypt(z,k,dd);

   //return result
   result:=z;

   end;
end;//case
except;end;
end;

function str__stdencrypt(const x:string;ekey:string;mode1:longint):string;//03oct2025
var
   Lt,El,E,p2,p:longint;
begin

//defaults
result:=x;

try

//default -> fail safe key
if (ekey='') then ekey:='198dlkjq34';

//init
lt     :=low__len(result);
el     :=low__len(ekey);
e      :=0;

//get
case Mode1 of
0:begin//encrypt string

   for p:=1 to lt do
   begin

   inc(e);
   if (e>el) then e:=1;

   p2:=byte(ekey[e-1+stroffset])+byte(result[p-1+stroffset]);
   if (p2>255) then dec(p2,256);

   result[p-1+stroffset]:=char(p2);

   end;//p

   end;
1:begin//decrypt the string

   for p:=1 to lt do
   begin

   inc(e);
   if (e>el) then e:=1;

   p2:=byte(result[p-1+stroffset])-byte(ekey[e-1+stroffset]);
   if (p2<0) then inc(p2,256);

   result[p-1+stroffset]:=char(p2);

   end;//p

   end;
2:begin//encrypt plaintext to plaintext string (13-255)

  for p:=1 to lt do
  begin

  inc(e);
  if (e>el) then e:=1;

  p2:=byte(ekey[e-1+stroffset])+byte(result[p-1+stroffset]);
  if (p2>255) then dec(p2,242);//**

  result[p-1+stroffset]:=char(p2);

  end;//p

  end;
3:begin//decrypt plaintext to plaintext string (13-255)

  for p:=1 to lt do
  begin

  inc(e);
  if (e>el) then e:=1;

  p2:=byte(result[p-1+stroffset])-byte(ekey[e-1+stroffset]);
  if (p2<14) then inc(p2,242);

  result[p-1+stroffset]:=char(p2);

  end;//p

  end;
end;//case

except;end;
end;

function strm(const sfullname,spartialname:string;var vs:string;var v:longint):boolean;//05oct2025
begin

result:=strmatch( spartialname, strcopy1(sfullname,1,low__len(spartialname)) );
if result then
   begin

   vs:=strcopy1(sfullname,low__len(spartialname)+1,low__len(sfullname));
   v :=strint32(vs);

   end
else
   begin

   vs:='';
   v :=0;

   end;

end;

function str__addval(var xdatastream:string;const xname,xval:string):boolean;//05oct2025
begin

//defaults
result:=false;

try

//get
xdatastream  :=

 xdatastream +

 str__from32(low__len(xname)) + xname +

 str__from32(low__len(xval))  + xval;

//successful
result:=true;

except;end;

end;

function str__makehash(const x:string):string;//13oct2025
var
   s,d:tstr8;
begin

//defaults
result :='';

try
//init
s      :=nil;
d      :=nil;

//get
s      :=small__new8;
d      :=small__new8;
s.text :=x;
s.text :=intstr64(low__ref256(x))+'_'+intstr64(low__crc32nonzero(s));
str__tob64(@s,@d,0);
result :=d.text;
except;end;

//free
small__free8(@s);
small__free8(@d);

end;

function str__pullval(var xpos:longint;const xdatastream:string;var xname,xval:string):boolean;//05oct2025
//v2 - returns an error if past EOT

   function xpull(var v:string):boolean;
   var
      xlen:longint;
   begin

   result :=false;

   xlen   :=str__to32( strcopy1(xdatastream,xpos,4) );
   inc(xpos,4);

   if (xlen<0) or (xpos>low__len(xdatastream)) then exit;

   v      :=strcopy1(xdatastream,xpos,xlen);
   inc(xpos,xlen);

   result :=(xlen = low__len(v) );

   end;

begin

//defaults
result   :=false;
xname    :='';
xval     :='';

try

//range
if (xpos<1) then xpos:=1;

//get
result:=xpull(xname) and xpull(xval);

except;end;
end;

procedure str__dispose(Str: PChar);
begin
  if Str <> nil then
  begin
    dec(str, sizeof(cardinal));
    freemem(Str, Cardinal(Pointer(Str)^));
  end;
end;

function str__alloc(Size: Cardinal): PChar;
begin
  Inc(Size, SizeOf(Cardinal));
  GetMem(Result, Size);
  Cardinal(Pointer(Result)^) := Size;
  Inc(Result, SizeOf(Cardinal));
end;

function str__to32(const x:string):longint;//02oct2025, 21jun2024, 29AUG2007
var
   a:tint4;
begin
if (low__len(x)>=4) then
   begin
   a.bytes[0]:=ord(x[0+stroffset]);
   a.bytes[1]:=ord(x[1+stroffset]);
   a.bytes[2]:=ord(x[2+stroffset]);
   a.bytes[3]:=ord(x[3+stroffset]);
   result:=a.val;
   end
else result:=0;
end;

function str__from32(x:longint):string;//02oct2025, 21jun2024, 29AUG2007
var
   a:tint4;
begin
a.val:=x;
result:='####';

result[0+stroffset]:=char(a.bytes[0]);
result[1+stroffset]:=char(a.bytes[1]);
result[2+stroffset]:=char(a.bytes[2]);
result[3+stroffset]:=char(a.bytes[3]);
end;

function swapcharsb(const x:string;a,b:char):string;
begin
result:=x;
swapchars(result,a,b);
end;

procedure swapchars(var x:string;a,b:char);//20JAN2011
var
   p:longint;
begin
try
//check
if (x='') then exit;
//get
for p:=0 to (low__len(x)-1) do if (x[p+stroffset]=a) then x[p+stroffset]:=b;
except;end;
end;

function low__findchar(const x:string;c:char):longint;//27feb2021, 14SEP2007
var
   p:longint;
   cv:byte;
begin
//defaults
result:=0;//not found

try
cv:=byte(c);
//get
for p:=1 to low__len(x) do if (strbyte1(x,p)=cv) then
   begin
   result:=p;
   break;
   end;
except;end;
end;

function low__havechar(const x:string;c:char):boolean;//27feb2021, 02FEB2008
var
   p:longint;
   cv:byte;
begin
//defaults
result:=false;

try
cv:=byte(c);
//get
for p:=1 to low__len(x) do if (strbyte1(x,p)=cv) then
   begin
   result:=true;
   break;
   end;
except;end;
end;

function low__havecharb(x:string;c:char):boolean;//09mar2021
begin
result:=low__havechar(x,c);
end;

function low__findchars(const x:string;const c:array of char):longint;//03jan2025
var//0=no chars found, 1..N=at least one char found from "c" list
   p:longint;
begin
result:=0;

for p:=low(c) to high(c) do
begin
result:=low__findchar(x,c[p]);
if (result>=1) then break;
end;//p
end;

function low__havechars(const x:string;const c:array of char):boolean;//03jan2025
var//false=no chars found, true=at least one char found from "c" list
   p:longint;
begin
result:=false;

for p:=low(c) to high(c) do
begin
result:=low__havechar(x,c[p]);
if result then break;
end;//p
end;

function low__havecharsb(x:string;c:array of char):boolean;//03jan2025
begin//false=no chars found, true=at least one char found from "c" list
result:=low__havechars(x,c);
end;

function swapstrsb(const x,a,b:string):string;
begin
result:='';

try
result:=x;
swapstrs(result,a,b);
except;end;
end;

function swapstrs(var x:string;a,b:string):boolean;
label
   redo;
var
   lenb,lena,maxp,p:longint;
begin
//defaults
result:=false;

try
//init
maxp:=low__len(x);
lena:=low__len(a);
lenb:=low__len(b);
p:=0;
//get
redo:
p:=p+1;
if (p>maxp) then exit;
if (x[p-1+stroffset]=a[0+stroffset]) and (strcopy1(x,p,lena)=a) then
   begin
   x:=strcopy1(x,1,p-1)+b+strcopy1(x,p+lena,maxp);
   p:=p+lenb-1;
   maxp:=maxp-lena+lenb;
   //mark as modified
   result:=true;
   end;
//loop
goto redo;
except;end;
end;

function stripwhitespace_lt(const x:string):string;//strips leading and trailing white space
begin
result:='';

try
result:=x;
result:=stripwhitespace(result,false);
result:=stripwhitespace(result,true);
except;end;
end;

function stripwhitespace(const x:string;xstriptrailing:boolean):string;
var//Agressive mode
   p:longint;
begin
//defaults
result:='';

try
//check
if (x='') then exit;

//find
case xstriptrailing of
true:begin//trailing white space
   for p:=low__len(x) downto 1 do
   begin
   case ord(x[p-1+stroffset]) of
   0..32,160:;
   else
      begin
      result:=strcopy1(x,1,p);
      break;
      end;
   end;//case
   end;//p
   end;
else begin//leading white space
   for p:=1 to low__len(x) do
   begin
   case ord(x[p-1+stroffset]) of
   0..32,160:;
   else
      begin
      result:=strcopy1(x,p,low__len(x));
      break;
      end;
   end;//case
   end;//p
   end;
end;//case
except;end;
end;

function low__point(const x,y:longint):tpoint;//09apr2024
begin
result.x:=x;
result.y:=y;
end;

function low__hexint2(const x2:string):longint;//26dec2023

   function xval(x:byte):longint;
   begin
   case x of
   48..57: result:=x-48;
   65..70: result:=x-55;
   97..102:result:=x-87;
   else    result:=0;
   end;//case
   end;
begin
result:=(xval(strbyte1(x2,1))*16)+xval(strbyte1(x2,2));
end;

function low__nextline0(xdata,xlineout:tstr8;var xpos:longint):boolean;//07apr2025, 31mar2025, 17oct2018
begin
result:=str__nextline0(@xdata,@xlineout,xpos);
end;

function low__nextline1(const xdata:string;var xlineout:string;xdatalen:longint;var xpos:longint):boolean;//31mar2025, 20mar2025, 17oct2018
var//Super fast line reader.  Supports #13 / #10 / #13#10 / #10#13,
   //with support for last line detection WITHOUT a trailing #10/#13 or combination thereof.
   int1,p:longint;
begin
//defaults
result:=false;

try
//init
xlineout:='';
if (xpos<1) then xpos:=1;

//get
if (xdatalen>=1) and (xpos<=xdatalen) then for p:=xpos to xdatalen do if (xdata[p-1+stroffset]=#10) or (xdata[p-1+stroffset]=#13) or (p=xdatalen) then
   begin

   //get
   result:=true;//detect even blank lines
   if (p>=xpos) then//fixed, was "p>xpos" - 31mar2025
      begin
      if (p=xdatalen) and (xdata[p-1+stroffset]<>#10) and (xdata[p-1+stroffset]<>#13) then int1:=1 else int1:=0;//adjust for last line terminated by #10/#13 or without either - 18oct2018
      xlineout:=strcopy1(xdata,xpos,p-xpos+int1);
      end;

   //inc
   if      (p<xdatalen) and (xdata[p-1+stroffset]=#13) and (xdata[p+1-1+stroffset]=#10) then xpos:=p+2//2 byte return code
   else if (p<xdatalen) and (xdata[p-1+stroffset]=#10) and (xdata[p+1-1+stroffset]=#13) then xpos:=p+2//2 byte return code
   else                                                                                      xpos:=p+1;//1 byte return code

   //quit
   break;
   end;
except;end;
end;

function low__splitstr(const s:string;ssplitval:byte;var dn,dv:string):boolean;//02mar2025
var
   slen,p:longint;
begin

//defaults
result:=false;
dn:='';
dv:=s;

//get
slen:=low__len(s);
if (slen>=1) then
   begin
   for p:=1 to slen do if (byte(s[p-1+stroffset])=ssplitval) then
      begin
      dn:=strcopy1(s,1,p-1);
      dv:=strcopy1(s,p+1,slen);
      result:=true;
      break;
      end;//p
   end;

end;

function low__splitto(s:string;d:tfastvars;ssep:string):boolean;//13jan2024
label
   redo;
var
   vcount,p:longint;
begin
//defaults
result:=false;

try
if (d<>nil) then d.clear else exit;
//init
if (ssep='') then ssep:='=';
s:=s+ssep;
vcount:=0;
//get
redo:
if (low__len(s)>=2) then for p:=1 to low__len(s) do if (s[p-1+stroffset]=ssep) then
   begin
   //get
   d.s['v'+intstr32(vcount)]:=strcopy1(s,1,p-1);
   //inc
   inc(vcount);
   strdel1(s,1,p);
   result:=true;//we have read at least one value
   goto redo;
   end;//p
except;end;
end;

function low__ref32u(const x:string):longint;//1..32 - 25dec2023, 04feb2023
var//Fast: 180% faster
   v:byte;
   p,xlen:longint;
begin
//default
result:=0;

try
//init
xlen:=low__len(x);
if (xlen<=0) then exit;
if (xlen>high(p4INT32)) then xlen:=high(p4INT32);
//get
for p:=0 to (xlen-1) do
begin
//2-stage - prevent math error
v:=byte(x[p+stroffset]);
if (v>=97) and (v<=122) then dec(v,32);
//inc
result:=result+p4INT32[p+1]*v;//fixed - 25dec2023
end;//p
//check
if (result=0) then result:=1;//never zero - 04feb2023
except;end;
end;

function low__ref256(const x:string):comp;//01may2025: never 0 for valid input, 28dec2023
var//Fast: 300% faster
   p,xlen:longint;
begin
//default
result:=0;

try
//init
xlen:=low__len(x);
if (xlen<=0) then exit;
if (xlen>high(p8CMP256)) then xlen:=high(p8CMP256);
//get
for p:=0 to (xlen-1) do result:=result+p8CMP256[p+1]*byte(x[p+stroffset]);//fixed - 25dec2023
//check
if (result=0) then result:=1;//never zero - 01may2024
except;end;
end;

function low__ref256U(const x:string):comp;//01may2025: never 0 for valid input, 28dec2023
var//Fast: 300% faster
   v:byte;
   p,xlen:longint;
begin
//default
result:=0;

try
//init
xlen:=low__len(x);
if (xlen<=0) then exit;
if (xlen>high(p8CMP256)) then xlen:=high(p8CMP256);
//get
for p:=0 to (xlen-1) do
begin
//lowercase
v:=byte(x[p+stroffset]);
if (v>=97) and (v<=122) then dec(v,32);
//add
result:=result+p8CMP256[p+1]*v;//fixed - 25dec2023
end;//p
//check
if (result=0) then result:=1;//never zero - 01may2024
except;end;
end;

function low__setstr(var xdata:string;xnewvalue:string):boolean;
begin
result:=false;

try
if (xnewvalue<>xdata) then
   begin
   xdata:=xnewvalue;
   result:=true;
   end;
except;end;
end;

function low__setcmp(var xdata:comp;xnewvalue:comp):boolean;//10mar2021
begin
if (xnewvalue<>xdata) then
   begin
   result:=true;
   xdata:=xnewvalue;
   end
else result:=false;
end;

function low__setint(var xdata:longint;xnewvalue:longint):boolean;
begin
if (xnewvalue<>xdata) then
   begin
   result:=true;
   xdata:=xnewvalue;
   end
else result:=false;
end;

function low__setdbl(var xdata:double;xnewvalue:double):boolean;
begin
if (xnewvalue<>xdata) then
   begin
   result:=true;
   xdata:=xnewvalue;
   end
else result:=false;
end;

function low__setbyt(var xdata:byte;xnewvalue:byte):boolean;//01feb2025
begin
if (xnewvalue<>xdata) then
   begin
   result:=true;
   xdata:=xnewvalue;
   end
else result:=false;
end;

function low__setbol(var xdata:boolean;xnewvalue:boolean):boolean;
begin
if (xnewvalue<>xdata) then
   begin
   xdata:=xnewvalue;
   result:=true;
   end
else result:=false;
end;

function low__rword(x:word):word;
var
   b,a:twrd2;
begin
a.val:=x;
b.bytes[0]:=a.bytes[1];
b.bytes[1]:=a.bytes[0];
result:=b.val;
end;

procedure low__divmod(dividend:longint;divisor:word;var result,remainder:word);
asm
PUSH    EBX
MOV     EBX,EDX
MOV     EDX,EAX
SHR     EDX,16
DIV     BX
MOV     EBX,Remainder
MOV     [ECX],AX
MOV     [EBX],DX
POP     EBX
end;

function low__aorb(a,b:longint;xuseb:boolean):longint;
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbD64(a,b:double;xuseb:boolean):double;//04sep2025
begin
if xuseb then result:=b else result:=a;
end;

function low__aorb32(a,b:longint;xuseb:boolean):longint;//27aug2024
begin
if xuseb then result:=b else result:=a;
end;

function low__aorb64(a,b:comp;xuseb:boolean):comp;//27aug2024
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbrect(a,b:twinrect;xuseb:boolean):twinrect;//25nov2023
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbbyte(a,b:byte;xuseb:boolean):byte;//11feb2023
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbcur(a,b:currency;xuseb:boolean):currency;//07oct2022
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbcomp(a,b:comp;xuseb:boolean):comp;//19feb2024
begin
if xuseb then result:=b else result:=a;
end;

procedure low__toggle(var x:boolean);
begin
x:=not x;
end;

function low__yes(x:boolean):string;//16sep2022
begin
result:=low__aorbstr('No','Yes',x);
end;

function low__enabled(x:boolean):string;//29apr2024
begin
result:=low__aorbstr('Disabled','Enabled',x);
end;

function low__aorbstr8(a,b:tstr8;xuseb:boolean):tstr8;//06dec2023
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbvars8(a,b:tvars8;xuseb:boolean):tvars8;//06dec2023
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbstr(a,b:string;xuseb:boolean):string;
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbobj(a,b:tobject;xuseb:boolean):tobject;//08may2025
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbchar(a,b:char;xuseb:boolean):char;
begin
if xuseb then result:=b else result:=a;
end;

function low__aorbbol(a,b:boolean;xuseb:boolean):boolean;
begin
if xuseb then result:=b else result:=a;
end;

function low__insd64(x:double;y:boolean):double;//06jul2025
begin
if y then result:=x else result:=0;
end;

function low__insint(x:longint;y:boolean):longint;
begin
if y then result:=x else result:=0;
end;

function insbol(x,y:boolean):boolean;//05jul2025
begin
if y then result:=x else result:=false;
end;

function insint(x:longint;y:boolean):longint;
begin
if y then result:=x else result:=0;
end;

function insint32(x:longint;y:boolean):longint;
begin
if y then result:=x else result:=0;
end;

function insint64(x:comp;y:boolean):comp;
begin
if y then result:=x else result:=0;
end;

function low__inscmp(x:comp;y:boolean):comp;
begin
if y then result:=x else result:=0;
end;

function frcmin64(x,min:comp):comp;//24jan2016
begin
if (x<min) then result:=min else result:=x;
end;

function frcmax64(x,max:comp):comp;//24jan2016
begin
if (x>max) then result:=max else result:=x;
end;

function frcrange64(x,min,max:comp):comp;//24jan2016
begin
result:=x;
if (result<min) then result:=min;
if (result>max) then result:=max;
end;

function frcrange642(var x:comp;xmin,xmax:comp):boolean;//20dec2023
begin
result:=true;//pass-thru
if (x<xmin) then x:=xmin;
if (x>xmax) then x:=xmax;
end;

function smallest64(a,b:comp):comp;
begin
if (a>b) then result:=b else result:=a;
end;

function largest64(a,b:comp):comp;
begin
if (a<b) then result:=b else result:=a;
end;

function strint32(x:string):longint;//01nov2024
begin
result:=restrict32(int__fromstr(x));
end;

function intstr32(x:longint):string;//01nov2024
begin
result:=int__tostr(x);
end;

function sign32(xpositive:boolean):longint;//29jul2025
begin
if xpositive then result:=1 else result:=-1;
end;

procedure inc32(var x:longint;xby:longint);
begin
x:=x+xby;
end;

procedure dec32(var x:longint;xby:longint);
begin
x:=x-xby;
end;

procedure inc64(var x:comp;xby:comp);
begin
x:=x+xby;
end;

procedure dec64(var x:comp;xby:comp);
begin
x:=x-xby;
end;

procedure inc132(var x:longint);
begin
if (x<max32) then inc(x);
end;

procedure dec132(var x:longint);
begin
if (x>min32) then dec(x);
end;

procedure inc164(var x:comp);
begin
if (x<max64) then x:=x+1;
end;

procedure dec164(var x:comp);
begin
if (x>min64) then x:=x-1;
end;

function strint64(x:string):comp;//01nov2024, 05jun2021, 28jan2017
begin
result:=int__fromstr(x);
end;

function intstr64(x:comp):string;//01nov2024, 30jan2017
begin
result:=int__tostr(x);
end;

function int__tostr(x:extended):string;
begin
result:=float__tostr3(x,ssdot,false);
end;

function int__fromstr(x:string):comp;
begin
result:=float__fromstr3(x,ssdot,false);
end;

function int__byteX(xindex,x:longint):byte;
begin
//range
if (xindex<0) then xindex:=0 else if (xindex>3) then xindex:=3;
//get
result:=tint4(x).bytes[xindex];
end;

function int__byte0(x:longint):byte;
begin
result:=int__byteX(0,x);
end;

function int__byte1(x:longint):byte;
begin
result:=int__byteX(1,x);
end;

function int__byte2(x:longint):byte;
begin
result:=int__byteX(2,x);
end;

function int__byte3(x:longint):byte;
begin
result:=int__byteX(3,x);
end;

function int__round4(x:longint):longint;//round X up to nearest 4 - 26apr2025
begin
result:=x;
if (result<>((result div 4)*4)) then result:=((result div 4)+1)*4;
end;

function float__tostr_divby(xvalue,xdivby:extended):string;//12dec2024
var//performs a nice division, e.g. 500/1000 = 0.5, and not 0.999999 when values passed in directly without first being converted to a double
   v,v2:double;
begin
v:=xvalue;
v2:=xdivby;
if (v2=0) then v2:=1;
v:=v/v2;
result:=float__tostr3(v,ssdot,true);
end;

function float__tostr(x:extended):string;//31oct2024: system independent
begin
result:=float__tostr3(x,ssdot,true);
end;

function float__tostr2(x:extended;xsep:byte):string;//31oct2024: system independent
begin
result:=float__tostr3(x,xsep,true);
end;

function float__tostr3(x:extended;xsep:byte;xallowdecimal:boolean):string;//31oct2024: system independent
var//Speed   : ~1.07 million cycles/sec vs "floattostrf" ~2.66 million cycles/sec on an icore 5
   //Accuracy: 18 digit combined left and right of decimal point
   //Range   : -999999999999999999.0 to 999999999999999999.0 (min64..max64)
   //Format  : System independent decimal point/formatting
   //Note    : Replaces "floattostrf()"
   sv:comp;
   slen,rlen,rlastnonzero,rseplen,alen,blen:longint;
   rok,sforce0:boolean;

   procedure radd(x:char);
   begin

   if not rok then
      begin
      result:='000000000000000000000';//21 -> space for 18 digits + "-" symbol + "." decimal point + plus extra space for safety
      rok:=true;
      end;

   inc(rlen);
   result[rlen-1+stroffset]:=x;
   if sforce0 and (x<>'0') then rlastnonzero:=rlen;

   end;

   procedure xscan(xmin:comp);
   var
      p:longint;
   begin
   if (sv>=xmin) then
      begin

      for p:=9 downto 1 do
      begin

      if (sv>=(p*xmin)) then
         begin
         sv:=sv-(p*xmin);
         inc(slen);
         radd(char(48+p));
         break;
         end
      else
         begin
         if (p<=1) and ((slen>=1) or sforce0) then
            begin
            inc(slen);
            inc(rlen);
            end;
         end;

      end;//p

      end
   else if (slen>=1) or sforce0 then
      begin
      inc(slen);
      inc(rlen);
      end;
   end;

begin

//defaults
result       :='0';
rok          :=false;
rlen         :=0;
alen         :=0;
blen         :=0;
rlastnonzero :=0;
rseplen      :=0;

//check
if (x=0) then exit;

//init
if (x<0) then
   begin
   x:=-x;
   radd('-');
   end;

//get
//.whole number -> left of decimal point, stored in "astr" -> 1-18 digits
sv     :=int(x);
slen   :=0;
sforce0:=false;

xscan(100000000000000000.0);
xscan(10000000000000000.0);
xscan(1000000000000000.0);
xscan(100000000000000.0);
xscan(10000000000000.0);
xscan(1000000000000.0);
xscan(100000000000.0);
xscan(10000000000.0);
xscan(1000000000.0);
xscan(100000000.0);
xscan(10000000.0);
xscan(1000000.0);
xscan(100000.0);
xscan(10000.0);
xscan(1000.0);
xscan(100.0);
xscan(10.0);
xscan(1.0);
alen:=slen;

//.fraction -> right of decimal point, stored in "bstr" -> 1-18 digits
slen    :=0;
sforce0 :=true;
if xallowdecimal then blen:=18-alen;

case blen of
 0:sv:=0;
 1:sv:=frac(x)*10;
 2:sv:=frac(x)*100;
 3:sv:=frac(x)*1000;
 4:sv:=frac(x)*10000;
 5:sv:=frac(x)*100000;
 6:sv:=frac(x)*1000000;
 7:sv:=frac(x)*10000000;
 8:sv:=frac(x)*100000000;
 9:sv:=frac(x)*mult64(100000000,10);
10:sv:=frac(x)*mult64(100000000,100);
11:sv:=frac(x)*mult64(100000000,1000);
12:sv:=frac(x)*mult64(100000000,10000);
13:sv:=frac(x)*mult64(100000000,100000);
14:sv:=frac(x)*mult64(100000000,1000000);
15:sv:=frac(x)*mult64(100000000,10000000);
16:sv:=frac(x)*mult64(100000000,100000000);
17:sv:=frac(x)*mult64(100000000,1000000000);
18:sv:=frac(x)*mult64(mult64(100000000,1000000000),10);
else sv:=0;
end;

//.insert decimal point
if (blen>=1) then
   begin

   if (alen<=0) then radd('0');
   radd(char(xsep));
   rseplen      :=rlen;
   rlastnonzero :=rlen;

   if (blen>=18) then xscan(100000000000000000.0);
   if (blen>=17) then xscan(10000000000000000.0);
   if (blen>=16) then xscan(1000000000000000.0);
   if (blen>=15) then xscan(100000000000000.0);
   if (blen>=14) then xscan(10000000000000.0);
   if (blen>=13) then xscan(1000000000000.0);
   if (blen>=12) then xscan(100000000000.0);
   if (blen>=11) then xscan(10000000000.0);
   if (blen>=10) then xscan(1000000000.0);
   if (blen>=9)  then xscan(100000000.0);
   if (blen>=8)  then xscan(10000000.0);
   if (blen>=7)  then xscan(1000000.0);
   if (blen>=6)  then xscan(100000.0);
   if (blen>=5)  then xscan(10000.0);
   if (blen>=4)  then xscan(1000.0);
   if (blen>=3)  then xscan(100.0);
   if (blen>=2)  then xscan(10.0);
   if (blen>=1)  then xscan(1.0);

   end;

//set -> remove trailing zeros on right of decimal point
if (rlen>=1) then
   begin

   if (blen>=1) then
      begin

      if (rseplen=rlastnonzero) then result:=strcopy1(result,1,rseplen-1) else result:=strcopy1(result,1,rlastnonzero);

      end
   else result:=strcopy1(result,1,rlen);

   end
else result:='0';//should never be required -> but here just in case

end;

function float__fromstr(x:string):extended;//31oct2024: system independent
begin
result:=float__fromstr3(x,ssDot,true);
end;

function float__fromstr2(x:string;xsep:byte):extended;//31oct2024: system independent
begin
result:=float__fromstr3(x,xsep,true);
end;

function float__fromstr3(x:string;xsep:byte;xallowdecimal:boolean):extended;//01nov2024, 31oct2024: system independent
var//Speed   : ~3.09 million cycles/sec vs "strtofloat" ~9.09 million cycles/sec on an icore 5
   //Accuracy: 18 digit combined left and right of decimal point
   //Range   : -999999999999999999.0 to 999999999999999999.0 (min64..max64)
   //Format  : System independent decimal point/formatting
   //Note    : Replaces "strtofloat()"
   dsep:char;
   a,b:string;
   rlen,p:longint;
   v:byte;
   vval:comp;
   vval2:extended;
   aok,dneg:boolean;
begin
//defaults
result:=0;

//check
if (x='') then exit;

//init
dsep:=char(xsep);
a   :='';
b   :='';
rlen:=0;
dneg:=false;

//split
aok:=false;
for p:=1 to low__len(x) do if (x[p-1+stroffset]=dsep) then
   begin
   aok:=true;
   a:=strcopy1(x,1,p-1);
   if xallowdecimal then b:=strcopy1(x,p+1,low__len(x));
   break;
   end;

if not aok then a:=x;

//get
//.a - left of decimal point
if (a<>'') then
   begin
   vval:=1;

   for p:=low__len(a) downto 1 do
   begin
   v:=ord(a[p-1+stroffset]);
   if (v>=48) and (v<=57) then
      begin
      inc(rlen);
      if (rlen<=18) then//allows for negative sign to still be detected for extremely long numbers, numbers that exceed 18 digits - 01nov2024
         begin
         result:=result+((v-48)*vval);
         vval:=vval*10;
         end;
      end
   else if (v=ssDash) and (not dneg) then dneg:=true;
   end;//p
   end;

//.b - right of decimal point
if (b<>'') then
   begin
   vval2:=0.1;

   for p:=1 to low__len(b) do
   begin
   v:=ord(b[p-1+stroffset]);
   if (v>=48) and (v<=57) then
      begin
      inc(rlen);
      if (rlen>18) then break;
      result:=result+((v-48)*vval2);
      vval2:=vval2*0.1;
      end;
   end;//p
   end;

//.negative
if dneg then result:=-result;
end;

function strdec(x:string;y:byte;xcomma:boolean):string;
var
   a,b:string;
   aLen,p:longint;
begin
result:='';

try
//range
if (y>10) then y:=10;
//init
a:=x;
alen:=low__len(a);
b:='';
//get
if (alen>=1) then
   begin
   for p:=0 to (alen-1) do if (a[p+stroffset]='.') then
      begin
      b:=strcopy0(a,p+1,alen);
      a:=strcopy0(a,0,p);
      break;
      end;//p
   end;
//xcomma - thousands
if xcomma then a:=curcomma(strtofloatex(a));
//set
if (y<=0) then result:=a else result:=a+'.'+strcopy0b(b+'0000000000',0,y);
except;end;
end;

function curdec(x:currency;y:byte;xcomma:boolean):string;
begin
result:=strdec(floattostrex2(x),y,xcomma);
end;

function curstrex(x:currency;sep:string):string;//01aug2017, 07SEP2007
var
   xlen,i,p:longint;
   decbit,z2,Z,Y:String;
begin
//defaults
result:='0';

try
decbit:='';
//init
z2:='';
if (x<0) then
   begin
   x:=-x;
   z2:='-';
   end;
//.dec point fix - 01aug2017
y:=floattostrex2(x);
if (y<>'') then for p:=0 to (low__len(y)-1) do if (y[p+stroffset]='.') then
   begin
   decbit:=strcopy0(y,p,low__len(y));
   y:=strcopy0(y,0,p);
   break;
   end;
//get
z:='';
xlen:=low__len(y);
i:=0;
if (xlen>=1) then
   begin
   for p:=(xlen-1) downto 0 do
   begin
   inc(i);
   if (i>=3) and (p>0) then
      begin
      z:=sep+strcopy0(y,p,3)+z;
      i:=0;
      end;
   end;//p
   end;
if (i<>0) then z:=strcopy0(y,0,i)+z;
//return result
result:=z2+z+decbit;
except;end;
end;

function curcomma(x:currency):string;{same as "Thousands" but for "double"}
begin
result:=curstrex(x,',');
end;

function low__remcharb(x:string;c:char):string;//26apr2019
begin
result:=x;
low__remchar(result,c);
end;

function low__remchar(var x:string;c:char):boolean;//26apr2019
var
   xlen,i,p:longint;
begin
//defaults
result:=false;

try
xlen:=low__len(x);
i:=0;
//get
if (xlen>=1) then
   begin
   for p:=0 to (xlen-1) do
   begin
   if (x[p+stroffset]=c) then inc(i)
   else if (i<>0) then x[p-i+stroffset]:=x[p+stroffset];
   end;//p
   end;
//shrink
if (i<>0) then low__setlen(x,xlen-i);
except;end;
end;

function low__rembinary(var x:string):boolean;//07apr2020
var
   xlen,i,p:longint;
begin
//defaults
result:=false;

try
xlen:=low__len(x);
i:=0;
//get
if (xlen>=1) then
   begin
   for p:=0 to (xlen-1) do
   begin
   if (x[p+stroffset]<#32) then inc(i)
   else if (i<>0) then x[p-i+stroffset]:=x[p+stroffset];
   end;//p
   end;
//shrink
if (i<>0) then low__setlen(x,xlen-i);
except;end;
end;

function low__digpad20(v:comp;s:longint):string;//1 -> 01
const
   p='00000000000000000000';//20
begin
result:='';

try
v:=restrict64(v);
result:=floattostrex2(v);
result:=strcopy1b(p,1,frcmin32(s-low__len(result),0))+result;
except;end;
end;

function low__digpad11(v,s:longint):string;//1 -> 01
const
   p='00000000000';//11
begin
result:='';

try
result:=intstr32(v);
result:=strcopy1b(p,1,frcmin32(s-low__len(result),0))+result;
except;end;
end;

procedure low__int3toRGB(x:longint;var r,g,b:byte);
begin
//range
x:=frcrange32(x,0,16777215);
//get
//.b
b:=byte(frcrange32(x div (256*256),0,255));
dec(x,b*256*256);
//.g
g:=byte(frcrange32(x div 256,0,255));
dec(x,g*256);
//.r
r:=byte(frcrange32(x,0,255));
end;

function low__intr(x:longint):longint;//reverse longint
var
   s,d:tint4;
begin
s.val:=x;
d.bytes[0]:=s.bytes[3];//swap round
d.bytes[1]:=s.bytes[2];
d.bytes[2]:=s.bytes[1];
d.bytes[3]:=s.bytes[0];
result:=d.val;
end;

function low__wrdr(x:word):word;//reverse word
var
   s,d:twrd2;
begin
s.val:=x;
d.bytes[0]:=s.bytes[1];//swap round
d.bytes[1]:=s.bytes[0];
result:=d.val;
end;

function low__posn(x:longint):longint;
begin
result:=x;
if (result<0) then result:=-result;
end;

function low__sign(x:longint):longint;//returns 0, 1 or -1 - 22jul2024
begin
if (x=0)      then result:=0
else if (x>0) then result:=1
else               result:=-1;
end;

procedure low__iroll(var x:longint;by:longint);//continuous incrementer with safe auto. reset
begin//if (x>capacity) reset to 0
try;x:=x+by;except;x:=0;end;
try;if (x<0) then x:=0;except;end;//required when compiler "range checking" is turned OFF - 25jun2022
end;

function low__irollone(var x:longint):longint;//14jul2025, 06jan2025
begin

if (x<max32) then inc(x) else x:=0;

result:=x;

end;

function low__irollone64(var x:comp):comp;//25jul2025
begin

if (x<max64) then x:=add64(x,1) else x:=0;

result:=x;

end;

procedure low__croll(var x:currency;by:currency);//continuous incrementer with safe auto. reset
begin//if (x>capacity) reset to 0
try;x:=x+by;except;x:=0;end;
try;if (x<0) then x:=0;except;end;//required when compiler "range checking" is turned OFF - 25jun2022
end;

procedure low__roll64(var x:comp;by:comp);//continuous incrementer with safe auto. reset to user specified value - 05feb2016
begin//if (x>capacity) reset to 0
try
x:=x+by;
//.don't allow "x" to exceed upper limit of whole number range
if (x>max64) then x:=0
else if (x<0) then x:=0;//06sep2016
except;x:=0;end;
try;if (x<0) then x:=0;except;end;//required when compiler "range checking" is turned OFF - 25jun2022
end;

function low__nrw(x,y,r:longint):boolean;//number within range
begin
result:=false;try;result:=(x>=(y-r)) and (x<=(y+r));except;end;
end;

function low__setobj(var xdata:tobject;xnewvalue:tobject):boolean;//28jun2024, 15mar2021
begin
if (xnewvalue<>xdata) then
   begin
   xdata:=xnewvalue;
   result:=true;
   end
else result:=false;
end;

function low__iseven(x:longint):boolean;
begin//no error handling for maximum speed - 28mar2020
result:=(x=((x div 2)*2));
end;

function low__even(x:longint):boolean;
begin//no error handling for maximum speed - 28mar2020
result:=(x=((x div 2)*2));
end;

function frcrange2(var x:longint;xmin,xmax:longint):boolean;//20dec2023, 29apr2020
begin
result:=true;//pass-thru
if (x<xmin) then x:=xmin;
if (x>xmax) then x:=xmax;
end;

function smallest32(a,b:longint):longint;
begin
result:=a;
if (result>b) then result:=b;
end;

function largest32(a,b:longint):longint;
begin
result:=a;
if (result<b) then result:=b;
end;

function smallestD64(a,b:double):double;//21jul2025
begin
result:=a;
if (result>b) then result:=b;
end;

function largestD64(a,b:double):double;
begin
result:=a;
if (result<b) then result:=b;
end;

function largestarea32(s,d:twinrect):twinrect;//25dec2024
begin
result:=s;

if (d.left<result.left)     then result.left  :=d.left;
if (d.right>result.right)   then result.right :=d.right;
if (d.top<result.top)       then result.top   :=d.top;
if (d.bottom>result.bottom) then result.bottom:=d.bottom;
end;

function cfrcrange32(x,min,max:currency):currency;//date: 02-APR-2004
begin
result:=x;
if (result<min) then result:=min;
if (result>max) then result:=max;
end;

function frcmin32(x,min:longint):longint;
begin
if (x<min) then result:=min else result:=x;
end;

function frcmax32(x,max:longint):longint;
begin
if (x>max) then result:=max else result:=x;
end;

function frcrange32(x,min,max:longint):longint;
begin
result:=x;
if (result<min) then result:=min;
if (result>max) then result:=max;
end;

function frcminD64(x,min:double):double;//05jul2025
begin
if (x<min) then result:=min else result:=x;
end;

function frcmaxD64(x,max:double):double;
begin
if (x>max) then result:=max else result:=x;
end;

function frcrangeD64(x,min,max:double):double;
begin
result:=x;
if (result<min) then result:=min;
if (result>max) then result:=max;
end;

function floattostrex2(x:extended):string;//19DEC2007
begin
result:=floattostrex(x,18);
end;

function floattostrex(x:extended;dig:byte):string;//07NOV20210
var//dig: 0=integer part only, 1-18=include partial content if present
   p:longint;
   a,b,c:string;
begin
//defaults
result:='0';

//get
//was: a:=floattostrf(x,ffFixed,18,18);
a:=float__tostr(x);//31oct2024
b:='';
c:='';
if (a<>'') then
   begin
   for p:=0 to (low__len(a)-1) do if (a[p+stroffset]='.') then
   begin
   if (dig>=1) then b:=strcopy0(a,p+1,dig);
   a:=strcopy0(a,0,p);
   break;
   end;
   end;
//scan
if (b<>'') then
   begin
   for p:=(low__len(b)-1) downto 0 do if (b[p+stroffset]<>'0') then
   begin
   c:=strcopy0(b,0,p+1);//strip off excess zeros - 07NOV2010
   break;
   end;
   end;
//set
result:=a+insstr('.'+c,c<>'');
end;

function strtofloatex(x:string):extended;//triggers less errors (x=nil now covered)
begin
//was: result:=0;try;if (x<>'') then result:=strtofloat(x);except;end;
result:=float__fromstr(x);//31oct2024
end;

function restrict64(x:comp):comp;//24jan2016
begin
result:=x;

try
if (result>max64) then result:=max64;
if (result<min64) then result:=min64;
except;end;
end;

function restrict32(x:comp):longint;//limit32 - 24jul2025, 24jan2016
begin
if (x>max32) then x:=max32;
if (x<min32) then x:=min32;
result:=round(x);
end;

function fr64(x,xmin,xmax:extended):extended;
begin
if (x<xmin) then x:=xmin else if (x>xmax) then x:=xmax;
result:=x;
end;

function f64(x:extended):string;//25jan2025
begin
result:=floattostrex2(x);
end;

function f642(x:extended;xdigcount:longint):string;//25jan2025
begin
result:=floattostrex(x,frcrange32(xdigcount,0,20));
end;

function k64(x:comp):string;//converts 64bit number into a string with commas -> handles full 64bit whole number range of min64..max64 - 24jan2016
begin
result:=k642(x,true);
end;

function k642(x:comp;xsep:boolean):string;//handles full 64bit whole number range of min64..max64 - 24jan2016
const
   sep=',';
var
   i,xlen,p:longint;
   z2,z,y:string;
begin
//defaults
result:='0';

try
//range
x:=restrict64(x);
//get
z2:='';
if (x<0) then
   begin
   x:=-x;
   z2:='-';
   end;
y:=floattostrex2(x);
z:='';
xlen:=low__len(y);
i:=0;
if (xlen>=1) then
   begin
   for p:=(xlen-1) downto 0 do
   begin
   inc(i);
   if (i>=3) and (p>0) then
      begin
      case xsep of//10mar2021
      true:z:=sep+strcopy0(y,p,3)+z;
      else z:=strcopy0(y,p,3)+z;
      end;
      i:=0;
      end;
   end;//p
   end;
if (i<>0) then z:=strcopy0(y,0,i)+z;
//set
result:=z2+z;
except;end;
end;

function mult64(xval,xval2:comp):comp;//multiply
begin
result:=xval;
try;result:=result*xval2;except;end;
end;

function add64(xval,xval2:comp):comp;//add
begin
result:=xval;
try;result:=result+xval2;except;end;
end;

function sub64(xval,xval2:comp):comp;//subtract
begin
result:=xval;
try;result:=result-xval2;except;end;
end;

function div64(xval,xdivby:comp):comp;//28dec2021, this proc performs proper "comp division" -> fixes Delphi's "comp" division error -> which raises POINTER EXCEPTION and MEMORY ERRORS when used at speed and repeatedly - 13jul2021, 19apr2021
label
   vsmall,x1b,x100m,x10m,x1m,x100K,x10K,x1K,x100,x10,x1;
var
   xminus:boolean;
   vmax,v,xoutval:comp;
begin
//defaults
result:=0;

try
xoutval:=0;
//zero value - 13jul2021
if (xval=0) then
   begin
   result:=0;
   exit;
   end;
//.divide by zero - 28dec2021
if (xdivby=0) then
   begin
   result:=0;
   exit;
   end;
//init
xminus:=(xval<0);
if xminus then xval:=-xval;
vmax:=mult64(100000000,1000);
//decide
if (xdivby>=vmax) then goto vsmall;

//1b
v:=xdivby*1000000000;
x1b:
if (v<=xval) then
   begin
   xoutval:=xoutval+1000000000;
   xval:=xval-v;
   goto x1b;
   end;

//100m
v:=xdivby*100000000;
x100m:
if (v<=xval) then
   begin
   xoutval:=xoutval+100000000;
   xval:=xval-v;
   goto x100m;
   end;
//10m
v:=xdivby*10000000;
x10m:
if (v<=xval) then
   begin
   xoutval:=xoutval+10000000;
   xval:=xval-v;
   goto x10m;
   end;
//1m
v:=xdivby*1000000;
x1m:
if (v<=xval) then
   begin
   xoutval:=xoutval+1000000;
   xval:=xval-v;
   goto x1m;
   end;
//100K
v:=xdivby*100000;
x100K:
if (v<=xval) then
   begin
   xoutval:=xoutval+100000;
   xval:=xval-v;
   goto x100K;
   end;
//10K
v:=xdivby*10000;
x10K:
if (v<=xval) then
   begin
   xoutval:=xoutval+10000;
   xval:=xval-v;
   goto x10K;
   end;
//1K
v:=xdivby*1000;
x1K:
if (v<=xval) then
   begin
   xoutval:=xoutval+1000;
   xval:=xval-v;
   goto x1K;
   end;
//100
v:=xdivby*100;
x100:
if (v<=xval) then
   begin
   xoutval:=xoutval+100;
   xval:=xval-v;
   goto x100;
   end;
//10
vsmall:
v:=xdivby*10;
x10:
if (v<=xval) then
   begin
   xoutval:=xoutval+10;
   xval:=xval-v;
   goto x10;
   end;
//1
v:=xdivby;
x1:
if (v<=xval) then
   begin
   xoutval:=xoutval+1;
   xval:=xval-v;
   goto x1;
   end;

//set
if xminus then result:=-xoutval else result:=xoutval;
except;end;
end;

function add32(xval,xval2:comp):longint;//01sep2025
begin
result:=restrict32(add64(xval,xval2));
end;

function sub32(xval,xval2:comp):longint;//30sep2022, subtract
begin
result:=restrict32(sub64(xval,xval2));
end;

function div32(xval,xdivby:comp):longint;//proper "comp division" - 19apr2021
var
   v:comp;
begin
result:=0;
v:=div64(xval,xdivby);
if (v<min32) then v:=min32 else if (v>max32) then v:=max32;
result:=round(v);
end;

function pert32(xval,xlimit:comp):longint;
begin
result:=frcrange32(div32(mult64(xval,100),xlimit),0,100);
end;

function strbol(x:string):boolean;//27aug2024, 02aug2024
begin
result:=(x<>'') and (strint(x)<>0);
end;

function bolstr(x:boolean):string;
begin
if x then result:='1' else result:='0';
end;

function strint(x:string):longint;//skip over pluses "+" - 22jan2022, skip over commas - 05jun2021, date: 16aug2020, 25mar2016 v1.00.50 / 10DEC2009, v1.00.045
var //Similar speed to "strtoint" - no erros are produced though
    //Fixed "integer out of range" error, for data sets that fall outside of range
   n,xlen,z,y:longint;
   tmp:currency;
begin
//defaults
result:=0;

try
tmp:=0;
if (x='') then exit;
//init
xlen:=low__len(x);
n:=1;
//get
z:=1;
while true do
begin
y:=byte(x[z-1+stroffset]);
if (y=45) then n:=-1
else if (y=43) then
   begin
   //do nothing as "+" does nothing - 22jan2022
   end
else if (y=ssComma) then//05jun2021
   begin
   //nil
   end
else
    begin
    if (y<48) or (y>57) then break;
    tmp:=(tmp*10)+y-48;
    end;
inc(z);
if (z>xlen) then break;
//.range limit => prevent error "EInvalidOP - Invalid floating point operation" - 25mar2016
if (tmp>max32) then
   begin
   tmp:=max32;
   break;
   end;
end;//loop
//n
tmp:=cfrcrange32(tmp*n,min32,max32);
result:=round(tmp);
except;end;
end;

function strlow(const x:string):string;//make string lowercase - 26apr2025
var
   p:longint;
   v:byte;
begin
//defaults
result:='';

try
result:=x;
for p:=1 to low__len(result) do
   begin
   v:=byte(result[p-1+stroffset]);
   if (v>=uuA) and (v<=uuZ) then result[p-1+stroffset]:=char(v+vvUppertolower);
   end;
except;end;
end;

function strup(const x:string):string;//make string uppercase - 26apr2025
var
   p:longint;
   v:byte;
begin
//defaults
result:='';

try
result:=x;
for p:=1 to low__len(result) do
   begin
   v:=byte(result[p-1+stroffset]);
   if (v>=llA) and (v<=llZ) then result[p-1+stroffset]:=char(v-vvUppertolower);
   end;
except;end;
end;

function strmatch(const a,b:string):boolean;//01may2025, 26apr2025
begin
result:=strmatch2(a,b,false);
end;

function strmatch2(const a,b:string;xcasesensitive:boolean):boolean;//01may2025, 26apr2025
var
   av,bv,p,alen,blen:longint;
begin
//defaults
result:=false;
alen  :=low__len(a);
blen  :=low__len(b);

//check
if (alen<>blen) then exit;

//get
if xcasesensitive then
   begin
   for p:=1 to alen do if (a[p-1+stroffset]<>b[p-1+stroffset]) then exit;
   end
else
   begin

   for p:=1 to alen do
   begin
   av:=byte(a[p-1+stroffset]);
   bv:=byte(b[p-1+stroffset]);

   if (av<>bv) then
      begin
      case av of
      uuA..uuZ:if ((av+32)<>bv) then exit;
      llA..llZ:if ((av-32)<>bv) then exit;
      else     exit;
      end;//case
      end;

   end;//p

   end;

//match
result:=true;
end;

function strmatch32(const a,b:string):longint;//26apr2025: replaces "comparestr"
var
   av,bv,p,alen,blen,plen:longint;
begin
//defaults
result:=0;
alen  :=low__len(a);
blen  :=low__len(b);

//check
plen  :=alen;
if (blen>plen) then plen:=blen;

//get
for p:=1 to plen do
begin
if (p>alen) then
   begin
   result:=p-blen-1;
   break;
   end
else if (p>blen) then
   begin
   result:=alen-p+1;
   break;
   end
else
   begin
   av:=byte(a[p-1+stroffset]);
   bv:=byte(b[p-1+stroffset]);

   if (av<>bv) then
      begin
      result:=av-bv;
      break;
      end;
   end;
end;//p

end;

function low__param(x:longint):string;//01mar2024
begin
result:='';
try
x:=frcmin32(x,0);
//impose a definite limit
if (x<=255) then result:=paramstr(x);
except;end;
end;

function strcopy0(const x:string;xpos,xlen:longint):string;//0based always -> forward compatible with D10 - 02may2020
begin
result:='';

try
if (xlen<1) then exit;
if (xpos<0) then xpos:=0;
result:=copy(x,xpos+stroffset,xlen);
except;end;
end;

function strcopy0b(x:string;xpos,xlen:longint):string;//0based always -> forward compatible with D10 - 02may2020
begin
result:='';

try
if (xlen<1) then exit;
if (xpos<0) then xpos:=0;
result:=copy(x,xpos+stroffset,xlen);
except;end;
end;

function strcopy1(const x:string;xpos,xlen:longint):string;//1based always -> backward compatible with D3 - 02may2020
begin
result:='';

try
if (xlen<1) then exit;
if (xpos<1) then xpos:=1;
result:=copy(x,xpos-1+stroffset,xlen);
except;end;
end;

function strcopy1b(x:string;xpos,xlen:longint):string;//1based always -> backward compatible with D3 - 02may2020
begin
result:='';

try
if (xlen<1) then exit;
if (xpos<1) then xpos:=1;
result:=copy(x,xpos-1+stroffset,xlen);
except;end;
end;

function insstr(const x:string;y:boolean):string;
begin
result:='';try;if y then result:=x;except;end;
end;

procedure strdef(var x:string;const xdef:string);//set new value, default to "xdef" if xnew is nil
begin

try
if (x='') then x:=xdef;
except;end;

end;

function strdefb(const x,xdef:string):string;
begin

try
if (x='') then result:=xdef else result:=x;
except;end;

end;

function pchar__strlen(str:pchar):cardinal; assembler;
asm
MOV     EDX,EDI
MOV     EDI,EAX
MOV     ECX,0FFFFFFFFH
XOR     AL,AL
REPNE   SCASB
MOV     EAX,0FFFFFFFEH
SUB     EAX,ECX
MOV     EDI,EDX
end;

function low__len(const x:string):longint;
begin
result:=length(x);
end;

function strdel0(var x:string;xpos,xlen:longint):boolean;//0based
begin
result:=true;

try
if (xlen<1) then exit;
if (xpos<0) then xpos:=0;
delete(x,xpos+stroffset,xlen);
except;end;
end;

function strdel1(var x:string;xpos,xlen:longint):boolean;//1based
begin
result:=true;

try
if (xlen<1) then exit;
if (xpos<1) then xpos:=1;
delete(x,xpos-1+stroffset,xlen);
except;end;
end;

function strbyte0(const x:string;xpos:longint):byte;//0based always -> backward compatible with D3 - 02may2020
var
   xlen:longint;
begin
result:=0;

try
if (xpos<0) then xpos:=0;
xlen:=low__len(x);
if (xlen>=1) and (xpos<xlen) then result:=byte(x[xpos+stroffset]);
except;end;
end;

function strbyte0b(x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
begin
result:=0;try;result:=strbyte0(x,xpos);except;end;
end;

function strbyte1(const x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
var
   xlen:longint;
begin
result:=0;

try
if (xpos<1) then xpos:=1;
xlen:=low__len(x);
if (xlen>=1) and (xpos<=xlen) then result:=byte(x[xpos-1+stroffset]);
except;end;
end;

function strbyte1b(x:string;xpos:longint):byte;//1based always -> backward compatible with D3 - 02may2020
begin
result:=0;try;result:=strbyte1(x,xpos);except;end;
end;

function low__setlen(var x:string;xlen:longint):boolean;
begin
result:=false;

try
if (xlen<=0) then x:='' else setlength(x,xlen);
result:=true;
except;end;

end;

function makestr(var x:string;xlen:longint;xfillchar:byte):boolean;
var
   p:longint;
   c:char;
begin
//defaults
result:=false;

try
//get
x:='';
if low__setlen(x,xlen) then
   begin
   c:=char(xfillchar);
   for p:=1 to low__len(x) do x[p-1+stroffset]:=c;
   //successful
   result:=true;
   end;
except;end;
try;if not result then x:='';except;end;
end;

function makestrb(xlen:longint;xfillchar:byte):string;
begin
result:='';try;makestr(result,xlen,xfillchar);except;end;
end;


//block memory management procs ------------------------------------------------
function block__size:longint;
begin
result:=system_blocksize;//static, does not change during runtime
end;

function block__fastinfo(x:pobject;xpos:longint;var xmem:pdlbyte;var xmin,xmax:longint):boolean;
var
   pmem:pointer;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;

try
//get
if str__ok(x) then
   begin
   if      (x^ is tstr9) then (x^ as tstr9).fastinfo(xpos,xmem,xmin,xmax)
   else if (x^ is tstr8) then
      begin
      if (xpos>=0) and (xpos<(x^ as tstr8).len) then
         begin
         xmem:=(x^ as tstr8).core;
         xmin:=0;
         xmax:=(x^ as tstr8).len-1;
         end;
      end
   else if (x^ is tintlist) then
      begin
      (x^ as tintlist).fastinfo(xpos,pmem,xmin,xmax);
      xmem:=pdlbyte(pmem);
      end;
   //successful
   result:=(xmem<>nil) and (xmax>=0) and (xmin>=0);
   end;
except;end;
end;

function block__fastptr(x:pobject;xpos:longint;var xmem:pointer;var xmin,xmax:longint):boolean;
var
   bmem:pdlbyte;
begin
//defaults
result:=false;
xmem:=nil;
xmin:=-1;
xmax:=-2;

try
//get
if str__ok(x) then
   begin
   if      (x^ is tstr9) then
      begin
      (x^ as tstr9).fastinfo(xpos,bmem,xmin,xmax);
      xmem:=pointer(bmem);
      end
   else if (x^ is tstr8) then
      begin
      if (xpos>=0) and (xpos<(x^ as tstr8).len) then
         begin
         xmem:=(x^ as tstr8).core;
         xmin:=0;
         xmax:=(x^ as tstr8).len-1;
         end;
      end
   else if (x^ is tintlist) then (x^ as tintlist).fastinfo(xpos,xmem,xmin,xmax);
   //successful
   result:=(xmem<>nil) and (xmax>=0) and (xmin>=0);
   end;
except;end;
end;

procedure block__cls(x:pointer);
begin
if (x<>nil) then low__cls(x,block__size);
end;

function block__new:pointer;
begin
result:=mem__create(system_blocksize);
if (result<>nil) then track__inc(satBlock,1);
end;

procedure block__free(var x:pointer);
begin
if (x<>nil) and mem__free(x) and (x=nil) then track__inc(satBlock,-1);
end;

procedure block__freeb(x:pointer);
begin
if (x<>nil) and mem__free(x) and (x=nil) then track__inc(satBlock,-1);
end;


//binary string procs ----------------------------------------------------------
function cache__ptr(x:tobject):pobject;//09feb2024: Stores a "floating object" (a dynamically created object that is to be passed to a proc as a parameter)
begin                                //           but which has no persistent variable to act as a SAFE pointer -> object is thus stored on it's own temp var
                                     //           as a special variable "__cacheptr", allowing for safe pointer operations - works on Delphi 3 and Lazarus - 10feb2024
//defaults
result:=nil;

try
//get
if (x<>nil) then
   begin
   if (x is tobjectex) then
      begin
      (x as tobjectex).__cacheptr:=x;
      result:=@(x as tobjectex).__cacheptr;
      end
   else freeobj(@x);//base class doesn't support ".__cacheptr" so we must free it and return nil
   end;
except;end;
end;

function str__info(x:pobject;var xstyle:longint):boolean;
begin
result:=false;
xstyle:=0;

if (x<>nil) and (x^<>nil) then
   begin
   if (x^ is tstr8) then
      begin
      xstyle:=8;
      result:=true;
      end
   else if (x^ is tstr9) then
      begin
      xstyle:=9;
      result:=true;
      end;
   end;
end;

function str__info2(x:pobject):longint;
begin
str__info(x,result);
end;

function str__ok(x:pobject):boolean;
begin
result:=(x<>nil) and (x^<>nil) and ( (x^ is tstr8) or (x^ is tstr9) );
end;

function str__newsametype(x:pobject):tobject;
begin
if str__ok(x) then
   begin
   if (x^ is tstr9) then result:=str__new9
   else                  result:=str__new8;
   end
else                     result:=str__new8;
end;

function str__lock(x:pobject):boolean;
begin
result:=str__ok(x);
if result then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).lock
   else if (x^ is tstr9) then (x^ as tstr9).lock
   else result:=false;
   end;
end;

function str__lock2(x,x2:pobject):boolean;
begin
if      not str__lock(x)  then result:=false
else if not str__lock(x2) then result:=false
else                           result:=true;
end;

function str__lock3(x,x2,x3:pobject):boolean;//17dec2024
begin
if      not str__lock(x)  then result:=false
else if not str__lock(x2) then result:=false
else if not str__lock(x3) then result:=false
else                           result:=true;
end;

function str__unlock(x:pobject):boolean;
begin
result:=str__ok(x);
if result then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).unlock
   else if (x^ is tstr9) then (x^ as tstr9).unlock
   else result:=false;
   end;
end;

procedure str__unlockautofree(x:pobject);
begin
if str__unlock(x) then str__autofree(x);
end;

procedure str__uaf(x:pobject);
begin
if str__unlock(x) then str__autofree(x);
end;

procedure str__uaf2(x,x2:pobject);
begin
if str__unlock(x)  then str__autofree(x);
if str__unlock(x2) then str__autofree(x2);
end;

procedure str__uaf3(x,x2,x3:pobject);//17dec2024
begin
if str__unlock(x)  then str__autofree(x);
if str__unlock(x2) then str__autofree(x2);
if str__unlock(x3) then str__autofree(x3);
end;

procedure str__autofree(x:pobject);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) and (x^ as tstr8).oautofree and ((x^ as tstr8).lockcount=0) then freeobj(x)
   else if (x^ is tstr9) and (x^ as tstr9).oautofree and ((x^ as tstr9).lockcount=0) then freeobj(x);
   end;
end;

procedure str__af(x:pobject);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) and (x^ as tstr8).oautofree and ((x^ as tstr8).lockcount=0) then freeobj(x)
   else if (x^ is tstr9) and (x^ as tstr9).oautofree and ((x^ as tstr9).lockcount=0) then freeobj(x);
   end;
end;

function str__mem(x:pobject):longint;
begin
result:=0;

try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).datalen
else if (x^ is tstr9) then result:=(x^ as tstr9).mem;
except;end;
try;str__uaf(x);except;end;
end;

function str__len(x:pobject):longint;
begin
result:=0;

try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).len
else if (x^ is tstr9) then result:=(x^ as tstr9).len;
except;end;
try;str__uaf(x);except;end;
end;

function str__datalen(x:pobject):longint;
begin
result:=0;

try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).datalen
else if (x^ is tstr9) then result:=(x^ as tstr9).datalen;
except;end;
try;str__uaf(x);except;end;
end;

function str__equal(s,s2:pobject):boolean;
label
   skipend;
var
   smin,smax,smin2,smax2,p,slen,slen2:longint;
   smem,smem2:pdlbyte;
begin
result:=false;

try
//check
if not str__lock2(s,s2) then goto skipend;

//length check
slen :=str__len(s);
slen2:=str__len(s2);
if (slen<>slen2) then goto skipend;
if (slen<=0) then
   begin
   result:=true;
   goto skipend;
   end;

//data check
smax:=-2;
smax2:=-2;
for p:=0 to (slen-1) do
begin
if (p>smax)  and (not block__fastinfo(s,p,smem,smin,smax)) then goto skipend;
if (p>smax2) and (not block__fastinfo(s2,p,smem2,smin2,smax2)) then goto skipend;
//.compare
if (smem[p-smin]<>smem2[p-smin2]) then goto skipend;
end;//p

//successful
result:=true;
skipend:
except;end;
try;str__uaf2(s,s2);except;end;
end;

function str__minlen(x:pobject;xnewlen:longint):boolean;//29feb2024: created
begin
//defaults
result:=false;

try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).minlen(xnewlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).minlen(xnewlen);
except;end;
try;str__uaf(x);except;end;
end;

function str__setlen(x:pobject;xnewlen:longint):boolean;
begin
//defaults
result:=false;

try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).setlen(xnewlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).setlen(xnewlen);
except;end;
try;str__uaf(x);except;end;
end;

function str__new8:tstr8;
begin
result:=nil;try;result:=tstr8.create(0);except;end;
end;

function str__new9:tstr9;
begin
result:=nil;try;result:=tstr9.create(0);except;end;
end;

function str__new8b(const xval:string):tstr8;
begin
result:=nil;try;result:=tstr8.create(0);result.text:=xval;except;end;
end;

function str__new9b(const xval:string):tstr9;
begin
result:=nil;try;result:=tstr9.create(0);result.text:=xval;except;end;
end;

function str__new8c(x:pobject):tstr8;
begin
result:=tstr8.create(0);str__add(@result,x);
end;

function str__new9c(x:pobject):tstr9;
begin
result:=tstr9.create(0);str__add(@result,x);
end;

function str__newlen8(xlen:longint):tstr8;//22jun2024
begin
result:=str__new8;
if (result<>nil) then str__setlen(@result,frcmin32(xlen,0));
end;

function str__newlen9(xlen:longint):tstr9;//22jun2024
begin
result:=str__new9;
if (result<>nil) then str__setlen(@result,frcmin32(xlen,0));
end;

function str__newaf8:tstr8;//autofree
begin
result:=nil;try;result:=tstr8.create(0);result.oautofree:=true;except;end;
end;

function str__newaf9:tstr9;//autofree
begin
result:=nil;try;result:=tstr9.create(0);result.oautofree:=true;except;end;
end;

function str__newaf8b(const xval:string):tstr8;//autofree
begin
result:=nil;try;result:=tstr8.create(0);result.text:=xval;result.oautofree:=true;except;end;
end;

function str__newaf9b(const xval:string):tstr9;//autofree
begin
result:=nil;try;result:=tstr9.create(0);result.text:=xval;result.oautofree:=true;except;end;
end;

procedure str__free(x:pobject);
begin
freeobj(x);
end;

procedure str__free2(x,x2:pobject);
begin
freeobj(x);
freeobj(x2);
end;

procedure str__free3(x,x2,x3:pobject);
begin
freeobj(x);
freeobj(x2);
freeobj(x3);
end;

procedure str__stripwhitespace_lt(s:pobject);//strips leading and trailing white space
begin
str__stripwhitespace(s,false);
str__stripwhitespace(s,true);
end;

procedure str__stripwhitespace(s:pobject;xstriptrailing:boolean);
label
   skipend;
var
   slen,p:longint;
begin
try
//check
if not str__lock(s) then goto skipend;

//init
slen:=str__len(s);
if (slen<=0) then goto skipend;

//get
if xstriptrailing then
   begin//strip trailing white space

   for p:=(slen-1) downto 0 do
   begin
   case str__bytes0(s,p) of
   0..32,160:;
   else
      begin
      if ((p+1)<slen) then str__setlen(s,p+1);
      break;
      end;
   end;//case
   end;//p

   end
else
   begin//strip leading white space

   for p:=0 to (slen-1) do
   begin
   case str__bytes0(s,p) of
   0..32,160:;
   else
      begin
      if (p>=1) then str__del3(s,0,p);
      break;
      end;
   end;//case
   end;//p

   end;//if

skipend:
except;end;
//free
str__uaf(s);
end;

function str__splice(x:pobject;xpos,xlen:longint;var xoutmem:pdlbyte;var xoutlen:longint):boolean;
begin
//defaults
result:=false;

try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).splice(xpos,xlen,xoutmem,xoutlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).splice(xpos,xlen,xoutmem,xoutlen);
except;end;
try;str__uaf(x);except;end;
end;

procedure str__clear(x:pobject);
begin
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then (x^ as tstr8).clear
else if (x^ is tstr9) then (x^ as tstr9).clear;
except;end;
try;str__uaf(x);except;end;
end;

procedure str__softclear(x:pobject);
begin
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then (x^ as tstr8).clear
else if (x^ is tstr9) then (x^ as tstr9).softclear;
except;end;
try;str__uaf(x);except;end;
end;

procedure str__softclear2(x:pobject;xmaxlen:longint);
begin
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then
   begin
   if ((x^ as tstr8).len>xmaxlen) then (x^ as tstr8).setlen(xmaxlen);
   end
else if (x^ is tstr9) then (x^ as tstr9).softclear2(xmaxlen);
except;end;
try;str__uaf(x);except;end;
end;


//string procs -----------------------------------------------------------------
function str__addrec(x:pobject;xrec:pointer;xrecsize:longint):boolean;//20feb2024, 07feb2022
begin
result:=str__pins2(x,pdlbyte(xrec),xrecsize,str__len(x),0,xrecsize-1);
end;

function str__add(x,xadd:pobject):boolean;
begin
result:=str__ins2(x,xadd,str__len(x),0,max32);
end;

function str__add2(x,xadd:pobject;xfrom,xto:longint):boolean;
begin
result:=str__ins2(x,xadd,str__len(x),xfrom,xto);
end;

function str__add3(x,xadd:pobject;xfrom,xlen:longint):boolean;
begin
//result:=false;try;if (xlen>=1) then result:=str__ins2(x,xadd,str__len(x),xfrom,xfrom+xlen-1) else result:=true;except;end;
if (xlen>=1) then result:=str__ins2(x,xadd,str__len(x),xfrom,xfrom+xlen-1) else result:=true;
end;

function str__add31(x,xadd:pobject;xfrom1,xlen:longint):boolean;
begin
result:=false;try;if (xlen>=1) then result:=str__ins2(x,xadd,str__len(x),(xfrom1-1),(xfrom1-1)+xlen-1) else result:=true;except;end;
end;

function str__padd(s:pobject;x:pdlbyte;xsize:longint):boolean;//15feb2024
begin
if (xsize<=0) then result:=true else result:=str__pins2(s,x,xsize,str__len(s),0,xsize-1);
end;

function str__pins2(s:pobject;x:pdlbyte;xcount,xpos,xfrom,xto:longint):boolean;
begin
result:=false;
try
if str__lock(s) then
   begin
   if      (s^ is tstr9) then result:=(s^ as tstr9).pins2(x,xcount,xpos,xfrom,xto)
   else if (s^ is tstr8) then result:=(s^ as tstr8).pins2(x,xcount,xpos,xfrom,xto);
   end;
except;end;
try;str__uaf(s);except;end;
end;

function str__insstr(x:pobject;xadd:string;xpos:longint):boolean;//18aug2024
var
   b:tobject;
begin
result:=false;
b:=nil;

try
b:=str__new8;
str__settext(@b,xadd);
result:=str__ins(x,@b,xpos);
except;end;
str__uaf(@b);
end;

function str__ins(x,xadd:pobject;xpos:longint):boolean;
begin
result:=str__ins2(x,xadd,xpos,0,max32);
end;

function str__ins2(x,xadd:pobject;xpos,xfrom,xto:longint):boolean;
begin
result:=false;

try
//get
if low__true2(str__lock(x),str__lock(xadd)) then
   begin
   if      (x^ is tstr9) then result:=(x^ as tstr9).ins2(xadd,xpos,xfrom,xto)//79% native speed of tstr8.ins2 which uses a single block of memory
   else if (x^ is tstr8) then result:=(x^ as tstr8)._ins2(xadd,xpos,xfrom,xto);
   end;
except;end;
try
str__uaf(x);
str__uaf(xadd);
except;end;
end;

function str__del3(x:pobject;xfrom,xlen:longint):boolean;//06feb2024
begin
result:=str__del(x,xfrom,xfrom+xlen-1);
end;

function str__del(x:pobject;xfrom,xto:longint):boolean;//06feb2024
label
   skipend;
var
   smin,dmin,smax,dmax,xlen,p,int1:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=true;//pass-thru

try
if not str__lock(x) then exit;
xlen:=str__len(x);

//check
if (xlen<=0) or (xfrom>xto) or (xto<0) or (xfrom>=xlen) then exit;
//get
if frcrange2(xfrom,0,xlen-1) and frcrange2(xto,xfrom,xlen-1) then
   begin
   //shift down
   int1:=xto+1;
   if (int1<xlen) then
      begin
      //init
      smax:=-2;
      dmax:=-2;
      //get
      for p:=int1 to (xlen-1) do
      begin
      if (p>smax) and (not block__fastinfo(x,p,smem,smin,smax)) then goto skipend;
      v:=smem[p-smin];

      if ((xfrom+p-int1)>dmax) and (not block__fastinfo(x,xfrom+p-int1,dmem,dmin,dmax)) then goto skipend;
      dmem[xfrom+p-int1-dmin]:=v;
      end;//p
      end;
   //resize
   result:=str__setlen(x,xlen-(xto-xfrom+1));
   end;
skipend:
except;end;
end;

function str__is8(x:pobject):boolean;//x is tstr8
begin
result:=str__ok(x) and (x^ is tstr8);
end;

function str__is9(x:pobject):boolean;//x is tstr9
begin
result:=str__ok(x) and (x^ is tstr9);
end;

function str__as8(x:pobject):tstr8;
begin
if str__is8(x) then result:=(x^ as tstr8) else result:=nil;
end;

function str__as9(x:pobject):tstr9;
begin
if str__is9(x) then result:=(x^ as tstr9) else result:=nil;
end;

function str__as8f(x:pobject):tstr8;//uses fallback var instead of failure - 30aug2025
begin

if str__is8(x) then result:=(x^ as tstr8)
else
   begin

   if (system_root_str8=nil) then system_root_str8:=str__new8;
   system_root_str8.floatsize:=5000;
   system_root_str8.clear;

   result:=system_root_str8;

   end;

end;

function str__as9f(x:pobject):tstr9;//uses fallback var instead of failure - 30aug2025
begin

if str__is9(x) then result:=(x^ as tstr9)
else
   begin

   if (system_root_str9=nil) then system_root_str9:=str__new9;
   system_root_str9.clear;

   result:=system_root_str9;

   end;

end;

function str__asame2(x:pobject;xfrom:longint;const xlist:array of byte):boolean;
begin
result:=str__asame3(x,xfrom,xlist,true);
end;

function str__asame3(x:pobject;xfrom:longint;const xlist:array of byte;xcasesensitive:boolean):boolean;//20jul2024
begin
result:=false;
try
if not str__lock(x)   then exit
else if (x^ is tstr8) then result:=(x^ as tstr8).asame3(xfrom,xlist,xcasesensitive)
else if (x^ is tstr9) then result:=(x^ as tstr9).asame3(xfrom,xlist,xcasesensitive);
except;end;
try;str__uaf(x);except;end;
end;

function str__aadd(x:pobject;const xlist:array of byte):boolean;//20jul2024
begin
result:=false;
try
if not str__lock(x)   then exit
else if (x^ is tstr8) then result:=(x^ as tstr8).aadd(xlist)
else if (x^ is tstr9) then result:=(x^ as tstr9).aadd(xlist);
str__uaf(x);
except;end;
try;str__uaf(x);except;end;
end;

function str__addbyt1(x:pobject;xval:longint):boolean;
begin
result:=str__aadd(x,[xval]);
end;

function str__addbol1(x:pobject;xval:boolean):boolean;
begin
if xval then result:=str__aadd(x,[1]) else result:=str__aadd(x,[0]);
end;

function str__addchr1(x:pobject;xval:char):boolean;
begin
result:=str__aadd(x,[byte(xval)]);
end;

function str__addsmi2(x:pobject;xval:smallint):boolean;
var
   a:twrd2;
begin
a.si:=xval;
result:=str__aadd(x,[a.bytes[0],a.bytes[1]]);
end;

function str__addwrd2(x:pobject;xval:word):boolean;
begin
result:=str__aadd(x,twrd2(xval).bytes);
end;

function str__addint4(x:pobject;xval:longint):boolean;
begin
result:=str__aadd(x,tint4(xval).bytes);
end;

function str__writeto1(x:pobject;a:pointer;asize,xfrom1,xlen:longint):boolean;
begin
result:=false;
try
if not str__lock(x)   then exit
else if (x^ is tstr8) then result:=(x^ as tstr8).writeto1(a,asize,xfrom1,xlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).writeto1(a,asize,xfrom1,xlen);
except;end;
try;str__uaf(x);except;end;
end;

function str__writeto1b(x:pobject;a:pointer;asize:longint;var xfrom1:longint;xlen:longint):boolean;
begin
result:=false;
try
if not str__lock(x)   then exit
else if (x^ is tstr8) then result:=(x^ as tstr8).writeto1b(a,asize,xfrom1,xlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).writeto1b(a,asize,xfrom1,xlen);
except;end;
try;str__uaf(x);except;end;
end;

function str__writeto(x:pobject;a:pointer;asize,xfrom0,xlen:longint):boolean;
begin
result:=false;
try
if not str__lock(x)   then exit
else if (x^ is tstr8) then result:=(x^ as tstr8).writeto(a,asize,xfrom0,xlen)
else if (x^ is tstr9) then result:=(x^ as tstr9).writeto(a,asize,xfrom0,xlen);
except;end;
try;str__uaf(x);except;end;
end;

function str__sadd(x:pobject;const xdata:string):boolean;
begin
result:=false;

if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).sadd(xdata)
   else if (x^ is tstr9) then result:=(x^ as tstr9).sadd(xdata);
   end;
{
try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).sadd(xdata)
else if (x^ is tstr9) then result:=(x^ as tstr9).sadd(xdata);
except;end;
try;str__uaf(x);except;end;
{}
end;

function str__remchar(x:pobject;y:byte):boolean;//29feb2024: created
label
   skipend;
var
   smin,smax,dmin,dmax,slen,dlen,p:longint;
   smem,dmem:pdlbyte;
   v:byte;
begin
//defaults
result:=false;

//check
if not str__lock(x) then exit;

try
//init
slen:=str__len(x);
dlen:=0;
if (slen<=0) then goto skipend;
smax:=-2;
smin:=-1;
dmax:=-2;
dmin:=-1;

//get
for p:=0 to (slen-1) do
begin
if (p>smax) and (not block__fastinfo(x,p,smem,smin,smax)) then goto skipend;
v:=smem[p-smin];
if (v<>y) then
   begin
   if (dlen>dmax) and (not block__fastinfo(x,dlen,dmem,dmin,dmax)) then goto skipend;
   dmem[dlen-dmin]:=v;
   inc(dlen);
   end;
end;//p

//finalise
if (dlen<>slen) then
   begin
   str__setlen(x,dlen);
   result:=true;
   end;

skipend:
except;end;
try;str__uaf(x);except;end;
end;

function str__text(x:pobject):string;
begin
//defaults
result:='';

//check
if not str__lock(x) then exit;

try
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).text
else if (x^ is tstr9) then result:=(x^ as tstr9).text;
except;end;
try;str__uaf(x);except;end;
end;

function str__settext(x:pobject;const xtext:string):boolean;
begin
//defaults
result:=false;

//check
if not str__lock(x) then exit;

try
//get
if (x^ is tstr8) then
   begin
   (x^ as tstr8).text:=xtext;
   result:=true;
   end
else if (x^ is tstr9) then
   begin
   (x^ as tstr9).text:=xtext;
   result:=true;
   end;
except;end;
try;str__uaf(x);except;end;
end;

function str__settextb(x:pobject;const xtext:string):boolean;
begin
result:=str__settext(x,xtext);
end;

function str__str1(x:pobject;xpos,xlen:longint):string;
begin
//defaults
result:='';

try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).str1[xpos,xlen]
else if (x^ is tstr9) then result:=(x^ as tstr9).str1[xpos,xlen];
except;end;
try;str__uaf(x);except;end;
end;

function str__str0(x:pobject;xpos,xlen:longint):string;
begin
//defaults
result:='';

try
//check
if not str__lock(x) then exit;
//get
if      (x^ is tstr8) then result:=(x^ as tstr8).str[xpos,xlen]
else if (x^ is tstr9) then result:=(x^ as tstr9).str[xpos,xlen];
except;end;
try;str__uaf(x);except;end;
end;

function bcopy1(x:tstr8;xpos1,xlen:longint):tstr8;//fixed - 26apr2021
begin
result:=str__newaf8;
try;if str__lock(@x) then result.add3(x,xpos1-1,xlen);except;end;
str__uaf(@x);
end;

function str__copy81(x:tobject;xpos1,xlen:longint):tstr8;//28jun2024
begin
result:=str__new8;
str__add3(@result,@x,xpos1-1,xlen);
result.oautofree:=true;
end;

function str__copy91(x:tobject;xpos1,xlen:longint):tstr9;//28jun2024
begin
result:=str__new9;
str__add3(@result,@x,xpos1-1,xlen);
result.oautofree:=true;
end;

function str__sml2(x:pobject;xpos:longint):smallint;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).sml2[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).sml2[xpos];
   end;
end;

function str__seekpos(x:pobject):longint;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).seekpos
   else if (x^ is tstr9) then result:=(x^ as tstr9).seekpos;
   end;
end;

function str__tag1(x:pobject):longint;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).tag1
   else if (x^ is tstr9) then result:=(x^ as tstr9).tag1;
   end;
end;

function str__tag2(x:pobject):longint;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).tag2
   else if (x^ is tstr9) then result:=(x^ as tstr9).tag2;
   end;
end;

function str__tag3(x:pobject):longint;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).tag3
   else if (x^ is tstr9) then result:=(x^ as tstr9).tag3;
   end;
end;

function str__tag4(x:pobject):longint;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).tag4
   else if (x^ is tstr9) then result:=(x^ as tstr9).tag4;
   end;
end;

function str__setseekpos(x:pobject;xval:longint):boolean;
begin
result:=false;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then
      begin
      (x^ as tstr8).seekpos:=xval;
      result:=true;
      end
   else if (x^ is tstr9) then
      begin
      (x^ as tstr9).seekpos:=xval;
      result:=true;
      end;
   end;
end;

function str__settag1(x:pobject;xval:longint):boolean;
begin
result:=false;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then
      begin
      (x^ as tstr8).tag1:=xval;
      result:=true;
      end
   else if (x^ is tstr9) then
      begin
      (x^ as tstr9).tag1:=xval;
      result:=true;
      end;
   end;
end;

function str__settag2(x:pobject;xval:longint):boolean;
begin
result:=false;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then
      begin
      (x^ as tstr8).tag2:=xval;
      result:=true;
      end
   else if (x^ is tstr9) then
      begin
      (x^ as tstr9).tag2:=xval;
      result:=true;
      end;
   end;
end;

function str__settag3(x:pobject;xval:longint):boolean;
begin
result:=false;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then
      begin
      (x^ as tstr8).tag3:=xval;
      result:=true;
      end
   else if (x^ is tstr9) then
      begin
      (x^ as tstr9).tag3:=xval;
      result:=true;
      end;
   end;
end;

function str__settag4(x:pobject;xval:longint):boolean;
begin
result:=false;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then
      begin
      (x^ as tstr8).tag4:=xval;
      result:=true;
      end
   else if (x^ is tstr9) then
      begin
      (x^ as tstr9).tag4:=xval;
      result:=true;
      end;
   end;
end;

function str__pbytes0(x:pobject;xpos:longint):byte;//not limited by internal count, but by datalen
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).pbytes[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).pbytes[xpos];
   end;
end;

function str__bytes0(x:pobject;xpos:longint):byte;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).bytes[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).bytes[xpos];
   end;
end;

function str__bytes1(x:pobject;xpos:longint):byte;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).bytes[xpos-1]
   else if (x^ is tstr9) then result:=(x^ as tstr9).bytes[xpos-1];
   end;
end;

procedure str__setpbytes0(x:pobject;xpos:longint;xval:byte);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).pbytes[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).pbytes[xpos]:=xval;
   end;
end;

procedure str__setbytes0(x:pobject;xpos:longint;xval:byte);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).bytes[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).bytes[xpos]:=xval;
   end;
end;

procedure str__setbytes1(x:pobject;xpos:longint;xval:byte);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).bytes[xpos-1]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).bytes[xpos-1]:=xval;
   end;
end;

function str__moveto(s:pobject;var d;spos,ssize:longint):longint;//move memory from "s" to buffer "d" - 04may2025
var
   s8   :tstr8;//pointer only
   slist:pdlbyte;
   p    :longint;
begin
//defaults
result:=0;

//range
if (ssize<=0) then exit;
if (spos<0)   then spos:=0;

//get
if str__ok(s) then
   begin
   //init
   result:=frcmin32( frcmax32(ssize,str__len(s)-spos) ,0);

   //get
   if (result>=1) then
      begin
      s8   :=str__as8(s);
      slist:=nil;

      try
      getmem(slist,result);

      //get
      case (s8<>nil) of
      true:for p:=0 to (result-1) do slist[p]:=s8.bytes[p+spos];
      else for p:=0 to (result-1) do slist[p]:=str__bytes0(s,p+spos);
      end;//case

      //set
      move(slist^,d,result);

      finally
      //free
      if (slist<>nil) then freemem(slist);
      end;
      end;//if

   end;

end;

function str__movefrom(s:pobject;const d;ssize:longint):longint;//move memory from buffer "d" to "s" - 04may2025
var
   s8   :tstr8;//pointer only
   slist:pdlbyte;
begin
//defaults
result:=frcmin32(ssize,0);

//get
if (result>=1) and str__ok(s) then
   begin
   s8   :=str__as8(s);
   slist:=nil;

   try
   getmem(slist,result);

   //get
   move(d,slist^,result);

   //set
   if (result>=1) then
      begin
      //size
      case (s8<>nil) of
      true:s8.addrec(slist,result);
      else str__addrec(s,slist,result);
      end;
      end;

   finally
   //free
   if (slist<>nil) then freemem(slist);
   end;

   end;

end;

function str__byt1(x:pobject;xpos:longint):byte;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).byt1[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).byt1[xpos];
   end;
end;

procedure str__setbyt1(x:pobject;xpos:longint;xval:byte);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).byt1[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).byt1[xpos]:=xval;
   end;
end;

function str__wrd2(x:pobject;xpos:longint):word;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).wrd2[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).wrd2[xpos];
   end;
end;

procedure str__setwrd2(x:pobject;xpos:longint;xval:word);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).wrd2[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).wrd2[xpos]:=xval;
   end;
end;

function str__int4(x:pobject;xpos:longint):longint;
begin
result:=0;
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).int4[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).int4[xpos];
   end;
end;

procedure str__setint4(x:pobject;xpos,xval:longint);//22nov2024
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).int4[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).int4[xpos]:=xval;
   end;
end;

function str__c8(x:pobject;xpos:longint):tcolor8;
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).c8[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).c8[xpos]
   else                       result:=0;
   end
else result:=0;
end;

procedure str__setc8(x:pobject;xpos:longint;xval:tcolor8);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).c8[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).c8[xpos]:=xval;
   end;
end;

function str__c24(x:pobject;xpos:longint):tcolor24;
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).c24[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).c24[xpos]
   else
      begin
      result.r:=0;
      result.g:=0;
      result.b:=0;
      end;
   end
else
   begin
   result.r:=0;
   result.g:=0;
   result.b:=0;
   end;
end;

procedure str__setc24(x:pobject;xpos:longint;xval:tcolor24);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).c24[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).c24[xpos]:=xval;
   end;
end;

function str__c32(x:pobject;xpos:longint):tcolor32;
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).c32[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).c32[xpos]
   else
      begin
      result.r:=0;
      result.g:=0;
      result.b:=0;
      result.a:=255;
      end;
   end
else
   begin
   result.r:=0;
   result.g:=0;
   result.b:=0;
   result.a:=255;
   end;
end;

procedure str__setc32(x:pobject;xpos:longint;xval:tcolor32);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).c32[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).c32[xpos]:=xval;
   end;
end;

function str__c40(x:pobject;xpos:longint):tcolor40;
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then result:=(x^ as tstr8).c40[xpos]
   else if (x^ is tstr9) then result:=(x^ as tstr9).c40[xpos]
   else
      begin
      result.r:=0;
      result.g:=0;
      result.b:=0;
      result.a:=255;
      result.c:=0;
      end;
   end
else
   begin
   result.r:=0;
   result.g:=0;
   result.b:=0;
   result.a:=255;
   result.c:=0;
   end;
end;

procedure str__setc40(x:pobject;xpos:longint;xval:tcolor40);
begin
if str__ok(x) then
   begin
   if      (x^ is tstr8) then (x^ as tstr8).c40[xpos]:=xval
   else if (x^ is tstr9) then (x^ as tstr9).c40[xpos]:=xval;
   end;
end;

function str__tob64(s,d:pobject;linelength:longint):boolean;//to base64
begin
result:=str__tob642(s,d,1,linelength);
end;

function str__tob642(s,d:pobject;xpos1,linelength:longint):boolean;//25jul2024: support for tstr8 and tstr9, 13jan2024: uses #10 return codes
begin
result:=str__tob643(s,d,xpos1,linelength,false,true,false);
end;

function str__tob643(s,d:pobject;xpos1,linelength:longint;r13,r10,xincludetrailingrcode:boolean):boolean;//03apr2024: r13 and r10, 25jul2024: support for tstr8 and tstr9, 13jan2024: uses #10 return codes
label
   skipend;
var
   sptr:tobject;
   smustfree:boolean;
   a,b:tint4;
   ll,slen,dlen,p,i:longint;
begin
//defaults
result:=false;
smustfree:=false;
sptr:=nil;

try
//check
if not low__true2(str__lock(s),str__lock(d)) then goto skipend;

//init
if (str__len(s)<=0) then
   begin
   str__clear(d);
   result:=true;
   goto skipend;
   end;

//detect in-out same conflict - 21aug2020
if (s=d) then
   begin
   smustfree:=true;
   sptr:=str__newsametype(s);
   str__add(@sptr,s);
   str__clear(s);
   end
else
   begin
   sptr:=s^;
   str__clear(d);
   end;

//get
dlen:=0;
slen:=str__len(@sptr);
ll:=0;
p:=1;
if (linelength<0) then linelength:=0;
str__minlen(d,4096+6);

repeat
//.get
a.val:=0;
a.bytes[2]:=str__bytes0(@sptr,p-1);
if ((p+1)<=slen) then a.bytes[1]:=str__bytes0(@sptr,p+1-1) else a.bytes[1]:=0;
if ((p+0)<=slen) then a.bytes[0]:=str__bytes0(@sptr,p+2-1) else a.bytes[0]:=0;

//.soup (3 -> 4)
b.bytes[0]:=(a.val div 262144);
dec(a.val,b.bytes[0]*262144);

b.bytes[1]:=(a.val div 4096);
dec(a.val,b.bytes[1]*4096);

if ((p+1)<=slen) then
   begin
   b.bytes[2]:=a.val div 64;
   dec(a.val,b.bytes[2]*64);
   end
else b.bytes[2]:=64;

if ((p+2)<=slen) then b.bytes[3]:=a.val else b.bytes[3]:=64;

//.encode
for i:=0 to 3 do b.bytes[i]:=base64[b.bytes[i]];

//.dlen
if ((dlen+6)>=str__len(d)) then str__minlen(d,dlen+100000);//100K buffer
inc(dlen,4);
str__setpbytes0(d,dlen-3-1,b.bytes[0]);//11aug2024: fixed -> str__setpbytes0() can write past len and upto internal datalen, was using "str__setbytes0()" which is limited to len and cannot write upto internal datalen
str__setpbytes0(d,dlen-2-1,b.bytes[1]);
str__setpbytes0(d,dlen-1-1,b.bytes[2]);
str__setpbytes0(d,dlen-1  ,b.bytes[3]);

//.line
if (linelength<>0) then
   begin
   inc(ll,4);
   if (ll>=linelength) then
      begin

      //.r13
      if r13 then
         begin
         inc(dlen,1);
         str__setpbytes0(d,dlen-1,13);//03apr2025
         end;

      //.r10
      if r10 then
         begin
         inc(dlen,1);
         str__setpbytes0(d,dlen-1,10);//03apr2025
         end;

      ll:=0;
      end;//if
   end;//if

//.inc
inc(p,3);
until (p>slen);

//.finalise
if (dlen>=1) then str__setlen(d,dlen);

//.force trailing return code
if (ll>=1) and xincludetrailingrcode then
   begin
   if r13 then str__sadd(d,#13);
   if r10 then str__sadd(d,#10);
   end;

//successful
result:=true;
skipend:
except;end;
try
if (not result) and str__ok(d)  then str__clear(d);
if smustfree and str__ok(@sptr) then str__free(@sptr);
str__uaf(s);
str__uaf(d);
except;end;
end;

function str__fromb64(s,d:pobject):boolean;//25jul2024: support for tstr8 and tstr9
begin
result:=str__fromb642(s,d,1);
end;

function str__fromb642(s,d:pobject;xpos1:longint):boolean;
label
   skipend;
var
   sptr:tobject;
   smustfree:boolean;
   b,a:tint4;
   slen,dlen,c,p:longint;
   v:byte;
begin
//defaults
result:=false;
smustfree:=false;
sptr:=nil;

try
//check
if not low__true2(str__lock(s),str__lock(d)) then goto skipend;

//init
if (str__len(s)<=0) then
   begin
   str__clear(d);
   result:=true;
   goto skipend;
   end;

//detect in-out same conflict - 21aug2020
if (s=d) then
   begin
   smustfree:=true;
   sptr:=str__newsametype(s);
   str__add(@sptr,s);
   str__clear(s);
   end
else
   begin
   sptr:=s^;
   str__clear(d);
   end;

//get
dlen:=0;
slen:=str__len(@sptr);
p:=frcmin32(xpos1,1);
if (p>slen) then
   begin
   result:=true;
   goto skipend;
   end;
repeat
a.val:=0;
c:=0;
repeat
//.store
v:=byte(base64r[ str__bytes0(@sptr,p-1) ]-48);
if (v>=0) and (v<=63) then
   begin
   //.set
   case c of
   0:inc(a.val,v*262144);
   1:inc(a.val,v*4096);
   2:inc(a.val,v*64);
   3:begin
     inc(a.val,v);
     inc(c);
     inc(p);
     break;
     end;//begin
   end;//case
   //.inc
   inc(c,1);
   end
else if (v=64) then
   begin
   p:=slen;
   break;//=
   end;//if
//.inc
inc(p);
until (p>slen);
//.split (4 -> 3)
b.bytes[0]:=a.val div 65536;
dec(a.val,b.bytes[0]*65536);
b.bytes[1]:=a.val div 256;
dec(a.val,b.bytes[1]*256);
b.bytes[2]:=a.val;
//.set
case c of
4:begin
  inc(dlen,3);
  if ((dlen+3)>str__len(d)) then str__minlen(d,dlen+100000);
  str__setpbytes0(d, dlen-2-1, b.bytes[0]);//11aug2024: fixed -> str__setpbytes0() can write past len and upto internal datalen, was using "str__setbytes0()" which is limited to len and cannot write upto internal datalen
  str__setpbytes0(d, dlen-1-1, b.bytes[1]);
  str__setpbytes0(d, dlen+0-1, b.bytes[2]);
  end;//begin
3:begin//finishing #1
  inc(dlen,2);
  if ((dlen+2)>str__len(d)) then str__minlen(d,dlen+100);
  str__setpbytes0(d, dlen-1-1, b.bytes[0]);
  str__setpbytes0(d, dlen+0-1, b.bytes[1]);
  end;//begin
1..2:begin//finishing #2
  inc(dlen,1);
  if ((dlen+1)>str__len(d)) then str__minlen(d,dlen+100);
  str__setpbytes0(d, dlen+0-1, b.bytes[0]);
  end;//begin
end;//case
until (p>=slen);
//.finalise
if (dlen>=1) then str__setlen(d,dlen);
//successful
result:=true;
skipend:
except;end;
try
if (not result) and str__ok(d)  then str__clear(d);
if smustfree and str__ok(@sptr) then str__free(@sptr);
str__uaf(s);
str__uaf(d);
except;end;
end;

function str__multipart_nextitem(x:pobject;var xpos:longint;var xboundary,xname,xfilename,xcontenttype:string;xoutdata:pobject):boolean;//03apr2025
label//Note: xboundary is the "boundary string" generated by the Browser when transmitting the form data
   redo,redo2,skipdone,skipend;
var
   lp,p,xdatapos,xdatalen,smin,smax,xlen,blen:longint;
   smem:pdlbyte;
   v,b1:byte;

   procedure xreadline;
   var
      n,v,xline:string;
      p3,lp2,p2:longint;
      c:byte;
      xwithinquotes:boolean;

      function xclean(const x:string):string;//03apr2025: fixed the "" for blank filenames
      var
         p:longint;
         bol1:boolean;

         function xcharok(x:byte):boolean;
         begin
         result:=(x<>ssSpace) and (x<>ssTab) and (x<>ssDoublequote) and (x<>10) and (x<>13);
         end;
      begin
      result:='';

      try
      //pre-clean
      if (x<>'') then for p:=1 to low__len(x) do if xcharok( ord(x[p-1+stroffset]) ) then
         begin
         result:=strcopy1(x,p,low__len(x));
         break;
         end;//p

      //post-clean
      if (result<>'') then
         begin
         bol1:=false;

         for p:=low__len(result) downto 1 do if xcharok( ord(result[p-1+stroffset]) ) then
            begin
            result:=strcopy1(result,1,p);
            bol1  :=true;
            break;
            end;//p

         if not bol1 then result:='';
         end;

      except;end;
      end;
   begin
   try
   xwithinquotes:=false;
   xline:=str__str0(x,lp,p-lp)+';';
   lp2:=1;

   for p2:=1 to low__len(xline) do
   begin
   c:=ord(xline[p2-1+stroffset]);

   if      (c=ssDoublequote) then xwithinquotes:=not xwithinquotes
   else if (c=ssSemicolon) and (not xwithinquotes) then
      begin
      n:=strcopy1(xline,lp2,p2-lp2);
      lp2:=p2+1;
      //.split into name+value
      if (n<>'') then
         begin
         for p3:=1 to low__len(n) do
         begin
         c:=ord(n[p3-1+stroffset]);
         if (c=ssColon) or (c=ssEqual) then
            begin
            //get
            v:=xclean(strcopy1(n,p3+1,low__len(n)));
            n:=xclean(strlow(strcopy1(n,1,p3-1)));

            //set
            if      (n='name')         then xname        :=v
            else if (n='filename')     then xfilename    :=v
            else if (n='content-type') then xcontenttype :=v;
            //stop
            break;
            end;
         end;//p3
         end;//n
      end;

   end;//p2

   except;end;
   end;
begin
//defaults
result:=false;

try
xname:='';
xfilename:='';
xcontenttype:='';
smin:=-1;
smax:=-2;

//check
if not low__true2(str__lock(x),str__lock(xoutdata)) then goto skipend;
if (x=xoutdata) then goto skipend;

//init
str__clear(xoutdata);
blen:=low__len(xboundary);
if (blen<=0) then goto skipend;
b1:=ord(xboundary[1-1+stroffset]);

xlen:=str__len(x);
if (xpos<0) then xpos:=0;
if (xpos>=xlen) then goto skipend;

//find boundary - start
redo:
if (xpos>smax) and (not block__fastinfo(x,xpos,smem,smin,smax)) then goto skipend;
if (smem[xpos-smin]=b1) and (xboundary=str__str1(x,xpos+1,blen)) then
   begin
   inc(xpos,blen);
   xdatapos:=xpos;
   xdatalen:=xlen-xpos;
   goto redo2;
   end;

//.inc
inc(xpos);
if (xpos<xlen) then goto redo;
//.failed
goto skipend;

//find boundary - finish
redo2:
if (xpos>smax) and (not block__fastinfo(x,xpos,smem,smin,smax)) then goto skipend;
if (smem[xpos-smin]=b1) then
   begin
   if (xboundary=str__str1(x,xpos+1,blen)) then
      begin
      xdatalen:=xpos-xdatapos-2;//back up to exclude previous CRLF
      goto skipdone;
      end
   else if ((strcopy1(xboundary,1,blen-2)+'--')=str__str1(x,xpos+1,blen)) then
      begin
      xdatalen:=xpos-xdatapos-2;//back up to exclude previous CRLF
      xpos:=xlen;//mark as at end of list
      goto skipdone;
      end;
   end;
//.inc
inc(xpos);
if (xpos<xlen) then goto redo2;

//done - read data
skipdone:

//.read header
lp:=xdatapos;
for p:=xdatapos to (xdatapos+xdatalen-1) do
begin
v:=str__bytes0(x,p);
if (v=13) and (str__bytes0(x,p+1)=10) and (str__bytes0(x,p+2)=13) and (str__bytes0(x,p+3)=10) then
   begin
   xreadline;
   if not str__add3(xoutdata,x,p+4,xdatalen-(p-xdatapos)-4) then goto skipend;
   break;
   end
else if (v=13) then
   begin
   xreadline;
   lp:=p+2;
   end;
end;

//successful
result:=true;
skipend:
except;end;
try
str__uaf(x);
str__uaf(xoutdata);
except;end;
end;

function fromnullstr(a:pointer;asize:longint):string;
var
   p:longint;
   b:pdlBYTE;
begin

//defaults
result:='';

try
//init
low__setlen(result,asize);
b:=a;

//get
for p:=0 to (asize-1) do
    begin

    result[p+stroffset]:=chr(b[p]);

    if (b[p]=0) then
       begin

       low__setlen(result,p);
       break;

       end;

    end;

except;end;
end;

function str__nullstr(x:pobject):string;//07oct2025
var
   p,i:longint;
begin

//defaults
result:='';

//get
if str__lock(x) then
   begin

   try
   for p:=1 to str__len(x) do if (str__pbytes0(x,p-1)=0) then
      begin

      low__setlen(result,p-1);
      for i:=1 to (p-1) do result[i-1+stroffset]:=char( str__pbytes0(x,i-1) );
      break;

      end;//p
   except;end;

   //free
   str__uaf(x);

   end;

end;

function str__nextline0(xdata,xlineout:pobject;var xpos:longint):boolean;//07apr2025, 31mar2025, 17oct2018
label
   skipend;
var//0-base
   //Super fast line reader.  Supports #13 / #10 / #13#10 / #10#13,
   //with support for last line detection WITHOUT a trailing #10/#13 or combination thereof.
   xlen,int1,p:longint;
   v0,v1,vlast:byte;
   bol1:boolean;

   function vcheck1:boolean;
   begin
   vlast:=str__pbytes0(xdata,p);
   result:=((p+1)=xlen) or (vlast=10) or (vlast=13);
   end;

   function vcheck2:boolean;
   begin
   result:=((p+1)=xlen) and (vlast<>10) and (vlast<>13);
   end;
begin
//defaults
result:=false;
v0    :=0;
v1    :=0;

try
//check
if not str__lock2(xdata,xlineout) then goto skipend;

//init
str__clear(xlineout);
if (xpos<0) then xpos:=0;
xlen:=str__len(xdata);

//get
if (xlen>=1) and (xpos<xlen) then for p:=xpos to (xlen-1) do if vcheck1 then
   begin

   //get
   result:=true;//detect even blank lines
   if (p>=xpos) then//fixed, was "p>xpos" - 07apr2020
      begin
      if vcheck2 then int1:=1 else int1:=0;//adjust for last line terminated by #10/#13 or without either - 18oct2018
      str__add3(xlineout,xdata,xpos,p-xpos+int1);
      end;

   //inc
   bol1:=(p<(xlen-1));
   if bol1 then
      begin
      v0:=str__pbytes0(xdata,p);
      v1:=str__pbytes0(xdata,p+1);
      end;

   if      bol1 and (v0=13) and (v1=10) then xpos:=p+2//2 byte return code
   else if bol1 and (v0=10) and (v1=13) then xpos:=p+2//2 byte return code
   else                                      xpos:=p+1;//1 byte return code

   //quit
   break;
   end;
skipend:
except;end;
//free
str__uaf(xdata);
str__uaf(xlineout);
end;

function bgetstr1(x:tobject;xpos1,xlen:longint):string;
begin
result:='';
try
if (str__len(@x)>=1) then
   begin
   if      (x is tstr8) then result:=(x as tstr8).str1[xpos1,xlen]
   else if (x is tstr9) then result:=(x as tstr9).str1[xpos1,xlen];
   end;
except;end;
try;str__autofree(@x);except;end;
end;

function _blen(x:tobject):longint;//does NOT destroy "x", keeps "x"
begin
result:=0;
try
if zzok(x,1001) then
   begin
   if      (x is tstr8) then result:=(x as tstr8).len
   else if (x is tstr9) then result:=(x as tstr9).len;
   end;
except;end;
end;

procedure bdel1(x:tobject;xpos1,xlen:longint);
begin
try
if (xpos1>=1) and (xlen>=1) and zzok(x,1003) then
   begin
   if      (x is tstr8) then (x as tstr8).del(xpos1-1,xpos1-1+xlen-1)
   else if (x is tstr9) then (x as tstr9).del(xpos1-1,xpos1-1+xlen-1);
   end;
except;end;
try;str__autofree(@x);except;end;
end;

function bcopystr1(const x:string;xpos1,xlen:longint):tstr8;
begin
result:=nil;
try
result:=str__newaf8;
if (x<>'') then result.sadd3(x,xpos1-1,xlen);
except;end;
end;

function bcopystrall(const x:string):tstr8;
begin

result:=str__newaf8;
if (x<>'') then result.sadd(x);

end;

function bcopyarray(const x:array of byte):tstr8;
begin

result:=str__newaf8;
result.aadd(x);

end;

function bnew2(var x:tstr8):boolean;//21mar2022
begin

x:=str__new8;
result:=(x<>nil);

end;

function bnewlen(xlen:longint):tstr8;
begin

result:=tstr8.create(frcmin32(xlen,0));

end;

function bnewstr(const xtext:string):tstr8;
begin
result:=str__new8;
try;result.replacestr:=xtext;except;end;
end;

function breuse(var x:tstr8;const xtext:string):tstr8;//also acts as a pass-thru - 24aug2025, 05jul2022
begin//Warning: Use with care, auto-creates, but never destroys -> that is upto the host
result:=nil;

try

if (x=nil) then x:=str__new8;
x.replacestr :=xtext;
result       :=x;

except;end;
end;

function bnewfrom(xdata:tstr8):tstr8;
begin

result:=tstr8.create(0);
result.replace:=xdata;

end;


//zero checkers ----------------------------------------------------------------
function nozero__int32(xdebugID,x:longint):longint;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+intstr32(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (int) error at location '+intstr32(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__int64(xdebugID:longint;x:comp):comp;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+intstr32(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (comp) error at location '+intstr32(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__byt(xdebugID:longint;x:byte):byte;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+intstr32(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (byte) error at location '+intstr32(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__dbl(xdebugID:longint;x:double):double;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+intstr32(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (double) error at location '+intstr32(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__ext(xdebugID:longint;x:extended):extended;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+intstr32(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (extended) error at location '+intstr32(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__cur(xdebugID:longint;x:currency):currency;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+intstr32(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (currency) error at location '+intstr32(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__sig(xdebugID:longint;x:single):single;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+intstr32(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (single) error at location '+intstr32(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;

function nozero__rel(xdebugID:longint;x:real):real;
begin
//defaults
result:=1;//fail safe value

try
//check
if (xdebugID<1000000) then showerror('Invalid no zero location value '+intstr32(xdebugID));//value MUST BE 1 million or above - this is strictly a made-up threshold to make it standout from code and code values - 26jul2016
//get
if (x=0) then
   begin
   //in program debug
   if debugging then showerror('No zero (real) error at location '+intstr32(xdebugID));
   //other
   exit;
   end
else result:=x;//acceptable value (non-zero)
except;end;
end;


//logic helper procs -----------------------------------------------------------

function low__true1(v1:boolean):boolean;
begin
result:=v1;
end;

function low__true2(v1,v2:boolean):boolean;
begin
result:=v1 and v2;
end;

function low__true3(v1,v2,v3:boolean):boolean;
begin
result:=v1 and v2 and v3;
end;

function low__true4(v1,v2,v3,v4:boolean):boolean;
begin
result:=v1 and v2 and v3 and v4;
end;

function low__true5(v1,v2,v3,v4,v5:boolean):boolean;
begin
result:=v1 and v2 and v3 and v4 and v5;
end;

function low__or2(v1,v2:boolean):boolean;
begin
result:=v1 or v2;
end;

function low__or3(v1,v2,v3:boolean):boolean;
begin
result:=v1 or v2 or v3;
end;


//crc32 procs ------------------------------------------------------------------

procedure low__initcrc32;
var//Note: 0xedb88320L="-306674912"
   c,k,n:longint;
begin
try
//check
if sys_initcrc32 then exit;
//get
for n:=0 to 255 do
begin
c:=n;
for k:=0 to 7 do if boolean(c and 1) then c:=crc_seed xor (c shr 1) else c:=c shr 1;
sys_crc32[n]:=c;
end;//loop
except;end;
try;sys_initcrc32:=true;except;end;
end;

procedure low__crc32inc(var _crc32:longint;x:byte);//23may2020, 31-DEC-2006
var
   c:longint;
begin
try
//check
if not sys_initcrc32 then low__initcrc32;
//get
c:=_crc32 xor crc_against;//was $ffffffff;
c:=sys_crc32[(c xor byte(x)) and $ff] xor (c shr 8);
_crc32:=c xor crc_against;//was $ffffffff;
except;end;
end;

procedure low__crc32(var _crc32:longint;x:tstr8;s,f:longint);//27mar2007: updated, 31dec2006
label
   skipend;
var//Industry standard CRC-32 -> PASSED, Sunday 31dec2006
   p,xlen:longint;
begin
try
//defaults
_crc32:=0;

//check
if (not str__lock(@x)) or (x.count<=0) then goto skipend else xlen:=x.count;

//init
if not sys_initcrc32 then low__initcrc32;

//range
s:=frcrange32(s,1,xlen);
f:=frcrange32(f,s,xlen);

//get
for p:=s to f do low__crc32inc(_crc32,x.bytes1[p]);

skipend:
except;end;
//free
str__uaf(@x);
end;

function low__crc32c(x:tstr8;s,f:longint):longint;
begin
result:=0;
if str__lock(@x) then low__crc32(result,x,s,f);
str__uaf(@x);
end;

function low__crc32b(x:tstr8):longint;
begin
result:=0;
if str__lock(@x) then low__crc32(result,x,1,x.count);
str__uaf(@x);
end;

function low__crc32nonzero(x:tstr8):longint;//02SEP2010
begin
if str__lock(@x) and (x.count>=1) then
   begin
   result:=low__crc32b(x);
   if (result=0) then result:=1;
   end
else result:=0;//only zero if "z=''" else non-zero, always

str__uaf(@x);
end;

function low__crc32seedable(x:tstr8;xseed:longint):longint;//14jan2018
label
   skipend;
var
   xref:array[0..255] of longint;
   k,n,c:longint;
begin
//defaults
result:=0;//only zero if "z=''" else non-zero, always

try
//check
if zznil(x,2196) or (x.count<=0) then goto skipend;
if (xseed=0) then xseed:=crc_seed;//industry standard seed value
//init
for n:=0 to 255 do
begin
c:=n;
for k:=0 to 7 do if boolean(c and 1) then c:=xseed xor (c shr 1) else c:=c shr 1;
xref[n]:=c;
end;//n
//get
for n:=1 to x.count do
begin
c:=result xor crc_against;//was $ffffffff;
c:=xref[(c xor x.bytes1[n]) and $ff] xor (c shr 8);
result:=c xor crc_against;//was $ffffffff;
end;//n
skipend:
except;end;
try;str__autofree(@x);except;end;
end;

function crc32__createseed(var x:tseedcrc32;xseed:longint):boolean;//21aug2025
var
   p,n:longint;
begin

//pass-thru
result :=true;

//init
if (xseed=0) then xseed:=crc_seed;//use industry standard seed value

//get
for n:=0 to 255 do
begin

x.val     :=n;

for p:=0 to 7 do if boolean(x.val and 1) then x.val:=xseed xor (x.val shr 1) else x.val:=x.val shr 1;

x.ref[n] :=x.val;

end;//p

//set
x.xresult:=0;

end;

function crc32__encode(var x:tseedcrc32;xdata:tstr8):longint;//21aug2025
var
   p:longint;
begin

//defaults
result:=0;

//get
if str__lock(@xdata) then
   begin

   for p:=0 to (xdata.count-1) do
   begin

   x.val     :=x.xresult xor crc_against;//was $ffffffff;
   x.val     :=x.ref[ (x.val xor xdata.bytes[p]) and $ff ] xor (x.val shr 8);
   x.xresult :=x.val xor crc_against;//was $ffffffff;

   end;//p

   end;

//set
result:=x.xresult;

//free
str__uaf(@xdata);

end;//n


//simple message procs ---------------------------------------------------------

function showhandle:longint;
begin
result:=app__mainformHandle;
end;

function showquery(const x:string):boolean;//03oct2025
begin
result:=(mbrYes=win____MessageBox(showhandle,pchar(x),pchar('Query'),mbWarning+MB_YESNO));
end;

function showYNC(const x:string):byte;
begin

case win____messagebox(showhandle,pchar(x),pchar('Important'),mbWarning+MB_YESNOCANCEL) of
2   :result:=llc;
1,6 :result:=lly;
7   :result:=lln;
else result:=llc;
end;//case

end;

function showbasic(const x:string):boolean;//18jun2025
begin
result:=showtext2(x,2);
end;

function showtext(const x:string):boolean;//12jun2025
begin
result:=showtext2(x,2);
end;

function showtext2(const x:string;xsec:longint):boolean;//26apr2025
begin
result:=true;

try
{$ifdef gui}
low__closelock;
win____MessageBox(showhandle,pchar(x),pchar('Information'),$00000000+$40);//better for testing
//win____MessageBox(app__activehandle,pchar(x),'Information',$00000000+$40);
try;low__closeunlock;except;end;
{$endif}
except;end;
end;

function showlow(const x:string):boolean;
begin
result:=true;

try
{$ifdef gui}
low__closelock;
win____messagebox(showhandle,pchar(x),pchar('Information'),$00000000+$40);
try;low__closeunlock;except;end;
{$endif}
except;end;
end;

function showerror(const x:string):boolean;
begin
result:=showerror2(x,5);
end;

function showerror2(const x:string;xsec:longint):boolean;//08oct2025
begin
result:=true;

try
{$ifdef gui}
low__closelock;
win____messagebox(showhandle,pchar(x),pchar('Error'),$00000000+$10);
try;low__closeunlock;except;end;
{$endif}
except;end;
end;


//area procs -------------------------------------------------------------------

{$ifdef gui3}
function low__shiftarea(xarea:twinrect;xshiftx,xshifty:longint):twinrect;//always shift
begin
result:=low__shiftarea2(xarea,xshiftx,xshifty,false);
end;

function low__shiftarea2(xarea:twinrect;xshiftx,xshifty:longint;xvalidcheck:boolean):twinrect;//xvalidcheck=true=shift only if valid area, false=shift always
begin
result:=xarea;

if (not xvalidcheck) or validarea(xarea) then
   begin
   try
   inc(result.left,xshiftx);
   inc(result.right,xshiftx);
   inc(result.top,xshifty);
   inc(result.bottom,xshifty);
   except;end;
   end;
end;

function area__within(const z:twinrect;const x,y:longint):boolean;
begin
result:=(z.left<=z.right) and (z.top<=z.bottom) and (x>=z.left) and (x<=z.right) and (y>=z.top) and (y<=z.bottom);
end;

function area__grow(const x:twinrect;const xby:longint):twinrect;//07apr2021
begin
result.left    :=x.left  -xby;
result.right   :=x.right +xby;
result.top     :=x.top   -xby;
result.bottom  :=x.bottom+xby;
end;

function area__grow2(const x:twinrect;const xby,yby:longint):twinrect;//14jul2025
begin
result.left    :=x.left  -xby;
result.right   :=x.right +xby;
result.top     :=x.top   -yby;
result.bottom  :=x.bottom+yby;
end;
{$endif}

function area__make(const xleft,xtop,xright,xbottom:longint):twinrect;
begin
result.left   :=xleft;
result.top    :=xtop;
result.right  :=xright;
result.bottom :=xbottom;
end;

function nilrect:twinrect;
begin
result:=area__make(0,0,-1,-1);
end;

function nilarea:twinrect;//25jul2021
begin
result:=area__make(0,0,-1,-1);
end;

function maxarea:twinrect;//02dec2023, 27jul2021
const
   xvoid=100000;//100k
begin//allow for graphics sub-procs to have room with their maths -> don't push it too near to "max32-1" - 28jul2021
result:=area__make(0,0,max32-xvoid,max32-xvoid);//allow numeric void
end;

function validarea(x:twinrect):boolean;//26jul2021
begin
result:=(x.left<=x.right) and (x.top<=x.bottom);
end;


//multi-monitor procs ----------------------------------------------------------

function app__monitorProc(unnamedParam1:HMONITOR;unnamedParam2:HDC;unnamedParam3:pwinrect;unnamedParam4:LPARAM):lresult; stdcall;//26sep2025, 26nov2024
var
   m:tmonitorinfoex;
   i:longint;
   v,v2:dword;

   function mprimary:boolean;
   begin
   result:=(0 in tint4(m.dwFlags).bits);
   end;
begin
//OK -> continue receiving data
result:=1;

{$ifdef gui}
try

if win__ok(vwin2____GetMonitorInfo) then
   begin
   //init
   low__cls(@m,sizeof(m));
   m.cbSize:=sizeof(m);

   //get
   if (0<>win2____GetMonitorInfo(unnamedParam1,@m)) then
      begin

      i:=system_monitors_count;
      if (i<=high(system_monitors_area)) then
         begin

         system_monitors_hmonitor[i] :=unnamedParam1;
         system_monitors_area[i]     :=m.rcMonitor;
         system_monitors_workarea[i] :=m.rcWork;
         system_monitors_primary[i]  :=mprimary;
         system_monitors_count:=i+1;

         //zero based
         dec(system_monitors_area[i].right);
         dec(system_monitors_area[i].bottom);
         dec(system_monitors_workarea[i].right);
         dec(system_monitors_workarea[i].bottom);

         //scale
         if (0<>win2____GetDpiForMonitor(unnamedParam1,0,v,v2)) then v:=100;
         system_monitors_scale[i]:=v;//not sure but perhaps: 140=> [140]/96 = 1.45 (150%) and [120]/96=1.25 (125%) etc...

         end;

      end;

   end;//if
except;end;
{$endif}

end;

procedure monitors__sync;//06jan2025, 26nov2024
label
   skipend;
var
   p:longint;
begin
{$ifdef gui}

//get list of monitor areas & workareas ----------------------------------------

//clear
system_monitors_primaryindex  :=0;
system_monitors_count         :=0;
system_monitors_totalarea     :=area__make(0,0,0,0);
system_monitors_totalworkarea :=area__make(0,0,0,0);

//get
if win__ok(vwin2____GetMonitorInfo) and win__ok(vwin2____EnumDisplayMonitors) then
   begin

   win2____EnumDisplayMonitors(0, nil, @app__monitorProc, 0);

   end;


//fallback -> something went wrong or the OS doesn't support the api procs, e.g. Windows 95
if (system_monitors_count<=0) then
   begin

   system_monitors_hmonitor[0] :=0;
   system_monitors_area[0]     :=area__make(0,0,win____getsystemmetrics(SM_CXSCREEN_primarymonitor),win____getsystemmetrics(SM_CYSCREEN_primarymonitor));//fixed for Win95 -> win95 doesn't support "SM_CXVIRTUALSCREEN" or "SM_CYVIRTUALSCREEN" - 06jan2025
   win____systemparametersinfo(SPI_GETWORKAREA,0,@system_monitors_workarea[0],0);
   system_monitors_primary[0]  :=true;
   system_monitors_count:=1;

   //zero based
   dec(system_monitors_area[0].right);
   dec(system_monitors_area[0].bottom);
   dec(system_monitors_workarea[0].right);
   dec(system_monitors_workarea[0].bottom);

   end;

//sync -------------------------------------------------------------------------

//init
system_monitors_totalarea     :=system_monitors_area[0];
system_monitors_totalworkarea :=system_monitors_workarea[0];

//get
for p:=0 to (system_monitors_count-1) do
begin

if system_monitors_primary[p] then system_monitors_primaryindex:=p;

//.totalarea
if (system_monitors_area[p].left<system_monitors_totalarea.left)     then system_monitors_totalarea.left:=system_monitors_area[p].left;
if (system_monitors_area[p].right>system_monitors_totalarea.right)   then system_monitors_totalarea.right:=system_monitors_area[p].right;
if (system_monitors_area[p].top<system_monitors_totalarea.top)       then system_monitors_totalarea.top:=system_monitors_area[p].top;
if (system_monitors_area[p].bottom>system_monitors_totalarea.bottom) then system_monitors_totalarea.bottom:=system_monitors_area[p].bottom;

//.totalworkarea
if (system_monitors_workarea[p].left<system_monitors_totalworkarea.left)     then system_monitors_totalworkarea.left:=system_monitors_workarea[p].left;
if (system_monitors_workarea[p].right>system_monitors_totalworkarea.right)   then system_monitors_totalworkarea.right:=system_monitors_workarea[p].right;
if (system_monitors_workarea[p].top<system_monitors_totalworkarea.top)       then system_monitors_totalworkarea.top:=system_monitors_workarea[p].top;
if (system_monitors_workarea[p].bottom>system_monitors_totalworkarea.bottom) then system_monitors_totalworkarea.bottom:=system_monitors_workarea[p].bottom;

end;//p


{$else}
system_monitors_hmonitor[0]   :=0;
system_monitors_area[0]       :=area__make(0,0,640-1,480-1);
system_monitors_workarea[0]   :=system_monitors_area[0];
system_monitors_primary[0]    :=true;
system_monitors_count         :=1;

system_monitors_totalarea     :=system_monitors_area[0];
system_monitors_totalworkarea :=system_monitors_workarea[0];
{$endif}

end;

function monitors__count:longint;
begin
result:=system_monitors_count;
end;

function monitors__primaryindex:longint;
begin
result:=system_monitors_primaryindex;
end;

procedure monitors__info(xindex:longint);
begin
xindex:=frcrange32(xindex,0,frcmin32(system_monitors_count-1,0));
showtext(
'Monitor Information'+rcode+
'index: '+k64(xindex)+rcode+
'width: '+k64(system_monitors_area[xindex].right-system_monitors_area[xindex].left+1)+rcode+
'height: '+k64(system_monitors_area[xindex].bottom-system_monitors_area[xindex].top+1)+rcode+
'primary: '+low__yes(system_monitors_primary[xindex])+rcode+
'area.x: '+k64(system_monitors_area[xindex].left)+'..'+k64(system_monitors_area[xindex].right)+rcode+
'area.y: '+k64(system_monitors_area[xindex].top)+'..'+k64(system_monitors_area[xindex].bottom)+rcode+
'');
end;

function monitors__dpiAwareV2:boolean;
begin
result:=system_monitors_dpiAwareV2;
end;

function monitors__scale(xindex:longint):longint;//27nov2024
begin
result:=system_monitors_scale[frcrange32(xindex,0,frcmin32(system_monitors_count-1,0))];
end;

function monitors__area(xindex:longint):twinrect;
begin
result:=system_monitors_area[frcrange32(xindex,0,frcmin32(system_monitors_count-1,0))];
end;

function monitors__workarea(xindex:longint):twinrect;
begin
result:=system_monitors_workarea[frcrange32(xindex,0,frcmin32(system_monitors_count-1,0))];
end;

function monitors__totalarea:twinrect;
begin
result:=system_monitors_totalarea;
end;

function monitors__totalworkarea:twinrect;
begin
result:=system_monitors_totalworkarea;
end;

function monitors__primaryarea:twinrect;
begin
result:=monitors__area(system_monitors_primaryindex);
end;

function monitors__primaryworkarea:twinrect;
begin
result:=monitors__workarea(system_monitors_primaryindex);
end;

function monitors__workarea_auto(xindex:longint):twinrect;
begin
if gui__vimultimonitor then result:=monitors__totalworkarea else result:=monitors__workarea(xindex);
end;

function monitors__area_auto(xindex:longint):twinrect;
begin
if gui__vimultimonitor then result:=monitors__totalarea else result:=monitors__area(xindex);
end;

function monitors__centerINarea_auto(sw,sh,xindex:longint;xworkarea:boolean):twinrect;
var
   a:twinrect;
begin
result:=area__make(0,0,sw-1,sh-1);

try
{$ifdef gui}
if xworkarea then
   begin
   if gui__vimultimonitor then a:=monitors__totalworkarea else a:=monitors__workarea(xindex);
   end
else
   begin
   if gui__vimultimonitor then a:=monitors__totalarea else a:=monitors__area(xindex);
   end;
{$else}
a:=monitors__totalworkarea;
{$endif}

result.left   :=a.left+(((a.right-a.left+1)-sw) div 2);
result.right  :=result.left+sw-1;
result.top    :=a.top +(((a.bottom-a.top+1)-sh) div 2);
result.bottom :=result.top+sh-1;
except;end;
end;

function monitors__findBYarea(s:twinrect):longint;
var
   la,da,p:longint;
begin
//defaults
result:=system_monitors_primaryindex;

//check
if (s.right<s.left) or (s.bottom<s.top) then exit;

try
//find largest window area on a monitor
la:=0;
for p:=0 to (system_monitors_count-1) do
begin
if (s.left<=system_monitors_area[p].right) and (s.right>=system_monitors_area[p].left) and (s.top<=system_monitors_area[p].bottom) and (s.bottom>=system_monitors_area[p].top) then da:=(frcmax32(s.right,system_monitors_area[p].right)-frcmin32(s.left,system_monitors_area[p].left)+1) * (frcmax32(s.bottom,system_monitors_area[p].bottom)-frcmin32(s.top,system_monitors_area[p].top)+1) else da:=0;
if (da>la) then
   begin
   result:=p;
   la:=da;
   end;
end;//p
except;end;
end;

function monitors__findBYpoint(s:tpoint):longint;
begin
result:=monitors__findBYarea(area__make(s.x,s.y,s.x,s.y));
end;

function monitors__findBYcursor:longint;
var
   s:tpoint;
begin
win____getcursorpos(s);
result:=monitors__findBYarea(area__make(s.x,s.y,s.x,s.y));
end;

function monitors__areawidth_auto(xindex:longint):longint;
var
   a:twinrect;
begin
a:=monitors__area_auto(xindex);
result:=a.right-a.left+1;
end;

function monitors__areaheight_auto(xindex:longint):longint;
var
   a:twinrect;
begin
a:=monitors__area_auto(xindex);
result:=a.bottom-a.top+1;
end;

function monitors__workareawidth_auto(xindex:longint):longint;
var
   a:twinrect;
begin
a:=monitors__workarea_auto(xindex);
result:=a.right-a.left+1;
end;

function monitors__workareaheight_auto(xindex:longint):longint;
var
   a:twinrect;
begin
a:=monitors__workarea_auto(xindex);
result:=a.bottom-a.top+1;
end;

function monitors__screenwidth_auto:longint;
var
   a:twinrect;
begin
a:=monitors__area_auto(gui__sysprogram_monitorindex);
result:=a.right-a.left+1;
end;

function monitors__screenheight_auto:longint;
var
   a:twinrect;
begin
a:=monitors__area_auto(gui__sysprogram_monitorindex);
result:=a.bottom-a.top+1;
end;

function monitors__workareatotalwidth:longint;
begin
result:=system_monitors_totalworkarea.right-system_monitors_totalworkarea.left+1;
end;

function monitors__workareatotalheight:longint;
begin
result:=system_monitors_totalworkarea.bottom-system_monitors_totalworkarea.top+1;
end;

function monitors__areatotalwidth:longint;
begin
result:=system_monitors_totalarea.right-system_monitors_totalarea.left+1;
end;

function monitors__areatotalheight:longint;
begin
result:=system_monitors_totalarea.bottom-system_monitors_totalarea.top+1;
end;


//sound procs ------------------------------------------------------------------

function snd__onmessage_mm(m,w,l:longint):longint;
begin
result:=0;
end;

function snd__onmessage_wave(m,w,l:longint):longint;
begin
result:=0;
end;


//gui support ------------------------------------------------------------------
function gui__vimultimonitor:boolean;
begin
{$ifdef gui}result:=vimultimonitor;{$else}result:=false;{$endif}
end;

function gui__sysprogram_monitorindex:longint;
begin
{$ifdef gui}result:=system_monitorindex;{$else}result:=0;{$endif}
end;

procedure gui__zoom(var aw,ah:longint);
begin
aw:=aw*vizoom;
ah:=ah*vizoom;
end;


//## ttbt ######################################################################
function low__encrypt(s:tstr8;xpass:string;xpower:longint;xencrypt:boolean;var e:string):boolean;
var
   d:tstr8;
begin
//defaults
result:=false;

try
e:=gecTaskfailed;
d:=nil;
//init
d:=str__new8;
//get
if low__encrypt2(s,d,xpass,xpower,xencrypt,e) then
   begin
   e:=gecOutOfMemory;
   s.clear;
   result:=s.add(d);
   end
else s.clear;//13jun2022
except;end;
try;str__free(@d);except;end;
end;

function low__encrypt2(s,d:tstr8;xpass:string;xpower:longint;xencrypt:boolean;var e:string):boolean;
var
   a:ttbt;
begin
//defaults
result:=false;

try
e:=gecTaskfailed;
a:=nil;
//range
if (xpower<2) then xpower:=1000;//max power
xpower:=frcrange32(xpower,2,1000);
//check
if low__true2(str__lock(@s),str__lock(@d)) then
   begin
   a:=ttbt.create;
   a.password:=xpass;
   a.power:=xpower;
   if xencrypt then
      begin
      if (xpower=1000) then result:=a.encode(s,d,e) else result:=a.encode4(s,d,e);
      end
   else result:=a.decode(s,d,e);
   end;
except;end;
try
freeobj(@a);
str__uaf(@s);
str__uaf(@d);
except;end;
end;

function low__encryptRETAINONFAIL(s:tstr8;xpass:string;xpower:longint;xencrypt:boolean;var e:string):boolean;//14nov20223
label
   skipend;
var
   s2,d:tstr8;
begin
//defaults
result:=false;

try
e:=gecTaskfailed;
d:=nil;
s2:=nil;
//init
s2:=str__new8;
d:=str__new8;
if not s2.add(s) then goto skipend;
//get
if low__encrypt2(s2,d,xpass,xpower,xencrypt,e) then
   begin
   e:=gecOutOfMemory;
   s2.clear;
   s.clear;
   result:=s.add(d);
   end;
skipend:
except;end;
try
str__free(@s2);
str__free(@d);
except;end;
end;

constructor ttbt.create;
var
   p:integer;
begin
//self
if classnameis('ttbt') then track__inc(satTBT,1);
inherited create;
//controls

//defaults
obreath:=true;//02mar2015
ipower:=1000;//8,000 bits(max), range 2..1000
ipassword:='';
ikey:='';
ikeyrandom:='';
ikeymodified:=true;
end;

destructor ttbt.destroy;
begin
try
//controls

//self
inherited destroy;
if classnameis('ttbt') then track__inc(satTBT,-1);
except;end;
end;

procedure ttbt.setpassword(x:string);
begin
if low__setstr(ipassword,x) then ikeymodified:=true;
end;

procedure ttbt.setpower(x:integer);
begin
if low__setint(ipower,frcrange32(x,2,1000)) then ikeymodified:=true;
end;

function ttbt.keyinit:boolean;
label
   skipend;
const
   klimit=1000;
var
   maxp,p:longint;
   k,x,j:tstr8;
   v:byte;
begin
//defaults
result:=false;

try
k:=nil;
x:=nil;
j:=nil;
//check
if not ikeymodified then
   begin
   result:=true;
   exit;
   end;
//init
k:=str__new8;
x:=str__new8;
j:=str__new8;


//PASSWORD KEY
//.password
x.text:=strcopy1(ipassword,1,klimit);
if (x.len<2) then x.text:=strcopy1(x.text+'O3ksiaAlkasdr',1,klimit);//13jun2022
//.fill
repeat
//..get
if not frs(x,j,tbtFeedback) then goto skipend;
//..set
k.add(x);//was: k:=k+x;
x.replace:=k;//was: x:=k;
until (k.len>=klimit);
//.trim to "klimit"
if (k.len>klimit) then k.setlen(klimit);//was: k:=strcopy1(k,1,klimit);
//.finalise
if not frs(k,j,tbtFeedback) then goto skipend;
//.set
ikey:=k.text;

//RANDOM KEY
//.setup
x.clear;
k.clear;
j.clear;
maxp:=frcrange32(ipower,2,klimit);
//.random
for p:=1 to maxp do
begin
v:=random(256);
if (v=5) then v:=13+random(65)
else if (v=79) then v:=random(19)+100
else if (v=201) then v:=9+random(200);
x.addbyt1(v);//was: x:=x+chr(v);
end;//p
//.fill
repeat
//..get
if not frs(x,j,tbtFeedback) then goto skipend;
//..set
k.add(x);//was: k:=k+x;
x.replace:=k;//was: x:=k;
until (k.len>=klimit);
//.trim to "klimit"
if (k.len>klimit) then k.setlen(klimit);//was: k:=strcopy1(k,1,klimit);
//.finalise
if not frs(k,j,tbtFeedback) then goto skipend;
//.set
ikeyrandom:=k.text;
//successful
ikeymodified:=false;
result:=true;
skipend:
except;end;
try
str__free(@k);
str__free(@x);
str__free(@j);
except;end;
end;

function ttbt.frs(s,d:tstr8;m:byte):boolean;//feedback randomisation of string - 16sep2017, 16nov2016
label
   skipend;
var//New and improved: OLD ~20Mb/sec, NEW ~33Mb/sec => 65% faster
   slen,dlen,o1,r1,r2,r3,x1,x2,x3,y1,y2,y3,p:longint;
begin
//defaults
result:=false;

try
if not low__true2(str__lock(@s),str__lock(@d)) then goto skipend;
//init
slen:=s.len;
dlen:=d.len;
//check
if (slen<2) then goto skipend;
//init
o1:=s.pbytes[0];//13jun2022
//get
for p:=1 to slen do
begin
//..r1-r3
//was: r1:=sref[p];
//was: if (p<slen) then r2:=sref[p+1] else r2:=o1;
//was:if (p>1) then r3:=sref[p-1] else r3:=0;
r1:=s.pbytes[p-1];
if (p<slen) then r2:=s.pbytes[p] else r2:=o1;
if (p>1) then r3:=s.pbytes[p-2] else r3:=0;
//..y1-y3
y1:=r1 div 16;
y2:=r2 div 16;
y3:=r3 div 16;
//..x1-x3
x1:=r1-y1*16;
x2:=r2-y2*15;//* - throws random rounding
x3:=r3-y3*16;
//..set
//was: sref[p]:=((x1+x3)+(y2*16)+3) mod 256;//s[p]
//was: if (p<slen) then sref[p+1]:=(x2+(x1*4+x3*2)) mod 256;//s[p+1]
s.pbytes[p-1]:=((x1+x3)+(y2*16)+3) mod 256;//s[p]
if (p<slen) then s.pbytes[p]:=(x2+((x1*4)+(x3*2))) mod 256;//s[p+1]
end;//p
//mode
if (m<>tbtFeedback) and (dlen>=1) and (dlen<=slen) then
   begin
   //.Was This:
   //if (m=tbtEncode)      then for p:=1 to dlen do dref[p]:=(sref[p]+dref[p]) mod 256
   //else if (m=tbtDecode) then for p:=1 to dlen do dref[p]:=(dref[p]-sref[p]) mod 256;

   //.But Now Is: -> Note the new "byte(...)" boundary that protects against "negative values"
   // and therefore prevents exceptions from happening - 16sep2017
   //was: if (m=tbtEncode)      then for p:=1 to dlen do dref[p]:=byte((sref[p]+dref[p]) mod 256)
   //was: else if (m=tbtDecode) then for p:=1 to dlen do dref[p]:=byte((dref[p]-sref[p]) mod 256);
   if (m=tbtEncode)      then for p:=1 to dlen do d.pbytes[p-1]:=byte((s.pbytes[p-1]+d.pbytes[p-1]) mod 256)
   else if (m=tbtDecode) then for p:=1 to dlen do d.pbytes[p-1]:=byte((d.pbytes[p-1]-s.pbytes[p-1]) mod 256);
   end;
//successful
result:=true;
skipend:
except;end;
try
str__uaf(@s);
str__uaf(@d);
except;end;
end;

function ttbt.keyid(x:tstr8;var id:integer):boolean;
var
   xlen,tmp,p:integer;
   v:byte;
begin
//defaults
result:=false;

try
id:=0;
tmp:=0;
//check
if not str__lock(@x) then exit;
//setup
xlen:=x.len;
tmp:=xlen;
//get
for p:=1 to xlen do
begin
//was: v:=byte(x[p]);
v:=x.pbytes[p-1];
inc(tmp,v);
//"even" values:
if (((p div 2)*2)=p) then
   begin
   if (v<100) then inc(tmp,3)
   else if (v>200) then inc(tmp,357);
   end
else
   begin
   if (v<51) then inc(tmp,71)
   else if (v=93) then inc(tmp,191)
   else if (v=101) then inc(tmp,191)
   else if (v=104) then inc(tmp,191)
   else if (v>130) then inc(tmp,191);
   end;
end;//p
//successful
result:=true;
id:=tmp;
except;end;
try;str__uaf(@x);except;end;
end;

function ttbt.encode(s,d:tstr8;var e:string):boolean;
label
   skipend;
const
   klimit=1000;
var
   i4:tint4;
   cc,sLEN,cs,rc,p:integer;
   tmp,h,j,k,kr:tstr8;
   ref64,ref64b:comp;
begin
//defaults
result:=false;

try
tmp:=nil;
h:=nil;
j:=nil;
k:=nil;
kr:=nil;
//check
if not low__true2(str__lock(@s),str__lock(@d)) then goto skipend;
//init
d.clear;
cs:=0;
sLEN:=s.len;
tmp:=str__new8;
h:=str__new8;
j:=str__new8;
k:=str__new8;
kr:=str__new8;
//init
e:=gecUnexpectedError;
if not keyinit then exit;
k.text:=ikey;
kr.text:=ikeyrandom;
//.offset checksum using keyID (password key)
if not keyid(k,cs) then exit;
rc:=2+random(21);//2..22 (old system was 0..15)
e:=gecOutOfMemory;
ref64:=ms64;
ref64b:=ms64;
//get
//.create header key "encrypt random key (1..12)"
tmp.replace:=kr;
for p:=1 to ((rc div 2)+1) do if not frs(k,tmp,tbtEncode) then goto skipend;
//.feedback randomise "kr"
for p:=1 to rc do if not frs(kr,j,tbtFeedback) then goto skipend;
//.header                    //pos=6,7,8,9=checksum
//was: pushb(dLEN,d,'TBT3'+char(rc)+#0#0#0#0+from32bit(sLEN)+tmp);
d.sadd('TBT3');
d.aadd([rc,0,0,0,0]);
d.addint4(sLEN);
d.add(tmp);
tmp.clear;
//.encrypt
//was: sysstatus(ref64b,sysstatus_encrypt,'Encrypting'+#9+low__percentage64str(1,1,true));//100%
cc:=0;
p:=1;
while true do
begin
//.get
tmp.clear;
tmp.add31(s,p,klimit);//was: tmp:=strcopy1(s,p,klimit);
//.set
if (tmp.len<=0) then break
else
   begin
   //.cs
   inc(cs,tmp.pbytes[0]);//was: inc(cs,byte(tmp[1]));
   //.encode
   if not frs(kr,tmp,tbtEncode) then goto skipend;
   //.store
   d.add(tmp);//was: pushb(dLEN,d,tmp);
   //.breath - 02mar2015
   inc(cc);
   if (cc>=50) then
      begin
      if obreath and (ms64>ref64) then
         begin
         app__processmessages;
         ref64:=ms64+200;
         end;
      //.system status - 04oct2022
{
//was:      if sysstatus(ref64b,sysstatus_encrypt,'Encrypting'+#9+low__percentage64str(p,sLEN,true)) then
         begin
         e:=gecTaskcancelled;
         goto skipend;
         end;
}
      cc:=0;
      end;
   end;
//inc
inc(p,klimit);
end;//loop
//.insert check sum value into header
i4.val:=cs;
//d[6]:=i4.chars[0];
//d[7]:=i4.chars[1];
//d[8]:=i4.chars[2];
//d[9]:=i4.chars[3];
d.pbytes[6-1]:=i4.bytes[0];
d.pbytes[7-1]:=i4.bytes[1];
d.pbytes[8-1]:=i4.bytes[2];
d.pbytes[9-1]:=i4.bytes[3];
//successful
result:=true;
skipend:
except;end;
try
str__free(@tmp);
str__free(@h);
str__free(@j);
str__free(@k);
str__free(@kr);
str__uaf(@s);
str__uaf(@d);
except;end;
end;

function ttbt.encode4(s,d:tstr8;var e:string):boolean;
begin
result:=false;

try
if low__true2(str__lock(@s),str__lock(@d)) then
   begin
   d.clear;
   if encodeLITE4(s,e) then
      begin
      e:=gecOutOfMemory;
      result:=d.add(s);
      end;
   end;
except;end;
try
str__uaf(@s);
str__uaf(@d);
except;end;
end;

function ttbt.encodeLITE4(s:tstr8;e:string):boolean;
label
   skipend;
var
   i4:tint4;
   pw2,cc,sLEN,dLEN,cs,rc,p:integer;
   dHDR,tmp,h,j,k,kr:tstr8;
   pw:twrd2;
   int1:longint;
   ref64,ref64b:comp;
begin
//defaults
result:=false;

try
dHDR:=nil;
tmp:=nil;
h:=nil;
j:=nil;
k:=nil;
kr:=nil;
//check
if not str__lock(@s) then exit;
//init
dHDR:=str__new8;
tmp:=str__new8;
h:=str__new8;
j:=str__new8;
k:=str__new8;
kr:=str__new8;
cs:=0;
slen:=s.len;
dlen:=0;
//init
e:=gecUnexpectedError;
if not keyinit then exit;
pw2:=ipower;
pw.val:=pw2;
k.text:=strcopy1(ikey,1,pw2);
kr.text:=strcopy1(ikeyrandom,1,pw2);
//.offset checksum using keyID (password key)
if not keyid(k,cs) then exit;
rc:=2+random(21);//2..22 (old system was 0..15)
e:=gecOutOfMemory;
//get
//.create header key "encrypt random key (1..12)"
tmp.replace:=kr;
for p:=1 to ((rc div 2)+1) do if not frs(k,tmp,tbtEncode) then goto skipend;
//.feedback randomise "kr"
for p:=1 to rc do if not frs(kr,j,tbtFeedback) then goto skipend;
//.header                    //pos=6,7,8,9=checksum      //length of key (power)
//was: dHDR:='TBT4'+char(rc)+#0#0#0#0+from32bit(sLEN)+pw.chars[0]+pw.chars[1]+tmp;//02JAN2012
dHDR.sadd('TBT4');
dHDR.aadd([rc,0,0,0,0]);
dHDR.addint4(sLEN);
dHDR.aadd([pw.bytes[0],pw.bytes[1]]);
dHDR.add(tmp);//02JAN2012
tmp.clear;
//.encrypt
ref64:=ms64;
ref64b:=ms64;
cc:=0;
p:=1;
//get
//was: sysstatus(ref64b,sysstatus_encrypt,'Encrypting'+#9+low__percentage64str(1,1,true));//100%
while true do
begin
//.get
tmp.clear;
tmp.add31(s,p,pw2);//was: tmp:=strcopy1(s,p,pw2);
//.set
if (tmp.len<=0) then break
else
   begin
   //.cs
   inc(cs,tmp.pbytes[0]);//was: inc(cs,byte(tmp[1]));
   //.encode
   if not frs(kr,tmp,tbtEncode) then goto skipend;
   //.store -> faster than using "push" - 16nov2016
   //was: dref:=pdlbyte1(pchar(tmp));
   //was: for int1:=low__len(tmp) downto 1 do sref[dlen+int1]:=dref[int1];
   //was: inc(dlen,low__len(tmp));
   for int1:=tmp.len downto 1 do s.pbytes[dlen+int1-1]:=tmp.pbytes[int1-1];
   inc(dlen,tmp.len);
   //.breath - 02mar2015
   inc(cc);
   if (cc>=50) then
      begin
      if obreath and (ms64>ref64) then
         begin
         app__processmessages;
         ref64:=ms64+100;
         end;
      //.system status - 04oct2022
{
//was:       if sysstatus(ref64b,sysstatus_encrypt,'Encrypting'+#9+low__percentage64str(p,sLEN,true)) then
         begin
         e:=gecTaskcancelled;
         goto skipend;
         end;
}
      cc:=0;
      end;
   end;
//inc
inc(p,pw2);
end;//loop
//.finalise
if (dlen<>slen) then s.setlen(dlen);
//.insert check sum value into header
i4.val:=cs;
//dHDR[6]:=i4.chars[0];
//dHDR[7]:=i4.chars[1];
//dHDR[8]:=i4.chars[2];
//dHDR[9]:=i4.chars[3];
dHDR.pbytes[6-1]:=i4.bytes[0];
dHDR.pbytes[7-1]:=i4.bytes[1];
dHDR.pbytes[8-1]:=i4.bytes[2];
dHDR.pbytes[9-1]:=i4.bytes[3];
//.insert header before "s"
if not s.ins(dHDR,0) then goto skipend;
//successful
result:=true;
skipend:
except;end;
try
str__free(@dHDR);
str__free(@tmp);
str__free(@h);
str__free(@j);
str__free(@k);
str__free(@kr);
str__uaf(@s);
except;end;
end;

function ttbt.decode(s,d:tstr8;var e:string):boolean;
begin
result:=false;

try
if low__true2(str__lock(@s),str__lock(@d)) then
   begin
   d.clear;
   if decodeLITE(s,e) then
      begin
      e:=gecOutOfMemory;
      result:=d.add(s);
      end;
   end;
except;end;
try
str__uaf(@s);
str__uaf(@d);
except;end;
end;

function ttbt.decodeLITE(s:tstr8;var e:string):boolean;//uses minimal RAM - 02JAN2012
label
   skipend;
const
   klimit=1000;
var
   i4:tint4;
   int1,startpos,klen,v,cc,slen,dlen,cl,cs,rc,p:longint;
   tmp,h,j,k,kr:tstr8;
   v3,v4:boolean;
   pw:twrd2;
   ref64,ref64b:comp;
begin
//defaults
result:=false;

try
e:=gecUnexpectedError;
tmp:=nil;
h:=nil;
j:=nil;
k:=nil;
kr:=nil;
//check
if not str__lock(@s) then exit;
//init
v3:=false;
v4:=false;
cs:=0;
dlen:=0;
slen:=s.len;
startpos:=1;
klen:=0;
if not keyinit then goto skipend;
tmp:=str__new8;
h:=str__new8;
j:=str__new8;
k:=str__new8;
kr:=str__new8;
//get
//.header
e:=gecDataCorrupt;
if      s.asame3(0,[uuT,uuB,uuT,nn4],false) and (sLEN>=15)   then v4:=true
else if s.asame3(0,[uuT,uuB,uuT,nn3],false) and (sLEN>=1013) then v3:=true
else
   begin
   e:=gecUnknownFormat;
   goto skipend;
   end;
//.read
//was: rc:=byte(s[5]);
//was: cs:=to32bit(strcopy1(s,6,4));
//was: cl:=to32bit(strcopy1(s,10,4));
rc:=s.pbytes[5-1];
cs:=s.int4[6-1];
cl:=s.int4[10-1];
if (cs<0) or (cl<0) then goto skipend;
//.version
if v3 then
   begin
   //get
   if ((cl+1013)>sLEN) then goto skipend;
   kr.clear;
   kr.add31(s,14,klimit);//was: kr:=strcopy1(s,14,klimit);
   klen:=kr.len;
   startpos:=1014;
   //check
   if (klen<>klimit) then goto skipend;
   end
else if v4 then
   begin
   //get
   pw.bytes[0]:=s.pbytes[14-1];//was: pw.chars[0]:=s[14];
   pw.bytes[1]:=s.pbytes[15-1];//was: pw.chars[1]:=s[15];
   if (pw.val<2) or (pw.val>1000) then goto skipend;//enforce range of 2..1000 (upto 8000bit)
   if ((cl+pw.val+15)>sLEN) then goto skipend;
   kr.clear;
   kr.add31(s,16,pw.val);//was: kr:=strcopy1(s,16,pw.val);
   klen:=kr.len;
   startpos:=15+klen+1;
   //check
   if (klen<>pw.val) then goto skipend;
   end;
//.keyid
k.text:=strcopy1(ikey,1,klen);
if not keyid(k,v) then exit;
//..cs
e:=gecAccessDenied;
dec(cs,v);
if (cs<0) then goto skipend;
//.recover header key "decrypt random key"
for p:=1 to ((rc div 2)+1) do if not frs(k,kr,tbtDecode) then goto skipend;
//.feedback randomise "kr"
for p:=1 to rc do if not frs(kr,j,tbtFeedback) then goto skipend;
//.decrypt
ref64:=ms64;
ref64b:=ms64;
cc:=0;
p:=startpos;
//was: sysstatus(ref64b,sysstatus_encrypt,'Decrypting'+#9+low__percentage64str(1,1,true));//100%
//get
while true do
begin
//.get
tmp.clear;
tmp.add31(s,p,klen);//was: tmp:=strcopy1(s,p,klen);
//.set
if (tmp.len<=0) then break
else
   begin
   //.decode
   if not frs(kr,tmp,tbtDecode) then goto skipend;
   //.store -> faster than using "push" - 16nov2016
   //was: dref:=pdlbyte1(pchar(tmp));
   //was: for int1:=low__len(tmp) downto 1 do sref[dlen+int1]:=dref[int1];
   //was: inc(dlen,low__len(tmp));
   for int1:=tmp.len downto 1 do s.pbytes[dlen+int1-1]:=tmp.pbytes[int1-1];
   inc(dlen,tmp.len);
   //.cs
   dec(cs,tmp.pbytes[0]);
   if (cs<0) then
      begin
      e:=gecAccessDenied;
      goto skipend;
      end;
   //.stop
   if (dlen>=cl) then break;
   //.breath - 02mar2015
   inc(cc);
   if (cc>=50) then
      begin
      if obreath and (ms64>ref64) then
         begin
         app__processmessages;
         ref64:=ms64+100;
         end;
      //.system status - 04oct2022
{
//was:      if sysstatus(ref64b,sysstatus_encrypt,'Decrypting'+#9+low__percentage64str(p,sLEN,true)) then
         begin
         e:=gecTaskcancelled;
         goto skipend;
         end;
}
      cc:=0;
      end;
   end;
//inc
inc(p,klen);
end;//loop
//.finalise
if (slen<>dlen) then s.setlen(dlen);//was: setlength(s,dlen);
//.check
if (cs<>0) then goto skipend;
//.size/finalise
if (s.len>cl) then s.setlen(cl);//was: setlength(s,cl);
//successful
result:=(s.len=cl);
skipend:
except;end;
try
str__free(@tmp);
str__free(@h);
str__free(@j);
str__free(@k);
str__free(@kr);
str__uaf(@s);
except;end;
end;


end.
