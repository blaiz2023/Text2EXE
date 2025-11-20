unit lwin;

interface
{$ifdef gui4} {$define gui3} {$define jpeg} {$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
{$ifdef gui4}uses classes, controls;{$endif}
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
//## Library.................. 32bit Windows api's (modernised legacy codebase)
//## Version.................. 1.00.1055
//## Items.................... 2
//## Last Updated ............ 05oct2025
//## Lines of Code............ 4,700+
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
//## | win__*                 | Win32 support     | 1.00.855  | 26sep2025   | Dynamic load and management procs for Win32 api calls - 05sep2025, 31aug2025
//## | win____*/win2____      | Win32 general     | 1.00.200  | 05oct2025   | Win32 general api procs for Windows specific features and functionality.  The leading "win____" denotes a Window's API call - subset of Gossamer procs
//## ==========================================================================================================================================================================================================================

type
   UINT          = longint;
   u_char        = char;
   u_short       = word;
   u_int         = integer;
   u_long        = longint;
   tsocket       = u_int;
   MakeIntResource = PAnsiChar;

   pbasic_handle   =^tbasic_handle;
   tbasic_handle   =longint;
   tbasic_message  =cardinal;
   tbasic_wparam   =longint;
   tbasic_lparam   =longint;
   tbasic_lresult  =longint;
   pbasic_pointer  =^tbasic_pointer;
   tbasic_pointer  =longint;

const
   //wincore procs support -----------------------------------------------------

   //dll names
   dnone                                                     =0;
   duser32                                                   =1;
   dshell32                                                  =2;
   dShcore                                                   =3;
   dxinput1_4                                                =4;
   dadvapi32                                                 =5;
   dkernel32                                                 =6;
   dmpr                                                      =7;
   dversion                                                  =8;
   dcomctl32                                                 =9;
   dgdi32                                                    =10;
   dopengl32                                                 =11;
   dwintrust                                                 =12;
   dole32                                                    =13;
   doleaut32                                                 =14;
   dolepro32                                                 =15;
   dwinmm                                                    =16;
   dwsock32                                                  =17;
   dwinspool                                                 =18;
   dcomdlg32                                                 =19;
   dmax                                                      =19;
   dllcount                                                  =dmax;

   //errors
   waOK                                                      =0;
   waBadDLLName                                              =1;
   waBadProcName                                             =2;
   waDLLLoadFail                                             =3;
   waProcNotFound                                            =4;
   waMax                                                     =4;

   //---------------------------------------------------------------------------

   win_ext1  ='d'+'ll';
   win_ext2  ='dr'+'v';
   user32      ='use'+'r32'+'.'+win_ext1;
   shell32     ='sh'+'el'+'l32'+'.'+win_ext1;
   Shcore      ='S'+'hco'+'re'+'.'+win_ext1;
   xinput1_4   ='xin'+'put'+'1_4'+'.'+win_ext1;
   advapi32    ='adv'+'ap'+'i32'+'.'+win_ext1;
   kernel32    ='ke'+'rne'+'l32'+'.'+win_ext1;
   mpr         ='mp'+'r'+'.'+win_ext1;
   version     ='v'+'er'+'si'+'on'+'.'+win_ext1;
   comctl32    ='co'+'mct'+'l32'+'.'+win_ext1;
   comdlg32    ='co'+'mdl'+'g32'+'.'+win_ext1;//04oct2025
   gdi32       ='gd'+'i32'+'.'+win_ext1;
   opengl32    ='open'+'gl32'+'.'+win_ext1;
   wintrust    ='wi'+'ntr'+'ust'+'.'+win_ext1;
   ole32       ='ol'+'e32'+'.'+win_ext1;
   oleaut32    ='olea'+'ut32'+'.'+win_ext1;
   olepro32    ='olep'+'ro32'+'.'+win_ext1;
   winmm       ='win'+'mm'+'.'+win_ext1;
   mmsyst      =winmm;
   winsocket   ='wso'+'ck32'+'.'+win_ext1;
   winspl      ='win'+'s'+'pool'+'.'+win_ext2;//.drv

   MAX_PATH = 260;
   MIIM_STATE = 1;
   MIIM_ID = 2;
   MIIM_SUBMENU = 4;
   MIIM_CHECKMARKS = 8;
   MIIM_TYPE = $10;
   MIIM_DATA = $20;

   OFN_READONLY = $00000001;
   OFN_OVERWRITEPROMPT = $00000002;
   OFN_HIDEREADONLY = $00000004;
   OFN_NOCHANGEDIR = $00000008;
   OFN_SHOWHELP = $00000010;
   OFN_ENABLEHOOK = $00000020;
   OFN_ENABLETEMPLATE = $00000040;
   OFN_ENABLETEMPLATEHANDLE = $00000080;
   OFN_NOVALIDATE = $00000100;
   OFN_ALLOWMULTISELECT = $00000200;
   OFN_EXTENSIONDIFFERENT = $00000400;
   OFN_PATHMUSTEXIST = $00000800;
   OFN_FILEMUSTEXIST = $00001000;
   OFN_CREATEPROMPT = $00002000;
   OFN_SHAREAWARE = $00004000;
   OFN_NOREADONLYRETURN = $00008000;
   OFN_NOTESTFILECREATE = $00010000;
   OFN_NONETWORKBUTTON = $00020000;
   OFN_NOLONGNAMES = $00040000;
   OFN_EXPLORER = $00080000;
   OFN_NODEREFERENCELINKS = $00100000;
   OFN_LONGNAMES = $00200000;

   CC_RGBINIT = $00000001;
   CC_FULLOPEN = $00000002;
   CC_PREVENTFULLOPEN = $00000004;
   CC_SHOWHELP = $00000008;
   CC_ENABLEHOOK = $00000010;
   CC_ENABLETEMPLATE = $00000020;
   CC_ENABLETEMPLATEHANDLE = $00000040;
   CC_SOLIDCOLOR = $00000080;
   CC_ANYCOLOR = $00000100;

{ CHARFORMAT masks }
  CFM_BOLD            = $00000001;
  CFM_ITALIC          = $00000002;
  CFM_UNDERLINE       = $00000004;
  CFM_STRIKEOUT       = $00000008;
  CFM_PROTECTED       = $00000010;
  CFM_LINK            = $00000020;              { Exchange hyperlink extension }
  CFM_SIZE            = $80000000;
  CFM_COLOR           = $40000000;
  CFM_FACE            = $20000000;
  CFM_OFFSET          = $10000000;
  CFM_CHARSET         = $08000000;

{ CHARFORMAT effects }

  CFE_BOLD            = $0001;
  CFE_ITALIC          = $0002;
  CFE_UNDERLINE       = $0004;
  CFE_STRIKEOUT       = $0008;
  CFE_PROTECTED       = $0010;
  CFE_LINK            = $0020;
  CFE_AUTOCOLOR       = $40000000;  { NOTE: this corresponds to CFM_COLOR, }
                                    { which controls it }
  yHeightCharPtsMost  = 1638;

{ EM_SETCHARFORMAT wParam masks }

  SCF_SELECTION       = $0001;
  SCF_WORD            = $0002;
  SCF_DEFAULT         = $0000;          { set the default charformat or paraformat }
  SCF_ALL             = $0004;          { not valid with SCF_SELECTION or SCF_WORD }
  SCF_USEUIRULES      = $0008;          { modifier for SCF_SELECTION; says that }
                                        { the format came from a toolbar, etc. and }
                                        { therefore UI formatting rules should be }
                                        { used instead of strictly formatting the }
                                        { selection. }

   { Predefined Clipboard Formats }
   CF_TEXT          =1;
   CF_BITMAP        =2;
   CF_METAFILEPICT  =3;
   CF_SYLK          =4;
   CF_DIF           =5;
   CF_TIFF          =6;
   CF_OEMTEXT       =7;
   CF_DIB           =8;
   CF_DIBV5         =17;//08jun2025
   CF_PALETTE       =9;
   CF_PENDATA       =10;
   CF_RIFF          =11;
   CF_WAVE          =12;
   CF_UNICODETEXT   =13;
   CF_ENHMETAFILE   =14;
   CF_HDROP         =15;
   CF_LOCALE        =$10;
   CF_MAX           =17;

   CF_OWNERDISPLAY = 128;
   CF_DSPTEXT = 129;
   CF_DSPBITMAP = 130;
   CF_DSPMETAFILEPICT = 131;
   CF_DSPENHMETAFILE = 142;

  {PopupMenu Alignment}
  TPM_LEFTBUTTON = 0;
  TPM_RIGHTBUTTON = 2;
  TPM_LEFTALIGN = 0;
  TPM_CENTERALIGN = 4;
  TPM_RIGHTALIGN = 8;

   { PeekMessage() Options }
   PM_NOREMOVE = 0;
   PM_REMOVE = 1;
   PM_NOYIELD = 2;

   { Success codes }
   S_OK    = $00000000;
   S_FALSE = $00000001;

   NOERROR = 0;

   NULLREGION = 1;

   SYNCHRONIZE              = $00100000;
   STANDARD_RIGHTS_REQUIRED = $000F0000;

   SM_CXSCREEN_primarymonitor       =0;
   SM_CYSCREEN_primarymonitor       =1;
   SM_CXFULLSCREEN_primarymonitor   =16;
   SM_CYFULLSCREEN_primarymonitor   =17;
   SM_CXVIRTUALSCREEN               =78;//total width in px of desktop spanning multiple monitors
   SM_CYVIRTUALSCREEN               =79;//total height in px of desktop spanning multiple monitors
   SM_CMONITORS                     =80;//number of monitors on a desktop

   DISPLAY_DEVICE_ACTIVE            = 1;//DISPLAY_DEVICE_ACTIVE specifies whether a monitor is presented as being "on" by the respective GDI view. Windows Vista: EnumDisplayDevices will only enumerate monitors that can be presented as being "on."
   DISPLAY_DEVICE_PRIMARY_DEVICE    = 4;//The primary desktop is on the device.
   DISPLAY_DEVICE_DISCONNECT        = $2000000;

   //win____getdevicecaps
   DRIVERVERSION = 0;     { Device driver version                     }
   TECHNOLOGY    = 2;     { Device classification                     }
   HORZSIZE      = 4;     { Horizontal size in millimeters            }
   VERTSIZE      = 6;     { Vertical size in millimeters              }
   HORZRES       = 8;     { Horizontal width in pixels                }
   VERTRES       = 10;    { Vertical height in pixels                 }
   BITSPIXEL     = 12;    { Number of bits per pixel                  }
   PLANES        = 14;    { Number of planes                          }
   NUMBRUSHES    = $10;   { Number of brushes the device has          }
   NUMPENS       = 18;    { Number of pens the device has             }
   NUMMARKERS    = 20;    { Number of markers the device has          }
   NUMFONTS      = 22;    { Number of fonts the device has            }
   NUMCOLORS     = 24;    { Number of colors the device supports      }
   PDEVICESIZE   = 26;    { Size required for device descriptor       }
   CURVECAPS     = 28;    { Curve capabilities                        }
   LINECAPS      = 30;    { Line capabilities                         }
   POLYGONALCAPS = $20;   { Polygonal capabilities                    }
   TEXTCAPS      = 34;    { Text capabilities                         }
   CLIPCAPS      = 36;    { Clipping capabilities                     }
   RASTERCAPS    = 38;    { Bitblt capabilities                       }
   ASPECTX       = 40;    { Length of the X leg                       }
   ASPECTY       = 42;    { Length of the Y leg                       }
   ASPECTXY      = 44;    { Length of the hypotenuse                  }

   LOGPIXELSX    = 88;    { Logical pixelsinch in X                  }
   LOGPIXELSY    = 90;    { Logical pixelsinch in Y                  }

   SIZEPALETTE   = 104;   { Number of entries in physical palette     }
   NUMRESERVED   = 106;   { Number of reserved entries in palette     }
   COLORRES      = 108;   { Actual color resolution                   }

  { WM_NCHITTEST and MOUSEHOOKSTRUCT Mouse Position Codes }
   HTERROR = -2;
   HTTRANSPARENT = -1;
   HTNOWHERE = 0;
   HTCLIENT = 1;
   HTCAPTION = 2;
   HTSYSMENU = 3;
   HTGROWBOX = 4;
   HTSIZE = HTGROWBOX;
   HTMENU = 5;
   HTHSCROLL = 6;
   HTVSCROLL = 7;
   HTMINBUTTON = 8;
   HTMAXBUTTON = 9;
   HTLEFT = 10;
   HTRIGHT = 11;
   HTTOP = 12;
   HTTOPLEFT = 13;
   HTTOPRIGHT = 14;
   HTBOTTOM = 15;
   HTBOTTOMLEFT = $10;
   HTBOTTOMRIGHT = 17;
   HTBORDER = 18;
   HTREDUCE = HTMINBUTTON;
   HTZOOM = HTMAXBUTTON;
   HTSIZEFIRST = HTLEFT;
   HTSIZELAST = HTBOTTOMRIGHT;
   HTOBJECT = 19;
   HTCLOSE = 20;
   HTHELP = 21;

   //StretchBlt render modes
   SRCCOPY     = $00CC0020;     { dest = source                    }
   SRCPAINT    = $00EE0086;     { dest = source OR dest            }
   SRCAND      = $008800C6;     { dest = source AND dest           }
   SRCINVERT   = $00660046;     { dest = source XOR dest           }
   SRCERASE    = $00440328;     { dest = source AND (NOT dest )    }
   NOTSRCCOPY  = $00330008;     { dest = (NOT source)              }
   NOTSRCERASE = $001100A6;     { dest = (NOT src) AND (NOT dest)  }
   MERGECOPY   = $00C000CA;     { dest = (source AND pattern)      }
   MERGEPAINT  = $00BB0226;     { dest = (NOT source) OR dest      }
   PATCOPY     = $00F00021;     { dest = pattern                   }
   PATPAINT    = $00FB0A09;     { dest = DPSnoo                    }
   PATINVERT   = $005A0049;     { dest = pattern XOR dest          }
   DSTINVERT   = $00550009;     { dest = (NOT dest)                }
   BLACKNESS   = $00000042;     { dest = BLACK                     }
   WHITENESS   = $00FF0062;     { dest = WHITE                     }

   //DIB color table identifiers
   DIB_RGB_COLORS = 0;//color table in RGBs
   DIB_PAL_COLORS = 1;//color table in palette indices

   ETO_OPAQUE = 2;
   ETO_CLIPPED = 4;
   ETO_GLYPH_INDEX = $10;
   ETO_RTLREADING = $80;
   ETO_IGNORELANGUAGE = $1000;

   CN_BASE                   = $BC00;
   CM_BASE                   = $B000;
   CM_ACTIVATE               = CM_BASE + 0;
   CM_DEACTIVATE             = CM_BASE + 1;
   CM_RECREATEWND            = CM_BASE + 51;
   CM_INVALIDATE             = CM_BASE + 52;
   CM_SYSFONTCHANGED         = CM_BASE + 53;
   CM_CONTROLCHANGE          = CM_BASE + 54;
   CM_CHANGED                = CM_BASE + 55;
   CM_APPKEYDOWN             = CM_BASE + 22;
   CM_APPSYSCOMMAND          = CM_BASE + 23;

   SF_TEXT             = $0001;
   SF_RTF              = $0002;
   SF_RTFNOOBJS        = $0003;          { outbound only }
   SF_TEXTIZED         = $0004;          { outbound only }
   SF_UNICODE          = $0010;          { Unicode file of some kind }

   WM_USER             =$0400;//anything below this is reserved

  { RedrawWindow() flags }
  RDW_INVALIDATE = 1;
  RDW_INTERNALPAINT = 2;
  RDW_ERASE = 4;
  RDW_VALIDATE = 8;
  RDW_NOINTERNALPAINT = $10;
  RDW_NOERASE = $20;
  RDW_NOCHILDREN = $40;
  RDW_ALLCHILDREN = $80;
  RDW_UPDATENOW = $100;
  RDW_ERASENOW = $200;
  RDW_FRAME = $400;
  RDW_NOFRAME = $800;

   { Edit control EM_SETMARGIN parameters }
   EC_LEFTMARGIN = 1;
   EC_RIGHTMARGIN = 2;
   EC_USEFONTINFO = 65535;

   EM_LIMITTEXT           = $00C5;
   EM_SETREADONLY         = $00CF;
   EM_GETLIMITTEXT                     = WM_USER + 37;
//  EM_POSFROMCHAR                      = WM_USER + 38;
//  EM_CHARFROMPOS                      = WM_USER + 39;
   EM_SCROLLCARET                      = WM_USER + 49;
   EM_CANPASTE                         = WM_USER + 50;
   EM_CANUNDO             = $00C6;
   EM_UNDO                = $00C7;
   EM_SETPASSWORDCHAR     = $00CC;
   EM_DISPLAYBAND                      = WM_USER + 51;
   EM_EXGETSEL                         = WM_USER + 52;
   EM_EXLIMITTEXT                      = WM_USER + 53;
   EM_EXLINEFROMCHAR                   = WM_USER + 54;
   EM_EXSETSEL                         = WM_USER + 55;
   EM_FINDTEXT                         = WM_USER + 56;
   EM_FORMATRANGE                      = WM_USER + 57;
   EM_GETCHARFORMAT                    = WM_USER + 58;
   EM_GETEVENTMASK                     = WM_USER + 59;
   EM_GETOLEINTERFACE                  = WM_USER + 60;
   EM_GETPARAFORMAT                    = WM_USER + 61;
   EM_GETSELTEXT                       = WM_USER + 62;
   EM_HIDESELECTION                    = WM_USER + 63;
   EM_PASTESPECIAL                     = WM_USER + 64;
   EM_REQUESTRESIZE                    = WM_USER + 65;
   EM_SELECTIONTYPE                    = WM_USER + 66;
   EM_SETBKGNDCOLOR                    = WM_USER + 67;
   EM_SETCHARFORMAT                    = WM_USER + 68;
   EM_SETEVENTMASK                     = WM_USER + 69;
   EM_SETOLECALLBACK                   = WM_USER + 70;
   EM_SETPARAFORMAT                    = WM_USER + 71;
   EM_SETTARGETDEVICE                  = WM_USER + 72;
   EM_STREAMIN                         = WM_USER + 73;
   EM_STREAMOUT                        = WM_USER + 74;
   EM_GETTEXTRANGE                     = WM_USER + 75;
   EM_FINDWORDBREAK                    = WM_USER + 76;
   EM_SETOPTIONS                       = WM_USER + 77;
   EM_GETOPTIONS                       = WM_USER + 78;
   EM_FINDTEXTEX                       = WM_USER + 79;
   EM_GETWORDBREAKPROCEX               = WM_USER + 80;
   EM_SETWORDBREAKPROCEX               = WM_USER + 81;
 { Richedit v2.0 messages }
   EM_GETSEL              = $00B0;
   EM_SETSEL              = $00B1;
   EM_SETUNDOLIMIT                     = WM_USER + 82;
   EM_REDO                             = WM_USER + 84;
   EM_CANREDO                          = WM_USER + 85;
   EM_GETUNDONAME                      = WM_USER + 86;
   EM_GETREDONAME                      = WM_USER + 87;
   EM_STOPGROUPTYPING                  = WM_USER + 88;
   EM_SETTEXTMODE                      = WM_USER + 89;
   EM_GETTEXTMODE                      = WM_USER + 90;
 { Edit Control Notification Codes }
   EN_SETFOCUS  = $0100;
   EN_KILLFOCUS = $0200;
   EN_CHANGE    = $0300;
   EN_UPDATE    = $0400;
   EN_ERRSPACE  = $0500;
   EN_MAXTEXT   = $0501;
   EN_HSCROLL   = $0601;
   EN_VSCROLL   = $0602;

 { for use with EM_GET/SETTEXTMODE }

   TM_PLAINTEXT                       = 1;
   TM_RICHTEXT                        = 2;     { default behavior }
   TM_SINGLELEVELUNDO                 = 4;
   TM_MULTILEVELUNDO                  = 8;     { default behavior }
   TM_SINGLECODEPAGE                  = 16;
   TM_MULTICODEPAGE                   = 32;    { default behavior }

   EM_AUTOURLDETECT                    = WM_USER + 91;
   EM_GETAUTOURLDETECT                 = WM_USER + 92;
   EM_SETPALETTE                       = WM_USER + 93;
   EM_GETTEXTEX                        = WM_USER + 94;
   EM_GETTEXTLENGTHEX                  = WM_USER + 95;

   CF_RTF                              = 'Rich Text Format';
   CF_RTFNOOBJS                        = 'Rich Text Format Without Objects';
   CF_RETEXTOBJ                        = 'RichEdit Text and Objects';


  { Standard Cursor IDs }
  IDC_ARROW = MakeIntResource(32512);
  IDC_IBEAM = MakeIntResource(32513);

  { Stock Logical Objects }
  WHITE_BRUSH = 0;
  LTGRAY_BRUSH = 1;
  GRAY_BRUSH = 2;
  DKGRAY_BRUSH = 3;
  BLACK_BRUSH = 4;
  NULL_BRUSH = 5;
  HOLLOW_BRUSH = NULL_BRUSH;
  WHITE_PEN = 6;
  BLACK_PEN = 7;
  NULL_PEN = 8;
  OEM_FIXED_FONT = 10;
  ANSI_FIXED_FONT = 11;
  ANSI_VAR_FONT = 12;
  SYSTEM_FONT = 13;
  DEVICE_DEFAULT_FONT = 14;
  DEFAULT_PALETTE = 15;
  SYSTEM_FIXED_FONT = $10;
  DEFAULT_GUI_FONT = 17;
  STOCK_LAST = 17;
  CLR_INVALID = $FFFFFFFF;
  { Brush Styles }
  BS_SOLID                = 0;
  BS_NULL                 = 1;
  BS_HOLLOW               = BS_NULL;
  BS_HATCHED              = 2;
  BS_PATTERN              = 3;
  BS_INDEXED              = 4;
  BS_DIBPATTERN           = 5;
  BS_DIBPATTERNPT         = 6;
  BS_PATTERN8X8           = 7;
  BS_DIBPATTERN8X8        = 8;
  BS_MONOPATTERN          = 9;
  { Hatch Styles }
  HS_HORIZONTAL = 0;       { ----- }
  HS_VERTICAL   = 1;       { ||||| }
  HS_FDIAGONAL  = 2;       { ///// }
  HS_BDIAGONAL  = 3;       { \\\\\ }
  HS_CROSS      = 4;       { +++++ }
  HS_DIAGCROSS  = 5;       { xxxxx }
  { Pen Styles }
  PS_SOLID       = 0;
  PS_DASH        = 1;      { ------- }
  PS_DOT         = 2;      { ....... }
  PS_DASHDOT     = 3;      { _._._._ }
  PS_DASHDOTDOT  = 4;      { _.._.._ }
  PS_NULL = 5;
  PS_INSIDEFRAME = 6;
  PS_USERSTYLE = 7;
  PS_ALTERNATE = 8;
  PS_STYLE_MASK = 15;
  PS_ENDCAP_ROUND = 0;
  PS_ENDCAP_SQUARE = $100;
  PS_ENDCAP_FLAT = $200;
  PS_ENDCAP_MASK = 3840;
  PS_JOIN_ROUND = 0;
  PS_JOIN_BEVEL = $1000;
  PS_JOIN_MITER = $2000;
  PS_JOIN_MASK = 61440;
  PS_COSMETIC = 0;
  PS_GEOMETRIC = $10000;
  PS_TYPE_MASK = $F0000;
  AD_COUNTERCLOCKWISE = 1;
  AD_CLOCKWISE = 2;

   //logical font
   LF_FACESIZE             = 32;

   DEFAULT_QUALITY         = 0;
   DRAFT_QUALITY           = 1;
   PROOF_QUALITY           = 2;
   NONANTIALIASED_QUALITY  = 3;
   ANTIALIASED_QUALITY     = 4;

   //sockets
   winsocketVersion       = $0101;//windows 95 compatiable
   WSADESCRIPTION_LEN     = 256;
   WSASYS_STATUS_LEN      = 128;
   INVALID_SOCKET         = tsocket(not(0));//This is used instead of -1, since the TSocket type is unsigned
   SOCKET_ERROR	          = -1;
   SOL_SOCKET             = $ffff;          {options for socket level }
   WSABASEERR             = 10000;
   WSAEWOULDBLOCK         = (WSABASEERR+35);

   //option for opening sockets for synchronous access
   SO_OPENTYPE            = $7008;
   SO_SYNCHRONOUS_ALERT   = $10;
   SO_SYNCHRONOUS_NONALERT= $20;
   SO_ACCEPTCONN          = $0002;          { socket has had listen() }
   SO_KEEPALIVE           = $0008;          { keep connections alive }
   SO_LINGER              = $0080;          { linger on close if data present }
   SO_DONTLINGER          = $ff7f;

   INADDR_ANY             = $00000000;
   INADDR_LOOPBACK        = $7F000001;
   INADDR_BROADCAST       = $FFFFFFFF;
   INADDR_NONE            = $FFFFFFFF;

   //Address families
   AF_UNSPEC       = 0;               { unspecified }
   AF_UNIX         = 1;               { local to host (pipes, portals) }
   AF_INET         = 2;               { internetwork: UDP, TCP, etc. }

   //Protocol families - same as address families for now. }
   PF_UNSPEC       = AF_UNSPEC;
   PF_UNIX         = AF_UNIX;
   PF_INET         = AF_INET;

   //Types
   SOCK_STREAM     = 1;               { stream socket }
   SOCK_DGRAM      = 2;               { datagram socket }
   SOCK_RAW        = 3;               { raw-protocol interface }
   SOCK_RDM        = 4;               { reliably-delivered message }
   SOCK_SEQPACKET  = 5;               { sequenced packet stream }

   //Protocols
   IPPROTO_IP     =   0;             { dummy for IP }
   IPPROTO_ICMP   =   1;             { control message protocol }
   IPPROTO_IGMP   =   2;             { group management protocol }
   IPPROTO_GGP    =   3;             { gateway^2 (deprecated) }
   IPPROTO_TCP    =   6;             { tcp }
   IPPROTO_PUP    =  12;             { pup }
   IPPROTO_UDP    =  17;             { user datagram protocol }
   IPPROTO_IDP    =  22;             { xns idp }
   IPPROTO_ND     =  77;             { UNOFFICIAL net disk proto }
   IPPROTO_RAW    =  255;            { raw IP packet }
   IPPROTO_MAX    =  256;

  { Window field offsets for GetWindowLong() }
  GWL_WNDPROC = -4;
  GWL_HINSTANCE = -6;
  GWL_HWNDPARENT = -8;
  GWL_STYLE = -16;
  GWL_EXSTYLE = -20;
  GWL_USERDATA = -21;
  GWL_ID = -12;

   //Define flags to be used with the WSAAsyncSelect
   FD_READ         = $01;
   FD_WRITE        = $02;
   FD_OOB          = $04;
   FD_ACCEPT       = $08;
   FD_CONNECT      = $10;{=16}
   FD_CLOSE        = $20;{=32}

   IOCPARM_MASK = $7f;
   IOC_VOID     = $20000000;
   IOC_OUT      = $40000000;
   IOC_IN       = $80000000;
   IOC_INOUT    = (IOC_IN or IOC_OUT);

   FIONREAD     = IOC_OUT or { get # bytes to read }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 127;
   FIONBIO      = IOC_IN or { set/clear non-blocking i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 126;
   FIOASYNC     = IOC_IN or { set/clear async i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 125;

   //values to access various Windows paths (folders)
   REGSTR_PATH_EXPLORER        = 'Software\Microsoft\Windows\CurrentVersion\Explorer';
   REGSTR_PATH_SPECIAL_FOLDERS   = REGSTR_PATH_EXPLORER + '\Shell Folders';
   CSIDL_DESKTOP                       = $0000;
   CSIDL_PROGRAMS                      = $0002;
   CSIDL_CONTROLS                      = $0003;
   CSIDL_PRINTERS                      = $0004;
   CSIDL_PERSONAL                      = $0005;
   CSIDL_FAVORITES                     = $0006;
   CSIDL_STARTUP                       = $0007;
   CSIDL_RECENT                        = $0008;
   CSIDL_SENDTO                        = $0009;
   CSIDL_BITBUCKET                     = $000a;
   CSIDL_STARTMENU                     = $000b;
   CSIDL_DESKTOPDIRECTORY              = $0010;
   CSIDL_DRIVES                        = $0011;
   CSIDL_NETWORK                       = $0012;
   CSIDL_NETHOOD                       = $0013;
   CSIDL_FONTS                         = $0014;
   CSIDL_TEMPLATES                     = $0015;
   CSIDL_COMMON_STARTMENU              = $0016;
   CSIDL_COMMON_PROGRAMS               = $0017;
   CSIDL_COMMON_STARTUP                = $0018;
   CSIDL_COMMON_DESKTOPDIRECTORY       = $0019;
   CSIDL_APPDATA                       = $001a;
   CSIDL_PRINTHOOD                     = $001b;

   CLSCTX_INPROC_SERVER     = 1;
   CLSCTX_INPROC_HANDLER    = 2;
   CLSCTX_LOCAL_SERVER      = 4;
   CLSCTX_INPROC_SERVER16   = 8;
   CLSCTX_REMOTE_SERVER     = $10;
   CLSCTX_INPROC_HANDLER16  = $20;
   CLSCTX_INPROC_SERVERX86  = $40;
   CLSCTX_INPROC_HANDLERX86 = $80;

  // String constants for Interface IDs
   SID_INewShortcutHookA  = '{000214E1-0000-0000-C000-000000000046}';
   SID_IShellBrowser      = '{000214E2-0000-0000-C000-000000000046}';
   SID_IShellView         = '{000214E3-0000-0000-C000-000000000046}';
   SID_IContextMenu       = '{000214E4-0000-0000-C000-000000000046}';
   SID_IShellIcon         = '{000214E5-0000-0000-C000-000000000046}';
   SID_IShellFolder       = '{000214E6-0000-0000-C000-000000000046}';
   SID_IShellExtInit      = '{000214E8-0000-0000-C000-000000000046}';
   SID_IShellPropSheetExt = '{000214E9-0000-0000-C000-000000000046}';
   SID_IPersistFolder     = '{000214EA-0000-0000-C000-000000000046}';
   SID_IExtractIconA      = '{000214EB-0000-0000-C000-000000000046}';
   SID_IShellLinkA        = '{000214EE-0000-0000-C000-000000000046}';
   SID_IShellCopyHookA    = '{000214EF-0000-0000-C000-000000000046}';
   SID_IFileViewerA       = '{000214F0-0000-0000-C000-000000000046}';
   SID_ICommDlgBrowser    = '{000214F1-0000-0000-C000-000000000046}';
   SID_IEnumIDList        = '{000214F2-0000-0000-C000-000000000046}';
   SID_IFileViewerSite    = '{000214F3-0000-0000-C000-000000000046}';
   SID_IContextMenu2      = '{000214F4-0000-0000-C000-000000000046}';
   SID_IShellExecuteHookA = '{000214F5-0000-0000-C000-000000000046}';
   SID_IPropSheetPage     = '{000214F6-0000-0000-C000-000000000046}';
   SID_INewShortcutHookW  = '{000214F7-0000-0000-C000-000000000046}';
   SID_IFileViewerW       = '{000214F8-0000-0000-C000-000000000046}';
   SID_IShellLinkW        = '{000214F9-0000-0000-C000-000000000046}';
   SID_IExtractIconW      = '{000214FA-0000-0000-C000-000000000046}';
   SID_IShellExecuteHookW = '{000214FB-0000-0000-C000-000000000046}';
   SID_IShellCopyHookW    = '{000214FC-0000-0000-C000-000000000046}';
   SID_IShellView2        = '{88E39E80-3578-11CF-AE69-08002B2E1262}';

    // Class IDs        xx=00-9F
   CLSID_ShellDesktop: TGUID = (
        D1:$00021400; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));
   CLSID_ShellLink: TGUID = (
        D1:$00021401; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));

   MHDR_DONE           = $00000001;       { done bit }
   MHDR_PREPARED       = $00000002;       { set if header prepared }
   MHDR_INQUEUE        = $00000004;       { reserved for driver }
   MHDR_ISSTRM         = $00000008;       { Buffer is stream buffer }
   MM_MOM_OPEN         = $3C7;//actual buffer
   MM_MOM_CLOSE        = $3C8;//actual buffer
   MM_MOM_DONE         = $3C9;//actual buffer
   MM_WOM_DONE         = $3BD;
   CALLBACK_FUNCTION   = $00030000;    { dwCallback is a FARPROC }
   CALLBACK_WINDOW     = $00010000;    { dwCallback is a HWND }
   WAVERR_BASE         = 32;
   MIDIERR_BASE        = 64;
   MIDI_MAPPER         = UINT(-1);//20JAN2011
   WAVE_MAPPER         = UINT(-1);
   CALLBACK_NULL       = $00000000;//no callback
   MAXPNAMELEN         = 32;    { max product name length (including nil) }
   MMSYSERR_NOERROR    = 0;                  { no error }
   WAVECAPS_VOLUME     = $0004;   { supports volume control }
   WAVECAPS_LRVOLUME   = $0008;   { separate left-right volume control }
   MIDICAPS_VOLUME     = $0001;  { supports volume control }
   MIDICAPS_LRVOLUME   = $0002;  { separate left-right volume control }

{ flags for dwFlags field of WAVEHDR }
   //.wave
   WHDR_DONE       = $00000001;  { done bit }
   WHDR_PREPARED   = $00000002;  { set if this header has been prepared }
   WHDR_BEGINLOOP  = $00000004;  { loop start block }
   WHDR_ENDLOOP    = $00000008;  { loop end block }
   WHDR_INQUEUE    = $00000010;  { reserved for driver }
   MM_WOM_OPEN         = $3BB;
   MM_WOM_CLOSE        = $3BC;
   MM_WIM_OPEN         = $3BE;
   MM_WIM_CLOSE        = $3BF;
   MM_WIM_DATA         = $3C0;
   WAVE_FORMAT_QUERY   = $0001;
   WAVE_ALLOWSYNC      = $0002;
   WAVE_MAPPED         = $0004;

   //.midi
   MIDIERR_UNPREPARED    = MIDIERR_BASE + 0;   { header not prepared }
   MIDIERR_STILLPLAYING  = MIDIERR_BASE + 1;   { still something playing }
   MIDIERR_NOMAP         = MIDIERR_BASE + 2;   { no current map }
   MIDIERR_NOTREADY      = MIDIERR_BASE + 3;   { hardware is still busy }
   MIDIERR_NODEVICE      = MIDIERR_BASE + 4;   { port no longer connected }
   MIDIERR_INVALIDSETUP  = MIDIERR_BASE + 5;   { invalid setup }
   MIDIERR_BADOPENMODE   = MIDIERR_BASE + 6;   { operation unsupported w/ open mode }
   MIDIERR_DONT_CONTINUE = MIDIERR_BASE + 7;   { thru device 'eating' a message }
   MIDIERR_LASTERROR     = MIDIERR_BASE + 5;   { last error in range }

  //  GM_Reset: array[1..6] of byte = ($F0, $7E, $7F, $09, $01, $F7); // = GM_On
//  GS_Reset: array[1..11] of byte = ($F0, $41, $10, $42, $12, $40, $00, $7F, $00, $41, $F7);
//  XG_Reset: array[1..9] of byte = ($F0, $43, $10, $4C, $00, $00, $7E, $00, $F7);
//  GM2_On: array[1..6] of byte = ($F0, $7E, $7F, $09, $03, $F7);  // = GM2_Reset
//  GM2_Off: array[1..6] of byte = ($F0, $7E, $7F, $09, $02, $F7); // switch to GS
//  GS_Off: array[1..11] of byte = ($F0, $41, $10, $42, $12, $40, $00, $7F, $7F, $42, $F7); // = Exit GS Mode
//  SysExMasterVolume: array[1..8] of byte = ($F0, $7F, $7F, $04, $01, $0, $0, $F7);

{multi-media}
  //general
  MM_MCINOTIFY        = $3B9;
  //flags for wParam of MM_MCINOTIFY message
  MCI_NOTIFY_SUCCESSFUL           =$0001;
  MCI_NOTIFY_SUPERSEDED           =$0002;
  MCI_NOTIFY_ABORTED              =$0004;
  MCI_NOTIFY_FAILURE              =$0008;
  //common flags for dwFlags parameter of MCI command messages
  MCI_NOTIFY                      =$00000001;
  MCI_WAIT                        =$00000002;
  MCI_FROM                        =$00000004;
  MCI_TO                          =$00000008;
  MCI_TRACK                       =$00000010;
  //flags for dwFlags parameter of MCI_OPEN command message
  MCI_OPEN_SHAREABLE              =$00000100;
  MCI_OPEN_ELEMENT                =$00000200;
  MCI_OPEN_ALIAS                  =$00000400;
  MCI_OPEN_ELEMENT_ID             =$00000800;
  MCI_OPEN_TYPE_ID                =$00001000;
  MCI_OPEN_TYPE                   =$00002000;
  //other
  MCI_SET_DOOR_OPEN               = $00000100;
  MCI_SET_DOOR_CLOSED             = $00000200;
  MCI_SET_TIME_FORMAT             = $00000400;
  MCI_SET_AUDIO                   = $00000800;
  MCI_SET_VIDEO                   = $00001000;
  MCI_SET_ON                      = $00002000;
  MCI_SET_OFF                     = $00004000;
  //MCI command message identifiers
  MCI_OPEN                        =$0803;
  MCI_CLOSE                       =$0804;
  MCI_ESCAPE                      =$0805;
  MCI_PLAY                        =$0806;
  MCI_SEEK                        =$0807;
  MCI_STOP                        =$0808;
  MCI_PAUSE                       =$0809;
  MCI_INFO                        =$080A;
  MCI_GETDEVCAPs                  =$080B;
  MCI_SPIN                        =$080C;
  MCI_SET                         =$080D;
  MCI_STEP                        =$080E;
  MCI_RECORD                      =$080F;
  MCI_SYSINFO                     =$0810;
  MCI_BREAK                       =$0811;
  MCI_SOUND                       =$0812;
  MCI_SAVE                        =$0813;
  MCI_STATUS                      =$0814;
  MCI_CUE                         =$0830;
  MCI_REALIZE                     =$0840;
  MCI_WINDOW                      =$0841;
  MCI_PUT                         =$0842;
  MCI_WHERE                       =$0843;
  MCI_FREEZE                      =$0844;
  MCI_UNFREEZE                    =$0845;
  MCI_LOAD                        =$0850;
  MCI_CUT                         =$0851;
  MCI_COPY                        =$0852;
  MCI_PASTE                       =$0853;
  MCI_UPDATE                      =$0854;
  MCI_RESUME                      =$0855;
  MCI_DELETE                      =$0856;
  //flags for dwFlags parameter of MCI_STATUS command message
  MCI_STATUS_ITEM                 =$00000100;
  MCI_STATUS_START                =$00000200;
  //flags for dwItem field of the MCI_STATUS_PARMS parameter block
  MCI_STATUS_LENGTH               =$00000001;
  MCI_STATUS_POSITION             =$00000002;
  MCI_STATUS_NUMBER_OF_TRACKS     =$00000003;
  MCI_STATUS_MODE                 =$00000004;
  MCI_STATUS_MEDIA_PRESENT        =$00000005;
  MCI_STATUS_TIME_FORMAT          =$00000006;
  MCI_STATUS_READY                =$00000007;
  MCI_STATUS_CURRENT_TRACK        =$00000008;


  type
   //.base value type - specify here before anything else
   HDROP         = longint;
   DWORD         = longint;
   PUINT         = ^UINT;
   ULONG         = longint;
   PULONG        = ^ULONG;
   PLongint      = ^longint;
   PInteger      = ^longint;
   PSmallInt     = ^smallint;
   PDouble       = ^double;
   PWChar        = PWideChar;
   WCHAR         = WideChar;
   LPSTR         = PAnsiChar;
   LPCSTR        = PAnsiChar;
   BOOL          = LongBool;
   PBOOL         = ^BOOL;
   SHORT         = smallint;
   HWND          = longint;
   HHOOK         = longint;
   THandle       = longint;
   PHandle       = ^THandle;
   phresult      = ^hresult;
   hresult       = longint;

   PWORD         = ^Word;
   PDWORD        = ^DWORD;
   LPDWORD       = PDWORD;

   HGLOBAL       = THandle;
   HLOCAL        = THandle;
   HMONITOR      = longint;
   FARPROC       = Pointer;
   TFarProc      = Pointer;
   TFNThreadStartRoutine = TFarProc;
   THandlerFunction = TFarProc;
   TFNHandlerRoutine = TFarProc;
   TFNTimerProc  = TFarProc;
   TFNTimeCallBack  = procedure(uTimerID,uMessage:UINT;dwUser,dw1,dw2:dword) stdcall;// <<-- special note: NO semicolon between "dword)" and "stdcall"!!!!
   PROC_22       = Pointer;

   WPARAM        = longint;
   LPARAM        = longint;
   LRESULT       = longint;
   SC_HANDLE     = THandle;
   SERVICE_STATUS_HANDLE = DWORD;
   ATOM          = Word;
   TAtom         = Word;
   PByte         = ^Byte;

   MMRESULT = UINT;              { error return code, 0 means no error }
   HGDIOBJ = Integer;
   HACCEL = Integer;
   HBITMAP = Integer;
   HBRUSH = Integer;
   HCOLORSPACE = Integer;
   HDC = Integer;
   HGLRC = Integer;
   HDESK = Integer;
   HENHMETAFILE = Integer;
   HFONT = Integer;
   HICON = Integer;
   HMENU = Integer;
   HMETAFILE = Integer;
   HINST = Integer;
   HMODULE = HINST;              { HMODULEs can be used in place of HINSTs }
   HPALETTE = Integer;
   HPEN = Integer;
   HRGN = Integer;
   HRSRC = Integer;
   HSTR = Integer;
   HTASK = Integer;
   HWINSTA = Integer;
   HKL = Integer;

   COLORREF = DWORD;
   TColorRef = Longint;

   HFILE         = Integer;
   HCURSOR       = HICON;              { HICONs & HCURSORs are polymorphic }

   TFNWndProc    = TFarProc;

   PByteArray    = ^TByteArray;
   TByteArray    = array[0..32767] of Byte;

   PWordArray    = ^TWordArray;
   TWordArray    = array[0..16383] of Word;

   TProcedure    = procedure;
   TFileName     = string;

   PIID          = PGUID;
   TIID          = TGUID;
   PCLSID        = PGUID;
   TCLSID        = TGUID;

   //.registry
   HKEY          = longint;
   PHKEY         = ^HKEY;
   ACCESS_MASK   = DWORD;
   PACCESS_MASK  = ^ACCESS_MASK;
   REGSAM        = ACCESS_MASK;


   PPoint        = ^TPoint;
   TPoint        = record
                   x: Longint;
                   y: Longint;
                   end;

   PCoord        = ^TCoord;
   TCoord        = packed record
                   X: SHORT;
                   Y: SHORT;
                   end;

   PSmallRect    = ^TSmallRect;
   TSmallRect    = packed record
                   Left: SHORT;
                   Top: SHORT;
                   Right: SHORT;
                   Bottom: SHORT;
                   end;

   pwinsize = ^twinsize;
   twinsize = record
    cx: Longint;
    cy: Longint;
   end;

   pwinrect=^twinrect;
   twinrect=record
    case longint of
    0:(left,top,right,bottom:longint);
    1:(topleft,bottomright:tpoint);
    end;

   pmsg = ^tmsg;
   tmsg = packed record
    hwnd: HWND;
    message: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
    time: DWORD;
    pt: TPoint;
   end;

  TMsgConv=Record
   case Integer of
   0: (
        WParam:Word;
        LParam:Longint);
   1: (
        WParamLo: Word;
        WParamHi: Word;
        LParamLo: Word;
        LParamHi: Word);
    end;//end of case

   pmonitorinfo=^tmonitorinfo;
   tmonitorinfo = record//26nov2024
      cbsize:dword;
      rcMonitor:twinrect;
      rcWork:twinrect;
      dwFlags:dword;
      end;

   pmonitorinfoex=^tmonitorinfoex;
   tmonitorinfoex = record//26nov2024
      cbsize:dword;
      rcMonitor:twinrect;
      rcWork:twinrect;
      dwFlags:dword;
      szDeviceName:array[0..31] of char;
      end;

   PMonitorenumproc=^TMonitorenumproc;
   TMonitorenumproc=function (unnamedParam1:HMONITOR;unnamedParam2:HDC;unnamedParam3:pwinrect;unnamedParam4:LPARAM):lresult; stdcall;

  PDeviceModeA = ^TDeviceModeA;
  TDeviceModeA = packed record
    dmDeviceName: array[0..31] of AnsiChar;
    dmSpecVersion: Word;
    dmDriverVersion: Word;
    dmSize: Word;
    dmDriverExtra: Word;
    dmFields: DWORD;
    dmOrientation: SHORT;
    dmPaperSize: SHORT;
    dmPaperLength: SHORT;
    dmPaperWidth: SHORT;
    dmScale: SHORT;
    dmCopies: SHORT;
    dmDefaultSource: SHORT;
    dmPrintQuality: SHORT;
    dmColor: SHORT;
    dmDuplex: SHORT;
    dmYResolution: SHORT;
    dmTTOption: SHORT;
    dmCollate: SHORT;
    dmFormName: array[0..31] of AnsiChar;
    dmLogPixels: Word;
    dmBitsPerPel: DWORD;
    dmPelsWidth: DWORD;
    dmPelsHeight: DWORD;
    dmDisplayFlags: DWORD;
    dmDisplayFrequency: DWORD;
    dmICMMethod: DWORD;
    dmICMIntent: DWORD;
    dmMediaType: DWORD;
    dmDitherType: DWORD;
    dmICCManufacturer: DWORD;
    dmICCModel: DWORD;
    dmPanningWidth: DWORD;
    dmPanningHeight: DWORD;
  end;

   //.service status
   PServiceStatus = ^TServiceStatus;
   TServiceStatus = record
     dwServiceType: DWORD;
     dwCurrentState: DWORD;
     dwControlsAccepted: DWORD;
     dwWin32ExitCode: DWORD;
     dwServiceSpecificExitCode: DWORD;
     dwCheckPoint: DWORD;
     dwWaitHint: DWORD;
   end;

   TServiceMainFunction = tfarproc;
   PServiceTableEntry = ^TServiceTableEntry;
   TServiceTableEntry = record
     lpServiceName: PAnsiChar;
     lpServiceProc: TServiceMainFunction;
   end;

  PShellExecuteInfo = ^TShellExecuteInfo;
  TShellExecuteInfo = record
    cbSize: DWORD;
    fMask: ULONG;
    Wnd: HWND;
    lpVerb: PAnsiChar;
    lpFile: PAnsiChar;
    lpParameters: PAnsiChar;
    lpDirectory: PAnsiChar;
    nShow: Integer;
    hInstApp: HINST;
    { Optional fields }
    lpIDList: Pointer;
    lpClass: PAnsiChar;
    hkeyClass: HKEY;
    dwHotKey: DWORD;
    hIcon: THandle;
    hProcess: THandle;
  end;

  TCharFormatA = record
    cbSize: UINT;
    dwMask: Longint;
    dwEffects: Longint;
    yHeight: Longint;
    yOffset: Longint;
    crTextColor: TColorRef;
    bCharSet: Byte;
    bPitchAndFamily: Byte;
    szFaceName: array[0..LF_FACESIZE - 1] of AnsiChar;
  end;

  PChooseColor =^TChooseColor;
  TChooseColor = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HWND;
    rgbResult: COLORREF;
    lpCustColors: ^COLORREF;
    Flags: DWORD;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
  end;

  POpenFilename = ^TOpenFilename;
  TOpenFilename = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PAnsiChar;
    lpstrCustomFilter: PAnsiChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PAnsiChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PAnsiChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PAnsiChar;
    lpstrTitle: PAnsiChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PAnsiChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PAnsiChar;
  end;

  { File System time stamps are represented with the following structure: }
   PFileTime = ^TFileTime;
   TFileTime = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
   end;

   PWin32FindDataA = ^TWin32FindDataA;
   TWin32FindDataA = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of AnsiChar;
    cAlternateFileName: array[0..13] of AnsiChar;
   end;

   PWin32FindData  = PWin32FindDataA;
   TWin32FindData  = TWin32FindDataA;

   pOSVersionInfo=^TOSVersionInfo;
   TOSVersionInfo = record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of AnsiChar; { Maintenance string for PSS usage }
   end;

   PSHItemID = ^TSHItemID;
   TSHItemID = packed record           { mkid }
    cb: Word;                         { Size of the ID (including cb itself) }
    abID: array[0..0] of Byte;        { The item ID (variable length) }
   end;

   PItemIDList = ^TItemIDList;
   TItemIDList = packed record         { idl }
     mkid: TSHItemID;
    end;

   POverlapped = ^TOverlapped;
   TOverlapped = record
    Internal: DWORD;
    InternalHigh: DWORD;
    Offset: DWORD;
    OffsetHigh: DWORD;
    hEvent: THandle;
   end;

   PLogBrush = ^TLogBrush;
   TLogBrush = packed record
    lbStyle: UINT;
    lbColor: longint;
    lbHatch: longint;
   end;

   PWndClassExA = ^TWndClassExA;
   PWndClassExW = ^TWndClassExW;
   PWndClassEx = PWndClassExA;
   TWndClassExA = packed record
    cbSize: UINT;
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PAnsiChar;
    lpszClassName: PAnsiChar;
    hIconSm: HICON;
   end;
   TWndClassExW = packed record
    cbSize: UINT;
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PWideChar;
    lpszClassName: PWideChar;
    hIconSm: HICON;
   end;
   TWndClassEx = TWndClassExA;

   PWndClassA = ^TWndClassA;
   PWndClassW = ^TWndClassW;
   PWndClass = PWndClassA;
   TWndClassA = packed record
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PAnsiChar;
    lpszClassName: PAnsiChar;
   end;
   TWndClassW = packed record
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PWideChar;
    lpszClassName: PWideChar;
   end;
   TWndClass = TWndClassA;


   PConsoleScreenBufferInfo = ^TConsoleScreenBufferInfo;
   TConsoleScreenBufferInfo = packed record
     dwSize: TCoord;
     dwCursorPosition: TCoord;
     wAttributes: Word;
     srWindow: TSmallRect;
     dwMaximumWindowSize: TCoord;
   end;

   PConsoleCursorInfo = ^TConsoleCursorInfo;
   TConsoleCursorInfo = packed record
     dwSize: DWORD;
     bVisible: BOOL;
   end;

  { imalloc interface }
   imalloc = interface(IUnknown)
      ['{00000002-0000-0000-C000-000000000046}']
      function Alloc(cb: Longint): Pointer; stdcall;
      function Realloc(pv: Pointer; cb: Longint): Pointer; stdcall;
      procedure Free(pv: Pointer); stdcall;
      function GetSize(pv: Pointer): Longint; stdcall;
      function DidAlloc(pv: Pointer): Integer; stdcall;
      procedure HeapMinimize; stdcall;
   end;

   //.network
   PWSAData = ^TWSAData;
   TWSAData = packed record
    wVersion: Word;
    wHighVersion: Word;
    szDescription: array[0..WSADESCRIPTION_LEN] of Char;
    szSystemStatus: array[0..WSASYS_STATUS_LEN] of Char;
    iMaxSockets: Word;
    iMaxUdpDg: Word;
    lpVendorInfo: PChar;
    end;

   SunB = packed record
    s_b1, s_b2, s_b3, s_b4: u_char;
    end;

   SunW = packed record
    s_w1, s_w2: u_short;
    end;

   PInAddr = ^TInAddr;
   TInAddr = packed record
    case integer of
      0: (S_un_b: SunB);
      1: (S_un_w: SunW);
      2: (S_addr: u_long);
    end;

   PSockAddrIn = ^TSockAddrIn;
   TSockAddrIn = packed record
    case Integer of
      0: (sin_family: u_short;
          sin_port: u_short;
          sin_addr: TInAddr;
          sin_zero: array[0..7] of Char);
      1: (sa_family: u_short;
          sa_data: array[0..13] of Char)
    end;

   PSockAddr = ^TSockAddr;
   TSockAddr = TSockAddrIn;

   PWindowPlacement = ^TWindowPlacement;
   TWindowPlacement = packed record
     length: UINT;
     flags: UINT;
     showCmd: UINT;
     ptMinPosition: TPoint;
     ptMaxPosition: TPoint;
     rcNormalPosition: twinrect;
   end;

  PPaintStruct = ^TPaintStruct;
  TPaintStruct = packed record
    hdc: HDC;
    fErase: BOOL;
    rcPaint: twinrect;
    fRestore: BOOL;
    fIncUpdate: BOOL;
    rgbReserved: array[0..31] of Byte;
  end;

  PKeyEventRecord = ^TKeyEventRecord;
  TKeyEventRecord = packed record
    bKeyDown: BOOL;
    wRepeatCount: Word;
    wVirtualKeyCode: Word;
    wVirtualScanCode: Word;
    case longint of
    0:(UnicodeChar:WCHAR; dwControlKeyStateU:DWORD);
    1:(AsciiChar:CHAR; dwControlKeyState:DWORD);
    end;

  PMouseEventRecord = ^TMouseEventRecord;
  TMouseEventRecord = packed record
    dwMousePosition: TCoord;
    dwButtonState: DWORD;
    dwControlKeyState: DWORD;
    dwEventFlags: DWORD;
  end;

  PWindowBufferSizeRecord = ^TWindowBufferSizeRecord;
  TWindowBufferSizeRecord = packed record
    dwSize: TCoord;
  end;

  PMenuEventRecord = ^TMenuEventRecord;
  TMenuEventRecord = packed record
    dwCommandId: UINT;
  end;

  PFocusEventRecord = ^TFocusEventRecord;
  TFocusEventRecord = packed record
    bSetFocus: BOOL;
  end;

   PInputRecord = ^TInputRecord;
   TInputRecord = record
    EventType: Word;
    case Integer of
      0: (KeyEvent: TKeyEventRecord);
      1: (MouseEvent: TMouseEventRecord);
      2: (WindowBufferSizeEvent: TWindowBufferSizeRecord);
      3: (MenuEvent: TMenuEventRecord);
      4: (FocusEvent: TFocusEventRecord);
    end;

   //.font support
   PLogFontA = ^TLogFontA;
   PLogFontW = ^TLogFontW;
   PLogFont = PLogFontA;
   TLogFontA = packed record
    lfHeight: Longint;
    lfWidth: Longint;
    lfEscapement: Longint;
    lfOrientation: Longint;
    lfWeight: Longint;
    lfItalic: Byte;
    lfUnderline: Byte;
    lfStrikeOut: Byte;
    lfCharSet: Byte;
    lfOutPrecision: Byte;
    lfClipPrecision: Byte;
    lfQuality: Byte;
    lfPitchAndFamily: Byte;
    lfFaceName: array[0..LF_FACESIZE - 1] of AnsiChar;
   end;
   TLogFontW = packed record
    lfHeight: Longint;
    lfWidth: Longint;
    lfEscapement: Longint;
    lfOrientation: Longint;
    lfWeight: Longint;
    lfItalic: Byte;
    lfUnderline: Byte;
    lfStrikeOut: Byte;
    lfCharSet: Byte;
    lfOutPrecision: Byte;
    lfClipPrecision: Byte;
    lfQuality: Byte;
    lfPitchAndFamily: Byte;
    lfFaceName: array[0..LF_FACESIZE - 1] of WideChar;
   end;
   TLogFont = TLogFontA;

   PPrinterInfo4 = ^TPrinterInfo4;
   TPrinterInfo4 = record
     pPrinterName: PAnsiChar;
     pServerName: PAnsiChar;
     Attributes: DWORD;
   end;

   PPrinterInfo5 = ^TPrinterInfo5;
   TPrinterInfo5 = record
     pPrinterName: PAnsiChar;
     pPortName: PAnsiChar;
     Attributes: DWORD;
     DeviceNotSelectedTimeout: DWORD;
     TransmissionRetryTimeout: DWORD;
   end;
   
   PSecurityAttributes = ^TSecurityAttributes;
   TSecurityAttributes = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
   end;

   PProcessInformation = ^TProcessInformation;
   TProcessInformation = record
    hProcess: THandle;
    hThread: THandle;
    dwProcessId: DWORD;
    dwThreadId: DWORD;
   end;

  pwinmenuiteminfo = ^twinmenuiteminfo;
  twinmenuiteminfo = packed record
    cbSize: UINT;
    fMask: UINT;
    fType: UINT;             { used if MIIM_TYPE}
    fState: UINT;            { used if MIIM_STATE}
    wID: UINT;               { used if MIIM_ID}
    hSubMenu: HMENU;         { used if MIIM_SUBMENU}
    hbmpChecked: HBITMAP;    { used if MIIM_CHECKMARKS}
    hbmpUnchecked: HBITMAP;  { used if MIIM_CHECKMARKS}
    dwItemData: DWORD;       { used if MIIM_DATA}
    dwTypeData: PAnsiChar;      { used if MIIM_TYPE}
    cch: UINT;               { used if MIIM_TYPE}
  end;

  { System time is represented with the following structure: }
  PSystemTime = ^TSystemTime;
  TSystemTime = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;

  { File System time stamps are represented with the following structure: }
   PByHandleFileInformation = ^TByHandleFileInformation;
   TByHandleFileInformation = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    dwVolumeSerialNumber: DWORD;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    nNumberOfLinks: DWORD;
    nFileIndexHigh: DWORD;
    nFileIndexLow: DWORD;
   end;

   pbitmapheader = ^tbitmapheader;//cf_bitmap clipboard info
   tbitmapheader = packed record
    bmType: Longint;
    bmWidth: Longint;
    bmHeight: Longint;
    bmWidthBytes: Longint;
    bmPlanes: Word;
    bmBitsPixel: Word;
    bmBits: Pointer;
   end;

   PBitmapInfoHeader = ^TBitmapInfoHeader;
   TBitmapInfoHeader = packed record
    biSize         :dword;
    biWidth        :longint;
    biHeight       :longint;
    biPlanes       :word;
    biBitCount     :word;
    biCompression  :dword;
    biSizeImage    :dword;
    biXPelsPerMeter:longint;
    biYPelsPerMeter:longint;
    biClrUsed      :dword;
    biClrImportant :dword;
   end;

   PDIBSection = ^TDIBSection;
   TDIBSection = packed record
    dsBm: tbitmapheader;
    dsBmih: TBitmapInfoHeader;
    dsBitfields: array[0..2] of DWORD;
    dshSection: THandle;
    dsOffset: DWORD;
   end;

   MMVERSION = UINT;             { major (high byte), minor (low byte) }
   PHMIDI = ^HMIDI;
   HMIDI = longint;
   PHMIDIIN = ^HMIDIIN;
   HMIDIIN = longint;
   PHMIDIOUT = ^HMIDIOUT;
   HMIDIOUT = longint;
   PHMIDISTRM = ^HMIDISTRM;
   HMIDISTRM = longint;
   PHWAVE = ^HWAVE;
   HWAVE = longint;
   PHWAVEIN = ^HWAVEIN;
   HWAVEIN = longint;
   PHWAVEOUT = ^HWAVEOUT;
   HWAVEOUT = longint;

   PWaveOutCaps=^TWaveOutCaps;//fixed 28jun2024
   TWaveOutCaps = record
    wMid: Word;                 { manufacturer ID }
    wPid: Word;                 { product ID }
    vDriverVersion: MMVERSION;       { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated string) }
    dwFormats: DWORD;          { formats supported }
    wChannels: Word;            { number of sources supported }
    dwSupport: DWORD;          { functionality supported by driver }
    end;

   PMidiOutCaps=^TMidiOutCaps;
   TMidiOutCaps = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    vDriverVersion: MMVERSION;        { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated string) }
    wTechnology: Word;           { type of device }
    wVoices: Word;               { # of voices (internal synth only) }
    wNotes: Word;                { max # of notes (internal synth only) }
    wChannelMask: Word;          { channels used (internal synth only) }
    dwSupport: DWORD;            { functionality supported by driver }
    end;

   PMidiHdr = ^TMidiHdr;
   TMidiHdr = record
    lpData: PChar;               { pointer to locked data block }
    dwBufferLength: DWORD;       { length of data in data block }
    dwBytesRecorded: DWORD;      { used for input only }
    dwUser: DWORD;               { for client's use }
    dwFlags: DWORD;              { assorted flags (see defines) }
    lpNext: PMidiHdr;            { reserved for driver }
    reserved: DWORD;             { reserved for driver }
    dwOffset: DWORD;             { Callback offset into buffer }
    dwReserved: array[0..7] of DWORD; { Reserved for winmmEM }
   end;
    
    MCIERROR = DWORD;     { error return code, 0 means no error }
    MCIDEVICEID = UINT;   { MCI device ID type }
    PMCI_Generic_Parms=^TMCI_Generic_Parms;
    TMCI_Generic_Parms=record
      dwCallback:DWORD;
      end;
    PMCI_Open_ParmsA=^TMCI_Open_ParmsA;
    PMCI_Open_Parms=PMCI_Open_ParmsA;
    TMCI_Open_ParmsA=record
      dwCallback:DWORD;
      wDeviceID:MCIDEVICEID;
      lpstrDeviceType:PAnsiChar;
      lpstrElementName:PAnsiChar;
      lpstrAlias:PAnsiChar;
      end;
    TMCI_Open_Parms=TMCI_Open_ParmsA;
    PMCI_Play_Parms=^TMCI_Play_Parms;
    TMCI_Play_Parms=record
      dwCallback:DWORD;
      dwFrom:DWORD;
      dwTo:DWORD;
      end;
    PMCI_Set_Parms=^TMCI_Set_Parms;
    TMCI_Set_Parms=record
      dwCallback:DWORD;
      dwTimeFormat:DWORD;
      dwAudio:DWORD;
      end;
    PMCI_Status_Parms=^TMCI_Status_Parms;
    TMCI_Status_Parms=record
      dwCallback:DWORD;
      dwReturn:DWORD;
      dwItem:DWORD;
      dwTrack:DWORD;
      end;
    PMCI_Seek_Parms=^TMCI_Seek_Parms;
    TMCI_Seek_Parms=record
      dwCallback:DWORD;
      dwTo:DWORD;
      end;

//    VERSION = UINT;               { major (high byte), minor (low byte) }
    PWaveFormatEx = ^TWaveFormatEx;
    TWaveFormatEx = packed record
     wFormatTag: Word;         { format type }
     nChannels: Word;          { number of channels (i.e. mono, stereo, etc.) }
     nSamplesPerSec: DWORD;  { sample rate }
     nAvgBytesPerSec: DWORD; { for buffer estimation }
     nBlockAlign: Word;      { block size of data }
     wBitsPerSample: Word;   { number of bits per sample of mono data }
     cbSize: Word;           { the count in bytes of the size of }
     end;
    PWaveHdr = ^TWaveHdr;
    TWaveHdr = record
     lpData: PChar;              { pointer to locked data buffer }
     dwBufferLength: DWORD;      { length of data buffer }
     dwBytesRecorded: DWORD;     { used for input only }
     dwUser: DWORD;              { for client's use }
     dwFlags: DWORD;             { assorted flags (see defines) }
     dwLoops: DWORD;             { loop control counter }
     lpNext: PWaveHdr;           { reserved for driver }
     reserved: DWORD;            { reserved for driver }
     end;

   //Xinput - Xbox controller input --------------------------------------------
   pxinputGamepad=^txinputGamepad;
   txinputGamepad=packed record
      wbuttons:word;
      bleftTrigger:byte;//0..255
      bRightTrigger:byte;//0..255
      sThumbLX:smallint;//-32768..32767 => negative values = down or left and positive values = up or right
      sThumbLY:smallint;
      sThumbRX:smallint;
      sThumbRY:smallint;
      end;

   pxinputstate=^txinputstate;
   txinputstate= packed record
      dwPacketNumber:dword;
      dGamepad:txinputGamepad;
      end;

   pxinputvibration=^txinputvibration;
   txinputvibration=packed record
       lmotorspeed:word;
       rmotorspeed:word;
      end;

   TMenuBreak       = (mbNone, mbBreak, mbBarBreak);

{$ifndef gui3}
   TShiftState      = set of (ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble);
   TMouseButton     = (mbLeft, mbRight, mbMiddle);
   TMouseEvent      =Procedure(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer) of Object;
   TMouseMoveEvent  =Procedure(Sender:TObject;Shift:TShiftState;X,Y:Integer) of Object;
   TCloseAction=(caNone, caHide, caFree, caMinimize);
   TCloseEvent=Procedure(Sender:TObject;var Action:TCloseAction) of Object;
   TCloseQueryEvent=Procedure(Sender:TObject;var CanClose:Boolean) of Object;
{$endif}

   TPopupEvent      =Procedure(Sender:TObject;ItemID:longint) of Object;

    PMouseInfo=^TMouseInfo;
    TMouseInfo=Record
     Down:Boolean;
     Button:TMouseButton;
     Shift:TShiftState;
     X:Integer;
     Y:Integer;
     lX:Integer;
     lY:Integer;
     end;

   //---------------------------------------------------------------------------
   //Win32 dynamic load support ------------------------------------------------

   pwincore=^twincore;
   twincore=packed record

     //proc information
     u             :array[0..999] of boolean;   //true=slot in use
     p             :array[0..999] of pointer;   //pointer to dll.proc -> nil=proc failed to load
     c             :array[0..999] of comp;      //number of calls to this proc
     e             :array[0..999] of longint;   //error code
     d             :array[0..999] of longint;   //dll name as an index
     r             :array[0..999] of longint;   //default return value -> used when proc fails to load
     r2            :array[0..999] of word;      //default return value WORD version -> used when proc fails to load

     //dll information
     du            :array[0..dmax] of boolean;  //true=DLL in use -> has already attempted to load
     dh            :array[0..dmax] of longint;  //module handle (0=failed to load)
     de            :array[0..dmax] of longint;  //error code
     dcalls        :array[0..dmax] of comp;     //number of calls to this DLL

     //load counters
     dcount        :longint;
     dOK           :longint;
     dFAIL         :longint;

     pcount        :longint;
     pOK           :longint;
     pFAIL         :longint;

     //usage counters
     pcalls        :comp;                       //number of calls to ALL procs
     ecount        :longint;                    //number of return errors from an api call

     //trace
     tracelist     :array[0..199] of longint;   //track proc usage by storing slot number in a list
     tracedepth    :longint;

     end;

   pwinscannerinfo=^twinscannerinfo;
   twinscannerinfo=record

     lhistory      :tobject;//(tdynamicnamelist) -> tracks repeat entries
     lprocvars     :tobject;//(tstr8) list of procs as constants
     lproctype     :tobject;//(tstr8) list of procs as record types
     lprocline     :tobject;//(tstr8) list of procs as a procedure or function definition line
     lprocbody     :tobject;//(tstr8) list of procs as a procedure or function text
     lprocinfo     :tobject;//(tstr8) list of procs in a management function(s)
     dunit         :tobject;//(tstr8) final unit code

     proccount     :longint;
     defaultcount  :longint;
     longestname   :longint;

     end;

   //---------------------------------------------------------------------------
   //---------------------------------------------------------------------------


const
   STD_INPUT_HANDLE = DWORD(-10);
   STD_OUTPUT_HANDLE = DWORD(-11);
   STD_ERROR_HANDLE = DWORD(-12);

   SEM_FAILCRITICALERRORS = 1;
   SEM_NOGPFAULTERRORBOX = 2;
   SEM_NOALIGNMENTFAULTEXCEPT = 4;
   SEM_NOOPENFILEERRORBOX = $8000;

   //file support
   INVALID_HANDLE_VALUE = -1;
   INVALID_FILE_SIZE = DWORD($FFFFFFFF);

   FILE_BEGIN = 0;
   FILE_CURRENT = 1;
   FILE_END = 2;

   FILE_SHARE_READ                     = $00000001;
   FILE_SHARE_WRITE                    = $00000002;
   FILE_SHARE_DELETE                   = $00000004;
   FILE_ATTRIBUTE_READONLY             = $00000001;
   FILE_ATTRIBUTE_HIDDEN               = $00000002;
   FILE_ATTRIBUTE_SYSTEM               = $00000004;
   FILE_ATTRIBUTE_DIRECTORY            = $00000010;
   FILE_ATTRIBUTE_ARCHIVE              = $00000020;
   FILE_ATTRIBUTE_NORMAL               = $00000080;
   FILE_ATTRIBUTE_TEMPORARY            = $00000100;
   FILE_ATTRIBUTE_COMPRESSED           = $00000800;
   FILE_ATTRIBUTE_OFFLINE              = $00001000;
   FILE_NOTIFY_CHANGE_FILE_NAME        = $00000001;
   FILE_NOTIFY_CHANGE_DIR_NAME         = $00000002;
   FILE_NOTIFY_CHANGE_ATTRIBUTES       = $00000004;
   FILE_NOTIFY_CHANGE_SIZE             = $00000008;
   FILE_NOTIFY_CHANGE_LAST_WRITE       = $00000010;
   FILE_NOTIFY_CHANGE_LAST_ACCESS      = $00000020;
   FILE_NOTIFY_CHANGE_CREATION         = $00000040;
   FILE_NOTIFY_CHANGE_SECURITY         = $00000100;
   FILE_ACTION_ADDED                   = $00000001;
   FILE_ACTION_REMOVED                 = $00000002;
   FILE_ACTION_MODIFIED                = $00000003;
   FILE_ACTION_RENAMED_OLD_NAME        = $00000004;
   FILE_ACTION_RENAMED_NEW_NAME        = $00000005;
   MAILSLOT_NO_MESSAGE                 = -1;
   MAILSLOT_WAIT_FOREVER               = -1;
   FILE_CASE_SENSITIVE_SEARCH          = $00000001;
   FILE_CASE_PRESERVED_NAMES           = $00000002;
   FILE_UNICODE_ON_DISK                = $00000004;
   FILE_PERSISTENT_ACLS                = $00000008;
   FILE_FILE_COMPRESSION               = $00000010;
   FILE_VOLUME_IS_COMPRESSED           = $00008000;

  { File creation flags must start at the high end since they }
  { are combined with the attributes}

   FILE_FLAG_WRITE_THROUGH = $80000000;
   FILE_FLAG_OVERLAPPED = $40000000;
   FILE_FLAG_NO_BUFFERING = $20000000;
   FILE_FLAG_RANDOM_ACCESS = $10000000;
   FILE_FLAG_SEQUENTIAL_SCAN = $8000000;
   FILE_FLAG_DELETE_ON_CLOSE = $4000000;
   FILE_FLAG_BACKUP_SEMANTICS = $2000000;
   FILE_FLAG_POSIX_SEMANTICS = $1000000;

   CREATE_NEW = 1;
   CREATE_ALWAYS = 2;
   OPEN_EXISTING = 3;
   OPEN_ALWAYS = 4;
   TRUNCATE_EXISTING = 5;

  { Edit Control Styles }
  ES_LEFT = 0;
  ES_CENTER = 1;
  ES_RIGHT = 2;
  ES_MULTILINE = 4;
  ES_UPPERCASE = 8;
  ES_LOWERCASE = $10;
  ES_PASSWORD = $20;
  ES_AUTOVSCROLL = $40;
  ES_AUTOHSCROLL = $80;
  ES_NOHIDESEL = $100;
  ES_OEMCONVERT = $400;
  ES_READONLY = $800;
  ES_WANTRETURN = $1000;
  ES_NUMBER = $2000;

   //system messages
  WM_MULTIMEDIA_TIMER  =WM_USER + 127;
  WM_NULL             = $0000;
  WM_CREATE           = $0001;
  WM_DESTROY          = $0002;
  WM_MOVE             = $0003;
  WM_SIZE             = $0005;
  WM_ACTIVATE         = $0006;
  WM_SETFOCUS         = $0007;
  WM_KILLFOCUS        = $0008;
  WM_ENABLE           = $000A;
  WM_SETREDRAW        = $000B;
  WM_SETTEXT          = $000C;
  WM_GETTEXT          = $000D;
  WM_GETTEXTLENGTH    = $000E;
  WM_PAINT            = $000F;
  WM_CLOSE            = $0010;
  WM_QUERYENDSESSION  = $0011;
  WM_QUIT             = $0012;
  WM_QUERYOPEN        = $0013;
  WM_ERASEBKGND       = $0014;
  WM_SYSCOLORCHANGE   = $0015;
  WM_ENDSESSION       = $0016;
  WM_SYSTEMERROR      = $0017;
  WM_SHOWWINDOW       = $0018;
  WM_CTLCOLOR         = $0019;
  WM_WININICHANGE     = $001A;
  WM_SETTINGCHANGE = WM_WININICHANGE;
  WM_DEVMODECHANGE    = $001B;
  WM_ACTIVATEAPP      = $001C;
  WM_FONTCHANGE       = $001D;
  WM_TIMECHANGE       = $001E;
  WM_CANCELMODE       = $001F;
  WM_SETCURSOR        = $0020;
  WM_MOUSEACTIVATE    = $0021;
  WM_CHILDACTIVATE    = $0022;
  WM_QUEUESYNC        = $0023;
  WM_GETMINMAXINFO    = $0024;
  WM_PAINTICON        = $0026;
  WM_ICONERASEBKGND   = $0027;
  WM_NEXTDLGCTL       = $0028;
  WM_SPOOLERSTATUS    = $002A;
  WM_DRAWITEM         = $002B;
  WM_MEASUREITEM      = $002C;
  WM_DELETEITEM       = $002D;
  WM_VKEYTOITEM       = $002E;
  WM_CHARTOITEM       = $002F;
  WM_SETFONT          = $0030;
  WM_GETFONT          = $0031;
  WM_SETHOTKEY        = $0032;
  WM_GETHOTKEY        = $0033;
  WM_QUERYDRAGICON    = $0037;
  WM_COMPAREITEM      = $0039;
  WM_COMPACTING       = $0041;

  WM_COMMNOTIFY       = $0044;    { obsolete in Win32}

  WM_WINDOWPOSCHANGING = $0046;
  WM_WINDOWPOSCHANGED = $0047;
  WM_POWER            = $0048;

  WM_COPYDATA         = $004A;
  WM_CANCELJOURNAL    = $004B;
  WM_NOTIFY           = $004E;
  WM_INPUTLANGCHANGEREQUEST = $0050;
  WM_INPUTLANGCHANGE  = $0051;
  WM_TCARD            = $0052;
  WM_HELP             = $0053;
  WM_USERCHANGED      = $0054;
  WM_NOTIFYFORMAT     = $0055;

  WM_CONTEXTMENU      = $007B;
  WM_STYLECHANGING    = $007C;
  WM_STYLECHANGED     = $007D;
  WM_DISPLAYCHANGE    = $007E;
  WM_GETICON          = $007F;
  WM_SETICON          = $0080;

  WM_NCCREATE         = $0081;
  WM_NCDESTROY        = $0082;
  WM_NCCALCSIZE       = $0083;
  WM_NCHITTEST        = $0084;
  WM_NCPAINT          = $0085;
  WM_NCACTIVATE       = $0086;
  WM_GETDLGCODE       = $0087;
  WM_NCMOUSEMOVE      = $00A0;
  WM_NCLBUTTONDOWN    = $00A1;
  WM_NCLBUTTONUP      = $00A2;
  WM_NCLBUTTONDBLCLK  = $00A3;
  WM_NCRBUTTONDOWN    = $00A4;
  WM_NCRBUTTONUP      = $00A5;
  WM_NCRBUTTONDBLCLK  = $00A6;
  WM_NCMBUTTONDOWN    = $00A7;
  WM_NCMBUTTONUP      = $00A8;
  WM_NCMBUTTONDBLCLK  = $00A9;

  WM_KEYFIRST         = $0100;
  WM_KEYDOWN          = $0100;
  WM_KEYUP            = $0101;
  WM_CHAR             = $0102;
  WM_DEADCHAR         = $0103;
  WM_SYSKEYDOWN       = $0104;
  WM_SYSKEYUP         = $0105;
  WM_SYSCHAR          = $0106;
  WM_SYSDEADCHAR      = $0107;
  WM_KEYLAST          = $0108;

  WM_INITDIALOG       = $0110;
  WM_COMMAND          = $0111;
  WM_SYSCOMMAND       = $0112;
  WM_TIMER            = $0113;
  WM_HSCROLL          = $0114;
  WM_VSCROLL          = $0115;
  WM_INITMENU         = $0116;
  WM_INITMENUPOPUP    = $0117;
  WM_MENUSELECT       = $011F;
  WM_MENUCHAR         = $0120;
  WM_ENTERIDLE        = $0121;

  WM_CTLCOLORMSGBOX   = $0132;
  WM_CTLCOLOREDIT     = $0133;
  WM_CTLCOLORLISTBOX  = $0134;
  WM_CTLCOLORBTN      = $0135;
  WM_CTLCOLORDLG      = $0136;
  WM_CTLCOLORSCROLLBAR= $0137;
  WM_CTLCOLORSTATIC   = $0138;

  WM_MOUSEFIRST       = $0200;
  WM_MOUSEMOVE        = $0200;
  WM_LBUTTONDOWN      = $0201;
  WM_LBUTTONUP        = $0202;
  WM_LBUTTONDBLCLK    = $0203;
  WM_RBUTTONDOWN      = $0204;
  WM_RBUTTONUP        = $0205;
  WM_RBUTTONDBLCLK    = $0206;
  WM_MBUTTONDOWN      = $0207;
  WM_MBUTTONUP        = $0208;
  WM_MBUTTONDBLCLK    = $0209;
  WM_MOUSEWHEEL       = $020A; 
  WM_MOUSELAST        = $020A;

  WM_PARENTNOTIFY     = $0210;
  WM_ENTERMENULOOP    = $0211;
  WM_EXITMENULOOP     = $0212;
  WM_NEXTMENU         = $0213;

  WM_SIZING           = 532;
  WM_CAPTURECHANGED   = 533;
  WM_MOVING           = 534;
  WM_POWERBROADCAST   = 536;
  WM_DEVICECHANGE     = 537;

  WM_IME_STARTCOMPOSITION        = $010D;
  WM_IME_ENDCOMPOSITION          = $010E;
  WM_IME_COMPOSITION             = $010F;
  WM_IME_KEYLAST                 = $010F;

  WM_IME_SETCONTEXT              = $0281;
  WM_IME_NOTIFY                  = $0282;
  WM_IME_CONTROL                 = $0283;
  WM_IME_COMPOSITIONFULL         = $0284;
  WM_IME_SELECT                  = $0285;
  WM_IME_CHAR                    = $0286;

  WM_IME_KEYDOWN                 = $0290;
  WM_IME_KEYUP                   = $0291;

  WM_MDICREATE        = $0220;
  WM_MDIDESTROY       = $0221;
  WM_MDIACTIVATE      = $0222;
  WM_MDIRESTORE       = $0223;
  WM_MDINEXT          = $0224;
  WM_MDIMAXIMIZE      = $0225;
  WM_MDITILE          = $0226;
  WM_MDICASCADE       = $0227;
  WM_MDIICONARRANGE   = $0228;
  WM_MDIGETACTIVE     = $0229;
  WM_MDISETMENU       = $0230;

  WM_ENTERSIZEMOVE    = $0231;
  WM_EXITSIZEMOVE     = $0232;
  WM_DROPFILES        = $0233;
  WM_MDIREFRESHMENU   = $0234;

  WM_MOUSEHOVER       = $02A1; 
  WM_MOUSELEAVE       = $02A3;

  WM_CUT              = $0300;
  WM_COPY             = $0301;
  WM_PASTE            = $0302;
  WM_CLEAR            = $0303;
  WM_UNDO             = $0304;
  WM_RENDERFORMAT     = $0305;
  WM_RENDERALLFORMATS = $0306;
  WM_DESTROYCLIPBOARD = $0307;
  WM_DRAWCLIPBOARD    = $0308;
  WM_PAINTCLIPBOARD   = $0309;
  WM_VSCROLLCLIPBOARD = $030A;
  WM_SIZECLIPBOARD    = $030B;
  WM_ASKCBFORMATNAME  = $030C;
  WM_CHANGECBCHAIN    = $030D;
  WM_HSCROLLCLIPBOARD = $030E;
  WM_QUERYNEWPALETTE  = $030F;
  WM_PALETTEISCHANGING= $0310;
  WM_PALETTECHANGED   = $0311;
  WM_HOTKEY           = $0312;
  WM_PRINT            = 791;
  WM_PRINTCLIENT      = 792;
  { Window Styles }
  WS_DEFAULT = -1;{custom, internal use only}
  WS_OVERLAPPED = 0;
  WS_POPUP = $80000000;
  WS_CHILD = $40000000;
  WS_MINIMIZE = $20000000;
  WS_VISIBLE = $10000000;
  WS_DISABLED = $8000000;
  WS_CLIPSIBLINGS = $4000000;
  WS_CLIPCHILDREN = $2000000;
  WS_MAXIMIZE = $1000000;
  WS_CAPTION = $C00000;      { WS_BORDER or WS_DLGFRAME  }
  WS_BORDER = $800000;
  WS_DLGFRAME = $400000;
  WS_VSCROLL = $200000;
  WS_HSCROLL = $100000;
  WS_SYSMENU = $80000;
  WS_THICKFRAME = $40000;
  WS_GROUP = $20000;
  WS_TABSTOP = $10000;
  WS_MINIMIZEBOX = $20000;
  WS_MAXIMIZEBOX = $10000;
  WS_TILED = WS_OVERLAPPED;
  WS_ICONIC = WS_MINIMIZE;
  WS_SIZEBOX = WS_THICKFRAME;
  { Common Window Styles }
  WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or
    WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX);
  WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW;
  WS_POPUPWINDOW = (WS_POPUP or WS_BORDER or WS_SYSMENU);
  WS_CHILDWINDOW = (WS_CHILD);
  { Extended Window Styles }
  WS_EX_DEFAULT = -1;{custom, internal use only}
  WS_EX_DLGMODALFRAME = 1;
  WS_EX_NOPARENTNOTIFY = 4;
  WS_EX_TOPMOST = 8;
  WS_EX_ACCEPTFILES = $10;
  WS_EX_TRANSPARENT = $20;
  WS_EX_MDICHILD = $40;
  WS_EX_TOOLWINDOW = $80;
  WS_EX_WINDOWEDGE = $100;
  WS_EX_CLIENTEDGE = $200;
  WS_EX_CONTEXTHELP = $400;
  WS_EX_RIGHT = $1000;
  WS_EX_LEFT = 0;
  WS_EX_RTLREADING = $2000;
  WS_EX_LTRREADING = 0;
  WS_EX_LEFTSCROLLBAR = $4000;
  WS_EX_RIGHTSCROLLBAR = 0;
  WS_EX_CONTROLPARENT = $10000;
  WS_EX_STATICEDGE = $20000;
  WS_EX_APPWINDOW = $40000;
  WS_EX_OVERLAPPEDWINDOW = (WS_EX_WINDOWEDGE or WS_EX_CLIENTEDGE);
  WS_EX_PALETTEWINDOW = (WS_EX_WINDOWEDGE or WS_EX_TOOLWINDOW or WS_EX_TOPMOST);
  WS_EX_LAYERED       = $00080000;//27nov2024

   { ShowWindow() Commands }
   SW_HIDE = 0;
   SW_SHOWNORMAL = 1;
   SW_NORMAL = 1;
   SW_SHOWMINIMIZED = 2;
   SW_SHOWMAXIMIZED = 3;
   SW_MAXIMIZE = 3;
   SW_SHOWNOACTIVATE = 4;
   SW_SHOW = 5;
   SW_MINIMIZE = 6;
   SW_SHOWMINNOACTIVE = 7;
   SW_SHOWNA = 8;
   SW_RESTORE = 9;
   SW_SHOWDEFAULT = 10;
   SW_MAX = 10;

   //class styles
   CS_VREDRAW = 1;
   CS_HREDRAW = 2;
   CS_KEYCVTWINDOW = 4;
   CS_DBLCLKS = 8;
   CS_OWNDC = $20;
   CS_CLASSDC = $40;
   CS_PARENTDC = $80;
   CS_NOKEYCVT = $100;
   CS_NOCLOSE = $200;
   CS_SAVEBITS = $800;
   CS_BYTEALIGNCLIENT = $1000;
   CS_BYTEALIGNWINDOW = $2000;
   CS_GLOBALCLASS = $4000;
   CS_IME = $10000;

   //file open modes
   fmOpenRead       = $0000;
   fmOpenWrite      = $0001;
   fmOpenReadWrite  = $0002;
   fmShareCompat    = $0000;
   fmShareExclusive = $0010;
   fmShareDenyWrite = $0020;
   fmShareDenyRead  = $0030;
   fmShareDenyNone  = $0040;

   //file attribute constants
   faReadOnly  = $00000001;
   faHidden    = $00000002;
   faSysFile   = $00000004;
   faVolumeID  = $00000008;
   faDirectory = $00000010;
   faArchive   = $00000020;
   faAnyFile   = $0000003F;

{ TStream seek origins }
  soFromBeginning = 0;
  soFromCurrent = 1;
  soFromEnd = 2;
{ TFileStream create mode }
  fmCreate = $FFFF;

{ Menu flags for AddCheckEnableMenuItem() }

  MF_INSERT = 0;
  MF_CHANGE = $80;
  MF_APPEND = $100;
  MF_DELETE = $200;
  MF_REMOVE = $1000;

  MF_BYCOMMAND = 0;
  MF_BYPOSITION = $400;

  MF_SEPARATOR = $800;

  MF_ENABLED = 0;
  MF_GRAYED = 1;
  MF_DISABLED = 2;

  MF_UNCHECKED = 0;
  MF_CHECKED = 8;
  MF_USECHECKBITMAPS = $200;

  MF_STRING = 0;
  MF_BITMAP = 4;
  MF_OWNERDRAW = $100;

  MF_POPUP = $10;
  MF_MENUBARBREAK = $20;
  MF_MENUBREAK = $40;

  MF_UNHILITE = 0;
  MF_HILITE = $80;

  MF_DEFAULT = $1000;
  MF_SYSMENU = $2000;
  MF_HELP = $4000;
  MF_RIGHTJUSTIFY = $4000;

  MF_MOUSESELECT = $8000;
  MF_END = $80;            { Obsolete -- only used by old RES files }
  MFT_STRING = MF_STRING;
  MFT_BITMAP = MF_BITMAP;
  MFT_MENUBARBREAK = MF_MENUBARBREAK;
  MFT_MENUBREAK = MF_MENUBREAK;
  MFT_OWNERDRAW = MF_OWNERDRAW;
  MFT_RADIOCHECK = $200;
  MFT_SEPARATOR = MF_SEPARATOR;
  MFT_RIGHTORDER = $2000;
  MFT_RIGHTJUSTIFY = MF_RIGHTJUSTIFY;
  { Menu flags for AddCheckEnableMenuItem() }
  MFS_GRAYED = 3;
  MFS_DISABLED = MFS_GRAYED;
  MFS_CHECKED = MF_CHECKED;
  MFS_HILITE = MF_HILITE;
  MFS_ENABLED = MF_ENABLED;
  MFS_UNCHECKED = MF_UNCHECKED;
  MFS_UNHILITE = MF_UNHILITE;
  MFS_DEFAULT = MF_DEFAULT;

  
   //access rights
   _DELETE                  = $00010000;
   READ_CONTROL             = $00020000;
   WRITE_DAC                = $00040000;
   WRITE_OWNER              = $00080000;
   STANDARD_RIGHTS_READ     = READ_CONTROL;
   STANDARD_RIGHTS_WRITE    = READ_CONTROL;
   STANDARD_RIGHTS_EXECUTE  = READ_CONTROL;
   STANDARD_RIGHTS_ALL      = $001F0000;
   SPECIFIC_RIGHTS_ALL      = $0000FFFF;
   ACCESS_SYSTEM_SECURITY   = $01000000;
   MAXIMUM_ALLOWED          = $02000000;
   GENERIC_READ             = -2147483647-1;//was $80000000; - avoids constant range error in Lazarus
   GENERIC_WRITE            = 1073741824;//was $40000000;
//   GENERIC_READ             = $80000000;
//   GENERIC_WRITE            = $40000000;
   GENERIC_EXECUTE          = $20000000;
   GENERIC_ALL              = $10000000;

  //Global Memory Flags
   GMEM_FIXED = 0;
   GMEM_MOVEABLE = 2;
   GMEM_NOCOMPACT = $10;
   GMEM_NODISCARD = $20;
   GMEM_ZEROINIT = $40;
   GMEM_MODIFY = $80;
   GMEM_DISCARDABLE = $100;
   GMEM_NOT_BANKED = $1000;
   GMEM_SHARE = $2000;
   GMEM_DDESHARE = $2000;
   GMEM_NOTIFY = $4000;
   GMEM_LOWER = GMEM_NOT_BANKED;
   GMEM_VALID_FLAGS = 32626;
   GMEM_INVALID_HANDLE = $8000;
   GHND = GMEM_MOVEABLE or GMEM_ZEROINIT;
   GPTR = GMEM_FIXED or GMEM_ZEROINIT;

   //registry
   HKEY_CLASSES_ROOT     =-2147483647-1;// $80000000;
   HKEY_CURRENT_USER     =-2147483647;// $80000001;
   HKEY_LOCAL_MACHINE    =-2147483646;// $80000002;
   HKEY_USERS            =-2147483645;// $80000003;
   HKEY_PERFORMANCE_DATA =-2147483644;// $80000004;
   HKEY_CURRENT_CONFIG   =-2147483643;// $80000005;
   HKEY_DYN_DATA         =-2147483642;// $80000006;
   ERROR_SUCCESS         = 0;
   NO_ERROR              = 0;
   REG_OPTION_NON_VOLATILE = ($00000000);//key is preserved when system is rebooted
   REG_CREATED_NEW_KEY     = ($00000001);//new registry key created
   REG_OPENED_EXISTING_KEY = ($00000002);//existing key opened
   //.registry value types
   REG_NONE                       = 0;
   REG_SZ                         = 1;
   REG_EXPAND_SZ                  = 2;
   REG_BINARY                     = 3;
   REG_DWORD                      = 4;
   REG_DWORD_LITTLE_ENDIAN        = 4;
   REG_DWORD_BIG_ENDIAN           = 5;
   REG_LINK                       = 6;
   REG_MULTI_SZ                   = 7;
   REG_RESOURCE_LIST              = 8;
   REG_FULL_RESOURCE_DESCRIPTOR   = 9;
   REG_RESOURCE_REQUIREMENTS_LIST = 10;

   KEY_QUERY_VALUE    = $0001;
   KEY_SET_VALUE      = $0002;
   KEY_CREATE_SUB_KEY = $0004;
   KEY_ENUMERATE_SUB_KEYS = $0008;
   KEY_NOTIFY         = $0010;
   KEY_CREATE_LINK    = $0020;

   KEY_READ           = (STANDARD_RIGHTS_READ or
                        KEY_QUERY_VALUE or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY) and not
                        SYNCHRONIZE;

   KEY_WRITE          = (STANDARD_RIGHTS_WRITE or
                        KEY_SET_VALUE or
                        KEY_CREATE_SUB_KEY) and not
                        SYNCHRONIZE;

   KEY_EXECUTE        =  KEY_READ and not SYNCHRONIZE;

   KEY_ALL_ACCESS     = (STANDARD_RIGHTS_ALL or
                        KEY_QUERY_VALUE or
                        KEY_SET_VALUE or
                        KEY_CREATE_SUB_KEY or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY or
                        KEY_CREATE_LINK) and not
                        SYNCHRONIZE;

  { Parameter for SystemParametersInfo() }
  SPI_GETBEEP = 1;
  SPI_SETBEEP = 2;
  SPI_GETMOUSE = 3;
  SPI_SETMOUSE = 4;
  SPI_GETBORDER = 5;
  SPI_SETBORDER = 6;
  SPI_GETKEYBOARDSPEED = 10;
  SPI_SETKEYBOARDSPEED = 11;
  SPI_LANGDRIVER = 12;
  SPI_ICONHORIZONTALSPACING = 13;
  SPI_GETSCREENSAVETIMEOUT = 14;
  SPI_SETSCREENSAVETIMEOUT = 15;
  SPI_GETSCREENSAVEACTIVE = $10;
  SPI_SETSCREENSAVEACTIVE = 17;
  SPI_GETGRIDGRANULARITY = 18;
  SPI_SETGRIDGRANULARITY = 19;
  SPI_SETDESKWALLPAPER = 20;
  SPI_SETDESKPATTERN = 21;
  SPI_GETKEYBOARDDELAY = 22;
  SPI_SETKEYBOARDDELAY = 23;
  SPI_ICONVERTICALSPACING = 24;
  SPI_GETICONTITLEWRAP = 25;
  SPI_SETICONTITLEWRAP = 26;
  SPI_GETMENUDROPALIGNMENT = 27;
  SPI_SETMENUDROPALIGNMENT = 28;
  SPI_SETDOUBLECLKWIDTH = 29;
  SPI_SETDOUBLECLKHEIGHT = 30;
  SPI_GETICONTITLELOGFONT = 31;
  SPI_SETDOUBLECLICKTIME = $20;
  SPI_SETMOUSEBUTTONSWAP = 33;
  SPI_SETICONTITLELOGFONT = 34;
  SPI_GETFASTTASKSWITCH = 35;
  SPI_SETFASTTASKSWITCH = 36;
  SPI_SETDRAGFULLWINDOWS = 37;
  SPI_GETDRAGFULLWINDOWS = 38;
  SPI_GETNONCLIENTMETRICS = 41;
  SPI_SETNONCLIENTMETRICS = 42;
  SPI_GETMINIMIZEDMETRICS = 43;
  SPI_SETMINIMIZEDMETRICS = 44;
  SPI_GETICONMETRICS = 45;
  SPI_SETICONMETRICS = 46;
  SPI_SETWORKAREA = 47;
  SPI_GETWORKAREA = 48;
  SPI_SETPENWINDOWS = 49;

  SPI_GETHIGHCONTRAST = 66;
  SPI_SETHIGHCONTRAST = 67;
  SPI_GETKEYBOARDPREF = 68;
  SPI_SETKEYBOARDPREF = 69;
  SPI_GETSCREENREADER = 70;
  SPI_SETSCREENREADER = 71;
  SPI_GETANIMATION = 72;
  SPI_SETANIMATION = 73;
  SPI_GETFONTSMOOTHING = 74;
  SPI_SETFONTSMOOTHING = 75;
  SPI_SETDRAGWIDTH = 76;
  SPI_SETDRAGHEIGHT = 77;
  SPI_SETHANDHELD = 78;
  SPI_GETLOWPOWERTIMEOUT = 79;
  SPI_GETPOWEROFFTIMEOUT = 80;
  SPI_SETLOWPOWERTIMEOUT = 81;
  SPI_SETPOWEROFFTIMEOUT = 82;
  SPI_GETLOWPOWERACTIVE = 83;
  SPI_GETPOWEROFFACTIVE = 84;
  SPI_SETLOWPOWERACTIVE = 85;
  SPI_SETPOWEROFFACTIVE = 86;
  SPI_SETCURSORS = 87;
  SPI_SETICONS = 88;
  SPI_GETDEFAULTINPUTLANG = 89;
  SPI_SETDEFAULTINPUTLANG = 90;
  SPI_SETLANGTOGGLE = 91;
  SPI_GETWINDOWSEXTENSION = 92;
  SPI_SETMOUSETRAILS = 93;
  SPI_GETMOUSETRAILS = 94;
  SPI_SCREENSAVERRUNNING = 97;
  SPI_GETFILTERKEYS = 50;
  SPI_SETFILTERKEYS = 51;
  SPI_GETTOGGLEKEYS = 52;
  SPI_SETTOGGLEKEYS = 53;
  SPI_GETMOUSEKEYS = 54;
  SPI_SETMOUSEKEYS = 55;
  SPI_GETSHOWSOUNDS = 56;
  SPI_SETSHOWSOUNDS = 57;
  SPI_GETSTICKYKEYS = 58;
  SPI_SETSTICKYKEYS = 59;
  SPI_GETACCESSTIMEOUT = 60;
  SPI_SETACCESSTIMEOUT = 61;
  SPI_GETSERIALKEYS = 62;
  SPI_SETSERIALKEYS = 63;
  SPI_GETSOUNDSENTRY = $40;
  SPI_SETSOUNDSENTRY = 65;

  SPI_GETSNAPTODEFBUTTON = 95; 
  SPI_SETSNAPTODEFBUTTON = 96; 
  SPI_GETMOUSEHOVERWIDTH = 98; 
  SPI_SETMOUSEHOVERWIDTH = 99; 
  SPI_GETMOUSEHOVERHEIGHT = 100; 
  SPI_SETMOUSEHOVERHEIGHT = 101; 
  SPI_GETMOUSEHOVERTIME = 102; 
  SPI_SETMOUSEHOVERTIME = 103; 
  SPI_GETWHEELSCROLLLINES = 104; 
  SPI_SETWHEELSCROLLLINES = 105;

   //priority codes
   NORMAL_PRIORITY_CLASS           = $00000020;
   IDLE_PRIORITY_CLASS             = $00000040;
   HIGH_PRIORITY_CLASS             = $00000080;
   REALTIME_PRIORITY_CLASS         = $00000100;

   THREAD_BASE_PRIORITY_LOWRT      = 15;  { value that gets a thread to LowRealtime-1 }
   THREAD_BASE_PRIORITY_IDLE       = -15;  { value that gets a thread to idle }
   THREAD_PRIORITY_NORMAL          = 0;
   THREAD_PRIORITY_TIME_CRITICAL   = THREAD_BASE_PRIORITY_LOWRT;
   THREAD_PRIORITY_IDLE            = THREAD_BASE_PRIORITY_IDLE;


var
   //---------------------------------------------------------------------------
   //Win32 dynamic load support ------------------------------------------------

   lwin_started                  :boolean=false;
   system_wininit                :boolean=false;
   system_wincore                :twincore;

   //---------------------------------------------------------------------------
   //---------------------------------------------------------------------------


//control procs ----------------------------------------------------------------
procedure lwin__start;
procedure lwin__stop;


//dynamic proc suport ----------------------------------------------------------
function win____CreateWindow(lpClassName: PChar; lpWindowName: PChar; dwStyle: DWORD; X, Y, nWidth, nHeight: longint; hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;

procedure win__init;//should be called from app__boot

function win__makeproc(x:string;var xcore:twinscannerinfo;var e:string):boolean;
function win__makeprocs(const sf,df,dversionlabel:string):boolean;
procedure win__make_lwin2_pas;

function win__errmsg(const e:longint):string;
function win__dllname(const xindex:longint):string;
function win__dllname2(const xindex:longint;xincludeext:boolean):string;
function win__finddllname(const xname:string;var xindex:longint):boolean;
procedure win__inc(const xslot:longint);
procedure win__dec;
procedure win__depthtrace(xlimit:longint);

function win__proccount:longint;
function win__proccalls:comp;
function win__procload:longint;
function win__dllload:longint;
function win__infocount:longint;
function win__infofind(xindex:longint;var v1,v2,v3,v4:string;var xtitle:boolean):boolean;
function win__procCallCount(const xslot:longint):comp;


function win__procname(const xslot:longint):string;
function win__slotinfo(const xslot:longint;var dname,rvalue:longint;var pname:string;var xmisc:string):boolean;

function win__ok(const xslot:longint):boolean;
function win__loaded(const xslot:longint):boolean;
function win__usebol(var xdefresult:bool;const xslot:longint;var xptr:pointer):boolean;////26sep2025
function win__usewrd(var xdefresult:word;const xslot:longint;var xptr:pointer):boolean;//26sep2025
function win__useint(var xdefresult:longint;const xslot:longint;var xptr:pointer):boolean;//26sep2025
function win__useptr(var xdefresult:pointer;const xslot:longint;var xptr:pointer):boolean;
function win__usehnd(var xdefresult:thandle;const xslot:longint;var xptr:pointer):boolean;
function win__use(const xslot:longint;var xptr:pointer):boolean;

procedure win__errbol(var xresult:bool;const xreturn:bool);
procedure win__errwrd(var xresult:word;const xreturn:word);
procedure win__errint(var xresult:longint;const xreturn:longint);
procedure win__errptr(var xresult:pointer;const xreturn:pointer);
procedure win__errhnd(var xresult:thandle;const xreturn:thandle);


//registry procs ---------------------------------------------------------------
function reg__openkey(xrootkey:hkey;xuserkey:string;var xoutkey:hkey):boolean;
function reg__closekey(var xkey:hkey):boolean;
function reg__deletekey(xrootkey:hkey;xuserkey:string):boolean;
function reg__setstr(xkey:hkey;const xname,xvalue:string):boolean;
function reg__setstrx(xkey:hkey;xname,xvalue:string):boolean;
function reg__setint(xkey:hkey;xname:string;xvalue:longint):boolean;
function reg__readval(xrootstyle:longint;xname:string;xuseint:boolean):string;



//############################################################################################################################################################
//##
//## Win32 API Calls ( Part I )
//##
//## The following Win32 api procs are included below for reference purposes only.  They can be used directly,
//## and statically linked in code, as they run on Windows 95/98.  But their definitions are primarily for automatic
//## code generation and conversion into dynamic loading versions of the same name, as well as providing the codebase
//## with realtime diagnostic and usage information.
//##
//## The proc prefixes "win____" and "net____" designate them as Win95/98 compatible
//##
//## Code automation performed by "win__make_gosswin2_pas()".  A special "default" variable list can be
//## specified, per proc, in the format "[[..a list of semi-colon separated name-value pairs..]]".  This provides the code
//## scanner with additional information, like a return value when the proc is unable to load, along with optional additional
//## information.
//##
//## [win32-api-scanner-start-point] - 30aug2025
//##
{$ifdef emergencyfallback}// - use when dynamic procs need maintanence or due to a failure (Win10+ only)
//##
//############################################################################################################################################################

const win____emergencyfallback_engaged=true;

function win____ChooseColor(var CC: TChooseColor): Bool; stdcall; external comdlg32  name 'ChooseColorA';
function win____GetSaveFileName(var OpenFile: TOpenFilename): Bool; stdcall; external comdlg32  name 'GetSaveFileNameA';
function win____GetOpenFileName(var OpenFile: TOpenFilename): Bool; stdcall; external comdlg32 name 'GetOpenFileNameA';
function win____RedrawWindow(hWnd: HWND; lprcUpdate: pwinrect; hrgnUpdate: HRGN; flags: UINT): BOOL; stdcall; external user32 name 'RedrawWindow';
function win____CreatePopupMenu:HMENU; stdcall; external user32 name 'CreatePopupMenu';
function win____AppendMenu(hMenu: HMENU; uFlags, uIDNewItem: UINT; lpNewItem: PChar): BOOL; stdcall; external user32 name 'AppendMenuA';
function win____GetSubMenu(hMenu: HMENU; nPos: Integer): HMENU; stdcall; external user32 name 'GetSubMenu';
function win____GetMenuItemID(hMenu: HMENU; nPos: Integer): UINT; stdcall; external user32 name 'GetMenuItemID';
function win____GetMenuItemCount(hMenu: HMENU): Integer; stdcall; external user32 name 'GetMenuItemCount';
function win____CheckMenuItem(hMenu: HMENU; uIDCheckItem, uCheck: UINT): DWORD; stdcall; external user32 name 'CheckMenuItem';
function win____EnableMenuItem(hMenu: HMENU; uIDEnableItem, uEnable: UINT): BOOL; stdcall; external user32 name 'EnableMenuItem';
function win____InsertMenuItem(p1: HMENU; p2: UINT; p3: BOOL; const p4: twinmenuiteminfo): BOOL; stdcall; external user32 name 'InsertMenuItemA';
function win____DestroyMenu(hMenu: HMENU): BOOL; stdcall; external user32 name 'DestroyMenu';
function win____TrackPopupMenu(hMenu: HMENU; uFlags: UINT; x, y, nReserved: Integer; hWnd: HWND; prcRect: pwinrect): BOOL; stdcall; external user32 name 'TrackPopupMenu';

function win____GetFocus:HWND; stdcall; stdcall; external user32 name 'GetFocus';
function win____SetFocus(hWnd: HWND): HWND; stdcall; external user32 name 'SetFocus';
function win____GetParent(hWnd: HWND): HWND; stdcall; external user32 name 'GetParent';
function win____SetParent(hWndChild, hWndNewParent: HWND): HWND; stdcall; external user32 name 'SetParent';

function win____CreateDirectory(lpPathName: PChar; lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall; external kernel32 name 'CreateDirectoryA';
function win____GetFileAttributes(lpFileName: PChar): DWORD; stdcall; external kernel32 name 'GetFileAttributesA';
procedure win____GetLocalTime(var lpSystemTime: TSystemTime); stdcall; external kernel32 name 'GetLocalTime';
function win____SetLocalTime(const lpSystemTime: TSystemTime): BOOL; stdcall; external kernel32 name 'SetLocalTime';
function win____DeleteFile(lpFileName: PChar): BOOL; stdcall; external kernel32 name 'DeleteFileA';
function win____MoveFile(lpExistingFileName, lpNewFileName: PChar): BOOL; stdcall; external kernel32 name 'MoveFileA';
function win____SetFileAttributes(lpFileName: PChar; dwFileAttributes: DWORD): BOOL; stdcall; external kernel32 name 'SetFileAttributesA';
function win____GetBitmapBits(Bitmap: HBITMAP; Count: Longint; Bits: Pointer): Longint; stdcall; external gdi32 name 'GetBitmapBits';
function win____GetDIBits(DC: HDC; Bitmap: HBitmap; StartScan, NumScans: UINT; Bits: Pointer; var BitInfo: TBitmapInfoHeader; Usage: UINT): Integer; stdcall; external gdi32 name 'GetDIBits';
function win____IsClipboardFormatAvailable(format: UINT): BOOL; stdcall; external user32 name 'IsClipboardFormatAvailable';
function win____EmptyClipboard: BOOL; stdcall; external user32 name 'EmptyClipboard';
function win____OpenClipboard(hWndNewOwner: HWND): BOOL; stdcall; external user32 name 'OpenClipboard';
function win____CloseClipboard: BOOL; stdcall; external user32 name 'CloseClipboard';
function win____GdiFlush: BOOL; stdcall; external gdi32 name 'GdiFlush';
function win____CreateCompatibleDC(DC: HDC): HDC; stdcall; external gdi32 name 'CreateCompatibleDC';
function win____CreateDIBSection(DC: HDC; const p2: TBitmapInfoHeader; p3: UINT; var p4: Pointer; p5: THandle; p6: DWORD): HBITMAP; stdcall; external gdi32 name 'CreateDIBSection';
function win____CreateCompatibleBitmap(DC: HDC; Width, Height: Integer): HBITMAP; stdcall; external gdi32 name 'CreateCompatibleBitmap';
function win____CreateBitmap(Width, Height: Integer; Planes, BitCount: Longint; Bits: Pointer): HBITMAP; stdcall; external gdi32 name 'CreateBitmap';
function win____SetTextColor(DC: HDC; Color: COLORREF): COLORREF; stdcall; external gdi32 name 'SetTextColor';
function win____SetBkColor(DC: HDC; Color: COLORREF): COLORREF; stdcall; external gdi32 name 'SetBkColor';
function win____SetBkMode(DC: HDC; BkMode: Integer): Integer; stdcall; external gdi32 name 'SetBkMode';
function win____CreateBrushIndirect(const p1: TLogBrush): HBRUSH; stdcall; external gdi32 name 'CreateBrushIndirect';
function win____MulDiv(nNumber, nNumerator, nDenominator: Integer): Integer; stdcall; external kernel32 name 'MulDiv';
function win____GetSysColor(nIndex: Integer): DWORD; stdcall; external user32 name 'GetSysColor';
function win____ExtTextOut(DC: HDC; X, Y: Integer; Options: Longint; Rect: PwinRect; Str: PChar; Count: Longint; Dx: PInteger): BOOL; stdcall; external gdi32 name 'ExtTextOutA';
function win____GetDesktopWindow: HWND; stdcall; external user32 name 'GetDesktopWindow';

//function win____HeapCreate(flOptions, dwInitialSize, dwMaximumSize: DWORD): THandle; stdcall; external kernel32 name 'HeapCreate';
//function win____HeapDestroy(hHeap: THandle): BOOL; stdcall; external kernel32 name 'HeapDestroy';
//function win____HeapValidate(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer): BOOL; stdcall; external kernel32 name 'HeapValidate';
//function win____HeapCompact(hHeap: THandle; dwFlags: DWORD): UINT; stdcall; external kernel32 name 'HeapCompact';

//recommended memory support by MS
function win____HeapAlloc(hHeap: THandle; dwFlags, dwBytes: DWORD): Pointer; stdcall; external kernel32 name 'HeapAlloc';
function win____HeapReAlloc(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer; dwBytes: DWORD): Pointer; stdcall; external kernel32 name 'HeapReAlloc';
function win____HeapSize(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer): DWORD; stdcall; external kernel32 name 'HeapSize';
function win____HeapFree(hHeap: THandle; dwFlags: DWORD; lpMem: Pointer): BOOL; stdcall; external kernel32 name 'HeapFree';

//legacy memory support - mainly for Clipboard functions etc
function win____GlobalHandle(Mem: Pointer): HGLOBAL; stdcall; external kernel32 name 'GlobalHandle';
function win____GlobalSize(hMem: HGLOBAL): DWORD; stdcall; external kernel32 name 'GlobalSize';
function win____GlobalFree(hMem: HGLOBAL): HGLOBAL; stdcall; external kernel32 name 'GlobalFree';
function win____GlobalUnlock(hMem: HGLOBAL): BOOL; stdcall; external kernel32 name 'GlobalUnlock';

function win____GetClipboardData(uFormat: UINT): THandle; stdcall; external user32 name 'GetClipboardData';
function win____SetClipboardData(uFormat: UINT; hMem: THandle): THandle; stdcall; external user32 name 'SetClipboardData';
function win____GlobalLock(hMem: HGLOBAL): Pointer; stdcall; external kernel32 name 'GlobalLock';
function win____GlobalAlloc(uFlags: UINT; dwBytes: DWORD): HGLOBAL; stdcall; external kernel32 name 'GlobalAlloc';
function win____GlobalReAlloc(hMem: HGLOBAL; dwBytes: DWORD; uFlags: UINT): HGLOBAL; stdcall; external kernel32 name 'GlobalReAlloc';
function win____LoadCursorFromFile(lpFileName: PAnsiChar): HCURSOR; stdcall; external user32 name 'LoadCursorFromFileA';

function win____GetDefaultPrinter(xbuffer:pointer;var xsize:longint):bool; stdcall; external winspl name 'GetDefaultPrinterA';
function win____GetVersionEx(var lpVersionInformation: TOSVersionInfo): BOOL; stdcall; external kernel32 name 'GetVersionExA';
function win____EnumPrinters(Flags: DWORD; Name: PChar; Level: DWORD; pPrinterEnum: Pointer; cbBuf: DWORD; var pcbNeeded, pcReturned: DWORD): BOOL; stdcall; external winspl name 'EnumPrintersA';

function win____CreateIC(lpszDriver, lpszDevice, lpszOutput: PChar; lpdvmInit: PDeviceModeA): HDC; stdcall; external gdi32 name 'CreateICA';
function win____GetProfileString(lpAppName, lpKeyName, lpDefault: PChar; lpReturnedString: PChar; nSize: DWORD): DWORD; stdcall; external kernel32 name 'GetProfileStringA';
function win____GetDC(hWnd: HWND): HDC; stdcall; external user32 name 'GetDC';
function win____GetVersion: DWORD; stdcall; external kernel32 name 'GetVersion';
function win____EnumFonts(DC: HDC; lpszFace: PChar; fntenmprc: TFarProc; lpszData: PChar): Integer; stdcall; external gdi32 name 'EnumFontsA';
function win____EnumFontFamiliesEx(DC: HDC; var p2: TLogFont; p3: TFarProc; p4: LPARAM; p5: DWORD): BOOL; stdcall; external gdi32 name 'EnumFontFamiliesExA';
function win____GetStockObject(Index: Integer): HGDIOBJ; stdcall; external gdi32 name 'GetStockObject';
function win____GetCurrentThread: THandle; stdcall; external kernel32 name 'GetCurrentThread';
function win____GetCurrentThreadId: DWORD; stdcall; external kernel32 name 'GetCurrentThreadId';
//function win____SetWindowsHookExA(idHook: Integer; lpfn: TFNHookProc; hmod: HINST; dwThreadId: DWORD): HHOOK; stdcall; external user32 name 'SetWindowsHookExA';
//function win____UnhookWindowsHookEx(hhk: HHOOK): BOOL; stdcall; external user32 name 'UnhookWindowsHookEx';
//function win____CallNextHookEx(hhk: HHOOK; nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; external user32 name 'CallNextHookEx';
function win____ClipCursor(lpRect: pwinrect): BOOL; stdcall; external user32 name 'ClipCursor';
function win____GetClipCursor(var lpRect: twinrect): BOOL; stdcall; external user32 name 'CloseClipboard';
function win____GetCapture: HWND; stdcall; external user32 name 'GetCapture';
function win____SetCapture(hWnd: HWND): HWND; stdcall; external user32 name 'SetCapture';
function win____ReleaseCapture: BOOL; stdcall; external user32 name 'ReleaseCapture';
function win____PostMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall; external user32 name 'PostMessageA';
function win____SetClassLong(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): DWORD; stdcall; external user32 name 'SetClassLongA';
function win____SetFocus(hWnd: HWND): HWND; stdcall; external user32 name 'SetFocus';
function win____GetActiveWindow: HWND; stdcall; external user32 name 'GetActiveWindow';
function win____GetFocus: HWND; stdcall; external user32 name 'GetFocus';
function win____ShowCursor(bShow: BOOL): Integer; stdcall; external user32 name 'ShowCursor';
function win____SetCursorPos(X, Y: Integer): BOOL; stdcall; external user32 name 'SetCursorPos';
function win____SetCursor(hCursor: HICON): HCURSOR; stdcall; external user32 name 'SetCursor';
function win____GetCursor: HCURSOR; stdcall; external user32 name 'GetCursor';
function win____GetCursorPos(var lpPoint: TPoint): BOOL; stdcall; external user32 name 'GetCursorPos';
function win____GetWindowText(hWnd: HWND; lpString: PChar; nMaxCount: Integer): Integer; stdcall; external user32 name 'GetWindowTextA';
function win____GetWindowTextLength(hWnd: HWND): Integer; stdcall; external user32 name 'GetWindowTextLengthA';
function win____SetWindowText(hWnd: HWND; lpString: PChar): BOOL; stdcall; external user32 name 'SetWindowTextA';
function win____GetModuleHandle(lpModuleName: PChar): HMODULE; stdcall; external kernel32 name 'GetModuleHandleA';
function win____GetWindowPlacement(hWnd: HWND; WindowPlacement: PWindowPlacement): BOOL; stdcall; external user32 name 'GetWindowPlacement';
function win____SetWindowPlacement(hWnd: HWND; WindowPlacement: PWindowPlacement): BOOL; stdcall; external user32 name 'SetWindowPlacement';
function win____GetTextExtentPoint(DC: HDC; Str: PChar; Count: Integer; var Size: tpoint): BOOL; stdcall; external gdi32 name 'GetTextExtentPointA';
function win____TextOut(DC: HDC; X, Y: Integer; Str: PChar; Count: Integer): BOOL; stdcall; external gdi32 name 'TextOutA';
function win____GetSysColorBrush(xindex:longint): HBRUSH; stdcall; external user32 name 'GetSysColorBrush';
function win____CreateSolidBrush(p1: COLORREF): HBRUSH; stdcall; external gdi32 name 'CreateSolidBrush';
function win____LoadIcon(hInstance: HINST; lpIconName: PChar): HICON; stdcall; external user32 name 'LoadIconA';
function win____LoadCursor(hInstance: HINST; lpCursorName: PAnsiChar): HCURSOR; stdcall; external user32 name 'LoadCursorA';
function win____FillRect(hDC: HDC; const lprc: twinrect; hbr: HBRUSH): Integer; stdcall; external user32 name 'FillRect';
function win____FrameRect(hDC: HDC; const lprc: twinrect; hbr: HBRUSH): Integer; stdcall; external user32 name 'FrameRect';
function win____InvalidateRect(hWnd: HWND; lpwinrect: pwinrect; bErase: BOOL): BOOL; stdcall; external user32 name 'InvalidateRect';
function win____StretchBlt(DestDC: HDC; X, Y, Width, Height: Integer; SrcDC: HDC; XSrc, YSrc, SrcWidth, SrcHeight: Integer; Rop: DWORD): BOOL; stdcall; external gdi32 name 'StretchBlt';
function win____GetClientwinrect(hWnd: HWND; var lpwinrect: twinrect): BOOL; stdcall; external user32 name 'GetClientwinrect';
function win____GetWindowRect(hWnd: HWND; var lpwinrect: twinrect): BOOL; stdcall; external user32 name 'GetWindowRect';
function win____GetClientRect(hWnd: HWND; var lpRect: twinrect): BOOL; stdcall; external user32 name 'GetClientRect';
function win____MoveWindow(hWnd: HWND; X, Y, nWidth, nHeight: Integer; bRepaint: BOOL): BOOL; stdcall; external user32 name 'MoveWindow';
function win____SetWindowPos(hWnd: HWND; hWndInsertAfter: HWND; X, Y, cx, cy: Integer; uFlags: UINT): BOOL; stdcall; external user32 name 'SetWindowPos';
function win____DestroyWindow(hWnd: HWND): BOOL; stdcall; external user32 name 'DestroyWindow';
function win____ShowWindow(hWnd: HWND; nCmdShow: Integer): BOOL; stdcall; external user32 name 'ShowWindow';
function win____RegisterClassExA(const WndClass: TWndClassExA): ATOM; stdcall; external user32 name 'RegisterClassExA';
function win____IsWindowVisible(hWnd: HWND): BOOL; stdcall; external user32 name 'IsWindowVisible';
function win____IsIconic(hWnd: HWND): BOOL; stdcall; external user32 name 'IsIconic';
function win____GetWindowDC(hWnd: HWND): HDC; stdcall; external user32 name 'GetWindowDC';
function win____ReleaseDC(hWnd: HWND; hDC: HDC): Integer; stdcall; external user32 name 'ReleaseDC';
function win____BeginPaint(hWnd: HWND; var lpPaint: TPaintStruct): HDC; stdcall; external user32 name 'BeginPaint';
function win____EndPaint(hWnd: HWND; const lpPaint: TPaintStruct): BOOL; stdcall; external user32 name 'EndPaint';
function win____SendMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; external user32 name 'SendMessageA';
function win____EnumDisplaySettingsA(lpszDeviceName: PAnsiChar; iModeNum: DWORD; var lpDevMode: TDeviceModeA): BOOL; stdcall; external user32 name 'EnumDisplaySettingsA';
function win____CreateDC(lpszDriver, lpszDevice, lpszOutput: PAnsiChar; lpdvmInit: PDeviceModeA): HDC; stdcall; external gdi32 name 'CreateDCA';
function win____DeleteDC(DC: HDC): BOOL; stdcall; external gdi32 name 'DeleteDC';
function win____GetDeviceCaps(DC: HDC; Index: Integer): Integer; stdcall; external gdi32 name 'GetDeviceCaps';
function win____GetSystemMetrics(nIndex: Integer): Integer; stdcall; external user32 name 'GetSystemMetrics';
function win____CreateRectRgn(p1, p2, p3, p4: Integer): HRGN; stdcall; external gdi32 name 'CreateRectRgn';
function win____CreateRoundRectRgn(p1, p2, p3, p4, p5, p6: Integer): HRGN; stdcall; external gdi32 name 'CreateRoundRectRgn';
function win____GetRgnBox(RGN: HRGN; var p2: twinrect): Integer; stdcall; external gdi32 name 'GetRgnBox';
function win____SetWindowRgn(hWnd: HWND; hRgn: HRGN; bRedraw: BOOL): BOOL; stdcall; external user32 name 'SetWindowRgn';
function win____PostThreadMessage(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall; external user32 name 'PostThreadMessageA';
function win____SetWindowLong(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): Longint; stdcall; external user32 name 'SetWindowLongA';
function win____GetWindowLong(hWnd: HWND; nIndex: Integer): Longint; stdcall; external user32 name 'GetWindowLongA';
function win____CallWindowProc(lpPrevWndFunc: TFNWndProc; hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; external user32 name 'CallWindowProcA';
function win____SystemParametersInfo(uiAction, uiParam: UINT; pvParam: Pointer; fWinIni: UINT): BOOL; stdcall; external user32 name 'SystemParametersInfoA';
function win____RegisterClipboardFormat(lpszFormat: PChar): UINT; stdcall; external user32 name 'RegisterClipboardFormatA';
function win____CountClipboardFormats: Integer; stdcall; external user32 name 'CountClipboardFormats';
function win____ClientToScreen(hWnd: HWND; var lpPoint: tpoint): BOOL; stdcall; external user32 name 'ClientToScreen';
function win____ScreenToClient(hWnd: HWND; var lpPoint: tpoint): BOOL; stdcall; external user32 name 'ScreenToClient';
procedure win____DragAcceptFiles(Wnd: HWND; Accept: BOOL); stdcall; external shell32 name 'DragAcceptFiles';
function win____DragQueryFile(Drop: HDROP; FileIndex: UINT; FileName: PChar; cb: UINT): UINT; stdcall; external shell32 name 'DragQueryFileA';
procedure win____DragFinish(Drop: HDROP); stdcall; external shell32 name 'DragFinish';
function win____SetTimer(hWnd: HWND; nIDEvent, uElapse: UINT; lpTimerFunc: TFNTimerProc): UINT; stdcall; external user32 name 'SetTimer';
function win____KillTimer(hWnd: HWND; uIDEvent: UINT): BOOL; stdcall; external user32 name 'KillTimer';
function win____WaitMessage:bool; stdcall; external user32 name 'WaitMessage';
function win____GetProcessHeap: THandle; stdcall; external kernel32 name 'GetProcessHeap';
function win____SetPriorityClass(hProcess: THandle; dwPriorityClass: DWORD): BOOL; stdcall; external kernel32 name 'SetPriorityClass';
function win____GetPriorityClass(hProcess: THandle): DWORD; stdcall; external kernel32 name 'GetPriorityClass';
function win____SetThreadPriority(hThread: THandle; nPriority: Integer): BOOL; stdcall; external kernel32 name 'SetThreadPriority';
function win____SetThreadPriorityBoost(hThread: THandle; DisablePriorityBoost: Bool): BOOL; stdcall; external kernel32 name 'SetThreadPriorityBoost';
function win____GetThreadPriority(hThread: THandle): Integer; stdcall; external kernel32 name 'GetThreadPriority';
function win____GetThreadPriorityBoost(hThread: THandle; var DisablePriorityBoost: Bool): BOOL; stdcall; external kernel32 name 'GetThreadPriorityBoost';

function win____CoInitializeEx(pvReserved: Pointer; coInit: Longint): HResult; stdcall; external ole32 name 'CoInitializeEx';
function win____CoInitialize(pvReserved: Pointer): HResult; stdcall; external ole32 name 'CoInitialize';
procedure win____CoUninitialize; stdcall; external ole32 name 'CoUninitialize';

//function win____InterlockedIncrement(var Addend: Integer): Integer; stdcall; external kernel32 name 'InterlockedIncrement';
//function win____InterlockedDecrement(var Addend: Integer): Integer; stdcall; external kernel32 name 'InterlockedDecrement';
//function win____InterlockedExchange(var Target: Integer; Value: Integer): Integer; stdcall; external kernel32 name 'InterlockedExchange';

function win____CreateMutexA(lpMutexAttributes: PSecurityAttributes; bInitialOwner: BOOL; lpName: PAnsiChar): THandle; stdcall; external kernel32 name 'CreateMutexA';
function win____ReleaseMutex(hMutex: THandle): BOOL; stdcall; external kernel32 name 'ReleaseMutex';

function win____WaitForSingleObject(hHandle: THandle; dwMilliseconds: DWORD): DWORD; stdcall; external kernel32 name 'WaitForSingleObject';
function win____WaitForSingleObjectEx(hHandle: THandle; dwMilliseconds: DWORD; bAlertable: BOOL): DWORD; stdcall; external kernel32 name 'WaitForSingleObjectEx';

function win____CreateEvent(lpEventAttributes: PSecurityAttributes; bManualReset, bInitialState: BOOL; lpName: PAnsiChar): THandle; stdcall; external kernel32 name 'CreateEventA';
function win____SetEvent(hEvent: THandle): BOOL; stdcall; external kernel32 name 'SetEvent';
function win____ResetEvent(hEvent: THandle): BOOL; stdcall; external kernel32 name 'ResetEvent';
function win____PulseEvent(hEvent: THandle): BOOL; stdcall; external kernel32 name 'PulseEvent';

//procedure win____InitializeCriticalSection(var lpCriticalSection: TRTLCriticalSection); stdcall; external kernel32 name 'InitializeCriticalSection';
//procedure win____EnterCriticalSection(var lpCriticalSection: TRTLCriticalSection); stdcall; external kernel32 name 'EnterCriticalSection';
//procedure win____LeaveCriticalSection(var lpCriticalSection: TRTLCriticalSection); stdcall; external kernel32 name 'LeaveCriticalSection';
//Note: "win____TryEnterCriticalSection()" does not work on Win98 - 30aug2025
//function win____TryEnterCriticalSection(var lpCriticalSection: TRTLCriticalSection): BOOL; stdcall; external kernel32 name 'TryEnterCriticalSection';
//procedure win____DeleteCriticalSection(var lpCriticalSection: TRTLCriticalSection); stdcall; external kernel32 name 'DeleteCriticalSection';

function win____InterlockedIncrement(var Addend: Integer): Integer; stdcall; external kernel32 name 'InterlockedIncrement';
function win____InterlockedDecrement(var Addend: Integer): Integer; stdcall; external kernel32 name 'InterlockedDecrement';

function win____GetFileVersionInfoSize(lptstrFilename: PAnsiChar; var lpdwHandle: DWORD): DWORD; stdcall; external version name 'GetFileVersionInfoSizeA';
function win____GetFileVersionInfo(lptstrFilename: PAnsiChar; dwHandle, dwLen: DWORD; lpData: Pointer): BOOL; stdcall; external version name 'GetFileVersionInfoA';
function win____VerQueryValue(pBlock: Pointer; lpSubBlock: PAnsiChar; var lplpBuffer: Pointer; var puLen: UINT): BOOL; stdcall; external version name 'VerQueryValueA';

function win____GetCurrentProcessId: DWORD; stdcall; external kernel32 name 'GetCurrentProcessId';
procedure win____ExitProcess(uExitCode: UINT); stdcall; external kernel32 name 'ExitProcess';

function win____GetExitCodeProcess(hProcess: THandle; var lpExitCode: DWORD): BOOL; stdcall; external kernel32 name 'GetExitCodeProcess';
function win____CreateThread(lpThreadAttributes: Pointer; dwStackSize: DWORD; lpStartAddress: TFNThreadStartRoutine; lpParameter: Pointer; dwCreationFlags: DWORD; var lpThreadId: DWORD): THandle; stdcall; external kernel32 name 'CreateThread';
function win____SuspendThread(hThread: THandle): DWORD; stdcall; external kernel32 name 'SuspendThread';
function win____ResumeThread(hThread: THandle): DWORD; stdcall; external kernel32 name 'ResumeThread';
function win____GetCurrentProcess: THandle; stdcall; external kernel32 name 'GetCurrentProcess';
function win____GetLastError: DWORD; stdcall; external kernel32 name 'GetLastError';
function win____GetStdHandle(nStdHandle: DWORD): THandle; stdcall; external kernel32 name 'GetStdHandle';
function win____SetStdHandle(nStdHandle: DWORD; hHandle: THandle): BOOL; stdcall; external kernel32 name 'SetStdHandle';
function win____GetConsoleScreenBufferInfo(hConsoleOutput: THandle; var lpConsoleScreenBufferInfo: TConsoleScreenBufferInfo): BOOL; stdcall; external kernel32 name 'GetConsoleScreenBufferInfo';
function win____FillConsoleOutputCharacter(hConsoleOutput: THandle; cCharacter: Char; nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfCharsWritten: DWORD): BOOL; stdcall; external kernel32 name 'FillConsoleOutputCharacterA';
function win____FillConsoleOutputAttribute(hConsoleOutput: THandle; wAttribute: Word; nLength: DWORD; dwWriteCoord: TCoord; var lpNumberOfAttrsWritten: DWORD): BOOL; stdcall; external kernel32 name 'FillConsoleOutputAttribute';
function win____GetConsoleMode(hConsoleHandle: THandle; var lpMode: DWORD): BOOL; stdcall; external kernel32 name 'GetConsoleMode';
function win____SetConsoleCursorPosition(hConsoleOutput: THandle; dwCursorPosition: TCoord): BOOL; stdcall; external kernel32 name 'SetConsoleCursorPosition';
function win____SetConsoleTitle(lpConsoleTitle: PChar): BOOL; stdcall; external kernel32 name 'SetConsoleTitleA';
function win____SetConsoleCtrlHandler(HandlerRoutine: TFNHandlerRoutine; Add: BOOL): BOOL; stdcall; external kernel32 name 'SetConsoleCtrlHandler';
function win____GetNumberOfConsoleInputEvents(hConsoleInput: THandle; var lpNumberOfEvents: DWORD): BOOL; stdcall; external kernel32 name 'GetNumberOfConsoleInputEvents';
function win____ReadConsoleInput(hConsoleInput: THandle; var lpBuffer: TInputRecord; nLength: DWORD; var lpNumberOfEventsRead: DWORD): BOOL; stdcall; external kernel32 name 'ReadConsoleInputA';
function win____GetMessage(var lpMsg: TMsg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall; external user32 name 'GetMessageA';
function win____PeekMessage(var lpMsg: tmsg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall; external user32 name 'PeekMessageA';
function win____DispatchMessage(const lpMsg: tmsg): Longint; stdcall; external user32 name 'DispatchMessageA';
function win____TranslateMessage(const lpMsg: tmsg): BOOL; stdcall; external user32 name 'TranslateMessage';
function win____GetDriveType(lpRootPathName: PChar): UINT; stdcall; external kernel32 name 'GetDriveTypeA';
function win____SetErrorMode(uMode: UINT): UINT; stdcall; external kernel32 name 'SetErrorMode';
procedure win____ExitThread(dwExitCode: DWORD); stdcall; external kernel32 name 'ExitThread';
function win____TerminateThread(hThread: THandle; dwExitCode: DWORD): BOOL; stdcall; external kernel32 name 'TerminateThread';
function win____QueryPerformanceCounter(var lpPerformanceCount: comp): BOOL; stdcall; external kernel32 name 'QueryPerformanceCounter';
function win____QueryPerformanceFrequency(var lpFrequency: comp): BOOL; stdcall; external kernel32 name 'QueryPerformanceFrequency';

function win____GetVolumeInformation(lpRootPathName: PChar; lpVolumeNameBuffer: PChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD; var lpMaximumComponentLength, lpFileSystemFlags: DWORD; lpFileSystemNameBuffer: PChar; nFileSystemNameSize: DWORD): BOOL; stdcall; external kernel32 name 'GetVolumeInformationA';
function win____GetShortPathName(lpszLongPath: PChar; lpszShortPath: PChar; cchBuffer: DWORD): DWORD; stdcall; external kernel32 name 'GetShortPathNameA';

function win____SHGetSpecialFolderLocation(hwndOwner: HWND; nFolder: Integer; var ppidl: PItemIDList): HResult; stdcall; external shell32 name 'SHGetSpecialFolderLocation';
function win____SHGetPathFromIDList(pidl: PItemIDList; pszPath: PChar): BOOL; stdcall; external shell32 name 'SHGetPathFromIDListA';
function win____GetWindowsDirectoryA(lpBuffer: PAnsiChar; uSize: UINT): UINT; stdcall; external kernel32 name 'GetWindowsDirectoryA';
function win____GetSystemDirectoryA(lpBuffer: PAnsiChar; uSize: UINT): UINT; stdcall; external kernel32 name 'GetSystemDirectoryA';
function win____GetTempPathA(nBufferLength: DWORD; lpBuffer: PAnsiChar): DWORD; stdcall; external kernel32 name 'GetTempPathA';
function win____FlushFileBuffers(hFile: THandle): BOOL; stdcall; external kernel32 name 'FlushFileBuffers';
function win____CreateFile(lpFileName: PChar; dwDesiredAccess, dwShareMode: Integer; lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD; hTemplateFile: THandle): THandle; stdcall; external kernel32 name 'CreateFileA';
function win____GetFileSize(hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall; external kernel32 name 'GetFileSize';
procedure win____GetSystemTime(var lpSystemTime: TSystemTime); stdcall; external kernel32 name 'GetSystemTime';
function win____CloseHandle(hObject: THandle): BOOL; stdcall; external kernel32 name 'CloseHandle';
function win____GetFileInformationByHandle(hFile: THandle; var lpFileInformation: TByHandleFileInformation): BOOL; stdcall; external kernel32 name 'GetFileInformationByHandle';
function win____SetFilePointer(hFile: THandle; lDistanceToMove: Longint; lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall; external kernel32 name 'SetFilePointer';
function win____SetEndOfFile(hFile: THandle): BOOL; stdcall; external kernel32 name 'SetEndOfFile';
function win____WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD; var lpNumberOfBytesWritten: DWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'WriteFile';
function win____ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall; external kernel32 name 'ReadFile';
function win____GetLogicalDrives: DWORD; stdcall; external kernel32 name 'GetLogicalDrives';
function win____FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall; external kernel32 name 'FileTimeToLocalFileTime';
function win____FileTimeToDosDateTime(const lpFileTime: TFileTime; var lpFatDate, lpFatTime: Word): BOOL; stdcall; external kernel32 name 'FileTimeToDosDateTime';
function win____DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; external user32 name 'DefWindowProcA';
function win____RegisterClass(const lpWndClass: TWndClass): ATOM; stdcall; external user32 name 'RegisterClassA';
function win____RegisterClassA(const lpWndClass: TWndClassA): ATOM; stdcall; external user32 name 'RegisterClassA';

function win____CreateWindowEx(dwExStyle: DWORD; lpClassName: PChar; lpWindowName: PChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND; stdcall; external user32 name 'CreateWindowExA';
function win____EnableWindow(hWnd: HWND; bEnable: BOOL): BOOL; stdcall; external user32 name 'EnableWindow';
function win____IsWindowEnabled(hWnd: HWND): BOOL; stdcall; external user32 name 'IsWindowEnabled';
function win____UpdateWindow(hWnd: HWND): BOOL; stdcall; external user32 name 'UpdateWindow';

function win____ShellExecute(hWnd: HWND; Operation, FileName, Parameters, Directory: PChar; ShowCmd: Integer): HINST; stdcall; external shell32 name 'ShellExecuteA';
function win____ShellExecuteEx(lpExecInfo: PShellExecuteInfo):BOOL; stdcall; external shell32 name 'ShellExecuteExA';

function win____SHGetMalloc(var ppMalloc: imalloc): HResult; stdcall; external shell32 name 'SHGetMalloc';
function win____CoCreateInstance(const clsid: TCLSID; unkOuter: IUnknown; dwClsContext: Longint; const iid: TIID; out pv): HResult; stdcall; external ole32 name 'CoCreateInstance';
function win____GetObject(p1: HGDIOBJ; p2: Integer; p3: Pointer): Integer; stdcall; external gdi32 name 'GetObjectA';
function win____CreateFontIndirect(const p1: TLogFont): HFONT; stdcall; external gdi32 name 'CreateFontIndirectA';
function win____SelectObject(DC: HDC; p2: HGDIOBJ): HGDIOBJ; stdcall; external gdi32 name 'SelectObject';
function win____DeleteObject(p1: HGDIOBJ): BOOL; stdcall; external gdi32 name 'DeleteObject';
procedure win____sleep(dwMilliseconds: DWORD); stdcall; external kernel32 name 'Sleep';
function win____sleepex(dwMilliseconds: DWORD; bAlertable: BOOL): DWORD; stdcall; external kernel32 name 'SleepEx';

//registry
function win____RegConnectRegistry(lpMachineName: PChar; hKey: HKEY; var phkResult: HKEY): Longint; stdcall; external advapi32 name 'RegConnectRegistryA';
function win___RegCreateKeyEx(hKey:HKEY;lpSubKey:PChar;Reserved:DWORD;lpClass:PChar;dwOptions:DWORD;samDesired:REGSAM;lpSecurityAttributes:PSecurityAttributes;var phkResult:HKEY;lpdwDisposition:PDWORD):Longint; stdcall; external advapi32 name 'RegCreateKeyExA';
function win____RegOpenKey(hKey: HKEY; lpSubKey: PChar; var phkResult: HKEY): Longint; stdcall; external advapi32 name 'RegOpenKeyA';
function win____RegCloseKey(hKey: HKEY): Longint; stdcall; external advapi32 name 'RegCloseKey';
function win____RegDeleteKey(hKey: HKEY; lpSubKey: PChar): Longint; stdcall; external advapi32 name 'RegDeleteKeyA';
function win____RegOpenKeyEx(hKey: HKEY; lpSubKey: PChar; ulOptions: DWORD; samDesired: REGSAM; var phkResult: HKEY): Longint; stdcall; external advapi32 name 'RegOpenKeyExA';
function win____RegQueryValueEx(hKey: HKEY; lpValueName: PChar; lpReserved: Pointer; lpType: PDWORD; lpData: PByte; lpcbData: PDWORD): Longint; stdcall; external advapi32 name 'RegQueryValueExA';
function win____RegSetValueEx(hKey: HKEY; lpValueName: PChar; Reserved: DWORD; dwType: DWORD; lpData: Pointer; cbData: DWORD): Longint; stdcall; external advapi32 name 'RegSetValueExA';

//support
function win____StartServiceCtrlDispatcher(var lpServiceStartTable: TServiceTableEntry): BOOL; stdcall; external advapi32 name 'StartServiceCtrlDispatcherA';
function win____RegisterServiceCtrlHandler(lpServiceName: PChar; lpHandlerProc: ThandlerFunction): SERVICE_STATUS_HANDLE; stdcall; external advapi32 name 'RegisterServiceCtrlHandlerA';
function win____SetServiceStatus(hServiceStatus: SERVICE_STATUS_HANDLE; var lpServiceStatus: TServiceStatus): BOOL; stdcall; external advapi32 name 'SetServiceStatus';
function win____OpenSCManager(lpMachineName, lpDatabaseName: PChar; dwDesiredAccess: DWORD): SC_HANDLE; stdcall; external advapi32 name 'OpenSCManagerA';
function win____CloseServiceHandle(hSCObject: SC_HANDLE): BOOL; stdcall; external advapi32 name 'CloseServiceHandle';
function win____CreateService(hSCManager: SC_HANDLE; lpServiceName, lpDisplayName: PChar; dwDesiredAccess, dwServiceType, dwStartType, dwErrorControl: DWORD; lpBinaryPathName, lpLoadOrderGroup: PChar; lpdwTagId: LPDWORD; lpDependencies, lpServiceStartName, lpPassword: PChar): SC_HANDLE; stdcall; external advapi32 name 'CreateServiceA';
function win____OpenService(hSCManager: SC_HANDLE; lpServiceName: PChar; dwDesiredAccess: DWORD): SC_HANDLE; stdcall; external advapi32 name 'OpenServiceA';
function win____DeleteService(hService: SC_HANDLE): BOOL; stdcall; external advapi32 name 'DeleteService';

//winmm.dll
function win____timeGetTime: DWORD; stdcall; external mmsyst name 'timeGetTime';
function win____timeSetEvent(uDelay, uResolution: UINT;  lpFunction: TFNTimeCallBack; dwUser: DWORD; uFlags: UINT): UINT; stdcall; external mmsyst name 'timeSetEvent';
function win____timeKillEvent(uTimerID: UINT): UINT; stdcall; external mmsyst name 'timeKillEvent';
function win____timeBeginPeriod(uPeriod: UINT): MMRESULT; stdcall; external mmsyst name 'timeBeginPeriod';
function win____timeEndPeriod(uPeriod: UINT): MMRESULT; stdcall; external mmsyst name 'timeEndPeriod';

//winsocket.dll
//.session
function net____WSAStartup(wVersionRequired: word; var WSData: TWSAData): Integer;                               stdcall;external winsocket name 'WSAStartup';
function net____WSACleanup: Integer;                                                                             stdcall;external winsocket name 'WSACleanup';
function net____wsaasyncselect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer;                stdcall;external winsocket name 'WSAAsyncSelect';
function net____WSAGetLastError: Integer;                                                                        stdcall;external winsocket name 'WSAGetLastError';

//function net____WSAGetLastError: Integer;                                                                        stdcall;external winsocket name 'WSAGetLastError';
//function net____WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int; name, buf: PChar; buflen: Integer): THandle;   stdcall;external winsocket name 'WSAAsyncGetHostByName';
//.sockets
function net____makesocket(af, struct, protocol: Integer): TSocket;                                              stdcall;external winsocket name 'socket';
function net____bind(s: TSocket; var addr: TSockAddr; namelen: Integer): Integer;                                stdcall;external winsocket name 'bind';
function net____listen(s: TSocket; backlog: Integer): Integer;                                                   stdcall;external winsocket name 'listen';
function net____closesocket(s: tsocket): integer;                                                                stdcall;external winsocket name 'closesocket';
function net____getsockopt(s: TSocket; level, optname: Integer; optval: PChar; var optlen: Integer): Integer;    stdcall;external winsocket name 'getsockopt';
function net____accept(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket;                                 stdcall;external winsocket name 'accept';
function net____recv(s: TSocket; var Buf; len, flags: Integer): Integer;                                         stdcall;external winsocket name 'recv';
function net____send(s: TSocket; var Buf; len, flags: Integer): Integer;                                         stdcall;external winsocket name 'send';
function net____getpeername(s: TSocket; var name: TSockAddr; var namelen: Integer): Integer;                     stdcall;external winsocket name 'getpeername';
function net____connect(s: TSocket; var name: TSockAddr; namelen: Integer): Integer;                             stdcall;external winsocket name 'connect';
function net____ioctlsocket(s: TSocket; cmd: Longint; var arg: u_long): Integer;                                 stdcall;external winsocket name 'ioctlsocket';

//file
function win____FindFirstFile(lpFileName: PChar; var lpFindFileData: TWIN32FindData): THandle; stdcall; external kernel32 name 'FindFirstFileA';
function win____FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall; external kernel32 name 'FindNextFileA';
function win____FindClose(hFindFile: THandle): BOOL; stdcall; external kernel32 name 'FindClose';
function win____RemoveDirectory(lpPathName: PChar): BOOL; stdcall; external kernel32 name 'RemoveDirectoryA';


//sound procs ------------------------------------------------------------------
{$ifdef snd}

//.wave - out
function win____waveOutGetDevCaps(uDeviceID: UINT; lpCaps: PWaveOutCaps; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'waveOutGetDevCapsA';
function win____waveOutOpen(lphWaveOut: PHWaveOut; uDeviceID: UINT; lpFormat: PWaveFormatEx; dwCallback, dwInstance, dwFlags: DWORD): MMRESULT; stdcall; external mmsyst name 'waveOutOpen';
function win____waveOutClose(hWaveOut: HWAVEOUT): MMRESULT; stdcall; external mmsyst name 'waveOutClose';
function win____waveOutPrepareHeader(hWaveOut: HWAVEOUT; lpWaveOutHdr: PWaveHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'waveOutPrepareHeader';
function win____waveOutUnprepareHeader(hWaveOut: HWAVEOUT; lpWaveOutHdr: PWaveHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'waveOutUnprepareHeader';
function win____waveOutWrite(hWaveOut: HWAVEOUT; lpWaveOutHdr: PWaveHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'waveOutWrite';
//.wave - in
function win____waveInOpen(lphWaveIn: PHWAVEIN; uDeviceID: UINT; lpFormatEx: PWaveFormatEx; dwCallback, dwInstance, dwFlags: DWORD): MMRESULT; stdcall; external mmsyst name 'waveInOpen';
function win____waveInClose(hWaveIn: HWAVEIN): MMRESULT; stdcall; external mmsyst name 'waveInClose';
function win____waveInPrepareHeader(hWaveIn: HWAVEIN; lpWaveInHdr: PWaveHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'waveInPrepareHeader';
function win____waveInUnprepareHeader(hWaveIn: HWAVEIN; lpWaveInHdr: PWaveHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'waveInUnprepareHeader';
function win____waveInAddBuffer(hWaveIn: HWAVEIN; lpWaveInHdr: PWaveHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'waveInAddBuffer';
function win____waveInStart(hWaveIn: HWAVEIN): MMRESULT; stdcall; external mmsyst name 'waveInStart';
function win____waveInStop(hWaveIn: HWAVEIN): MMRESULT; stdcall; external mmsyst name 'waveInStop';
function win____waveInReset(hWaveIn: HWAVEIN): MMRESULT; stdcall; external mmsyst name 'waveInReset';
//.midi
function win____midiOutGetNumDevs: UINT; stdcall; external mmsyst name 'midiOutGetNumDevs';

//Windows 98: Once the function "win____midiOutGetDevCaps()" returns FALSE stop calling it, else lockup can
//            occur when calling other subsequent functions, such as midiOutOpen() - 04sep2025
function win____midiOutGetDevCaps(uDeviceID: UINT; lpCaps: PMidiOutCaps; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'midiOutGetDevCapsA';

function win____midiOutOpen(lphMidiOut: PHMIDIOUT; uDeviceID: UINT; dwCallback, dwInstance, dwFlags: DWORD): MMRESULT; stdcall; external mmsyst name 'midiOutOpen';
function win____midiOutClose(hMidiOut: HMIDIOUT): MMRESULT; stdcall; external mmsyst name 'midiOutClose';
function win____midiOutReset(hMidiOut: HMIDIOUT): MMRESULT; stdcall; external mmsyst name 'midiOutReset';//for midi streams only? -> hence the "no effect" for volume reset between songs - 15apr2021

//was: function win____midiOutShortMsg(hMidiOut: HMIDIOUT; dwMsg: DWORD): MMRESULT; stdcall; external mmsyst name 'midiOutShortMsg';
function win____midiOutShortMsg(const hMidiOut: HMIDIOUT; const dwMsg: DWORD): MMRESULT; stdcall; external mmsyst name 'midiOutShortMsg';

//function midiOutPrepareHeader(hMidiOut: HMIDIOUT; lpMidiOutHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'midiOutPrepareHeader';
//function midiOutUnprepareHeader(hMidiOut: HMIDIOUT; lpMidiOutHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'midiOutUnprepareHeader';
//function midiOutLongMsg(hMidiOut: HMIDIOUT; lpMidiOutHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall; external mmsyst name 'midiOutLongMsg';

//.mci
function win____mciSendCommand(mciId:MCIDEVICEID;uMessage:UINT;dwParam1,dwParam2:DWORD):MCIERROR; stdcall; external winmm name 'mciSendCommandA';
function win____mciGetErrorString(mcierr: MCIERROR; pszText: PChar; uLength: UINT): BOOL; stdcall; external winmm name 'mciGetErrorStringA';

//.mixer - volumes
function win____waveOutGetVolume(hwo: longint; lpdwVolume: PDWORD): MMRESULT; stdcall; external mmsyst name 'waveOutGetVolume';
function win____waveOutSetVolume(hwo: longint; dwVolume: DWORD): MMRESULT; stdcall; external mmsyst name 'waveOutSetVolume';
function win____midiOutGetVolume(hmo: longint; lpdwVolume: PDWORD): MMRESULT; stdcall; external mmsyst name 'midiOutGetVolume';
function win____midiOutSetVolume(hmo: longint; dwVolume: DWORD): MMRESULT; stdcall; external mmsyst name 'midiOutSetVolume';
function win____auxSetVolume(uDeviceID: UINT; dwVolume: DWORD): MMRESULT; stdcall; external mmsyst name 'auxSetVolume';
function win____auxGetVolume(uDeviceID: UINT; lpdwVolume: PDWORD): MMRESULT; stdcall; external mmsyst name 'auxGetVolume';

{$endif}
//sound procs - end ------------------------------------------------------------



//############################################################################################################################################################
//##
//## Win32 API Calls ( Part II )
//##
//## The following Win32 api procs are included below for reference purposes only.  They should not be used directly,
//## or statically linked in code.  Their definitions are provided primarily for automatic code generation into dynamic
//## loading versions of the same name.  This allows the codebase to function across all flavours of Microsoft Windows
//## without breaking, or preventing the app from starting.  In addition, each dynamic proc provides the codebase with
//## realtime diagnostic and usage information.
//##
//## The proc prefixes "win2____" and "net2____" designate a usage scope beyond Win95/98
//##
//## Code automation performed by "win__make_gosswin2_pas()".  A special "default" variable list can be
//## specified, per proc, in the format "[[..a list of semi-colon separated name-value pairs..]]".  This provides the code
//## scanner with additional information, like a return value when the proc is unable to load, along with optional additional
//## information.
//##
//############################################################################################################################################################

function win2____GetGuiResources(xhandle:thandle;flags:dword):dword; stdcall; external user32 name 'GetGuiResources';
function win2____SetProcessDpiAwarenessContext(inDPI_AWARENESS_CONTEXT:dword):lresult; stdcall; external user32 name 'SetProcessDpiAwarenessContext';
function win2____GetMonitorInfo(Monitor:hmonitor;lpMonitorInfo:pmonitorinfo):lresult; stdcall; external user32 name 'GetMonitorInfoA';
function win2____EnumDisplayMonitors(dc:hdc;lpcrect:pwinrect;userProc:PMonitorenumproc;dwData:lparam):lresult; stdcall; external user32 name 'EnumDisplayMonitors';
function win2____GetDpiForMonitor(monitor:hmonitor;dpiType:longint;var dpiX,dpiY:uint):lresult; stdcall; external Shcore name 'GetDpiForMonitor';//[[result:^^E_FAIL^^;]]
function win2____SetLayeredWindowAttributes(winHandle:hwnd;color:dword;bAplha:byte;dwFlags:dword):lresult; stdcall; external user32 name 'SetLayeredWindowAttributes';
function win2____XInputGetState(dwUserIndex03:dword;xinputstate:pxinputstate):tbasic_lresult; stdcall; external xinput1_4 name 'XInputGetState';//[[result:^^E_FAIL^^;]]
function win2____XInputSetState(dwUserIndex03:dword;xinputvibration:pxinputvibration):tbasic_lresult; stdcall; external xinput1_4 name 'XInputSetState';//[[result:^^E_FAIL^^;]]
function win2____GetFileVersionInfoSize(lptstrFilename: PAnsiChar; var lpdwHandle: DWORD): DWORD; stdcall; external version name 'GetFileVersionInfoSizeA';
function win2____GetFileVersionInfo(lptstrFilename: PAnsiChar; dwHandle, dwLen: DWORD; lpData: Pointer): BOOL; stdcall; external version name 'GetFileVersionInfoA';
function win2____VerQueryValue(pBlock: Pointer; lpSubBlock: PAnsiChar; var lplpBuffer: Pointer; var puLen: UINT): BOOL; stdcall; external version name 'VerQueryValueA';



//############################################################################################################################################################
//##
//## END of automatic scan point AND emergency proc fallback support
//##
{$else}
const win____emergencyfallback_engaged=false;// - use when dynamic procs need maintanence or due to a failure (Win10+ only)
{$endif}
//##
//## [win32-api-scanner-stop-point] - 30aug2025
//##
//############################################################################################################################################################


//static Win32 procs
function win____LoadLibraryA(lpLibFileName: PAnsiChar): HMODULE; stdcall; external kernel32 name 'LoadLibraryA';
function win____GetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall; external kernel32 name 'GetProcAddress';
function win____MessageBox(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall; external user32 name 'MessageBoxA';


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
function info__lwin(xname:string):string;//information specific to this unit of code


implementation

uses lwin2, lroot, lio;


//info proc --------------------------------------------------------------------

function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__lwin(xname:string):string;//information specific to this unit of code

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
if not m('lwin.') then exit;

//get
if      (xname='ver')        then result:='1.00.1055'
else if (xname='date')       then result:='05oct2025'
else if (xname='name')       then result:='Win32'
else
   begin
   //nil
   end;

except;end;
end;


//control procs ----------------------------------------------------------------

procedure lwin__start;

type
   ttestalign=record
    a:byte;
    b:longint;
   end;

begin
try

//check
if lwin_started then exit else lwin_started:=true;

//aligned record fields check - 10aug2025
if (sizeof(ttestalign)<>8) then showerror('Warning:'+rcode+'Win32 (lwin.pas) requires "{$align on}" or "Aligned record fields" compiler condition to be set for proper interaction with api calls, otherwise erratic data may result.');

except;end;
end;


procedure lwin__stop;
begin
try

//check
if not lwin_started then exit else lwin_started:=false;

//get

except;end;
end;


//registry procs ---------------------------------------------------------------

function reg__openkey(xrootkey:hkey;xuserkey:string;var xoutkey:hkey):boolean;
begin
//defaults
result:=false;
xoutkey:=0;
try
//create key
result:=(0=win___RegCreateKeyEx(xrootkey,pchar(xuserkey),0,nil,REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,xoutkey,nil));
//open key
if not result then result:=(0=win____RegOpenKey(xrootkey,pchar(xuserkey),xoutkey));
except;end;
end;

function reg__closekey(var xkey:hkey):boolean;
begin
if (xkey=0) then result:=true
else
   begin
   result:=(0=win____RegCloseKey(xkey));
   if result then xkey:=0;
   end;
end;

function reg__deletekey(xrootkey:hkey;xuserkey:string):boolean;
begin
result:=(0=win____RegDeleteKey(xrootkey,pchar(xuserkey)));
end;

function reg__setstr(xkey:hkey;const xname,xvalue:string):boolean;
begin
result:=(0=win____RegSetValueEx(xkey,pchar(xname),0,reg_sz,pchar(xvalue),1+low__len(xvalue)));
end;

function reg__setstrx(xkey:hkey;xname,xvalue:string):boolean;
begin
result:=(0=win____RegSetValueEx(xkey,pchar(xname),0,reg_expand_sz,pchar(xvalue),1+low__len(xvalue)));
end;

function reg__setint(xkey:hkey;xname:string;xvalue:longint):boolean;
begin
result:=(0=win____RegSetValueEx(xkey,pchar(xname),0,reg_dword,@xvalue,sizeof(xvalue)));
end;

function reg__readval(xrootstyle:longint;xname:string;xuseint:boolean):string;
label//xrootstyle: 0=current user, 1=current machine
   skipend;
//  HKEY_CLASSES_ROOT     = $80000000;
//  HKEY_CURRENT_USER     = $80000001;
//  HKEY_LOCAL_MACHINE    = $80000002;
//  HKEY_USERS            = $80000003;
//  HKEY_PERFORMANCE_DATA = $80000004;
//  HKEY_CURRENT_CONFIG   = $80000005;
//  HKEY_DYN_DATA         = $80000006;
var
   k:hkey;
   xbuf:array[0..255] of char;
   xbuflen:cardinal;
   xlen,p:longint;
   xvalname:string;
   v:tint4;
begin
try
//defaults
result:='';
//init
xvalname:='';
xlen:=low__len(xname);
if (xlen<=0) then goto skipend;
//split
for p:=xlen downto 1 do
begin
if (xname[p-1+stroffset]='\') then
   begin
   xvalname:=strcopy1(xname,p+1,xlen);
   xname:=strcopy1(xname,1,p-1);
   break;
   end;
end;//p
//.enforcing trailing slash for xname - 28may2022
if (strcopy1(xname,length(xname),1)<>'\') then xname:=xname+'\';
//get
xbuflen:=sizeof(xbuf);
case xrootstyle of
0:if (win____regopenkeyex(HKEY_CURRENT_USER,pchar(xname),0,KEY_READ,k)<>ERROR_SUCCESS) then goto skipend;
1:if (win____regopenkeyex(HKEY_LOCAL_MACHINE,pchar(xname),0,KEY_READ,k)<>ERROR_SUCCESS) then goto skipend;
else goto skipend;
end;
//set
try
fillchar(xbuf,sizeof(xbuf),0);
if (win____regqueryvalueex(k,pchar(xvalname),nil,nil,@xbuf,@xbuflen)=ERROR_SUCCESS) then
   begin
   if xuseint then
      begin
      v.bytes[0]:=ord(xbuf[0]);
      v.bytes[1]:=ord(xbuf[1]);
      v.bytes[2]:=ord(xbuf[2]);
      v.bytes[3]:=ord(xbuf[3]);
      result:=intstr32(v.val);
      end
   else result:=string(xbuf);
   end;
except;end;
//close
win____regclosekey(k);
skipend:
except;end;
end;

//dynamic procs support --------------------------------------------------------
//wina procs -------------------------------------------------------------------
function win____CreateWindow(lpClassName: PChar; lpWindowName: PChar; dwStyle: DWORD; X, Y, nWidth, nHeight: longint; hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
begin
Result := win____CreateWindowEx(0, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;

function win__makeproc(x:string;var xcore:twinscannerinfo;var e:string):boolean;
label
   skipend;
var
   lnameindex,xlen,pc,lp,p2,p:longint;
   xfunc:boolean;
   xprocline,xorgprocname,str1,str2,xvarlist,xvarlistBARE,xreturntype,dname,lname,pname,vname:string;
   xdefvalsline,xloadType,xfuncbody,xfuncbodyBARE,xfuncbody2,n,v,etmp:string;
   xdefvals:tfastvars;
   vc:char;
   xhasdefault,xcolon,bol1,bol2:boolean;

   function c(xindex:longint):char;
   begin

   if (xindex>=1) and (xindex<=xlen) then result:=x[xindex-1+stroffset] else result:=#32;

   end;

   function emsg(const xmsg:string):boolean;
   begin

   result:=true;
   if (e='') then e:=xmsg+rcode+rcode+'-- For Proc --'+rcode+x;

   end;

   function xpad0(const x:string):string;
   const
      xline='                                          ';
   begin
   result:=x+strcopy1(xline,1,low__len(xline)-low__len(x));
   end;

   function xpad1(const x:string):string;
   const
      xline='                                                      ';
   begin
   result:=x+strcopy1(xline,1,low__len(xline)-low__len(x));
   end;

   function xpad2(const x:string):string;
   const
      xline='               ';
   begin
   result:=x+strcopy1(xline,1,low__len(xline)-low__len(x));
   end;

   function xpad3(const x:string):string;
   const
      xline='              ';
   begin
   result:=x+strcopy1(xline,1,low__len(xline)-low__len(x));
   end;

   function xpad4(const x:string):string;
   const
      xline='                                   ';
   begin
   result:=x+strcopy1(xline,1,low__len(xline)-low__len(x));
   end;

   function rh(const x:string):boolean;
   begin
   result:=strmatch(x,xreturntype);
   if result then xloadType:='hnd';//thandle
   end;

   function rp(const x:string):boolean;
   begin
   result:=strmatch(x,xreturntype);
   if result then xloadType:='ptr';//longint
   end;

   function ri(const x:string):boolean;
   begin
   result:=strmatch(x,xreturntype);
   if result then xloadType:='int';//longint
   end;

   function rw(const x:string):boolean;
   begin
   result:=strmatch(x,xreturntype);
   if result then xloadType:='wrd';//word
   end;

   function rb(const x:string):boolean;
   begin
   result:=strmatch(x,xreturntype);
   if result then xloadType:='bol';//bool
   end;

   function rskip(const x:string):boolean;
   begin
   result:=strmatch(x,xreturntype);
   end;

   //---------------------------------------------------------------------------
   function xsysvals(var x,e:string):boolean;
   label
      redo;
   const
      xsyschar   ='^';
      xsyschar2  =xsyschar+xsyschar;
   var
      xrescanlimit,p2,p,xlen:longint;
      xvaldone,bol1:boolean;
      n:string;

      function emsg(const x:string):boolean;
      begin

      result:=true;
      if (e='') then e:=x;

      end;

      function m(const xname,xvarval:string):boolean;
      begin

      //check
      if xvaldone then
         begin

         result:=true;
         exit;

         end;

      //get
      result:=strmatch(n,xname);

      if result then
         begin

         x        :=strcopy1(x,1,p-1)+xvarval+strcopy1(x,p2+2,xlen);
         xlen     :=low__len(x);
         xvaldone :=true;

         end;

      end;

      function mi(const xname:string;xvarval:longint):boolean;
      begin

      result:=xvaldone or m(xname,intstr32(xvarval));

      end;

   begin

   //defaults
   result            :=false;
   e                 :='';
   xrescanlimit      :=100;

   //init
   xlen   :=low__len(x);
   if (xlen<1) then
      begin

      result:=true;
      exit;

      end;

   //scan
   redo:
   if (xlen>=1) then for p:=1 to xlen do if (x[p-1+stroffset]=xsyschar) and (strcopy1(x,p,2)=xsyschar2) then
      begin

      //init
      xvaldone  :=false;
      bol1      :=false;
      n         :='';

      //get
      for p2:=(p+2) to xlen do if (x[p2-1+stroffset]=xsyschar) and (strcopy1(x,p2,2)=xsyschar2) then
         begin

         n    :=strlow( strcopy1( x, p+2, p2-p-2 ) );
         bol1 :=true;
         break;

         end;

      //error
      if (not bol1) and emsg('A system value in the format "'+xsyschar2+'<value name>'+xsyschar2+'" was started but not finished') then exit;

      //check
      if (n='') and emsg('Invalid system value name "nil"')                                                  then exit;



      //replace sys.val label with actual value
      mi('s_false',s_false);
      mi('e_fail',$80004005);//03sep2025



      //check
      if (not xvaldone) and emsg('System value name "'+n+'" not found')                                      then exit;


      //rescan from the beginning
      dec(xrescanlimit);
      if (xrescanlimit<=0) and emsg('Rescan limit for system value exceeded - error in code')                then exit;

      //loop
      goto redo;

      end;//p

   //successful
   result:=true;

   end;

   //read defaults
   function xreadDefaultVars(x:string;var e:string):boolean;
   label
      skipend;
   var
      xlen,xpos:longint;
      xline:string;
      dtext:tstr8;
   begin

   //defaults
   result :=false;
   e      :='';
   dtext  :=nil;

   try
   //filter
   x:=stripwhitespace_lt(x);
   if (x='') then exit;

   //init
   xlen  :=low__len(x);
   xpos  :=0;
   dtext :=small__new8;

   //.make lines
   swapchars(x,';',#10);

   //read lines and REPLACE system variable references with their actual values
   while low__nextline1(x,xline,xlen,xpos) do
   begin

   case xsysvals(xline,e) of
   true:dtext.sadd(xline+rcode);
   else goto skipend;
   end;

   end;//loop

   //get
   xdefvals.text:=dtext.text;

   //check
   if (xdefvals.s['result']='') and emsg('Default var "result" has no value')                   then goto skipend;
   if (intstr32(strint32(xdefvals.s['result'])) <> xdefvals.s['result']) and emsg('Numerical value for default var "result" is corrupt') then goto skipend;

   if (xdefvals.count<=0)       and emsg('Default vars specified but no variables were found')  then goto skipend;

   //succesful
   result:=(xdefvals.count>=1);
   skipend:

   except;end;

   //free
   small__free8(@dtext);

   end;

   function xdefvalsononeline(var xline:string):boolean;
   label
      skipend;
   var
      p:longint;
      a:tstr8;

      function xhaschar(const x:string;v:char):boolean;
      var
         p:longint;
      begin

      //defaults
      result:=false;

      //get
      if (x<>'') then for p:=1 to low__len(x) do if (v=x[p-1+stroffset]) then
         begin

         result:=true;
         break;

         end;//p

      end;

   begin

   //defaults
   result :=false;
   xline  :='';
   a      :=nil;

   try

   //check
   if (xdefvals.count<=0) then
      begin

      result:=true;
      exit;

      end;

   //init
   a:=small__new8;

   //get
   for p:=0 to (xdefvals.count-1) do if not strmatch(xdefvals.n[p],'result') then //exclude return "result" - 30aug2025
   begin

   if xhaschar(xdefvals.n[p],';') and emsg('Default var has a ";" in its name') then goto skipend;
   if xhaschar(xdefvals.n[p],':') and emsg('Default var has a ":" in its name') then goto skipend;

   if xhaschar(xdefvals.v[p],';') and emsg('Default var has a ";" in its value') then goto skipend;
   if xhaschar(xdefvals.v[p],':') and emsg('Default var has a ":" in its value') then goto skipend;

   a.sadd( insstr(#32,a.count>=1) + xdefvals.n[p]+':'+xdefvals.v[p]+';' );

   end;//p

   //set
   xline:=a.text;

   //successful
   result:=true;
   skipend:

   except;end;

   //free
   small__free8(@a);

   end;

begin

//defaults
result          :=false;
//xprocline       :='';
//xout            :='';
//xoutlisting     :='';
e               :='';
//xnamelen        :=0;
//xhasdefault     :=false;
xorgprocname    :='';
xdefvals        :=nil;

//check core vars
if (xcore.lhistory=nil) or (xcore.lprocvars=nil) or (xcore.lprocline=nil) or
   (xcore.lprocbody=nil) or (xcore.lprocinfo=nil) or (xcore.dunit=nil) or
   (xcore.lproctype=nil) then exit;

try

//filter
x:=stripwhitespace_lt(x);
if (x='') then
   begin

   result:=true;
   exit;

   end;

//check -> ignore -> line is a comment
if (strcopy1(x,1,2)='//') then
   begin

   result:=true;
   exit;

   end;


//------------------------------------------------------------------------------
//init
x            :=x+';';//force terminator char
xlen         :=low__len(x);
pc           :=0;
xhasdefault  :=false;
xfunc        :=false;
xvarlist     :='';
xvarlistBARE :='';
xreturntype  :='';
xloadType    :='';
dname        :='';
lname        :='';
lnameindex   :=dnone;
xdefvals     :=tfastvars.create;//used for the default return value when proc is not available, agmonst other things

//------------------------------------------------------------------------------
//proc type
lp    :=1;
bol1  :=false;

for p:=1 to xlen do if (c(p)=#32) then
   begin

   str1:=stripwhitespace_lt(strcopy1(x,lp,p-lp));

   if strmatch(str1,'function')  then
      begin

      xfunc :=true;
      bol1  :=true;

      end
   else if strmatch(str1,'procedure') then
      begin

      xfunc :=false;
      bol1  :=true;

      end;

   break;

   end;//p

//.skip
if not bol1 then
   begin

   result:=true;
   goto skipend;

   end;


//------------------------------------------------------------------------------
//is it external -> only process external procs
bol1:=false;

for p:=xlen downto 1 do
begin

if      ( c(p)=')' ) then break
else if ( (c(p)='e') or (c(p)='E') ) and ( strmatch( strcopy1(x,p-1,10),' external ' ) or strmatch( strcopy1(x,p-1,10),';external ' ) ) then
   begin

   bol1:=true;
   break;

   end;

end;//p

if not bol1 then
   begin

   result:=true;
   goto skipend;

   end;


//------------------------------------------------------------------------------
//org.procname
lp:=1;

for p:=1 to xlen do
begin

if      (c(p)=#32) then lp:=p+1
else if (c(p)='(') or (c(p)=':') or (c(p)=';') then
   begin

   xorgprocname:=strcopy1(x,lp,p-lp);
   break;

   end;

end;//p

if (xorgprocname='') and emsg('Original proc name is invalid') then goto skipend;


//------------------------------------------------------------------------------
//proc varlist
lp:=1;

for p:=1 to xlen do
begin

if      (c(p)='(') then lp:=p+1
else if (c(p)=')') then
   begin

   xvarlist:=stripwhitespace_lt(strcopy1(x,lp,p-lp));
   break;

   end
else if (c(p)=':') and (lp<=0) then break;

end;//p

if (xvarlist<>'') then
   begin

   str1:=xvarlist+';';
   bol1:=true;
   lp  :=1;

   for p:=1 to low__len(str1) do
   begin

   vc:=str1[p-1+stroffset];

   if (vc=';') or (vc=',') then
      begin

      str2:=stripwhitespace_lt(strcopy1(str1,lp,p-lp));

      //.strip trailing ":type" if present
      if (str2<>'') then for p2:=1 to low__len(str2) do if (str2[p2-1+stroffset]=':') then
         begin

         str2:=stripwhitespace_lt(strcopy1(str2,1,p2-1));
         break;

         end;


      //.stripleading "var" and "const" etc
      if (str2<>'') then for p2:=low__len(str2) downto 1 do if (str2[p2-1+stroffset]=#32) then
         begin

         str2:=strcopy1(str2,p2+1,low__len(str2));
         break;

         end;

      if (str2='') and emsg('A var name in varlist has no name') then goto skipend;

      xvarlistBARE:=xvarlistBARE+insstr(', ',xvarlistBARE<>'')+str2;

      lp:=p+1;

      end

   else if (vc=';') then lp:=p+1;

   end;//p

   end;

if (xvarlist<>'') and (xvarlistBARE='') and emsg('Varlist and varlistBARE mismatch') then goto skipend;


//------------------------------------------------------------------------------
//proc return type
lp          :=1;
bol1        :=true;
xcolon      :=false;

for p:=1 to xlen do
begin

if      (c(p)='(') then bol1:=false
else if (c(p)=')') then
   begin

   bol1:=true;
   lp  :=p+1;

   end;

if bol1 then
   begin

   if      (c(p)=':') then
      begin

      lp     :=p+1;
      xcolon :=true;

      end

   else if (c(p)=';') then
      begin

      if xcolon then
         begin

         xreturntype:=strlow(stripwhitespace_lt(strlow( strcopy1(x,lp,p-lp) )));
         if (xreturntype='stdcall') then xreturntype:='';

         end;

      break;

      end;
   end;

end;//p

//check
case xfunc of
true:if (xreturntype='')  and emsg('Function as no return type')             then goto skipend;
else if (xreturntype<>'') and emsg('Procedure cannot have a return type "'+xreturntype+'"') then goto skipend;
end;//case

//check return type
if (xreturntype<>'') then
   begin

   if
   //boolean
   rb('bool') or

   //longint
   ri('integer') or ri('longint') or ri('hbrush') or ri('COLORREF') or ri('dword') or ri('hdc') or ri('hbitmap') or ri('hwnd') or
   ri('hglobal') or ri('hcursor') or ri('hgdiobj') or ri('hmodule') or ri('hicon') or ri('hrgn') or ri('lresult') or ri('uint') or
   ri('hresult') or ri('HINST') or ri('hfont') or ri('SERVICE_STATUS_HANDLE') or ri('MMRESULT') or ri('tsocket') or
   ri('MCIERROR') or ri('tbasic_lresult') or ri('hmenu') or


   //word
   rw('atom') or

   //pointer
   rp('pointer') or rp('farproc') or

//   //thandle
   rh('thandle') or rh('SC_HANDLE') then

      begin
      //ok
      end

   //unknown return type -> report error
   else if emsg('Unknown return type "'+xreturntype+'"') then goto skipend;

   end;


//------------------------------------------------------------------------------
//dll name
lp:=0;
pc:=0;

for p:=xlen downto 1 do
begin

if (c(p)='''') then
   begin

   inc(pc);

   case pc of
   1:lp:=p-1;
   2:begin

      dname:=stripwhitespace_lt(strcopy1(x,p+1,lp-p));//case-sensitive dll name
      break;

      end;
   end;//case

   end;

end;//p

//.check name
if (dname='')  and emsg('Proc name is "nil"') then goto skipend;
xcore.longestname:=largest32(xcore.longestname,low__len(dname));


//------------------------------------------------------------------------------
//lib name
lp:=0;
pc:=0;

for p:=xlen downto 1 do
begin

if      ( c(p)=')' ) then break
else if ( (c(p)='e') or (c(p)='E') ) and ( strmatch( strcopy1(x,p-1,10),' external ' ) or strmatch( strcopy1(x,p-1,10),';external ' ) ) then
   begin

   //find lib name
   lp  :=1;
   pc  :=0;

   for p2:=p to xlen do
   begin

   if (c(p2)=#32) then
      begin

      inc(pc);

      if (pc>=2) then
         begin

         lname:=strlow(stripwhitespace_lt(strcopy1(x,lp,p2-lp)));
         break;

         end;

      lp:=p2+1;

      end;


   end;//p2

   break;

   end;

end;//p

if (lname='') and emsg('Proc has no lib name') then goto skipend;

//similar names conversion
if      (lname='mmsyst')      then lname:='winmm'
else if (lname='winspl')      then lname:='winspool'
else if (lname='winsocket')   then lname:='wsock32';

if (not win__finddllname(lname,lnameindex)) and emsg('Li'+'b name unknown "'+lname+'"') then goto skipend;


//------------------------------------------------------------------------------
//default value - optional -> "[[some value]]" (without double quotes)
lp    :=xlen;
bol1  :=false;
bol2  :=false;
etmp  :='';

for p:=1 to xlen do
begin

if (c(p)='[') and strmatch(strcopy1(x,p,2),'[[') and (not bol1) then
   begin

   bol1 :=true;
   lp   :=p+2;

   end
else if bol1 and ((c(p)=']') and (strcopy1(x,p,2)=']]')) then
   begin

   bol2        :=true;
   xhasdefault :=xreadDefaultVars( strcopy1(x,lp,p-lp) ,etmp);

   break;

   end;

end;//p

if bol1 and (not bol2) and emsg('Warning:'+rcode+'Default value started but not finished')                   then goto skipend;

if bol1 and bol2 and (not xhasdefault) and emsg('Warning:'+rcode+'Default value equates to an usable value' + insstr(' ('+etmp+')',etmp<>'') ) then goto skipend;

if xhasdefault then inc(xcore.defaultcount);


//------------------------------------------------------------------------------
//generate proc code

//init
xfuncbody      :=insstr('(',xvarlist<>'')+xvarlist+insstr(')',xvarlist<>'');
xfuncbodyBARE  :=insstr('(',xvarlist<>'')+xvarlistBARE+insstr(')',xvarlist<>'');
xfuncbody2     :=low__aorbstr('procedure','function',xfunc)+xfuncbody+insstr(':',xreturntype<>'')+xreturntype;
pname          :='t'+xorgprocname;
vname          :='v'+xorgprocname;
xprocline      :=low__aorbstr('procedure','function',xfunc)+#32+xorgprocname+xfuncbody+insstr(':',xreturntype<>'')+xreturntype+';';

//.exclude repeates
if not (xcore.lhistory as tdynamicnamelist).addonce(xprocline) then
   begin

   result:=true;
   goto skipend;

   end;

//.proc vars
str__as8f(@xcore.lprocvars).sadd( '   '+xpad1(vname)+'='+k64(xcore.proccount)+';' + rcode );

//.proc types
str__as8f(@xcore.lproctype).sadd('   '+xpad1(pname)+'='+xfuncbody2+'; stdcall;'+rcode );

//.proc line
str__as8f(@xcore.lprocline).sadd( xprocline + rcode );

//.proc info -> optional -> only add an entry if default vars present
case xhasdefault of
true:if not xdefvalsononeline(xdefvalsline) then goto skipend;
else xdefvalsline:='';
end;//case

str1:=intstr32(strint32( xdefvals.s['result'] ));
case (xdefvalsline<>'') of
true:str__as8f(@xcore.lprocinfo).sadd( xpad0(vname)+':s4( ' + xpad2(str1) +',d'+xpad3(win__dllname2(lnameindex,false)) + ','+xpad4('''' + dname + '''') + ',' + xpad4(''''+xdefvalsline+'''') + ');' + insstr('//custom return value',str1<>'0') + rcode );
else str__as8f(@xcore.lprocinfo).sadd( xpad0(vname)+':s3( ' + xpad2(str1) +',d'+xpad3(win__dllname2(lnameindex,false)) + ','+xpad4('''' + dname + '''') + ');' + insstr('//custom return value',str1<>'0') + rcode );
end;//case

//.proc body
str__as8f(@xcore.lprocbody).sadd(

'//'+x+rcode+//keep a copy of the original proc
rcode+
xprocline+rcode+
'var'+rcode+
'   a:pointer;'+rcode+
'begin'+rcode+

low__aorbstr(
 'if win__use'+xloadType+'('+vname+',a) then '+pname+'(a)'+xfuncbodyBARE+';'+rcode,//as a procedure
 'if win__use'+xloadType+'(result,'+vname+',a) then result:='+pname+'(a)'+xfuncbodyBARE+';'+rcode,//as a function
xfunc)+

'win__dec;'+rcode+
'end;'+rcode+
rcode+
rcode+

'');

//.inc
inc(xcore.proccount);


//------------------------------------------------------------------------------
//successful
result:=true;

skipend:
except;end;

//free
freeobj(@xdefvals);

end;

function win__makeprocs(const sf,df,dversionlabel:string):boolean;
label
   skipend;
const
   xpointPrefix='//## [';
   xstartpoint=xpointPrefix+'win32-api-scanner-start-point]';
   xstoppoint =xpointPrefix+'win32-api-scanner-stop-point]';
var
   a:tdynamicstring;
   xcore:twinscannerinfo;
   e,etmp,ecdprocline,dv,dv2:string;
   xpointPrefixLEN,int1,p:longint;
   bol1,xscanning:boolean;

   function emsg(const x:string):boolean;
   begin

   result:=true;
   if (e='') then e:=x;

   end;

   function m(const x:string):boolean;
   begin
   result:=strmatch( x, strcopy1(a.value[p],1,low__len(x)) );
   end;

   procedure ladd(const x:string);//add line
   begin

   str__as8f(@xcore.dunit).sadd(x+rcode);

   end;

   procedure radd(const x:string);//raw add (no return code)
   begin

   str__as8f(@xcore.dunit).sadd(x);

   end;

   function mt(xok:boolean):string;
   begin

   result:='-- Win32 Proc Extraction '+low__aorbstr('Failed','Successful',xok)+' ('+io__extractfilename(sf)+') --'+rcode+rcode;

   end;

   function sm(const xmsg:string):boolean;
   begin

   result:=true;
   showtext(mt(true)+xmsg);

   end;

   function se(const xmsg:string):boolean;
   begin

   result:=true;
   showerror(mt(false)+xmsg);

   end;

   function xpad1(const x:string):string;
   const
      xline='                                                      ';
   begin
   result:=x+strcopy1(xline,1,low__len(xline)-low__len(x));
   end;

begin

//defaults
result             :=false;
a                  :=nil;
low__cls(@xcore,sizeof(xcore));
e                  :='';
xscanning          :=false;
xpointPrefixLEN    :=low__len(xpointPrefix);

try
//check
if not io__fileexists(sf) and emsg('Source filename does not exist:'+rcode+sf) then goto skipend;
if strmatch(sf,df) and emsg('Source and destination filenames are the same')   then goto skipend;

//init
a              :=tdynamicstring.create;
a.text         :=io__fromfilestr2( sf );

if (a.count<=0) and emsg('No text to process') then goto skipend;

//.core
with xcore do
begin

lhistory   :=tdynamicnamelist.create;//tracks repeat entries
lprocvars  :=str__new8;//(tstr8) list of procs as constants
lproctype  :=str__new8;//(tstr8) list of procs as record types
lprocline  :=str__new8;//(tstr8) list of procs as a procedure or function definition line
lprocbody  :=str__new8;//(tstr8) list of procs as a procedure or function text
lprocinfo  :=str__new8;//(tstr8) list of procs in a management function(s)
dunit      :=str__new8;

end;


//get
for p:=0 to pred(a.count) do
begin

//.start/stop scan
if (strcopy1(a.value[p],1,xpointPrefixLEN)=xpointPrefix) then
   begin

   if      m(xstartpoint) then xscanning:=true
   else if m(xstoppoint)  then break;

   end;

//.read line
if xscanning and (not win__makeproc(a.value[p],xcore,e)) then
   begin

   e:='Error at line '+k64(p)+rcode+rcode+e;
   goto skipend;

   end;

end;//p

//check
if (not xscanning) and emsg('Start/stop scanner commands not found in source code') then goto skipend;


//build unit "lwin2.pas"

//unit header
ladd('unit lwin2;');
ladd('');
ladd('interface');
ladd('');
ladd('uses lwin;');
ladd('{$align on}{$iochecks on}{$O+}{$W-}{$U+}{$V+}{$B-}{$X+}{$T-}{$P+}{$H+}{$J-}');
ladd('//## ==========================================================================================================================================================================================================================');
ladd('//##');
ladd('//## MIT License');
ladd('//##');
ladd('//## Copyright '+low__yearstr(2025)+' Blaiz Enterprises ( http://www.blaizenterprises.com )');
ladd('//##');
ladd('//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation');
ladd('//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,');
ladd('//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software');
ladd('//## is furnished to do so, subject to the following conditions:');
ladd('//##');
ladd('//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.');
ladd('//##');
ladd('//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES');
ladd('//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE');
ladd('//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN');
ladd('//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.');
ladd('//##');
ladd('//## ==========================================================================================================================================================================================================================');
ladd('//## Note..................... ** This is an automatically generated unit, created by "lwin.win__make_lwin2_pas" **');
ladd('//## Library.................. dynamically loaded and managed 32bit Windows api''s (lwin2.pas)');
ladd('//## Version.................. '+dversionlabel);
ladd('//## Items.................... '+k64(xcore.proccount) );
ladd('//## Last Updated ............ '+strlow(low__remcharb(low__datestr(date__now,4,false),#32)) );
ladd('//## ==========================================================================================================================================================================================================================');

ladd('');
ladd('');


//unit code
ladd('const');
radd( '   '+xpad1('vwin____proccount')+'='+k64(xcore.proccount)+';//total number of Win32 api procs defined' + rcode );
radd( str__as8f(@xcore.lprocvars).text );

ladd('');
ladd('');
ladd('type');
radd( str__as8f(@xcore.lproctype).text );

ladd('');
ladd('');
ladd('function win____slotinfo(const xslot:longint;var dname,rvalue:longint;var pname:string;var xmisc:string):boolean;');
radd( str__as8f(@xcore.lprocline).text );

ladd('');
ladd('');
ladd('implementation');

ladd('');
ladd('');
ladd('function win____slotinfo(const xslot:longint;var dname,rvalue:longint;var pname:string;var xmisc:string):boolean;');
ladd('');
ladd('   procedure s3(const _rvalue,_dname:longint;const _pname:string);');
ladd('   begin');
ladd('');
ladd('   rvalue :=_rvalue;');
ladd('   dname  :=_dname;');
ladd('   pname  :=_pname;');
ladd('');
ladd('   end;');
ladd('');
ladd('   procedure s4(const _rvalue,_dname:longint;const _pname,_xmisc:string);');
ladd('   begin');
ladd('');
ladd('   rvalue :=_rvalue;');
ladd('   dname  :=_dname;');
ladd('   pname  :=_pname;');
ladd('   xmisc  :=_xmisc;');
ladd('');
ladd('   end;');
ladd('');
ladd('begin');
ladd('');
ladd('//defaults');
ladd('result :=true;');
ladd('dname  :=dnone;');
ladd('rvalue :=0;');
ladd('pname  :='''';');
ladd('xmisc  :='''';');
ladd('');
ladd('//get');
ladd('case xslot of');
radd( str__as8f(@xcore.lprocinfo).text );
ladd('-1:;//placeholder');
ladd('end;//case');
ladd('');
ladd('end;');

ladd('');
ladd('');
radd( str__as8f(@xcore.lprocbody).text );

ladd('end.');


//save unit
if (not io__tofile(df,@xcore.dunit,etmp)) and emsg('Save unit failed ('+etmp+')') then goto skipend;

//successful
result:=true;
skipend:

except;end;

//free
freeobj(@a);
freeobj(@xcore.lhistory);
freeobj(@xcore.lprocvars);
freeobj(@xcore.lproctype);
freeobj(@xcore.lprocline);
freeobj(@xcore.lprocbody);
freeobj(@xcore.lprocinfo);
freeobj(@xcore.dunit);

//show result
case result of
true:begin

   sm(
   k64(xcore.proccount)+' proc'+insstr('s',xcore.proccount<>1)+' converted to dynamic loading'+rcode+
   k64(xcore.longestname)+' char'+insstr('s',xcore.longestname<>1)+' is the longest dll proc name'+rcode+
   k64(xcore.defaultcount)+' proc'+insstr('s',xcore.defaultcount<>1)+' defined with default vars'+rcode+
   '');

   end;
else se(e);
end;//case

end;

procedure win__make_lwin2_pas;
const
   dversionlabel='4.00.531';//'ver'
begin
win__makeprocs( io__asfolderNIL(io__extractfilepath(io__exename))+'lwin.p'+'as', io__asfolderNIL(io__extractfilepath(io__exename))+'lwin2.p'+'as' ,dversionlabel );
end;

function win__errmsg(const e:longint):string;
begin

case e of
waOK                :result:='OK';
waBadDLLName        :result:='FAIL: Bad D'+'LL name';
waBadProcName       :result:='FAIL: Bad Pr'+'oc name';
waDLLLoadFail       :result:='FAIL: D'+'LL not loaded';
waProcNotFound      :result:='FAIL: Pr'+'oc not found';
else                 result:='-';
end;//case

end;

function win__dllname(const xindex:longint):string;
begin
result:=win__dllname2(xindex,false);
end;

function win__dllname2(const xindex:longint;xincludeext:boolean):string;
begin

case xindex of
duser32      :result:='use'+'r32';
dshell32     :result:='sh'+'el'+'l32';
dShcore      :result:='S'+'hco'+'re';
dxinput1_4   :result:='xin'+'put'+'1_4';
dadvapi32    :result:='adv'+'ap'+'i32';
dkernel32    :result:='ke'+'rne'+'l32';
dmpr         :result:='mp'+'r';
dversion     :result:='ver'+'si'+'on';
dcomctl32    :result:='co'+'mct'+'l32';
dgdi32       :result:='gd'+'i32';
dopengl32    :result:='open'+'gl32';
dwintrust    :result:='wi'+'ntr'+'ust';
dole32       :result:='ol'+'e32';
doleaut32    :result:='olea'+'ut32';
dolepro32    :result:='olep'+'ro32';
dwinmm       :result:='win'+'mm';
dwsock32     :result:='wso'+'ck32';
dwinspool    :result:='win'+'s'+'pool';//.drv
dcomdlg32    :result:='co'+'mdl'+'g32';//04oct2025
else          result:='';
end;//case

//extension
if xincludeext then
   begin

   case xindex of
   dwinspool :result:=result+'.'+'dr'+'v';
   else       result:=result+'.'+'d'+'ll';
   end;//case

   end;

end;

function win__finddllname(const xname:string;var xindex:longint):boolean;
var
   p:longint;
begin

//defaults
result :=false;
xindex :=dnone;

//find
for p:=1 to dmax do if strmatch(xname, win__dllname2(p,false) ) then
   begin

   result :=true;
   xindex :=p;
   break;

   end;//p

end;


procedure win__inc(const xslot:longint);
begin

//check
if (xslot<0) or (xslot>high(system_wincore.u)) or (not system_wincore.u[xslot]) then exit;

//set
inc164(system_wincore.c[xslot]);//number of calls to this proc
inc164(system_wincore.pcalls);//total number of proc calls (covers all procs)

if (system_wincore.d[xslot]>dnone) and (system_wincore.d[xslot]<=dmax) then inc164(system_wincore.dcalls[ system_wincore.d[xslot] ]);//number of calls to this proc

if (system_wincore.tracedepth>=0) and (system_wincore.tracedepth<=high(system_wincore.tracelist)) then system_wincore.tracelist[system_wincore.tracedepth]:=xslot;

inc132(system_wincore.tracedepth);

end;

procedure win__dec;
begin

dec132(system_wincore.tracedepth);

//win__depthtrace(20);

end;

procedure win__depthtrace(xlimit:longint);
var
   str1,v:string;
   int1,i,p:longint;
begin

v:='';

for p:=frcrange32(system_wincore.tracedepth,1,50) downto 1 do
begin

i:=system_wincore.tracedepth-p;
if (i>=0) and (i<=high(system_wincore.tracelist)) then
   begin

   int1:=system_wincore.tracelist[i];

   if (int1>=0) and (int1<=high(system_wincore.u)) then
      begin

      if not system_wincore.u[int1]        then str1:='proc not in use'
      else if (system_wincore.p[int1]=nil) then str1:='proc not supported'
      else                                      str1:=strdefb(win__procname(int1),'proc has no name');

      end
   else                                         str1:='< trace error >';

   v:=v+intstr32(i)+'. ['+str1+']'+rcode;

   end
else break;

end;//p

if (v='') then v:='No trace available';

showtext('-- Trace --'+rcode+v);

end;

function win__infocount:longint;
begin
result:=1 + system_wincore.dcount + 1 + 2 + system_wincore.pcount;
end;

function win__infofind(xindex:longint;var v1,v2,v3,v4:string;var xtitle:boolean):boolean;
label
   redo;
var
   i:longint;

   function xfind1(var i:longint):boolean;
   var
      tc,c,p:longint;
   begin

   //defaults
   result :=false;
   i      :=0;
   tc     :=xindex+1-2;
   c      :=0;

   //find
   for p:=0 to high(system_wincore.du) do if system_wincore.du[p] then
      begin

      inc(c);

      if (c=tc) then
         begin

         i      :=p;
         result :=true;
         break;

         end;

      end;//p

   end;

   function xfind2(var i:longint):boolean;
   var
      tc,c,p:longint;
   begin

   //defaults
   result :=false;
   i      :=0;
   tc     :=xindex+1-system_wincore.dcount-4;
   c      :=0;

   //find
   for p:=0 to high(system_wincore.u) do if system_wincore.u[p] then
      begin

      inc(c);

      if (c=tc) then
         begin

         i      :=p;
         result :=true;
         break;

         end;

      end;//p

   end;

begin

//defaults
result :=false;
v1     :='';
v2     :='';
v3     :='';
v4     :='';
xtitle :=false;

//get

if (xindex=0) then
   begin

   xtitle :=true;
   v1     :='DLL Name';
   v2     :='Status';
   v3     :='Calls';
   result :=true;

   end

else if (xindex=1) then
   begin

   v1     :='Total';
   v2     :='-';
   v3     :=k64(system_wincore.pcalls);
   result :=true;

   end

else if xfind1(i) then
   begin

   v1        :=win__dllname2(i,true);
   v2        :=win__errmsg(system_wincore.de[i]);
   v3        :=k64(system_wincore.dcalls[i]);

   result    :=true;

   end

else if (xindex=(system_wincore.dcount+2)) then
   begin

   //space

   end

else if (xindex=(system_wincore.dcount+3)) then
   begin

   xtitle :=true;
   v1     :='API Name';
   v2     :='Status';
   v3     :='Calls';
   result :=true;

   end

else if xfind2(i) then
   begin

   v1        :=win__procname(i);
   v2        :=win__errmsg(system_wincore.e[i]);
   v3        :=k64(system_wincore.c[i]);

   result    :=true;

   end;

end;

function win__procCallCount(const xslot:longint):comp;
begin
if (xslot>=0) and (xslot<=high(system_wincore.u)) and system_wincore.u[xslot] then result:=system_wincore.c[xslot] else result:=0;
end;

function win__proccount:longint;
begin
result:=vwin____proccount;
end;

function win__procload:longint;
begin
result:=system_wincore.pOK;
end;

function win__proccalls:comp;
begin
result:=system_wincore.pcalls;
end;

function win__dllload:longint;
begin
result:=system_wincore.dOK;
end;

procedure win__init;//should be called from app__boot
begin

//check
if system_wininit then exit else system_wininit:=true;

//get
low__cls(@system_wincore,sizeof(system_wincore));//30aug2025

end;

function win__ok(const xslot:longint):boolean;
begin

case xslot of
0..high(system_wincore.u) :result:=( system_wincore.u[xslot] or win__loaded(xslot) ) and (system_wincore.p[xslot]<>nil);
else                       result:=false;
end;//case

end;

function win__procname(const xslot:longint):string;
var
   dname,rvalue:longint;
   xmisc:string;
begin
win__slotinfo(xslot,dname,rvalue,result,xmisc);
end;

function win__slotinfo(const xslot:longint;var dname,rvalue:longint;var pname:string;var xmisc:string):boolean;
begin
result:=win____slotinfo(xslot,dname,rvalue,pname,xmisc);
end;

function win__loaded(const xslot:longint):boolean;
var
   a:hmodule;
   b:pointer;
   dname,rvalue:longint;
   pname:string;
   smisc:string;

   function emsg(const xmsg:longint):boolean;
   begin

   result                  :=true;
   system_wincore.e[xslot] :=xmsg;

   end;

begin

//defaults
result      :=false;

//range check
if (xslot<0) or (xslot>high(system_wincore.u)) then
   begin

   //out of range

   end

//load now
else if (not system_wincore.u[xslot]) then
   begin

   //init
   system_wincore.u[xslot] :=true;//mark slot as in use - all other values are zeroed out at this stage, which is their default state

   inc132(system_wincore.pcount);
   inc132(system_wincore.pOK);


   //fetch slot info
   win__slotinfo(xslot,dname,rvalue,pname,smisc);


   //.set important values for fast access
   system_wincore.r [xslot]  :=rvalue;//default return value for proc when unable to access it (e.g. fails to load)
   system_wincore.r2[xslot]  :=frcrange32(rvalue,0,max16);//26sep2025
   system_wincore.d [xslot]  :=dname; //dll name as an index


   //.check DLL and PROC names are valid
   if ( (dname<=dnone) or (dname>dmax) ) and emsg(waBadDLLName)  then exit;
   if (pname='')                         and emsg(waBadProcName) then exit;


   //load dll -> on failure -> stop here
   a:=system_wincore.dh[dname];

   //.attempt to load the DLL if not already in use (du=true)
   if (a=0) and (not system_wincore.du[dname]) then
      begin

      system_wincore.du[dname]:=true;//mark dll slot as in use

      system_wincore.dh[dname] :=win____LoadLibraryA(pchar( win__dllname(dname) ));//cache module handle
      a                        :=system_wincore.dh[dname];

      system_wincore.de[dname] :=low__aorb(waDLLLoadFail,waOk,a<>0);

      inc132(system_wincore.dcount);

      case (a<>0) of
      true:inc132(system_wincore.dOK);
      else inc132(system_wincore.dFAIL);
      end;//case

      end;

   //check DLL loaded -> on failure -> stop here
   if (a=0) and emsg(waDLLLoadFail) then exit;


   //fetch api proc function pointer by name -> on failure -> stop here
   b:=win____GetProcAddress(a,PAnsiChar( pname ));

   if (b=nil) then
      begin

      dec132(system_wincore.pOK);
      inc132(system_wincore.pFAIL);

      end;


   //check proc linked -> on failure -> stop here
   if (b=nil) and emsg(waProcNotFound) then exit;


   //get
   system_wincore.p[xslot] :=b;//set proc pointer (link to it)
   result                  :=true;

   end;

end;

function win__usebol(var xdefresult:bool;const xslot:longint;var xptr:pointer):boolean;////26sep2025
begin

result:=(xslot>=0) and (xslot<=high(system_wincore.u));

if result then
   begin

   result       :=win__ok(xslot);//26sep2025
   xdefresult   :=(system_wincore.r[xslot]<>0);//26sep2025
   xptr         :=system_wincore.p[xslot];
   win__inc(xslot);

   end
else
   begin

   xdefresult   :=false;
   xptr         :=nil;

   end;

end;

function win__usewrd(var xdefresult:word;const xslot:longint;var xptr:pointer):boolean;//26sep2025
begin

result:=(xslot>=0) and (xslot<=high(system_wincore.u));

if result then
   begin

   result       :=win__ok(xslot);//26sep2025
   xdefresult   :=system_wincore.r2[xslot];//word version
   xptr         :=system_wincore.p[xslot];
   win__inc(xslot);

   end
else
   begin

   xdefresult   :=0;
   xptr         :=nil;

   end;

end;

function win__useint(var xdefresult:longint;const xslot:longint;var xptr:pointer):boolean;//26sep2025
begin

result:=(xslot>=0) and (xslot<=high(system_wincore.u));

if result then
   begin

   result       :=win__ok(xslot);//26sep2025
   xdefresult   :=system_wincore.r[xslot];//26sep2025
   xptr         :=system_wincore.p[xslot];
   win__inc(xslot);

   end
else
   begin

   xdefresult   :=0;
   xptr         :=nil;

   end;

end;

function win__useptr(var xdefresult:pointer;const xslot:longint;var xptr:pointer):boolean;
begin

result:=(xslot>=0) and (xslot<=high(system_wincore.u));

if result then
   begin

   xdefresult   :=nil;
   result       :=system_wincore.u[xslot] or win__loaded(xslot);
   xptr         :=system_wincore.p[xslot];
   win__inc(xslot);

   end
else
   begin

   xdefresult   :=nil;
   xptr         :=nil;

   end;

end;

function win__usehnd(var xdefresult:thandle;const xslot:longint;var xptr:pointer):boolean;
begin

result:=(xslot>=0) and (xslot<=high(system_wincore.u));

if result then
   begin

   xdefresult   :=0;
   result       :=system_wincore.u[xslot] or win__loaded(xslot);
   xptr         :=system_wincore.p[xslot];
   win__inc(xslot);

   end
else
   begin

   xdefresult   :=0;
   xptr         :=nil;

   end;

end;

function win__use(const xslot:longint;var xptr:pointer):boolean;
begin

result:=(xslot>=0) and (xslot<=high(system_wincore.u));

if result then
   begin

   result       :=system_wincore.u[xslot] or win__loaded(xslot);
   xptr         :=system_wincore.p[xslot];
   win__inc(xslot);

   end
else
   begin

   xptr         :=nil;

   end;

end;

procedure win__errbol(var xresult:bool;const xreturn:bool);
begin

if (xresult<>xreturn) then inc132(system_wincore.ecount);
xresult:=xreturn;

end;

procedure win__errwrd(var xresult:word;const xreturn:word);
begin

if (xresult<>xreturn) then inc132(system_wincore.ecount);
xresult:=xreturn;

end;

procedure win__errint(var xresult:longint;const xreturn:longint);
begin

if (xresult<>xreturn) then inc132(system_wincore.ecount);
xresult:=xreturn;

end;

procedure win__errptr(var xresult:pointer;const xreturn:pointer);
begin

if (xreturn=nil) then inc132(system_wincore.ecount);
xresult:=xreturn;

end;

procedure win__errhnd(var xresult:thandle;const xreturn:thandle);
begin

if (xreturn=0) then inc132(system_wincore.ecount);
xresult:=xreturn;

end;


end.
