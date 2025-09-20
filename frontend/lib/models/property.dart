class Property {
  final int id;
  final String title;
  final String description;
  final String type;
  String status;
  final String purpose;
  final double price;
  final String address;
  final String city;
  final String state;
  final int? bedrooms;
  final int? bathrooms;
  final int? area;
  final int? brokerId;
  final bool hasWifi;
  final int? garageSpots;
  final List<String> images;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.purpose,
    required this.price,
    required this.address,
    required this.city,
    required this.state,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.brokerId,
    required this.hasWifi,
    this.garageSpots,
    required this.images,
    required this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = List<String>.from(json['images'].map((item) => item.toString()));
    }
    
    return Property(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Título Indisponível',
      description: json['description'] ?? 'Sem descrição.',
      type: json['type'] ?? 'N/A',
      status: json['status'] ?? 'Disponível',
      purpose: json['purpose'] ?? 'Venda',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      address: json['address'] ?? 'Endereço não informado',
      city: json['city'] ?? 'Cidade não informada',
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      state: json['state'] ?? 'GO', 
      area: json['area'],
      brokerId: json['broker_id'],
      hasWifi: (json['has_wifi'] == 1 || json['has_wifi'] == true),
      garageSpots: json['garage_spots'],
      images: imagesList,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // No arquivo property.dart
Property copyWith({
  int? id,
  String? title,
  String? description,
  String? type,
  String? status,
  String? purpose,
  double? price,
  String? address,
  String? city,
  List<String>? images,
  int? bedrooms,
  int? bathrooms,
  int? area,
  int? brokerId,
  bool? hasWifi,
  int? garageSpots,
  String? state,
  DateTime? createdAt,
}) {
  return Property(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    type: type ?? this.type,
    status: status ?? this.status,
    purpose: purpose ?? this.purpose,
    price: price ?? this.price,
    address: address ?? this.address,
    city: city ?? this.city,
    images: images ?? this.images,
    bedrooms: bedrooms ?? this.bedrooms,
    bathrooms: bathrooms ?? this.bathrooms,
    area: area ?? this.area,
    brokerId: brokerId ?? this.brokerId,
    hasWifi: hasWifi ?? this.hasWifi,
    garageSpots: garageSpots ?? this.garageSpots,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
  );
}
}