CLASS zcl_eml_read_xxx DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EML_READ_XXX IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.
*read using first found travel in the database
SELECT SINGLE travel_uuid FROM ztravel_axxx INTO @DATA(lv_traveluuid).

    READ ENTITIES OF zr_travelxxx
         ENTITY Travel
            ALL FIELDS WITH
            VALUE #( ( TravelUUID = lv_traveluuid ) )
      RESULT DATA(travels)
      FAILED DATA(failedTravels)
      REPORTED DATA(reportedTravels).

     out->write( travels ).

        READ ENTITIES OF zr_travelxxx
          ENTITY travel BY \_booking
          ALL FIELDS
            WITH VALUE #( ( TravelUUID = lv_traveluuid ) )
      RESULT DATA(bookings)
      FAILED DATA(failedBookings)
      REPORTED DATA(reportedBookings).

    out->write( bookings ).

ENDMETHOD.
ENDCLASS.
