class ApiConstants {
  static const String baseUrl = 'https://traveldesksolutions.in';

  // Authentication endpoints
  static const String sendOtp = '/api/send-otp';
  static const String verifyOtp = '/api/verify-otp';
  static const String resendOtp = '/api/resend-otp';
  static const String login = '/api/login';

  // Driver endpoints
  static const String driverRegister = '/api/driver/register';
  static const String driverDetails = '/api/driver/details';
  static const String driverUpdate = '/api/driver/update';
  static const String driverLocation = '/api/driver/location';
  static const String driverDashboard = '/api/driver/dashboard';
  static const String driverRideRequests = '/api/driver/ride-request-offers';
  static const String driverRideRequestDetails = '/api/driver/ride-request-offers/';
  static const String driverRideRequestAction = '/api/driver/ride-request-offers/';

  // Fuel endpoints
  static const String fuel = '/api/fuel';

  // Trip endpoints
  static const String trips = '/api/trips';
  static const String tripDetails = '/api/trip-details/';
  static const String tripUpdateStatus = '/api/trip-update-status';
  static const String tripVerifyOtp = '/api/trip-verify-otp';
  
  // Invoice & Booking history
  static const String invoiceDownload = '/api/invoice/download/';
  static const String bookingHistory = '/api/ride/booking-history';

  // Legacy endpoints (keeping for reference)
  static const String cabBooking = '/api/cab-booking';
  static const String bookingDetails = '/api/booking-details';
  static const String createRideBooking = '/api/ride/create-booking';

  // MapMyIndia Atlas API Configuration
  static const String atlasBaseUrl = 'https://atlas.mapmyindia.com/api/places';
  static const String atlasTextSearchEndpoint = '/textsearch/json';

  // Deprecated Mappls API Configuration (keeping for reference)
  static const String mapplsBaseUrl = 'https://apis.mappls.com';
  static const String mapplsApiKey = '9cf52ae378796dc6bd2e8a2b912cf31f'; // MapMyIndia REST Key (project key)
  static const String mapplsClientId = '96dHZVzsAutCyRYU1vd8QopBO8HnTYXtySVldSv4Vtb7pnroiiddrY3o4oogYc-vPwT0ryCuSnKlq_J7JMNdNQ==';
  static const String mapplsClientSecret = 'lrFxI-iSEg-uD8wdks4HKwm6CU-YEaiFUrfE5GA_LJifJdWBJ_MxPzC-DvYm6pnjr1cpG0hC6keriyllpXwmBE8jtmVXUFmK';
  static const String mapplsOAuthTokenUrl = 'https://outpost.mappls.com/api/security/oauth/token';
  static const String mapplsGeocodeEndpoint = '/advancedmaps/v1';
  static const String mapplsAutosuggestEndpoint = '/advancedmaps/v1';
}



