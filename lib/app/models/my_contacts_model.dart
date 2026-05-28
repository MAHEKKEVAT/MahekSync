class MyContactsModel {
  final String docId;
  final String ownerId;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String profileImage;

  MyContactsModel({
    this.docId = '',
    required this.ownerId,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    this.profileImage = '',
  });

  String get formattedName => '$firstName $lastName'.trim();

  bool get hasProfile => profileImage.isNotEmpty;

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  static String normalizeMobile(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    String clean = digits;

    /// remove india code
    if (clean.startsWith('91') && clean.length > 10) {
      clean = clean.substring(clean.length - 10);
    }

    /// remove leading zero
    if (clean.startsWith('0') && clean.length > 10) {
      clean = clean.substring(clean.length - 10);
    }

    return clean;
  }

  static int? _runeToDigit(int rune) {
    if (rune >= 0x30 && rune <= 0x39) return rune - 0x30;
    if (rune >= 0x0660 && rune <= 0x0669) return rune - 0x0660;
    if (rune >= 0x06F0 && rune <= 0x06F9) return rune - 0x06F0;
    if (rune >= 0x07C0 && rune <= 0x07C9) return rune - 0x07C0;
    if (rune >= 0x0966 && rune <= 0x096F) return rune - 0x0966;
    if (rune >= 0x09E6 && rune <= 0x09EF) return rune - 0x09E6;
    if (rune >= 0x0A66 && rune <= 0x0A6F) return rune - 0x0A66;
    if (rune >= 0x0AE6 && rune <= 0x0AEF) return rune - 0x0AE6;
    if (rune >= 0x0B66 && rune <= 0x0B6F) return rune - 0x0B66;
    if (rune >= 0x0BE6 && rune <= 0x0BEF) return rune - 0x0BE6;
    if (rune >= 0x0C66 && rune <= 0x0C6F) return rune - 0x0C66;
    if (rune >= 0x0CE6 && rune <= 0x0CEF) return rune - 0x0CE6;
    if (rune >= 0x0D66 && rune <= 0x0D6F) return rune - 0x0D66;
    if (rune >= 0x0DE6 && rune <= 0x0DEF) return rune - 0x0DEF;
    if (rune >= 0x0E50 && rune <= 0x0E59) return rune - 0x0E50;
    if (rune >= 0x0ED0 && rune <= 0x0ED9) return rune - 0x0ED0;
    if (rune >= 0x1040 && rune <= 0x1049) return rune - 0x1040;
    if (rune >= 0x1090 && rune <= 0x1099) return rune - 0x1090;
    if (rune >= 0x17E0 && rune <= 0x17E9) return rune - 0x17E0;
    if (rune >= 0x1810 && rune <= 0x1819) return rune - 0x1810;
    if (rune >= 0x1946 && rune <= 0x194F) return rune - 0x1946;
    if (rune >= 0x19D0 && rune <= 0x19D9) return rune - 0x19D0;
    if (rune >= 0x1A80 && rune <= 0x1A89) return rune - 0x1A80;
    if (rune >= 0x1A90 && rune <= 0x1A99) return rune - 0x1A90;
    if (rune >= 0x1B50 && rune <= 0x1B59) return rune - 0x1B50;
    if (rune >= 0x1BB0 && rune <= 0x1BB9) return rune - 0x1BB0;
    if (rune >= 0x1C40 && rune <= 0x1C49) return rune - 0x1C40;
    if (rune >= 0x1C50 && rune <= 0x1C59) return rune - 0x1C50;
    if (rune >= 0xA620 && rune <= 0xA629) return rune - 0xA620;
    if (rune >= 0xA8D0 && rune <= 0xA8D9) return rune - 0xA8D0;
    if (rune >= 0xA900 && rune <= 0xA909) return rune - 0xA900;
    if (rune >= 0xA9D0 && rune <= 0xA9D9) return rune - 0xA9D0;
    if (rune >= 0xA9F0 && rune <= 0xA9F9) return rune - 0xA9F0;
    if (rune >= 0xAA50 && rune <= 0xAA59) return rune - 0xAA50;
    if (rune >= 0xABF0 && rune <= 0xABF9) return rune - 0xABF0;
    if (rune >= 0xFF10 && rune <= 0xFF19) return rune - 0xFF10;
    return null;
  }

  factory MyContactsModel.fromJson(Map<String, dynamic> json, {String docId = ''}) {
    return MyContactsModel(
      docId: docId,
      ownerId: json['ownerId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      mobileNumber: normalizeMobile(json['mobileNumber'] as String? ?? ''),
      profileImage: json['profileImage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'profileImage': profileImage,
    };
  }

  MyContactsModel copyWith({
    String? docId,
    String? ownerId,
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? profileImage,
  }) {
    return MyContactsModel(
      docId: docId ?? this.docId,
      ownerId: ownerId ?? this.ownerId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
