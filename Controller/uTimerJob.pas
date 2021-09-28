unit uTimerJob;

interface

uses
  System.Classes, System.SyncObjs, System.SysUtils;

type
  TTimerJobException = reference to procedure(Sender: TObject; AException: Exception);

type
  TTimerJob = class(TThread)
  private
    { private declarations }
    FEvent: TEvent;
    FOnTimer: TNotifyEvent;
    FInterval: Integer;
    FOnFinish: TNotifyEvent;
    FOnException: TTimerJobException;
    procedure SetOnTimer(const Value: TNotifyEvent);
    procedure SetInterval(const Value: Integer);
    procedure SetOnFinish(const Value: TNotifyEvent);
    procedure SetOnException(const Value: TTimerJobException);
  protected
    { protected declarations }
    procedure Execute; override;
    procedure DoTimer;
    procedure DoFinish;
    procedure DoException(AException: Exception);
  public
    { public declarations }
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure ForceTerminate;
    property OnTimer: TNotifyEvent read FOnTimer write SetOnTimer;
    property OnFinish: TNotifyEvent read FOnFinish write SetOnFinish;
    property OnException: TTimerJobException read FOnException write SetOnException;
    property Interval: Integer read FInterval write SetInterval;
  end;

implementation

{ TTimerJob }

procedure TTimerJob.AfterConstruction;
begin
  inherited;
  FInterval := 1000;
  FEvent := TEvent.Create;
end;

procedure TTimerJob.BeforeDestruction;
begin
  inherited;
  FEvent.Free;
end;

procedure TTimerJob.DoException(AException: Exception);
begin
  if Assigned(FOnException) then
    FOnException(Self, AException);
end;

procedure TTimerJob.DoFinish;
begin
  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TTimerJob.DoTimer;
begin
  if Assigned(FOnTimer) then
    FOnTimer(Self);
end;

procedure TTimerJob.Execute;
var
  lWaitResult: TWaitResult;
begin
  inherited;

  try
    while not Self.Terminated do
    begin
      lWaitResult := FEvent.WaitFor(FInterval);
      if lWaitResult <> TWaitResult.wrTimeout then
        Exit;

      try
        DoTimer;
      except
        on E: Exception do
        begin
          DoException(E);
          // raise // caso queira interromper o processo
        end;
      end;
    end;
  finally
    DoFinish;
  end;
end;

procedure TTimerJob.ForceTerminate;
begin
  FEvent.SetEvent;
end;

procedure TTimerJob.SetInterval(const Value: Integer);
begin
  FInterval := Value;
end;

procedure TTimerJob.SetOnException(const Value: TTimerJobException);
begin
  FOnException := Value;
end;

procedure TTimerJob.SetOnFinish(const Value: TNotifyEvent);
begin
  FOnFinish := Value;
end;

procedure TTimerJob.SetOnTimer(const Value: TNotifyEvent);
begin
  FOnTimer := Value;
end;

end.
