unit uBackup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, ExtCtrls, Buttons, Process, LCLType, LazFileUtils, LCLIntf,
  zstream, zipper, uFunctions;

type
  { TfrmBackup }
  TfrmBackup = class(TForm)
    btnBackup : TBitBtn;
    btnClose : TBitBtn;
    btnOpenFolder : TBitBtn;
    btnRestore : TBitBtn;
    dlgFindMySQL: TOpenDialog;
    dlgOpen : TOpenDialog;
    edtLast : TEdit;
    edtPath : TEdit;
    grpLast : TGroupBox;
    grpPath : TGroupBox;
    dlgFindMySQLDump: TOpenDialog;
    pnlBackupAndRestoreButtons : TPanel;
    pnlButtons : TPanel;
    dlgSave: TSaveDialog;
    procedure FormCreate(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure btnOpenFolderClick(Sender : TObject);
    procedure btnCloseClick(Sender : TObject);
    procedure btnBackupClick(Sender : TObject);
    procedure btnRestoreClick(Sender : TObject);
  private
    //
  public
    //
  end;

var
  frmBackup : TfrmBackup;

implementation

uses
  udm, uWait;

{$R *.lfm}

{ TfrmBackup }

procedure TfrmBackup.FormCreate(Sender : TObject);
var
  BackupPath,
  BackupTime : String;
begin
  BackupPath := '';
  BackupTime := '';

  if dm.GetIniPropStorageValue(Self.Name, 'Path', False, BackupPath) then edtPath.Text := BackupPath;
  if dm.GetIniPropStorageValue(Self.Name, 'Time', False, BackupTime) then edtLast.Text := BackupTime;
end;

procedure TfrmBackup.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  { TODO : Реалізувати запис шляху і часу в socfix.ini }
  CloseAction := caFree;
end;

procedure TfrmBackup.btnCloseClick(Sender : TObject);
begin
  Close;
end;

procedure TfrmBackup.btnOpenFolderClick(Sender : TObject);
begin
  OpenDocument(edtPath.Text);
end;

procedure TfrmBackup.btnBackupClick(Sender : TObject);
var
  MySQLDump : TProcess;
  Zipper : TZipper;
  ZipFileEntry :TZipFileEntry;
  x64Path, x86Path,
  BackupName,
  TempFileName,
  DefaultHost,
  DumpFileName : String;
begin
  x64Path    := ProgramFilesX64Path + 'MySQL\MySQL Server 5.6\bin\mysqldump.exe';
  x86Path    := ProgramFilesX86Path + 'MySQL\MySQL Server 5.6\bin\mysqldump.exe';

  BackupName   := 'SF-DB_' + FormatDateTime('yyyy.mm.dd-hh.nn.ss', Now) + '.sfbackup';
  DefaultHost  := '127.0.0.1';
  DumpFileName := '';

  if not dm.GetIniPropStorageValue(Self.Name, 'Dump', False, DumpFileName) then Exit;

  if not FullStr(DumpFileName) or
     not FileExists(DumpFileName)
  then
  begin
    if FileExists(x64Path) then DumpFileName := x64Path else
    if FileExists(x86Path) then DumpFileName := x86Path else
    begin
      if not dlgFindMySQLDump.Execute then Exit;

      DumpFileName := dlgFindMySQLDump.FileName;
    end;
  end;

  if not FileExists(DumpFileName) then
  begin
    Application.MessageBox(PChar('Не знайдено компонент створення' + LineEnding +
                                 'резервних копій!'),
                           PChar(Caption),
                           MB_OK + MB_ICONSTOP);
    Exit;
  end;

  if (dm.MySQLDB56.HostName = DefaultHost) or
     (dm.MySQLDB56.HostName = LocalIPAddress)
  then
  begin
    if EmptyStr(edtPath.Text)
    then dlgSave.InitialDir := ApplicationPath
    else dlgSave.InitialDir := edtPath.Text;

    dlgSave.FileName := BackupName;

    MySQLDump := TProcess.Create(nil);
    Zipper    := TZipper.Create;
    frmWait   := TfrmWait.uCreate(Self, 'Створення резервної копії...');

    try
      if not dlgSave.Execute then Exit;

      Self.Refresh;

      frmWait.Show;
      frmWait.Refresh;

      Zipper.FileName := dlgSave.FileName;
      BackupName      := ExtractFileNameOnly(dlgSave.FileName);
      TempFileName    := SFTempPath + BackupName + '.sql';

      MySQLDump.Executable := DumpFileName;

      MySQLDump.Parameters.Add('-h'  + dm.MySQLDB56.HostName);
      MySQLDump.Parameters.Add('-P'  + IntToStr(dm.MySQLDB56.Port));
      MySQLDump.Parameters.Add('-u'  + dm.MySQLDB56.UserName);
      MySQLDump.Parameters.Add('-p'  + dm.MySQLDB56.Password);
      MySQLDump.Parameters.Add('-c');
      MySQLDump.Parameters.Add('-e');
      MySQLDump.Parameters.Add('-B "' + dm.MySQLDB56.DatabaseName + '"');
      MySQLDump.Parameters.Add('-r "' + TempFileName + '"');

      MySQLDump.Options := [poWaitOnExit];

      try
        MySQLDump.Execute;

        if FileExists(TempFileName) and (FileSizeUtf8(TempFileName) > 0) then
        begin
          ZipFileEntry := Zipper.Entries.AddFileEntry(TempFileName, ExtractFileName(TempFileName));

          ZipFileEntry.CompressionLevel := cldefault;

          Zipper.ZipAllFiles;
        end;

        DeleteFileUTF8(TempFileName);
      except
        on E:Exception do
        begin
          Application.MessageBox(PChar('Резервну копію не створено!' + LineEnding +
                                                                       LineEnding +
                                       'Модуль: ' + E.ClassName      + LineEnding +
                                                                       LineEnding +
                                       'Виникла наступна помилка:'   + LineEnding +
                                        E.Message                    + LineEnding +
                                                                       LineEnding +
                                       'Закрийте вікно і повторіть спробу.'),
                                 PChar(Caption),
                                 MB_OK + MB_ICONSTOP);
          Exit;
        End;
      end;
    finally
      frmWait.Free;
      Zipper.Free;
      MySQLDump.Free;
    end;

    if FileExists(dlgSave.FileName) and (FileSizeUtf8(dlgSave.FileName) > 0) then
    begin
      edtPath.Text := ExtractFilePath(dlgSave.FileName);
      edtLast.Text := FormatDateTime('dd.mm.yyyy hh:nn:ss', Now);

      dm.SetIniPropStorageValue(Self.Name, 'Dump', DumpFileName);
      dm.SetIniPropStorageValue(Self.Name, 'Path', ExtractFilePath(dlgSave.FileName));
      dm.SetIniPropStorageValue(Self.Name, 'Time', FormatDateTime('dd.mm.yyyy hh:nn:ss', Now));

      Application.MessageBox(PChar('Резервну копію створено успішно!'),
                             PChar(Caption),
                             MB_OK + MB_ICONINFORMATION);
    end;
  end
  else
  begin
    Application.MessageBox(PChar('Створення резервних копій передбачене' + LineEnding +
                                 'лише на серверы СУБД!'),
                           PChar(Caption),
                           MB_OK + MB_ICONWARNING);
  end;
end;

procedure TfrmBackup.btnRestoreClick(Sender : TObject);
var
  MySQL     : TProcess;          //
  x64Path, x86Path,              //
  BackupName,                    //
  TempFileName,                  //
  DefaultHost,                   //
  RestoreFileName,                  //
  UnzipFile,                     // файл який буде розпаковуватися
  UnzippedFolderName: String;    // місце розпакування файлу
  UnZipper: TUnZipper;
begin
  UnzippedFolderName := ApplicationPath + 'Backup\SFTempPath';
  x64Path      := ProgramFilesX64Path + 'MySQL\MySQL Server 5.6\bin\mysqladmin .exe';
  x86Path      := ProgramFilesX86Path + 'MySQL\MySQL Server 5.6\bin\mysqladmin .exe';
  DefaultHost  := '127.0.0.1';
  BackupName   := '';
  RestoreFileName := '';

  //перевірка чи в файлі .ini існує запис про місце розташування компоненти MySQLadmin
  if not dm.GetIniPropStorageValue(Self.Name, 'Restore', False, RestoreFileName) then Exit;

  if not FullStr(RestoreFileName) or
     not FileExists(RestoreFileName)
  then
  //перевірка чи MySQLDump існує в типових директоріях х64 та х86
  begin
    if FileExists(x64Path) then RestoreFileName := x64Path else
    if FileExists(x86Path) then RestoreFileName := x86Path else
  //відкриття утиліти MySQLDump через діалогове вікно
    begin
      if not dlgFindMySQL.Execute then Exit;
      RestoreFileName := dlgFindMySQL.FileName;
    end;
  end;
  if not FileExists(RestoreFileName) then
  begin
    Application.MessageBox(PChar('Не знайдено компонент відновлення' + LineEnding +
                                 'резервних копій!'),
                           PChar(Caption),
                           MB_OK + MB_ICONSTOP);
    Exit;
  end;

  if (dm.MySQLDB56.HostName = DefaultHost) or
     (dm.MySQLDB56.HostName = LocalIPAddress)
  then
  // розпакування старої запакованої бази
  Begin
     if not dlgOpen.Execute then Exit;
     UnzipFile := dlgOpen.FileName;
     UnZipper := TUnZipper.Create;
     try
        UnZipper.FileName   := UnzipFile;            //файл який буде розпаковано
        UnZipper.OutputPath := UnzippedFolderName;   //місце розпакування файлу
        UnZipper.Examine;                            //
        UnZipper.UnZipAllFiles;                      //
     finally
         UnZipper.Free;
     end;
  //Create your new database
      MySQL := TProcess.Create(nil);
      BackupName      := ExtractFileNameOnly(dlgOpen.FileName);
      TempFileName    := SFTempPath + BackupName + '.sql';

      MySQL.Executable := RestoreFileName;

      MySQL.Parameters.Add('-u');
      MySQL.Parameters.Add('-p');
      MySQL.Parameters.Add('create database ');
      MySQL.Parameters.Add('use ');
      MySQL.Parameters.Add('source D:\Socfix\Bin\Backup\SFTempPath\SF-DB_2019.06.19-08.35.57.sql');

      MySQL.Options := [poWaitOnExit];

      try
        MySQL.Execute;
      except
        on E:Exception do
        begin
          Application.MessageBox(PChar('Резервну копію не відновлено!' + LineEnding +
                                                                       LineEnding +
                                       'Модуль: ' + E.ClassName      + LineEnding +
                                                                       LineEnding +
                                       'Виникла наступна помилка:'   + LineEnding +
                                        E.Message                    + LineEnding +
                                                                       LineEnding +
                                       'Закрийте вікно і повторіть спробу.'),
                                 PChar(Caption),
                                 MB_OK + MB_ICONSTOP);
          Exit;
        End;
   end
   end
  else
  begin
    Application.MessageBox(PChar('Відновдення резервних копій передбачене' + LineEnding +
                                 'лише на серверы СУБД!'),
                           PChar(Caption),
                           MB_OK + MB_ICONWARNING);
  end;

end;

end.

