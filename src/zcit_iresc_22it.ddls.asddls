@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Child Interface View - Resources'
define view entity ZCIT_IRESC_22IT
  as select from zcit_resc_22it
  association to parent ZCIT_IDSTR_22IT as _Disaster on $projection.DisasterID = _Disaster.DisasterID
{
  key disaster_id           as DisasterID,
  key resource_id           as ResourceID,
      resource_type         as ResourceType,
      quantity              as Quantity,
      
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      
      _Disaster // Link back to Parent
}
