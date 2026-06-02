CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTravelID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~calculateTravelID.
    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.
    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.
    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD calculateTravelID.

    READ ENTITIES OF zr_travelxxx IN LOCAL MODE
      ENTITY Travel
        FIELDS ( TravelID ) WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    DELETE travels WHERE TravelID IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    SELECT SINGLE
        FROM  ztravel_axxx
        FIELDS MAX( travel_id ) AS travelID
        INTO @DATA(max_travelID).

    MODIFY ENTITIES OF zr_travelxxx IN LOCAL MODE
    ENTITY Travel
      UPDATE
        FROM VALUE #( FOR travel IN travels INDEX INTO i (
          %tky            = travel-%tky
          TravelID      = max_travelID + i
          %control-TravelID = if_abap_behv=>mk-on ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.



METHOD validateDates.

  READ ENTITIES OF zr_travelxxx IN LOCAL MODE
      ENTITY Travel
        FIELDS ( TravelID BeginDate EndDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
" Clear state messages that might exist
       APPEND VALUE #( %tky = travel-%tky
                      %state_area = 'VALIDATE_INTERVAL' ) TO reported-travel.
       APPEND VALUE #(  %tky = travel-%tky
                        %state_area = 'VALIDATE_SYSTEM' ) TO reported-travel.

      IF travel-EndDate < travel-BeginDate.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky               = travel-%tky
                        %state_area = ' VALIDATE_INTERVAL '
                        %msg =  NEW zcl_message_wrapper_xxx(
                                                       severity = if_abap_behv_message=>severity-error
                                                       textid = zcl_message_wrapper_xxx=>date_interval
                                                       begindate = travel-BeginDate
                                                       enddate = travel-EndDate
                                                       travelid = travel-TravelID )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF
      travel-BeginDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky  = travel-%tky
                        %state_area   = 'VALIDATE_SYSTEM'
                        %msg = NEW zcl_message_wrapper_xxx(
                            severity  = if_abap_behv_message=>severity-error
                            textid = zcl_message_wrapper_xxx=>begin_date_before_system_date
                         begindate = travel-BeginDate )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

    METHOD acceptTravel.

    MODIFY ENTITIES OF zr_travelxxx IN LOCAL MODE
      ENTITY Travel
         UPDATE
           FIELDS ( TravelStatus )
           WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             TravelStatus = 'A' ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zr_travelxxx IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels
                        ( %tky   = travel-%tky
                          %param = travel ) ).
  ENDMETHOD.


 METHOD rejectTravel.

    MODIFY ENTITIES OF zr_travelxxx IN LOCAL MODE
      ENTITY Travel
         UPDATE
           FIELDS ( TravelStatus )
           WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             TravelStatus = 'X' ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zr_travelxxx IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels
                        ( %tky   = travel-%tky
                          %param = travel ) ).

  ENDMETHOD.


    METHOD get_instance_features.

      READ ENTITIES OF zr_travelxxx IN LOCAL MODE
          ENTITY Travel
            FIELDS ( TravelStatus )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_travel)
          FAILED failed.


        result = VALUE #( FOR ls_travel IN lt_travel LET
                  is_accepted =   COND #( WHEN ls_travel-TravelStatus = 'A'
                                                THEN if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled  )
                  is_rejected =   COND #( WHEN ls_travel-TravelStatus = 'X'
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled )
              IN
                ( %tky                 = ls_travel-%tky
                  %action-acceptTravel = is_accepted
                  %action-rejectTravel = is_rejected
                  %field-BookingFee     = COND #( WHEN ls_travel-TravelStatus = 'A'
                                          THEN if_abap_behv=>fc-f-read_only
                                          ELSE if_abap_behv=>fc-f-unrestricted )
                  %assoc-_Booking       = COND #( WHEN ls_travel-TravelStatus = 'X'
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled )

                 ) ).

  ENDMETHOD.


    METHOD get_global_authorizations.

      IF requested_authorizations-%create EQ if_abap_behv=>mk-on.
          AUTHORITY-CHECK OBJECT 'ZAO_TRV###' ID 'ACTVT' FIELD '01'.
          result-%create = COND #( WHEN sy-subrc = 0 THEN
          if_abap_behv=>auth-allowed ELSE
          if_abap_behv=>auth-unauthorized ).
        ENDIF.

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on OR
         requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.
          AUTHORITY-CHECK OBJECT 'ZAO_TRV###'  ID 'ACTVT' FIELD '02'.
          result-%update = COND #( WHEN sy-subrc = 0 THEN
          if_abap_behv=>auth-allowed ELSE
          if_abap_behv=>auth-unauthorized ).
      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.
          AUTHORITY-CHECK OBJECT 'ZAO_TRV###'  ID 'ACTVT' FIELD '06'.
          result-%delete = COND #( WHEN sy-subrc = 0 THEN
          if_abap_behv=>auth-allowed ELSE
          if_abap_behv=>auth-unauthorized ).
      ENDIF.

    ENDMETHOD.


ENDCLASS.

CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateBookingID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateBookingID.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateBookingID.

    DATA max_bookingID TYPE /dmo/booking_id.
    DATA update TYPE TABLE FOR UPDATE zr_travelxxx\\Booking.

    READ ENTITIES OF zr_travelxxx IN LOCAL MODE
    ENTITY Booking BY \_Travel
      FIELDS ( TravelUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    READ ENTITIES OF zr_travelxxx IN LOCAL MODE
    ENTITY Travel BY \_Booking
    ALL FIELDS WITH
    CORRESPONDING #( travels )
    RESULT DATA(bookings).

    LOOP AT travels INTO DATA(travel).
      max_bookingID = '0000'.
      LOOP AT bookings INTO DATA(booking) WHERE TravelUUID = travel-TravelUUID.
        IF booking-BookingID > max_bookingID.
          max_bookingID = booking-BookingID.
        ENDIF.
      ENDLOOP.

      LOOP AT bookings INTO booking WHERE BookingID IS INITIAL
                                    AND TravelUUID = travel-TravelUUID.
        max_bookingID += 1.
        APPEND VALUE #( %tky      = booking-%tky
                        BookingID = max_bookingID
                      ) TO update.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zr_travelxxx IN LOCAL MODE
    ENTITY Booking
      UPDATE FIELDS ( BookingID ) WITH update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.
ENDCLASS.
