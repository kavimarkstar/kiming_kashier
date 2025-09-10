import 'package:mongo_dart/mongo_dart.dart';
import 'package:kiming_kashier/Server/database/loacl_database.dart';
import 'package:kiming_kashier/core/view/top/model/top_model.dart';

class BrandService {
  const BrandService();

  Future<List<Brand>> fetchBrands({Map<String, dynamic>? filter}) async {
    final DbCollection collection =
        await LocalDatabaseConfig.brandsDbCollection as DbCollection;
    final Map<String, dynamic> resolvedFilter = filter ?? <String, dynamic>{};
    final List<Map<String, dynamic>> raw = await collection
        .find(resolvedFilter)
        .toList();
    return raw.map(Brand.fromMap).toList(growable: false);
  }
}
