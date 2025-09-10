class BillItem {
  final String productId;
  final String itemCode;
  final String description;
  final int quantity;
  final double price;

  BillItem({
    required this.productId,
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.price,
  });

  BillItem copyWith({
    String? productId,
    String? itemCode,
    String? description,
    int? quantity,
    double? price,
  }) {
    return BillItem(
      productId: productId ?? this.productId,
      itemCode: itemCode ?? this.itemCode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

class Bill {
  final String billNumber;
  final List<BillItem> items;

  Bill({required this.billNumber, required this.items});

  Bill copyWith({String? billNumber, List<BillItem>? items}) {
    return Bill(
      billNumber: billNumber ?? this.billNumber,
      items: items ?? this.items,
    );
  }
}
