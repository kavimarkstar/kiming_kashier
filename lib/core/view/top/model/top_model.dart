import 'package:mongo_dart/mongo_dart.dart';

class Brand {
  final ObjectId objectId;
  final String name;
  final String logoBase64;
  final String location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Brand({
    required this.objectId,
    required this.name,
    required this.logoBase64,
    required this.location,
    this.createdAt,
    this.updatedAt,
  });

  String get id => objectId.oid;

  static Brand fromMap(Map<String, dynamic> map) {
    final dynamic idValue = map['_id'];
    final ObjectId resolvedId = idValue is ObjectId
        ? idValue
        : ObjectId.parse(idValue.toString());

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value.toUtc();
      try {
        return DateTime.parse(value.toString()).toUtc();
      } catch (_) {
        return null;
      }
    }

    return Brand(
      objectId: resolvedId,
      name: (map['name'] ?? '').toString(),
      logoBase64: (map['logo'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': objectId,
      'name': name,
      'logo': logoBase64,
      'location': location,
      if (createdAt != null) 'createdAt': createdAt!.toUtc(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toUtc(),
    };
  }
}
