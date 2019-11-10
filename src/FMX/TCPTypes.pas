unit TCPTypes;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}
{$H+}

interface

uses
	Generics.Collections, Classes;

type
 	TMsgData = array of Byte;

     { TBaseIdentMessage }

    TBaseIdentMessage = class
		Ident: TGUID;
        Data: TMsgData;

        constructor Create; virtual;

		function  Encode: TMsgData; virtual;
		procedure Decode(const AData: TMsgData); virtual;
	end;

    TIdentMessages = TThreadList<TBaseIdentMessage>;

    TLogKind = (slkError, slkWarning, slkInfo, slkDebug);

    TLogMessage = class
        Kind: TLogKind;
        Message: string;
    end;

	TLogMessages = TThreadList<TLogMessage>;


procedure AddLogMessage(const AKind: TLogKind; const AMessage: string);

var
	LogMessages: TLogMessages;


implementation
	
uses
    SysUtils;


procedure AddLogMessage(const AKind: TLogKind; const AMessage: string);
    var
    lm: TLogMessage;

    begin
    lm:= TLogMessage.Create;
    lm.Kind:= AKind;
    lm.Message:= FormatDateTime('hh:nn:ss.zzz ', Now) + AMessage;
    UniqueString(lm.Message);

    LogMessages.Add(lm);
    end;

{ TBaseIdentMessage }

constructor TBaseIdentMessage.Create;
    begin
    inherited;

    end;

function TBaseIdentMessage.Encode: TMsgData;
    begin
    Result:= Data;
    end;

procedure TBaseIdentMessage.Decode(const AData: TMsgData);
    begin
    Data:= AData;
    end;


initialization
	LogMessages:= TLogMessages.Create;


finalization
    with LogMessages.LockList do
        while Count > 0 do
            begin
            Items[Count - 1].Free;
            Delete(Count - 1);
            end;

	LogMessages.Free;

end.
