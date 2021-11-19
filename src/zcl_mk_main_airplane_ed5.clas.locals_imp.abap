*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_airplane DEFINITION.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        im_name      TYPE string
        im_planetype TYPE /dmo/plane_type_id.
    METHODS display_attributes
      IMPORTING im_out TYPE REF TO if_oo_adt_classrun_out.

    CLASS-METHODS display_number_of_airplanes
      IMPORTING im_out TYPE REF TO if_oo_adt_classrun_out.
    CLASS-METHODS get_number_of_airplanes
      RETURNING VALUE(re_number_of_airplanes) TYPE i.


  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA name TYPE string.
    DATA planetype TYPE /dmo/plane_type_id.
    CLASS-DATA number_of_airplanes TYPE i.

    METHODS get_technical_attributes
      IMPORTING im_planetype     TYPE /dmo/plane_type_id
      EXPORTING ex_weight        TYPE zraph_mk_airplane_weight.
ENDCLASS.



CLASS lcl_airplane IMPLEMENTATION.

  METHOD constructor.
    name = im_name.
    planetype = im_planetype.
    number_of_airplanes = number_of_airplanes + 1.
  ENDMETHOD.


  METHOD display_attributes.
    me->get_technical_attributes(
        EXPORTING im_planetype = me->planetype
        IMPORTING ex_weight = DATA(l_weight)
    ).
    im_out->write( |{ me->name }: { me->planetype }, weight: { l_weight }| ).
  ENDMETHOD.

  METHOD display_number_of_airplanes.
    im_out->write( |Number of airplanes: { lcl_airplane=>number_of_airplanes }| ).
  ENDMETHOD.

  METHOD get_number_of_airplanes.
    re_number_of_airplanes = lcl_airplane=>number_of_airplanes.
  ENDMETHOD.

  METHOD get_technical_attributes.
    SELECT SINGLE weight
        FROM zraph_mk_airpln
        WHERE type_id = @im_planetype
        INTO @ex_weight.

    IF sy-subrc NE 0.
      ex_weight = 100000.
    ENDIF.
  ENDMETHOD.


ENDCLASS.
