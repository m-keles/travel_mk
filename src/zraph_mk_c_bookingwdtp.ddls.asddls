@EndUserText.label: 'RAP HandsOn: Booking Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZRAPH_MK_C_BookingWDTP
  as projection on ZRAPH_MK_I_BookingWDTP
  
//    association        to parent ZRAPH_MK_I_TravelWDTP as _Travel on  $projection.TravelUUID        = _Travel.TravelUUID
//    composition [0..*] of ZRAPH_MK_I_BookingSupplWDTP  as _BookingSupplement
//    
//    association [1..1] to /DMO/I_Customer               as _Customer   on  $projection.CustomerID = _Customer.CustomerID
//    association [1..1] to /DMO/I_Carrier                as _Carrier    on  $projection.CarrierID = _Carrier.AirlineID
//    association [1..1] to /DMO/I_Connection             as _Connection on  $projection.CarrierID    = _Connection.AirlineID
//                                                                     and $projection.ConnectionID = _Connection.ConnectionID
{
  key     BookingUUID,

          TravelUUID,

          @Search.defaultSearchElement: true
          BookingID,

          BookingDate,

          @ObjectModel.text.element: ['CustomerName']
          @Search.defaultSearchElement: true
          @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Customer', element: 'CustomerID' }}]
          CustomerID,
          _Customer.LastName as CustomerName,

          @ObjectModel.text.element: ['CarrierName']
          @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Carrier', element: 'AirlineID' }}]
          CarrierID,
          _Carrier.Name      as CarrierName,

          @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                         additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                              { localElement: 'CarrierID',    element: 'AirlineID'},
                                              { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT},
                                              { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]
          ConnectionID,

          FlightDate,

          @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                         additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                              { localElement: 'CarrierID',    element: 'AirlineID'},
                                              { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT },
                                              { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]
          FlightPrice,

          @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
          CurrencyCode,

          BookingStatus,

          Criticality,
          
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZRAPH_MK_CL_DAYS_TO_FLIGHT'
          virtual DaysToFlight : abap.int2,

          LocalLastChangedAt,
          

          /* Associations */
          _BookingSupplement : redirected to composition child ZRAPH_MK_C_BookingSupplWDTP,
          _Carrier,
          _Connection,
          _Customer,
          _Travel            : redirected to parent ZRAPH_MK_C_TravelWDTP
}
