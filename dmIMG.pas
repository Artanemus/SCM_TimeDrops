unit dmIMG;

interface

uses
  System.SysUtils, System.Classes, System.ImageList,
  Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection;

type
  TIMG = class(TDataModule)
    imgcolDT: TImageCollection;
    vimglistDTEvent: TVirtualImageList;
    vimglistDTGrid: TVirtualImageList;
    vimglistMenu: TVirtualImageList;
    vimglistTreeView: TVirtualImageList;
    vimglistStateImages: TVirtualImageList;
    vimglistDTCell: TVirtualImageList;
    VirtualImageList1: TVirtualImageList;
    ImageCollection2: TImageCollection;
  private
    { Private declarations }
    fIMGIsactive: boolean;
  public
    { Public declarations }
    procedure ActivateDataIMG();  //---
    procedure DeActivateDataIMG();  //---

  end;

var
  IMG: TIMG;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TAppData }

procedure TIMG.ActivateDataIMG;
begin
  fIMGIsactive := false;
end;

procedure TIMG.DeActivateDataIMG;
begin
  fIMGIsactive := false;
end;

end.
