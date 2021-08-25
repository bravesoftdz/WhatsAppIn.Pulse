unit uBase64;

interface

uses System.Classes, System.netEncoding, System.SysUtils, FMX.Graphics;

  procedure Base64ToFile(AArquivo, ACaminhoSalvar : String);
  function Base64ToStream(AImagem : String) : TMemoryStream;
  function FileToBase64(AArquivo : String) : String;
  function StreamToBase64(ASTream : TMemoryStream) : String;
  function Base64ToBitmap(AImagem : String) : TBitmap;
  function BitmapToBase64(AImagem : TBitmap) : String;

implementation

procedure Base64ToFile(AArquivo, ACaminhoSalvar : String);
var
  lStream : TMemoryStream;
begin
  try
    if not (DirectoryExists(ExtractFilePath(ACaminhoSalvar))) then
      ForceDirectories(ExtractFilePath(ACaminhoSalvar));

    lStream := Base64ToStream(AArquivo);
    lStream.SaveToFile(ACaminhoSalvar);
  finally
    lStream.free;
    lStream := nil;
  end;
end;

function Base64ToStream(AImagem: String): TMemoryStream;
var
  lBase64 : TBase64Encoding;
  lBytes : tBytes;
begin
  try
    lBase64 := TBase64Encoding.Create;
    lBytes  := lBase64.DecodeStringToBytes(AImagem);
    Result := TBytesStream.Create(lBytes);
    Result.Position := 0; {ANDROID 64 BITS}
    //result.Seek(0, 0); {ANDROID 32 BITS SOMENTE}
  finally
    lBase64.Free;
    lBase64 := nil;
    SetLength(lBytes, 0);
  end;
end;

function FileToBase64(AArquivo : String): String;
var
  lStream : tMemoryStream;
begin
  if (Trim(AArquivo) <> '') then
  begin
    lStream := TMemoryStream.Create;
    try
      lStream.LoadFromFile(AArquivo);
      Result := StreamToBase64(lStream);
    finally
      lStream.Free;
      lStream := nil;
    end;
  end else
     Result := '';
end;

function StreamToBase64(ASTream: TMemoryStream): String;
var
  lBase64 : tBase64Encoding;
begin
  try
    AStream.Position := 0; {ANDROID 64 BITS}
    //result.Seek(0, 0); {ANDROID 32 BITS SOMENTE}
    lBase64 := TBase64Encoding.Create;
    Result := lBase64.EncodeBytesToString(ASTream.Memory, ASTream.Size);
  finally
    lBase64.Free;
    lBase64 := nil;
  end;
end;

function Base64ToBitmap(AImagem: String): TBitmap;
var
  lStream : TMemoryStream;
begin
  if (trim(AImagem) <> '') then
  begin
    try
      lStream := Base64ToStream(AImagem);
      Result := TBitmap.CreateFromStream(lStream);
    finally
      lStream.DisposeOf;
      lStream := nil;
    end;
  end;
end;


function BitmapToBase64(AImagem: TBitmap): String;
var
  lStream : TMemoryStream;
begin
  Result := '';

  if not (AImagem.IsEmpty) then
  begin
    try
      lStream := TMemoryStream.Create;
      AImagem.SaveToStream(lStream);
      Result := StreamToBase64(lStream);
      lStream.DisposeOf;
      lStream := nil;
    except
    end;
  end;
end;

end.
