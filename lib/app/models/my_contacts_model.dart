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
