unit TestAllMain;

interface

uses
  SynTests,

  InfraFamilyTest;

type

  TTestAllMain = class(TSynTests)
  published
    procedure Infrastructure;
    procedure Domain;
  end;

implementation

{ TTestAllMain }

procedure TTestAllMain.Infrastructure;
begin
  AddCase([TTestMotherInfraestructure]);
  AddCase([TTestFatherInfraestructure]);
  AddCase([TTestSonInfraestructure]);
  AddCase([TTestFamilyInfraestructure]);
end;

procedure TTestAllMain.Domain;
begin

end;

initialization
end.

