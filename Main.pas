unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.JSON, Soap.EncdDecd, Math, StrUtils,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdGlobal;

type
  // 폼과 쓰레드의 소통을 위한 이벤트 2개 정의.
  TIndySyncEvent = procedure () of object;
  TLogEvent = procedure () of object;

  // 쓰레드 정의
  TIndyWorkerThread = class(TThread)
  private
    WExit: Boolean;           // 쓰레드 종료 여부.
    WPacket: String;          // 발송을 위한 패킷 변수.
    WOnSync: TIndySyncEvent;  // 발송 완료시점 이벤트.
    WOnLog: TLogEvent;        // 로그 출력 이벤트.

    procedure Execute; override;
    procedure ShowLog(Msg: String);
  public
    WClient: TIdTcpClient;  // 통신 Client
    WStrRead: String;       // 발송 결과
    WStrLog: String;        // 출력 Log

    constructor Create(WIp: String; WPort: word; WSyncEvent: TIndySyncEvent; WLogEvent: TLogEvent);
    procedure SendMessage(Msg: String);
  end;

  // 발송화면 정의
  TfrmForm = class(TForm)
    ButtonSend: TButton;
    MemoResult: TMemo;
    EditToken: TEdit;
    MemoMessage: TMemo;
    LabelToken: TLabel;
    LabelIP: TLabel;
    LabelPort: TLabel;
    LabelTitle: TLabel;
    EditIP: TEdit;
    EditPort: TEdit;
    EditTitle: TEdit;
    LabelCallback: TLabel;
    LabelTel: TLabel;
    EditCallback: TEdit;
    EditTel: TEdit;
    LabelMessage: TLabel;
    LabelTime: TLabel;
    EditTime: TEdit;
    LabelTimeInfo: TLabel;
    LabelSendType: TLabel;
    LabelMessageLength: TLabel;
    procedure ButtonSendClick(Sender: TObject);
    procedure MemoMessageChange(Sender: TObject);
  public
    MessageSize: Integer;   // 메시지 길이. (엔터 1byte, 한글 2byte 계산) 실제 사용시 문자셋으로 차이가 나지 않아야 합니다.
    StrMessage: String;     // 실제 발송할 최종 가공된 문자열. 개발 환경에 따라 핸드폰 인식불가 문자가 생길 수 있으니 주의하세요.
  private
    WClientWorkerThread: TIndyWorkerThread;  // 발송용 쓰레드.

    function DataToPacket: String;
    function JSONToString(obj: TJSONAncestor): string;
    procedure DidSendPacket;
    procedure ShowClientLog;
    procedure FormDestroy(Sender: TObject);
    function FindNumber(Target: string): string;
  end;

var
  frmForm: TfrmForm;

implementation

{$R *.dfm}

{*
 * TfrmForm
 * 발송 화면 Form Class
 *}

// 패킷 생성.
function TfrmForm.DataToPacket : String;
var
  jPair: TJSONObject; // JSON을 담는 변수.
  strPacket: String;  // 최종 생선된 발송용 패킷.
begin
  // JSON을 생성 하는 과정.
  jPair := TJSONObject.Create;
  jPair.AddPair('key',EditToken.Text);
  jPair.AddPair('tel',FindNumber(EditTel.Text));
  jPair.AddPair('cb',FindNumber(EditCallback.Text));
  jPair.AddPair('title',EditTitle.Text);
  jPair.AddPair('msg',StrMessage);
  jPair.AddPair('date',FindNumber(EditTime.Text));
  strPacket := JSONToString(jPair);
  jPair.Free;

  // 패킷 앞 '06' 코드와 JSON 길이를 계산하여 붙여주는 과정.
  strPacket := '06' + format('%0.4d', [strPacket.Length]) + strPacket;
  // 패킷의 구조가 규격서와 맞는지 직접 출력하여 확인하세요.
  // MemoResult.Text := MemoResult.Text + strPacket + #13#10;

  // 필수 항목 없을 시 함수 종료.
  // 번호 상세검사 및 날자가 맞는지 여부 등의 상세한 검사를 추가해야 합니다.
  if (EditToken.Text = '') or (EditTel.Text = '') or (EditCallback.Text = '') or (MessageSize = 0) then Result := ''
  else Result := strPacket;
end;

// JSON 원형 추출.
// 해당 함수를 통해 JSON 내의 한글을 변환해줍니다.
function TfrmForm.JSONToString(obj: TJSONAncestor): string;
var
  bytes: TBytes;
  len: Integer;
begin
  SetLength(bytes, obj.EstimatedByteSize);
  len := obj.ToBytes(bytes, 0);
  Result := TEncoding.ANSI.GetString(bytes, 0, len);
end;

// 발송 문구가 변경되는 경우.
procedure TfrmForm.MemoMessageChange(Sender: TObject);
begin
  StrMessage := StringReplace(MemoMessage.Text, #13#10, #13, [rfReplaceAll]); // 엔터를 1byte로 치환. ASCII 13번으로...
  MessageSize := Length(AnsiString(StrMessage)); // 한글을 2byte로 인식하기 위해 Ansi로 변경.
  // 발송 형태를 확인합니다. SMS / LMS
  LabelSendType.Caption := IfThen( MessageSize > 90, 'LMS', 'SMS' );
  // 발송 문구 길이를 표기합니다.
  LabelMessageLength.Caption := IntToStr(MessageSize) + 'b';
end;

// 전송버튼 클릭.
procedure TfrmForm.ButtonSendClick(Sender: TObject);
var
  SendPacket: String;
begin
  // 스레드 미생성시 생성합니다.
  if WClientWorkerThread = nil then
    WClientWorkerThread := TIndyWorkerThread.Create(EditIP.Text, StrToInt(EditPort.Text), DidSendPacket, ShowClientLog);

  SendPacket := DataToPacket; // 발송할 패킷을 가져옵니다.
  if SendPacket <> '' then
  begin
    ButtonSend.Enabled := False;
    // 패킷이 존재하면 발송 진행을 합니다.
    WClientWorkerThread.SendMessage(SendPacket);
  end
  else MemoResult.Text := MemoResult.Text + '발송할 정보가 잘못되었습니다.' + #13#10;
end;

// 메인쓰레드와 동기화 되어서 TcpClient 가 일하는 부분..
procedure TfrmForm.DidSendPacket;
begin
  // 발송이 완료되면 발송 버튼을 사용 가능하게 합니다.
  ButtonSend.Enabled := True;

  { 발송이 끝난 시점에 처리할 부분을 여기서 진행합니다. }
end;

// TcpClient 로그 출력.
procedure TfrmForm.ShowClientLog;
begin
  MemoResult.Text := MemoResult.Text + WClientWorkerThread.WStrLog + #13#10;
end;

procedure TfrmForm.FormDestroy(Sender: TObject);
begin
  // 쓰레드 중단 요청.
  if WClientWorkerThread <> nil then WClientWorkerThread.WExit := true;
end;

// 문자에서 숫자만 추출하는 함수
// 전화번호, 발송날자에 이용됩니다.
function TfrmForm.FindNumber(Target: string): string;
var
  I, NCnt, DLen: Integer;
  DStr: string;
begin
  DLen := Length(Target);

  for I := 1 to dLen do begin
    if not(Target[I] in['0'..'9']) then Continue;

    for NCnt := I to dLen do begin
    if not(Target[nCnt] in['0'..'9']) then Continue;
      DStr := DStr + Target[nCnt];
    end;

    Result := DStr;
    Break;
  end;
end;

{*
 * TIndyWorkerThread
 * 발송을 위한 쓰레드 클래스
 *}

// 쓰레드 생성자
// IP, Port와 함께 이벤트 2가지를 받아 기록합니다.
constructor TIndyWorkerThread.Create(WIP: string; WPort: word; WSyncEvent: TIndySyncEvent; WLogEvent: TLogEvent);
begin
  WExit := False;
  WPacket := '';
  WOnSync := WSyncEvent;
  WOnLog := WLogEvent;

  inherited Create(false);

  // TcpClient를 생성하여 접속처리 합니다.
  WClient := TIdTcpClient.Create(Application);
  WClient.Host := WIP;
  WClient.Port := WPort;
  WClient.Connect;
end;

// 문자 발송 처리.
// WPacket에 문자가 담기면 쓰레드로 인해 자동으로 발송이 진행됩니다.
procedure TIndyWorkerThread.SendMessage(Msg: String);
begin
  WPacket := Msg;
end;

// 쓰레드 구동부.
procedure TIndyWorkerThread.Execute;
var
  Len: Integer;       // 결과 문구 길이.
  Buffer: TIdBytes;   // 결과 임시 버퍼.
  ReadPacket: String; // 결과를 담는 문자열.
  IsSent: Boolean;    // 발송되어 결과를 기다리는 상태 기록. True 면 결과를 기다리는 중.
begin
  IsSent := False;

  // 소켓이 접속되어 반복이 진행된다.
  // 해당 반복문에서 발송을 반복 진행한다.
  while not WExit and WClient.Connected do
  begin
    // 발송중이 아닌 경우 패킷 문자열이 있다면 발송 진행.
    if not IsSent and (WPacket <> '') then
    begin
      // 발송값 전달.
      WClient.IOHandler.Write(WPacket);
      ShowLog(#13#10 + '패킷 발송: ' + WPacket);
      IsSent := True; // 발송중으로 전환.
      WPacket := ''; // 발송패킷 변수를 비운다.

      // 결과 확인을 위해 필요한 값들을 초기화.
      Buffer := nil;
      Len := 0;
    end;

    // 발송중인 경우 수신할 버퍼가 있는지 확인한다.
    if IsSent and not WClient.IOHandler.InputBufferIsEmpty then
    begin
      // 존재하는 버퍼의 크기를 가져와 누적한다.
      Len := Len + WClient.IOHandler.InputBuffer.Size;
      // 버퍼의 내용도 누적하여 기록한다.
      WClient.IOHandler.InputBuffer.ExtractToBytes(Buffer);

      // 버퍼의 길이가 31byte인 경우 결과를 표시한다.
      if Len = 31 then
      begin
        // 버퍼의 내용을 문자열로 바꾼다.
        WStrRead := BytesToString(Buffer);
        ShowLog('결과수신: ' + WStrRead);

        // 정상 수신시 Form 클래에게 완료되었음을 알리기 위해 함수를 호출한다.
        if Assigned(WOnSync) and (WStrRead <> '') then
        begin
          Synchronize(WOnSync);
          IsSent := False; // 다시 발송하기 위해 발송 상태를 False 로 변경한다.
        end;
      end;
    end;

    sleep(100);
  end;
end;

// 쓰레드 내에서 진행하는 내용(Log)을 Form으로 전달한다.
procedure TIndyWorkerThread.ShowLog(Msg: String);
begin
  if Assigned(WOnSync) then
  begin
    WStrLog := Msg;
    Synchronize(WOnLog);
  end;
end;

end.
