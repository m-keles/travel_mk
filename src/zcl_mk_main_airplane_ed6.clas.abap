CLASS zcl_mk_main_airplane_ed6 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MK_MAIN_AIRPLANE_ED6 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA l_cargo_plane TYPE REF TO lcl_cargo_plane.
    DATA l_passenger_plane TYPE REF TO lcl_passenger_plane.

    lcl_airplane=>display_number_of_airplanes(  out ).

    l_cargo_plane = NEW #( im_name = 'Plane1' im_planetype = 'Boeing' im_max_cargo = 1000 ).
    l_cargo_plane->display_attributes(  out ).

    l_passenger_plane = NEW #( im_name = 'Plane2' im_planetype = 'Airbus'  im_max_seats = 500 ).
    l_passenger_plane->display_attributes(  out ).

    l_cargo_plane = NEW #( im_name = 'Plane3' im_planetype = 'Boeing' im_max_cargo = 2000 ).
    l_cargo_plane->display_attributes(  out ).

    l_cargo_plane = NEW #( im_name = 'Plane4' im_planetype = 'Boeing' im_max_cargo = 700 ).
    l_cargo_plane->display_attributes(  out ).

    lcl_airplane=>display_number_of_airplanes(  out ).


*    DATA l_airplane TYPE REF TO lcl_airplane.
*    DATA l_airplanes TYPE TABLE OF REF TO lcl_airplane.
*
*    lcl_airplane=>display_number_of_airplanes(  out ).
*
*    l_airplane = NEW lcl_airplane( im_name = 'Plane1' im_planetype = '747-400' ).
*    l_airplane->set_attributes( im_name = 'Plane1' im_planetype = 'A700' ).
*    l_airplane->display_attributes(  out ).
*    airplane->get_technical_attributes( 'A700' ).
*    APPEND l_airplane TO l_airplanes.
*
*    l_airplane = NEW lcl_airplane( im_name = 'Plane2' im_planetype = 'A320-200' ).
*    l_airplane->set_attributes( im_name = 'Plane2' im_planetype = 'A600' ).
*    l_airplane->display_attributes(  out ).
*    APPEND l_airplane TO l_airplanes.
*
*     l_airplane = NEW lcl_airplane( im_name = 'Plane3' im_planetype = '767-200' ).
*    l_airplane->set_attributes( im_name = 'Plane3' im_planetype = 'Boeing' ).
*    l_airplane->display_attributes(  out ).
*    APPEND l_airplane TO l_airplanes.
*
*    l_airplane = NEW lcl_airplane( im_name = 'Plane4' im_planetype = 'Airbus' ).
*    l_airplane->set_attributes( im_name = 'Plane4' im_planetype = 'Airbus' ).
*    l_airplane->display_attributes(  out ).
*    APPEND l_airplane TO l_airplanes.
*
*    lcl_airplane=>display_number_of_airplanes(  out ).

  ENDMETHOD.
ENDCLASS.
