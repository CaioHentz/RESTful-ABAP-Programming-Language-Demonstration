CLASS zcl_eml_update_xxx DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EML_UPDATE_XXX IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lv_flightDate TYPE /dmo/flight_date.
                 lv_flightDate = cl_abap_context_info=>get_system_date( ) + 10.
    DATA: update TYPE TABLE FOR UPDATE zr_travelxxx\\booking.

* update the first booking entry found on the database
    SELECT SINGLE booking_uuid, flight_date FROM zbooking_axxx INTO @DATA(ls_booking).

    out->write( 'Before Update' ).
    out->write( ls_booking ).

    APPEND VALUE #( Bookinguuid  = ls_booking-booking_uuid
                    FlightDate   = lv_flightDate
                            ) TO update.

    MODIFY ENTITIES OF zr_travelxxx
      ENTITY booking
        UPDATE FIELDS ( FlightDate ) WITH update
       FAILED DATA(failed)
       REPORTED DATA(reported).

    COMMIT ENTITIES.

    SELECT SINGLE booking_uuid, flight_date FROM zbooking_axxx
    WHERE booking_uuid = @ls_booking-booking_uuid
    INTO @DATA(ls_update).

    out->write( 'After Update' ).
    out->write( ls_update ).

  ENDMETHOD.
ENDCLASS.
