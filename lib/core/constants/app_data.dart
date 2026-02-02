class AppData {
  static const List<String> cities = [
    'Agra', 'Ahmedabad', 'Ahmednagar', 'Ajmer', 'Akola', 'Aligarh', 'Allahabad', 'Alwar',
    'Amaravati', 'Ambala', 'Amravati', 'Amritsar', 'Anand', 'Aurangabad',
    'Bangalore', 'Bareilly', 'Belgaum', 'Bellary', 'Bhagalpur', 'Bharatpur', 'Bhavnagar',
    'Bhilai', 'Bhilwara', 'Bhopal', 'Bhubaneswar', 'Bikaner', 'Bilaspur', 'Bokaro',
    'Calicut', 'Chandigarh', 'Chennai', 'Coimbatore', 'Cuttack',
    'Darbhanga', 'Davangere', 'Dehradun', 'Delhi', 'Dhanbad', 'Durgapur',
    'Erode',
    'Faridabad', 'Firozabad',
    'Gandhinagar', 'Gaya', 'Ghaziabad', 'Goa', 'Gorakhpur', 'Gulbarga', 'Guntur', 'Gurgaon', 'Guwahati', 'Gwalior',
    'Haridwar', 'Hubli', 'Hyderabad',
    'Imphal', 'Indore',
    'Jabalpur', 'Jaipur', 'Jalandhar', 'Jalgaon', 'Jammu', 'Jamnagar', 'Jamshedpur', 'Jhansi', 'Jodhpur', 'Junagadh',
    'Kanpur', 'Kakinada', 'Kochi', 'Kolhapur', 'Kolkata', 'Kollam', 'Kota', 'Kottayam', 'Kozhikode',
    'Lucknow', 'Ludhiana',
    'Madurai', 'Mangalore', 'Mathura', 'Meerut', 'Moradabad', 'Mumbai', 'Mysore',
    'Nagpur', 'Nanded', 'Nashik', 'Nellore', 'Noida',
    'Patna', 'Pondicherry', 'Port Blair', 'Pune',
    'Raipur', 'Rajahmundry', 'Rajkot', 'Ranchi', 'Rourkela',
    'Sagar', 'Salem', 'Sangli', 'Shimla', 'Siliguri', 'Solapur', 'Srinagar', 'Surat',
    'Thiruvananthapuram', 'Thrissur', 'Tiruchirappalli', 'Tirunelveli', 'Tirupati', 'Tiruppur', 'Trichy',
    'Udaipur', 'Ujjain',
    'Vadodara', 'Varanasi', 'Vellore', 'Vijayawada', 'Visakhapatnam',
    'Warangal',
  ];

  // Expanded Dummy Data
  static final List<Map<String, dynamic>> dummyBookings = [
    {
      'id': 'BK-2025-001',
      'from': 'Delhi Airport T3',
      'to': 'The Oberoi, Gurgaon',
      'date': '20 Dec, 2025',
      'time': '10:00 AM',
      'vehicle': 'Sedan Premium',
      'image': 'assets/images/sedan.png', // Ensure you have these assets or use placeholders
      'price': 1200.0,
      'status': 'Upcoming',
      'driverName': 'Rajesh Kumar',
      'driverRating': 4.8,
      'carModel': 'Honda City',
      'plateNumber': 'DL 01 AB 1234'
    },
    {
      'id': 'BK-2025-002',
      'from': 'Bangalore City',
      'to': 'Mysore Palace',
      'date': '18 Dec, 2025',
      'time': '08:30 AM',
      'vehicle': 'SUV Luxury',
      'image': 'assets/images/suv.png',
      'price': 4500.0,
      'status': 'Completed',
      'driverName': 'Suresh Menon',
      'driverRating': 4.9,
      'carModel': 'Toyota Innova Crysta',
      'plateNumber': 'KA 05 MN 5678'
    },
    {
      'id': 'BK-2025-003',
      'from': 'Pune Station',
      'to': 'Lonavala Resort',
      'date': '15 Dec, 2025',
      'time': '06:00 AM',
      'vehicle': 'Hatchback',
      'image': 'assets/images/hatchback.png',
      'price': 2200.0,
      'status': 'Cancelled',
      'driverName': 'Amit Sharma',
      'driverRating': 4.7,
      'carModel': 'Maruti Swift',
      'plateNumber': 'MH 12 CD 9012'
    },
     {
      'id': 'BK-2025-004',
      'from': 'Mumbai Airport',
      'to': 'Taj Mahal Palace',
      'date': '22 Dec, 2025',
      'time': '11:00 PM',
      'vehicle': 'Luxury Sedan',
      'image': 'assets/images/luxury.png',
      'price': 1800.0,
      'status': 'Upcoming',
      'driverName': 'Vikram Singh',
      'driverRating': 4.9,
      'carModel': 'Mercedes E-Class',
      'plateNumber': 'MH 01 AB 7777'
    },
    {
      'id': 'BK-2025-005',
      'from': 'Jaipur City',
      'to': 'Amer Fort',
      'date': '10 Dec, 2025',
      'time': '09:00 AM',
      'vehicle': 'SUV',
      'image': 'assets/images/suv.png',
      'price': 800.0,
      'status': 'Completed',
      'driverName': 'Rohan Das',
      'driverRating': 4.6,
      'carModel': 'Mahindra XUV700',
      'plateNumber': 'RJ 14 XY 3344'
    },
  ];
}



