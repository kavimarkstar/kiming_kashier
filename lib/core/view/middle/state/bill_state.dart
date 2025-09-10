import 'package:flutter/foundation.dart';
import 'package:kiming_kashier/core/view/middle/state/bill_models.dart';

class BillState {
  static final ValueNotifier<Bill> current = ValueNotifier<Bill>(
    Bill(billNumber: '0000001', items: <BillItem>[]),
  );

  static String? lastAddedProductId;
  static Bill? _lastBill;

  static final ValueNotifier<double> subtotal = ValueNotifier<double>(0.0);
  static final ValueNotifier<int> pieces = ValueNotifier<int>(0);
  static final ValueNotifier<double> cashGiven = ValueNotifier<double>(0.0);
  static final ValueNotifier<double> changeDue = ValueNotifier<double>(0.0);

  static void _recomputeTotals() {
    final double s = current.value.items.fold(
      0.0,
      (double a, BillItem b) => a + (b.price * b.quantity),
    );
    final int p = current.value.items.fold(
      0,
      (int a, BillItem b) => a + b.quantity,
    );
    subtotal.value = s;
    pieces.value = p;
    changeDue.value = (cashGiven.value - subtotal.value);
  }

  static void reset({String billNumber = '0000001'}) {
    // Save current bill as last bill before resetting
    if (current.value.items.isNotEmpty) {
      _lastBill = current.value;
    }
    current.value = Bill(billNumber: billNumber, items: <BillItem>[]);
    lastAddedProductId = null;
    cashGiven.value = 0.0;
    _recomputeTotals();
  }

  static void clearLastBill() {
    _lastBill = null;
  }

  static Bill? get lastBill => _lastBill;

  static void restoreLastBill() {
    if (_lastBill != null) {
      current.value = _lastBill!;
      _recomputeTotals();
    }
  }

  static void setItems(List<BillItem> items) {
    current.value = current.value.copyWith(items: List<BillItem>.from(items));
    _recomputeTotals();
  }

  static void addOrIncrementItem(BillItem newItem) {
    final List<BillItem> updated = List<BillItem>.from(current.value.items);
    final int existingIndex = updated.indexWhere(
      (BillItem i) => i.productId == newItem.productId,
    );
    if (existingIndex >= 0) {
      final BillItem existing = updated[existingIndex];
      updated[existingIndex] = existing.copyWith(
        quantity: existing.quantity + newItem.quantity,
      );
    } else {
      updated.add(newItem);
    }
    lastAddedProductId = newItem.productId;
    current.value = current.value.copyWith(items: updated);
    _recomputeTotals();
  }

  static void decrementOrRemoveItem({
    required String productId,
    required int quantity,
  }) {
    if (quantity <= 0) return;
    final List<BillItem> updated = List<BillItem>.from(current.value.items);
    final int existingIndex = updated.indexWhere(
      (BillItem i) => i.productId == productId,
    );
    if (existingIndex < 0) return;
    final BillItem existing = updated[existingIndex];
    final int newQty = existing.quantity - quantity;
    if (newQty > 0) {
      updated[existingIndex] = existing.copyWith(quantity: newQty);
    } else {
      updated.removeAt(existingIndex);
    }
    current.value = current.value.copyWith(items: updated);
    _recomputeTotals();
  }

  static void setCashGiven(double amount) {
    cashGiven.value = amount;
    changeDue.value = (cashGiven.value - subtotal.value);
  }
}
