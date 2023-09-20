Unit uMain;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, sqldb, db, FileUtil, LR_Class, LR_DBSet, Forms, Controls,
  Graphics, Dialogs, Menus, LCLType, ComCtrls, ExtCtrls, Buttons, ActnList,
  StdCtrls, EditBtn, DbCtrls, DBGrids, windows, LazUTF8, LR_RRect, fpstypes,
  fpsexport, LCLIntf, uSelect, uFunctions;

Type
  { TfrmMain }
  TfrmMain = Class(TForm)
    actFamily_Del : TAction;
    actFamily_Upd : TAction;
    actExport : TAction;
    actDel : TAction;
    actFamily_Upd_Person : TAction;
    actSetCurrentPerson : TAction;
    actSetCurrentHouse: TAction;
    btnFamily_Upd : TBitBtn;
    chkFemale : TCheckBox;
    chkLifeless : TCheckBox;
    chkHomeless : TCheckBox;
    chkMale : TCheckBox;
    chkAlive : TCheckBox;
    chkUnderaged : TCheckBox;
    dbgPopulation : TDBGrid;
    dbgLandOwners : TDBGrid;
    dsLandOwners : TDataSource;
    frDSLandOwners : TfrDBDataSet;
    lcbLocation : TDBLookupComboBox;
    MainMenu : TMainMenu;
    mmLands_Purpose : TMenuItem;
    mmReferencesLine_4 : TMenuItem;
    mmProgramLine_3 : TMenuItem;
    mmHelp : TMenuItem;
    mmAbout : TMenuItem;
    pmFamily_Line_1 : TMenuItem;
    pmFamily_Upd_Person : TMenuItem;
    pmFamily_Line_2 : TMenuItem;
    mmReferencesLine_3 : TMenuItem;
    mmReferencesLine_2 : TMenuItem;
    mmGeneral_Data : TMenuItem;
    pmFamily_Line_4 : TMenuItem;
    pmFamily_Lifeless: TMenuItem;
    pmFamily_Completely_Absent: TMenuItem;
    pmPopulation_Line_3: TMenuItem;
    pmFamily_Columns: TMenuItem;
    pmFamily_Temporarily_Absent: TMenuItem;
    pmFamily_Columns_Passport: TMenuItem;
    pmHouse_Add1 : TMenuItem;
    pmHouse_Print1 : TMenuItem;
    pmHouse_Space_2 : TMenuItem;
    pmHouse_Upd1 : TMenuItem;
    pmPopulation_Columns_Passport: TMenuItem;
    pmPopulation_Columns: TMenuItem;
    pmFamily_SetCurrentPerson : TMenuItem;
    pmPopulation_Del : TMenuItem;
    pmPopulation_Line_2 : TMenuItem;
    mmProgramLine_2 : TMenuItem;
    mmBackup : TMenuItem;
    pmExport: TMenuItem;
    pmPopulation_SetCurrentHouse: TMenuItem;
    pmFamily_Del : TMenuItem;
    mmReferencesLine_1 : TMenuItem;
    mmPassword : TMenuItem;
    mmProgramLine_1 : TMenuItem;
    mmVillage : TMenuItem;
    mmStreet : TMenuItem;
    mmRegion : TMenuItem;
    mmDistrict : TMenuItem;
    mmAffinity : TMenuItem;
    mmNationality : TMenuItem;
    mmUsers : TMenuItem;
    mmReferences : TMenuItem;
    mmPopulation : TMenuItem;
    mmWindows : TMenuItem;
    mmClose : TMenuItem;
    mmProgram : TMenuItem;
    pcInfo : TPageControl;
    pmHouse_Add : TMenuItem;
    pmFamily_Add : TMenuItem;
    pmHouse_Print : TMenuItem;
    pmHouse_Space_1 : TMenuItem;
    pmFamily_Line_3 : TMenuItem;
    pmHouse_Upd : TMenuItem;
    pmFamily_Upd : TMenuItem;
    pnlButtons : TPanel;
    btnAdd : TBitBtn;
    btnUpd : TBitBtn;
    btnClose : TBitBtn;
    btnPrint : TBitBtn;
    ActionList : TActionList;
    actAdd : TAction;
    actUpd : TAction;
    actPrint : TAction;
    pnlFilters_Population : TPanel;
    pUpmHouse : TPopupMenu;
    pUpmFamily : TPopupMenu;
    dlgSave: TSaveDialog;
    pLandOwners : TPopupMenu;
    qLandOwners : TSQLQuery;
    sqlQuery : TSQLQuery;
    tsLandOwners : TTabSheet;
    tmrSearch : TTimer;
    tmrScroll : TTimer;
    qFamily : TSQLQuery;
    dsFamily : TDataSource;
    frDSFamily : TfrDBDataSet;
    qLocation : TSQLQuery;
    dsLocation : TDataSource;
    pnlFilters : TPanel;
    grpSearch : TGroupBox;
    edtSearch : TEditButton;
    grpLocation : TGroupBox;
    tsPopulation : TTabSheet;
    tsHouse : TTabSheet;
    actFamily_Add : TAction;
    pUpmPrint : TPopupMenu;
    pmPrint : TMenuItem;
    pmDesign : TMenuItem;
    Splitter : TSplitter;
    mmStreetType : TMenuItem;
    mmHouse : TMenuItem;
    actLands_Upd : TAction;
    qLands : TSQLQuery;
    dsLands : TDataSource;
    actLands_Add : TAction;
    actLands_Del : TAction;
    pcDetails : TPageControl;
    tsFamily : TTabSheet;
    dbgFamily : TDBGrid;
    tsLands : TTabSheet;
    dbgLands : TDBGrid;
    pnlFamily_Buttons : TPanel;
    btnFamily_Add : TBitBtn;
    btnFamily_Del : TBitBtn;
    pnlLands_Buttons : TPanel;
    btnLands_Add : TBitBtn;
    btnLands_Upd : TBitBtn;
    btnLands_Del : TBitBtn;
    frDSLands : TfrDBDataSet;
    qPopulation : TSQLQuery;
    dsPopulation : TDataSource;
    frDSPopulation : TfrDBDataSet;
    pUpmPopulation : TPopupMenu;
    pmPopulation_Add : TMenuItem;
    pmPopulation_Upd : TMenuItem;
    pmPopulation_Line_1 : TMenuItem;
    pmPopulation_Print : TMenuItem;
    frDSHouse : TfrDBDataSet;
    dsHouse : TDataSource;
    qHouse : TSQLQuery;
    dbgHouse : TDBGrid;
    pnlFilters_House : TPanel;
    chkWithout_Inhabitant : TCheckBox;
    Procedure FormCreate(Sender : TObject);
    Procedure FormClose(Sender : TObject; Var CloseAction : TCloseAction);
    Procedure btnCloseClick(Sender : TObject);
    Procedure ShowApplicationWindow(Sender: TObject);
    procedure mmGeneral_DataClick(Sender : TObject);
    Procedure mmHouseClick(Sender : TObject);
    Procedure mmPopulationClick(Sender : TObject);
    Procedure mmReferenceClick(Sender : TObject);
    procedure mmAboutClick(Sender : TObject);
    procedure mmHelpClick(Sender : TObject);
    Procedure mmUsersClick(Sender : TObject);
    Procedure mmPasswordClick(Sender : TObject);
    Procedure mmBackupClick(Sender : TObject);
    procedure pmGridColumnsVisibleClick(Sender : TObject);
    Procedure dbgDblClick(Sender : TObject);
    Procedure dbgTitleClick(Column : TColumn);
    Procedure dbgUTF8KeyPress(Sender : TObject;  Var UTF8Key : TUTF8Char);
    Procedure dbgFamilyDblClick(Sender : TObject);
    Procedure dbgLandsDblClick(Sender : TObject);
    Procedure edtSearchButtonClick(Sender : TObject);
    Procedure OnFilterUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
    Procedure OnFilterDropDown(Sender : TObject);
    Procedure OnFilterCloseUp(Sender : TObject);
    Procedure OnFilterChange(Sender : TObject);
    Procedure tmrSearchTimer(Sender : TObject);
    Procedure tmrScrollTimer(Sender : TObject);
    procedure pcDetailsChange(Sender : TObject);
    Procedure qPopulationAfterOpen(DataSet : TDataSet);
    Procedure qHouseAfterOpen(DataSet : TDataSet);
    procedure qLandOwnersAfterOpen(DataSet : TDataSet);
    Procedure qFamilyAfterOpen(DataSet : TDataSet);
    Procedure qLandsAfterOpen(DataSet : TDataSet);
    Procedure qQueryAfterScroll(DataSet : TDataSet);
    Procedure qPopulationAfterScrollForPrint(DataSet : TDataSet);
    Procedure actPrintExecute(Sender : TObject);
    Procedure actAddUpdExecute(Sender : TObject);
    procedure actDelExecute(Sender : TObject);
    procedure actExportExecute(Sender : TObject);
    Procedure actFamilyAddUpdExecute(Sender : TObject);
    Procedure actFamily_DelExecute(Sender : TObject);
    Procedure actFamily_Upd_PersonExecute(Sender : TObject);
    Procedure actLandsAddUpdExecute(Sender : TObject);
    Procedure actLands_DelExecute(Sender : TObject);
    Procedure actSetCurrentHouseExecute(Sender: TObject);
    Procedure actSetCurrentPersonExecute(Sender : TObject);
  Private
    { private declarations }
    is_Start, is_Change : Boolean;
    procedure QueryRefresh(AQuery : TSQLQuery; AFetch : Boolean = False);
    procedure QueryFetchAll(AQuery : TSQLQuery);
  Public
    { public declarations }
    Procedure AddItemToMainMenu(ACaption : String; Var AMenuHandle : HMenu; AFormHandle : HWND);
    Procedure ChangeItemOnMainMenu(ACaption : String; AMenuHandle : HMenu);
    Procedure DeleteItemFromMainMenu(AMenuHandle : HMenu);
  End;

Var
  frmMain : TfrmMain;

Implementation

uses
  udm, uWait, uAbout, uBackup, uUsers, uReference, uPopulation, uGeneral_Data,
  uHouse, uPassword_Edit, uPopulation_Edit, uHouse_Edit, uLands_Edit,
  uInhabitant_Edit;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.QueryRefresh(AQuery : TSQLQuery; AFetch : Boolean = False);
var
  Locate_ID : Variant;
begin
  if AQuery.RecordCount > 0
  then Locate_ID := AQuery.FieldByName('ID').Value
  else Locate_ID := 0;

  AQuery.Close;
  AQuery.Open;

  if AFetch then QueryFetchAll(AQuery);

  AQuery.Locate('ID', Locate_ID, []);
end;

procedure TfrmMain.QueryFetchAll(AQuery : TSQLQuery);
begin
  AQuery.DisableControls;
  AQuery.Last;
  AQuery.First;
  AQuery.EnableControls;
end;

// Додати останнє відкрите вікно до списку активних вікон (Головне меню -> Вікна).
Procedure TfrmMain.AddItemToMainMenu(ACaption : String; Var AMenuHandle : HMenu; AFormHandle : HWND);
Var
  NewItem: TMenuItem;
  MenuIndex : Integer;
Begin
  NewItem         := TMenuItem.Create(Self);
  NewItem.Caption := ACaption;
  NewItem.Tag     := AFormHandle;

  mmWindows.Add(NewItem);

  MenuIndex := mmWindows.IndexOf(NewItem);

  mmWindows.Items[MenuIndex].OnClick := @ShowApplicationWindow;

  AMenuHandle := mmWindows.Items[MenuIndex].Handle;
End;

Procedure TfrmMain.ChangeItemOnMainMenu(ACaption : String; AMenuHandle : HMenu);
Var
  i : Word;
Begin
  For i := 0 to mmWindows.Count - 1 do
  Begin
    If AMenuHandle = mmWindows.Items[i].Handle Then
    Begin
      mmWindows.Items[i].Caption := ACaption;

      Break;
    End;
  End;
End;

// Видалити останнє закрите вікно зі списку активних вікон (Головне меню -> Вікна).
Procedure TfrmMain.DeleteItemFromMainMenu(AMenuHandle : HMenu);
Var
  i : Word;
Begin
  For i := 0 to mmWindows.Count - 1 do
  Begin
    If AMenuHandle = mmWindows.Items[i].Handle Then
    Begin
      mmWindows.Items[i].Destroy;

      Break;
    End;
  End;
End;

Procedure TfrmMain.FormCreate(Sender : TObject);
  procedure LoadGridColumnsVisible(AGrid : TDBGrid; AMenuItem : TMenuItem; AColumnName : String);
  var
    LParam : String;
    LValue : Boolean;
  begin
    LParam := AGrid.Name + '.' + AColumnName + '.Visible';
    LValue := False;

    if dm.GetIniPropStorageValue(Self.Name, LParam, False, LValue) then
    begin
      AMenuItem.Checked := LValue;

      pmGridColumnsVisibleClick(AMenuItem);
    end;
  end;
Begin
  is_Start  := False;
  is_Change := False;

  btnFamily_Add.Caption := '';
  btnFamily_Upd.Caption := '';
  btnFamily_Del.Caption := '';

  btnLands_Add.Caption := '';
  btnLands_Upd.Caption := '';
  btnLands_Del.Caption := '';

  pcInfo.ActivePage    := tsPopulation;
  pcDetails.ActivePage := tsFamily;

  qLocation.Open;
  qLocation.Last;
  qLocation.First;

  lcbLocation.KeyValue := -1;

  // Встановлюємо мову вводу - українську
  try
    LoadKeyboardLayout(PChar('00000422'), KLF_ACTIVATE);
  except
    //
  End;

  dm.LoadGlobal_Data();

  is_Start := True;

  OnFilterChange(nil);

  //Встановлюємо параметр видимості паспортних даних
  LoadGridColumnsVisible(dbgPopulation, pmPopulation_Columns_Passport, 'Passport');
  LoadGridColumnsVisible(dbgFamily,     pmFamily_Columns_Passport,     'Passport');
End;

Procedure TfrmMain.FormClose(Sender : TObject; Var CloseAction : TCloseAction);
Begin
  is_Start := False;

  qLocation.Close;
  qFamily.Close;
  qLands.Close;
  qPopulation.Close;
  qHouse.Close;
  qLandOwners.Close;

  dm.MySQLDB56.Connected := False;

  CloseAction := caFree;
End;

Procedure TfrmMain.btnCloseClick(Sender : TObject);
Begin
  Close;
End;

Procedure TfrmMain.ShowApplicationWindow(Sender: TObject);
Var
  R : TRect;
  sTag : Integer;
Begin
  If Sender.ClassName = 'TMenuItem' Then
  Begin
    sTag := (Sender as TMenuItem).Tag;

    ShowWindow(sTag, SW_Restore);
    BringWindowToTop(sTag);

    R := ClientRect;

    GetWindowRect(sTag, R);

    If R.Left > Screen.Width Then
    Begin
      SetWindowPos(sTag,
                   HWND_TOP,
                  (R.Left - Screen.Width),
                   R.Top,
                  (R.Right - R.Left),
                  (R.Bottom - R.Top),
                   SWP_FRAMECHANGED);
    End;
  End;
End;

procedure TfrmMain.mmGeneral_DataClick(Sender : TObject);
var
  Data_Changed : Boolean;
begin
  Data_Changed := False;

  with TfrmGeneral_Data.CreateInt(Self, Data_Changed) do
  Begin
    ShowModal;
    Free;
  End;

  if Data_Changed then
  begin
    //
  end;
end;

Procedure TfrmMain.mmHouseClick(Sender : TObject);
Begin
  with TfrmHouse.Create(Self) do
  Begin
    ShowModal;
    Free;
  End;
End;

Procedure TfrmMain.mmPopulationClick(Sender : TObject);
Begin
  with TfrmPopulation.Create(Self) do
  Begin
    ShowModal;
    Free;
  End;
End;

Procedure TfrmMain.mmReferenceClick(Sender : TObject);
Var
  ReferenceCaption,
  ReferenceTable : String;
Begin
  If Sender = mmRegion Then
  Begin
    ReferenceCaption := 'Довідник областей';
    ReferenceTable   :=  UTF8Trim(UTF8UpperString('OBLAST'));
  end
  Else
  If Sender = mmDistrict Then
  Begin
    ReferenceCaption := 'Довідник районів';
    ReferenceTable   :=  UTF8Trim(UTF8UpperString('RAION'));
  end
  Else
  If Sender = mmVillage Then
  Begin
    ReferenceCaption := 'Довідник сіл';
    ReferenceTable   :=  UTF8Trim(UTF8UpperString('SELO'));
  end
  Else
  If Sender = mmStreet Then
  Begin
    ReferenceCaption := 'Довідник вулиць';
    ReferenceTable   :=  UTF8Trim(UTF8UpperString('VULYTSIA'));
  end
  Else
  If Sender = mmStreetType Then
  Begin
    ReferenceCaption := 'Довідник типів вулиць';
    ReferenceTable   :=  UTF8Trim(UTF8UpperString('TYP_VULYTSI'));
  end
  Else
  If Sender = mmNationality Then
  Begin
    ReferenceCaption := 'Довідник громадянств';
    ReferenceTable   :=  UTF8Trim(UTF8UpperString('HROMADIANSTVO'));
  end
  Else
  If Sender = mmAffinity Then
  Begin
    ReferenceCaption := 'Довідник родинних зв''язків';
    ReferenceTable   :=  UTF8Trim(UTF8UpperString('TYP_SPORIDNENOSTI'));
  end
  Else
  If Sender = mmLands_Purpose Then
  Begin
    ReferenceCaption := 'Довідник цільового призначення землі';
    ReferenceTable   :=  UTF8Trim(UTF8UpperString('TYP_ZEMLI'));
  end
  Else Exit;

  with TfrmReference.CreateInt(Self, ReferenceCaption, ReferenceTable, Null) do
  Begin
    ShowModal;
    Free;
  End;
End;

procedure TfrmMain.mmAboutClick(Sender : TObject);
begin
  with TfrmAbout.Create(Self) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TfrmMain.mmHelpClick(Sender : TObject);
begin
  OpenDocument('https://drive.google.com/drive/folders/1EctnP2xX_NGXkKoacY8jltmsJ7XYp0pX?usp=sharing');
end;

Procedure TfrmMain.mmUsersClick(Sender : TObject);
Begin
  with TfrmUsers.Create(Self) do
  Begin
    ShowModal;
    Free;
  End;
End;

Procedure TfrmMain.mmPasswordClick(Sender : TObject);
Begin
  with TfrmPassword_Edit.Create(Self) do
  Begin
    ShowModal;
    Free;
  End;
End;

procedure TfrmMain.mmBackupClick(Sender : TObject);
begin
  with TFrmBackup.Create(Self) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TfrmMain.pmGridColumnsVisibleClick(Sender : TObject);
var
  LField : String;
  LMenuItem : TMenuItem;
  LDBGrid : TDBGrid;
  LForm : TForm;
  i : Word;

  procedure SetGridColumnVisibleStatus();
  begin
    if dm.GridColumnByName(LDBGrid, LField) <> nil then
    begin
      dm.GridColumnByName(LDBGrid, LField).Visible := LMenuItem.Checked;

      dm.SetIniPropStorageValue(Self.Name,
                              LDBGrid.Name + '.' + LField + '.Visible',
                              LMenuItem.Checked);

    end;
  end;
begin
  LField    := '';
  LMenuItem := nil;
  LDBGrid   := nil;

  if (Sender = pmPopulation_Columns_Passport) or
     (Sender = pmFamily_Columns_Passport)
  then LField := 'PASSPORT';

  if EmptyStr(LField) then Exit;

  if Sender is TMenuItem
  then LMenuItem := TMenuItem(Sender)
  else Exit;

  if LMenuItem.GetParentMenu is TPopupMenu then
  begin
    if TPopupMenu(LMenuItem.GetParentMenu).PopupComponent <> nil then
    begin
      if TPopupMenu(LMenuItem.GetParentMenu).PopupComponent is TDBGrid then
      begin
        LDBGrid := TDBGrid(TPopupMenu(LMenuItem.GetParentMenu).PopupComponent);

        SetGridColumnVisibleStatus();
      end;
    end
    else
    begin
      if TPopupMenu(LMenuItem.GetParentMenu).Owner is TForm then
      begin
        LForm := TForm(TPopupMenu(LMenuItem.GetParentMenu).Owner);

        for i := 0 to LForm.ComponentCount - 1 do
        begin
          if LForm.Components[i] is TDBGrid then
          begin
            if TDBGrid(LForm.Components[i]).PopupMenu = TPopupMenu(LMenuItem.GetParentMenu) then
            begin
              if TDBGrid(LForm.Components[i]) <> nil then
              begin
                LDBGrid := TDBGrid(LForm.Components[i]);

                SetGridColumnVisibleStatus();
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  if dbgPopulation.Columns[3].Visible=true then
  begin
     dbgPopulation.Columns[6].Width:=330;
     dbgPopulation.Columns[8].Width:=40;
  end;
     dbgPopulation.Columns[6].Width:=400;
     dbgPopulation.Columns[8].Width:=100;
end;

Procedure TfrmMain.dbgDblClick(Sender : TObject);
Begin
  if pcInfo.ActivePage = tsPopulation then
  begin
    If qPopulation.RecordCount = 0
    Then btnAdd.Click
    Else btnUpd.Click;
  end
  else
  if pcInfo.ActivePage = tsHouse then
  begin
    If qHouse.RecordCount = 0
    Then btnAdd.Click
    Else btnUpd.Click;
  end;
End;

Procedure TfrmMain.dbgFamilyDblClick(Sender : TObject);
Begin
  If qFamily.RecordCount = 0
  Then btnFamily_Add.Click
  Else btnFamily_Upd.Click;
end;

Procedure TfrmMain.dbgLandsDblClick(Sender : TObject);
Begin
  If qLands.RecordCount = 0
  Then btnLands_Add.Click
  Else btnLands_Upd.Click;
end;

Procedure TfrmMain.dbgTitleClick(Column : TColumn);
Begin
  if pcInfo.ActivePage = tsPopulation then
  begin
    if Column = nil
    then dm.GridSort(dbgPopulation, 'ID', 'ID')
    else dm.GridSort(dbgPopulation, 'ID', Column.FieldName);
  end
  else
  if pcInfo.ActivePage = tsHouse then
  begin
    if Column = nil
    then dm.GridSort(dbgHouse, 'ID', 'ID')
    else dm.GridSort(dbgHouse, 'ID', Column.FieldName);
  end
  else
  if pcInfo.ActivePage = tsLandOwners then
  begin
    if Column = nil
    then dm.GridSort(dbgLandOwners, 'ID', 'ID')
    else dm.GridSort(dbgLandOwners, 'ID', Column.FieldName);
  end;
end;

Procedure TfrmMain.dbgUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
  If not ((UTF8Key > ' ') or
          (UTF8Key =  #8) or
          (UTF8Key = #13) or
          (UTF8Key = #22) or
          (UTF8Key = #46)) Then Exit;

  If (UTF8Key > ' ') or (UTF8Key = #8) Then
  Begin
    If UTF8Key = #8
    Then edtSearch.Text := UTF8Copy(edtSearch.Text, 1, UTF8Length(edtSearch.Text) - 1)
    Else edtSearch.Text := edtSearch.Text + UTF8Key;

    edtSearch.SetFocus;
    edtSearch.SelStart := UTF8Length(edtSearch.Text);
  End;

  If (UTF8Key = #13) Then
  Begin
    UTF8Key := #0;

    dbgDblClick(nil);
  End;
End;

Procedure TfrmMain.edtSearchButtonClick(Sender : TObject);
Begin
  edtSearch.Clear;
End;

Procedure TfrmMain.OnFilterUTF8KeyPress(Sender : TObject; Var UTF8Key : TUTF8Char);
Begin
  case UTF8Key of
    #10 : Begin
            UTF8Key := #0;

            tmrSearchTimer(nil);
          End;
    #13 : Begin
            UTF8Key := #0;

            SelectNext(ActiveControl, True, True);
          End;
  End;
End;

Procedure TfrmMain.OnFilterDropDown(Sender : TObject);
Begin
  If is_Change Then tmrSearch.Enabled := False;
End;

Procedure TfrmMain.OnFilterCloseUp(Sender : TObject);
Begin
  If is_Change Then tmrSearch.Enabled := True;
End;

Procedure TfrmMain.OnFilterChange(Sender : TObject);
Begin
  If not is_Start Then Exit;

  tsFamily.TabVisible := (pcInfo.ActivePage = tsPopulation) or
                         (pcInfo.ActivePage = tsHouse);
  tsLands.TabVisible  := (pcInfo.ActivePage = tsPopulation) or
                         (pcInfo.ActivePage = tsLandOwners);

  dm.SetGridColumnVisible(dbgFamily, 'RELATIONSHIP', (pcInfo.ActivePage = tsPopulation));

  pnlFilters_Population.Visible := (pcInfo.ActivePage = tsPopulation);
  pnlFilters_House.Visible      := (pcInfo.ActivePage = tsHouse);

  if pcInfo.ActivePage = tsPopulation then
  begin
    actAdd.Visible := True;
    actAdd.Caption := 'Новий мешканець';
    actAdd.Hint    := 'Додати до бази даних інформацію про нового мешканця';

    actUpd.Visible := True;

    pnlFilters_Population.Left := 175;
    pnlFilters_House.Left      := pnlFilters_Population.Left + pnlFilters_Population.Width;
  End
  else
  if pcInfo.ActivePage = tsHouse then
  begin
    actAdd.Visible := True;
    actAdd.Caption := 'Нове господарство';
    actAdd.Hint    := 'Додати до бази даних інформацію про нове господарство';

    actUpd.Visible := True;

    pnlFilters_House.Left      := 175;
    pnlFilters_Population.Left := pnlFilters_House.Left + pnlFilters_House.Width;
  End
  else
  if pcInfo.ActivePage = tsLandOwners then
  begin
    actAdd.Visible := False;
    actUpd.Visible := False;
  End;

  is_Change := True;

  tmrSearch.Enabled := False;
  tmrSearch.Enabled := True;
End;

Procedure TfrmMain.tmrSearchTimer(Sender : TObject);
Var
  Locate_ID : Integer;
  tS, tA : String;
Begin
  tmrSearch.Enabled := False;

  frmWait := TfrmWait.uCreate(Self, 'Виконується запит...');

  try
    Self.Refresh;

    frmWait.Show;
    frmWait.Refresh;

    if pcInfo.ActivePage = tsPopulation then
    begin
      If qPopulation.Active
      Then Locate_ID := qPopulation.FieldByName('ID').AsInteger
      Else Locate_ID := -1;

      qPopulation.Close;

      qPopulation.SQL[qPopulation.SQL.Count - 9] := ''; // Село
      qPopulation.SQL[qPopulation.SQL.Count - 8] := ''; // Стать
      qPopulation.SQL[qPopulation.SQL.Count - 7] := ''; // Живі або неживі
      qPopulation.SQL[qPopulation.SQL.Count - 6] := ''; // Неповнолітні
      qPopulation.SQL[qPopulation.SQL.Count - 5] := ''; // Без господарства
      qPopulation.SQL[qPopulation.SQL.Count - 4] := ''; //
      qPopulation.SQL[qPopulation.SQL.Count - 3] := ''; //
      qPopulation.SQL[qPopulation.SQL.Count - 2] := ''; // Пошук

      If lcbLocation.KeyValue >= 0 Then
      Begin
        qPopulation.SQL[qPopulation.SQL.Count - 9] := '  and (q.ID_SELO = :prm_Selo)';

        qPopulation.ParamByName('prm_Selo').AsString := lcbLocation.KeyValue;
      End;

      tS := '';
      tA := '';

      if chkMale.Checked     then tS := tS + ' or (q.STAT = 0)';
      if chkFemale.Checked   then tS := tS + ' or (q.STAT = 1)';
      if chkAlive.Checked    then tA := tA + ' or (q.DATA_SMERTI is     null)';
      if chkLifeless.Checked then tA := tA + ' or (q.DATA_SMERTI is not null)';

      qPopulation.SQL[qPopulation.SQL.Count - 8] := '  and ((1 = 0)' + tS + ')';
      qPopulation.SQL[qPopulation.SQL.Count - 7] := '  and ((1 = 0)' + tA + ')';

      if chkUnderaged.Checked then qPopulation.SQL[qPopulation.SQL.Count - 6] := '  and (q.AGE < 18)';
      if chkHomeless.Checked  then qPopulation.SQL[qPopulation.SQL.Count - 5] := '  and (q.ID_HOSPODARSTVO is null)';

      If FullStr(edtSearch.Text) Then
      Begin
        tS := '''%' + StringReplace(edtSearch.Text, '''', '''''', [rfReplaceAll]) + '%''';

        qPopulation.SQL[qPopulation.SQL.Count - 2] := '  and ((q.FULLNAME            like ' + tS + ') or ' +
                                                             '(q.VILLAGE             like ' + tS + ') or ' +
                                                             '(q.ADRESA              like ' + tS + ') or ' +
                                                             '(q.ADRESA_HOSPODARSTVA like ' + tS + ') or ' +
                                                             '(q.PASSPORT            like ' + tS + ') or ' +
                                                             '(q.IPN                 like ' + tS + ') or ' +
                                                             '(q.YEDDR_NOMER         like ' + tS + ') or ' +
                                                             '(q.NOMER_TELEFONU      like ' + tS + ') or ' +
                                                             '(q.PRYMITKY            like ' + tS + '))';
      End;

      qPopulation.Open;
      qPopulation.First;

      qPopulation.Locate('ID', Locate_ID, []);
    End
    else
    if pcInfo.ActivePage = tsHouse then
    begin
      If qHouse.Active
      Then Locate_ID := qHouse.FieldByName('ID').AsInteger
      Else Locate_ID := -1;

      qHouse.Close;

      qHouse.SQL[qHouse.SQL.Count - 5] := ''; // Село
      qHouse.SQL[qHouse.SQL.Count - 4] := ''; //
      qHouse.SQL[qHouse.SQL.Count - 3] := ''; // Господарство без жителів
      qHouse.SQL[qHouse.SQL.Count - 2] := ''; // Пошук

      If lcbLocation.KeyValue >= 0 Then
      Begin
        qHouse.SQL[qHouse.SQL.Count - 5] := '  and (q.ID_SELO = :prm_Selo)';

        qHouse.ParamByName('prm_Selo').AsString := lcbLocation.KeyValue;
      End;

      if chkWithout_Inhabitant.Checked then qHouse.SQL[qHouse.SQL.Count - 3] := '  and (q.INHABITANTS_COUNT      = 0)';

      If FullStr(edtSearch.Text) Then
      Begin
        tS := '''%' + StringReplace(edtSearch.Text, '''', '''''', [rfReplaceAll]) + '%''';

        qHouse.SQL[qHouse.SQL.Count - 2] := '  and ((q.NAZVA  like ' + tS + ') or ' +
                                                   '(q.ADRESA like ' + tS + '))';
      End;

      qHouse.Open;
      qHouse.First;

      qHouse.Locate('ID', Locate_ID, []);
    End
    else
    if pcInfo.ActivePage = tsLandOwners then
    begin
      If qLandOwners.Active
      Then Locate_ID := qLandOwners.FieldByName('ID').AsInteger
      Else Locate_ID := -1;

      qLandOwners.Close;

      qLandOwners.SQL[qLandOwners.SQL.Count - 3] := ''; // Село
      qLandOwners.SQL[qLandOwners.SQL.Count - 2] := ''; // Пошук

      If lcbLocation.KeyValue >= 0 Then
      Begin
        qLandOwners.SQL[qLandOwners.SQL.Count - 3] := '  and (q.ID_SELO = :prm_Selo)';

        qLandOwners.ParamByName('prm_Selo').AsString := lcbLocation.KeyValue;
      End;

      If FullStr(edtSearch.Text) Then
      Begin
        tS := '''%' + StringReplace(edtSearch.Text, '''', '''''', [rfReplaceAll]) + '%''';

        qLandOwners.SQL[qLandOwners.SQL.Count - 2] := '  and ((q.FULLNAME            like ' + tS + ') or ' +
                                                             '(q.ADRESA_HOSPODARSTVA like ' + tS + ') or ' +
                                                             '(q.ADRESA              like ' + tS + '))';
      End;

      qLandOwners.Open;
      qLandOwners.First;

      qLandOwners.Locate('ID', Locate_ID, []);
    End;

    is_Change := False;

    Try
      if pcInfo.ActivePage = tsPopulation then dbgPopulation.SetFocus else
      if pcInfo.ActivePage = tsHouse      then dbgHouse.SetFocus      else
      if pcInfo.ActivePage = tsLandOwners then dbgLandOwners.SetFocus;
    Except
      //
    End;
  finally
    FreeAndNil(frmWait);
  end;
End;

Procedure TfrmMain.tmrScrollTimer(Sender : TObject);
var
  tT, tC, tA : String;
begin
  tmrScroll.Enabled := False;

  tT := '';
  tC := '';
  tA := '';

  if pmFamily_Temporarily_Absent.Checked then tT := tT + ' or (q.TYMCHASOVO_VYBUV    = 1)';
  if pmFamily_Completely_Absent.Checked  then tC := tC + ' or (q.OSTATOCHNO_VYBUV    = 1)';
  if pmFamily_Lifeless.Checked           then tA := tA + ' or (q.DATA_SMERTI is not null)';

  dm.SetGridColumnVisible(dbgFamily, 'TYMCHASOVO_VYBUV', pmFamily_Temporarily_Absent.Checked);
  dm.SetGridColumnVisible(dbgFamily, 'OSTATOCHNO_VYBUV', pmFamily_Completely_Absent.Checked);
  dm.SetGridColumnVisible(dbgFamily, 'DATA_SMERTI',      pmFamily_Lifeless.Checked);

  if pcInfo.ActivePage = tsPopulation then
  begin
    // Scroll Населення
    if not qPopulation.Active then Exit;

    qFamily.Close;

    // Щоб у нижній таблиці виводився запис про заявника
    //qFamily.SQL[qFamily.SQL.Count - 6] := '  and (q.ID_NASELENNIA  <> :prm_Person)';
    qFamily.SQL[qFamily.SQL.Count - 5] := '  and ((q.TYMCHASOVO_VYBUV = 0)' + tT + ')';
    qFamily.SQL[qFamily.SQL.Count - 4] := '  and ((q.OSTATOCHNO_VYBUV = 0)' + tC + ')';
    qFamily.SQL[qFamily.SQL.Count - 3] := '  and ((q.DATA_SMERTI  is null)' + tA + ')';
    qFamily.SQL[qFamily.SQL.Count - 2] := '';

    qFamily.ParamByName('prm_Person').Value := qPopulation.FieldByName('ID').Value;
    qFamily.ParamByName('prm_House').Value  := qPopulation.FieldByName('ID_HOSPODARSTVO').Value;
    qFamily.Open;

    if pcDetails.ActivePage = tsFamily then QueryFetchAll(qFamily);

    // Scroll Земля
    qLands.Close;
    qLands.ParamByName('prm_Person').Value := qPopulation.FieldByName('ID').Value;
    qLands.Open;

    if pcDetails.ActivePage = tsLands then QueryFetchAll(qLands);

  end
  else
  if pcInfo.ActivePage = tsHouse then
  begin
    // Scroll Господарства
    if not qHouse.Active then Exit;

    qFamily.Close;

    qFamily.SQL[qFamily.SQL.Count - 6] := '';
    qFamily.SQL[qFamily.SQL.Count - 5] := '  and ((q.TYMCHASOVO_VYBUV = 0)' + tT + ')';
    qFamily.SQL[qFamily.SQL.Count - 4] := '  and ((q.OSTATOCHNO_VYBUV = 0)' + tC + ')';
    qFamily.SQL[qFamily.SQL.Count - 3] := '  and ((q.DATA_SMERTI  is null)' + tA + ')';
    qFamily.SQL[qFamily.SQL.Count - 2] := '';

    qFamily.ParamByName('prm_Person').Value := 0;
    qFamily.ParamByName('prm_House').Value  := qHouse.FieldByName('ID').Value;
    qFamily.Open;

    if pcDetails.ActivePage = tsFamily then QueryFetchAll(qFamily);
  end
  else
  if pcInfo.ActivePage = tsLandOwners then
  begin
    if not qLandOwners.Active then Exit;

    qLands.Close;
    qLands.ParamByName('prm_Person').Value := qLandOwners.FieldByName('ID').Value;
    qLands.Open;

    if pcDetails.ActivePage = tsLands then QueryFetchAll(qLands);
  end;
end;

procedure TfrmMain.pcDetailsChange(Sender : TObject);
begin
  if pcDetails.ActivePage = tsFamily then QueryRefresh(qFamily) else
  if pcDetails.ActivePage = tsLands  then QueryRefresh(qLands);
end;

Procedure TfrmMain.qPopulationAfterOpen(DataSet : TDataSet);
Var
  is_Record : Boolean;
Begin
  is_Record := (DataSet.RecordCount > 0);

  actUpd.Enabled        := is_Record;
  actFamily_Add.Enabled := is_Record;
  actLands_Add.Enabled  := is_Record;
end;

Procedure TfrmMain.qHouseAfterOpen(DataSet : TDataSet);
var
  is_Record : Boolean;
Begin
  is_Record := (DataSet.RecordCount > 0);

  actUpd.Enabled        := is_Record;
  actFamily_Add.Enabled := is_Record;
end;

procedure TfrmMain.qLandOwnersAfterOpen(DataSet : TDataSet);
Var
  is_Record : Boolean;
Begin
  is_Record := (DataSet.RecordCount > 0);

  actLands_Add.Enabled := is_Record;
end;

Procedure TfrmMain.qFamilyAfterOpen(DataSet : TDataSet);
Var
  is_Record : Boolean;
Begin
  is_Record := (DataSet.RecordCount > 0);

  actFamily_Upd.Enabled := is_Record;
  actFamily_Del.Enabled := is_Record;
  actFamily_Del.Visible := is_Record and (pcInfo.ActivePage = tsHouse);
end;

Procedure TfrmMain.qLandsAfterOpen(DataSet : TDataSet);
var
  is_Record : Boolean;
Begin
  is_Record := (DataSet.RecordCount > 0);

  actLands_Upd.Enabled := is_Record;
  actLands_Del.Enabled := is_Record;
end;

Procedure TfrmMain.qQueryAfterScroll(DataSet : TDataSet);
Begin
  tmrScroll.Enabled := False;
  tmrScroll.Enabled := True;
End;

Procedure TfrmMain.qPopulationAfterScrollForPrint(DataSet : TDataSet);
Begin
  tmrScrollTimer(nil);
End;

Procedure TfrmMain.actPrintExecute(Sender : TObject);
Var
  PrevDir : String;
  PopulationDefaultScroll : TDataSetNotifyEvent;
Begin
  PrevDir := GetCurrentDir;

  PopulationDefaultScroll := qPopulation.AfterScroll;
  qPopulation.AfterScroll := @qPopulationAfterScrollForPrint;

  Try
    qPopulation.DisableControls;

    dm.OpenDialogPrint.InitialDir := ApplicationPath + 'Template\';

    If pcInfo.ActivePage = tsPopulation Then dm.OpenDialogPrint.FileName := '[Населення] Довідка*.lrf'    else
    If pcInfo.ActivePage = tsHouse      Then dm.OpenDialogPrint.FileName := '[Господарства] Довідка*.lrf' else Exit;

    If not dm.OpenDialogPrint.Execute Then Exit;

    frVariables['p_Selo']   := lcbLocation.Text;
    frVariables['p_Search'] := edtSearch.Text;

    dm.frReport.LoadFromFile(dm.OpenDialogPrint.FileName);

    If pcInfo.ActivePage = tsPopulation Then dm.frReport.Dataset := frDSPopulation else
    If pcInfo.ActivePage = tsHouse      Then dm.frReport.Dataset := frDSHouse;

    If Sender = pmDesign
    Then dm.frReport.DesignReport
    Else dm.frReport.ShowReport;
  Finally
    qPopulation.AfterScroll := PopulationDefaultScroll;

    SetCurrentDir(PrevDir);

    qPopulation.EnableControls;

    tmrScrollTimer(nil);
  End;
End;

Procedure TfrmMain.actAddUpdExecute(Sender : TObject);
Var
  ID : Integer;
  DataChanged : Boolean;
Begin
  DataChanged := False;

  if pcInfo.ActivePage = tsPopulation then
  begin
    If Sender = actAdd Then ID := -1                                      Else
    If Sender = actUpd Then ID := qPopulation.FieldByName('ID').AsInteger Else Exit;

    with TfrmPopulation_Edit.CreatePerson(Self, -1, ID, DataChanged) Do
    Begin
      ShowModal;
      Free;
    End;

    If DataChanged Then
    Begin
      qPopulation.Close;
      qPopulation.Open;
      qPopulation.Last;
      qPopulation.First;
      qPopulation.Locate('ID', ID, []);
    End;
  end
  else
  if pcInfo.ActivePage = tsHouse then
  begin
    If Sender = actAdd Then ID := -1                                 Else
    If Sender = actUpd Then ID := qHouse.FieldByName('ID').AsInteger Else Exit;

    with TfrmHouse_Edit.CreateInt(Self, ID, DataChanged) Do
    Begin
      ShowModal;
      Free;
    End;

    If DataChanged Then
    Begin
      qHouse.Close;
      qHouse.Open;
      qHouse.Last;
      qHouse.First;
      qHouse.Locate('ID', ID, []);
    End;
  end
  else Exit;
End;

procedure TfrmMain.actDelExecute(Sender : TObject);
begin
  //
end;

procedure TfrmMain.actExportExecute(Sender : TObject);
var
  i : Word;
  iGrid : TDBGrid;
  iColumn : TColumn;
  Exporter : TFPSExport;
  FormatSettings : TFPSExportFormatSettings;
begin
  dlgSave.FileName:= pcInfo.ActivePage.Caption;

  If not dlgSave.Execute then exit;

  if pcInfo.ActivePage = tsPopulation then qPopulation.First else
  if pcInfo.ActivePage = tsHouse      then qHouse.First;

  Exporter       := TFPSExport.Create(nil);
  FormatSettings := TFPSExportFormatSettings.Create(true);

  try
    // Write header row with field names
    FormatSettings.HeaderRow    := True;
    FormatSettings.ExportFormat := efXLS;

    // Actually apply settings
    Exporter.FormatSettings := FormatSettings;

    // Write
    if pcInfo.ActivePage = tsPopulation then
    begin
      Exporter.Dataset := qPopulation;
      iGrid            := dbgPopulation;
    end
    else
    if pcInfo.ActivePage = tsHouse then
    begin
      Exporter.Dataset := qHouse;
      iGrid            := dbgHouse;
    end
    else
    if pcInfo.ActivePage = tsLandOwners then
    begin
      Exporter.Dataset := qLandOwners;
      iGrid            := dbgLandOwners;
    end;

    Exporter.FileName := dlgSave.FileName;

    Exporter.ExportFields.Clear;

    for i := 0 to iGrid.Columns.Count - 1 do
    begin
      if iGrid.Columns[i].Tag >= 0 then
      begin
        with Exporter.ExportFields do
        begin
          iColumn := iGrid.Columns[i];

          AddField(iColumn.FieldName);

          Fields[IndexOfField(iColumn.FieldName)].ExportedName := iColumn.Title.Caption;
        end;
      end;
    end;

    Exporter.Execute;

    Application.MessageBox('Експорт завершено!',
                            PChar(Caption),
                            MB_OK + MB_ICONINFORMATION);
  finally
    FormatSettings.Free;
    Exporter.Free;
  end;
end;

Procedure TfrmMain.actFamilyAddUpdExecute(Sender : TObject);
var
  House_ID, Inhabitant_ID, Relationship_ID, Person_ID, Declarant_ID : Integer;
  DataChanged : Boolean;
Begin
  House_ID := 0;

  if pcInfo.ActivePage = tsPopulation then House_ID := qPopulation.FieldByName('ID_HOSPODARSTVO').AsInteger else
  if pcInfo.ActivePage = tsHouse      then House_ID := qHouse.FieldByName('ID').AsInteger;

  If House_ID = 0 then
  begin
    Application.MessageBox('Обрано особу без господарства!',
                            PChar(Caption),
                            MB_OK + MB_ICONWARNING);

    Exit;
  End;

  If Sender = actFamily_Add Then
  begin
    Inhabitant_ID   := -1;
    Relationship_ID := -1;

    DataChanged := False;

    with TfrmPopulation.SelectPerson(Self, House_ID, DataChanged) Do
    begin
      Select := TSelect.Create();

      ShowModal;

      if Select.Success
      then Person_ID := Select.Code
      else Person_ID := -1;

      Free;
    End;

    Declarant_ID := qPopulation.FieldByName('ID').AsInteger;

    if Person_ID < 0 then
    begin
      Application.MessageBox('Не обрано особу!',
                              PChar(Caption),
                              MB_OK + MB_ICONWARNING);

      Exit;
    end;
  end
  Else
  If Sender = actFamily_Upd Then
  begin
    Inhabitant_ID := qFamily.FieldByName('MESHKANTSI_ID').AsInteger;

    if qFamily.FieldByName('SPORIDNENIST_ID').IsNull
    then Relationship_ID := -1
    else Relationship_ID := qFamily.FieldByName('SPORIDNENIST_ID').AsInteger;

    Person_ID    := qFamily.FieldByName('ID').AsInteger;
    Declarant_ID := qPopulation.FieldByName('ID').AsInteger;
  end
  Else Exit;

  DataChanged := False;

  if pcInfo.ActivePage = tsPopulation then
  begin
    if Declarant_ID = Inhabitant_ID then
    begin
      Application.MessageBox('Корекція відносин заявника з самим собою' + LineEnding +
                             'не передбачена!',
                              PChar(Caption),
                              MB_OK + MB_ICONWARNING);

      Relationship_ID := -1;

      with TfrmInhabitant_Edit.CreateFromHouseTab(Self, House_ID,
                                                        Person_ID,
                                                        Relationship_ID,
                                                        Inhabitant_ID,
                                                        DataChanged)
      Do
      begin
        ShowModal;
        Free;
      End;
    end
    else
    begin
      with TfrmInhabitant_Edit.CreateFromPopulationTab(Self, House_ID,
                                                             Person_ID,
                                                             Declarant_ID,
                                                             Relationship_ID,
                                                             Inhabitant_ID,
                                                             DataChanged)
      Do
      begin
        ShowModal;
        Free;
      End;
    end;
  end
  else
  if pcInfo.ActivePage = tsHouse then
  begin
    Relationship_ID := -1;

    with TfrmInhabitant_Edit.CreateFromHouseTab(Self, House_ID,
                                                      Person_ID,
                                                      Relationship_ID,
                                                      Inhabitant_ID,
                                                      DataChanged)
    Do
    begin
      ShowModal;
      Free;
    End;
  end;

  if DataChanged then
  begin
    if pcInfo.ActivePage = tsPopulation then
    begin
      QueryRefresh(qPopulation);
    end;

    QueryRefresh(qFamily);

    qFamily.Locate('MESHKANTSI_ID', Inhabitant_ID, []);
  End;
End;

Procedure TfrmMain.actFamily_DelExecute(Sender : TObject);
var
  House_Name, Person_Name : String;
Begin
  if pcInfo.ActivePage = tsPopulation then
  begin
    House_Name := qPopulation.FieldByName('ADRESA').AsString  + ' (' +
                  qPopulation.FieldByName('VILLAGE').AsString + ')';
  end
  else
  if pcInfo.ActivePage = tsHouse then
  begin
    House_Name := qHouse.FieldByName('ADRESA').AsString       + ' (' +
                  qHouse.FieldByName('NAZVA').AsString        + ')';
  end;

  Person_Name := qFamily.FieldByName('FULLNAME').AsString;

  if Application.MessageBox(PChar('Видалити з господарства ' + LineEnding +
                                  ' > ' + House_Name         + LineEnding +
                                  'наступну особу: '         + LineEnding +
                                  ' > ' + Person_Name + '?'),
                            PChar(Caption),
                            MB_YESNO + MB_ICONQUESTION) = IDNO
  then Exit;

  if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

  try
    sqlQuery.SQL.Text := 'delete from SPORIDNENIST '                     + #13#10 +
                         'where ( ID_HOSPODARSTVO    = :prm_House)     ' + #13#10 +
                         '  and ((ID_NASELENNIA_KHTO = :prm_Person) or ' + #13#10 +
                         '       (ID_NASELENNIA_KOMU = :prm_Person))';

    sqlQuery.ParamByName('prm_House').AsInteger  := qFamily.FieldByName('ID_HOSPODARSTVO').AsInteger;
    sqlQuery.ParamByName('prm_Person').AsInteger := qFamily.FieldByName('ID_NASELENNIA').AsInteger;

    sqlQuery.ExecSQL;

    sqlQuery.SQL.Text := 'delete from MESHKANTSI ' + #13#10 +
                         'where (ID = :prm_ID)';

    sqlQuery.ParamByName('prm_ID').AsInteger := qFamily.FieldByName('MESHKANTSI_ID').AsInteger;

    sqlQuery.ExecSQL;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    QueryRefresh(qFamily, True);
  except
    on E: EDatabaseError do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Операцію скасовано!'       + LineEnding +
                                                                 LineEnding +
                                   'Виникла наступна помилка:' + LineEnding +
                                                                 LineEnding +
                                    E.Message                  + LineEnding +
                                                                 LineEnding +
                                   'Модуль: ' + E.ClassName),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
      Exit;
    end;
    on E : Exception do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Модуль: ' + E.ClassName    + LineEnding +
                                                                 LineEnding +
                                   'Виникла наступна помилка:' + LineEnding +
                                    E.Message                  + LineEnding +
                                                                 LineEnding +
                                   'Зміни не збережено! '      + LineEnding +
                                   'Закрийте вікно і повторіть спробу.'),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
      Exit;
    end;
  end;
End;

procedure TfrmMain.actFamily_Upd_PersonExecute(Sender : TObject);
Var
  ID : Integer;
  DataChanged : Boolean;
Begin
  DataChanged := False;

  ID := qFamily.FieldByName('ID_NASELENNIA').AsInteger;

  with TfrmPopulation_Edit.CreatePerson(Self, -1, ID, DataChanged) Do
  Begin
    ShowModal;
    Free;
  End;

  If DataChanged Then
  Begin
    qFamily.Close;
    qFamily.Open;
    qFamily.Last;
    qFamily.First;
    qFamily.Locate('ID_NASELENNIA', ID, []);
  End;
end;

Procedure TfrmMain.actLandsAddUpdExecute(Sender : TObject);
Var
  ID_Person,            // ID власника землі
  ID_Lands : Integer;   // ID земельної ділянки
  DataChanged : Boolean;
Begin
  DataChanged := False;

  if pcInfo.ActivePage = tsPopulation then ID_Person := qPopulation.FieldByName('ID').AsInteger else
  if pcInfo.ActivePage = tsLandOwners then ID_Person := qLandOwners.FieldByName('ID').AsInteger else Exit;

  If Sender = actLands_Add Then ID_Lands  := -1                                 Else
  If Sender = actLands_Upd Then ID_Lands  := qLands.FieldByName('ID').AsInteger Else Exit;

  with TfrmLands_Edit.CreateLands(Self, ID_Person, ID_Lands, DataChanged) Do
  Begin
    ShowModal;
    Free;
  End;

  If DataChanged Then
  Begin

    if pcInfo.ActivePage = tsLandOwners then
    begin
      QueryRefresh(qLandOwners);
    end;

    QueryRefresh(qLands, True);

    qLands.Locate('ID', ID_Person, []);
  End;
end;

Procedure TfrmMain.actLands_DelExecute(Sender : TObject);
var
  Person_Name : String;
Begin
  Person_Name := qPopulation.FieldByName('FULLNAME').AsString;

  if Application.MessageBox(PChar('Видалити інформацію про земельну ділянку ' + LineEnding +
                                  'наступної особи: '                         + LineEnding +
                                  ' > ' + Person_Name + '?'),
                            PChar(Caption),
                            MB_YESNO + MB_ICONQUESTION) = IDNO
  then Exit;

  if not dm.SaveTransaction.Active then dm.SaveTransaction.StartTransaction;

  try
    sqlQuery.SQL := qLands.DeleteSQL;

    sqlQuery.ParamByName('prm_ID').AsInteger := qLands.FieldByName('ID').AsInteger;

    sqlQuery.ExecSQL;

    if dm.SaveTransaction.Active then dm.SaveTransaction.CommitRetaining;

    QueryRefresh(qLands, True);
  except
    on E: EDatabaseError do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Операцію скасовано!'       + LineEnding +
                                                                 LineEnding +
                                   'Виникла наступна помилка:' + LineEnding +
                                                                 LineEnding +
                                    E.Message                  + LineEnding +
                                                                 LineEnding +
                                   'Модуль: ' + E.ClassName),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
      Exit;
    end;
    on E : Exception do
    begin
      if dm.SaveTransaction.Active then dm.SaveTransaction.RollbackRetaining;

      Application.MessageBox(PChar('Модуль: ' + E.ClassName    + LineEnding +
                                                                 LineEnding +
                                   'Виникла наступна помилка:' + LineEnding +
                                    E.Message                  + LineEnding +
                                                                 LineEnding +
                                   'Зміни не збережено! '      + LineEnding +
                                   'Закрийте вікно і повторіть спробу.'),
                             PChar(Caption),
                             MB_OK + MB_ICONSTOP);
      Exit;
    end;
  end;
end;

Procedure TfrmMain.actSetCurrentHouseExecute(Sender: TObject);
begin
  if qPopulation.FieldByName('ID_SELO').AsInteger > 0
  then lcbLocation.KeyValue :=  qPopulation.FieldByName('ID_SELO').AsInteger
  else lcbLocation.KeyValue := -1;

  edtSearch.Text := qPopulation.FieldByName('ADRESA_HOSPODARSTVA').AsString;

  pcInfo.ActivePage := tsHouse;

  OnFilterChange(pcInfo);
end;

procedure TfrmMain.actSetCurrentPersonExecute(Sender : TObject);
begin
  if qPopulation.FieldByName('ID_SELO').AsInteger > 0
  then lcbLocation.KeyValue :=  qPopulation.FieldByName('ID_SELO').AsInteger
  else lcbLocation.KeyValue := -1;

  edtSearch.Text := qFamily.FieldByName('FULLNAME').AsString;

  pcInfo.ActivePage := tsPopulation;

  OnFilterChange(pcInfo);
end;

End.

