unit DomFamilyTypes;

interface

uses
  SynCommons,
  mORMot;

type

  TMotherName = type RawUTF8;
  TMotherIdNumber = type Cardinal;

  TMother = class(TSynPersistent)
  private
    fIdNumber : TMotherIdNumber;
    fName: TMotherName;
  protected
    procedure AssignTo(Source: TSynPersistent); override;
  published
    property IdNumber: TMotherIdNumber read fIdNumber write fIdNumber;
    property Name: TMotherName read fName write fName;
  end;

  TMotherObjArray = array of TMother;


  TFatherName = type RawUTF8;
  TFatherIdNumber = type Cardinal;

  TFather = class(TSynPersistent)
  private
    fIdNumber : TFatherIdNumber;
    fName: TFatherName;
  protected
    procedure AssignTo(Source: TSynPersistent); override;
  published
    property IdNumber: TFatherIdNumber read fIdNumber write fIdNumber;
    property Name: TFatherName read fName write fName;
  end;

  TFatherObjArray  = array of TFather;


  TSonName = type RawUTF8;
  TSonIdNumber = type Cardinal;

  TSon = class(TSynAutoCreateFields)
  private
    fIdNumber : TSonIdNumber;
    fName: TSonName;
    fMother: TMother;
    fFather: TFather;
  protected
    procedure AssignTo(Source: TSynPersistent); override;
  public
    procedure AssignMother(aMother: TMother);
    procedure AssignFather(aFather: TFather);
    procedure AssignParents(aMother: TMother; aFather: TFather);
  published
    property IdNumber: TSonIdNumber read fIdNumber write fIdNumber;
    property Name: TSonName read fName write fName;
    property Mother: TMother read fMother;
    property Father: TFather read fFather;
  end;

  TSonObjArray = array of TSon;

  TFamilyName  = type RawUTF8;

  TFamily  = class(TSynAutoCreateFields)
  private
    fFamilyName: TFamilyName;
    fMother: TMother;
    fFather: TFather;
    fSon: TSon;
  public
    procedure AssignMother(aMother: TMother);
    procedure AssignFather(aFather: TFather);
    procedure AssignMembers(aMother: TMother; aFather: TFather; aSon: TSon);
  published
    property FamilyName: TFamilyName read fFamilyName write fFamilyName;
    property Mother: TMother read fMother;
    property Father: TFather read fFather;
    property Son: TSon read fSon;
  end;

  TFamilyObjArray = array of TFamily;


implementation

{ TFamily }

procedure TFamily.AssignMother(aMother: TMother);
begin
  if (aMother<>nil) Then
    aMother.Assign( Mother );
end;


procedure TFamily.AssignFather(aFather: TFather);
begin
  if (aFather<>nil) Then
    aFather.Assign( Father );
end;

procedure TFamily.AssignMembers(aMother: TMother; aFather: TFather; aSon: TSon);
begin
  AssignMother(aMother);
  AssignFather(aFather);

  if (aSon<>nil) Then begin
    Son.AssignParents(aMother,aFather);
    aSon.Assign( Son );
  end;

end;


{ TMother }

procedure TMother.AssignTo(Source: TSynPersistent);
begin
  if (Source=nil) or (Source.ClassName <> ClassName )
    then inherited
    else begin
      IdNumber := TMother(Source).IdNumber;
      Name := TMother(Source).Name;
    end;
end;

{ TFather }

procedure TFather.AssignTo(Source: TSynPersistent);
begin
  if (Source=nil) or (Source.ClassName <> ClassName )
    then inherited
    else begin
      IdNumber := TFather(Source).IdNumber;
      Name := TFather(Source).Name;
    end;
end;

{ TSon }

procedure TSon.AssignMother(aMother: TMother);
begin
  if (aMother<>nil) Then
    aMother.Assign( Mother );
end;

procedure TSon.AssignFather(aFather: TFather);
begin
  if (aFather<>nil) Then
    aFather.Assign( Father );
end;

procedure TSon.AssignParents(aMother: TMother; aFather: TFather);
begin
  AssignMother(aMother);
  AssignFather(aFather);
end;

procedure TSon.AssignTo(Source: TSynPersistent);
begin
  if (Source=nil) or (Source.ClassName <> ClassName )
    then inherited
    else begin
      IdNumber := TSon(Source).IdNumber;
      Name := TSon(Source).Name;
    end;
end;

initialization
  TJSONSerializer.RegisterObjArrayForJSON([
    TypeInfo(TMotherObjArray), TMother,
    TypeInfo(TFatherObjArray), TFather,
    TypeInfo(TSonObjArray), TSon,
    TypeInfo(TFamilyObjArray), TFamily
  ]);

end.

