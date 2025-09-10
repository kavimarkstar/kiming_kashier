import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiming_kashier/theme/theme.dart';
import 'package:kiming_kashier/core/home/auth/cashier_auth_service.dart';
import 'package:kiming_kashier/core/home/auth/cashier_session.dart';

class CashierLoginDialog extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const CashierLoginDialog({super.key, this.onLoginSuccess});

  @override
  State<CashierLoginDialog> createState() => _CashierLoginDialogState();
}

class _CashierLoginDialogState extends State<CashierLoginDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus nodes for keyboard navigation
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _loginButtonFocusNode = FocusNode();

  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    // Initialize focus nodes list
    _focusNodes.addAll([
      _usernameFocusNode,
      _passwordFocusNode,
      _loginButtonFocusNode,
    ]);

    // Set initial focus to username field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginButtonFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validate input
    if (username.isEmpty || password.isEmpty) {
      AppTheme.showErrorMessage(
        context,
        'Please enter both username and password',
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );

      // Authenticate with database
      final cashier = await CashierAuthService.authenticateCashier(
        username: username,
        password: password,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (cashier != null) {
        // Save cashier session
        await CashierSession.setCashierSession(cashier);

        // Login successful
        AppTheme.showSuccessMessage(
          context,
          'Welcome, ${cashier['fullName']}!',
        );

        // Close login dialog
        Navigator.of(context).pop();

        // Notify parent widget of successful login
        widget.onLoginSuccess?.call();

        print(
          'Cashier logged in: ${cashier['fullName']} (${cashier['cashierUsername']})',
        );
      } else {
        // Login failed
        AppTheme.showErrorMessage(context, 'Invalid username or password');
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      AppTheme.showErrorMessage(context, 'Login failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.2, color: Colors.white),
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: BlurryContainer(
            blur: 5,
            elevation: 0,
            color: Colors.white.withOpacity(0.05),
            padding: const EdgeInsets.all(8),
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            width: MediaQuery.of(context).size.width * 0.4,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cashier Login',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.surfaceColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  buildTextField(
                    'Username',
                    'Enter your username',
                    _usernameController,
                    _usernameFocusNode,
                    onSubmitted: () => _passwordFocusNode.requestFocus(),
                  ),

                  SizedBox(height: 20),
                  buildTextField(
                    'Password',
                    'Enter your password',
                    _passwordController,
                    _passwordFocusNode,
                    onSubmitted: () => _loginButtonFocusNode.requestFocus(),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,

                    children: [
                      Focus(
                        focusNode: _loginButtonFocusNode,
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.enter) {
                            _handleLogin();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.surfaceColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _handleLogin,
                          child: Text(
                            'Login',
                            style: TextStyle(color: AppTheme.surfaceColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildTextField(
  String label,
  String hint,
  TextEditingController controller,
  FocusNode focusNode, {
  VoidCallback? onSubmitted,
}) {
  return TextField(
    controller: controller,
    focusNode: focusNode,
    style: const TextStyle(
      color: Colors.white,
    ), // Set input text color to white
    onSubmitted: (_) => onSubmitted?.call(),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
      hintStyle: const TextStyle(color: AppTheme.textTertiary, fontSize: 14),
    ),
  );
}
