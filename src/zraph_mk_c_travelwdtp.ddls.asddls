@EndUserText.label: 'RAP HandsOn: Travel Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['TravelID']

define root view entity ZRAPH_MK_C_TravelWDTP
  provider contract transactional_query
  as projection on ZRAPH_MK_I_TravelWDTP
  
  
//    composition [0..*] of ZRAPH_MK_I_BookingWDTP         as _Booking
//    composition [0..*] of ZRAPH_MK_I_RoomReservationWDTP as _RoomReservation
//    
//    association [0..1] to /DMO/I_Agency             as _Agency       on $projection.AgencyID = _Agency.AgencyID
//    association [0..1] to /DMO/I_Customer           as _Customer     on $projection.CustomerID = _Customer.CustomerID
//    association [0..1] to I_Currency                as _Currency     on $projection.CurrencyCode = _Currency.Currency
//    association [0..1] to ZRAPH_I_OverallStatus     as _TravelStatus on $projection.OverallStatus = _TravelStatus.TravelStatus
  
{
  key     TravelUUID,

          @Search.defaultSearchElement: true
          TravelID,

          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.7
          @ObjectModel.text.element: ['AgencyName']
          @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID'  } }]
          AgencyID,
          _Agency.Name       as AgencyName,

          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.7
          @ObjectModel.text.element: ['CustomerName']
          @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID'  } }]
          CustomerID,
          _Customer.LastName as CustomerName,

          BeginDate,

          EndDate,

          BookingFee,

          TotalPrice,

          @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
          CurrencyCode,

          Description,

          @Consumption.valueHelpDefinition: [{entity: { name:    'ZRAPH_I_OverallStatus',
                                                        element: 'TravelStatus' } }]
          @ObjectModel.foreignKey.association: '_TravelStatus'
          OverallStatus,

          LocalCreatedBy,

          LocalCreatedAt,

          LocalLastChangedBy,

          LocalLastChangedAt,

          LastChangedAt,
          

          /* Associations */
          _Booking         : redirected to composition child ZRAPH_MK_C_BookingWDTP,
          _RoomReservation : redirected to composition child ZRAPH_MK_C_RoomReservationWDTP,
          _Agency,
          _Currency,
          _Customer,
          _TravelStatus

}

