@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Room Reservation Cds'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRAPH_MK_RESERVATION as select from zraph_mk_roomrsv as roomrsv
association[1..1] to zraph_mk_hotel as _hotel on _hotel.hotel_id = roomrsv.hotel_id{


    
    key roomrsv_uuid as RoomReservationUUID,
    parent_uuid           as ParentUUID,
    roomrsv_id            as RoomReservationID,
    hotel_id              as HotelID,
    begin_date            as BeginDate,
    end_date              as EndDate,
    room_type             as RoomType,
    
    @Semantics.amount.currencyCode : 'CurrencyCode'
    roomrsv_price       as RoomReservationPrice,
    currency_code         as CurrencyCode,
    local_last_changed_at as LocalLastChangedAt,
    
    _hotel.name           as Name,
    _hotel.city           as City,
    _hotel.country        as Country
}
