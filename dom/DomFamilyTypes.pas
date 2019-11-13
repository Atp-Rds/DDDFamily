unit DomFamilyTypes;

interface

uses
  SynCommons,
  mORMot;

type

  TMotherName = type RawUTF8;

  TMother = class(TSynPersistent)
  private
    fName: TMotherName;
  protected
    procedure AssignTo(Source: TSynPersistent); override;
  published
    property Name: TMotherName read fName write fName;
  end;

  TMotherObjArray = array of TMother;


  TFatherName = type RawUTF8;

  TFather = class(TSynPersistent)
  private
    fName: TFatherName;
  protected
    procedure AssignTo(Source: TSynPersistent); override;
  published
    property Name: TFatherName read fName write fName;
  end;

  TFatherObjArray  = array of TFather;


  TSonName = type RawUTF8;

  TSon = class(TSynAutoCreateFields)
  private
    fName: TSonName;
    fMother: TMother;
    fFather: TFather;
  protected
    procedure AssignTo(Source: TSynPersistent); override;
  public
    procedure AssignParents(aMother: TMother; aFather: TFather);
  published
    property Name: TSonName read fName write fName;
    property Mother: TMother read fMother;// write fMother;
    property Father: TFather read fFather;// write fFather;
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

procedure TFamily.AssignMembers(aMother: TMother; aFather: TFather; aSon: TSon);
begin

  if (aMother<>nil) Then
    aMother.Assign( Mother );

  if (aFather<>nil) Then
    aFather.Assign( Father );

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
      Name := TMother(Source).Name;
    end;
end;

{ TFather }

procedure TFather.AssignTo(Source: TSynPersistent);
begin
  if (Source=nil) or (Source.ClassName <> ClassName )
    then inherited
    else begin
      Name := TFather(Source).Name;
    end;
end;

{ TSon }

procedure TSon.AssignParents(aMother: TMother; aFather: TFather);
begin
  if (aMother<>nil) Then
    aMother.Assign( Mother );
  if (aFather<>nil) Then
    aFather.Assign( Father );
end;

procedure TSon.AssignTo(Source: TSynPersistent);
begin
  if (Source=nil) or (Source.ClassName <> ClassName )
    then inherited
    else begin
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

