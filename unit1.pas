unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, StrUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls, Menus, Process, Registry, ShlObj, ActiveX, ComObj, LCLIntf, LCLType, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    CloseImg: TImage;
    img: TImage;
    img1: TImage;
    l11: TLabel;
    l12: TLabel;
    l14: TLabel;
    item7: TMenuItem;
    item6: TMenuItem;
    item5: TMenuItem;
    item4: TMenuItem;
    item3: TMenuItem;
    item2: TMenuItem;
    item1: TMenuItem;
    listbox: TListBox;
    popMenu: TPopupMenu;
    Timer1: TTimer;

    procedure b1Click(Sender: TObject);
    procedure b3Click(Sender: TObject);
    procedure b4Click(Sender: TObject);
    procedure b2Click(Sender: TObject);
    procedure CloseImgClick(Sender: TObject);
    procedure CloseImgMouseEnter(Sender: TObject);
    procedure CloseImgMouseLeave(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; FileNames: array of String);
    procedure imgClick(Sender: TObject);
    procedure item1Click(Sender: TObject);
    procedure item2Click(Sender: TObject);
    procedure l11Click(Sender: TObject);
    procedure l11MouseEnter(Sender: TObject);
    procedure l11MouseLeave(Sender: TObject);
    procedure l12Click(Sender: TObject);
    procedure l12MouseEnter(Sender: TObject);
    procedure l12MouseLeave(Sender: TObject);
    procedure listboxClick(Sender: TObject);
    procedure listboxDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure listboxMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure listboxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure item7Click(Sender: TObject);
    procedure item6Click(Sender: TObject);
    procedure item5Click(Sender: TObject);
    procedure item4Click(Sender: TObject);
    procedure item3Click(Sender: TObject);
    procedure popMenuPopup(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    { private declarations }
  public
    Procedure PaintImage(myListbox :TListBox; Control: TWinControl; Index: Integer; Rect: TRect);
  end;


type  TChangeWindowMessageFilter = function(msg:Cardinal; Action:Dword):BOOL; stdcall;

var
  Form1 :TForm1;
  i,x,j :Integer;
  User,Selected :String;
  cmd :Tprocess;
  reg :Tregistry;
  P :Tpoint;
  ListBoxWidth, pos :Integer;
  filepathsList :TstringList;
  flag :Boolean;

  User32Module :THandle;
  ChangeWindowMessageFilterPtr :Pointer;

implementation

       uses unit2,unit3;

{$R *.lfm}

{ TForm1 }


procedure SetListBoxWidth(); //overload;  "SetListBoxWidth(variable);"
begin
    ListBoxWidth:=0;
    for i:=0 to Form1.listbox.Items.Count -1 do
    begin
        if (ListBoxWidth < Form1.listbox.Canvas.TextWidth(Form1.listbox.Items[i])) then
          ListBoxWidth:=Form1.listbox.Canvas.TextWidth(Form1.listbox.Items[i]) ;
    end;

    SendMessage(Form1.listbox.Handle, LB_SETHORIZONTALEXTENT, ListBoxWidth + 10, 0);
end;

procedure TForm1.b1Click(Sender: TObject);  // Make Inaccesible
begin
    if (listbox.ItemIndex = -1) or (listbox.SelCount = 0) then
      Exit;

    try
      cmd:= TProcess.Create(nil);
      reg:= TRegistry.Create;
      reg.RootKey:= HKEY_CURRENT_USER;
    try
    for i:= 0 to listbox.Count -1 do
    begin
        if listbox.Selected[i] then
        begin
          cmd.ShowWindow:= swoHide;
          cmd.CommandLine:= 'cmd.exe /c  cacls ' + '"' + Utf8Decode(filepathsList.Strings[i]) + '" ' + '/e /d ' + User;
          cmd.Execute;

          reg.OpenKey('AVSM',true);
          reg.WriteString(Utf8Decode(filepathsList.Strings[i]),'locked');
          reg.CloseKey;

          listbox.Items.Add('🔒  ' + filepathsList.Strings[i]);
          listbox.Items.Exchange(i,listbox.Count -1);
          listbox.Items.Delete(listbox.Count -1);
        end;
    end;
    except on E: exception do ShowMessage(E.Message);
    end;
    finally
        cmd.Free;
        reg.Free;
    end;
end;

procedure TForm1.b3Click(Sender: TObject);  // Make Accessible
begin
    if (listbox.ItemIndex = -1) or (listbox.SelCount = 0) then
      Exit;

    try
      cmd:= TProcess.Create(nil);
      reg:= TRegistry.Create;
      reg.RootKey:= HKEY_CURRENT_USER;
    try
    for i:= 0 to listbox.Count -1 do
    begin
        if listbox.Selected[i] then
        begin
          cmd.ShowWindow:= swoHide;
          cmd.CommandLine:= 'cmd.exe /c  cacls ' + '"' + Utf8Decode(filepathsList.Strings[i]) + '" ' + '/e /g ' + User + ':f';
          cmd.Execute;

          reg.OpenKey('AVSM',true);
          reg.DeleteValue(filepathsList.Strings[i]);
          reg.CloseKey;

          listbox.Items.Add('▪ ' + filepathsList.Strings[i]);
          listbox.Items.Exchange(i,listbox.Count -1);
          listbox.Items.Delete(listbox.Count -1);
        end;
    end;
    except on E: exception do ShowMessage(E.Message);
    end;
    finally
        cmd.Free;
        reg.Free;
    end;
end;

procedure TForm1.b4Click(Sender: TObject);  // Make Visible
begin
     if (listbox.ItemIndex = -1) or (listbox.SelCount = 0) then
      Exit;

     try
      cmd:= TProcess.Create(nil);
      reg:= TRegistry.Create;
      reg.RootKey:= HKEY_CURRENT_USER;
     try
     for i:= 0 to listbox.Count -1 do
     begin
        if listbox.Selected[i] then
        begin
          if AnsiContainsText(listbox.Items.ValueFromIndex[i], '🔒 ') then
          begin
             ShowMessage('Τα ΜΗ προσβασιμα αρχεια\φακελοι δεν μπορουν να γινουν Ορατα\Αορατα');
             Continue;
          end;

          cmd.ShowWindow:= swoHide;
          cmd.CommandLine:= 'cmd.exe /c  attrib -h -s ' + '"' + Utf8Decode(filepathsList.Strings[i]) + '"';
          cmd.Execute;

          reg.OpenKey('AVSM',true);
          reg.DeleteValue(filepathsList.Strings[i]);
          reg.CloseKey;

          listbox.Items.Add('▪ ' + filepathsList.Strings[i]);
          listbox.Items.Exchange(i,listbox.Count -1);
          listbox.Items.Delete(listbox.Count -1);
        end;
     end;
     except on E: exception do ShowMessage(E.Message);
     end;
     finally
        cmd.Free;
        reg.Free;
     end;
end;

procedure TForm1.b2Click(Sender: TObject);  // Make Invisible
begin
    if (listbox.ItemIndex = -1) or (listbox.SelCount = 0) then
      Exit;

    try
      cmd:= TProcess.Create(nil);
      reg:= TRegistry.Create;
      reg.RootKey:= HKEY_CURRENT_USER;
     try
     for i:= 0 to listbox.Count -1 do
     begin
        if listbox.Selected[i] then
        begin
          if AnsiContainsText(listbox.Items.ValueFromIndex[i], '🔒 ') then
          begin
             ShowMessage('Τα ΜΗ προσβασιμα αρχεια\φακελοι δεν μπορουν να γινουν Ορατα\Αορατα');
             Continue;
          end;

          cmd.ShowWindow:= swoHide;
          cmd.CommandLine:= 'cmd.exe /c  attrib +h +s ' + '"' + Utf8Decode(filepathsList.Strings[i]) + '"';
          cmd.Execute;

          reg.OpenKey('AVSM',true);
          reg.WriteString(Utf8Decode(filepathsList.Strings[i]),'invisible');
          reg.CloseKey;

          listbox.Items.Add('😁  ' + filepathsList.Strings[i]);
          listbox.Items.Exchange(i,listbox.Count -1);
          listbox.Items.Delete(listbox.Count -1);
        end;
     end;
     except on E: exception do ShowMessage(E.Message);
     end;
     finally
        cmd.Free;
        reg.Free;
     end;
end;

function GetPathFromShortcut(const path :String):String;
var
  link: IShellLink;
  storage: IPersistFile;
  filedata: TWin32FindData;
  buf: Array[0..MAX_PATH] of Char;
  widepath: WideString;
begin
  OleCheck( CoCreateInstance( CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,IShellLink, link ));
  OleCheck( link.QueryInterface( IPersistFile, storage ));
  widepath:= path;
  Result:= '';

  If Succeeded( storage.Load( @widepath[1], STGM_READ )) Then
    If Succeeded( link.Resolve( GetActiveWindow, SLR_NOUPDATE )) Then
      If Succeeded(link.GetPath( buf, sizeof(buf), filedata, SLGP_UNCPRIORITY)) then
        Result:= buf;

  storage:= nil;
  link:= nil;
end;

procedure TForm1.FormDropFiles(Sender: TObject; FileNames: array of String);
var Duplicated :Boolean;
    i,j,maxValue,tempValue :integer;
begin
   try
    Form1.FormStyle:= fsStayOnTop;
    GetCursorPos(P);

    if FindDragTarget(P,True) = listbox then
    begin
       for i:= Low(Filenames) to High(Filenames) do
       begin
         if length(Filenames[i]) <= 3 then
           showMessage('Μονο αρχεια και φακελοι επιτρεπονται')
         else
         begin
             Duplicated:= false;

             if LowerCase(ExtractFileExt(Filenames[i])) = '.lnk' then
                 Filenames[i]:= GetPathFromShortcut(Filenames[i]);

             for j:= 0 to listbox.Count -1 do
             begin
               if listbox.Items.Strings[j] = '▪ ' + Filenames[i] then
                Duplicated:= true;
             end;

             if not Duplicated then
             begin
                 listbox.Items.Add('▪ ' + Filenames[i]);
                 filepathsList.Add(Filenames[i]);
             end;
         end;
       end;

       if Listbox.Count > 1 then
       begin
          maxValue:= ListBox.Items.Strings[ListBox.Count -1].Length;
          j:= ListBox.Count -2;

          while true do
          begin
              maxValue:= Max(maxValue, ListBox.Items.Strings[j].Length);
              Dec(j);
              if j= -1 then
                break;
          end;

          Listbox.ScrollWidth:= maxValue *8;
       end
       else
         Listbox.ScrollWidth:= ListBox.Items.Strings[0].Length *8;
    end;


    {if (e1.canvas.textwidth(e1.caption) > 530) then
    begin
        e1.Caption:= Copy(path,1,Round(length(path)/2)) + #13#10 + Copy(path,Round(length(path)/2)+1,length(path));
    end;}


   finally
      Form1.FormStyle:= fsNormal;
      listbox.ItemIndex:= -1;
   end;
end;

procedure TForm1.l11Click(Sender: TObject);
begin
    try
       Form3:= TForm3.Create(self);
       Form3.Visible:= false;
       Form3.ShowModal;
    finally
       Form3.Free;
    end;
end;

procedure TForm1.l11MouseEnter(Sender: TObject);
begin
    l11.Font.Color:= clLime;
end;

procedure TForm1.l12MouseEnter(Sender: TObject);
begin
    l12.Font.Color:= clLime;
end;

procedure TForm1.l11MouseLeave(Sender: TObject);
begin
    l11.Font.Color:= clWhite;
end;

procedure TForm1.l12MouseLeave(Sender: TObject);
begin
    l12.Font.Color:= clWhite;
end;

procedure TForm1.listboxClick(Sender: TObject);
begin
   ////
end;

Procedure TForm1.PaintImage(myListbox :TListBox; Control: TWinControl; Index: Integer; Rect: TRect);
var BMPRect: TRect;
begin
  with (Control as TListBox).Canvas do
  begin
    FillRect(Rect);
    listbox.Canvas.Draw(0, Rect.Top, popMenu.Items[0].Bitmap);  //.Picture.Graphic);
    BMPRect:= Bounds(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
    TextOut(Rect.Left + Rect.Right, Rect.Top + Rect.Bottom, '  ' + listbox.Items[index]);
  end;
end;

procedure TForm1.listboxDrawItem(Control: TWinControl; Index: Integer;ARect: TRect; State: TOwnerDrawState);
begin
   //PaintImage(listbox, Control, 0, Rect(10,20,12,12));
end;

function GetMousePosition():TPoint;
var
  point: TPoint;
begin
  //point.x:= Form1.b3.Left;
  //point.y:= Form1.b3.Top + Form1.b3.Height;
  result:= Form1.ClientToScreen(point);

  //PopupMenu1.PopUp(pt2.x, pt2.y);
end;

Procedure SelectItemsByMouseMovement();
var
   Pointer :TPoint;
   i,j :Integer;
   ValuesArray :Array of Integer;
   //mouseX,mouseY :Word;
   //Win :HWND;
   //Rect :TRect;
begin
     //mouseX:= 0;
     //mouseY:= 0;
     //Win:=GetForegroundWindow;
     //mouseX:= Rect.Left + 100;
     //mouseY:= Rect.Top + 90;
     //Win:= GetActiveWindow;
     //GetWindowRect(Win,Rect);
     //SetCursorPos(mouseX,mouseY);

     //Form1.Timer2.Enabled:= false;
     GetCursorPos(Pointer);
     Pointer:= Form1.ScreenToClient(Pointer);
     //showMessage(IntToStr(Pointer.y));


     if Pointer.y in [56..74] then
     begin
         Form1.listbox.Selected[0]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[0] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [75..93] then
     begin
         Form1.listbox.Selected[1]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[1] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [94..112] then
     begin
         Form1.listbox.Selected[2]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[2] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [113..131] then
     begin
         Form1.listbox.Selected[3]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[3] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [132..150] then
     begin
         Form1.listbox.Selected[4]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[4] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [151..169] then
     begin
         Form1.listbox.Selected[5]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[5] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [170..188] then
     begin
         Form1.listbox.Selected[6]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[6] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [189..207] then
     begin
         Form1.listbox.Selected[7]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[7] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [208..226] then
     begin
         Form1.listbox.Selected[8]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[8] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [225..243] then
     begin
         Form1.listbox.Selected[9]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[9] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end
     else
     if Pointer.y in [244..262] then
     begin
         Form1.listbox.Selected[10]:= true;
         for j:=0 to Form1.listbox.Count -1 do
         begin
            if Form1.listbox.Items.Strings[10] <> Form1.listbox.Items.Strings[j] then
              Form1.listbox.Selected[j]:= false;
         end;
     end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   SelectItemsByMouseMovement();
end;

procedure TForm1.listboxMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
begin
   if (Button = mbLeft) and (listbox.Items.Capacity < 2) then
   begin
      ReleaseCapture;
      SendMessage(Handle, WM_SYSCOMMAND, 61458, 0);  // move form
   end;

   if (button = mbRight) and (listbox.SelCount <= 1) then
   begin
       mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
       mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
   end;
end;

procedure TForm1.listboxMouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
begin
   if (Button = mbRight) and (listbox.SelCount > 0) then
     popMenu.PopUp;

   //PostMessage(Handle, WM_LBUTTONDOWN , 0, 0);
   //PostMessage(Handle, WM_LBUTTONUP , 0, 0);
   //SendMessage(listbox.Handle,BM_Click,0,0);
end;

procedure TForm1.item7Click(Sender: TObject); // Delete Items from Listbox
var maxValue, i,j :Integer;
begin
   for i:= listbox.Count -1 downto 0 do
   begin
      if listbox.Selected[i] then
        filepathsList.Delete(i);
   end;

   listbox.DeleteSelected;

   if Listbox.Count = 1 then
     Listbox.ScrollWidth:= ListBox.Items.Strings[0].Length *8

   else if Listbox.Count > 1 then
   begin
       maxValue:= ListBox.Items.Strings[ListBox.Count -1].Length;
       j:= ListBox.Count -2;

       while true do
       begin
           maxValue:= Max(maxValue, ListBox.Items.Strings[j].Length);
           Dec(j);
           if j= -1 then
             break;
       end;

       Listbox.ScrollWidth:= maxValue *8;
   end
   else
     Listbox.ScrollWidth:= 0;

   listbox.ItemIndex:= -1;
end;

procedure TForm1.item6Click(Sender: TObject);
begin
   b4Click(Sender);
   listbox.ItemIndex:= -1;
end;

procedure TForm1.item5Click(Sender: TObject);
begin
   b3Click(Sender);
   listbox.ItemIndex:= -1;
end;

procedure TForm1.item4Click(Sender: TObject);
begin
   b2Click(Sender);
   listbox.ItemIndex:= -1;
end;

procedure TForm1.item3Click(Sender: TObject);
begin
    b1Click(Sender);
    listbox.ItemIndex:= -1;
end;

procedure TForm1.popMenuPopup(Sender: TObject);
begin
   /////
end;

procedure TForm1.l12Click(Sender: TObject);
begin
    Close;
end;

procedure TForm1.CloseImgClick(Sender: TObject);
begin
    Close;
end;

procedure TForm1.CloseImgMouseEnter(Sender: TObject);
begin
    l12.Font.Color:= clLime;
end;

procedure TForm1.CloseImgMouseLeave(Sender: TObject);
begin
    l12.Font.Color:= clWhite;
end;

procedure TForm1.FormActivate(Sender: TObject);
var ValueNames :TStringlist;
begin
    DragAcceptFiles(WindowHandle, True);

    if Activated or PassApplied then
      Exit;

    try
    reg:= TRegistry.Create(); //KEY_READ or KEY_WOW64_32KEY
    reg.RootKey:= HKEY_CURRENT_USER;
    if reg.KeyExists('AVSM') then
    begin
      try
        reg.OpenKey('AVSM',false);
        if reg.ReadString('') <> '' then
        begin
           l11.Caption:= 'Διαγραφη Κωδικου Ασφαλειας';
           Form2:= TForm2.Create(nil);
           Form2.Visible:= false;
           Form2.ShowModal;
        end;
      finally
        Form2.Free;
      end;
    end;
    finally
       reg.CloseKey;
    end;

    try
      ValueNames:= TStringlist.Create;
      if reg.KeyExists('AVSM') then
      begin
        reg.OpenKeyReadOnly('AVSM');
        reg.GetValueNames(ValueNames);

        for i:=0 to ValueNames.Count -1 do
        begin
          if reg.ReadString(ValueNames.Strings[i]) = 'locked' then
          begin
             listbox.Items.Add('🔒  ' + ValueNames.Strings[i]);
             filepathsList.Add(ValueNames.Strings[i]);
          end
          else if reg.ReadString(ValueNames.Strings[i]) = 'invisible' then
          begin
              listbox.Items.Add('😁  ' + ValueNames.Strings[i]);
              filepathsList.Add(ValueNames.Strings[i]);
          end
          else if reg.ReadString(ValueNames.Strings[i]) = 'startup' then
          begin
              listbox.Items.Add('❤️ ' + ValueNames.Strings[i]);
              filepathsList.Add(ValueNames.Strings[i]);
          end;
        end;
    end;
    finally
       reg.CloseKey;
       reg.Free;
       ValueNames.Free;
    end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    filepathsList.Free;
end;

procedure TForm1.imgClick(Sender: TObject);
begin
    ShowMessage('Τα ΜΗ προσβασιμα αρχεια\φακελοι δεν μπορουν να γινουν Ορατα\Αορατα');
end;

procedure TForm1.item1Click(Sender: TObject);  //Startup
begin
    if (listbox.ItemIndex = -1) or (listbox.SelCount = 0) then
      Exit;

    try
      reg:= TRegistry.Create;
      reg.RootKey:= HKEY_CURRENT_USER;
     try
     for i:= 0 to listbox.Count -1 do
     begin
        if listbox.Selected[i] then
        begin
          {if AnsiContainsText(listbox.Items.ValueFromIndex[i], '$') then
          begin
             ShowMessage('Τα ΜΗ προσβασιμα αρχεια\φακελοι δεν μπορουν να γινουν Ορατα\Αορατα');
             Continue;
          end;}

          reg.OpenKey('AVSM',true);
          reg.WriteString(Utf8Decode(filepathsList.Strings[i]),'startup');
          reg.CloseKey;

          reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run',true);
          reg.WriteString(ExtractFileName(Utf8Decode(filepathsList.Strings[i])),Utf8Decode(filepathsList.Strings[i]));
          reg.CloseKey;

          listbox.Items.Add('❤️ ' + filepathsList.Strings[i]);
          listbox.Items.Exchange(i,listbox.Count -1);
          listbox.Items.Delete(listbox.Count -1);
        end;
     end;
     except on E: exception do ShowMessage(E.Message);
     end;
     finally
        reg.Free;
        listbox.ItemIndex:= -1;
     end;
end;

procedure TForm1.item2Click(Sender: TObject);  // Delete Startup
begin
    if (listbox.ItemIndex = -1) or (listbox.SelCount = 0) then
      Exit;

    try
      reg:= TRegistry.Create;
      reg.RootKey:= HKEY_CURRENT_USER;
     try
     for i:= 0 to listbox.Count -1 do
     begin
        if listbox.Selected[i] then
        begin
          {if AnsiContainsText(listbox.Items.ValueFromIndex[i], '$') then
          begin
             ShowMessage('Τα ΜΗ προσβασιμα αρχεια\φακελοι δεν μπορουν να γινουν Ορατα\Αορατα');
             Continue;
          end;}

            reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run',false);
            reg.DeleteValue(ExtractFileName(Utf8Decode(filepathsList.Strings[i])));
            reg.CloseKey;

            reg.OpenKey('AVSM',false);
            if reg.ReadString(filepathsList.Strings[i]) = 'startup' then
              reg.DeleteValue(Utf8Decode(filepathsList.Strings[i]));
            reg.CloseKey;

            listbox.Items.Add('▪ ' + filepathsList.Strings[i]);
            listbox.Items.Exchange(i,listbox.Count -1);
            listbox.Items.Delete(listbox.Count -1);
        end;
     end;
     except on E: exception do ShowMessage(E.Message);
     end;
     finally
        reg.Free;
        listbox.ItemIndex:= -1;
     end;
end;

/////////// fixing DropFiles procedure with Admin Rights
function CheckUser32Module:Boolean;
begin
   if User32Module = 0 then
     User32Module:= safeLoadLibrary('USER32.DLL');

   Result:= User32Module>HINSTANCE_ERROR;
end;

function CheckUser32ModuleFunc(const Name:string; var ptr:Pointer):Boolean;
begin
 Result:= CheckUser32Module;
 if Result then
  begin
   ptr:= GetProcAddress(User32Module, PChar(Name));
   Result:= Assigned(ptr);
   if not Result then
     ptr:= Pointer(1);
  end;
end;


function ChangeWindowMessageFilter(msg:Cardinal; Action:Dword):BOOL;
begin
 if (Integer(ChangeWindowMessageFilterPtr) > 1) or
  CheckUser32ModuleFunc('ChangeWindowMessageFilter', ChangeWindowMessageFilterPtr) then
 Result:= TChangeWindowMessageFilter(ChangeWindowMessageFilterPtr)(Cardinal(msg), action)
 else
   Result:= false;
end;
//////////

procedure TForm1.FormCreate(Sender: TObject);
const
  WM_COPYGLOBALDATA = 73;
  MSGFLT_ADD = 1;
begin
    try  // fixing DropFiles procedure with Admin Rights
     DragAcceptFiles(WindowHandle, true);
     ChangeWindowMessageFilter(WM_COPYGLOBALDATA, MSGFLT_ADD);
     ChangeWindowMessageFilter(WM_DROPFILES, MSGFLT_ADD);
    except
      on E :Exception do ShowMessage(E.Message);
    end;

    Caption:= 'Accessibility\Visibility\Startup Manager v1.0/2022 bySkiller(Gogito)';
    filepathsList:= TStringList.Create;

    Application.HintColor:= clWhite;

    //for i := 0 to Screen.FormCount - 1 do   Gia polla Forms Tautoxrona
    //Screen.Forms[i].BorderIcons:= Screen.Forms[i].BorderIcons-[biMaximize]; //hides maximize button
    //EnableMenuItem(GetSystemMenu(handle,False),SC_CLOSE,MF_BYCOMMAND or MF_GRAYED);

    reg:= TRegistry.Create;
    reg.RootKey:= HKEY_CURRENT_USER;
    //reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Explorer');
    reg.OpenKeyReadOnly('Volatile Environment');
    User:= reg.ReadString('USERNAME');
    reg.CloseKey;
end;

end.
