unit uWait;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TfrmWait }

  TfrmWait = class(TForm)
    bvlBorder : TBevel;
    imgLogo : TImage;
    lblMessage : TLabel;
  private
    //
  public
    constructor uCreate(Sender : TComponent; AMessage : String);
  end;

var
  frmWait : TfrmWait;

implementation

{$R *.lfm}

constructor TfrmWait.uCreate(Sender : TComponent; AMessage : String);
begin
  Inherited Create(Sender);

  lblMessage.Caption := AMessage;
end;

end.

