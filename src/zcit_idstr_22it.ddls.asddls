@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View - Disaster'
define root view entity ZCIT_IDSTR_22IT
  as select from zcit_dstr_22it
  composition [0..*] of ZCIT_IRESC_22IT as _Resource
{
  key disaster_id           as DisasterID,
      disaster_type         as DisasterType,
      severity              as Severity,
      location              as Location,
      status                as  status,
      
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
      
      _Resource // Exposing association
}
