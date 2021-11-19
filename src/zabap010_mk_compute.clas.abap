CLASS zabap010_mk_compute DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZABAP010_MK_COMPUTE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA d1(2) TYPE C.
    DATA d2 LIKE d1.
    DATA minimum_value TYPE I VALUE 10.


    DATA:
        lv_int1 TYPE i,
        lv_int2 TYPE i,
        lv_op(1) TYPE c,
        lv_result TYPE p DECIMALS 2.


    lv_int1 = 4.
    lv_op = '/'.
    lv_int2 = 0.


    IF NOT ( lv_op = '+' OR
             lv_op = '-' OR
             lv_op = '*' OR
             lv_op = '/'
           ).

        out->write( EXPORTING data = 'Invalid' ).
    ELSEIF ( lv_op = '/' AND lv_int2 = 0 ).
         out->write( EXPORTING data = 'Number 0' ).
    ELSE.
        CASE lv_op.
            WHEN '+'.
                lv_result = lv_int1 + lv_int2.
            WHEN '-'.
                lv_result = lv_int1 - lv_int2.
            WHEN '*'.
                lv_result = lv_int1 * lv_int2.
            WHEN '/'.
                lv_result = lv_int1 / lv_int2.
        ENDCASE.
        DATA(lv_result2) = |Result: | && lv_result.
        out->write( EXPORTING data = lv_result2 ).

     ENDIF.

  ENDMETHOD.
ENDCLASS.
