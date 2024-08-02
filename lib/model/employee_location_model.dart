// To parse this JSON data, do
//
//     final employeeLocationModel = employeeLocationModelFromJson(jsonString);

import 'dart:convert';

EmployeeLocationModel employeeLocationModelFromJson(String str) => EmployeeLocationModel.fromJson(json.decode(str));

String employeeLocationModelToJson(EmployeeLocationModel data) => json.encode(data.toJson());

class EmployeeLocationModel {
    bool? success;
    int? total;
    EmployeeLocationData? data;

    EmployeeLocationModel({
        this.success,
        this.total,
        this.data,
    });

    factory EmployeeLocationModel.fromJson(Map<String, dynamic> json) => EmployeeLocationModel(
        success: json["success"],
        total: json["total"],
        data: json["data"] == null ? null : EmployeeLocationData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "total": total,
        "data": data?.toJson(),
    };
}

class EmployeeLocationData {
    String? name;
    int? id;
    List<LocationWithTIme>? locations;

    EmployeeLocationData({
        this.name,
        this.id,
        this.locations,
    });

    factory EmployeeLocationData.fromJson(Map<String, dynamic> json) => EmployeeLocationData(
        name: json["name"],
        id: json["id"],
        locations: json["locations"] == null ? [] : List<LocationWithTIme>.from(json["locations"]!.map((x) => LocationWithTIme.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "locations": locations == null ? [] : List<dynamic>.from(locations!.map((x) => x.toJson())),
    };
}

class LocationWithTIme {
    String? time;
    double? lat;
    double? long;

    LocationWithTIme({
        this.time,
        this.lat,
        this.long,
    });

    factory LocationWithTIme.fromJson(Map<String, dynamic> json) => LocationWithTIme(
        time: json["time"],
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "time": time,
        "lat": lat,
        "long": long,
    };
}
