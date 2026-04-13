@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Disaster Header Consumption'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZCIT_CDSTR_22IT
  provider contract transactional_query
  as projection on ZCIT_IDSTR_22IT
{
      @Search.defaultSearchElement: true
  key DisasterID,
      @Search.defaultSearchElement: true
      DisasterType,
      Severity,
      Location,
      Status,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
      /* Associations */
      _Resource : redirected to composition child ZCIT_CRESC_22IT
}
