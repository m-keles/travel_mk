@EndUserText.label: 'RAP HandsOn: Booking Suppl. Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZRAPH_MK_C_BookingSupplWDTP
  as projection on ZRAPH_MK_I_BookingSupplWDTP
  
  
//    association        to parent ZRAPH_MK_I_BookingWDTP as _Booking  on $projection.BookingUUID     = _Booking.BookingUUID
//    association [1..1] to ZRAPH_MK_I_TravelWDTP         as _Travel   on $projection.TravelUUID      = _Travel.TravelUUID
//    
//    association [1..1] to /DMO/I_Supplement          as _Product        on $projection.SupplementID = _Product.SupplementID
//    association [1..*] to /DMO/I_SupplementText      as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID
{
  key BookSupplUUID,

      TravelUUID,

      BookingUUID,

      @Search.defaultSearchElement: true
      BookingSupplementID,

      @ObjectModel.text.element: ['SupplementDescription']
      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_SUPPLEMENT', element: 'SupplementID' } ,
                     additionalBinding: [ { localElement: 'Price',  element: 'Price', usage: #RESULT },
                                          { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT }] }]
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,

      Price,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,

      LocalLastChangedAt,
      

      /* Associations */
      _Booking : redirected to parent ZRAPH_MK_C_BookingWDTP,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZRAPH_MK_C_TravelWDTP
}

