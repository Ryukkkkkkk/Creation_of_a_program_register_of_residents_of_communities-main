unit uAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, LCLIntf;

type
  { TfrmAbout }
  TfrmAbout = class(TForm)
    btnClose : TBitBtn;
    lblAuthors : TLabel;
    lblAuthor_1 : TLabel;
    lblAuthor_2 : TLabel;
    lblCaption1: TLabel;
    lblContact : TLabel;
    lblName : TLabel;
    lblVersion : TLabel;
    lblCaption : TLabel;
    pnlButtons : TPanel;
    procedure btnCloseClick(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure FormCreate(Sender : TObject);
    procedure lblContactClick(Sender : TObject);
    procedure lblContactMouseMove(Sender : TObject; Shift : TShiftState; X, Y : Integer);
    procedure lblContactMouseLeave(Sender : TObject);
  private

  public

  end;

var
  frmAbout : TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.FormCreate(Sender : TObject);
begin
  { TODO : Додати отримання поточної версії }
end;

procedure TfrmAbout.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TfrmAbout.btnCloseClick(Sender : TObject);
begin
  Close;
end;

procedure TfrmAbout.lblContactClick(Sender : TObject);
begin
  OpenDocument('mailto:' + lblContact.Caption);
end;

procedure TfrmAbout.lblContactMouseMove(Sender : TObject; Shift : TShiftState; X, Y : Integer);
begin
  lblContact.Font.Style := lblContact.Font.Style + [fsUnderline];
end;

procedure TfrmAbout.lblContactMouseLeave(Sender : TObject);
begin
  lblContact.Font.Style := lblContact.Font.Style - [fsUnderline];
end;

end.

