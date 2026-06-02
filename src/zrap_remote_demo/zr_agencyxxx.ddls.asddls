@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZAGENCYXXX'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_AGENCYXXX
  as select from ZAGENCYXXX as Agency
{
  key agencyid as Agencyid,
  name as Name,
  street as Street,
  postalcode as Postalcode,
  city as City,
  country as Country,
  phonenumber as Phonenumber,
  webaddress as Webaddress,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged,
  @Semantics.user.lastChangedBy: true
  user_last_changed as UserLastChanged,
  @Semantics.user.createdBy: true
  created_by as CreatedBy
}
