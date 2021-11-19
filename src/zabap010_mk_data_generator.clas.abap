CLASS zabap010_mk_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZABAP010_MK_DATA_GENERATOR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA roomreservations TYPE STANDARD TABLE OF zraph_mk_roomrsv WITH DEFAULT KEY.

    "Clear personal travel table and fill it from /DMO/ referance table
    DELETE FROM zraph_mk_travel.
    INSERT zraph_mk_travel FROM ( SELECT * FROM /dmo/a_travel_d ).
    out->write( 'Travel data copied.' ).

    "Clear personal booking table and fill it from /DMO/ referance table
    DELETE FROM zraph_mk_booking.
    INSERT zraph_mk_booking FROM ( SELECT * FROM /dmo/a_booking_d ).
    out->write( 'Booking data copied.' ).

    "Clear personal booking supplement table and fill it from /DMO/ referance table
    DELETE FROM zraph_mk_booksup.
    INSERT zraph_mk_booksup FROM ( SELECT * FROM /dmo/a_bksuppl_d ).
    out->write( 'Booking supplement data copied.' ).


      " Clear personal room reservation table and fill it from data generated
    " based on existing travels and hotels

    SELECT COUNT( * ) FROM zraph_hotel INTO @DATA(hotel_count).
    IF hotel_count = 0.
      out->write( 'Aborted: No hotels found!' ).
      RETURN.
    ENDIF.
    DELETE FROM zraph_mk_roomrsv.

    SELECT travel_uuid, begin_date, end_date, total_price, currency_code
      FROM zraph_mk_travel INTO TABLE @DATA(travels).
    SELECT hotel_id FROM zraph_hotel INTO TABLE @DATA(hotels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      DATA(index) = sy-tabix.
      READ TABLE hotels INDEX index MOD hotel_count + 1 INTO DATA(hotel).
      IF index MOD 4 <= 2.
        APPEND VALUE #( parent_uuid   = <travel>-travel_uuid
                        roomrsv_uuid  = cl_system_uuid=>create_uuid_x16_static( )
                        roomrsv_id    = '000001'
                        hotel_id      = hotel-hotel_id
                        begin_date    = <travel>-begin_date
                        end_date      = <travel>-end_date
                        room_type     = 'S'
                        roomrsv_price = <travel>-total_price * '0.15'
                        currency_code = <travel>-currency_code ) TO roomreservations.
        IF index MOD 4 = 1.
          APPEND VALUE #( parent_uuid   = <travel>-travel_uuid
                          roomrsv_uuid  = cl_system_uuid=>create_uuid_x16_static( )
                          roomrsv_id    = '000002'
                          hotel_id      = hotel-hotel_id
                          begin_date    = <travel>-begin_date
                          end_date      = <travel>-end_date
                          room_type     = 'D'
                          roomrsv_price = <travel>-total_price * '0.25'
                          currency_code = <travel>-currency_code ) TO roomreservations.
        ELSEIF index MOD 4 = 2.
          APPEND VALUE #( parent_uuid   = <travel>-travel_uuid
                          roomrsv_uuid  = cl_system_uuid=>create_uuid_x16_static( )
                          roomrsv_id    = '000002'
                          hotel_id      = hotel-hotel_id
                          begin_date    = <travel>-begin_date
                          end_date      = <travel>-end_date
                          room_type     = 'F'
                          roomrsv_price = <travel>-total_price * '0.4'
                          currency_code = <travel>-currency_code ) TO roomreservations.
        ENDIF.
      ENDIF.
      IF index MOD 4 = 3.
        APPEND VALUE #( parent_uuid   = <travel>-travel_uuid
                        roomrsv_uuid  = cl_system_uuid=>create_uuid_x16_static( )
                        roomrsv_id    = '000001'
                        hotel_id      = hotel-hotel_id
                        begin_date    = <travel>-begin_date
                        end_date      = <travel>-end_date
                        room_type     = 'E'
                        roomrsv_price = <travel>-total_price * '0.7'
                        currency_code = <travel>-currency_code ) TO roomreservations.
      ENDIF.
    ENDLOOP.
    INSERT zraph_mk_roomrsv FROM TABLE @roomreservations.
    out->write( 'Room reservation data generated.' ).

  ENDMETHOD.
ENDCLASS.
