Program SocFix;

{$mode objfpc}{$H+}

Uses
  {$IFDEF UNIX}
  {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  RunTimeTypeInfoControls,
  DateTimeCtrls,
  udm,
  uPassword,
  uPassword_Edit,
  uMain,
  uAbout,
  uPopulation,
  uPopulation_Edit,
  uUsers,
  uUsers_Edit,
  uReference,
  uReference_Edit,
  uHouse,
  uHouse_Edit,
  uInhabitant_Edit,
  uBackup,
  uGeneral_Data,
  uGeneral_Data_Edit,
  uAddress_Edit;

{$R *.res}

Begin
  Application.Scaled := True;

  RequireDerivedFormResource := True;

  Application.Initialize;

  Application.CreateForm(Tdm, dm);

  if dm.MySQLDB56.Connected then
  begin
    if TfrmPassword.Execute then
    begin
      Application.CreateForm(TfrmMain, frmMain);

      Application.Run;
    end;
  end;
End.
