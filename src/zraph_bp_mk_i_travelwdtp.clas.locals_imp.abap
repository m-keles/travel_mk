CLASS lhc_roomreservation DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR RoomReservation~calculateTotalPrice.

ENDCLASS.

CLASS lhc_roomreservation IMPLEMENTATION.

  METHOD calculateTotalPrice.
       READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY roomreservation BY \_travel
          FROM CORRESPONDING #( keys )
        LINK DATA(lt_link).

      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY travel
        EXECUTE recalctotalprice
        FROM VALUE #( FOR <link> IN lt_link ( COND #( WHEN <link>-target-%is_draft = if_abap_behv=>mk-off THEN VALUE #( traveluuid = <link>-target-traveluuid ) ) ) )
        REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_bookingsupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSupplement~calculateTotalPrice.
    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR BookingSupplement~validateSupplement.

ENDCLASS.

CLASS lhc_bookingsupplement IMPLEMENTATION.

  METHOD calculateTotalPrice.
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY bookingsupplement BY \_travel
          FROM CORRESPONDING #( keys )
        LINK DATA(lt_link).

      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY travel
        EXECUTE recalctotalprice
        FROM VALUE #( FOR <link> IN lt_link ( COND #( WHEN <link>-target-%is_draft = if_abap_behv=>mk-off THEN VALUE #( traveluuid = <link>-target-traveluuid ) ) ) )
        REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

  METHOD validateSupplement.
      " Read relevant booking supplement instance data
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY bookingsupplement
          FIELDS ( supplementid )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_supplement).

      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY bookingsupplement BY \_travel
          FROM CORRESPONDING #( lt_supplement )
        LINK DATA(lt_link).

      " Get Supplement Master Data for comparison
      SELECT FROM /dmo/i_supplement AS md_supplement
        INNER JOIN @lt_supplement AS supplement ON supplement~supplementid = md_supplement~supplementid
        FIELDS md_supplement~supplementid
        INTO TABLE @DATA(lt_supplement_db).

      " Loop over all booking supplement instances to be saved
      LOOP AT lt_supplement INTO DATA(ls_supplement).
        APPEND VALUE #(  %tky               = ls_supplement-%tky
                         %state_area        = 'VALIDATE_SUPPLEMENT' ) TO reported-booking.

        " Raise messages for empty supplement ids
        IF ls_supplement-supplementid IS  INITIAL.
          APPEND VALUE #( %tky = ls_supplement-%tky ) TO failed-bookingsupplement.
          APPEND VALUE #( %tky                  = ls_supplement-%tky
                          %state_area           = 'VALIDATE_SUPPLEMENT'
                          %msg                  = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                               number   = '012' " Supplement is initial
                                                               severity = if_abap_behv_message=>severity-error )
                          %path                 = VALUE #( travel-%tky = lt_link[ KEY draft COMPONENTS source-%tky = ls_supplement-%tky ]-target-%tky )
                          %element-supplementid = if_abap_behv=>mk-on ) TO reported-bookingsupplement.

        " Raise messages for non existing supplement ids
        ELSEIF ls_supplement-supplementid IS NOT INITIAL AND NOT line_exists( lt_supplement_db[ supplementid = ls_supplement-supplementid ] ).
          APPEND VALUE #( %tky = ls_supplement-%tky ) TO failed-bookingsupplement.
          APPEND VALUE #( %tky                  = ls_supplement-%tky
                          %state_area           = 'VALIDATE_SUPPLEMENT'
                          %msg                  = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                               number   = '013' " Supplement &1 unknown
                                                               v1       = ls_supplement-supplementid
                                                               severity = if_abap_behv_message=>severity-error )
                          %path                 = VALUE #( travel-%tky = lt_link[ KEY draft COMPONENTS source-%tky = ls_supplement-%tky ]-target-%tky )
                          %element-supplementid = if_abap_behv=>mk-on ) TO reported-bookingsupplement.
        ENDIF.
      ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

    METHODS setBookingDate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~setBookingDate.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateCustomer.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD calculateTotalPrice.
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY booking BY \_travel
          FROM CORRESPONDING #( keys )
        LINK DATA(lt_link).

      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY travel
        EXECUTE recalctotalprice
        FROM VALUE #( FOR <link> IN lt_link ( COND #( WHEN <link>-target-%is_draft = if_abap_behv=>mk-off THEN VALUE #( traveluuid = <link>-target-traveluuid ) ) ) )
        REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

  METHOD setBookingDate.
      " Read relevant booking instances
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY booking
          FIELDS ( bookingdate )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_booking).

      " Loop over bookings and set system date as booking date
      LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<ls_booking>) WHERE bookingdate IS INITIAL.
        <ls_booking>-bookingdate = cl_abap_context_info=>get_system_date( ).
      ENDLOOP.

      " Save changes via EML
      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY booking
          UPDATE FIELDS ( bookingdate )
          WITH CORRESPONDING #( lt_booking )
        REPORTED DATA(lt_reported).

      " Forward reported instances
      reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

  METHOD validateCustomer.
      " Read relevant booking instance data
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY booking
          FIELDS (  customerid )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_booking).

      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY booking BY \_travel
          FROM CORRESPONDING #( lt_booking )
        LINK DATA(lt_link).

      " Get Customer Master Data for comparison
      SELECT FROM /dmo/customer AS md_customer
        INNER JOIN @lt_booking AS book ON book~customerid = md_customer~customer_id
        FIELDS customer_id
        INTO TABLE @DATA(lt_customer_db).

      " Loop over all travel instances to be saved
      LOOP AT lt_booking INTO DATA(ls_booking).
        APPEND VALUE #(  %tky               = ls_booking-%tky
                         %state_area        = 'VALIDATE_CUSTOMER' ) TO reported-booking.

        " Raise messages for empty customer ids
        IF ls_booking-customerid IS  INITIAL.
          APPEND VALUE #( %tky = ls_booking-%tky ) TO failed-booking.
          APPEND VALUE #( %tky                = ls_booking-%tky
                          %state_area         = 'VALIDATE_CUSTOMER'
                          %msg                = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                             number   = '005' " Customer is initial
                                                             severity = if_abap_behv_message=>severity-error )
                          %path               = VALUE #( travel-%tky = lt_link[ KEY draft COMPONENTS source-%tky = ls_booking-%tky ]-target-%tky )
                          %element-customerid = if_abap_behv=>mk-on ) TO reported-booking.

        " Raise messages for non existing customer ids
        ELSEIF ls_booking-customerid IS NOT INITIAL AND NOT line_exists( lt_customer_db[ customer_id = ls_booking-customerid ] ).
          APPEND VALUE #(  %tky = ls_booking-%tky ) TO failed-booking.
          APPEND VALUE #( %tky                = ls_booking-%tky
                          %state_area         = 'VALIDATE_CUSTOMER'
                          %msg                = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                             number   = '006' " Customer &1 unknown
                                                             v1       = ls_booking-customerid
                                                             severity = if_abap_behv_message=>severity-error )
                          %path               = VALUE #( travel-%tky = lt_link[ KEY draft COMPONENTS source-%tky = ls_booking-%tky ]-target-%tky )
                          %element-customerid = if_abap_behv=>mk-on ) TO reported-booking.
        ENDIF.
      ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.
    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejecttravel RESULT result.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.

    METHODS setinitialstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~setinitialstatus.

    METHODS settravelid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~settravelid.
    METHODS validateagency FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateagency.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedates.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
      READ ENTITIES OF ZRAPH_MK_I_TravelWDTP IN LOCAL MODE
        ENTITY Travel
          FIELDS ( OverallStatus )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

        result = VALUE #( FOR ls_travel IN lt_travel
                              ( %tky                   = ls_travel-%tky
                                %field-BookingFee      = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                                 THEN if_abap_behv=>fc-f-read_only
                                                                 ELSE if_abap_behv=>fc-f-unrestricted )
                                %action-acceptTravel   = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )
                                %action-rejectTravel   = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )
                                %assoc-_Booking        = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                THEN if_abap_behv=>fc-o-disabled
                                                                ELSE if_abap_behv=>fc-o-enabled )
                              ) ).
  ENDMETHOD.



  METHOD acceptTravel.
      "Modify travel instance
      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
         ENTITY travel
          UPDATE FIELDS ( overallstatus )
          WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                          overallstatus = 'A' ) )
      FAILED failed
      REPORTED reported.

      "Read changed data for action result
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
         ENTITY travel
          ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

      result = VALUE #( FOR travel IN lt_travel ( %tky   = travel-%tky
                                                  %param = travel ) ).
  ENDMETHOD.




  METHOD rejectTravel.
            "Modify travel instance
          MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
             ENTITY travel
              UPDATE FIELDS ( overallstatus )
              WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                              overallstatus = 'X' ) )
          FAILED failed
          REPORTED reported.

          "Read changed data for action result
          READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
             ENTITY travel
              ALL FIELDS WITH
              CORRESPONDING #( keys )
            RESULT DATA(lt_travel).

          result = VALUE #( FOR travel IN lt_travel ( %tky   = travel-%tky
                                                      %param = travel ) ).
      ENDMETHOD.



      METHOD reCalcTotalPrice.

      TYPES: BEGIN OF ty_amount_per_currencycode,
               amount        TYPE /dmo/total_price,
               currency_code TYPE /dmo/currency_code,
             END OF ty_amount_per_currencycode.

      DATA: amount_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

      " Read all relevant travel instances.
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
           ENTITY travel
              FIELDS ( bookingfee currencycode )
              WITH CORRESPONDING #( keys )
           RESULT DATA(lt_travel)
           FAILED failed.

      DELETE lt_travel WHERE currencycode IS INITIAL.

      LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
        " Set the start for the calculation by adding the booking fee.
        amount_per_currencycode = VALUE #( ( amount        = <fs_travel>-bookingfee
                                             currency_code = <fs_travel>-currencycode ) ).

        " Read all associated room reservation and add them to the total price.
        READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
          ENTITY travel BY \_roomreservation
            FIELDS ( roomrsvprice currencycode )
          WITH VALUE #( ( %key = <fs_travel>-%key ) )
          RESULT DATA(lt_roomreservation).

        LOOP AT lt_roomreservation INTO DATA(roomreservation) WHERE currencycode IS NOT INITIAL.
          COLLECT VALUE ty_amount_per_currencycode( amount        = roomreservation-roomrsvprice
                                                    currency_code = roomreservation-currencycode ) INTO amount_per_currencycode.
        ENDLOOP.

        " Read all associated bookings and add them to the total price.
        READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
          ENTITY travel BY \_booking
            FIELDS ( flightprice currencycode )
          WITH VALUE #( ( %key = <fs_travel>-%key ) )
          RESULT DATA(lt_booking).

        LOOP AT lt_booking INTO DATA(booking) WHERE currencycode IS NOT INITIAL.
          COLLECT VALUE ty_amount_per_currencycode( amount        = booking-flightprice
                                                    currency_code = booking-currencycode ) INTO amount_per_currencycode.
        ENDLOOP.

        " Read all associated booking supplements and add them to the total price.
        READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
          ENTITY booking BY \_bookingsupplement
            FIELDS (  price currencycode )
          WITH VALUE #( FOR rba_booking IN lt_booking ( %tky = rba_booking-%tky ) )
          RESULT DATA(lt_bookingsupplement).

        LOOP AT lt_bookingsupplement INTO DATA(bookingsupplement) WHERE currencycode IS NOT INITIAL.
          COLLECT VALUE ty_amount_per_currencycode( amount        = bookingsupplement-price
                                                      currency_code = bookingsupplement-currencycode ) INTO amount_per_currencycode.
        ENDLOOP.

        CLEAR <fs_travel>-totalprice.
        LOOP AT amount_per_currencycode INTO DATA(single_amount_per_currencycode).
          " If needed do a Currency Conversion
          IF single_amount_per_currencycode-currency_code = <fs_travel>-currencycode.
            <fs_travel>-totalprice += single_amount_per_currencycode-amount.
          ELSE.
            /dmo/cl_flight_amdp=>convert_currency(
               EXPORTING
                 iv_amount                   =  single_amount_per_currencycode-amount
                 iv_currency_code_source     =  single_amount_per_currencycode-currency_code
                 iv_currency_code_target     =  <fs_travel>-currencycode
                 iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
               IMPORTING
                 ev_amount                   = DATA(total_booking_price_per_curr)
              ).
            <fs_travel>-totalprice += total_booking_price_per_curr.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      " write back the modified total_price of travels
      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY travel
          UPDATE FIELDS ( totalprice )
          WITH CORRESPONDING #( lt_travel ).
  ENDMETHOD.



  METHOD calculateTotalPrice.
      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY travel
          EXECUTE recalctotalprice
          FROM CORRESPONDING #( keys )
        REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

  METHOD setInitialStatus.
      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY travel
          UPDATE SET FIELDS
          WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                          overallstatus = 'O' ) )
      REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

  METHOD setTravelID.
        "Read travel entity
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY travel
          FIELDS ( travelid )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

      " remove lines where TravelID is already filled.
      DELETE lt_travel WHERE TravelID IS NOT INITIAL.
      CHECK lt_travel IS NOT INITIAL.

      " Select max travel ID
      SELECT SINGLE
          FROM  ZRAPH_MK_Travel
          FIELDS MAX( travel_id )
          INTO @DATA(max_travelid).

      " Set the travel ID
      MODIFY ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
      ENTITY Travel
        UPDATE
          FROM VALUE #( FOR ls_travel IN lt_travel INDEX INTO i (
            %tky              = ls_travel-%tky
            TravelID          = max_travelid + i
            %control-TravelID = if_abap_behv=>mk-on ) )
        REPORTED DATA(update_reported).

      reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD validateAgency.
      " Read relevant travel instances
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
        ENTITY travel
          FIELDS ( agencyid )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

      " Get Agency Master Data for comparison
      SELECT FROM /dmo/agency AS agency
        INNER JOIN @lt_travel AS travel ON travel~agencyid = agency~agency_id
        FIELDS agency_id
        INTO TABLE @DATA(lt_agency_db).


      " Loop over all travel instances to be saved
      LOOP AT lt_travel INTO DATA(ls_travel).
        APPEND VALUE #( %tky               = ls_travel-%tky
                        %state_area        = 'VALIDATE_AGENCY' ) TO reported-travel.

        " Raise messages for empty agency ids
        IF ls_travel-agencyid IS INITIAL.
          APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.

          APPEND VALUE #( %tky                = ls_travel-%tky
                          %state_area         = 'VALIDATE_AGENCY'
                          %msg                = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                             number   = '007' " Agency is initial
                                                             severity = if_abap_behv_message=>severity-error )
                          %element-agencyid   = if_abap_behv=>mk-on ) TO reported-travel.

        " Raise messages for non existing agency ids
        ELSEIF ls_travel-agencyid IS NOT INITIAL AND NOT line_exists( lt_agency_db[ agency_id = ls_travel-agencyid ] ).
          APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
          APPEND VALUE #( %tky                = ls_travel-%tky
                          %state_area         = 'VALIDATE_AGENCY'
                          %msg                = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                             number   = '008' " Agency &1 unknown
                                                             v1       = ls_travel-agencyid
                                                             severity = if_abap_behv_message=>severity-error )
                          %element-agencyid = if_abap_behv=>mk-on ) TO reported-travel.
        ENDIF.
      ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.
          " Read relevant travel instances
          READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
            ENTITY travel
              FIELDS ( customerid )
              WITH CORRESPONDING #( keys )
            RESULT DATA(lt_travel).

          " Get Customer Master Data for comparison
          SELECT FROM /dmo/customer AS customer
            INNER JOIN @lt_travel AS travel ON travel~customerid = customer~customer_id
            FIELDS customer_id
            INTO TABLE @DATA(lt_customer_db).


          " Loop over all travel instances to be saved
          LOOP AT lt_travel INTO DATA(ls_travel).
            APPEND VALUE #( %tky               = ls_travel-%tky
                            %state_area        = 'VALIDATE_CUSTOMER' ) TO reported-travel.

            " Raise messages for empty customer ids
            IF ls_travel-customerid IS INITIAL.
              APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.

              APPEND VALUE #( %tky                = ls_travel-%tky
                              %state_area         = 'VALIDATE_CUSTOMER'
                              %msg                = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                                 number   = '005' " Customer is initial
                                                                 severity = if_abap_behv_message=>severity-error )
                              %element-customerid = if_abap_behv=>mk-on ) TO reported-travel.

            " Raise messages for non existing customer ids
            ELSEIF ls_travel-customerid IS NOT INITIAL AND NOT line_exists( lt_customer_db[ customer_id = ls_travel-customerid ] ).
              APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
              APPEND VALUE #( %tky                = ls_travel-%tky
                              %state_area         = 'VALIDATE_CUSTOMER'
                              %msg                = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                                 number   = '006' " Customer &1 unknown
                                                                 v1       = ls_travel-customerid
                                                                 severity = if_abap_behv_message=>severity-error )
                              %element-customerid = if_abap_behv=>mk-on ) TO reported-travel.
            ENDIF.
          ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
      "Read relevant travel instance data
      READ ENTITIES OF zraph_mk_i_travelwdtp IN LOCAL MODE
      ENTITY Travel
      FIELDS ( begindate enddate ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

      LOOP AT lt_travel INTO DATA(ls_travel).

        APPEND VALUE #(  %tky               = ls_travel-%tky
                         %state_area        = 'VALIDATE_DATES' ) TO reported-travel.

        IF ls_travel-begindate IS INITIAL.
          APPEND VALUE #( %tky               = ls_travel-%tky ) TO failed-travel.
          APPEND VALUE #( %tky               = ls_travel-%tky
                          %state_area        = 'VALIDATE_DATES'
                          %msg               =  new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                             number   = '003' " Enter Begin Date for travel
                                                             v1       = ls_travel-travelid
                                                             severity = if_abap_behv_message=>severity-error )
                          %element-begindate = if_abap_behv=>mk-on ) TO reported-travel.
        ENDIF.
        IF ls_travel-enddate IS INITIAL.
          APPEND VALUE #( %tky               = ls_travel-%tky ) TO failed-travel.
          APPEND VALUE #( %tky               = ls_travel-%tky
                          %state_area        = 'VALIDATE_DATES'
                          %msg               =  new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                             number   = '004' " Enter EndDate for travel
                                                             v1       = ls_travel-travelid
                                                             severity = if_abap_behv_message=>severity-error )
                          %element-enddate   = if_abap_behv=>mk-on ) TO reported-travel.
        ENDIF.

        IF ls_travel-enddate < ls_travel-begindate
          AND ls_travel-begindate IS NOT INITIAL
          AND ls_travel-enddate IS NOT INITIAL.

          APPEND VALUE #( %tky               = ls_travel-%tky ) TO failed-travel.
          APPEND VALUE #( %tky               = ls_travel-%tky
                          %state_area        = 'VALIDATE_DATES'
                          %msg               = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                            number   = '001'
                                                            v1       = ls_travel-begindate
                                                            v2       = ls_travel-enddate
                                                            v3       = ls_travel-travelid
                                                            severity = if_abap_behv_message=>severity-error )
                          %element-begindate = if_abap_behv=>mk-on
                          %element-enddate   = if_abap_behv=>mk-on ) TO reported-travel.

        ELSEIF ls_travel-begindate < cl_abap_context_info=>get_system_date( )
          AND ls_travel-begindate IS NOT INITIAL
          AND ls_travel-enddate IS NOT INITIAL.

            APPEND VALUE #( %tky               = ls_travel-%tky ) TO failed-travel.
            APPEND VALUE #( %tky               = ls_travel-%tky
                            %state_area        = 'VALIDATE_DATES'
                            %msg               = new_message( id       = 'ZRAPH_MSG_TRAVELWD'
                                                              number   = '002' "Begin date &1 must be on or after system date
                                                              v1       = ls_travel-begindate
                                                              severity = if_abap_behv_message=>severity-error )
                            %element-begindate = if_abap_behv=>mk-on ) TO reported-travel.
        ENDIF.
      ENDLOOP.
  ENDMETHOD.

ENDCLASS.
