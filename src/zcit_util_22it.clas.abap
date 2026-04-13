CLASS zcit_util_22it DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    " Using table types that match your database structure
    TYPES: tt_dstr_hdr  TYPE STANDARD TABLE OF zcit_dstr_22it WITH EMPTY KEY,
           tt_dstr_resc TYPE STANDARD TABLE OF zcit_resc_22it WITH EMPTY KEY.

    CLASS-METHODS get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcit_util_22it.

    METHODS:
      " Methods to set/get Header data
      set_dstr_value IMPORTING im_header TYPE zcit_dstr_22it,
      get_dstr_value EXPORTING ex_header TYPE zcit_dstr_22it,

      " Methods to set/get Resource data
      set_resc_value IMPORTING im_resource TYPE zcit_resc_22it,
      get_resc_value EXPORTING ex_resource TYPE zcit_resc_22it,

      " Methods for Deletion tracking
      set_dstr_del   IMPORTING im_dstr_id TYPE zcit_dstr_22it-disaster_id,
      get_dstr_del   EXPORTING ex_dstr_ids TYPE tt_dstr_hdr,

      cleanup_buffer.

  PRIVATE SECTION.
    CLASS-DATA mo_instance TYPE REF TO zcit_util_22it.

    " Internal buffers to hold data during the LUW (Logical Unit of Work)
    DATA: gs_dstr_hdr_buff  TYPE zcit_dstr_22it,
          gs_dstr_resc_buff TYPE zcit_resc_22it,
          gt_dstr_del_buff  TYPE tt_dstr_hdr.
ENDCLASS.

CLASS zcit_util_22it IMPLEMENTATION.

  METHOD get_instance.
    IF mo_instance IS INITIAL.
      mo_instance = NEW zcit_util_22it( ).
    ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.

  METHOD set_dstr_value.
    gs_dstr_hdr_buff = im_header.
  ENDMETHOD.

  METHOD get_dstr_value.
    ex_header = gs_dstr_hdr_buff.
  ENDMETHOD.

  METHOD set_resc_value.
    gs_dstr_resc_buff = im_resource.
  ENDMETHOD.

  METHOD get_resc_value.
    ex_resource = gs_dstr_resc_buff.
  ENDMETHOD.

  METHOD cleanup_buffer.
    CLEAR: gs_dstr_hdr_buff, gs_dstr_resc_buff, gt_dstr_del_buff.
  ENDMETHOD.

  METHOD set_dstr_del.
    " Appending the key to the deletion buffer
    APPEND VALUE #( disaster_id = im_dstr_id ) TO gt_dstr_del_buff.
  ENDMETHOD.

  METHOD get_dstr_del.
    ex_dstr_ids = gt_dstr_del_buff.
  ENDMETHOD.

ENDCLASS.
