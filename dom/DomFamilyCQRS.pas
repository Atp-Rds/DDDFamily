unit DomFamilyCQRS;

interface

uses
  mORMot,
  mORMotDDD,

  DomFamilyTypes;

type

  IDomFamilyQuery = interface(ICQRSService)
   ['{625008F8-FEE2-43F5-938D-4FE51F66A8AC}']
    function SelectAllByFamilyName(const aFamilyName: TFamilyName): TCQRSResult;
    function SelectAll: TCQRSResult;
    function Get(out aAggregate: TFamily): TCQRSResult;
    function GetAll(out aAggretates: TFamilyObjArray): TCQRSResult;
    function GetNext(out aAggregate: TFamily): TCQRSResult;
    function GetCount: Integer;
  end;

  IDomFamilyCommand = interface(IDomFamilyQuery)
   ['{D7FB27F3-7150-4A40-8775-8F58EED5A664}']
    function Add(const aAggregate: TFamily): TCQRSResult;
    function Update(const aUpdatedAggregate: TFamily): TCQRSResult;
    function Delete: TCQRSResult;
    function DeleteAll: TCQRSResult;
    function Commit: TCQRSResult;
    function Rollback: TCQRSResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IDomFamilyQuery), TypeInfo(IDomFamilyCommand)]);

end.

