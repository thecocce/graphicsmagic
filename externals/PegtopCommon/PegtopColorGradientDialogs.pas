////////////////////////////////////////////////////////////////////////////////
// File:       PegtopColorDialogs.pas
// Components: TPegtopColorGradientDialog
// Version:    1.01
// Date:       24 Jan 2005 1.00
//             17 Aug 2005 1.01 (gradient library support added)
// Author:     Jens Gruschel (GRU)
// Copyright:  (c) 2005 Jens Gruschel
// Website:    http://www.pegtop.net/delphi
////////////////////////////////////////////////////////////////////////////////
// Description:
// TPegtopColorGradientDialog is a dialog for defininig color gradients
// (see TPegtopColorGradient in PegtopColorGradients.pas).
////////////////////////////////////////////////////////////////////////////////
// License:
// Please read the license.txt file that comes with this software
// and visit http://www.pegtop.net/delphi
////////////////////////////////////////////////////////////////////////////////
// Documentation / Installation:
// Please read the readme.txt file that comes with this software
// and visit http://www.pegtop.net/delphi
////////////////////////////////////////////////////////////////////////////////

unit PegtopColorGradientDialogs;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  PegtopColorControls, PegtopColorGradients, PegtopColorDialogs,
  PegtopColorGradientLists, PegtopColorGradientListBoxes;

type
  TPegtopColorGradientEvent = procedure(Sender: TObject; ColorGradient: TPegtopCustomColorGradient) of object;

  TPegtopColorGradientDialog = class(TComponent)
  private
    FInternalGradient: TPegtopCustomColorGradient;
    FGradient: TPegtopCustomColorGradient;
    FGradientLibrary: TPegtopCustomColorGradientLibrary;
    FGradientLibraryIndex: Integer;
    FCaption: TCaption;
    FLook: TPegtopColorControlLook;
    FGradientOptions: TPegtopColorGradientOptions;
    FOnPreview: TPegtopColorGradientEvent;
    procedure FormPreview(Sender: TObject; ColorGradient: TPegtopCustomColorGradient);
    procedure SetGradient(Value: TPegtopCustomColorGradient);
    procedure SetGradientHook(Value: TPegtopCustomColorGradient);
    procedure SetGradientLibrary(Value: TPegtopCustomColorGradientLibrary);
    procedure SetGradientLibraryIndex(Value: Integer);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean;
    property GradientHook: TPegtopCustomColorGradient read FGradient write SetGradientHook;
  published
    property Gradient: TPegtopCustomColorGradient read FGradient write SetGradient;
    property GradientLibrary: TPegtopCustomColorGradientLibrary read FGradientLibrary write SetGradientLibrary;
    property GradientLibraryIndex: Integer read FGradientLibraryIndex write SetGradientLibraryIndex;
    property Caption: TCaption read FCaption write FCaption;
    property Look: TPegtopColorControlLook read FLook write FLook default pclRoundedRect;
    property GradientOptions: TPegtopColorGradientOptions read FGradientOptions write FGradientOptions;
    property OnPreview: TPegtopColorGradientEvent read FOnPreview write FOnPreview;
  end;

implementation

uses
  Forms, StdCtrls, ComCtrls, PegtopCheckBoxes, PegtopNumEdits, PegtopTrackBars,
  PegtopColorGradientBars, PegtopColorUtils;

type
  TPegtopColorGradientForm = class(TCustomForm)
  private
    FGradient: TPegtopCustomColorGradient;
    FGradientLibrary: TPegtopCustomColorGradientLibrary;
    FGradientLibraryIndex: Integer;
    FLook: TPegtopColorControlLook;
    FGradientOptions: TPegtopColorGradientOptions;
    FUpdating: Boolean;
    FOnPreview: TPegtopColorGradientEvent;
    
    FManager: TPegtopColorGradientManager;
    FNameEdit: TEdit;
    FModeComboBox: TComboBox;
    FSeamlessCheckBox: TPegtopCheckBox;
    FColorGroupBox: TGroupBox;
    FColorGradientBar: TPegtopColorGradientBar;
    FColorFrequencyTrackBar: TPegtopTrackBar;
    FColorSmoothnessTrackBar: TPegtopTrackBar;
    FColorNoiseStrengthTrackBar: TPegtopTrackBar;
    FColorNoiseFrequencyTrackBar: TPegtopTrackBar;
    FColorNoiseHeaderLabel: TLabel;
    FColorNoiseRoughnessTrackBar: TPegtopTrackBar;
    FColorNoiseKeyLabel: TLabel;
    FColorNoiseKeyIntEdit: TPegtopIntEdit;
    FColorNoiseKeyUpDown: TUpDown;
    FColorNoiseRedRangeBar: TPegtopRangeBar;
    FColorNoiseGreenRangeBar: TPegtopRangeBar;
    FColorNoiseBlueRangeBar: TPegtopRangeBar;
    FColorNoiseHueAvgTrackBar: TPegtopTrackBar;
    FColorNoiseHueRangeTrackBar: TPegtopTrackBar;
    FColorNoiseSaturationRangeBar: TPegtopRangeBar;
    FColorNoiseBrightnessRangeBar: TPegtopRangeBar;
    FColorKeyHeaderLabel: TLabel;
    FColorKeyColorBox: TPegtopColorBox;
    FColorKeyLocationLabel: TLabel;
    FColorKeyLocationFloatEdit: TPegtopFloatEdit;
    FColorKeyDeleteButton: TButton;
    FOpacityGroupBox: TGroupBox;
    FOpacityGradientBar: TPegtopOpacityGradientBar;
    FOpacityFrequencyTrackBar: TPegtopTrackBar;
    FOpacitySmoothnessTrackBar: TPegtopTrackBar;
    FOpacityNoiseStrengthTrackBar: TPegtopTrackBar;
    FOpacityNoiseFrequencyTrackBar: TPegtopTrackBar;
    FOpacityNoiseHeaderLabel: TLabel;
    FOpacityNoiseRoughnessTrackBar: TPegtopTrackBar;
    FOpacityNoiseKeyLabel: TLabel;
    FOpacityNoiseKeyIntEdit: TPegtopIntEdit;
    FOpacityNoiseKeyUpDown: TUpDown;
    FOpacityNoiseOpacityRangeBar: TPegtopRangeBar;
    FOpacityKeyHeaderLabel: TLabel;
    FOpacityKeyOpacityTrackBar: TPegtopTrackBar;
    FOpacityKeyLocationLabel: TLabel;
    FOpacityKeyLocationFloatEdit: TPegtopFloatEdit;
    FOpacityKeyDeleteButton: TButton;
    procedure CreateControls;
    procedure UpdateColorFocusKey;
    procedure UpdateOpacityFocusKey;
    procedure UpdateColorNoiseVisibility;
    // ## event handlers:
    procedure ColorGradientChange(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure ModeComboBoxClick(Sender: TObject);
    procedure SeamlessCheckBoxClick(Sender: TObject);
    procedure ColorGradientBarFocusKeyChange(Sender: Tobject);
    procedure ColorGradientBarFocusKeyModify(Sender: Tobject);
    procedure ColorGradientBarScroll(Sender: TObject;
      ScrollCode: TPegtopScrollCode; var ScrollPos: Integer);
    procedure ColorSmoothnessTrackBarChange(Sender: TObject);
    procedure ColorFrequencyTrackBarChange(Sender: TObject);
    procedure ColorNoiseStrengthTrackBarChange(Sender: TObject);
    procedure TriggerColorNoiseStrengthChange;
    procedure ColorNoiseFrequencyTrackBarChange(Sender: TObject);
    procedure ColorNoiseRoughnessTrackBarChange(Sender: TObject);
    procedure ColorNoiseKeyIntEditChange(Sender: TObject);
    procedure ColorNoiseKeyUpDownChangingEx(Sender: TObject;
      var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
    procedure ColorNoiseRGBRangeBarChange(Sender: TObject);
    procedure ColorNoiseHSBRangeBarChange(Sender: TObject);
    procedure ColorNoiseRGBRangeBarDrawTrack(Sender: TObject; Canvas: TCanvas; Orientation: TPegtopSlideBarOrientation; BoundsRect: TRect; Center: TPoint);
    procedure ColorNoiseHueRangeBarDrawTrack(Sender: TObject; Canvas: TCanvas; Orientation: TPegtopSlideBarOrientation; BoundsRect: TRect; Center: TPoint);
    procedure ColorNoiseSBRangeBarDrawTrack(Sender: TObject; Canvas: TCanvas; Orientation: TPegtopSlideBarOrientation; BoundsRect: TRect; Center: TPoint);
    procedure SmoothnessTrackBarLabel(Sender: TObject; var Caption: String);
    procedure ColorKeyColorBoxChange(Sender: TObject);
    procedure ColorKeyColorBoxPreview(Sender: TObject; Color: TColor);
    procedure ColorKeyLocationFloatEditChange(Sender: TObject);
    procedure ColorKeyDeleteButtonClick(Sender: TObject);
    procedure OpacityGradientBarFocusKeyChange(Sender: Tobject);
    procedure OpacityGradientBarFocusKeyModify(Sender: Tobject);
    procedure OpacityGradientBarScroll(Sender: TObject;
      ScrollCode: TPegtopScrollCode; var ScrollPos: Integer);
    procedure OpacitySmoothnessTrackBarChange(Sender: TObject);
    procedure OpacityFrequencyTrackBarChange(Sender: TObject);
    procedure OpacityNoiseStrengthTrackBarChange(Sender: TObject);
    procedure OpacityNoiseOpacityRangeBarDrawTrack(Sender: TObject; Canvas: TCanvas; Orientation: TPegtopSlideBarOrientation; BoundsRect: TRect; Center: TPoint);
    procedure TriggerOpacityNoiseStrengthChange;
    procedure OpacityNoiseFrequencyTrackBarChange(Sender: TObject);
    procedure OpacityNoiseRoughnessTrackBarChange(Sender: TObject);
    procedure OpacityNoiseKeyIntEditChange(Sender: TObject);
    procedure OpacityNoiseKeyUpDownChangingEx(Sender: TObject;
      var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
    procedure OpacityNoiseOpacityRangeBarChange(Sender: TOBject);
    procedure OpacityKeyOpacityTrackBarChange(Sender: TObject);
    procedure OpacityKeyLocationFloatEditChange(Sender: TObject);
    procedure OpacityKeyDeleteButtonClick(Sender: TObject);
    procedure ManagerApply(Sender: TObject);
    procedure ManagerAddNew(Sender: TObject; NewGradient: TPegtopCustomColorGradient);
  protected
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  public
    procedure Init;
    procedure DeInit;
    property Gradient: TPegtopCustomColorGradient read FGradient;
    property GradientLibrary: TPegtopCustomColorGradientLibrary read FGradientLibrary write FGradientLibrary;
    property GradientLibraryIndex: Integer read FGradientLibraryIndex write FGradientLibraryIndex;
    property Look: TPegtopColorControlLook read FLook write FLook;
    property GradientOptions: TPegtopColorGradientOptions read FGradientOptions write FGradientOptions;
    property OnPreview: TPegtopColorGradientEvent read FOnPreview write FOnPreview;
  end;

resourcestring
  PegtopColorGradientDialogOkCaption = 'OK';
  PegtopColorGradientDialogCancelCaption = 'Cancel';
  PegtopColorGradientDialogDefaultCaption = 'Modify color gradient';

////////////////////////////////////////////////////////////////////////////////
// TPegtopColorGradientForm
////////////////////////////////////////////////////////////////////////////////

procedure TPegtopColorGradientForm.AfterConstruction;
begin
  inherited;
  FGradient := TPegtopColorGradient.Create([]);
end;

procedure TPegtopColorGradientForm.CreateControls;
var
  OpacityHeight: Integer;
  ManagerWidth: Integer;
begin
  if pgoIgnoreOpacity in FGradientOptions then OpacityHeight := 0 else OpacityHeight := 220;
  if Assigned(FGradientLibrary) then ManagerWidth := 128 else ManagerWidth := 0;
  ClientWidth := 481 + ManagerWidth;
  ClientHeight := 293 + OpacityHeight;
  Position := poScreenCenter;
  BorderStyle := bsSingle;
  BorderIcons := [biSystemMenu];
  AutoScroll := False;

  // main controls:
  with TLabel.Create(Self) do begin
    SetBounds(8 + ManagerWidth, 12, 41, 13);
    Caption := 'Name';
    Parent := Self;
  end;

  FNameEdit := TEdit.Create(Self);
  FNameEdit.SetBounds(56 + ManagerWidth, 8, 193, 21);
  FNameEdit.Parent := Self;
  FNameEdit.MaxLength := 31;
  FNameEdit.OnChange := NameEditChange;

  with TLabel.Create(Self) do begin
    SetBounds(264 + ManagerWidth, 12, 41, 13);
    Caption := 'Mode';
    Parent := Self;
  end;

  FModeComboBox := TComboBox.Create(Self);
  FModeComboBox.SetBounds(312 + ManagerWidth, 8, 73, 21);
  FModeComboBox.Parent := Self;
  FModeComboBox.Style := csDropDownList;
  FModeComboBox.Items.Add('RGB');
  FModeComboBox.Items.Add('HSB');
  FModeComboBox.OnClick := ModeComboBoxClick;

  FSeamlessCheckBox := TPegtopCheckBox.Create(Self);
  FSeamlessCheckBox.SetBounds(392 + ManagerWidth, 10, 81, 17);
  FSeamlessCheckBox.Caption := 'Seamless';
  FSeamlessCheckBox.Parent := Self;
  FSeamlessCheckBox.OnClick := SeamlessCheckBoxClick;

  // color group box:
  FColorGroupBox := TGroupBox.Create(Self);
  FColorGroupBox.SetBounds(8 + ManagerWidth, 32, 465, 221);
  FColorGroupBox.Caption := 'Color';
  FColorGroupBox.Parent := Self;

  // color gradient control:
  FColorGradientBar := TPegtopColorGradientBar.Create(Self);
  FColorGradientBar.SetBounds(8, 16, 448, 41);
  FColorGradientBar.Parent := FColorGroupBox;
  FColorGradientBar.OnFocusKeyModify := ColorGradientBarFocusKeyModify;
  FColorGradientBar.OnScroll := ColorGradientBarScroll;
  FColorGradientBar.OnGradientChange := ColorGradientChange;

  // color gradient settings controls:
  with TLabel.Create(Self) do begin
    SetBounds(8, 60, 144, 13);
    Caption := 'Gradient settings';
    Parent := FColorGroupBox;
    Font.Style := [fsBold];
  end;

  FColorFrequencyTrackBar := TPegtopTrackBar.Create(Self);
  FColorFrequencyTrackBar.SetBounds(8, 76, 144, 32);
  FColorFrequencyTrackBar.LabelCaption := 'Frequency: <pos>';
  FColorFrequencyTrackBar.Parent := FColorGroupBox;
  FColorFrequencyTrackBar.Min := 1;
  FColorFrequencyTrackBar.Max := 10;
  FColorFrequencyTrackBar.DefaultPosition := 1;
  FColorFrequencyTrackBar.OnChange := ColorFrequencyTrackBarChange;

  FColorSmoothnessTrackBar := TPegtopTrackBar.Create(Self);
  FColorSmoothnessTrackBar.SetBounds(8, 108, 144, 32);
  FColorSmoothnessTrackBar.LabelCaption := 'Smoothness: <pos> %';
  FColorSmoothnessTrackBar.Parent := FColorGroupBox;
  FColorSmoothnessTrackBar.DefaultPosition := 100;
  FColorSmoothnessTrackBar.OnChange := ColorSmoothnessTrackBarChange;
  FColorSmoothnessTrackBar.OnLabel := SmoothnessTrackBarLabel;

  FColorNoiseStrengthTrackBar := TPegtopTrackBar.Create(Self);
  FColorNoiseStrengthTrackBar.SetBounds(8, 140, 144, 32);
  FColorNoiseStrengthTrackBar.LabelCaption := 'Noise strength: <pos> %';
  FColorNoiseStrengthTrackBar.Parent := FColorGroupBox;
  FColorNoiseStrengthTrackBar.OnChange := ColorNoiseStrengthTrackBarChange;
  FColorNoiseStrengthTrackBar.DefaultPosition := 0;

  FColorNoiseFrequencyTrackBar := TPegtopTrackBar.Create(Self);
  FColorNoiseFrequencyTrackBar.SetBounds(8, 172, 144, 32);
  FColorNoiseFrequencyTrackBar.LabelCaption := 'Noise frequency: <pos>';
  FColorNoiseFrequencyTrackBar.Parent := FColorGroupBox;
  FColorNoiseFrequencyTrackBar.Min := 1;
  FColorNoiseFrequencyTrackBar.Max := 10;
  FColorNoiseFrequencyTrackBar.DefaultPosition := 2;
  FColorNoiseFrequencyTrackBar.OnChange := ColorNoiseFrequencyTrackBarChange;

  // color noise settings controls:
  FColorNoiseHeaderLabel := TLabel.Create(Self);
  FColorNoiseHeaderLabel.SetBounds(160, 60, 144, 13);
  FColorNoiseHeaderLabel.Caption := 'Noise settings';
  FColorNoiseHeaderLabel.Parent := FColorGroupBox;
  FColorNoiseHeaderLabel.Font.Style := [fsBold];

  FColorNoiseRoughnessTrackBar := TPegtopTrackBar.Create(Self);
  FColorNoiseRoughnessTrackBar.SetBounds(160, 76, 144, 32);
  FColorNoiseRoughnessTrackBar.LabelCaption := 'Noise roughness: <pos> %';
  FColorNoiseRoughnessTrackBar.Parent := FColorGroupBox;
  FColorNoiseRoughnessTrackBar.OnChange := ColorNoiseRoughnessTrackBarChange;
  FColorNoiseRoughnessTrackBar.DefaultPosition := 50;

  FColorNoiseKeyLabel := TLabel.Create(Self);
  FColorNoiseKeyLabel.SetBounds(160, 116, 65, 13);
  FColorNoiseKeyLabel.Caption := 'Noise key';
  FColorNoiseKeyLabel.Parent := FColorGroupBox;

  FColorNoiseKeyIntEdit := TPegtopIntEdit.Create(Self);
  FColorNoiseKeyIntEdit.SetBounds(232, 112, 55, 21);
  FColorNoiseKeyIntEdit.Options := [pneFixLength];
  FColorNoiseKeyIntEdit.MinValue := 0;
  FColorNoiseKeyIntEdit.MaxValue := 999999;
  FColorNoiseKeyIntEdit.Parent := FColorGroupBox;
  FColorNoiseKeyIntEdit.OnChange := ColorNoiseKeyIntEditChange;

  FColorNoiseKeyUpDown := TUpDown.Create(Self);
  FColorNoiseKeyUpDown.SetBounds(288, 110, 17, 25);
  FColorNoiseKeyUpDown.Wrap := True;
  FColorNoiseKeyUpDown.Parent := FColorGroupBox;
  FColorNoiseKeyUpDown.Position := 1; // must not equal Min or Max
  FColorNoiseKeyUpDown.OnChangingEx := ColorNoiseKeyUpDownChangingEx;

  // color noise RGB range controls:
  FColorNoiseRedRangeBar := TPegtopRangeBar.Create(Self);
  FColorNoiseRedRangeBar.SetBounds(160, 136, 144, 20);
  FColorNoiseRedRangeBar.LabelOptions := [];
  FColorNoiseRedRangeBar.Min := 0;
  FColorNoiseRedRangeBar.Max := 255;
  FColorNoiseRedRangeBar.Parent := FColorGroupBox;
  FColorNoiseRedRangeBar.LabelOptions := [ploHint];
  FColorNoiseRedRangeBar.LabelCaption := 'Red range: <min> - <max>';
  FColorNoiseRedRangeBar.Tag := 0;
  FColorNoiseRedRangeBar.OnChange := ColorNoiseRGBRangeBarChange;
  FColorNoiseRedRangeBar.OnDrawTrack := ColorNoiseRGBRangeBarDrawTrack;

  FColorNoiseGreenRangeBar := TPegtopRangeBar.Create(Self);
  FColorNoiseGreenRangeBar.SetBounds(160, 156, 144, 20);
  FColorNoiseGreenRangeBar.LabelOptions := [];
  FColorNoiseGreenRangeBar.Min := 0;
  FColorNoiseGreenRangeBar.Max := 255;
  FColorNoiseGreenRangeBar.Parent := FColorGroupBox;
  FColorNoiseGreenRangeBar.LabelOptions := [ploHint];
  FColorNoiseGreenRangeBar.LabelCaption := 'Green range: <min> - <max>';
  FColorNoiseGreenRangeBar.Tag := 1;
  FColorNoiseGreenRangeBar.OnChange := ColorNoiseRGBRangeBarChange;
  FColorNoiseGreenRangeBar.OnDrawTrack := ColorNoiseRGBRangeBarDrawTrack;

  FColorNoiseBlueRangeBar := TPegtopRangeBar.Create(Self);
  FColorNoiseBlueRangeBar.SetBounds(160, 176, 144, 20);
  FColorNoiseBlueRangeBar.LabelOptions := [];
  FColorNoiseBlueRangeBar.Min := 0;
  FColorNoiseBlueRangeBar.Max := 255;
  FColorNoiseBlueRangeBar.Parent := FColorGroupBox;
  FColorNoiseBlueRangeBar.LabelOptions := [ploHint];
  FColorNoiseBlueRangeBar.LabelCaption := 'Blue range: <min> - <max>';
  FColorNoiseBlueRangeBar.Tag := 2;
  FColorNoiseBlueRangeBar.OnChange := ColorNoiseRGBRangeBarChange;
  FColorNoiseBlueRangeBar.OnDrawTrack := ColorNoiseRGBRangeBarDrawTrack;

  // color noise HSB range controls:
  FColorNoiseHueAvgTrackBar := TPegtopTrackBar.Create(Self);
  FColorNoiseHueAvgTrackBar.SetBounds(160, 136, 144, 20);
  FColorNoiseHueAvgTrackBar.LabelOptions := [];
  FColorNoiseHueAvgTrackBar.Min := 0;
  FColorNoiseHueAvgTrackBar.Max := 360;
  FColorNoiseHueAvgTrackBar.Parent := FColorGroupBox;
  FColorNoiseHueAvgTrackBar.LabelOptions := [ploHint];
  FColorNoiseHueAvgTrackBar.LabelCaption := 'Average hue: <pos>�';
  FColorNoiseHueAvgTrackBar.Tag := 0;
  FColorNoiseHueAvgTrackBar.OnChange := ColorNoiseHSBRangeBarChange;
  FColorNoiseHueAvgTrackBar.OnDrawTrack := ColorNoiseHueRangeBarDrawTrack;

  FColorNoiseHueRangeTrackBar := TPegtopTrackBar.Create(Self);
  FColorNoiseHueRangeTrackBar.SetBounds(160, 156, 144, 20);
  FColorNoiseHueRangeTrackBar.LabelOptions := [];
  FColorNoiseHueRangeTrackBar.Min := 0;
  FColorNoiseHueRangeTrackBar.Max := 100;
  FColorNoiseHueRangeTrackBar.Parent := FColorGroupBox;
  FColorNoiseHueRangeTrackBar.LabelOptions := [ploHint];
  FColorNoiseHueRangeTrackBar.LabelCaption := 'Hue range: <pos> %';
  FColorNoiseHueRangeTrackBar.Tag := 1;
  FColorNoiseHueRangeTrackBar.OnChange := ColorNoiseHSBRangeBarChange;
  FColorNoiseHueRangeTrackBar.OnDrawTrack := ColorNoiseHueRangeBarDrawTrack;

  FColorNoiseSaturationRangeBar := TPegtopRangeBar.Create(Self);
  FColorNoiseSaturationRangeBar.SetBounds(160, 176, 144, 20);
  FColorNoiseSaturationRangeBar.LabelOptions := [];
  FColorNoiseSaturationRangeBar.Min := 0;
  FColorNoiseSaturationRangeBar.Max := 100;
  FColorNoiseSaturationRangeBar.Parent := FColorGroupBox;
  FColorNoiseSaturationRangeBar.LabelOptions := [ploHint];
  FColorNoiseSaturationRangeBar.LabelCaption := 'Saturation range: <min> - <max> %';
  FColorNoiseSaturationRangeBar.Tag := 2;
  FColorNoiseSaturationRangeBar.OnChange := ColorNoiseHSBRangeBarChange;
  FColorNoiseSaturationRangeBar.OnDrawTrack := ColorNoiseSBRangeBarDrawTrack;

  FColorNoiseBrightnessRangeBar := TPegtopRangeBar.Create(Self);
  FColorNoiseBrightnessRangeBar.SetBounds(160, 196, 144, 20);
  FColorNoiseBrightnessRangeBar.LabelOptions := [];
  FColorNoiseBrightnessRangeBar.Min := 0;
  FColorNoiseBrightnessRangeBar.Max := 100;
  FColorNoiseBrightnessRangeBar.Parent := FColorGroupBox;
  FColorNoiseBrightnessRangeBar.LabelOptions := [ploHint];
  FColorNoiseBrightnessRangeBar.LabelCaption := 'Brightness range: <min> - <max> %';
  FColorNoiseBrightnessRangeBar.Tag := 3;
  FColorNoiseBrightnessRangeBar.OnChange := ColorNoiseHSBRangeBarChange;
  FColorNoiseBrightnessRangeBar.OnDrawTrack := ColorNoiseSBRangeBarDrawTrack;

  // color key controls:
  FColorKeyHeaderLabel := TLabel.Create(Self);
  FColorKeyHeaderLabel.SetBounds(312, 60, 144, 13);
  FColorKeyHeaderLabel.Caption := 'Selected color key';
  FColorKeyHeaderLabel.Parent := FColorGroupBox;
  FColorKeyHeaderLabel.Font.Style := [fsBold];

  FColorKeyColorBox := TPegtopColorBox.Create(Self);
  FColorKeyColorBox.SetBounds(312, 76, 144, 30);
  FColorKeyColorBox.Caption := 'Key color';
  FColorKeyColorBox.Parent := FColorGroupBox;
  FColorKeyColorBox.OnChange := ColorKeyColorBoxChange;
  FColorKeyColorBox.OnPreview := ColorKeyColorBoxPreview;

  FColorKeyLocationLabel := TLabel.Create(Self);
  FColorKeyLocationLabel.SetBounds(312, 116, 65, 13);
  FColorKeyLocationLabel.Caption := 'Location';
  FColorKeyLocationLabel.Parent := FColorGroupBox;

  FColorKeyLocationFloatEdit := TPegtopFloatEdit.Create(Self);
  FColorKeyLocationFloatEdit.SetBounds(384, 112, 73, 21);
  FColorKeyLocationFloatEdit.Parent := FColorGroupBox;
  FColorKeyLocationFloatEdit.Caption := ' %';
  FColorKeyLocationFloatEdit.CaptionAlignment := pcaRight;
  FColorKeyLocationFloatEdit.Options := [pneFixLength];
  FColorKeyLocationFloatEdit.MinValue := 0;
  FColorKeyLocationFloatEdit.MaxValue := 100;
  FColorKeyLocationFloatEdit.Digits := 1;
  FColorKeyLocationFloatEdit.OnChange := ColorKeyLocationFloatEditChange;

  FColorKeyDeleteButton := TButton.Create(Self);
  FColorKeyDeleteButton.SetBounds(312, 136, 144, 25);
  FColorKeyDeleteButton.Caption := 'Delete key';
  FColorKeyDeleteButton.Parent := FColorGroupBox;
  FColorKeyDeleteButton.OnClick := ColorKeyDeleteButtonClick;

  // opacity group box:
  if not (pgoIgnoreOpacity in FGradientOptions) then begin
    FOpacityGroupBox := TGroupBox.Create(Self);
    FOpacityGroupBox.SetBounds(8 + ManagerWidth, 260, 465, 213);
    FOpacityGroupBox.Caption := 'Opacity';
    FOpacityGroupBox.Parent := Self;

    // opacity gradient control:
    FOpacityGradientBar := TPegtopOpacityGradientBar.Create(Self);
    FOpacityGradientBar.SetBounds(8, 16, 448, 41);
    FOpacityGradientBar.Parent := FOpacityGroupBox;
    FOpacityGradientBar.OnFocusKeyModify := OpacityGradientBarFocusKeyModify;
    FOpacityGradientBar.OnScroll := OpacityGradientBarScroll;
    FOpacityGradientBar.OnGradientChange := ColorGradientChange;

    // opacity gradient settings controls:
    with TLabel.Create(Self) do begin
      SetBounds(8, 60, 144, 13);
      Caption := 'Gradient settings';
      Parent := FOpacityGroupBox;
      Font.Style := [fsBold];
    end;

    FOpacityFrequencyTrackBar := TPegtopTrackBar.Create(Self);
    FOpacityFrequencyTrackBar.SetBounds(8, 76, 144, 32);
    FOpacityFrequencyTrackBar.LabelCaption := 'Frequency: <pos>';
    FOpacityFrequencyTrackBar.Parent := FOpacityGroupBox;
    FOpacityFrequencyTrackBar.Min := 1;
    FOpacityFrequencyTrackBar.Max := 10;
    FOpacityFrequencyTrackBar.OnChange := OpacityFrequencyTrackBarChange;

    FOpacitySmoothnessTrackBar := TPegtopTrackBar.Create(Self);
    FOpacitySmoothnessTrackBar.SetBounds(8, 108, 144, 32);
    FOpacitySmoothnessTrackBar.LabelCaption := 'Smoothness: <pos> %';
    FOpacitySmoothnessTrackBar.Parent := FOpacityGroupBox;
    FOpacitySmoothnessTrackBar.DefaultPosition := 100;
    FOpacitySmoothnessTrackBar.OnChange := OpacitySmoothnessTrackBarChange;
    FOpacitySmoothnessTrackBar.OnLabel := SmoothnessTrackBarLabel;

    FOpacityNoiseStrengthTrackBar := TPegtopTrackBar.Create(Self);
    FOpacityNoiseStrengthTrackBar.SetBounds(8, 140, 144, 32);
    FOpacityNoiseStrengthTrackBar.LabelCaption := 'Noise strength: <pos> %';
    FOpacityNoiseStrengthTrackBar.Parent := FOpacityGroupBox;
    FOpacityNoiseStrengthTrackBar.OnChange := OpacityNoiseStrengthTrackBarChange;
    FOpacityNoiseStrengthTrackBar.DefaultPosition := 0;

    FOpacityNoiseFrequencyTrackBar := TPegtopTrackBar.Create(Self);
    FOpacityNoiseFrequencyTrackBar.SetBounds(8, 172, 144, 32);
    FOpacityNoiseFrequencyTrackBar.LabelCaption := 'Noise frequency: <pos>';
    FOpacityNoiseFrequencyTrackBar.Parent := FOpacityGroupBox;
    FOpacityNoiseFrequencyTrackBar.Min := 1;
    FOpacityNoiseFrequencyTrackBar.Max := 10;
    FOpacityNoiseFrequencyTrackBar.DefaultPosition := 2;
    FOpacityNoiseFrequencyTrackBar.OnChange := OpacityNoiseFrequencyTrackBarChange;

    // opacity noise settings controls:
    FOpacityNoiseHeaderLabel := TLabel.Create(Self);
    FOpacityNoiseHeaderLabel.SetBounds(160, 60, 144, 13);
    FOpacityNoiseHeaderLabel.Caption := 'Noise settings';
    FOpacityNoiseHeaderLabel.Parent := FOpacityGroupBox;
    FOpacityNoiseHeaderLabel.Font.Style := [fsBold];

    FOpacityNoiseRoughnessTrackBar := TPegtopTrackBar.Create(Self);
    FOpacityNoiseRoughnessTrackBar.SetBounds(160, 76, 144, 32);
    FOpacityNoiseRoughnessTrackBar.LabelCaption := 'Noise roughness: <pos> %';
    FOpacityNoiseRoughnessTrackBar.Parent := FOpacityGroupBox;
    FOpacityNoiseRoughnessTrackBar.OnChange := OpacityNoiseRoughnessTrackBarChange;
    FOpacityNoiseRoughnessTrackBar.DefaultPosition := 50;

    FOpacityNoiseKeyLabel := TLabel.Create(Self);
    FOpacityNoiseKeyLabel.SetBounds(160, 116, 65, 13);
    FOpacityNoiseKeyLabel.Caption := 'Noise key';
    FOpacityNoiseKeyLabel.Parent := FOpacityGroupBox;

    FOpacityNoiseKeyIntEdit := TPegtopIntEdit.Create(Self);
    FOpacityNoiseKeyIntEdit.SetBounds(232, 112, 55, 21);
    FOpacityNoiseKeyIntEdit.Options := [pneFixLength];
    FOpacityNoiseKeyIntEdit.MinValue := 0;
    FOpacityNoiseKeyIntEdit.MaxValue := 999999;
    FOpacityNoiseKeyIntEdit.Parent := FOpacityGroupBox;
    FOpacityNoiseKeyIntEdit.OnChange := OpacityNoiseKeyIntEditChange;

    FOpacityNoiseKeyUpDown := TUpDown.Create(Self);
    FOpacityNoiseKeyUpDown.SetBounds(288, 110, 17, 25);
    FOpacityNoiseKeyUpDown.Wrap := True;
    FOpacityNoiseKeyUpDown.Parent := FOpacityGroupBox;
    FOpacityNoiseKeyUpDown.Position := 1; // must not equal Min or Max
    FOpacityNoiseKeyUpDown.OnChangingEx := OpacityNoiseKeyUpDownChangingEx;

    FOpacityNoiseOpacityRangeBar := TPegtopRangeBar.Create(Self);
    FOpacityNoiseOpacityRangeBar.SetBounds(160, 140, 144, 32);
    FOpacityNoiseOpacityRangeBar.LabelCaption := 'Opacity range: <min> - <max> %';
    FOpacityNoiseOpacityRangeBar.Min := 0;
    FOpacityNoiseOpacityRangeBar.Max := 100;
    FOpacityNoiseOpacityRangeBar.LabelOptions := [ploVisible];
    FOpacityNoiseOpacityRangeBar.Parent := FOpacityGroupBox;
    FOpacityNoiseOpacityRangeBar.OnChange := OpacityNoiseOpacityRangeBarChange;
    FOpacityNoiseOpacityRangeBar.OnDrawTrack := OpacityNoiseOpacityRangeBarDrawTrack;

    // opacity key controls:
    FOpacityKeyHeaderLabel := TLabel.Create(Self);
    FOpacityKeyHeaderLabel.SetBounds(312, 60, 144, 13);
    FOpacityKeyHeaderLabel.Caption := 'Selected opacity key';
    FOpacityKeyHeaderLabel.Parent := FOpacityGroupBox;
    FOpacityKeyHeaderLabel.Font.Style := [fsBold];

    FOpacityKeyOpacityTrackBar := TPegtopTrackBar.Create(Self);
    FOpacityKeyOpacityTrackBar.SetBounds(312, 76, 144, 32);
    FOpacityKeyOpacityTrackBar.LabelCaption := 'Key opacity: <pos> %';
    FOpacityKeyOpacityTrackBar.Parent := FOpacityGroupBox;
    FOpacityKeyOpacityTrackBar.OnChange := OpacityKeyOpacityTrackBarChange;
    FOpacityKeyOpacityTrackBar.DefaultPosition := 100;

    FOpacityKeyLocationLabel := TLabel.Create(Self);
    FOpacityKeyLocationLabel.SetBounds(312, 116, 65, 13);
    FOpacityKeyLocationLabel.Caption := 'Location';
    FOpacityKeyLocationLabel.Parent := FOpacityGroupBox;

    FOpacityKeyLocationFloatEdit := TPegtopFloatEdit.Create(Self);
    FOpacityKeyLocationFloatEdit.SetBounds(384, 112, 73, 21);
    FOpacityKeyLocationFloatEdit.Parent := FOpacityGroupBox;
    FOpacityKeyLocationFloatEdit.Caption := ' %';
    FOpacityKeyLocationFloatEdit.CaptionAlignment := pcaRight;
    FOpacityKeyLocationFloatEdit.Options := [pneFixLength];
    FOpacityKeyLocationFloatEdit.MinValue := 0;
    FOpacityKeyLocationFloatEdit.MaxValue := 100;
    FOpacityKeyLocationFloatEdit.Digits := 1;
    FOpacityKeyLocationFloatEdit.OnChange := OpacityKeyLocationFloatEditChange;

    FOpacityKeyDeleteButton := TButton.Create(Self);
    FOpacityKeyDeleteButton.SetBounds(312, 136, 144, 25);
    FOpacityKeyDeleteButton.Caption := 'Delete key';
    FOpacityKeyDeleteButton.Parent := FOpacityGroupBox;
    FOpacityKeyDeleteButton.OnClick := OpacityKeyDeleteButtonClick;
  end;

  // buttons:
{  with TButton.Create(Self) do begin
    SetBounds(128 + ManagerWidth, 260 + OpacityHeight, 80, 25);
    Caption := 'Open...';
    Parent := Self;
  end;

  with TButton.Create(Self) do begin
    SetBounds(216 + ManagerWidth, 260 + OpacityHeight, 80, 25);
    Caption := 'Save as...';
    Parent := Self;
  end;}

  with TButton.Create(Self) do begin
    SetBounds(304 + ManagerWidth, 260 + OpacityHeight, 80, 25);
    Caption := PegtopColorGradientDialogOkCaption;
    ModalResult := mrOk;
    Default := True;
    Parent := Self;
  end;

  with TButton.Create(Self) do begin
    SetBounds(392 + ManagerWidth, 260 + OpacityHeight, 80, 25);
    Caption := PegtopColorGradientDialogCancelCaption;
    ModalResult := mrCancel;
    Cancel := True;
    Parent := Self;
  end;

  // color gradient manager:
  if Assigned(FGradientLibrary) then begin
    FManager := TPegtopColorGradientManager.Create(Self);
    FManager.SetBounds(8, 8, ManagerWidth - 8, 244 + OpacityHeight);
    FManager.Parent := Self;
    FManager.GradientLibrary := FGradientLibrary;
    FManager.GradientLibraryIndex := FGradientLibraryIndex;
    FManager.OnApply := ManagerApply;
    FManager.OnAddNew := ManagerAddNew;
  end;
end;

procedure TPegtopColorGradientForm.BeforeDestruction;
begin
  // disable event handlers
  // (might trigger some objects already destroyed otherwise):
  FColorGradientBar.OnFocusKeyChange := NIL;
  if Assigned(FOpacityGradientBar) then FOpacityGradientBar.OnFocusKeyChange := NIL;
  FGradient.Free;
  inherited;
end;

procedure TPegtopColorGradientForm.Init;
begin
  CreateControls;
  FColorGradientBar.GradientHook := FGradient;
  FColorGradientBar.Look := FLook;
  FColorKeyColorBox.Look := FLook;
  FColorGradientBar.OnFocusKeyChange := ColorGradientBarFocusKeyChange;
  if Assigned(FOpacityGradientBar) then begin
    FOpacityGradientBar.GradientHook := FGradient;
    FOpacityGradientBar.Look := FLook;
    FOpacityGradientBar.OnFocusKeyChange := OpacityGradientBarFocusKeyChange;
  end;
  ColorGradientChange(NIL);
end;

procedure TPegtopColorGradientForm.DeInit;
begin
  if Assigned(FGradientLibrary) then begin
    FGradientLibrary.Items.SaveAll;
  end;
end;

procedure TPegtopColorGradientForm.UpdateColorFocusKey;
var
  IsFocus: Boolean;
begin
  IsFocus := (FGradient.Color.Noise.Strength < 256)
    and (FColorGradientBar.FocusKey <> NIL);
  FColorKeyHeaderLabel.Enabled := IsFocus;
  FColorKeyColorBox.Enabled := IsFocus;
  FColorKeyLocationLabel.Enabled := IsFocus;
  FColorKeyLocationFloatEdit.Enabled := IsFocus;
  FColorKeyDeleteButton.Enabled := IsFocus
    and (FGradient.Color.Keys.Count > FColorGradientBar.MinCount);
  if FColorGradientBar.FocusKey <> NIL then begin
    FColorKeyColorBox.Color := FColorGradientBar.FocusKey.Color;
    FColorKeyLocationFloatEdit.Value := FColorGradientBar.FocusKey.Position * 0.1;
  end;
end;

procedure TPegtopColorGradientForm.UpdateOpacityFocusKey;
var
  IsFocus: Boolean;
begin
  IsFocus := (FGradient.Opacity.Noise.Strength < 256)
    and (FOpacityGradientBar.FocusKey <> NIL);
  FOpacityKeyHeaderLabel.Enabled := IsFocus;
  FOpacityKeyLocationLabel.Enabled := IsFocus;
  FOpacityKeyOpacityTrackBar.Enabled := IsFocus;
  FOpacityKeyLocationFloatEdit.Enabled := IsFocus;
  FOpacityKeyDeleteButton.Enabled := IsFocus
    and (FGradient.Opacity.Keys.Count > FOpacityGradientBar.MinCount);
  if FOpacityGradientBar.FocusKey <> NIL then begin
    FOpacityKeyOpacityTrackBar.Position := Round(FOpacityGradientBar.FocusKey.Opacity * 100 / 256);
    FOpacityKeyLocationFloatEdit.Value := FOpacityGradientBar.FocusKey.Position * 0.1;
  end;
end;

procedure TPegtopColorGradientForm.UpdateColorNoiseVisibility;
begin
  if FGradient.Color.Mode = pgmHSB then begin
    // avoid flickering by showing controls before hiding controls
    FColorNoiseHueAvgTrackBar.Visible := True;
    FColorNoiseHueRangeTrackBar.Visible := True;
    FColorNoiseSaturationRangeBar.Visible := True;
    FColorNoiseBrightnessRangeBar.Visible := True;
    FColorNoiseRedRangeBar.Visible := False;
    FColorNoiseGreenRangeBar.Visible := False;
    FColorNoiseBlueRangeBar.Visible := False;
  end
  else begin
    // avoid flickering by showing controls before hiding controls
    FColorNoiseRedRangeBar.Visible := True;
    FColorNoiseGreenRangeBar.Visible := True;
    FColorNoiseBlueRangeBar.Visible := True;
    FColorNoiseHueAvgTrackBar.Visible := False;
    FColorNoiseHueRangeTrackBar.Visible := False;
    FColorNoiseSaturationRangeBar.Visible := False;
    FColorNoiseBrightnessRangeBar.Visible := False;
  end;
end;

procedure TPegtopColorGradientForm.ColorGradientChange(Sender: TObject);
begin
  if not FUpdating then begin
    FNameEdit.Text := FGradient.Name;
    FModeComboBox.ItemIndex := Ord(FGradient.Color.Mode);
    FSeamlessCheckBox.Change(FGradient.Seamless);
    FColorSmoothnessTrackBar.Position := Round(FGradient.Color.Smoothness * 100 / 256);
    FColorFrequencyTrackBar.Position := FGradient.Color.Frequency;
    FColorNoiseStrengthTrackBar.Position := Round(FGradient.Color.Noise.Strength * 100 / 256);
    TriggerColorNoiseStrengthChange;
    FColorNoiseFrequencyTrackBar.Position := FGradient.Color.Noise.Frequency;
    FColorNoiseRoughnessTrackBar.Position := Round(FGradient.Color.Noise.Roughness * 100 / 256);
    FColorNoiseKeyIntEdit.Value := FGradient.Color.Noise.RandomKey;
    FColorNoiseRedRangeBar.PositionMin := FGradient.Color.Noise.RedMin;
    FColorNoiseRedRangeBar.PositionMax := FGradient.Color.Noise.RedMax;
    FColorNoiseGreenRangeBar.PositionMin := FGradient.Color.Noise.GreenMin;
    FColorNoiseGreenRangeBar.PositionMax := FGradient.Color.Noise.GreenMax;
    FColorNoiseBlueRangeBar.PositionMin := FGradient.Color.Noise.BlueMin;
    FColorNoiseBlueRangeBar.PositionMax := FGradient.Color.Noise.BlueMax;
    FColorNoiseHueAvgTrackBar.Position := Round(FGradient.Color.Noise.HueAvg * 360 / 65536);
    FColorNoiseHueRangeTrackBar.Position := Round(FGradient.Color.Noise.HueRange * 100 / 65536);
    FColorNoiseSaturationRangeBar.PositionMin := Round(FGradient.Color.Noise.SaturationMin * 100 / 65536);
    FColorNoiseSaturationRangeBar.PositionMax := Round(FGradient.Color.Noise.SaturationMax * 100 / 65536);
    FColorNoiseBrightnessRangeBar.PositionMin := Round(FGradient.Color.Noise.BrightnessMin * 100 / 65536);
    FColorNoiseBrightnessRangeBar.PositionMax := Round(FGradient.Color.Noise.BrightnessMax * 100 / 65536);
    UpdateColorFocusKey;
    if not (pgoIgnoreOpacity in FGradientOptions) then begin
      FOpacityFrequencyTrackBar.Position := FGradient.Opacity.Frequency;
      FOpacityNoiseStrengthTrackBar.Position := Round(FGradient.Opacity.Noise.Strength * 100 / 256);
      TriggerOpacityNoiseStrengthChange;
      FOpacitySmoothnessTrackBar.Position := Round(FGradient.Opacity.Smoothness * 100 / 256);
      FOpacityNoiseFrequencyTrackBar.Position := FGradient.Opacity.Noise.Frequency;
      FOpacityNoiseRoughnessTrackBar.Position := Round(FGradient.Opacity.Noise.Roughness * 100 / 256);
      FOpacityNoiseKeyIntEdit.Value := FGradient.Opacity.Noise.RandomKey;
      FOpacityNoiseOpacityRangeBar.PositionMin := Round(FGradient.Opacity.Noise.OpacityMin * 100 / 256);
      FOpacityNoiseOpacityRangeBar.PositionMax := Round(FGradient.Opacity.Noise.OpacityMax * 100 / 256);
      UpdateOpacityFocusKey;
    end;
    UpdateColorNoiseVisibility;
  end;
  if Assigned(FOnPreview) then FOnPreview(Self, FGradient);
end;

procedure TPegtopColorGradientForm.NameEditChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Name := FNameEdit.Text;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.ModeComboBoxClick(Sender: TObject);
begin
  if (FModeComboBox.ItemIndex >= Ord(Low(TPegtopColorGradientMode)))
  and (FModeComboBox.ItemIndex <= Ord(High(TPegtopColorGradientMode))) then begin
    FUpdating := True;
    try
      FGradient.Color.Mode := TPegtopColorGradientMode(FModeComboBox.ItemIndex);
      UpdateColorNoiseVisibility;
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.SeamlessCheckBoxClick(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Seamless := FSeamlessCheckBox.Checked;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.ColorGradientBarFocusKeyChange(Sender: Tobject);
begin
  UpdateColorFocusKey;
end;

procedure TPegtopColorGradientForm.ColorGradientBarFocusKeyModify(Sender: Tobject);
begin
  if FColorGradientBar.FocusKey <> NIL then begin
    FColorKeyColorBox.Color := FColorGradientBar.FocusKey.Color;
  end;
end;

procedure TPegtopColorGradientForm.ColorGradientBarScroll(Sender: TObject;
  ScrollCode: TPegtopScrollCode; var ScrollPos: Integer);
begin
  FColorKeyLocationFloatEdit.Value := ScrollPos * 0.1;
end;

procedure TPegtopColorGradientForm.ColorSmoothnessTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Color.Smoothness := Round(FColorSmoothnessTrackBar.Position * 256 / 100);
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.ColorFrequencyTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Color.Frequency := FColorFrequencyTrackBar.Position;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.ColorNoiseStrengthTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Color.Noise.Strength := Round(FColorNoiseStrengthTrackBar.Position * 256 / 100);
  finally
    FUpdating := False;
  end;
  TriggerColorNoiseStrengthChange;
end;

procedure TPegtopColorGradientForm.TriggerColorNoiseStrengthChange;
var
  HasNoise: Boolean;
  HasKeys: Boolean;
begin
  HasNoise := FGradient.Color.Noise.Strength > 0;
  HasKeys := FGradient.Color.Noise.Strength < 256;
  FColorGradientBar.BarEnabled := HasKeys;
  FColorFrequencyTrackBar.Enabled := HasKeys;
  FColorSmoothnessTrackBar.Enabled := HasKeys;
  FColorNoiseHeaderLabel.Enabled := HasNoise;
  FColorNoiseFrequencyTrackBar.Enabled := HasNoise;
  FColorNoiseRoughnessTrackBar.Enabled := HasNoise;
  FColorNoiseKeyLabel.Enabled := HasNoise;
  FColorNoiseKeyIntEdit.Enabled := HasNoise;
  FColorNoiseKeyUpDown.Enabled := HasNoise;
  FColorNoiseRedRangeBar.Enabled := HasNoise;
  FColorNoiseGreenRangeBar.Enabled := HasNoise;
  FColorNoiseBlueRangeBar.Enabled := HasNoise;
  FColorNoiseHueAvgTrackBar.Enabled := HasNoise;
  FColorNoiseHueRangeTrackBar.Enabled := HasNoise;
  FColorNoiseSaturationRangeBar.Enabled := HasNoise;
  FColorNoiseBrightnessRangeBar.Enabled := HasNoise;
  UpdateColorFocusKey;
end;

procedure TPegtopColorGradientForm.ColorNoiseFrequencyTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Color.Noise.Frequency := FColorNoiseFrequencyTrackBar.Position;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.ColorNoiseRoughnessTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Color.Noise.Roughness := Round(FColorNoiseRoughnessTrackBar.Position * 256 / 100);
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.ColorNoiseKeyIntEditChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Color.Noise.RandomKey := FColorNoiseKeyIntEdit.Value;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.ColorNoiseKeyUpDownChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
var
  N: Longword;
  T: Int64;
begin
  if Direction <> updNone then begin
    N := FColorNoiseKeyIntEdit.Value;
    if Direction = updUp then begin
      T := (N + 1000000 - 904261) mod 1000000;
      T := (993461 * T) mod 1000000;
      FColorNoiseKeyIntEdit.Value := T;
    end
    else begin
      FColorNoiseKeyIntEdit.Value := (N * 2141 + 904261) mod 1000000;
    end;
    FUpdating := True;
    try
      FGradient.Color.Noise.RandomKey := FColorNoiseKeyIntEdit.Value;
    finally
      FUpdating := False;
    end;
  end;
  AllowChange := False;
end;

procedure TPegtopColorGradientForm.ColorNoiseRGBRangeBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.BeginUpdate;
    try
      FGradient.Color.Noise.RedMin := FColorNoiseRedRangeBar.PositionMin;
      FGradient.Color.Noise.RedMax := FColorNoiseRedRangeBar.PositionMax;
      FGradient.Color.Noise.GreenMin := FColorNoiseGreenRangeBar.PositionMin;
      FGradient.Color.Noise.GreenMax := FColorNoiseGreenRangeBar.PositionMax;
      FGradient.Color.Noise.BlueMin := FColorNoiseBlueRangeBar.PositionMin;
      FGradient.Color.Noise.BlueMax := FColorNoiseBlueRangeBar.PositionMax;
    finally
      FGradient.EndUpdate;
    end;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.ColorNoiseHSBRangeBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.BeginUpdate;
    try
      FGradient.Color.Noise.HueAvg := Round(FColorNoiseHueAvgTrackBar.Position * 65536 / 360);
      FGradient.Color.Noise.HueRange := Round(FColorNoiseHueRangeTrackBar.Position * 65536 / 100);
      FGradient.Color.Noise.SaturationMin := Round(FColorNoiseSaturationRangeBar.PositionMin * 65536 / 100);
      FGradient.Color.Noise.SaturationMax := Round(FColorNoiseSaturationRangeBar.PositionMax * 65536 / 100);
      FGradient.Color.Noise.BrightnessMin := Round(FColorNoiseBrightnessRangeBar.PositionMin * 65536 / 100);
      FGradient.Color.Noise.BrightnessMax := Round(FColorNoiseBrightnessRangeBar.PositionMax * 65536 / 100);
    finally
      FGradient.EndUpdate;
    end;
  finally
    FUpdating := False;
  end;
  if Sender = FColorNoiseHueAvgTrackBar then begin
    FColorNoiseHueRangeTrackBar.Invalidate;
    FColorNoiseSaturationRangeBar.Invalidate;
    FColorNoiseBrightnessRangeBar.Invalidate;
  end;
end;

procedure TPegtopColorGradientForm.ColorNoiseRGBRangeBarDrawTrack(Sender: TObject; Canvas: TCanvas; Orientation: TPegtopSlideBarOrientation; BoundsRect: TRect; Center: TPoint);
const
  Shades = 32;
  LeftColors: array[0..2] of TColor = (clRed, clGreen, clBlue);
  RightColors: array[0..2] of TColor = (clBtnFace, clBtnFace, clBtnFace);
var
  I: Integer;
  C1, C2: TPegtopColor;
begin
  if TPegtopSlideBar(Sender).Enabled then begin
    C1 := TPegtopColor(ColorToRGB(LeftColors[TComponent(Sender).Tag]));
    C2 := TPegtopColor(ColorToRGB(RightColors[TComponent(Sender).Tag]));
    Canvas.Brush.Style := bsSolid;
    for I := 0 to Shades - 1 do begin
      Canvas.Brush.Color := TColor(MixColors(PegtopColor(ColorToRGB(clBtnFace)), PegtopColor($000000), I * 256 div (Shades - 1)));
      Canvas.FillRect(Rect(
        BoundsRect.Left + 1 + I * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y - 2,
        BoundsRect.Left + 1 + (I + 1) * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y - 1
      ));
      Canvas.FillRect(Rect(
        BoundsRect.Left + 1 + I * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y + 2,
        BoundsRect.Left + 1 + (I + 1) * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y + 3
      ));
      Canvas.Brush.Color := TColor(MixColors(C2, C1, I * 256 div (Shades - 1)));
      Canvas.FillRect(Rect(
        BoundsRect.Left + 1 + I * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y - 1,
        BoundsRect.Left + 1 + (I + 1) * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y + 2
      ));
    end;
    Canvas.Brush.Color := $000000;
    Canvas.FillRect(Rect(
      BoundsRect.Right - 2,
      Center.Y - 1,
      BoundsRect.Right - 1,
      Center.Y + 2
    ));
  end
  else begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clBtnShadow;
    Canvas.Rectangle(
      BoundsRect.Left + 1,
      Center.Y - 2,
      BoundsRect.Right - 1,
      Center.Y + 3
    );
  end;
end;

procedure TPegtopColorGradientForm.ColorNoiseHueRangeBarDrawTrack(Sender: TObject; Canvas: TCanvas; Orientation: TPegtopSlideBarOrientation; BoundsRect: TRect; Center: TPoint);
const
  Shades = 32;
var
  I: Integer;
  H1, H2: Integer;
begin
  if TPegtopSlideBar(Sender).Enabled then begin
    case TComponent(Sender).Tag of
      1:
        begin
          H1 := FGradient.Color.Noise.HueAvg - FGradient.Color.Noise.HueRange div 2;
          H2 := FGradient.Color.Noise.HueAvg + FGradient.Color.Noise.HueRange div 2;
        end;
      else
        begin
          H1 := 0;
          H2 := Hue360;
        end;
    end;
    Canvas.Brush.Style := bsSolid;
    for I := 0 to Shades - 1 do begin
      Canvas.Brush.Color := TColor(SwapColorBytes(GetSaturatedColor(H1 + I * (H2 - H1) div Shades)));
      Canvas.FillRect(Rect(
        BoundsRect.Left + 1 + I * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y - 1,
        BoundsRect.Left + 1 + (I + 1) * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y + 2
      ));
    end;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := $000000;
    Canvas.Rectangle(
      BoundsRect.Left + 1,
      Center.Y - 2,
      BoundsRect.Right - 1,
      Center.Y + 3
    );
  end
  else begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clBtnShadow;
    Canvas.Rectangle(
      BoundsRect.Left + 1,
      Center.Y - 2,
      BoundsRect.Right - 1,
      Center.Y + 3
    );
  end;
end;

procedure TPegtopColorGradientForm.ColorNoiseSBRangeBarDrawTrack(Sender: TObject; Canvas: TCanvas; Orientation: TPegtopSlideBarOrientation; BoundsRect: TRect; Center: TPoint);
const
  Shades = 32;
var
  I: Integer;
  C1, C2: TPegtopColor;
begin
  if TPegtopSlideBar(Sender).Enabled then begin
    case TComponent(Sender).Tag of
      2:
        begin
          C1 := SwapColorBytes(ConvertHSBToColor(FGradient.Color.Noise.HueAvg, 0, Bri100));
          C2 := SwapColorBytes(ConvertHSBToColor(FGradient.Color.Noise.HueAvg, Sat100, Bri100));
        end;
      3:
        begin
          C1 := SwapColorBytes(ConvertHSBToColor(FGradient.Color.Noise.HueAvg, Sat100, 0));
          C2 := SwapColorBytes(ConvertHSBToColor(FGradient.Color.Noise.HueAvg, Sat100, Bri100));
        end;
      else
        begin
          C1 := PegtopColor($000000);
          C2 := PegtopColor($FFFFFF);
        end;
    end;
    Canvas.Brush.Style := bsSolid;
    for I := 0 to Shades - 1 do begin
      Canvas.Brush.Color := TColor(MixColors(C1, C2, I * 256 div (Shades - 1)));
      Canvas.FillRect(Rect(
        BoundsRect.Left + 1 + I * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y - 1,
        BoundsRect.Left + 1 + (I + 1) * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y + 2
      ));
    end;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := $000000;
    Canvas.Rectangle(
      BoundsRect.Left + 1,
      Center.Y - 2,
      BoundsRect.Right - 1,
      Center.Y + 3
    );
  end
  else begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clBtnShadow;
    Canvas.Rectangle(
      BoundsRect.Left + 1,
      Center.Y - 2,
      BoundsRect.Right - 1,
      Center.Y + 3
    );
  end;
end;

procedure TPegtopColorGradientForm.SmoothnessTrackBarLabel(Sender: TObject; var Caption: String);
begin
  if TPegtopTrackBar(Sender).Position = 0 then Caption := 'Linear interpolation';
end;

procedure TPegtopColorGradientForm.ColorKeyColorBoxChange(Sender: TObject);
begin
  if FColorGradientBar.FocusKey <> NIL then begin
    FUpdating := True;
    try
      FColorGradientBar.FocusKey.Color := FColorKeyColorBox.Color;
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.ColorKeyColorBoxPreview(Sender: TObject; Color: TColor);
begin
  if FColorGradientBar.FocusKey <> NIL then begin
    FUpdating := True;
    try
      FColorGradientBar.FocusKey.Color := Color;
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.ColorKeyLocationFloatEditChange(Sender: TObject);
begin
  if FColorGradientBar.FocusKey <> NIL then begin
    FUpdating := True;
    try
      FColorGradientBar.FocusKey.Position := Round(FColorKeyLocationFloatEdit.Value * 10.0);
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.ColorKeyDeleteButtonClick(Sender: TObject);
begin
  if (FColorGradientBar.FocusKey <> NIL)
  and (FGradient.Color.Keys.Count > FColorGradientBar.MinCount) then begin
    FUpdating := True;
    try
      FGradient.Color.Keys.Remove(FColorGradientBar.FocusKey);
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.OpacityGradientBarScroll(Sender: TObject;
  ScrollCode: TPegtopScrollCode; var ScrollPos: Integer);
begin
  FUpdating := True;
  try
    FOpacityKeyLocationFloatEdit.Value := ScrollPos * 0.1;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.OpacitySmoothnessTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Opacity.Smoothness := Round(FOpacitySmoothnessTrackBar.Position * 256 / 100);
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.OpacityFrequencyTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Opacity.Frequency := FOpacityFrequencyTrackBar.Position;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.OpacityNoiseStrengthTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Opacity.Noise.Strength := Round(FOpacityNoiseStrengthTrackBar.Position * 256 / 100);
  finally
    FUpdating := False;
  end;
  TriggerOpacityNoiseStrengthChange;
end;

procedure TPegtopColorGradientForm.TriggerOpacityNoiseStrengthChange;
var
  HasNoise: Boolean;
  HasKeys: Boolean;
begin
  HasNoise := FGradient.Opacity.Noise.Strength > 0;
  HasKeys := FGradient.Opacity.Noise.Strength < 256;
  FOpacityGradientBar.BarEnabled := HasKeys;
  FOpacityFrequencyTrackBar.Enabled := HasKeys;
  FOpacitySmoothnessTrackBar.Enabled := HasKeys;
  FOpacityNoiseHeaderLabel.Enabled := HasNoise;
  FOpacityNoiseFrequencyTrackBar.Enabled := HasNoise;
  FOpacityNoiseRoughnessTrackBar.Enabled := HasNoise;
  FOpacityNoiseKeyLabel.Enabled := HasNoise;
  FOpacityNoiseKeyIntEdit.Enabled := HasNoise;
  FOpacityNoiseKeyUpDown.Enabled := HasNoise;
  FOpacityNoiseOpacityRangeBar.Enabled := HasNoise;
  UpdateOpacityFocusKey;
end;

procedure TPegtopColorGradientForm.OpacityNoiseFrequencyTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Opacity.Noise.Frequency := FOpacityNoiseFrequencyTrackBar.Position;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.OpacityNoiseRoughnessTrackBarChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Opacity.Noise.Roughness := Round(FOpacityNoiseRoughnessTrackBar.Position * 256 / 100);
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.OpacityNoiseKeyIntEditChange(Sender: TObject);
begin
  FUpdating := True;
  try
    FGradient.Opacity.Noise.RandomKey := FOpacityNoiseKeyIntEdit.Value;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.OpacityNoiseKeyUpDownChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
var
  N: Longword;
  T: Int64;
begin
  if Direction <> updNone then begin
    N := FOpacityNoiseKeyIntEdit.Value;
    if Direction = updUp then begin
      T := (N + 1000000 - 904261) mod 1000000;
      T := (993461 * T) mod 1000000;
      FOpacityNoiseKeyIntEdit.Value := T;
    end
    else begin
      FOpacityNoiseKeyIntEdit.Value := (N * 2141 + 904261) mod 1000000;
    end;
    FUpdating := True;
    try
      FGradient.Opacity.Noise.RandomKey := FOpacityNoiseKeyIntEdit.Value;
    finally
      FUpdating := False;
    end;
  end;
  AllowChange := False;
end;

procedure TPegtopColorGradientForm.OpacityNoiseOpacityRangeBarChange(Sender: TOBject);
begin
  FUpdating := True;
  try
    FGradient.BeginUpdate;
    try
      FGradient.Opacity.Noise.OpacityMin := Round(FOpacityNoiseOpacityRangeBar.PositionMin * 256 / 100);
      FGradient.Opacity.Noise.OpacityMax := Round(FOpacityNoiseOpacityRangeBar.PositionMax * 256 / 100);
    finally
      FGradient.EndUpdate;
    end;
  finally
    FUpdating := False;
  end;
end;

procedure TPegtopColorGradientForm.OpacityNoiseOpacityRangeBarDrawTrack(Sender: TObject; Canvas: TCanvas; Orientation: TPegtopSlideBarOrientation; BoundsRect: TRect; Center: TPoint);
const
  Shades = 32;
var
  I: Integer;
begin
  if TPegtopSlideBar(Sender).Enabled then begin
    Canvas.Brush.Style := bsSolid;
    for I := 0 to Shades - 1 do begin
      Canvas.Brush.Color := TColor(MixColors(PegtopColor(ColorToRGB(clBtnFace)), PegtopColor($000000), I * 256 div (Shades - 1)));
      Canvas.FillRect(Rect(
        BoundsRect.Left + 1 + I * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y - 2,
        BoundsRect.Left + 1 + (I + 1) * (BoundsRect.Right - BoundsRect.Left - 2) div Shades,
        Center.Y + 3
      ));
    end;
    Canvas.Brush.Color := $000000;
    Canvas.FillRect(Rect(
      BoundsRect.Right - 2,
      Center.Y - 1,
      BoundsRect.Right - 1,
      Center.Y + 2
    ));
  end
  else begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clBtnShadow;
    Canvas.Rectangle(
      BoundsRect.Left + 1,
      Center.Y - 2,
      BoundsRect.Right - 1,
      Center.Y + 3
    );
  end;
end;

procedure TPegtopColorGradientForm.OpacityGradientBarFocusKeyChange(Sender: Tobject);
begin
  UpdateOpacityFocusKey;
end;

procedure TPegtopColorGradientForm.OpacityGradientBarFocusKeyModify(Sender: Tobject);
begin
  if FOpacityGradientBar.FocusKey <> NIL then begin
    FUpdating := True;
    try
      FOpacityKeyOpacityTrackBar.Position := Round(FOpacityGradientBar.FocusKey.Opacity * 100 / 256);
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.OpacityKeyOpacityTrackBarChange(Sender: TObject);
begin
  if FOpacityGradientBar.FocusKey <> NIL then begin
    FUpdating := True;
    try
      FOpacityGradientBar.FocusKey.Opacity := Round(FOpacityKeyOpacityTrackBar.Position * 256 / 100);
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.OpacityKeyLocationFloatEditChange(Sender: TObject);
begin
  if FOpacityGradientBar.FocusKey <> NIL then begin
    FUpdating := True;
    try
      FOpacityGradientBar.FocusKey.Position := Round(FOpacityKeyLocationFloatEdit.Value * 10.0);
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.OpacityKeyDeleteButtonClick(Sender: TObject);
begin
  if (FOpacityGradientBar.FocusKey <> NIL)
  and (FGradient.Opacity.Keys.Count > FOpacityGradientBar.MinCount) then begin
    FUpdating := True;
    try
      FGradient.Opacity.Keys.Remove(FOpacityGradientBar.FocusKey);
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TPegtopColorGradientForm.ManagerApply(Sender: TObject);
var
  SelectedGradient: TPegtopCustomColorGradient;
begin
  SelectedGradient := FManager.Selected;
  if Assigned(SelectedGradient) then begin
    FGradient.Assign(SelectedGradient);
  end;
end;

procedure TPegtopColorGradientForm.ManagerAddNew(Sender: TObject; NewGradient: TPegtopCustomColorGradient);
begin
  NewGradient.Assign(FGradient);
end;

////////////////////////////////////////////////////////////////////////////////
// TPegtopColorGradientDialog
////////////////////////////////////////////////////////////////////////////////

constructor TPegtopColorGradientDialog.Create(AOwner: TComponent);
begin
  inherited;
  FInternalGradient := TPegtopColorGradient.Create([clBlack, clWhite]);
  FGradient := FInternalGradient;
  FLook := pclRoundedRect;
end;

destructor TPegtopColorGradientDialog.Destroy;
begin
  FInternalGradient.Free;
  inherited;
end;

function TPegtopColorGradientDialog.Execute: Boolean;
var
  Form: TPegtopColorGradientForm;
begin
  Form := TPegtopColorGradientForm.CreateNew(Application);
  try
    Form.Gradient.Assign(FGradient);
    Form.GradientLibrary := FGradientLibrary;
    Form.GradientLibraryIndex := FGradientLibraryIndex;
    Form.Look := FLook;
    Form.GradientOptions := FGradientOptions;
    Form.OnPreview := FormPreview;
    if FCaption <> '' then
      Form.Caption := FCaption
    else
      Form.Caption := PegtopColorGradientDialogDefaultCaption;
    Form.Init;
    try
      Result := Form.ShowModal = mrOk;
    finally
      Form.DeInit;
    end;
    if Result then begin
      FGradient.Assign(Form.Gradient);
    end;
  finally
    Form.Free;
  end;
end;

procedure TPegtopColorGradientDialog.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FGradientLibrary) then begin
    FGradientLibrary := NIL;
  end;
end;

procedure TPegtopColorGradientDialog.FormPreview(Sender: TObject; ColorGradient: TPegtopCustomColorGradient);
begin
  if Assigned(FOnPreview) then FOnPreview(Self, ColorGradient);
end;

procedure TPegtopColorGradientDialog.SetGradient(Value: TPegtopCustomColorGradient);
begin
  FGradient.Assign(Value);
end;

procedure TPegtopColorGradientDialog.SetGradientHook(Value: TPegtopCustomColorGradient);
begin
  if Value = NIL then Value := FInternalGradient;
  if FGradient <> Value then begin
    FGradient := Value;
  end;
end;

procedure TPegtopColorGradientDialog.SetGradientLibrary(Value: TPegtopCustomColorGradientLibrary);
begin
  if FGradientLibrary <> Value then begin
    if Assigned(FGradientLibrary) then begin
      FGradientLibrary.RemoveFreeNotification(Self);
    end;
    FGradientLibrary := Value;
    if Assigned(FGradientLibrary) then begin
      // if FGradientLibrary.Items.Count > 0 then FGradientLibraryIndex := 0 else FGradientLibraryIndex := -1;
      FGradientLibrary.FreeNotification(Self);
    end;
  end;
end;

procedure TPegtopColorGradientDialog.SetGradientLibraryIndex(Value: Integer);
begin
  if Value < -1 then Value := -1;
  // else if FGradientLibrary = NIL then Value := -1
  // else if Value > FGradientLibrary.Items.Count - 1 then Value := FGradientLibrary.Items.Count - 1;
  if FGradientLibraryIndex <> Value then begin
    FGradientLibraryIndex := Value;
  end;
end;

end.

