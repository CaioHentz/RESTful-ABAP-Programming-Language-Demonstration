CLASS zcl_eml_create_xxx DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EML_CREATE_XXX IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA create TYPE TABLE FOR CREATE zr_travelxxx.
*create using  copy of existing travel and booking record.
    SELECT SINGLE * FROM ztravel_axxx INTO @DATA(ls_travel).

    create = VALUE #( (
                  %cid                 = 'create_travel'
                  CustomerID           = ls_travel-customer_id
                  %control-CustomerID  = if_abap_behv=>mk-on
                  AgencyID             = ls_travel-agency_id
                  %control-AgencyID    = if_abap_behv=>mk-on
                  BeginDate            = cl_abap_context_info=>get_system_date( )
                  %control-BeginDate   = if_abap_behv=>mk-on
                  EndDate              = cl_abap_context_info=>get_system_date( ) + 10
                  %control-EndDate     = if_abap_behv=>mk-on
                  Description          = ls_travel-description
                  %control-Description = if_abap_behv=>mk-on
                  BookingFee           = ls_travel-booking_fee
                  %control-BookingFee  = if_abap_behv=>mk-on
                  CurrencyCode         = ls_travel-currency_code
                  %control-CurrencyCode  = if_abap_behv=>mk-on
                       ) ).

    MODIFY ENTITIES OF zr_travelxxx
      ENTITY travel
        CREATE FROM create
        MAPPED DATA(mapped)
        REPORTED DATA(reported)
        FAILED DATA(failed).

    COMMIT ENTITIES.

    DATA: newtravelUUID TYPE STRUCTURE FOR MAPPED EARLY zr_travelxxx\\travel.

    LOOP AT mapped-travel INTO newtravelUUID.

      out->write( 'New TravelUUID' ).
      out->write( newtravelUUID-TravelUUID  ).

      SELECT * FROM zr_travelxxx WHERE TravelUUID = @newtravelUUID-TravelUUID
       INTO TABLE @DATA(lt_new_travel).

      out->write( 'New Travel Record' ).
      out->write( lt_new_travel ).

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
