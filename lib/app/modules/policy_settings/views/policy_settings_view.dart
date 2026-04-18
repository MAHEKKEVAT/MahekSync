import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/policy_settings_controller.dart';

class PolicySettingsView extends GetView<PolicySettingsController> {
  const PolicySettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolicySettingsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PolicySettingsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
