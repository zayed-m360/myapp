// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:myapp/constants/constants.dart';
import '../widgets/app_dropdown.dart';

class MapPage extends StatefulWidget {
  static const LatLng m360 = LatLng(23.788752945834084, 90.40882928334105);

  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    _loadOfficeIcon();
    _loadPointIcon();
    super.initState();
  }

  final Completer<GoogleMapController> _mapController = Completer();

  BitmapDescriptor officeIcon = BitmapDescriptor.defaultMarker;
  // Default icon
  BitmapDescriptor pointIcon = BitmapDescriptor.defaultMarker;
  // Default icon
  Future<void> _loadOfficeIcon() async {
    officeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/office.png',
    );
    setState(() {});
  }

  Future<void> _loadPointIcon() async {
    pointIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/point.png',
    );
    setState(() {});
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return "${place.street}, ${place.subLocality}, ${place.locality}";
    }
    return "No address available";
  }

  Future<Set<Marker>> _createMarkers() async {
    var address = await _getAddressFromLatLng(
        MapPage.m360.latitude, MapPage.m360.longitude);
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId("M360 ICT"),
        position: MapPage.m360,
        icon: officeIcon,
        infoWindow: InfoWindow(
          snippet: address,
          title: "M360 ICT",
        ),
      ),
    };

    if (getEmployeeLocationController.employeeLocations.isNotEmpty) {
      for (var location in getEmployeeLocationController.employeeLocations) {
        var address =
            await _getAddressFromLatLng(location.lat!, location.long!);
        markers.add(
          Marker(
            markerId: MarkerId(location.time ?? ''),
            position: LatLng(location.lat!, location.long!),
            icon: pointIcon,
            infoWindow: InfoWindow(
              snippet: address,
              title: location.time,
            ),
          ),
        );
      }
    }

    return markers;
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    LatLngBounds bounds;
    if (markers.length == 1) {
      bounds = LatLngBounds(
        southwest: markers.first.position,
        northeast: markers.first.position,
      );
    } else {
      bounds = markers.fold<LatLngBounds>(
        LatLngBounds(
          southwest: markers.first.position,
          northeast: markers.first.position,
        ),
        (previous, marker) => LatLngBounds(
          southwest: LatLng(
            (previous.southwest.latitude < marker.position.latitude)
                ? previous.southwest.latitude
                : marker.position.latitude,
            (previous.southwest.longitude < marker.position.longitude)
                ? previous.southwest.longitude
                : marker.position.longitude,
          ),
          northeast: LatLng(
            (previous.northeast.latitude > marker.position.latitude)
                ? previous.northeast.latitude
                : marker.position.latitude,
            (previous.northeast.longitude > marker.position.longitude)
                ? previous.northeast.longitude
                : marker.position.longitude,
          ),
        ),
      );
    }
    return bounds;
  }

  void _updateMapBounds(
      GoogleMapController controller, Set<Marker> markers) async {
    final bounds = _calculateBounds(markers);
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Location"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            AppDropdown(
              value: getEmployeeLocationController.selectedEmployee.value,
              label: "Employee",
              hint: "Select an employee",
              itemList: const ["Zayed", "Robiul", "Shamol", "Soton"],
              onChanged: (val) {
                getEmployeeLocationController.selectedEmployee.value = val!;
              },
              itemBuilder: (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item.toString().split(" ").first,
                  style: const TextStyle(
                      color: Colors.black45,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          getEmployeeLocationController.setDate(picked);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Obx(() => Text(
                              getEmployeeLocationController
                                          .selectedDate.value ==
                                      null
                                  ? 'Choose Date'
                                  : DateFormat('yyyy-MM-dd').format(
                                      getEmployeeLocationController
                                          .selectedDate.value!),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          getEmployeeLocationController.setStartTime(picked);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: Colors.amber)),
                        padding: const EdgeInsets.all(5),
                        child: Obx(() => Text(
                              getEmployeeLocationController.startTime.value ==
                                      null
                                  ? 'Start Time'
                                  : getEmployeeLocationController
                                      .startTime.value!
                                      .format(context),
                            )),
                      ),
                    ),
                    const Text(" - "),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          getEmployeeLocationController.setEndTime(picked);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: Colors.amber)),
                        padding: const EdgeInsets.all(5),
                        child: Obx(() => Text(
                              getEmployeeLocationController.endTime.value ==
                                      null
                                  ? 'End Time'
                                  : getEmployeeLocationController.endTime.value!
                                      .format(context),
                            )),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    await getEmployeeLocationController
                        .getEmployeeLocationModel();
                    final GoogleMapController controller =
                        await _mapController.future;
                    final markers = await _createMarkers();
                    _updateMapBounds(controller, markers);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(Iconsax.send_1, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (getEmployeeLocationController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return FutureBuilder<Set<Marker>>(
                  future: _createMarkers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final markers = snapshot.data!;

                    return GoogleMap(
                      buildingsEnabled: false,
                      compassEnabled: true,
                      mapType: MapType.terrain,
                      initialCameraPosition:
                          const CameraPosition(target: MapPage.m360, zoom: 15),
                      markers: markers,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
