unit DomSonCQRS;

interface

uses
  SynCommons,
  mORMot,
  mORMotDDD,

  DomFamilyTypes;

type

  IDomSonQuery = interface(ICQRSService)
   ['{2F68DD49-5D63-472A-B6E3-17F55278F2A7}']
    function SelectAllBySonName(const aSonName: TSonName): TCQRSResult;
    function SelectAll: TCQRSResult;
    function Get(out aAggregate: TSon): TCQRSResult;
    function GetAll(out aAggretates: TSonObjArray): TCQRSResult;
    function GetNext(out aAggregate: TSon): TCQRSResult;
    function GetCount: Integer;
  end;

  IDomSonCommand = interface(IDomSonQuery)
   ['{8CC36E54-6561-4E61-86A7-E7F922F5B61E}']
    function Add(const aAggregate: TSon): TCQRSResult;
    function Update(const aUpdatedAggregate: TSon): TCQRSResult;
    function Delete: TCQRSResult;
    function DeleteAll: TCQRSResult;
    function Commit: TCQRSResult;
    function Rollback: TCQRSResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IDomSonQuery), TypeInfo(IDomSonCommand)]);

end.

