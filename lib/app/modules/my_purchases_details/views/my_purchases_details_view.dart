import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/my_purchases_details_controller.dart';

class MyPurchasesDetailsView extends GetView<MyPurchasesDetailsController> {
  const MyPurchasesDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPurchasesDetailsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MyPurchasesDetailsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
