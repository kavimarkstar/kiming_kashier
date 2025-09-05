import 'package:flutter/material.dart';

class Keyboard extends StatefulWidget {
  final Function(String)? onKeyPressed;
  final Function()? onBackspace;
  final Function()? onEnter;

  const Keyboard({Key? key, this.onKeyPressed, this.onBackspace, this.onEnter})
    : super(key: key);

  @override
  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(width: 0.1, color: Colors.white),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildKey(
                    icon: Icons.keyboard_return,
                    onTap: widget.onEnter,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKey(
                    icon: Icons.backspace_outlined,
                    onTap: widget.onBackspace,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildKeyRow(['?', '<', '>']),
            const SizedBox(height: 8),
            // First row: 1, 2, 3
            _buildKeyRow(['1', '2', '3']),
            const SizedBox(height: 8),
            // Second row: 4, 5, 6
            _buildKeyRow(['4', '5', '6']),
            const SizedBox(height: 8),
            // Third row: 7, 8, 9
            _buildKeyRow(['7', '8', '9']),
            const SizedBox(height: 8),
            // Fourth row: Backspace, 0, 00, 000
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildKey(
                      text: '0',
                      onTap: () => widget.onKeyPressed?.call('0'),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildKey(
                      text: '00',
                      onTap: () => widget.onKeyPressed?.call('00'),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildKey(
                      text: '000',
                      onTap: () => widget.onKeyPressed?.call('000'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildIcon('assets/icons/cash.png', 'Cash', () {}),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildIcon('assets/icons/credit.png', 'Credit', () {}),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildIcon('assets/icons/debit.png', 'Debit', () {}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String icon, String title, VoidCallback onPressed) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[300]!, width: 0.1),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, height: 40),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildKeyRow(List<String> numbers) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildKey(
              text: number,
              onTap: () => widget.onKeyPressed?.call(number),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey({
    String? text,
    IconData? icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          padding: EdgeInsets.zero,
        ),
        child: text != null
            ? Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
            : Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}
