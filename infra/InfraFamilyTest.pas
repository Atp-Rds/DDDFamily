unit InfraFamilyTest;

interface

uses
  SynTests,

  {$I Test.inc}
  InfraMotherRepository,
  InfraFatherRepository,
  InfraSonRepository,
  InfraFamilyRepository;


type

  TTestMotherInfraestructure = class(TSynTestCase)
  published
    procedure TestSelf;
  end;

  TTestFatherInfraestructure = class(TSynTestCase)
  published
    procedure TestSelf;
  end;

  TTestSonInfraestructure = class(TSynTestCase)
  published
    procedure TestSelf;
  end;

  TTestFamilyInfraestructure = class(TSynTestCase)
  published
    procedure TestSelf;
  end;

implementation

{ TTestMotherInfraestructure }

procedure TTestMotherInfraestructure.TestSelf;
begin
  TInfraRepoMotherFactory.RegressionTests(Self);

  {$ifdef INFRANESTEDTESTS}
  TInfraRepoMotherFactory.RegressionTestsToSQLite3(Self, True);
  {$else}
  TInfraRepoMotherFactory.RegressionTestsToSQLite3(Self, False);
  {$endif}
end;

{ TTestFatherInfraestructure }

procedure TTestFatherInfraestructure.TestSelf;
begin
  TInfraRepoFatherFactory.RegressionTests(Self);

  {$ifdef INFRANESTEDTESTS}
  TInfraRepoFatherFactory.RegressionTestsToSQLite3(Self, True);
  {$else}
  TInfraRepoFatherFactory.RegressionTestsToSQLite3(Self, False);
  {$endif}
end;


{ TTestSonInfraestructure }

procedure TTestSonInfraestructure.TestSelf;
begin
  TInfraRepoSonFactory.RegressionTests(Self);

  {$ifdef INFRANESTEDTESTS}
  TInfraRepoSonFactory.RegressionTestsToSQLite3(Self, True);
  {$else}
  TInfraRepoSonFactory.RegressionTestsToSQLite3(Self, False);
  {$endif}
end;

{ TTestFamilyInfraestructure }

procedure TTestFamilyInfraestructure.TestSelf;
begin
  TInfraRepoFamilyFactory.RegressionTests(Self);

  {$ifdef INFRANESTEDTESTS}
  TInfraRepoFamilyFactory.RegressionTestsToSQLite3(Self, True);
  {$else}
  TInfraRepoFamilyFactory.RegressionTestsToSQLite3(Self, False);
  {$endif}
end;


initialization
end.

