class Item {
  final String id;
  final String name;
  final String description;
  final String condition;
  final double price;
  final String contact;
  final List<String> imageBase64List;
  final double? locationLat;
  final double? locationLng;
  final String? locationName;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.price,
    required this.contact,
    required this.imageBase64List,
    this.locationLat,
    this.locationLng,
    this.locationName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'condition': condition,
      'price': price,
      'contact': contact,
      'imageBase64List': imageBase64List,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'locationName': locationName,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map, String id) {
    return Item(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      condition: map['condition'] ?? '',
      price: (map['price'] as num).toDouble(),
      contact: map['contact'] ?? '',
      imageBase64List: List<String>.from(map['imageBase64List'] ?? []),
      locationLat: map['locationLat'] != null ? (map['locationLat'] as num).toDouble() : null,
      locationLng: map['locationLng'] != null ? (map['locationLng'] as num).toDouble() : null,
      locationName: map['locationName'],
    );
  }
}
