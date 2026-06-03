//$D+}
{$D-,L-,O+,Q-,R-,Y-,S-}
program myentunnel;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles;

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'MyEntunnel';
  Application.ShowMainForm := False;
  Application.CreateForm(TForm1, Form1);
  if Form1.ConnectOnStartup.Checked then Form1.Connect.Click;
  Application.Run;
end.

