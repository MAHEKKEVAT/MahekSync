// ignore_for_file: non_MahekConstant_identifier_names

class MahekConstantModel {
  String? jsonFileURL;
  String? notificationServerKey;
  String? webNotificationKey;
  String? referralAmount;
  String? privacyPolicy;
  String? termsAndConditions;
  String? aboutApp;
  String? customerAppColor;
  String? appName;
  String? countryCode;
  MapSettingModel? mapSettings;

  MahekConstantModel(
      {this.jsonFileURL,
      this.notificationServerKey,
      this.webNotificationKey,
      this.privacyPolicy,
      this.termsAndConditions,
      this.aboutApp,
      this.customerAppColor,
      this.appName,
      this.countryCode,
      this.referralAmount,
      this.mapSettings,});

  MahekConstantModel.fromJson(Map<String, dynamic> json) {
    jsonFileURL = json['jsonFileURL'] ?? '';
    notificationServerKey = json['notification_senderId'] ?? '';
    webNotificationKey = json['web_notification_key'] ?? '';
    privacyPolicy = json['privacyPolicy'] ?? '';
    termsAndConditions = json['termsAndConditions'] ?? '';
    referralAmount = json['referral_Amount'];
    aboutApp = json['aboutApp'] ?? '';
    customerAppColor = json['customerAppColor'] ?? '';
    appName = json['appName'] ?? '';
    countryCode = json['countryCode'] ?? '';
    mapSettings = json["mapSettings"] == null ? null : MapSettingModel.fromJson(json["mapSettings"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['jsonFileURL'] = jsonFileURL ?? "";
    data['notification_senderId'] = notificationServerKey ?? "";
    data['web_notification_key'] = webNotificationKey ?? "";
    data['privacyPolicy'] = privacyPolicy ?? "";
    data['termsAndConditions'] = termsAndConditions ?? "";
    data['aboutApp'] = aboutApp ?? "";
    data['customerAppColor'] = customerAppColor ?? "";
    data['appName'] = appName ?? "";
    data['countryCode'] = countryCode ?? "";
    data['referral_Amount'] = referralAmount ?? "";
    if (mapSettings != null) {
      data['mapSettings'] = mapSettings!.toJson();
    }
    return data;
  }
}

class MapSettingModel {
  String? googleMapKey;
  String? mapType;

  MapSettingModel({this.googleMapKey, this.mapType});

  MapSettingModel.fromJson(Map<String, dynamic> json) {
    googleMapKey = json['googleMapKey'];
    mapType = json['mapType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['googleMapKey'] = googleMapKey;
    data['mapType'] = mapType;
    return data;
  }
}
