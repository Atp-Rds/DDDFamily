unit InfraFamilyTest;

interface

uses
  SynTests,

  {$I Test.inc}
  InfraSonRepository,
  InfraFamilyRepository;


type

  TTestFamilyInfraestructure = class(TSynTestCase)
  published
    procedure TestSelf;
  end;

  TTestSonInfraestructure = class(TSynTestCase)
  published
    procedure TestSelf;
  end;

implementation

{ TTestFamilyInfraestructure }

procedure TTestFamilyInfraestructure.TestSelf;
begin
  TInfraRepoFamilyFactory.RegressionTests(Self);

  {$ifdef INFRANESTEDTESTS}
  TInfraRepoFamilyFactory.RegressionTestsToSQLite3InfraNested(Self);
  {$else}
  TInfraRepoFamilyFactory.RegressionTestsToSQLite3(Self);
  {$endif}
end;

{ TTestSonInfraestructure }

procedure TTestSonInfraestructure.TestSelf;
begin
  TInfraRepoSonFactory.RegressionTests(Self);

  {$ifdef INFRANESTEDTESTS}
  TInfraRepoSonFactory.RegressionTestsToSQLite3InfraNested(Self);
  {$else}
  TInfraRepoSonFactory.RegressionTestsToSQLite3(Self);
  {$endif}
end;

initialization
end.

