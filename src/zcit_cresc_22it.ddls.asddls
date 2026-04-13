@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Resource Item Consumption'
@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZCIT_CRESC_22IT
  as projection on ZCIT_IRESC_22IT
{
      @Search.defaultSearchElement: true
  key DisasterID,
  key ResourceID,
      @Search.defaultSearchElement: true
      ResourceType,
      Quantity,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      
      /* Associations */
      _Disaster : redirected to parent ZCIT_CDSTR_22IT
}
