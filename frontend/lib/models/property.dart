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
  final int? bedrooms;
  final int? bathrooms;
  final int? area;
  final int? brokerId;
  final bool hasWifi; 
  final int? garageSpots;

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
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.brokerId,
    required this.hasWifi,
    this.garageSpots,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
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
      area: json['area'],
      brokerId: json['broker_id'],
      hasWifi: (json['has_wifi'] == 1 || json['has_wifi'] == true),
      garageSpots: json['garage_spots'],
    );
  }
}