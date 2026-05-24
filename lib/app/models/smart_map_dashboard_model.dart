class SmartMapDashboardModel {
  final double latitude;
  final double longitude;
  final String address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? subLocality;
  final DateTime? updatedAt;

  SmartMapDashboardModel({
    required this.latitude,
    required this.longitude,
    this.address = '',
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.subLocality,
    this.updatedAt,
  });

  String get shortAddress {
    final parts = [subLocality, city, country].where((e) => e != null && e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : address;
  }

  factory SmartMapDashboardModel.fromJson(Map<String, dynamic> json) {
    return SmartMapDashboardModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      subLocality: json['subLocality'] as String?,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'subLocality': subLocality,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SmartMapDashboardModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? subLocality,
    DateTime? updatedAt,
  }) {
    return SmartMapDashboardModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      subLocality: subLocality ?? this.subLocality,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
