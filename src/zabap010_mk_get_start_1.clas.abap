CLASS zabap010_mk_get_start_1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZABAP010_MK_GET_START_1 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA lv_customer_id TYPE /dmo/customer_id.
    DATA ls_customer TYPE /dmo/customer.

    lv_customer_id = '000003'.
    SELECT SINGLE * FROM /dmo/customer
    WHERE customer_id = @lv_customer_id
      INTO @ls_customer.

      out->write( EXPORTING data = ls_customer ).

  ENDMETHOD.
ENDCLASS.
