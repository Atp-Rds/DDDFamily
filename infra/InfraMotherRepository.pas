unit InfraMotherRepository;

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
  DomFamilyTypes,

  InfraFamilyTypes;

type

  /// ORM class corresponding to TMother DDD aggregate
  TSQLRecordMother = class(TSQLRecord)
  protected
    fName: RawUTF8; // TMotherName
  published
    /// maps TMother.Name (TMotherName)
    property Name: RawUTF8 read fName write fName;
  end;

  TInfraRepoMother = class(TDDDRepositoryRestCommand, IDomMotherQuery, IDomMotherCommand)
  public
    function SelectAllByMotherName(const aMotherName: TMotherName): TCQRSResult;
    function SelectAll: TCQRSResult;
    function Get(out aAggregate: TMother): TCQRSResult;
    function GetAll(out aAggregates: TMotherObjArray): TCQRSResult;
    function GetNext(out aAggregate: TMother): TCQRSResult;
//    function GetCount: Integer;
    function Add(const aAggregate: TMother): TCQRSResult;
    function Update(const aUpdatedAggregate: TMother): TCQRSResult;
//    function Delete: TCQRSResult;
//    function DeleteAll: TCQRSResult;
//    function Commit: TCQRSResult;
//    function Rollback: TCQRSResult;
  end;

  TInfraRepoMotherFactory = class(TDDDRepositoryRestFactory)
  private
    class procedure TestOne(test: TSynTestCase; Rest: TSQLRest);
    class procedure TestOneNested(test: TSynTestCase; Rest: TSQLRest);
  public
    constructor Create(aRest: TSQLRest; aOwner: TDDDRepositoryRestManager=nil); reintroduce;
    class procedure RegressionTests(test: TSynTestCase);
    class procedure RegressionTestsToSQLite3(test: TSynTestCase; infraNested : boolean);
  end;

implementation

{ TInfraRepoMother }

function TInfraRepoMother.Add(const aAggregate: TMother): TCQRSResult;
begin
  Result := ORMAdd(aAggregate);
end;

function TInfraRepoMother.Get(out aAggregate: TMother): TCQRSResult;
begin
  Result := ORMGetAggregate(aAggregate);
end;

function TInfraRepoMother.GetAll(out aAggregates: TMotherObjArray): TCQRSResult;
begin
  Result := ORMGetAllAggregates(aAggregates);
end;

function TInfraRepoMother.GetNext(out aAggregate: TMother): TCQRSResult;
begin
  Result := ORMGetNextAggregate(aAggregate);
end;

function TInfraRepoMother.SelectAll: TCQRSResult;
begin
  Result := ORMSelectAll('', []);
end;

function TInfraRepoMother.SelectAllByMotherName(const aMotherName: TMotherName): TCQRSResult;
begin
  Result := ORMSelectAll('Name=?', [aMotherName], (''=aMotherName));
end;

function TInfraRepoMother.Update(const aUpdatedAggregate: TMother): TCQRSResult;
begin
  Result := ORMUpdate(aUpdatedAggregate);
end;

{ TInfraRepoMotherFactory }

constructor TInfraRepoMotherFactory.Create(aRest: TSQLRest; aOwner: TDDDRepositoryRestManager);
begin
  inherited Create(IDomMotherCommand,TInfraRepoMother,TMother,aRest,TSQLRecordMother,aOwner);
  AddFilterOrValidate(['*'], TSynFilterTrim.Create);
  AddFilterOrValidate(['Name'],TSynValidateNonVoidText.Create);
end;

class procedure TInfraRepoMotherFactory.TestOne(test: TSynTestCase; Rest: TSQLRest);
const
  //MAX = 1000;
  MAX = MAX_INFRA_RTESTS_LOOP;
var
  cmd: IDomMotherCommand;
  //qry: IDomMotherQuery;
  entity: TMother;
  entitys: TMotherObjArray;
  i: Integer;
  //entityCount: Integer;
  iText: RawUTF8;
  aCQRSRes : TCQRSResult;

begin
  with test do
  begin
    entity := TMother.Create;

    Check(Rest.Services.Resolve(IDomMotherCommand, cmd));
    try
      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i,iText);
        entity.Name := 'Mother' + iText;
        Check(cqrsSuccess = cmd.Add(entity));
      end;
      aCQRSRes := cmd.Commit;
      Check(cqrsSuccess = aCQRSRes);

      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i, iText);
        aCQRSRes := cmd.SelectAllByMotherName('Mother' + iText);
        Check(cqrsSuccess = aCQRSRes );
        Check(1 = cmd.GetCount);
        Check(cqrsSuccess = cmd.GetNext(entity));
        Check('Mother'+iText = entity.Name);
      end;

      Check(cqrsSuccess = cmd.SelectAll());
      Check(MAX = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetAll(entitys));
      Check(MAX = high(entitys)+1 );

      Check(cqrsSuccess = cmd.SelectAllByMotherName('Mother1'));
      Check(1 = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetNext(entity));

      entity.Name := 'HelloMother1';
      Check(cqrsSuccess = cmd.Update(entity));
      Check(cqrsSuccess = cmd.Commit);
    finally
      ObjArrayClear(entitys);
      entity.Free;
    end;
  end;
end;

class procedure TInfraRepoMotherFactory.TestOneNested(test: TSynTestCase; Rest: TSQLRest);
begin
  TestOne(test, Rest);
end;


class procedure TInfraRepoMotherFactory.RegressionTests(test: TSynTestCase);
var
  RestServer: TSQLRestServerFullMemory;
  RestClient: TSQLRestClientURI;
begin
  RestServer := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordMother]);
  try // first try directly on server side
    RestServer.ServiceContainer.InjectResolver([TInfraRepoMotherFactory.Create(RestServer)],true);
    TestOne(test,RestServer); // sub function will ensure that all I*Command are released
  finally
    RestServer.Free;
  end;
  RestServer := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordMother]);
  try // then try from a client-server process
    RestServer.ServiceContainer.InjectResolver([TInfraRepoMotherFactory.Create(RestServer)],true);
    RestServer.ServiceDefine(TInfraRepoMother,[IDomMotherCommand,IDomMotherQuery],sicClientDriven);
    test.Check(RestServer.ExportServer);
    RestClient := TSQLRestClientURIDll.Create(TSQLModel.Create(RestServer.Model),@URIRequest);
    try
      RestClient.Model.Owner := RestClient;
      RestClient.ServiceDefine([IDomMotherCommand],sicClientDriven);
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

class procedure TInfraRepoMotherFactory.RegressionTestsToSQLite3(test: TSynTestCase; infraNested : boolean);
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

  RestServer := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordMother]), aStore, false, []);
  RestServer.Model.Owner := RestServer;
  try

    if RestServer is TSQLRestServerDB then
      with TSQLRestServerDB(RestServer) do begin // may be a client in settings :)
        DB.Synchronous := smOff; // faster exclusive access to the file
        DB.LockingMode := lmExclusive;
        CreateMissingTables;     // will create the tables, if necessary
      end;

    RestServer.ServiceContainer.InjectResolver([TInfraRepoMotherFactory.Create(RestServer)],true);

    if not infraNested
      then TestOne(test,RestServer)  // sub function will ensure that all I*Command are released
      else TestOneNested(test,RestServer); // sub function will ensure that all I*Command are released

  finally
    aStore.Free;
    RestServer.Free;
  end;

end;


initialization
//  TDDDRepositoryRestFactory.ComputeSQLRecord([TMother]); //from mORMotDDD

end.

