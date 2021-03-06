unit InfraFamilyRepository;

interface

uses
  SysUtils,
  SynCommons,
  mORMot,
  mORMotDDD,
  mORMotDB,
  SynSQLite3,
  mORMotSQLite3,
  SynTable, // for TSynValidate*, TSynFilter*
  SynTests,

  DomMotherCQRS,
  DomFatherCQRS,
  DomSonCQRS,
  DomFamilyCQRS,
  DomFamilyInterfaces,
  DomFamilyServices,
  DomFamilyTypes,

  InfraFamilyTypes,
  InfraMotherRepository,
  InfraFatherRepository,
  InfraSonRepository;


type

  /// ORM class corresponding to TFamily DDD aggregate
  TSQLRecordFamily = class(TSQLRecord)
  protected
    fFamilyName: RawUTF8; // TFamilyName

         // TMother
    fMother_IdNumber: Int64; //TMotherIdNumber
    fMother_Name: RawUTF8; // TMotherName

         // TFather
    fFather_IdNumber: Int64; // TFatherIdNumber
    fFather_Name: RawUTF8; // TFatherName

         // TSon
    fSon_IdNumber: Int64; // TSonIdNumber
    fSon_Name: RawUTF8; // TSonName
    fSon_Mother_IdNumber: Int64; // TMotherIdNumber
    fSon_Mother_Name: RawUTF8; // TMotherName
    fSon_Father_IdNumber: Int64; // TFatherIdNumber
    fSon_Father_Name: RawUTF8; // TFatherName

  published
    /// maps TFamily.FamilyName (TFamilyName)
    property FamilyName: RawUTF8 read fFamilyName write fFamilyName stored AS_UNIQUE;

    /// maps TFamily.Mother.IdNumber (TMotherIdNumber)
    property Mother_IdNumber: Int64 read fMother_IdNumber write fMother_IdNumber;
    /// maps TFamily.Mother.Name (TMotherName)
    property Mother_Name: RawUTF8 read fMother_Name write fMother_Name;

    /// maps TFamily.Father.IdNumber (TFatherIdNumber)
    property Father_IdNumber: Int64 read fFather_IdNumber write fFather_IdNumber;
    /// maps TFamily.Father.Name (TFatherName)
    property Father_Name: RawUTF8 read fFather_Name write fFather_Name;

    /// maps TFamily.Son.IdNumber (TSonIdNumber)
    property Son_IdNumber: Int64 read fSon_IdNumber write fSon_IdNumber;
    /// maps TFamily.Son.Name (TSonName)
    property Son_Name: RawUTF8 read fSon_Name write fSon_Name;

    /// maps TFamily.Son.Mother.IdNumber (TMotherIdNumber)
    property Son_Mother_IdNumber: Int64 read fSon_Mother_IdNumber write fSon_Mother_IdNumber;
    /// maps TFamily.Son.Mother.Name (TMotherName)
    property Son_Mother_Name: RawUTF8 read fSon_Mother_Name write fSon_Mother_Name;

    /// maps TFamily.Son.Father.IdNumber (TFatherIdNumber)
    property Son_Father_IdNumber: Int64 read fSon_Father_IdNumber write fSon_Father_IdNumber;
    /// maps TFamily.Son.Father.Name (TFatherName)
    property Son_Father_Name: RawUTF8 read fSon_Father_Name write fSon_Father_Name;
  end;

  TInfraRepoFamily = class(TDDDRepositoryRestCommand, IDomFamilyQuery, IDomFamilyCommand)
  public
    function SelectAllByFamilyName(const aFamilyName: TFamilyName): TCQRSResult;
    function SelectAllByMotherIdNumber(const aMotherIdNumber: TMotherIdNumber): TCQRSResult;
    function SelectAll: TCQRSResult;
    function Get(out aAggregate: TFamily): TCQRSResult;
    function GetAll(out aAggregates: TFamilyObjArray): TCQRSResult;
    function GetNext(out aAggregate: TFamily): TCQRSResult;
//    function GetCount: Integer;
    function Add(const aAggregate: TFamily): TCQRSResult;
    function Update(const aUpdatedAggregate: TFamily): TCQRSResult;
//    function Delete: TCQRSResult;
//    function DeleteAll: TCQRSResult;
//    function Commit: TCQRSResult;
//    function Rollback: TCQRSResult;
  end;

  TInfraRepoFamilyFactory = class(TDDDRepositoryRestFactory)
  private
    class procedure TestOne(test: TSynTestCase; Rest: TSQLRest);
    class procedure TestOneNested(test: TSynTestCase; Rest: TSQLRest);
  public
    constructor Create(aRest: TSQLRest; aOwner: TDDDRepositoryRestManager=nil); reintroduce;
    class procedure RegressionTests(test: TSynTestCase);
    class procedure RegressionTestsToSQLite3(test: TSynTestCase; infraNested : boolean);

  end;

implementation

{ TInfraRepoFamily }

function TInfraRepoFamily.Add(const aAggregate: TFamily): TCQRSResult;
begin
  Result := ORMAdd(aAggregate);
end;

function TInfraRepoFamily.Get(out aAggregate: TFamily): TCQRSResult;
begin
  Result := ORMGetAggregate(aAggregate);
end;

function TInfraRepoFamily.GetAll(out aAggregates: TFamilyObjArray): TCQRSResult;
begin
  Result := ORMGetAllAggregates(aAggregates);
end;

function TInfraRepoFamily.GetNext(out aAggregate: TFamily): TCQRSResult;
begin
  Result := ORMGetNextAggregate(aAggregate);
end;

function TInfraRepoFamily.SelectAll: TCQRSResult;
begin
  Result := ORMSelectAll('', []);
end;

function TInfraRepoFamily.SelectAllByFamilyName(const aFamilyName: TFamilyName): TCQRSResult;
begin
  Result := ORMSelectAll('FamilyName=?', [aFamilyName], (''=aFamilyName));
end;

function TInfraRepoFamily.SelectAllByMotherIdNumber(const aMotherIdNumber: TMotherIdNumber): TCQRSResult;
begin
  Result := ORMSelectAll('Mother_IdNumber=?', [aMotherIdNumber], (aMotherIdNumber<1));
end;

function TInfraRepoFamily.Update(const aUpdatedAggregate: TFamily): TCQRSResult;
begin
  Result := ORMUpdate(aUpdatedAggregate);
end;

{ TInfraRepoFamilyFactory }

constructor TInfraRepoFamilyFactory.Create(aRest: TSQLRest;
  aOwner: TDDDRepositoryRestManager);
begin
  inherited Create(IDomFamilyCommand,TInfraRepoFamily,TFamily,aRest,TSQLRecordFamily,aOwner);
  AddFilterOrValidate(['*'], TSynFilterTrim.Create);
  AddFilterOrValidate(['FamilyName'],TSynValidateNonVoidText.Create);
end;

class procedure TInfraRepoFamilyFactory.TestOne(test: TSynTestCase; Rest: TSQLRest);
const
  //MAX = 1000;
  MAX = MAX_INFRA_RTESTS_LOOP;
var
  cmd: IDomFamilyCommand;
  //qry: IDomFamilyQuery;
  entity: TFamily;

  entity2: TMother;
  entity3: TFather;
  entity4: TSon;

  entitys: TFamilyObjArray;
  i: Integer;
  //entityCount: Integer;
  iText: RawUTF8;
  aCQRSRes : TCQRSResult;
begin
  with test do
  begin
    entity := TFamily.Create;

    entity2 := TMother.Create;
    entity3 := TFather.Create;
    entity4 := TSon.Create;

    Check(Rest.Services.Resolve(IDomFamilyCommand, cmd));
    try
      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i,iText);
        entity.FamilyName := 'Family' + iText;

        entity2.IdNumber := i;
        entity2.Name := 'Mother' + iText;

        entity3.IdNumber := i;
        entity3.Name := 'Father' + iText;

        entity4.IdNumber := i;
        entity4.Name := 'Son' + iText;
        entity4.AssignParents(entity2,entity3);
        entity.AssignMembers(entity2,entity3,entity4);
        aCQRSRes := cmd.Add(entity);
        Check(cqrsSuccess = aCQRSRes);
      end;
      Check(cqrsSuccess = cmd.Commit);

      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i, iText);
        Check(cqrsSuccess = cmd.SelectAllByFamilyName('Family' + iText));
        Check(1 = cmd.GetCount);
        Check(cqrsSuccess = cmd.GetNext(entity));
        Check('Family'+iText = entity.FamilyName);
      end;

      Check(cqrsSuccess = cmd.SelectAll());
      Check(MAX = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetAll(entitys));
      Check(MAX = high(entitys)+1 );

      Check(cqrsSuccess = cmd.SelectAllByFamilyName('Family1'));
      Check(1 = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetNext(entity));

      entity.FamilyName := 'Hello1';
      Check(cqrsSuccess = cmd.Update(entity));
      Check(cqrsSuccess = cmd.Commit);
    finally
      ObjArrayClear(entitys);
      entity2.Free;
      entity3.Free;
      entity4.Free;
      entity.Free;
    end;
  end;
end;

class procedure TInfraRepoFamilyFactory.TestOneNested(test: TSynTestCase; Rest: TSQLRest);
const
  //MAX = 1000;
  MAX = MAX_INFRA_RTESTS_LOOP;
var
  cmd: IDomFamilyCommand;
  cmd2: IDomMotherCommand;
  cmd3: IDomFatherCommand;
  cmd4: IDomSonCommand;
  //qry: IDomFamilyQuery;
  entity: TFamily;

  entity2: TMother;
  entity3: TFather;
  entity4: TSon;

  entitys: TFamilyObjArray;
  i: Integer;
  //entityCount: Integer;
  iText: RawUTF8;
  aPrefix: RawUTF8;
  aCQRSRes : TCQRSResult;
  aChecked : Boolean;
  aMotherIdNumber: Cardinal;
  aMotherName: RawUTF8;

  aFamMng :IFamilyManager;

begin
  with test do
  begin
    entity := TFamily.Create;

    entity2 := TMother.Create;
    entity3 := TFather.Create;
    entity4 := TSon.Create;

    Check(Rest.Services.Resolve(IDomFamilyCommand, cmd));
    Check(Rest.Services.Resolve(IDomMotherCommand, cmd2));
    Check(Rest.Services.Resolve(IDomFatherCommand, cmd3));
    Check(Rest.Services.Resolve(IDomSonCommand, cmd4));
    try
      aPrefix:='Hello';
      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i,iText);
        entity.FamilyName := 'Family' + iText;

           // Get Son
        Check(cqrsSuccess = cmd4.SelectAllBySonName(aPrefix+'Son'+iText));
        Check(1 = cmd4.GetCount);
        Check(cqrsSuccess = cmd4.GetNext(entity4));

        entity4.Mother.Assign( entity2 );
        entity4.Father.Assign( entity3 );

        entity.AssignMembers(entity2,entity3,entity4);
        aCQRSRes := cmd.Add(entity);
        Check(cqrsSuccess = aCQRSRes);

        if aPrefix<>''
          then aPrefix:='';
      end;
      Check(cqrsSuccess = cmd.Commit);

      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i, iText);
        Check(cqrsSuccess = cmd.SelectAllByFamilyName('Family' + iText));
        Check(1 = cmd.GetCount);
        Check(cqrsSuccess = cmd.GetNext(entity));
        Check('Family'+iText = entity.FamilyName);
      end;

      Check(cqrsSuccess = cmd.SelectAll());
      Check(MAX = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetAll(entitys));
      Check(MAX = high(entitys)+1 );

      Check(cqrsSuccess = cmd.SelectAllByFamilyName('Family1'));
      Check(1 = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetNext(entity));

      entity.FamilyName := 'HelloFamily1';
      Check(cqrsSuccess = cmd.Update(entity));
      Check(cqrsSuccess = cmd.Commit);

               /// Business Logic
      aFamMng := TFamilyManager.Create( cmd2,cmd3,cmd4,cmd );
      for i := 1 to MAX do begin
        UInt32ToUtf8(i, iText);
        aChecked := aFamMng.ChangeMothersName( i, 'MotherName'+iText+'Changes');
        Check(aChecked);
      end;

    finally
      ObjArrayClear(entitys);
      entity2.Free;
      entity3.Free;
      entity4.Free;
      entity.Free;
    end;
  end;
end;

class procedure TInfraRepoFamilyFactory.RegressionTests(test: TSynTestCase);
var
  RestServer: TSQLRestServerFullMemory;
  RestClient: TSQLRestClientURI;
begin
  RestServer := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordFamily]);
  try // first try directly on server side
    RestServer.ServiceContainer.InjectResolver([TInfraRepoFamilyFactory.Create(RestServer)],true);
    TestOne(test,RestServer); // sub function will ensure that all I*Command are released
  finally
    RestServer.Free;
  end;
  RestServer := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordFamily]);
  try // then try from a client-server process
    RestServer.ServiceContainer.InjectResolver([TInfraRepoFamilyFactory.Create(RestServer)],true);
    RestServer.ServiceDefine(TInfraRepoFamily,[IDomFamilyCommand,IDomFamilyQuery],sicClientDriven);
    test.Check(RestServer.ExportServer);
    RestClient := TSQLRestClientURIDll.Create(TSQLModel.Create(RestServer.Model),@URIRequest);
    try
      RestClient.Model.Owner := RestClient;
      RestClient.ServiceDefine([IDomFamilyCommand],sicClientDriven);
      TestOne(test,RestServer);
      RestServer.DropDatabase;
      USEFASTMM4ALLOC := true; // for slightly faster process
      TestOne(test,RestClient);
    finally
      RestClient.Free;
    end;
  finally
    RestServer.Free;
  end;
end;

class procedure TInfraRepoFamilyFactory.RegressionTestsToSQLite3(test: TSynTestCase; infraNested : boolean);
var
  aStore: TSynConnectionDefinition;
  RestServer: TSQLRest;
  aSQLite3DBFile: String;
begin

  aSQLite3DBFile := SQLITE3_DBTESTFILE;

  // use a local SQlite3 database file
  aStore := TSynConnectionDefinition.CreateFromJSON(StringToUtf8(
              '{	"Kind": "TSQLRestServerDB", '+
                '"ServerName": "'+aSQLite3DBFile+'"' +
              '}'));

  if infraNested
    then RestServer := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordMother,TSQLRecordFather,TSQLRecordSon,TSQLRecordFamily]), aStore, false, [])
    else RestServer := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordFamily]), aStore, false, []);

  RestServer.Model.Owner := RestServer;
  try

    if RestServer is TSQLRestServerDB then
      with TSQLRestServerDB(RestServer) do begin // may be a client in settings :)
        DB.Synchronous := smOff; // faster exclusive access to the file
        DB.LockingMode := lmExclusive;
        CreateMissingTables;     // will create the tables, if necessary
      end;

    RestServer.ServiceContainer.InjectResolver([TInfraRepoFamilyFactory.Create(RestServer)],true);

    if infraNested then begin
      RestServer.ServiceContainer.InjectResolver([TInfraRepoMotherFactory.Create(RestServer)],true);
      RestServer.ServiceContainer.InjectResolver([TInfraRepoFatherFactory.Create(RestServer)],true);
      RestServer.ServiceContainer.InjectResolver([TInfraRepoSonFactory.Create(RestServer)],true);

      if RestServer is TSQLRestServerDB then
        TSQLRestServerDB(RestServer).ServiceDefine(TFamilyManager,[IFamilyManager],sicClientDriven);

    end;

    if not infraNested
      then TestOne(test,RestServer)  // sub function will ensure that all I*Command are released
      else TestOneNested(test,RestServer); // sub function will ensure that all I*Command are released

  finally
    aStore.Free;
    RestServer.Free;
  end;

end;

initialization
//  TDDDRepositoryRestFactory.ComputeSQLRecord([TMother, TFather, TSon, TFamily]); //from mORMotDDD

end.

