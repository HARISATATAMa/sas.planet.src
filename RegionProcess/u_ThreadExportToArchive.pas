unit u_ThreadExportToArchive;

interface

uses
  Types,
  SysUtils,
  Classes,
  GR32,
  i_TileFileNameGenerator,
  i_NotifierOperation,
  i_RegionProcessProgressInfo,
  i_CoordConverterFactory,
  i_VectorItmesFactory,
  i_VectorItemLonLat,
  i_ArchiveReadWrite,
  u_MapType,
  u_ResStrings,
  u_ThreadExportAbstract;

type
  TThreadExportToArchive = class(TThreadExportAbstract)
  private
    FMapType: TMapType;
    FArchive: IArchiveWriter;
    FTileNameGen: ITileFileNameGenerator;
    FProjectionFactory: IProjectionInfoFactory;
    FVectorItmesFactory: IVectorItmesFactory;
  protected
    procedure ProcessRegion; override;
  public
    constructor Create(
      const ACancelNotifier: INotifierOperation;
      const AOperationID: Integer;
      const AProgressInfo: IRegionProcessProgressInfoInternal;
      const AArchiveWriter: IArchiveWriter;
      const AProjectionFactory: IProjectionInfoFactory;
      const AVectorItmesFactory: IVectorItmesFactory;
      const APolygon: ILonLatPolygon;
      const Azoomarr: TByteDynArray;
      const AMapType: TMapType;
      const ATileNameGen: ITileFileNameGenerator
    );
  end;

implementation

uses
  i_BinaryData,
  i_VectorItemProjected,
  i_TileIterator,
  i_TileInfoBasic,  
  u_TileIteratorByPolygon,
  u_TileStorageAbstract;

{ TThreadExportToArchive }

constructor TThreadExportToArchive.Create(
  const ACancelNotifier: INotifierOperation;
  const AOperationID: Integer;
  const AProgressInfo: IRegionProcessProgressInfoInternal;
  const AArchiveWriter: IArchiveWriter;
  const AProjectionFactory: IProjectionInfoFactory;
  const AVectorItmesFactory: IVectorItmesFactory;
  const APolygon: ILonLatPolygon;
  const Azoomarr: TByteDynArray;
  const AMapType: TMapType;
  const ATileNameGen: ITileFileNameGenerator
);
begin
  inherited Create(
    ACancelNotifier,
    AOperationID,
    AProgressInfo,
    APolygon,
    Azoomarr,
    Self.ClassName
  );
  FProjectionFactory := AProjectionFactory;
  FVectorItmesFactory := AVectorItmesFactory;
  FTileNameGen := ATileNameGen;
  FMapType := AMapType;
  FArchive := AArchiveWriter;
end;

procedure TThreadExportToArchive.ProcessRegion;
var
  I: Integer;
  VZoom: Byte;
  VExt: string;
  VTile: TPoint;
  VTileIterators: array of ITileIterator;
  VTileIterator: ITileIterator;
  VTileStorage: TTileStorageAbstract;
  VTileInfo: ITileInfoBasic;
  VProjectedPolygon: IProjectedPolygon;
  VTilesToProcess: Int64;
  VTilesProcessed: Int64;
  VData: IBinaryData;
begin
  inherited;
  VTilesToProcess := 0;
  SetLength(VTileIterators, Length(FZooms));
  for I := 0 to Length(FZooms) - 1 do begin
    VZoom := FZooms[I];
    VProjectedPolygon :=
      FVectorItmesFactory.CreateProjectedPolygonByLonLatPolygon(
        FProjectionFactory.GetByConverterAndZoom(FMapType.GeoConvert, VZoom),
        PolygLL
      );
    VTileIterators[I] := TTileIteratorByPolygon.Create(VProjectedPolygon);
    VTilesToProcess := VTilesToProcess + VTileIterators[I].TilesTotal;
  end;
  try
    ProgressInfo.SetCaption(SAS_STR_ExportTiles);
    ProgressInfo.SetFirstLine(
      SAS_STR_AllSaves + ' ' + inttostr(VTilesToProcess) + ' ' + SAS_STR_Files
    );
    VTileStorage := FMapType.TileStorage;
    VTilesProcessed := 0;
    ProgressFormUpdateOnProgress(VTilesProcessed, VTilesToProcess);
    for I := 0 to Length(FZooms) - 1 do begin
      VZoom := FZooms[I];
      VExt := FMapType.StorageConfig.TileFileExt;
      VTileIterator := VTileIterators[I];
      while VTileIterator.Next(VTile) do begin
        if CancelNotifier.IsOperationCanceled(OperationID) then begin
          Exit;
        end;
        VData := VTileStorage.LoadTile(VTile, VZoom, nil, VTileInfo);
        if VData <> nil then begin
          FArchive.AddFile(
            VData,
            FTileNameGen.GetTileFileName(VTile, VZoom) + VExt,
            VTileInfo.GetLoadDate
          );
        end;
        Inc(VTilesProcessed);
        if VTilesProcessed mod 100 = 0 then begin
          ProgressFormUpdateOnProgress(VTilesProcessed, VTilesToProcess);
        end;
      end;
    end;
  finally
    for I := 0 to Length(FZooms) - 1 do begin
      VTileIterators[I] := nil;
    end;
    VTileIterators := nil;
  end;
end;

end.