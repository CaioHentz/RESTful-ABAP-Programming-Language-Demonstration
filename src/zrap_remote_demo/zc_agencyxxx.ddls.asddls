@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZAGENCYXXX'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_AGENCYXXX
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_AGENCYXXX
  association [1..1] to ZR_AGENCYXXX as _BaseEntity on $projection.AGENCYID = _BaseEntity.AGENCYID
{
  key Agencyid,
  Name,
  Street,
  Postalcode,
  City,
  Country,
  Phonenumber,
  Webaddress,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChanged,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChanged,
  @Semantics: {
    User.Lastchangedby: true
  }
  UserLastChanged,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  _BaseEntity
}
