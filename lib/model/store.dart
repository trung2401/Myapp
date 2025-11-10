class Store {
  final int id;
  final String name;
  final String displayAddress;
  final Location location;
  final String timeOpen;
  final String timeClose;

  Store({
    required this.id,
    required this.name,
    required this.displayAddress,
    required this.location,
    required this.timeOpen,
    required this.timeClose,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      displayAddress: json['displayAddress'],
      location: Location.fromJson(json['location']),
      timeOpen: json['timeOpen'],
      timeClose: json['timeClose'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayAddress': displayAddress,
      'location': location.toJson(),
      'timeOpen': timeOpen,
      'timeClose': timeClose,
    };
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
