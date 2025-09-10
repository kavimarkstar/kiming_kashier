import 'package:flutter/material.dart';
import 'package:kiming_kashier/core/view/middle/state/bill_state.dart';
import 'package:kiming_kashier/core/view/middle/state/bill_models.dart';
import 'package:kiming_kashier/theme/theme.dart';

Widget middlebuild(BuildContext context) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(5, 2.5, 5, 2.5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(width: 1, color: Colors.white.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ValueListenableBuilder(
            valueListenable: BillState.current,
            builder: (context, value, _) => SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,

                columnWidths: const <int, TableColumnWidth>{
                  0: FlexColumnWidth(0.4),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      border: const Border(
                        bottom: BorderSide(width: 0.5, color: Colors.white),
                      ),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Center(
                          child: Text(
                            "No",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Products",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Item Code",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Center(
                          child: Text(
                            "Qty",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Price",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...List<TableRow>.generate(value.items.length, (int index) {
                    final BillItem item = value.items[index];
                    final bool isLast =
                        BillState.lastAddedProductId == item.productId;
                    final bool isEven = index % 2 == 0;
                    final Color base = isLast
                        ? AppTheme.primaryColor.withOpacity(0.25)
                        : (isEven
                              ? Colors.white.withOpacity(0.03)
                              : Colors.transparent);
                    return TableRow(
                      decoration: BoxDecoration(
                        color: base,
                        border: const Border(
                          bottom: BorderSide(
                            width: 0.05,
                            color: Colors.white24,
                          ),
                        ),
                        boxShadow: isLast
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.description,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isLast
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.itemCode,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              item.price.toStringAsFixed(2),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  // Footer subtotal row (only visible after '+' when cashGiven > 0)
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      border: const Border(
                        top: BorderSide(width: 0.5, color: Colors.white),
                      ),
                    ),
                    children: [
                      const SizedBox.shrink(),
                      ValueListenableBuilder<double>(
                        valueListenable: BillState.cashGiven,
                        builder: (context, cash, _) => cash > 0
                            ? const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Subtotal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox.shrink(),
                      ValueListenableBuilder<double>(
                        valueListenable: BillState.cashGiven,
                        builder: (context, cash, _) => cash > 0
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                child: Center(
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: BillState.pieces,
                                    builder: (context, p, _) => Text(
                                      '$p',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: BillState.cashGiven,
                        builder: (context, cash, _) => cash > 0
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: BillState.subtotal,
                                    builder: (context, s, _) => Text(
                                      s.toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
