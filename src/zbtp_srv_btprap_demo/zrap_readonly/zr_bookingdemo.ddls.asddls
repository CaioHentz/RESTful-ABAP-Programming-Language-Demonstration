@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
 
define view entity zr_bookingdemo as select from zbooking_demo as Booking 
 
  association to parent zr_traveldemo as _Travel on $projection.TravelUUID = _Travel.TravelUUID
  
  association [1..1] to /DMO/I_Customer as _Customer on  $projection.CustomerID = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier as _Carrier on  $projection.CarrierID = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection as _Connection on  $projection.CarrierID = _Connection.AirlineID
 and $projection.ConnectionID = _Connection.ConnectionID
  association [1..1] to /DMO/I_Flight as _Flight on  $projection.CarrierID = _Flight.AirlineID
  and $projection.ConnectionID = _Flight.ConnectionID
  and $projection.FlightDate   = _Flight.FlightDate
  association [0..1] to I_Currency as _Currency on $projection.CurrencyCode    = _Currency.Currency    
{
  key booking_uuid          as BookingUUID,
      travel_uuid           as TravelUUID,
      booking_id            as BookingID,
      booking_date          as BookingDate,
      customer_id           as CustomerID,
      carrier_id            as CarrierID,
      connection_id         as ConnectionID,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
 
      /* associations */
      _Travel,
      _Customer,
      _Carrier,
      _Connection,
      _Flight,
      _Currency
}
