CLASS lhc_Disaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Disaster RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Disaster.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Disaster.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Disaster.

    METHODS read FOR READ
      IMPORTING keys FOR READ Disaster RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Disaster.

    METHODS rba_Resource FOR READ
      IMPORTING keys_rba FOR READ Disaster\_Resource FULL result_requested RESULT result LINK association_links.

    METHODS cba_Resource FOR MODIFY
      IMPORTING entities_cba FOR CREATE Disaster\_Resource.
ENDCLASS.

CLASS lhc_Disaster IMPLEMENTATION.
  METHOD get_instance_authorizations.
    " Implementation for authorizations can be added here [cite: 840]
  ENDMETHOD.

  METHOD lock.
    " Locking logic for unmanaged scenario [cite: 842]
  ENDMETHOD.

  METHOD create.
    DATA: ls_dstr_hdr TYPE zcit_dstr_22it.
    LOOP AT entities INTO DATA(ls_entity).
      ls_dstr_hdr = CORRESPONDING #( ls_entity MAPPING FROM ENTITY ).

      IF ls_dstr_hdr-disaster_id IS NOT INITIAL.
        " Check if record already exists in DB [cite: 855-856]
        SELECT SINGLE FROM zcit_dstr_22it FIELDS disaster_id
          WHERE disaster_id = @ls_dstr_hdr-disaster_id
          INTO @DATA(lv_exists).

        IF sy-subrc <> 0.
          " Save to Buffer Utility [cite: 865-867]
          zcit_util_22it=>get_instance( )->set_dstr_value( im_header = ls_dstr_hdr ).

          APPEND VALUE #( %cid = ls_entity-%cid disasterid = ls_dstr_hdr-disaster_id )
            TO mapped-disaster.
        ELSE.
          " Handle Duplicate Error [cite: 890-894]
          APPEND VALUE #( %cid = ls_entity-%cid ) TO failed-disaster.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    " Logic to update the buffer for existing records [cite: 901, 922]
    LOOP AT entities INTO DATA(ls_entity).
      DATA(ls_dstr_hdr) = CORRESPONDING zcit_dstr_22it( ls_entity MAPPING FROM ENTITY ).
      zcit_util_22it=>get_instance( )->set_dstr_value( im_header = ls_dstr_hdr ).
      APPEND VALUE #( disasterid = ls_dstr_hdr-disaster_id ) TO mapped-disaster.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      " Register deletion in buffer [cite: 968]
      zcit_util_22it=>get_instance( )->set_dstr_del( im_dstr_id = ls_key-disasterid ).
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    " Standard read from DB for display [cite: 983-987]
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE * FROM zcit_dstr_22it WHERE disaster_id = @ls_key-disasterid INTO @DATA(ls_db).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_db ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Resource.
    " Read By Association: Fetching items for a header [cite: 994-998]
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT * FROM zcit_resc_22it WHERE disaster_id = @ls_key-disasterid INTO TABLE @DATA(lt_items).
      LOOP AT lt_items INTO DATA(ls_item).
        APPEND CORRESPONDING #( ls_item ) TO result.
        APPEND VALUE #( source-disasterid = ls_key-disasterid
                       target-disasterid = ls_item-disaster_id
                       target-resourceid = ls_item-resource_id ) TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Resource.
    " Create By Association: Creating a resource from a disaster header [cite: 1046-1049]
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        DATA(ls_resc) = CORRESPONDING zcit_resc_22it( ls_target ).
        ls_resc-disaster_id = ls_cba-disasterid.
        zcit_util_22it=>get_instance( )->set_resc_value( im_resource = ls_resc ).
        APPEND VALUE #( %cid = ls_target-%cid
                       disasterid = ls_resc-disaster_id
                       resourceid = ls_resc-resource_id ) TO mapped-resource.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_Resource DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Resource.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Resource.
    METHODS read   FOR READ   IMPORTING keys FOR READ Resource RESULT result.
ENDCLASS.

CLASS lhc_Resource IMPLEMENTATION.
  METHOD update.
    " Set item update in buffer [cite: 1118-1119]
    LOOP AT entities INTO DATA(ls_entity).
      DATA(ls_resc) = CORRESPONDING zcit_resc_22it( ls_entity MAPPING FROM ENTITY ).
      zcit_util_22it=>get_instance( )->set_resc_value( im_resource = ls_resc ).
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    " Logic for individual item deletion [cite: 1144]
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZCIT_IDSTR_22IT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save              REDEFINITION.
    METHODS cleanup           REDEFINITION.
    METHODS cleanup_finalize  REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_IDSTR_22IT IMPLEMENTATION.

  METHOD finalize.
    " Final adjustments before the save sequence begins
  ENDMETHOD.

  METHOD check_before_save.
    " Final validation check before data hits the database
  ENDMETHOD.

  METHOD save.
    " Fetch the singleton instance of your transactional buffer
    DATA(lo_util) = zcit_util_22it=>get_instance( ).

    " 1. Retrieve the session data from the buffer
    lo_util->get_dstr_value( IMPORTING ex_header = DATA(ls_header) ).
    lo_util->get_resc_value( IMPORTING ex_resource = DATA(ls_resource) ).
    lo_util->get_dstr_del( IMPORTING ex_dstr_ids = DATA(lt_deletion_list) ).

    " 2. Save or Update the Disaster Header Table
    IF ls_header IS NOT INITIAL.
      MODIFY zcit_dstr_22it FROM @ls_header.
    ENDIF.

    " 3. Save or Update the Disaster Resource Table
    IF ls_resource IS NOT INITIAL.
      MODIFY zcit_resc_22it FROM @ls_resource.
    ENDIF.

    " 4. Execute Deletions
    IF lt_deletion_list IS NOT INITIAL.
      LOOP AT lt_deletion_list INTO DATA(ls_del).
        " Delete header and cascade the deletion to assigned resources
        DELETE FROM zcit_dstr_22it WHERE disaster_id = @ls_del-disaster_id.
        DELETE FROM zcit_resc_22it WHERE disaster_id = @ls_del-disaster_id.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    " Wipe the buffer after a successful save to prevent duplicate data in the next transaction
    zcit_util_22it=>get_instance( )->cleanup_buffer( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
