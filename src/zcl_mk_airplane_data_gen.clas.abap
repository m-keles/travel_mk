CLASS zcl_mk_airplane_data_gen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mk_airplane_data_gen IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    TYPES ltt_airplanes TYPE STANDARD TABLE OF zraph_mk_airpln WITH DEFAULT KEY.

    DATA(l_airplanes) = VALUE ltt_airplanes(
        ( type_id = '767-200' weight = 99999 )
        ( type_id = 'A320-200' weight = 70000 )
        ( type_id = '747-400' weight = 250000 )
     ).

    " clear first to avoid duplicates on multiple runs
    DELETE FROM zraph_mk_airpln.

    INSERT zraph_mk_airpln FROM TABLE @l_airplanes.

  ENDMETHOD.
ENDCLASS.
