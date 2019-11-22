unit InfraFatherRepository;

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

  DomFatherCQRS,
  DomFamilyTypes,

  InfraFamilyTypes;

type

  /// ORM class corresponding to TFather DDD aggregate
  TSQLRecordFather = class(TSQLRecord)
  protected
    fIdNumber: Int64; // TFatherIdNumber
    fName: RawUTF8; // TFatherName
  published
    /// maps TFather.IdNumber (TFatherIdNumber)
    property IdNumber: Int64 read fIdNumber write fIdNumber stored AS_UNIQUE;
    /// maps TFather.Name (TFatherName)
    property Name: RawUTF8 read fName write fName;
  end;

  TInfraRepoFather = class(TDDDRepositoryRestCommand, IDomFatherQuery, IDomFatherCommand)
  public
    function SelectAllByFatherIdNumber(const aFatherIdNumber: TFatherIdNumber): TCQRSResult;
    function SelectAllByFatherName(const aFatherName: TFatherName): TCQRSResult;
    function SelectAll: TCQRSResult;
    function Get(out aAggregate: TFather): TCQRSResult;
    function GetAll(out aAggregates: TFatherObjArray): TCQRSResult;
    function GetNext(out aAggregate: TFather): TCQRSResult;
//    function GetCount: Integer;
    function Add(const aAggregate: TFather): TCQRSResult;
    function Update(const aUpdatedAggregate: TFather): TCQRSResult;
//    function Delete: TCQRSResult;
//    function DeleteAll: TCQRSResult;
//    function Commit: TCQRSResult;
//    function Rollback: TCQRSResult;
  end;

  TInfraRepoFatherFactory = class(TDDDRepositoryRestFactory)
  private
    class procedure TestOne(test: TSynTestCase; Rest: TSQLRest);
    class procedure TestOneNested(test: TSynTestCase; Rest: TSQLRest);
  public
    constructor Create(aRest: TSQLRest; aOwner: TDDDRepositoryRestManager=nil); reintroduce;
    class procedure RegressionTests(test: TSynTestCase);
    class procedure RegressionTestsToSQLite3(test: TSynTestCase; infraNested : boolean);
  end;

implementation

{ TInfraRepoFather }

function TInfraRepoFather.Add(const aAggregate: TFather): TCQRSResult;
begin
  Result := ORMAdd(aAggregate);
end;

function TInfraRepoFather.Get(out aAggregate: TFather): TCQRSResult;
begin
  Result := ORMGetAggregate(aAggregate);
end;

function TInfraRepoFather.GetAll(out aAggregates: TFatherObjArray): TCQRSResult;
begin
  Result := ORMGetAllAggregates(aAggregates);
end;

function TInfraRepoFather.GetNext(out aAggregate: TFather): TCQRSResult;
begin
  Result := ORMGetNextAggregate(aAggregate);
end;

function TInfraRepoFather.SelectAll: TCQRSResult;
begin
  Result := ORMSelectAll('', []);
end;

function TInfraRepoFather.SelectAllByFatherIdNumber(const aFatherIdNumber: TFatherIdNumber): TCQRSResult;
begin
  Result := ORMSelectAll('IdNumber=?', [aFatherIdNumber], (aFatherIdNumber<1));
end;

function TInfraRepoFather.SelectAllByFatherName(const aFatherName: TFatherName): TCQRSResult;
begin
  Result := ORMSelectAll('Name=?', [aFatherName], (''=aFatherName));
end;

function TInfraRepoFather.Update(const aUpdatedAggregate: TFather): TCQRSResult;
begin
  Result := ORMUpdate(aUpdatedAggregate);
end;

{ TInfraRepoFatherFactory }

constructor TInfraRepoFatherFactory.Create(aRest: TSQLRest; aOwner: TDDDRepositoryRestManager);
begin
  inherited Create(IDomFatherCommand,TInfraRepoFather,TFather,aRest,TSQLRecordFather,aOwner);
  AddFilterOrValidate(['*'], TSynFilterTrim.Create);
  AddFilterOrValidate(['Name'],TSynValidateNonVoidText.Create);
end;

class procedure TInfraRepoFatherFactory.TestOne(test: TSynTestCase; Rest: TSQLRest);
const
  //MAX = 1000;
  MAX = MAX_INFRA_RTESTS_LOOP;
var
  cmd: IDomFatherCommand;
  //qry: IDomFatherQuery;
  entity: TFather;
  entitys: TFatherObjArray;
  i: Integer;
  //entityCount: Integer;
  iText: RawUTF8;
  aCQRSRes : TCQRSResult;

begin
  with test do
  begin
    entity := TFather.Create;

    Check(Rest.Services.Resolve(IDomFatherCommand, cmd));
    try
      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i,iText);
        entity.IdNumber := i;
        entity.Name := 'Father' + iText;
        Check(cqrsSuccess = cmd.Add(entity));
      end;
      aCQRSRes := cmd.Commit;
      Check(cqrsSuccess = aCQRSRes);

      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i, iText);
        aCQRSRes := cmd.SelectAllByFatherName('Father' + iText);
        Check(cqrsSuccess = aCQRSRes );
        Check(1 = cmd.GetCount);
        Check(cqrsSuccess = cmd.GetNext(entity));
        Check('Father'+iText = entity.Name);
        Check(i = entity.IdNumber);
      end;

      Check(cqrsSuccess = cmd.SelectAll());
      Check(MAX = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetAll(entitys));
      Check(MAX = high(entitys)+1 );

      Check(cqrsSuccess = cmd.SelectAllByFatherName('Father1'));
      Check(1 = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetNext(entity));

      entity.Name := 'HelloFather1';
      Check(cqrsSuccess = cmd.Update(entity));
      Check(cqrsSuccess = cmd.Commit);
    finally
      ObjArrayClear(entitys);
      entity.Free;
    end;
  end;
end;

class procedure TInfraRepoFatherFactory.TestOneNested(test: TSynTestCase; Rest: TSQLRest);
begin
  TestOne(test, Rest);
end;


class procedure TInfraRepoFatherFactory.RegressionTests(test: TSynTestCase);
var
  RestServer: TSQLRestServerFullMemory;
  RestClient: TSQLRestClientURI;
begin
  RestServer := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordFather]);
  try // first try directly on server side
    RestServer.ServiceContainer.InjectResolver([TInfraRepoFatherFactory.Create(RestServer)],true);
    TestOne(test,RestServer); // sub function will ensure that all I*Command are released
  finally
    RestServer.Free;
  end;
  RestServer := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordFather]);
  try // then try from a client-server process
    RestServer.ServiceContainer.InjectResolver([TInfraRepoFatherFactory.Create(RestServer)],true);
    RestServer.ServiceDefine(TInfraRepoFather,[IDomFatherCommand,IDomFatherQuery],sicClientDriven);
    test.Check(RestServer.ExportServer);
    RestClient := TSQLRestClientURIDll.Create(TSQLModel.Create(RestServer.Model),@URIRequest);
    try
      RestClient.Model.Owner := RestClient;
      RestClient.ServiceDefine([IDomFatherCommand],sicClientDriven);
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

class procedure TInfraRepoFatherFactory.RegressionTestsToSQLite3(test: TSynTestCase; infraNested : boolean);
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

  RestServer := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordFather]), aStore, false, []);
  RestServer.Model.Owner := RestServer;
  try

    if RestServer is TSQLRestServerDB then
      with TSQLRestServerDB(RestServer) do begin // may be a client in settings :)
        DB.Synchronous := smOff; // faster exclusive access to the file
        DB.LockingMode := lmExclusive;
        CreateMissingTables;     // will create the tables, if necessary
      end;

    RestServer.ServiceContainer.InjectResolver([TInfraRepoFatherFactory.Create(RestServer)],true);

    if not infraNested
      then TestOne(test,RestServer)  // sub function will ensure that all I*Command are released
      else TestOneNested(test,RestServer); // sub function will ensure that all I*Command are released

  finally
    aStore.Free;
    RestServer.Free;
  end;

end;

initialization
//  TDDDRepositoryRestFactory.ComputeSQLRecord([TFather]); //from mORMotDDD

end.

