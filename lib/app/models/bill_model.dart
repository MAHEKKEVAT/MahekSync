// lib/app/models/bill_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BillItemModel {
  String? itemName;
  String? paymentMethodId;
  String? paymentMethodName;
  String? paymentMethodIcon;
  int? qty;
  double? unitPrice;
  double? total;

  BillItemModel({
    this.itemName,
    this.paymentMethodId,
    this.paymentMethodName,
    this.paymentMethodIcon,
    this.qty,
    this.unitPrice,
    this.total,
  });

  double get calculatedTotal => (qty ?? 0) * (unitPrice ?? 0);

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      itemName: json['itemName'],
      paymentMethodId: json['paymentMethodId'],
      paymentMethodName: json['paymentMethodName'],
      paymentMethodIcon: json['paymentMethodIcon'],
      qty: json['qty'] ?? 1,
      unitPrice: json['unitPrice']?.toDouble(),
      total: json['total']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'paymentMethodIcon': paymentMethodIcon,
      'qty': qty,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}

class BillModel {
  String? id;
  String? ownerId;
  String? toName;
  String? invoiceNumber;
  DateTime? billDate;
  List<BillItemModel>? items;
  String? notes;
  double? totalAmount;
  String? paymentInfo;
  String? myName;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  BillModel({
    this.id,
    this.ownerId,
    this.toName,
    this.invoiceNumber,
    this.billDate,
    this.items,
    this.notes,
    this.totalAmount,
    this.paymentInfo,
    this.myName,
    this.createdAt,
    this.updatedAt,
  });

  double get computedTotal =>
      (items ?? []).fold(0.0, (total, item) => total + (item.total ?? 0));

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      ownerId: json['ownerId'],
      toName: json['toName'],
      invoiceNumber: json['invoiceNumber'],
      billDate: json['billDate']?.toDate(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => BillItemModel.fromJson(item))
              .toList()
          : [],
      notes: json['notes'],
      totalAmount: json['totalAmount']?.toDouble(),
      paymentInfo: json['paymentInfo'],
      myName: json['myName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'toName': toName,
      'invoiceNumber': invoiceNumber,
      'billDate': billDate,
      'items': items?.map((item) => item.toJson()).toList() ?? [],
      'notes': notes,
      'totalAmount': totalAmount,
      'paymentInfo': paymentInfo,
      'myName': myName,
      'createdAt': createdAt ?? Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  String get formattedInvoiceNumber => invoiceNumber ?? 'N/A';

  String get formattedBillDate => billDate != null
      ? '${billDate!.day.toString().padLeft(2, '0')}/${billDate!.month.toString().padLeft(2, '0')}/${billDate!.year}'
      : 'N/A';

  String get formattedTotal =>
      '₹${totalAmount?.toStringAsFixed(2) ?? '0.00'}';

  int get itemCount => items?.length ?? 0;
}
