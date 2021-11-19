@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Booking Supp Cds Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAPH_MK_I_BookingSupplWDTP as select from zraph_mk_booksup 
    association        to parent ZRAPH_MK_I_BookingWDTP as _Booking  on $projection.BookingUUID     = _Booking.BookingUUID
    association [1..1] to ZRAPH_MK_I_TravelWDTP         as _Travel   on $projection.TravelUUID      = _Travel.TravelUUID
    
    association [1..1] to /DMO/I_Supplement          as _Product        on $projection.SupplementID = _Product.SupplementID
    association [1..*] to /DMO/I_SupplementText      as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID

{
    key booksuppl_uuid as BookSupplUUID,
      root_uuid as TravelUUID,
      parent_uuid as BookingUUID,
      booking_supplement_id as BookingSupplementID,
      supplement_id as SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price  as Price,
      currency_code as CurrencyCode,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      
      //Associations
      _Travel,
      _Booking,
      
      _Product,
      _SupplementText
}
