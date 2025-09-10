import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:kiming_kashier/core/view/middle/service/bill_service.dart';
import 'package:kiming_kashier/core/view/keyboard/keyboard.dart';
import 'package:kiming_kashier/core/view/middle/state/bill_state.dart';

final TextEditingController _barcodeController = TextEditingController();
final FocusNode _barcodeFocusNode = FocusNode();
bool _focusInitialized = false;

void _registerKeyboardBridge(BuildContext context) {
  KeyboardBridge.onKeyPressed = (String v) {
    if (v == '+') {
      _applyCashFromInput();
      return;
    }
    _appendText(v);
  };
  KeyboardBridge.onBackspace = () {
    _backspace();
  };
  KeyboardBridge.onEnter = () async {
    // If input parses as cash, apply it; otherwise treat as code submit
    final String raw = _barcodeController.text.trim();
    final double? cash = double.tryParse(raw);
    if (cash != null) {
      BillState.setCashGiven(cash);
      _barcodeController.clear();
      _barcodeFocusNode.requestFocus();
      await _saveBillAndNext(context);
      return;
    }
    await _submitBarcode(context, _barcodeController.text);
  };
}

void _applyCashFromInput() {
  final String raw = _barcodeController.text.trim();
  final double cash = double.tryParse(raw) ?? BillState.subtotal.value;
  if (cash <= 0) return;
  BillState.setCashGiven(cash);
  _barcodeController.clear();
  _barcodeFocusNode.requestFocus();
}

void _ensureFocusSetup(BuildContext context) {
  if (_focusInitialized) return;
  _focusInitialized = true;
  _barcodeFocusNode.addListener(() {
    // Keep focus only
  });
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _barcodeFocusNode.requestFocus();
  });
}

class _ParsedInput {
  final String code;
  final int qty;
  final bool isRemove;
  _ParsedInput({required this.code, required this.qty, required this.isRemove});
}

_ParsedInput _parseInput(String raw) {
  final String input = raw.trim();
  final RegExp removeRe = RegExp(r'^(\d+)\s*[-]\s*(\S+)$');
  final Match? rm = removeRe.firstMatch(input);
  if (rm != null && rm.groupCount >= 2) {
    final int qty = int.tryParse(rm.group(1) ?? '1') ?? 1;
    final String code = (rm.group(2) ?? '').trim();
    return _ParsedInput(code: code, qty: qty, isRemove: true);
  }
  final RegExp addQtyFirst = RegExp(r'^(\d+)\s*[\*xX]\s*(\S+)$');
  final Match? addm = addQtyFirst.firstMatch(input);
  if (addm != null && addm.groupCount >= 2) {
    final int qty = int.tryParse(addm.group(1) ?? '1') ?? 1;
    final String code = (addm.group(2) ?? '').trim();
    return _ParsedInput(code: code, qty: qty, isRemove: false);
  }
  return _ParsedInput(code: input, qty: 1, isRemove: false);
}

Future<void> _saveBillAndNext(BuildContext context) async {
  final ok = await const BillService().saveCurrentBill(
    subtotal: BillState.subtotal.value,
    cashGiven: BillState.cashGiven.value,
    changeDue: BillState.changeDue.value,
    pieces: BillState.pieces.value,
  );
  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to save bill'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }
  // Increment bill number and reset
  final String currentNo = BillState.current.value.billNumber;
  final int n = int.tryParse(currentNo) ?? 1;
  final String nextNo = (n + 1).toString().padLeft(currentNo.length, '0');
  BillState.reset(billNumber: nextNo);
  await const BillService().ensureBillExists();
}

Future<void> _submitBarcode(BuildContext context, String raw) async {
  final parsed = _parseInput(raw);
  if (parsed.code.isEmpty || parsed.qty <= 0) return;

  bool ok = false;
  try {
    if (parsed.isRemove) {
      ok = await const BillService().removeProductByCode(
        parsed.code,
        quantity: parsed.qty,
      );
    } else {
      ok = await const BillService().addProductToBillByCode(
        parsed.code,
        quantity: parsed.qty,
      );
    }
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          parsed.isRemove
              ? 'Item not found to remove: ${parsed.code}'
              : 'Item not found: ${parsed.code}',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
  _barcodeController.clear();
  _barcodeFocusNode.requestFocus();
}

void _appendText(String value) {
  final String current = _barcodeController.text;
  final String next = current + value;
  _barcodeController.text = next;
  _barcodeController.selection = TextSelection.collapsed(offset: next.length);
  _barcodeFocusNode.requestFocus();
}

void _backspace() {
  final String current = _barcodeController.text;
  if (current.isEmpty) return;
  final String next = current.substring(0, current.length - 1);
  _barcodeController.text = next;
  _barcodeController.selection = TextSelection.collapsed(offset: next.length);
  _barcodeFocusNode.requestFocus();
}

@override
Widget bottombuild(BuildContext context, bool isShow) {
  _ensureFocusSetup(context);
  _registerKeyboardBridge(context);
  return Padding(
    padding: const EdgeInsets.fromLTRB(5, 2.5, 5, 5),
    child: Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(width: 1, color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (!isShow) SizedBox(width: 60),
          AnimatedOpacity(
            opacity: !isShow ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: !isShow
                        ? MediaQuery.of(context).size.width * 0.15
                        : 0,
                    height: !isShow
                        ? MediaQuery.of(context).size.height * 0.15
                        : 0,
                    child: !isShow
                        ? Image.asset('assets/images/logo.png')
                        : SizedBox.shrink(),
                  ),
                  !isShow
                      ? Text(
                          'KaptureX',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
          if (!isShow) SizedBox(width: 60),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Focus(
                      onKey: (FocusNode node, RawKeyEvent event) {
                        if (event is RawKeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.tab) {
                          _barcodeFocusNode.requestFocus();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: const TextSelectionThemeData(
                            selectionColor: Colors.transparent,
                            selectionHandleColor: Colors.transparent,
                          ),
                        ),
                        child: TextField(
                          controller: _barcodeController,
                          focusNode: _barcodeFocusNode,
                          autofocus: true,
                          enableInteractiveSelection: false,
                          contextMenuBuilder: (context, editableTextState) {
                            return const SizedBox.shrink();
                          },
                          textInputAction: TextInputAction.done,
                          onSubmitted: (String value) async {
                            await _submitBarcode(context, value);
                          },
                          onEditingComplete: () {
                            _barcodeFocusNode.requestFocus();
                          },
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          cursorColor: Colors.blueAccent,
                          decoration: InputDecoration(
                            filled: true,
                            hint: Text(
                              '',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 17,
                                fontWeight: FontWeight.normal,
                              ),
                            ),

                            helperStyle: TextStyle(color: Colors.white70),
                            fillColor: const Color.fromARGB(
                              255,
                              102,
                              102,
                              102,
                            ).withOpacity(0.05),

                            hintStyle: TextStyle(color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20),

          Container(
            margin: const EdgeInsets.all(2),
            width: MediaQuery.of(context).size.width * 0.25,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _amountBox(context, 'TOTAL', BillState.subtotal),
                _amountBox(context, 'Pieces', BillState.pieces, isInt: true),
                _amountBox(context, 'Cash', BillState.cashGiven),
                _amountBox(context, 'Change', BillState.changeDue),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _amountBox<T>(
  BuildContext context,
  String label,
  ValueListenable<T> listenable, {
  bool isInt = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 3),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.15,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ValueListenableBuilder<T>(
            valueListenable: listenable,
            builder: (context, value, _) {
              final String text = isInt
                  ? (value as int).toString()
                  : (value as double).toStringAsFixed(2);
              return Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}
