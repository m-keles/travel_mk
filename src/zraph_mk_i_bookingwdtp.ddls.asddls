@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Booking Cds Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAPH_MK_I_BookingWDTP as select from zraph_mk_booking 
    association        to parent ZRAPH_MK_I_TravelWDTP as _Travel on  $projection.TravelUUID        = _Travel.TravelUUID
    composition [0..*] of ZRAPH_MK_I_BookingSupplWDTP  as _BookingSupplement
    
    association [1..1] to /DMO/I_Customer               as _Customer   on  $projection.CustomerID = _Customer.CustomerID
    association [1..1] to /DMO/I_Carrier                as _Carrier    on  $projection.CarrierID = _Carrier.AirlineID
    association [1..1] to /DMO/I_Connection             as _Connection on  $projection.CarrierID    = _Connection.AirlineID
                                                                     and $projection.ConnectionID = _Connection.ConnectionID

{
    key booking_uuid as BookingUUID,
      parent_uuid as TravelUUID,
      booking_id as BookingID,
      booking_date as BookingDate,
      customer_id as CustomerID,
      carrier_id as CarrierID,
      connection_id as ConnectionID,
      flight_date as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price as FlightPrice,
      currency_code as CurrencyCode,
      booking_status as BookingStatus,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      case when $projection.FlightPrice <  200 then 3
           when $projection.FlightPrice >= 200 and $projection.FlightPrice < 500 then 2
           when $projection.FlightPrice >= 500 then 1
           else 0
      end                         as Criticality,
      //Associations
      _Travel,
      _BookingSupplement,
      
      _Customer,
      _Carrier,
      _Connection
}
