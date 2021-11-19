CLASS zabap010_mk_tr_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZABAP010_MK_TR_LIST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
      DATA ls_travel TYPE /dmo/travel.
      DATA lv_concat TYPE string.

      SELECT * FROM /dmo/travel
        INTO CORRESPONDING FIELDS OF @ls_travel.

      CONCATENATE ls_travel-travel_id
                  ls_travel-agency_id
                  ls_travel-customer_id
                  ls_travel-status
                  INTO lv_concat SEPARATED BY space.

      out->write( EXPORTING data = lv_concat ).
      ENDSELECT.
  ENDMETHOD.
ENDCLASS.
