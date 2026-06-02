CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ Travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Travel.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ Travel\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE Travel\_Booking.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD create.

  DATA:   messages   TYPE /dmo/if_flight_legacy=>tt_message,
                 travel_legacy_in  TYPE /dmo/travel,
                 travel_legacy_out TYPE /dmo/travel.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_create>).

      travel_legacy_in = CORRESPONDING #( <travel_create> MAPPING FROM ENTITY USING CONTROL ).

     CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
        is_travel   = CORRESPONDING /dmo/if_flight_legacy=>ts_travel_in( travel_legacy_in )
        IMPORTING
          es_travel   = travel_legacy_out
          et_messages = messages.

      IF messages IS INITIAL.
        APPEND VALUE #( %cid = <travel_create>-%cid travelid = travel_legacy_out-travel_id )
        TO mapped-travel.
      ELSE.
        APPEND VALUE #( %cid = <travel_create>-%cid ) TO failed-travel.
        APPEND VALUE #( travelid = travel_legacy_in-travel_id
                        %msg = new_message( id = messages[ 1 ]-msgid
                                            number = messages[ 1 ]-msgno
                                            v1 = messages[ 1 ]-msgv1
                                            v2 = messages[ 1 ]-msgv2
                                            v3 = messages[ 1 ]-msgv3
                                            v4 = messages[ 1 ]-msgv4
                                            severity = CONV #( messages[ 1 ]-msgty ) )
       ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.

   DATA: legacy_travel_in  TYPE /dmo/travel,
               legacy_travel_x   TYPE /dmo/s_travel_inx,
               messages TYPE /dmo/if_flight_legacy=>tt_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_update>).

      legacy_travel_in = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY  ).
      legacy_travel_x-travel_id = <travel_update>-TravelID.
      legacy_travel_x-_intx = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY  ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( legacy_travel_in )
          is_travelx  = legacy_travel_x
        IMPORTING
          et_messages = messages.

      IF messages IS NOT INITIAL.
        APPEND VALUE #( travelid = legacy_travel_in-travel_id ) TO failed-travel.
        APPEND VALUE #( travelid = legacy_travel_in-travel_id
                        %msg = new_message( id = messages[ 1 ]-msgid
                                            number = messages[ 1 ]-msgno
                                            v1 = messages[ 1 ]-msgv1
                                            v2 = messages[ 1 ]-msgv2
                                            v3 = messages[ 1 ]-msgv3
                                            v4 = messages[ 1 ]-msgv4
                                            severity = CONV #( messages[ 1 ]-msgty ) )
       ) TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.

   DATA messages TYPE /dmo/if_flight_legacy=>tt_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <key>-travelid
        IMPORTING
          et_messages  = messages.

      IF messages IS INITIAL.
        APPEND VALUE #( travelid = <key>-travelid ) TO mapped-travel.
      ELSE.
        APPEND VALUE #( travelid = <key>-travelid ) TO failed-travel.
        APPEND VALUE #( travelid = <key>-travelid
                        %msg = new_message( id = messages[ 1 ]-msgid
                                            number = messages[ 1 ]-msgno
                                            v1 = messages[ 1 ]-msgv1
                                            v2 = messages[ 1 ]-msgv2
                                            v3 = messages[ 1 ]-msgv3
                                            v4 = messages[ 1 ]-msgv4
                                            severity = CONV #( messages[ 1 ]-msgty ) )
       ) TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
  DATA: legacy_travel_out TYPE /dmo/travel,
               messages          TYPE /dmo/if_flight_legacy=>tt_message.

  LOOP AT keys INTO DATA(key) GROUP BY key-TravelId.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
      EXPORTING
        iv_travel_id = key-travelid
      IMPORTING
        es_travel    = legacy_travel_out
        et_messages  = messages.

    IF messages IS INITIAL.
       INSERT CORRESPONDING #( legacy_travel_out MAPPING TO ENTITY )
             INTO TABLE result.
    ELSE.
      APPEND VALUE #( travelid = key-travelid ) TO failed-travel.
      LOOP AT messages INTO DATA(message).
        APPEND VALUE #( travelid = key-travelid
                        %msg = new_message( id = message-msgid
                                            number = message-msgno
                                            v1 = message-msgv1
                                            v2 = message-msgv2
                                            v3 = message-msgv3
                                            v4 = message-msgv4
                                            severity = CONV #( message-msgty ) )
       ) TO reported-travel.
      ENDLOOP.
    ENDIF.

  ENDLOOP.
ENDMETHOD.


  METHOD lock.
  TRY.
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( iv_name = '/DMO/ETRAVEL' ).
      CATCH cx_abap_lock_failure.
        "handle exception
    ENDTRY.


    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      TRY.
          lock->enqueue(
              it_parameter  = VALUE #( (  name = 'TRAVEL_ID' value = REF #( <key>-travelid ) ) )
          ).
          CATCH cx_abap_foreign_lock INTO DATA(lx_foreign_lock).

          APPEND VALUE #( travelid = <key>-travelid ) TO failed-travel.
          APPEND VALUE #( travelid = <key>-travelid
                          %msg = new_message( id = '/DMO/CM_FLIGHT_LEGAC'
                                              number = '032'
                                              v1 = <key>-travelid
                                              v2 = lx_foreign_lock->user_name
                                              severity = CONV #( 'E' ) )
         ) TO reported-travel.

        CATCH cx_abap_lock_failure.
          "handle exception
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


  METHOD rba_Booking.

  DATA:   legacy_parent_entity_out  TYPE /dmo/travel,
                 legacy_booking_out TYPE /dmo/if_flight_legacy=>tt_booking,
                entity     LIKE LINE OF result,
                message     TYPE /dmo/if_flight_legacy=>tt_message.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<key_rba>) GROUP  BY <key_rba>-TravelId.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <key_rba>-travelid
        IMPORTING
          es_travel    = legacy_parent_entity_out
          et_booking   = legacy_booking_out
          et_messages  = message.

      IF message IS INITIAL.
        LOOP AT legacy_booking_out ASSIGNING FIELD-SYMBOL(<fs_booking>).
           INSERT
            VALUE #(
                source-%key = <key_rba>-%key
                target-%key = VALUE #(
                  TravelID  = <fs_booking>-travel_id
                  BookingID = <fs_booking>-booking_id
              )
            )
            INTO TABLE association_links.

          IF result_requested = abap_true.
            entity = CORRESPONDING #( <fs_booking> MAPPING TO ENTITY ).
            INSERT entity INTO TABLE result.
          ENDIF.
        ENDLOOP.
      ELSE.
        failed-travel = VALUE #(
          BASE failed-travel
          FOR msg IN message (
            %key = <key_rba>-%key
            %fail-cause = COND #(
              WHEN msg-msgty = 'E' AND  ( msg-msgno = '016' OR msg-msgno = '009' )
              THEN if_abap_behv=>cause-not_found
              ELSE if_abap_behv=>cause-unspecific
            )
          )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD cba_Booking.

  DATA: messages        TYPE /dmo/if_flight_legacy=>tt_message,
               lt_bookings     TYPE /dmo/if_flight_legacy=>tt_booking,
               entity          TYPE /dmo/booking,
               last_booking_id TYPE /dmo/booking_id VALUE '0'.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<entity_booking>).
      DATA(travelid) = <entity_booking>-travelid.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = travelid
        IMPORTING
          et_booking   = lt_bookings
          et_messages  = messages.

      IF messages IS INITIAL.
        IF lt_bookings IS NOT INITIAL.
          last_booking_id = lt_bookings[ lines( lt_bookings ) ]-booking_id.
        ENDIF.

        LOOP AT <entity_booking>-%target ASSIGNING FIELD-SYMBOL(<entity>).
          entity = CORRESPONDING #( <entity> MAPPING FROM ENTITY USING CONTROL   ) .
          last_booking_id += 1.
          entity-booking_id = last_booking_id.
          CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
            EXPORTING
              is_travel   = VALUE /dmo/s_travel_in( travel_id = travelid )
              is_travelx  = VALUE /dmo/s_travel_inx( travel_id = travelid )
              it_booking  =
              VALUE /dmo/if_flight_legacy=>tt_booking_in( ( CORRESPONDING #( entity ) ) )
              it_bookingx = VALUE /dmo/if_flight_legacy=>tt_booking_inx(
                (
                  booking_id  = entity-booking_id
                  action_code = /dmo/if_flight_legacy=>action_code-create
                )
              )
            IMPORTING
              et_messages = messages.
          IF messages IS INITIAL.
            INSERT
              VALUE #(
                %cid = <entity>-%cid
                travelid = travelid
                bookingid = entity-booking_id
              )
              INTO TABLE mapped-booking.
          ELSE.
            INSERT VALUE #( %cid = <entity>-%cid travelid = travelid ) INTO TABLE failed-booking.
            LOOP AT messages INTO DATA(message) WHERE msgty = 'E' OR msgty = 'A'.
             INSERT
                VALUE #(
                  %cid     = <entity>-%cid
                  travelid = <entity>-TravelID
                  %msg     = new_message(
                    id       = message-msgid
                    number   = message-msgno
                    severity = if_abap_behv_message=>severity-error
                    v1       = message-msgv1
                    v2       = message-msgv2
                    v3       = message-msgv3
                    v4       = message-msgv4
                  )
                )
                INTO TABLE reported-booking.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      ELSE.
        APPEND VALUE #( travelid = travelid ) TO failed-travel.
        APPEND VALUE #( travelid = travelid
                        %msg = new_message( id = messages[ 1 ]-msgid
                                            number = messages[ 1 ]-msgno
                                            v1 = messages[ 1 ]-msgv1
                                            v2 = messages[ 1 ]-msgv2
                                            v3 = messages[ 1 ]-msgv3
                                            v4 = messages[ 1 ]-msgv4
                                            severity = CONV #( messages[ 1 ]-msgty ) )
       ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZR_TRAVEL_UXXX DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_TRAVEL_UXXX IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

  METHOD cleanup.
  CALL FUNCTION '/DMO/FLIGHT_TRAVEL_INITIALIZE'.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.


ENDCLASS.
