CLASS zcl_eml_delete_xxx DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EML_DELETE_XXX IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

  SELECT SINGLE travel_uuid
    FROM ztravel_axxx
    INTO @DATA(lv_traveluuid).

  MODIFY ENTITIES OF zr_travelxxx
    ENTITY travel
      DELETE FROM VALUE #(
        ( traveluuid = lv_traveluuid )
      )
    FAILED DATA(failed)
    REPORTED DATA(reported).

  COMMIT ENTITIES.

  out->write( |Travel deletado: { lv_traveluuid }| ).

ENDMETHOD.
ENDCLASS.
