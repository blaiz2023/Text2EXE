program Text2EXE;

uses
  main in 'main.pas' {Form1},
  lroot in 'lroot.pas',
  lform in 'lform.pas',
  lwin in 'lwin.pas',
  lio in 'lio.pas',
  lzip in 'lzip.pas',
  lnet in 'lnet.pas',
  lwin2 in 'lwin2.pas',
  ldat in 'ldat.pas',
  limg in 'limg.pas',
  lgui in 'lgui.pas',
  limg2 in 'limg2.pas',
  lview in 'lview.pas',
  ljpeg in 'ljpeg.pas';

//{$R *.RES}
{$R text2exe-256.res}
{$R ver.res}

begin

app__boot(true,false,true,info__app,app__create,app__destroy);

end.
