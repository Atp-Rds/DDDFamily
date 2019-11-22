unit DomFatherCQRS;

interface

uses
  SynCommons,
  mORMot,
  mORMotDDD,

  DomFamilyTypes;

type

  IDomFatherQuery = interface(ICQRSService)
   ['{4BC1173D-923A-4069-B58E-F1933971045A}']
    function SelectAllByFatherIdNumber(const aFatherIdNumber: TFatherIdNumber): TCQRSResult;
    function SelectAllByFatherName(const aFatherName: TFatherName): TCQRSResult;
    function SelectAll: TCQRSResult;
    function Get(out aAggregate: TFather): TCQRSResult;
    function GetAll(out aAggretates: TFatherObjArray): TCQRSResult;
    function GetNext(out aAggregate: TFather): TCQRSResult;
    function GetCount: Integer;
  end;

  IDomFatherCommand = interface(IDomFatherQuery)
   ['{2FD8B4B3-0594-4127-9F97-F07CD645D387}']
    function Add(const aAggregate: TFather): TCQRSResult;
    function Update(const aUpdatedAggregate: TFather): TCQRSResult;
    function Delete: TCQRSResult;
    function DeleteAll: TCQRSResult;
    function Commit: TCQRSResult;
    function Rollback: TCQRSResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IDomFatherQuery), TypeInfo(IDomFatherCommand)]);

end.

