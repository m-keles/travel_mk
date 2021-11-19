@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Room Reservation Cds Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAPH_MK_I_RoomReservationWDTP as select from zraph_mk_roomrsv 

    association        to parent ZRAPH_MK_I_TravelWDTP as _Travel     on $projection.TravelUUID = _Travel.TravelUUID
    
    association [1..1] to ZRAPH_I_HOTEL             as _Hotel         on $projection.HotelID  = _Hotel.HotelID
    association [1..1] to ZRAPH_I_HotelRoomType     as _HotelRoomType on $projection.RoomType = _HotelRoomType.Value

{
    key roomrsv_uuid as RoomRsvUUID,
      parent_uuid  as TravelUUID,
      roomrsv_id as RoomRsvID,
      hotel_id  as HotelID,
      begin_date as BeginDate,
      end_date as EndDate,
      room_type as RoomType,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      roomrsv_price as RoomRsvPrice,
      currency_code as CurrencyCode,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      
      //Associations
      _Travel,
      
      _Hotel,
      _HotelRoomType
}
