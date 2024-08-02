import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:myapp/json/employee_location.dart';

import '../model/employee_location_model.dart';

class GetEmployeeLocationModelController extends GetxController {
  Rx<EmployeeLocationModel> employeeLocationModel = EmployeeLocationModel().obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getEmployeeLocationModel();
  }

  Future getEmployeeLocationModel() async {
    try {
      var response = employeeLocation;

      employeeLocationModel.value = employeeLocationModelFromJson(jsonEncode(response));
      isLoading(false);
      return employeeLocationModel.value;
    } catch (e) {
      debugPrint("Error: $e");
      isLoading(false);
    }
  }
}
