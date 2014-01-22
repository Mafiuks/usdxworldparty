{* UltraStar Deluxe - Karaoke Game
 *
 * UltraStar Deluxe is the legal property of its developers, whose names
 * are too numerous to list here. Please refer to the COPYRIGHT
 * file distributed with this source distribution.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 * $URL: https://ultrastardx.svn.sourceforge.net/svnroot/ultrastardx/trunk/src/screens/UScreenOptionsAdvanced.pas $
 * $Id: UScreenOptionsAdvanced.pas 2338 2010-05-03 21:58:30Z k-m_schindler $
 *}

unit UScreenOptionsWebcam;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  SDL,
  UMenu,
  UDisplay,
  UMusic,
  UFiles,
  UIni,
  UThemes;

type
  TScreenOptionsWebcam = class(TMenu)
    private
      FrameX, FrameY, FrameW, FrameH: integer;
    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      function Draw: boolean; override;
      procedure DrawWebCamFrame;
  end;

implementation

uses
  gl,
  UGraphic,
  UUnicodeUtils,
  UWebcam,
  SysUtils;

function TScreenOptionsWebcam.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          //Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenOptions);
        end;
      SDLK_RETURN:
        begin
          if SelInteraction = 3 then
          begin
            //Ini.Save;
            AudioPlayback.PlaySound(SoundLib.Back);
            FadeTo(@ScreenOptions);
          end;
        end;
      SDLK_DOWN:
        InteractNext;
      SDLK_UP :
        InteractPrev;
      SDLK_RIGHT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 2) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractInc;
          end;
        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction <= 2) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;
        end;
    end;
  end;
end;

constructor TScreenOptionsWebcam.Create;
var
  WebcamsIDs: array[0..1] of UTF8String;
  SelectWebcam: integer;
begin
  inherited Create;

  LoadFromTheme(Theme.OptionsWebcam);

  WebcamsIDs[0] := '0';
  WebcamsIDs[1] := '1';

  Theme.OptionsWebcam.SelectWebcam.showArrows := true;
  Theme.OptionsWebcam.SelectWebcam.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsWebcam.SelectWebcam, Ini.WebCamID, WebcamsIDs);

  Theme.OptionsWebcam.SelectResolution.showArrows := true;
  Theme.OptionsWebcam.SelectResolution.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsWebcam.SelectResolution, Ini.WebcamResolution, IWebcamResolution);

  Theme.OptionsWebcam.SelectFPS.showArrows := true;
  Theme.OptionsWebcam.SelectFPS.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsWebcam.SelectFPS, Ini.WebCamFPS, IWebcamFPS);

  AddButton(Theme.OptionsWebcam.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 5, Theme.Options.Description[9]);

  FrameX := Theme.OptionsWebcam.Frame.X;
  FrameY := Theme.OptionsWebcam.Frame.Y;
  FrameW := Theme.OptionsWebcam.Frame.W;
  FrameH := Theme.OptionsWebcam.Frame.H;

  Interaction := 0;
end;

procedure TScreenOptionsWebcam.OnShow;
begin
  inherited;

  Interaction := 0;
end;

function TScreenOptionsWebcam.Draw: boolean;
begin
  DrawBG;

  DrawWebCamFrame;

  DrawFG;
end;

procedure TScreenOptionsWebcam.DrawWebCamFrame;
begin

  Webcam.GetWebcamFrame;

  if (Webcam.TextureCam.TexNum > 0) then
  begin
    glColor4f(1, 1, 1, 1);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glEnable(GL_TEXTURE_2D);

    glBindTexture(GL_TEXTURE_2D, Webcam.TextureCam.TexNum);
    glEnable(GL_BLEND);
    glBegin(GL_QUADS);

    // WITHOUT FLIP
    {
    glTexCoord2f(0, 0);
    glVertex2f(800,  0);
    glTexCoord2f(0, ScreenSing.TextureCam.TexH);
    glVertex2f(800,  600);
    glTexCoord2f( ScreenSing.TextureCam.TexW, ScreenSing.TextureCam.TexH);
    glVertex2f(0, 600);
    glTexCoord2f( ScreenSing.TextureCam.TexW, 0);
    glVertex2f(0, 0);
    }

    // WITH FLIP
    glTexCoord2f(0, 0);
    glVertex2f(FrameX, FrameY);
    glTexCoord2f(0,  Webcam.TextureCam.TexH);
    glVertex2f(FrameX,  FrameY + FrameH);
    glTexCoord2f( Webcam.TextureCam.TexW,  Webcam.TextureCam.TexH);
    glVertex2f(FrameX + FrameW, FrameY + FrameH);
    glTexCoord2f( Webcam.TextureCam.TexW, 0);
    glVertex2f(FrameX + FrameW, FrameY);

    glEnd;
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);

    // reset to default
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  end;

end;




end.
