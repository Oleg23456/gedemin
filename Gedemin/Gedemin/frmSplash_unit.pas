
unit frmSplash_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, gd_splash, StdCtrls, jpeg;

type
  TfrmSplash = class(TForm, IgdSplash)
    Timer: TTimer;
    imgGedemin: TImage;
    lblPositiveLoading: TLabel;
    imgPositive: TImage;
    lblGedeminLoading: TLabel;
    imgPositiveCash: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);

  protected
    procedure ShowSplash;
    procedure ShowText(const AText: String);
    procedure FreeSplash(const Immediately: Boolean = False);
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.DFM}

uses
  gd_GlobalParams_unit, gd_resourcestring;

{ TfrmSplash }

procedure TfrmSplash.ShowSplash;
begin
  if gdSplash <> nil then
  begin
    Show;
    Application.ProcessMessages;
  end;
end;

procedure TfrmSplash.ShowText(const AText: String);
begin
  if gdSplash <> nil then
  begin
    if lblGedeminLoading.Visible then
    begin
      lblGedeminLoading.Caption := AText + '...';
      lblGedeminLoading.Repaint;
    end else
    begin
      lblPositiveLoading.Caption := AText + '...';
      lblPositiveLoading.Repaint;
    end;
  end;
end;

procedure TfrmSplash.FormCreate(Sender: TObject);
{var
  FN: String;
  P: TPicture;}
begin
  {FN := ChangeFileExt(Application.EXEName, '.JPG');
  if FileExists(FN) then
  begin
    P := TPicture.Create;
    try
      try
        P.LoadFromFile(FN);
        if (P.Width = 439) and (P.Height = 330) then
        begin
          Image.Picture.Assign(P);
        end;
      except
      end;
    finally
      P.Free;
    end;
  end;}

  if Pos('POSITIVE_CHECK', AnsiUpperCase(gd_GlobalParams.UpdateToken)) > 0 then
  begin
    imgGedemin.Visible := False;
    lblGedeminLoading.Visible := False;
    imgPositiveCash.Visible := False;
    imgPositive.Visible := True;
    lblPositiveLoading.Visible := True;
  end
  else if Pos('POSITIVE_CASH', AnsiUpperCase(gd_GlobalParams.UpdateToken)) > 0 then
  begin
    imgGedemin.Visible := False;
    lblGedeminLoading.Visible := False;
    imgPositive.Visible := False;
    imgPositiveCash.Visible := True;
    lblPositiveLoading.Visible := True;
  end else
  begin
    imgGedemin.Visible := True;
    lblGedeminLoading.Visible := True;
    imgPositive.Visible := False;
    imgPositiveCash.Visible := False;
    lblPositiveLoading.Visible := False;
  end;

  gdSplash := Self;
end;

procedure TfrmSplash.FormDestroy(Sender: TObject);
begin
  gdSplash := nil;
end;

procedure TfrmSplash.TimerTimer(Sender: TObject);
begin
  gdSplash := nil;
  Release;
end;

procedure TfrmSplash.FreeSplash(const Immediately: Boolean = False);
begin
  if gdSplash = nil then
    exit;

  if Immediately then
  begin
    gdSplash := nil;
    Release;
    exit;
  end;

  ShowText(sItisAll);

  if gdSplash = nil then
    exit;

  gdSplash := nil;

  try
    if Timer.Enabled then
      Timer.Interval := 1000
    else
      Release;
  except
    Release;
  end;
end;

procedure TfrmSplash.FormShow(Sender: TObject);
begin
  try
    if not Timer.Enabled then
    begin
      Timer.Enabled := True;
    end;
  except
    gdSplash := nil;
    Release;
  end;
end;

end.
