CLASS zabap010_mk_select_customer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZABAP010_MK_SELECT_CUSTOMER IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA ls_travel TYPE zraph_mk_travel_info.
    DATA lv_concat TYPE string.
    CONSTANTS lc_customer_id TYPE /dmo/customer_id VALUE '000004'.

    SELECT * FROM /dmo/travel
        WHERE customer_id = @lc_customer_id
            INTO CORRESPONDING FIELDS OF @ls_travel.

        ls_travel-dayamount = ls_travel-end_date - ls_travel-begin_date + 1.

        DATA(lv_dayamount) = CONV string( ls_travel-dayamount ).

        CONCATENATE ls_travel-travel_id
                    ls_travel-agency_id
                    ls_travel-customer_id
                    ls_travel-begin_date
                    ls_travel-end_date
                    lv_dayamount

                    INTO lv_concat SEPARATED BY space.
        out->write( EXPORTING data = lv_concat ).



    ENDSELECT.


  ENDMETHOD.
ENDCLASS.
