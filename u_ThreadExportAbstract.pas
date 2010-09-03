unit u_ThreadExportAbstract;

interface

uses
  Classes,
  t_GeoTypes,
  u_ThreadRegionProcessAbstract,
  UResStrings;

type
  TThreadExportAbstract = class(TThreadRegionProcessAbstract)
  protected
    FZooms: array of Byte;
    procedure ProgressFormUpdateOnProgress; virtual;
  public
    constructor Create(
      APolygon: TExtendedPointArray;
      Azoomarr: array of boolean
    );
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils;

constructor TThreadExportAbstract.Create(APolygon: TExtendedPointArray;
  Azoomarr: array of boolean);
var
  i: Integer;
  VZoomCount: Integer;
begin
  inherited Create(APolygon);
  SetLength(FZooms, 24);
  VZoomCount := 0;
  for i := 0 to 23 do begin
    if Azoomarr[i] then begin
      FZooms[VZoomCount] := i;
      Inc(VZoomCount);
    end;
  end;
  if VZoomCount <= 0 then
    raise Exception.Create('�� ������� �� ������ ����');
  SetLength(FZooms, VZoomCount);
end;

destructor TThreadExportAbstract.Destroy;
begin
  inherited;
  FZooms := nil;
end;

procedure TThreadExportAbstract.ProgressFormUpdateOnProgress;
begin
  ProgressFormUpdateProgressAndLine1(
    round((FTilesProcessed / FTilesToProcess) * 100),
    SAS_STR_Processed + ' ' + inttostr(FTilesProcessed)
  );
end;

end.
