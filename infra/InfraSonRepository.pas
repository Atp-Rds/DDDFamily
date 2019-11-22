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

  DomMotherCQRS,
  DomFatherCQRS,
  DomSonCQRS,
  DomFamilyTypes,

  InfraFamilyTypes,
  InfraMotherRepository,
  InfraFatherRepository;

type

  /// ORM class corresponding to TSon DDD aggregate
  TSQLRecordSon = class(TSQLRecord)
  protected
    fIdNumber: Int64; //TSonIdNumber;
    fName: RawUTF8; // TSonName

    fMother_IdNumber: Int64; // TMotherIdNumber
    fMother_Name: RawUTF8; // TMotherName

    fFather_IdNumber: Int64; // TFatherIdNumber
    fFather_Name: RawUTF8; // TFatherName
  published
    /// maps TSon.IdNumber (TSonIdNumber)
    property IdNumber: Int64 read fIdNumber write fIdNumber stored AS_UNIQUE;
    /// maps TSon.Name (TSonName)
    property Name: RawUTF8 read fName write fName;

    /// maps TSon.Mother.IdNumber (TMotherIdNumber)
    property Mother_IdNumber: Int64 read fMother_IdNumber write fMother_IdNumber;
    /// maps TSon.Mother.Name (TMotherName)
    property Mother_Name: RawUTF8 read fMother_Name write fMother_Name;

    /// maps TSon.Father.IdNumber (TFatherIdNumber)
    property Father_IdNumber: Int64 read fFather_IdNumber write fFather_IdNumber;
    /// maps TSon.Father.Name (TFatherName)
    property Father_Name: RawUTF8 read fFather_Name write fFather_Name;
  end;

  TInfraRepoSon = class(TDDDRepositoryRestCommand, IDomSonQuery, IDomSonCommand)
  public
    function SelectAllBySonName(const aSonName: TSonName): TCQRSResult;
    function SelectAllByMotherIdNumber(const aMotherIdNumber: TMotherIdNumber): TCQRSResult;
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
    class procedure RegressionTestsToSQLite3(test: TSynTestCase; infraNested : boolean);
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

function TInfraRepoSon.SelectAllByMotherIdNumber(const aMotherIdNumber: TMotherIdNumber): TCQRSResult;
begin
  Result := ORMSelectAll('Mother_IdNumber=?', [aMotherIdNumber], (aMotherIdNumber<1));
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
        entity.IdNumber := i;
        entity.Name := 'Son' + iText;

        entity2.IdNumber := i;
        entity2.Name := 'Mother' + iText;

        entity3.IdNumber := i;
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
        Check(i = entity.IdNumber);
      end;

      Check(cqrsSuccess = cmd.SelectAll());
      Check(MAX = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetAll(entitys));
      Check(MAX = high(entitys)+1 );

      Check(cqrsSuccess = cmd.SelectAllBySonName('Son1'));
      Check(1 = cmd.GetCount);
      Check(cqrsSuccess = cmd.GetNext(entity));

      entity.Name := 'HelloSon1';
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
  cmd2: IDomMotherCommand;
  cmd3: IDomFatherCommand;
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
    Check(Rest.Services.Resolve(IDomMotherCommand, cmd2));
    Check(Rest.Services.Resolve(IDomFatherCommand, cmd3));
    try
      for i := 1 to MAX do
      begin
        UInt32ToUtf8(i,iText);
        entity.IdNumber := i;
        entity.Name := 'Son' + iText;

           // Get Mother
        Check(cqrsSuccess = cmd2.SelectAllByMotherIdNumber(i));
        Check(1 = cmd2.GetCount);
        Check(cqrsSuccess = cmd2.GetNext(entity2));

           // Get Father
        Check(cqrsSuccess = cmd3.SelectAllByFatherIdNumber(i));
        Check(1 = cmd3.GetCount);
        Check(cqrsSuccess = cmd3.GetNext(entity3));

        entity.AssignParents(entity2,entity3);
        aCQRSRes := cmd.Add(entity);
        Check(cqrsSuccess = aCQRSRes);

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

      entity.Name := 'HelloSon1';
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

class procedure TInfraRepoSonFactory.RegressionTestsToSQLite3(test: TSynTestCase; infraNested : boolean);
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
    then RestServer := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordMother,TSQLRecordFather,TSQLRecordSon]), aStore, false, [])
    else RestServer := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordSon]), aStore, false, []);

  RestServer.Model.Owner := RestServer;
  try

    if RestServer is TSQLRestServerDB then
      with TSQLRestServerDB(RestServer) do begin // may be a client in settings :)
        DB.Synchronous := smOff; // faster exclusive access to the file
        DB.LockingMode := lmExclusive;
        CreateMissingTables;     // will create the tables, if necessary
      end;

    RestServer.ServiceContainer.InjectResolver([TInfraRepoSonFactory.Create(RestServer)],true);

    if infraNested then begin
      RestServer.ServiceContainer.InjectResolver([TInfraRepoMotherFactory.Create(RestServer)],true);
      RestServer.ServiceContainer.InjectResolver([TInfraRepoFatherFactory.Create(RestServer)],true);
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
//  TDDDRepositoryRestFactory.ComputeSQLRecord([TMother, TFather, TSon]); //from mORMotDDD

end.

