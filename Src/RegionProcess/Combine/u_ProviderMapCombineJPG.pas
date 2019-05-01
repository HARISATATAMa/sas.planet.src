{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2014, SAS.Planet development team.                      *}
{* This program is free software: you can redistribute it and/or modify       *}
{* it under the terms of the GNU General Public License as published by       *}
{* the Free Software Foundation, either version 3 of the License, or          *}
{* (at your option) any later version.                                        *}
{*                                                                            *}
{* This program is distributed in the hope that it will be useful,            *}
{* but WITHOUT ANY WARRANTY; without even the implied warranty of             *}
{* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *}
{* GNU General Public License for more details.                               *}
{*                                                                            *}
{* You should have received a copy of the GNU General Public License          *}
{* along with this program.  If not, see <http://www.gnu.org/licenses/>.      *}
{*                                                                            *}
{* http://sasgis.org                                                          *}
{* info@sasgis.org                                                            *}
{******************************************************************************}

unit u_ProviderMapCombineJPG;

interface

uses
  i_InternalPerformanceCounter,
  i_LanguageManager,
  i_ProjectionSetList,
  i_ProjectionSetChangeable,
  i_RegionProcessProgressInfo,
  i_UseTilePrevZoomConfig,
  i_BitmapPostProcessing,
  i_HashFunction,
  i_Bitmap32BufferFactory,
  i_UsedMarksConfig,
  i_MarksDrawConfig,
  i_MarkSystem,
  i_MapType,
  i_FillingMapLayerConfig,
  i_FillingMapPolygon,
  i_MapLayerGridsConfig,
  i_CoordToStringConverter,
  i_MapCalibration,
  i_MapTypeListChangeable,
  i_GeometryProjectedFactory,
  i_GeometryProjectedProvider,
  i_VectorItemSubsetBuilder,
  i_GlobalViewMainConfig,
  i_RegionProcessProgressInfoInternalFactory,
  i_BitmapMapCombiner,
  u_ExportProviderAbstract,
  fr_MapSelect,
  u_ProviderMapCombine;

type
  TProviderMapCombineJPG = class(TProviderMapCombineBase)
  private
    FSaveRectCounter: IInternalPerformanceCounter;
    FPrepareDataCounter: IInternalPerformanceCounter;
    FGetLineCounter: IInternalPerformanceCounter;
  protected
    function PrepareMapCombiner(
      const AProgressInfo: IRegionProcessProgressInfoInternal
    ): IBitmapMapCombiner; override;
  public
    constructor Create(
      const AProgressFactory: IRegionProcessProgressInfoInternalFactory;
      const ALanguageManager: ILanguageManager;
      const ACounterList: IInternalPerformanceCounterList;
      const AMapSelectFrameBuilder: IMapSelectFrameBuilder;
      const AActiveMapsSet: IMapTypeListChangeable;
      const AViewConfig: IGlobalViewMainConfig;
      const AUseTilePrevZoomConfig: IUseTilePrevZoomConfig;
      const AProjectionSet: IProjectionSetChangeable;
      const AProjectionSetList: IProjectionSetList;
      const AVectorGeometryProjectedFactory: IGeometryProjectedFactory;
      const AProjectedGeometryProvider: IGeometryProjectedProvider;
      const AVectorSubsetBuilderFactory: IVectorItemSubsetBuilderFactory;
      const AMarksShowConfig: IUsedMarksConfig;
      const AMarksDrawConfig: IMarksDrawConfig;
      const AMarksDB: IMarkSystem;
      const AHashFunction: IHashFunction;
      const ABitmapFactory: IBitmap32StaticFactory;
      const ABitmapPostProcessing: IBitmapPostProcessingChangeable;
      const AFillingMapConfig: IFillingMapLayerConfig;
      const AFillingMapType: IMapTypeChangeable;
      const AFillingMapPolygon: IFillingMapPolygon;
      const AGridsConfig: IMapLayerGridsConfig;
      const ACoordToStringConverter: ICoordToStringConverterChangeable;
      const AMapCalibrationList: IMapCalibrationList
    );
  end;

implementation

uses
  Types,
  gnugettext,
  t_CommonTypes,
  t_MapCombineOptions,
  u_BitmapMapCombinerJPG,
  fr_MapCombine;

{ TProviderMapCombineJPG }

constructor TProviderMapCombineJPG.Create(
  const AProgressFactory: IRegionProcessProgressInfoInternalFactory;
  const ALanguageManager: ILanguageManager;
  const ACounterList: IInternalPerformanceCounterList;
  const AMapSelectFrameBuilder: IMapSelectFrameBuilder;
  const AActiveMapsSet: IMapTypeListChangeable;
  const AViewConfig: IGlobalViewMainConfig;
  const AUseTilePrevZoomConfig: IUseTilePrevZoomConfig;
  const AProjectionSet: IProjectionSetChangeable;
  const AProjectionSetList: IProjectionSetList;
  const AVectorGeometryProjectedFactory: IGeometryProjectedFactory;
  const AProjectedGeometryProvider: IGeometryProjectedProvider;
  const AVectorSubsetBuilderFactory: IVectorItemSubsetBuilderFactory;
  const AMarksShowConfig: IUsedMarksConfig;
  const AMarksDrawConfig: IMarksDrawConfig;
  const AMarksDB: IMarkSystem;
  const AHashFunction: IHashFunction;
  const ABitmapFactory: IBitmap32StaticFactory;
  const ABitmapPostProcessing: IBitmapPostProcessingChangeable;
  const AFillingMapConfig: IFillingMapLayerConfig;
  const AFillingMapType: IMapTypeChangeable;
  const AFillingMapPolygon: IFillingMapPolygon;
  const AGridsConfig: IMapLayerGridsConfig;
  const ACoordToStringConverter: ICoordToStringConverterChangeable;
  const AMapCalibrationList: IMapCalibrationList
);
var
  VCounterList: IInternalPerformanceCounterList;
begin
  inherited Create(
    AProgressFactory,
    ALanguageManager,
    AMapSelectFrameBuilder,
    AActiveMapsSet,
    AViewConfig,
    AUseTilePrevZoomConfig,
    AProjectionSet,
    AProjectionSetList,
    AVectorGeometryProjectedFactory,
    AProjectedGeometryProvider,
    AVectorSubsetBuilderFactory,
    AMarksShowConfig,
    AMarksDrawConfig,
    AMarksDB,
    AHashFunction,
    ABitmapFactory,
    ABitmapPostProcessing,
    AFillingMapConfig,
    AFillingMapType,
    AFillingMapPolygon,
    AGridsConfig,
    ACoordToStringConverter,
    AMapCalibrationList,
    Point(0, 0),
    Point(65536, 65536),
    stsUnicode,
    'jpg',
    gettext_NoExtract('JPEG (Joint Photographic Experts Group)'),
    [mcQuality, mcExif]
  );
  VCounterList := ACounterList.CreateAndAddNewSubList('JPEG');
  FSaveRectCounter := VCounterList.CreateAndAddNewCounter('SaveRect');
  FPrepareDataCounter := VCounterList.CreateAndAddNewCounter('PrepareData');
  FGetLineCounter := VCounterList.CreateAndAddNewCounter('GetLine');
end;

function TProviderMapCombineJPG.PrepareMapCombiner(
  const AProgressInfo: IRegionProcessProgressInfoInternal
): IBitmapMapCombiner;
var
  VProgressUpdate: IBitmapCombineProgressUpdate;
begin
  VProgressUpdate := PrepareCombineProgressUpdate(AProgressInfo);
  Result :=
    TBitmapMapCombinerJPG.Create(
      VProgressUpdate,
      FSaveRectCounter,
      FPrepareDataCounter,
      FGetLineCounter,
      (ParamsFrame as IRegionProcessParamsFrameMapCombine).CustomOptions.Quality,
      (ParamsFrame as IRegionProcessParamsFrameMapCombine).CustomOptions.IsSaveGeoRefInfoToExif
    );
end;

end.
