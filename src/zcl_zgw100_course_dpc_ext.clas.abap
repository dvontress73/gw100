class ZCL_ZGW100_COURSE_DPC_EXT definition
  public
  inheriting from ZCL_ZGW100_COURSE_DPC
  create public .

public section.
protected section.

  methods PRODUCTSET_GET_ENTITYSET
    redefinition .
  methods PRODUCTSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW100_COURSE_DPC_EXT IMPLEMENTATION.


  METHOD productset_get_entity.
    DATA: ls_product_id TYPE bapi_epm_product_id, ls_headerdata TYPE bapi_epm_product_header, lt_return	TYPE TABLE OF bapiret2.

*	Get key fields from request
    io_tech_request_context->get_converted_keys(
    IMPORTING
    es_key_values = er_entity
    ).

*	Map key fields to function module parameters
    ls_product_id-product_id = er_entity-product_id.

*	Get data
    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_DETAIL'
      EXPORTING
        product_id = ls_product_id
      IMPORTING
        headerdata = ls_headerdata
      TABLES
        return     = lt_return.

    IF lt_return IS NOT INITIAL. " Message Container
      mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = mo_context->get_message_container( ).
    ENDIF.

* Fill response data
    MOVE-CORRESPONDING ls_headerdata TO er_entity.

  ENDMETHOD.


METHOD productset_get_entityset.
  DATA: ls_entity     LIKE LINE OF et_entityset,
        lt_headerdata TYPE TABLE OF bapi_epm_product_header,
        ls_headerdata TYPE bapi_epm_product_header,
        lt_return     TYPE TABLE OF bapiret2.

* Get data
  CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_LIST'
    TABLES
      headerdata = lt_headerdata
      return     = lt_return.

  IF lt_return IS NOT INITIAL. " Message Container
    mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid            = /iwbep/cx_mgw_busi_exception=>business_error
        message_container = mo_context->get_message_container( ).
  ENDIF.

* Fill response data
  MOVE-CORRESPONDING lt_headerdata TO et_entityset.

ENDMETHOD.
ENDCLASS.
