import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:kiming_kashier/Server/database/loacl_database.dart';
import 'package:kiming_kashier/core/view/middle/state/bill_state.dart';
import 'package:kiming_kashier/core/view/middle/state/bill_models.dart';

class BillService {
  const BillService();

  Future<void> ensureBillExists() async {
    final coll = await LocalDatabaseConfig.billsDbCollection as DbCollection;
    final String billNo = BillState.current.value.billNumber;
    final existing = await coll.findOne({'billNumber': billNo});
    if (existing == null) {
      await coll.insertOne({'billNumber': billNo, 'items': <dynamic>[]});
    }
  }

  Future<bool> saveCurrentBill({
    required double subtotal,
    required double cashGiven,
    required double changeDue,
    required int pieces,
  }) async {
    try {
      final coll = await LocalDatabaseConfig.billsDbCollection as DbCollection;
      final String billNo = BillState.current.value.billNumber;
      await coll.updateOne(where.eq('billNumber', billNo), {
        r'$set': {
          'items': BillState.current.value.items
              .map(
                (e) => {
                  'productId': e.productId,
                  'itemCode': e.itemCode,
                  'description': e.description,
                  'quantity': e.quantity,
                  'price': e.price,
                },
              )
              .toList(),
          'subtotal': subtotal,
          'pieces': pieces,
          'cashGiven': cashGiven,
          'changeDue': changeDue,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillService] Error saving bill: $e');
      }
      return false;
    }
  }

  Future<void> loadBillIntoState() async {
    final coll = await LocalDatabaseConfig.billsDbCollection as DbCollection;
    final String billNo = BillState.current.value.billNumber;
    final doc = await coll.findOne({'billNumber': billNo});
    if (doc == null) {
      await ensureBillExists();
      return;
    }
    final List<dynamic> items = (doc['items'] as List<dynamic>? ?? <dynamic>[]);
    final List<BillItem> parsed = items.map((dynamic e) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);
      return BillItem(
        productId: (m['productId'] ?? '').toString(),
        itemCode: (m['itemCode'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        quantity: (m['quantity'] is num) ? (m['quantity'] as num).toInt() : 0,
        price: (m['price'] is num) ? (m['price'] as num).toDouble() : 0.0,
      );
    }).toList();
    BillState.setItems(parsed);
  }

  Future<Map<String, dynamic>?> findProductByCode(String code) async {
    final coll = await LocalDatabaseConfig.productsDbCollection as DbCollection;

    final String trimmed = code.trim();
    final bool isNumeric = RegExp(r'^\\d+$').hasMatch(trimmed);
    final String padded = isNumeric ? trimmed.padLeft(8, '0') : trimmed;
    final String depadded = isNumeric
        ? trimmed.replaceFirst(RegExp(r'^0+'), '')
        : trimmed;

    if (kDebugMode) {
      debugPrint(
        '[BillService] Lookup code: "$trimmed" (padded: "$padded", depadded: "$depadded")',
      );
    }

    final byItemExact = await coll.findOne({'itemCode': trimmed});
    if (byItemExact != null) return byItemExact;
    if (padded != trimmed) {
      final byItemPadded = await coll.findOne({'itemCode': padded});
      if (byItemPadded != null) return byItemPadded;
    }
    if (depadded != trimmed) {
      final byItemDepadded = await coll.findOne({'itemCode': depadded});
      if (byItemDepadded != null) return byItemDepadded;
    }

    final byBarcode = await coll.findOne({'barcode': trimmed});
    if (byBarcode != null) return byBarcode;
    final byRef = await coll.findOne({'referenceCode': trimmed});
    if (byRef != null) return byRef;

    final String escaped = RegExp.escape(trimmed);
    return await coll.findOne(
      where
          .match('itemCode', '^$escaped', caseInsensitive: true)
          .or(where.match('description', escaped, caseInsensitive: true))
          .or(where.match('invDescription', escaped, caseInsensitive: true))
          .map,
    );
  }

  Future<bool> addProductToBillByCode(String code, {int quantity = 1}) async {
    await ensureBillExists();
    try {
      final Map<String, dynamic>? product = await findProductByCode(code);
      if (product == null) {
        if (kDebugMode) {
          debugPrint('[BillService] No product found for "$code"');
        }
        return false;
      }

      final String id = (product['_id'] ?? '').toString();
      final String itemCode = (product['itemCode'] ?? '').toString();
      final String desc =
          (product['description'] ??
                  product['invDescription'] ??
                  product['name'] ??
                  product['altDescription'] ??
                  '')
              .toString();

      final dynamic priceRaw =
          product['eachRetPrice'] ??
          product['retail'] ??
          product['wSale'] ??
          product['whPrice'] ??
          product['price'] ??
          product['unitPrice'] ??
          product['sellPrice'] ??
          0;
      final double price = (priceRaw is num) ? priceRaw.toDouble() : 0.0;

      BillState.addOrIncrementItem(
        BillItem(
          productId: id,
          itemCode: itemCode,
          description: desc.isEmpty ? 'Item' : desc,
          quantity: quantity,
          price: price,
        ),
      );

      final coll = await LocalDatabaseConfig.billsDbCollection as DbCollection;
      final String billNo = BillState.current.value.billNumber;
      await coll.updateOne(
        where.eq('billNumber', billNo),
        modify.push('items', {
          'productId': id,
          'itemCode': itemCode,
          'description': desc,
          'quantity': quantity,
          'price': price,
        }),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillService] Error adding product: $e');
      }
      return false;
    }
  }

  Future<bool> removeProductByCode(String code, {int quantity = 1}) async {
    await ensureBillExists();
    try {
      final Map<String, dynamic>? product = await findProductByCode(code);
      if (product == null) return false;

      final String id = (product['_id'] ?? '').toString();

      BillState.decrementOrRemoveItem(productId: id, quantity: quantity);

      final coll = await LocalDatabaseConfig.billsDbCollection as DbCollection;
      final String billNo = BillState.current.value.billNumber;
      await coll.updateOne(where.eq('billNumber', billNo), {
        r'$set': {
          'items': BillState.current.value.items
              .map(
                (e) => {
                  'productId': e.productId,
                  'itemCode': e.itemCode,
                  'description': e.description,
                  'quantity': e.quantity,
                  'price': e.price,
                },
              )
              .toList(),
        },
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillService] Error removing product: $e');
      }
      return false;
    }
  }
}
