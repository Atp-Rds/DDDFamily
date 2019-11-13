unit InfraSonRepository;

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

  DomSonCQRS,
  DomFamilyTypes,

  InfraFamilyTypes;

type

  /// ORM class corresponding to TSon DDD aggregate
  TSQLRecordSon = class(TSQLRecord)
  protected
    fName: RawUTF8; // TSonName
    fMother: RawUTF8; // TMotherName
    fFather: RawUTF8; // TFatherName
  published
    /// maps TSon.Name (TSonName)
    property Name: RawUTF8 read fName write fName;
    /// maps TSon.Mother.Name (TMotherName)
    property Mother: RawUTF8 read fMother write fMother;
    /// maps TSon.Father.Name (TFatherName)
    property Father: RawUTF8 read fFather write fFather;
  end;

  TInfraRepoSon = class(TDDDRepositoryRestCommand, IDomSonQuery, IDomSonCommand)
  public
    function SelectAllBySonName(const aSonName: TSonName): TCQRSResult;
    function SelectAll: TCQRSResult;
    function Get(out aAggregate: TSon): TCQRSResult;
    function GetAll(out aAggregates: TSonObjArray): TCQRSResult;
    function GetNext(out aAggregate: TSon): TCQRSResult;
//    function GetCount: Integer;
    function Add(const aAggregate: TSon): TCQRSResult;
    function Update(const aUpdatedAggregate: TSon): TCQRSResult;
//    function Delete: TCQRSResult;
//    function DeleteAll: TCQRSResult;
//    function Commit: TCQRSResult;
//    function Rollback: TCQRSResult;
  end;

  TInfraRepoSonFactory = class(TDDDRepositoryRestFactory)
  private
    class procedure TestOne(test: TSynTestCase; Rest: TSQLRest);
    class procedure TestOneNested(test: TSynTestCase; Rest: TSQLRest);
  public
    constructor Create(aRest: TSQLRest; aOwner: TDDDRepositoryRestManager=nil); reintroduce;
    class procedure RegressionTests(test: TSynTestCase);
    class procedure RegressionTestsToSQLite3(test: TSynTestCase);
    class procedure RegressionTestsToSQLite3InfraNested(test: TSynTestCase);
  end;

implementation

{ TInfraRepoSon }

function TInfraRepoSon.Add(const aAggregate: TSon): TCQRSResult;
begin
  Result := ORMAdd(aAggregate);
end;

function TInfraRepoSon.Get(out aAggregate: TSon): TCQRSResult;
begin
  Result := ORMGetAggregate(aAggregate);
end;

function TInfraRepoSon.GetAll(out aAggregates: TSonObjArray): TCQRSResult;
begin
  Result := ORMGetAllAggregates(aAggregates);
end;

function TInfraRepoSon.GetNext(out aAggregate: TSon): TCQRSResult;
begin
  Result := ORMGetNextAggregate(aAggregate);
end;

function TInfraRepoSon.SelectAll: TCQRSResult;
begin
  Result := ORMSelectAll('', []);
end;

function TInfraRepoSon.SelectAllBySonName(const aSonName: TSonName): TCQRSResult;
begin
  Result := ORMSelectAll('Name=?', [aSonName], (''=aSonName));
end;

function TInfraRepoSon.Update(const aUpdatedAggregate: TSon): TCQRSResult;
begin
  Result := ORMUpdate(aUpdatedAggregate);
end;

{ TInfraRepoSonFactory }

constructor TInfraRepoSonFactory.Create(aRest: TSQLRest; aOwner: TDDDRepositoryRestManager);
begin
  inherited Create(IDomSonCommand,TInfraRepoSon,TSon,aRest,TSQLRecordSon,aOwner);
  AddFilterOrValidate(['*'], TSynFilterTrim.Create);
  AddFilterOrValidate(['Name'],TSynValidateNonVoidText.Create);
end;

class procedure TInfraRepoSonFactory.TestOne(test: TSynTestCase; Rest: TSQLRest);
const
  //MAX = 1000;
  MAX = MAX_INFRA_RTESTS_LOOP;
var
  cmd: IDomSonCommand;
  //qry: IDomSonQuery;
  entity: TSon;
  entity2: TMother;
  entity3: TFather;
  entitys: TSonObjArray;
  i: Integer;
  //entityCount: Integer;
  iText: RawUTF8;
  aCQRSRes : TCQRSResult;

begin
  with test do
  begin
    entity := TSon.Create;

    entity2 := TMother.Create;
    entity3 := TFather.Create;

    Check(Rest.Services.Resolve(IDomSonCommand, cmd));
    try
      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i,iText);
        entity.Name := 'Son' + iText;
        entity2.Name := 'Mother' + iText;
        entity3.Name := 'Father' + iText;
        entity.AssignParents(entity2,entity3);
        Check(cqrsSuccess = cmd.Add(entity));
      end;
      aCQRSRes := cmd.Commit;
      Check(cqrsSuccess = aCQRSRes);


      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i, iText);
        aCQRSRes := cmd.SelectAllBySonName('Son' + iText);
        Check(cqrsSuccess = aCQRSRes );
        Check(1 = cmd.GetCount);
        Check(cqrsSuccess = cmd.GetNext(entity));
        Check('Son'+iText = entity.Name);
      end;

      Check(cqrsSuccess = cmd.SelectAll());
      Check(MAX = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetAll(entitys));
      Check(MAX = high(entitys)+1 );

      Check(cqrsSuccess = cmd.SelectAllBySonName('Son1'));
      Check(1 = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetNext(entity));

      entity.Name := 'hello';
      Check(cqrsSuccess = cmd.Update(entity));
      Check(cqrsSuccess = cmd.Commit);
    finally
      ObjArrayClear(entitys);
      entity2.Free;
      entity3.Free;
      entity.Free;
    end;
  end;
end;

class procedure TInfraRepoSonFactory.TestOneNested(test: TSynTestCase; Rest: TSQLRest);
const
  //MAX = 1000;
  MAX = MAX_INFRA_RTESTS_LOOP;
var
  cmd: IDomSonCommand;
  //qry: IDomSonQuery;
  entity: TSon;
  entity2: TMother;
  entity3: TFather;
  entitys: TSonObjArray;
  i: Integer;
  //entityCount: Integer;
  iText: RawUTF8;
  aCQRSRes : TCQRSResult;

begin
  with test do
  begin
    entity := TSon.Create;

    entity2 := TMother.Create;
    entity3 := TFather.Create;

    Check(Rest.Services.Resolve(IDomSonCommand, cmd));
    try
      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i,iText);
        entity.Name := 'Son' + iText;
        entity2.Name := 'Mother' + iText;
        entity3.Name := 'Father' + iText;
        entity.AssignParents(entity2,entity3);
        Check(cqrsSuccess = cmd.Add(entity));
      end;
      aCQRSRes := cmd.Commit;
      Check(cqrsSuccess = aCQRSRes);


      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i, iText);
        aCQRSRes := cmd.SelectAllBySonName('Son' + iText);
        Check(cqrsSuccess = aCQRSRes );
        Check(1 = cmd.GetCount);
        Check(cqrsSuccess = cmd.GetNext(entity));
        Check('Son'+iText = entity.Name);
      end;

      Check(cqrsSuccess = cmd.SelectAll());
      Check(MAX = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetAll(entitys));
      Check(MAX = high(entitys)+1 );

      Check(cqrsSuccess = cmd.SelectAllBySonName('Son1'));
      Check(1 = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetNext(entity));

      entity.Name := 'hello';
      Check(cqrsSuccess = cmd.Update(entity));
      Check(cqrsSuccess = cmd.Commit);
    finally
      ObjArrayClear(entitys);
      entity2.Free;
      entity3.Free;
      entity.Free;
    end;
  end;
end;

class procedure TInfraRepoSonFactory.RegressionTests(test: TSynTestCase);
var
  RestServer: TSQLRestServerFullMemory;
  RestClient: TSQLRestClientURI;
begin
  RestServer := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordSon]);
  try // first try directly on server side
    RestServer.ServiceContainer.InjectResolver([TInfraRepoSonFactory.Create(RestServer)],true);
    TestOne(test,RestServer); // sub function will ensure that all I*Command are released
  finally
    RestServer.Free;
  end;
  RestServer := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordSon]);
  try // then try from a client-server process
    RestServer.ServiceContainer.InjectResolver([TInfraRepoSonFactory.Create(RestServer)],true);
    RestServer.ServiceDefine(TInfraRepoSon,[IDomSonCommand,IDomSonQuery],sicClientDriven);
    test.Check(RestServer.ExportServer);
    RestClient := TSQLRestClientURIDll.Create(TSQLModel.Create(RestServer.Model),@URIRequest);
    try
      RestClient.Model.Owner := RestClient;
      RestClient.ServiceDefine([IDomSonCommand],sicClientDriven);
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

class procedure TInfraRepoSonFactory.RegressionTestsToSQLite3(test: TSynTestCase);
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

  RestServer := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordSon]), aStore, false, []);
  RestServer.Model.Owner := RestServer;
  try

    if RestServer is TSQLRestServerDB then
      with TSQLRestServerDB(RestServer) do begin // may be a client in settings :)
        DB.Synchronous := smOff; // faster exclusive access to the file
        DB.LockingMode := lmExclusive;
        CreateMissingTables;     // will create the tables, if necessary
      end;

    RestServer.ServiceContainer.InjectResolver([TInfraRepoSonFactory.Create(RestServer)],true);
    TestOne(test,RestServer); // sub function will ensure that all I*Command are released

  finally
    aStore.Free;
    RestServer.Free;
  end;

end;

class procedure TInfraRepoSonFactory.RegressionTestsToSQLite3InfraNested(test: TSynTestCase);
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

  RestServer := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordSon]), aStore, false, []);
  RestServer.Model.Owner := RestServer;
  try

    if RestServer is TSQLRestServerDB then
      with TSQLRestServerDB(RestServer) do begin // may be a client in settings :)
        DB.Synchronous := smOff; // faster exclusive access to the file
        DB.LockingMode := lmExclusive;
        CreateMissingTables;     // will create the tables, if necessary
      end;

    RestServer.ServiceContainer.InjectResolver([TInfraRepoSonFactory.Create(RestServer)],true);
    TestOneNested(test,RestServer); // sub function will ensure that all I*Command are released

  finally
    aStore.Free;
    RestServer.Free;
  end;

end;


initialization
//  TDDDRepositoryRestFactory.ComputeSQLRecord([TMother, TFather, TSon]); //from mORMotDDD

end.

