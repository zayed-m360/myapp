import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/json/employee_location.dart';

import '../model/employee_location_model.dart';

class GetEmployeeLocationModelController extends GetxController {
  var selectedDate = Rxn<DateTime>();
  var startTime = Rxn<TimeOfDay>();
  var endTime = Rxn<TimeOfDay>();
  var employeeLocations = <LocationWithTIme>[].obs;
  RxString selectedEmployee = ''.obs;

  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  void setStartTime(TimeOfDay time) {
    startTime.value = time;
  }

  void setEndTime(TimeOfDay time) {
    endTime.value = time;
  }

  Rx<EmployeeLocationModel> employeeLocationModel = EmployeeLocationModel().obs;
  RxBool isLoading = false.obs;

  Future<void> getEmployeeLocationModel() async {
    try {
      var response = employeeLocation;  // Mock API response

      employeeLocationModel.value =
          employeeLocationModelFromJson(jsonEncode(response));
      employeeLocations.value = employeeLocationModel.value.data?.locations ?? [];
      isLoading(false);
    } catch (e) {
      debugPrint("Error: $e");
      isLoading(false);
    }
  }
}
