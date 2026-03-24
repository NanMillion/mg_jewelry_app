class CompanySettings {
  final String name;
  final String address;
  final String gst;
  final String? logoUrl;

  CompanySettings({
    required this.name,
    required this.address,
    required this.gst,
    this.logoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'gst': gst,
      'logo_url': logoUrl,
    };
  }

  factory CompanySettings.fromMap(Map<String, dynamic> map) {
    return CompanySettings(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      gst: map['gst'] ?? '',
      logoUrl: map['logo_url'],
    );
  }
}