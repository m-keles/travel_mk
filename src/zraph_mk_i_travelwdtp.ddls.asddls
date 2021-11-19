@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Travel Cds Data'
define root view entity ZRAPH_MK_I_TravelWDTP as select from zraph_mk_travel
    composition [0..*] of ZRAPH_MK_I_BookingWDTP         as _Booking
    composition [0..*] of ZRAPH_MK_I_RoomReservationWDTP as _RoomReservation
    
    association [0..1] to /DMO/I_Agency             as _Agency       on $projection.AgencyID = _Agency.AgencyID
    association [0..1] to /DMO/I_Customer           as _Customer     on $projection.CustomerID = _Customer.CustomerID
    association [0..1] to I_Currency                as _Currency     on $projection.CurrencyCode = _Currency.Currency
    association [0..1] to ZRAPH_I_OverallStatus     as _TravelStatus on $projection.OverallStatus = _TravelStatus.TravelStatus

{
    key travel_uuid as TravelUUID,
      travel_id as TravelID,
      agency_id as AgencyID,
      customer_id as CustomerID,
      begin_date as BeginDate,
      end_date as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price as TotalPrice,
      currency_code as CurrencyCode,
      description as Description,
      overall_status as OverallStatus,
      //Administrative Fields
      @Semantics.user.createdBy: true
      local_created_by as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      //total ETag field
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      
      
      //Associations
      _Booking,
      _RoomReservation,
      
      _Agency,
      _Customer,
      _Currency,
      _TravelStatus
}
