{******************************************************************************}
{* SAS.Planet (SAS.�������)                                                   *}
{* Copyright (C) 2007-2019, SAS.Planet development team.                      *}
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

unit u_DownloaderByCurlFactory;

interface

uses
  i_Downloader,
  i_DownloaderFactory,
  i_DownloadResultFactory,
  u_BaseInterfacedObject;

type
  TDownloaderByCurlFactory = class(TBaseInterfacedObject, IDownloaderFactory)
  private
    FResultFactory: IDownloadResultFactory;
  private
    { IDownloaderFactory }
    function BuildDownloader(
      const AAllowUseCookie: Boolean;
      const AAllowRedirect: Boolean;
      const ATryDetectContentType: Boolean;
      const AOnDownloadProgress: TOnDownloadProgress
    ): IDownloader;

    function BuildDownloaderAsync(
      const AAllowUseCookie: Boolean;
      const AAllowRedirect: Boolean;
      const ATryDetectContentType: Boolean;
      const AOnDownloadProgress: TOnDownloadProgress
    ): IDownloaderAsync;
  public
    constructor Create;
  end;

implementation

uses
  u_DownloaderHttpByCurl,
  u_DownloadResultFactory;

{ TDownloaderByCurlFactory }

constructor TDownloaderByCurlFactory.Create;
begin
  inherited Create;
  FResultFactory := TDownloadResultFactory.Create;
end;

function TDownloaderByCurlFactory.BuildDownloader(
  const AAllowUseCookie: Boolean;
  const AAllowRedirect: Boolean;
  const ATryDetectContentType: Boolean;
  const AOnDownloadProgress: TOnDownloadProgress
): IDownloader;
begin
  Result :=
    TDownloaderHttpByCurl.Create(
      FResultFactory,
      AAllowUseCookie,
      AAllowRedirect,
      True, // ToDo
      ATryDetectContentType,
      AOnDownloadProgress
    );
end;

function TDownloaderByCurlFactory.BuildDownloaderAsync(
  const AAllowUseCookie: Boolean;
  const AAllowRedirect: Boolean;
  const ATryDetectContentType: Boolean;
  const AOnDownloadProgress: TOnDownloadProgress
): IDownloaderAsync;
begin
  Result :=
    TDownloaderHttpByCurl.Create(
      FResultFactory,
      AAllowUseCookie,
      AAllowRedirect,
      True, // ToDo
      ATryDetectContentType,
      AOnDownloadProgress
    );
end;

end.