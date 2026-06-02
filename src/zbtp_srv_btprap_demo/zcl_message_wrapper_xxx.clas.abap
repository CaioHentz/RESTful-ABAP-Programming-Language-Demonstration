CLASS zcl_message_wrapper_xxx DEFINITION
 PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .
    INTERFACES if_abap_behv_message.

    CONSTANTS:
      BEGIN OF date_interval,
        msgid TYPE symsgid VALUE 'ZMC_TRAVEL_xxx',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'BEGINDATE',
        attr2 TYPE scx_attrname VALUE 'ENDDATE',
        attr3 TYPE scx_attrname VALUE 'TRAVELID',
        attr4 TYPE scx_attrname VALUE '',
      END OF date_interval.

    CONSTANTS:
      BEGIN OF begin_date_before_system_date,
        msgid TYPE symsgid VALUE 'ZMC_TRAVEL_xxx',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'BEGINDATE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF begin_date_before_system_date.

     METHODS constructor
      IMPORTING
        severity   TYPE if_abap_behv_message=>t_severity
                          DEFAULT if_abap_behv_message=>severity-error
        textid     LIKE if_t100_message=>t100key OPTIONAL
        previous   TYPE REF TO cx_root OPTIONAL
        begindate  TYPE /dmo/begin_date OPTIONAL
        enddate    TYPE /dmo/end_date OPTIONAL
        travelid   TYPE /dmo/travel_id OPTIONAL.

    DATA begindate TYPE /dmo/begin_date READ-ONLY.
    DATA enddate TYPE /dmo/end_date READ-ONLY.
    DATA travelid TYPE string READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MESSAGE_WRAPPER_XXX IMPLEMENTATION.


METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      If_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      If_t100_message~t100key = textid.
    ENDIF.


    Me->if_abap_behv_message~m_severity = severity.
    Me->begindate = begindate.
    Me->enddate = enddate.
    Me->travelid = |{ travelid ALPHA = OUT }|.

  ENDMETHOD.
ENDCLASS.
