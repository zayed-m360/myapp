import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:myapp/constants/constants.dart';
import '../widgets/app_dropdown.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng m360 = LatLng(23.788934724471485, 90.40879178077513);
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker; // Default icon
  BitmapDescriptor pointIcon = BitmapDescriptor.defaultMarker; // Default icon

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  List<String> employeeList = ["Zayed", "Robiul", "Shamol", "Soton"];
  String? selectedEmployee;

  @override
  void initState() {
    super.initState();
    _loadOfficeIcon();
    _loadPointIcon();
    getEmployeeLocationController.getEmployeeLocationModel();
  }

  Future<void> _loadOfficeIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _submit() {
    getEmployeeLocationController.getEmployeeLocationModel();
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return "${place.street}, ${place.subLocality}, ${place.locality}";
    }
    return "No address available";
  }

  Future<List<Marker>> _createMarkers() async {
    var address =await _getAddressFromLatLng(m360.latitude, m360.longitude);
    List<Marker> markers = [
      Marker(
        markerId: const MarkerId("Office"),
        position: m360,
        icon: customIcon,
        infoWindow: InfoWindow(
          snippet: address,
          title: "Office",
        ),
      ),
    ];

    if (getEmployeeLocationController.employeeLocationModel.value.data?.locations != null) {
      for (var location in getEmployeeLocationController.employeeLocationModel.value.data!.locations!) {
        var address =await _getAddressFromLatLng(location.lat!, location.long!);
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
              value: selectedEmployee,
              label: "Employee",
              hint: "Select an employee",
              itemList: employeeList,
              onChanged: (val) {
                setState(() {
                  selectedEmployee = val;
                });
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
                      onTap: () => _selectDate(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          selectedDate == null
                              ? 'Choose Date'
                              : DateFormat('yyyy-MM-dd').format(selectedDate!),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: Colors.amber)),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          startTime == null
                              ? 'Start Time'
                              : startTime!.format(context),
                        ),
                      ),
                    ),
                    const Text(" - "),
                    GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: Colors.amber)),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          endTime == null
                              ? 'End Time'
                              : endTime!.format(context),
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _submit(),
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
              child: FutureBuilder<List<Marker>>(
                future: _createMarkers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final markers = snapshot.data!;
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
                          (previous.southwest.latitude <
                                  marker.position.latitude)
                              ? previous.southwest.latitude
                              : marker.position.latitude,
                          (previous.southwest.longitude <
                                  marker.position.longitude)
                              ? previous.southwest.longitude
                              : marker.position.longitude,
                        ),
                        northeast: LatLng(
                          (previous.northeast.latitude >
                                  marker.position.latitude)
                              ? previous.northeast.latitude
                              : marker.position.latitude,
                          (previous.northeast.longitude >
                                  marker.position.longitude)
                              ? previous.northeast.longitude
                              : marker.position.longitude,
                        ),
                      ),
                    );
                  }

                  return GoogleMap(
                    buildingsEnabled: false,
                    compassEnabled: true,
                    mapType: MapType.terrain,
                    initialCameraPosition:
                        const CameraPosition(target: m360, zoom: 15),
                    markers: markers.toSet(),
                    onMapCreated: (GoogleMapController controller) {
                      Future.delayed(const Duration(milliseconds: 100))
                          .then((_) {
                        controller.animateCamera(
                            CameraUpdate.newLatLngBounds(bounds, 50));
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
