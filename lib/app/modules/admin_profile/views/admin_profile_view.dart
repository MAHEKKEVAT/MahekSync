import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/admin_profile_controller.dart';

class AdminProfileView extends GetView<AdminProfileController> {
  const AdminProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdminProfileView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AdminProfileView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
