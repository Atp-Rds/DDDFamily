program DDDFamilyTest;

{$APPTYPE CONSOLE}

uses
  {$I SynDprUses.inc} // includes FastMM4
  SysUtils,
  SynLog,
  mORMot,
  SynSQLite3Static,   // statically linked SQLite3 engine

  //Domain
  DomFamilyTypes in '..\dom\DomFamilyTypes.pas',
  DomMotherCQRS in '..\dom\DomMotherCQRS.pas',
  DomFatherCQRS in '..\dom\DomFatherCQRS.pas',
  DomSonCQRS in '..\dom\DomSonCQRS.pas',
  DomFamilyCQRS in '..\dom\DomFamilyCQRS.pas',

  //Infraestructure
  InfraFamilyTypes in '..\infra\InfraFamilyTypes.pas',
  InfraFamilyTest in '..\infra\InfraFamilyTest.pas',
  InfraMotherRepository in '..\infra\InfraMotherRepository.pas',
  InfraFatherRepository in '..\infra\InfraFatherRepository.pas',
  InfraSonRepository in '..\infra\InfraSonRepository.pas',
  InfraFamilyRepository in '..\infra\InfraFamilyRepository.pas',

  //Tests
  {$I Test.inc}
  TestAllMain in 'TestAllMain.pas';

begin
  {$ifdef ISDELPHI2007ANDUP}
  {$ifdef DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$endif}
  {$endif}


  {$ifdef DELETESQLITE3DBTESTFILE}
  DeleteFile(SQLITE3_DBTESTFILE);
  {$endif}

  TSynLogTestLog := TSQLLog; // share the same log file with the whole mORMot
  TTestAllMain.RunAsConsole('DDD Family Automated Tests',LOG_VERBOSE);
end.


//program DDDFamilyTest;
//
//{$APPTYPE CONSOLE}
//
//uses
//  {$I SynDprUses.inc} // includes FastMM4
//  SysUtils,
//  SynLog,
//  mORMot,
//  SynSQLite3Static,   // statically linked SQLite3 engine
//
//  //Domain
//  DomFamilyTypes in '..\dom\DomFamilyTypes.pas',
//  DomMotherCQRS in '..\dom\DomMotherCQRS.pas',
//  DomFatherCQRS in '..\dom\DomFatherCQRS.pas',
//  DomSonCQRS in '..\dom\DomSonCQRS.pas',
//  DomFamilyCQRS in '..\dom\DomFamilyCQRS.pas',
//
//  //Infraestructure
//  InfraFamilyTypes in '..\infra\InfraFamilyTypes.pas',
//  InfraFamilyTest in '..\infra\InfraFamilyTest.pas',
//  InfraMotherRepository in '..\infra\InfraMotherRepository.pas',
//  InfraFatherRepository in '..\infra\InfraFatherRepository.pas',
//  InfraSonRepository in '..\infra\InfraSonRepository.pas',
//  InfraFamilyRepository in '..\infra\InfraFamilyRepository.pas',
//
//  //Tests
//  {$I Test.inc}
//  TestAllMain in 'TestAllMain.pas';
//
//begin
//  {$ifdef ISDELPHI2007ANDUP}
//  {$ifdef DEBUG}
//  ReportMemoryLeaksOnShutdown := True;
//  {$endif}
//  {$endif}
//
//
//  {$ifdef DELETESQLITE3DBTESTFILE}
//  DeleteFile(SQLITE3_DBTESTFILE);
//  {$endif}
//
//  TSynLogTestLog := TSQLLog; // share the same log file with the whole mORMot
//  TTestAllMain.RunAsConsole('DDD Family Automated Tests',LOG_VERBOSE);
//end.


