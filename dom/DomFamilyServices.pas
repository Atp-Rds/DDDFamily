unit DomFamilyServices;

interface

uses
  SynCommons,
  mORMot,
  mORMotDDD,

  DomFamilyTypes,
  DomFamilyInterfaces,

  DomMotherCQRS,
  DomFatherCQRS,
  DomSonCQRS,
  DomFamilyCQRS;

type

  TFamilyManager = class(TInterfacedObject, IFamilyManager)
    protected
      fMotherRepo: IDomMotherCommand;
      fFatherRepo: IDomFatherCommand;
      fSonRepo: IDomSonCommand;
      fFamilyRepo: IDomFamilyCommand;
    public                                // All IDom*Command Dependencys
      constructor Create( aIDMoherCmd: IDomMotherCommand;
                          aIDFaherCmd: IDomFatherCommand;
                          aIDSonCmd: IDomSonCommand;
                          aIDFamilyCmd: IDomFamilyCommand ); reintroduce;

      // IFamilyManager methods below
      function ChangeMotherName (const aMotherIdNumber: TMotherIdNumber; const aNewMotherName : TMotherName): Boolean;

  end;

implementation

{ TFamilyManager }
constructor TFamilyManager.Create(aIDMoherCmd: IDomMotherCommand;
  aIDFaherCmd: IDomFatherCommand; aIDSonCmd: IDomSonCommand;
  aIDFamilyCmd: IDomFamilyCommand);
begin
  inherited Create;
  fMotherRepo:=aIDMoherCmd;
  fFatherRepo:=aIDFaherCmd;
  fSonRepo:=aIDSonCmd;
  fFamilyRepo:=aIDFamilyCmd;
end;


function TFamilyManager.ChangeMotherName(const aMotherIdNumber: TMotherIdNumber;
  const aNewMotherName: TMotherName): Boolean;
var aCQRSRes : TCQRSResult;
    aRes : Boolean;

    aMother: TMother;
    aFather: TFather;
    aSon: TSon;
    aFamily: TFamily;
begin

  aMother := TMother.Create;
  aFather := TFather.Create;
  aSon := TSon.Create;
  aFamily := TFamily.Create;

  Try
             ///// Change Mother Name, apply to all Aggregates

             // Apply to Mother Aggregate
    aCQRSRes := fMotherRepo.SelectAllByMotherIdNumber( aMotherIdNumber);
    aRes:=(cqrsSuccess=aCQRSRes);
    if aRes then begin
      aCQRSRes:=fMotherRepo.GetNext(aMother);
      aRes:=(cqrsSuccess=aCQRSRes);
      if aRes then begin
        aMother.Name:=aNewMotherName;
        aCQRSRes:=fMotherRepo.Update(aMother);
        aRes:=(cqrsSuccess=aCQRSRes);
      end;
    end;

            /// Apply to Son Aggregate
    if aRes then begin
      fSonRepo.SelectAllByMotherIdNumber(aMotherIdNumber);
      aCQRSRes:=fSonRepo.GetNext(aSon);
      aRes:=(cqrsSuccess=aCQRSRes);
      if aRes then begin
        aSon.AssignMother( aMother );
        aCQRSRes:=fSonRepo.Update(aSon);
        aRes:=(cqrsSuccess=aCQRSRes);
      end;
    end;

            /// Apply to Family Aggregate
    if aRes then begin
      fFamilyRepo.SelectAllByMotherIdNumber(aMotherIdNumber);
      aCQRSRes:=fFamilyRepo.GetNext(aFamily);
      aRes:=(cqrsSuccess=aCQRSRes);
      if aRes then begin
        aFamily.AssignMother(aMother);
        aFamily.Son.AssignMother(aMother);
        aCQRSRes:=fFamilyRepo.Update(aFamily);
        aRes:=(cqrsSuccess=aCQRSRes);
      end;
    end;

            //// Commit to All Aggregates
    if aRes then begin
      aCQRSRes:=fMotherRepo.Commit; // Mother Aggregate
      aRes:=(cqrsSuccess=aCQRSRes);
    end;
    if aRes then begin
      aCQRSRes:=fSonRepo.Commit; // Son Aggregate
      aRes:=(cqrsSuccess=aCQRSRes);
    end;
    if aRes then begin
      aCQRSRes:=fFamilyRepo.Commit; // Family Aggregate
      aRes:=(cqrsSuccess=aCQRSRes);
    end;

  Finally
    aFamily.Free;
    aSon.Free;
    aFather.Free;
    aMother.Free;
  End;

  Result:=aRes;

end;


end.

