@EndUserText.label: 'RAP HandsOn: Room Reservation Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZRAPH_MK_C_RoomReservationWDTP
  as projection on ZRAPH_MK_I_RoomReservationWDTP
  
//    association        to parent ZRAPH_MK_I_TravelWDTP as _Travel     on $projection.TravelUUID = _Travel.TravelUUID
//    
//    association [1..1] to ZRAPH_I_HOTEL             as _Hotel         on $projection.HotelID  = _Hotel.HotelID
//    association [1..1] to ZRAPH_I_HotelRoomType     as _HotelRoomType on $projection.RoomType = _HotelRoomType.Value
{
  key RoomRsvUUID,

      TravelUUID,

      RoomRsvID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['HotelName']
      @Consumption.valueHelpDefinition: [ {entity: {name: 'ZRAPH_I_HOTEL', element: 'HotelID' } } ]
      HotelID,
      _Hotel.Name as HotelName,
      
      _Hotel.City as City,

      BeginDate,

      EndDate,

      @Consumption.valueHelpDefinition: [{ entity: { name:    'ZRAPH_I_HotelRoomType',
                                                     element: 'Value'  } }]
      @ObjectModel.text.element: ['RoomTypeText']
      @Search.defaultSearchElement: true
      RoomType,
      _HotelRoomType.Text as RoomTypeText,

      RoomRsvPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,

      LocalLastChangedAt,
      
      
      /* Associations */
      _Hotel,
      _HotelRoomType,
      _Travel : redirected to parent ZRAPH_MK_C_TravelWDTP
}
