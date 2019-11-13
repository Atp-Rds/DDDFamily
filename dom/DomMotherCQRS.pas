unit DomMotherCQRS;

interface

uses
  SynCommons,
  mORMot,
  mORMotDDD,

  DomFamilyTypes;

type

  IDomMotherQuery = interface(ICQRSService)
   ['{C1628902-A12C-4909-B4DC-E3722BF77040}']
    function SelectAllByMotherName(const aMotherName: TMotherName): TCQRSResult;
    function SelectAll: TCQRSResult;
    function Get(out aAggregate: TMother): TCQRSResult;
    function GetAll(out aAggretates: TMotherObjArray): TCQRSResult;
    function GetNext(out aAggregate: TMother): TCQRSResult;
    function GetCount: Integer;
  end;

  IDomMotherCommand = interface(IDomMotherQuery)
   ['{CEFB24E7-DEDF-44BA-A693-8E1C1C42FAE3}']
    function Add(const aAggregate: TMother): TCQRSResult;
    function Update(const aUpdatedAggregate: TMother): TCQRSResult;
    function Delete: TCQRSResult;
    function DeleteAll: TCQRSResult;
    function Commit: TCQRSResult;
    function Rollback: TCQRSResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IDomMotherQuery), TypeInfo(IDomMotherCommand)]);

end.

