class OtpRecord {
  final String contact;
  final String otpCode;
  final String purpose;
  final String expiresAt;
  final String createdAt;

  OtpRecord({
    required this.contact,
    required this.otpCode,
    required this.purpose,
    required this.expiresAt,
    required this.createdAt,
  });

  factory OtpRecord.fromJson(Map<String, dynamic> json) {
    return OtpRecord(
      contact: json['contact'] ?? '',
      otpCode: json['otp_code'] ?? '',
      purpose: json['purpose'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact': contact,
      'otp_code': otpCode,
      'purpose': purpose,
      'expires_at': expiresAt,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'OtpRecord(contact: $contact, purpose: $purpose, expiresAt: $expiresAt)';
  }
}
