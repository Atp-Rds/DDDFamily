unit DomFamilyInterfaces;

interface

uses
  SynCommons,
  mORMot,

  DomFamilyTypes;

type

  IFamilyManager = interface(IInvokable)
   ['{AB4A7C81-528B-4BB3-A3AC-2009B7B2088A}']
    function ChangeMothersName (const aMotherIdNumber: TMotherIdNumber; const aNewMotherName : TMotherName): Boolean;
  end;


implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IFamilyManager)
  ]);

end.

