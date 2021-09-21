class ZCL_ZGW100_COURSE_DPC_EXT definition
  public
  inheriting from ZCL_ZGW100_COURSE_DPC
  create public .

public section.
protected section.

  methods BUSINESSPARTNERS_GET_ENTITYSET
    redefinition .
  methods PRODUCTSET_GET_ENTITY
    redefinition .
  methods PRODUCTSET_GET_ENTITYSET
    redefinition .
  methods BUSINESSPARTNERS_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW100_COURSE_DPC_EXT IMPLEMENTATION.


  METHOD businesspartners_get_entity.
**TRY.
*CALL METHOD SUPER->BUSINESSPARTNERS_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    DATA: ls_bp_id      TYPE bapi_epm_bp_id,
          ls_headerdata TYPE bapi_epm_bp_header,
          lt_return     TYPE TABLE OF bapiret2.

*Get key fields from request
    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = er_entity
    ).

    ls_bp_id-bp_id = er_entity-businesspartnerid.

*Get data
    CALL FUNCTION 'BAPI_EPM_BP_GET_DETAIL'
      EXPORTING
        bp_id      = ls_bp_id
      IMPORTING
        headerdata = ls_headerdata
      TABLES
*       CONTACTDATA       =
        return     = lt_return.

    IF lt_return IS NOT INITIAL.
      "message container
      mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = mo_context->get_message_container( ).
    ENDIF.

*	Map properties from the backend to output response structure
    er_entity-businesspartnerid	= ls_headerdata-bp_id.
    er_entity-businesspartnerrole = ls_headerdata-bp_role.
    er_entity-emailaddress  = ls_headerdata-email_address.
    er_entity-companyname	= ls_headerdata-company_name.
    er_entity-currencycode  = ls_headerdata-currency_code.
    er_entity-city  = ls_headerdata-city.
    er_entity-street  = ls_headerdata-street.
    er_entity-country	= ls_headerdata-country.
    er_entity-addresstype	= ls_headerdata-address_type.


  ENDMETHOD.


  METHOD businesspartners_get_entityset.
**TRY.
*CALL METHOD SUPER->BUSINESSPARTNERS_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    DATA: ls_entity     LIKE LINE OF et_entityset,
          lt_headerdata TYPE TABLE OF bapi_epm_bp_header,
          ls_headerdata LIKE LINE OF lt_headerdata,
          lt_return     TYPE TABLE OF bapiret2.


*	Get data
    CALL FUNCTION 'BAPI_EPM_BP_GET_LIST'
      TABLES
        bpheaderdata = lt_headerdata
        return       = lt_return.
    IF lt_return IS NOT INITIAL. " Message Container
      mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = mo_context->get_message_container( ).
    ENDIF.

*	Map properties from the backend to output response structure
    LOOP AT lt_headerdata INTO ls_headerdata.
      ls_entity-businesspartnerid	  = ls_headerdata-bp_id.
      ls_entity-businesspartnerrole = ls_headerdata-bp_role.
      ls_entity-emailaddress        = ls_headerdata-email_address.
      ls_entity-companyname	        = ls_headerdata-company_name.
      ls_entity-currencycode        = ls_headerdata-currency_code.
      ls_entity-city                = ls_headerdata-city.
      ls_entity-street              = ls_headerdata-street.
      ls_entity-country             = ls_headerdata-country.
      ls_entity-addresstype         = ls_headerdata-address_type.

      APPEND ls_entity TO et_entityset.
      CLEAR ls_entity.
    ENDLOOP.
  ENDMETHOD.


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

  DATA: ls_bp_id           TYPE bapi_epm_bp_id,
        ls_bp_headerdata   TYPE bapi_epm_bp_header,
        ls_so_supplier     TYPE bapi_epm_supplier_name_range,
        lt_so_supplier     TYPE TABLE OF
                             bapi_epm_supplier_name_range,
        ls_businesspartner TYPE zcl_zgw100_course_mpc=>ts_businesspartner,
        lv_source_entity   TYPE /iwbep/mgw_tech_name.

  lv_source_entity = io_tech_request_context->get_source_entity_type_name( ).

*Handle navigation...
  CASE lv_sourcE_entity.
    WHEN zcl_zgw100_course_mpc=>gc_businesspartner.
      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_businesspartner ).

      ls_bp_id-bp_id = ls_businesspartner-businesspartnerid.
      CALL FUNCTION 'BAPI_EPM_BP_GET_DETAIL'
        EXPORTING
          bp_id      = ls_bp_id
        IMPORTING
          headerdata = ls_bp_headerdata
        TABLES
*         CONTACTDATA       =
          return     = lt_return.

      IF lt_return IS NOT INITIAL.
        " Message Container
        mo_context->get_message_container( )->add_messages_from_bapi( lt_return ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid            = /iwbep/cx_mgw_busi_exception=>business_error
            message_container = mo_context->get_message_container( ).
      ENDIF.

      ls_so_supplier-sign = 'I'.
      ls_so_supplier-option = 'EQ'.
      ls_so_supplier-low = ls_bp_headerdata-company_name.

      APPEND ls_so_supplier TO lt_so_supplier.
    WHEN OTHERS.
  ENDCASE.

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
