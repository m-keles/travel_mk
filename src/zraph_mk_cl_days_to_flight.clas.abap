CLASS zraph_mk_cl_days_to_flight DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.

CLASS zraph_mk_cl_days_to_flight IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA(today) = cl_abap_context_info=>get_system_date( ).
    DATA bookings TYPE STANDARD TABLE OF zraph_mk_c_bookingwdtp WITH DEFAULT KEY.
    bookings = CORRESPONDING #( it_original_data ).

    " Loop over all requested bookings
    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      " Calculate DaysToFlight for the current booking instance
      <booking>-daystoflight = <booking>-flightdate - today.
    ENDLOOP.

    " Add booking instances with the added virtual field to the output parameter
    ct_calculated_data = CORRESPONDING #( bookings ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<element>).
      " When DaysOfFlight was requested we also need to load the FlightDate for calculation
      CASE <element>.
        WHEN 'DAYSTOFLIGHT'.
          APPEND 'FLIGHTDATE' TO et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
