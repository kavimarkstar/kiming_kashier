import 'package:flutter/material.dart';
import 'package:kiming_kashier/core/view/top/widget/detaile_view.dart';
import 'package:kiming_kashier/core/view/top/widget/network.dart';
import 'package:kiming_kashier/theme/util/date.dart';
import 'package:kiming_kashier/theme/util/time.dart';
import 'package:kiming_kashier/database/database_config.dart';
import 'package:kiming_kashier/core/home/auth/cashier_session.dart';
import 'package:kiming_kashier/core/view/top/service/top-service.dart';
import 'package:kiming_kashier/core/view/top/model/top_model.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:kiming_kashier/core/view/middle/state/bill_state.dart';

class TopPage extends StatefulWidget {
  final VoidCallback isShowButton;
  const TopPage({super.key, required this.isShowButton});

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  String? _brandLocation;
  Uint8List? _brandLogoBytes;

  Future<void> _loadBrandLocation() async {
    try {
      final List<Brand> brands = await const BrandService().fetchBrands();
      if (!mounted) return;
      setState(() {
        _brandLocation = brands.isNotEmpty
            ? (brands.first.location.isNotEmpty ? brands.first.location : null)
            : null;
        final String logoB64 = brands.isNotEmpty ? brands.first.logoBase64 : '';
        if (logoB64.isNotEmpty) {
          try {
            _brandLogoBytes = base64Decode(logoB64);
          } catch (_) {
            _brandLogoBytes = null;
          }
        } else {
          _brandLogoBytes = null;
        }
      });
    } catch (_) {
      // ignore errors and keep null -> UI will fallback
    }
  }

  @override
  void initState() {
    super.initState();
    // Load cashier session on widget initialization
    CashierSession.loadCashierSession();
    // Load brand location
    _loadBrandLocation();

    // Set up session change listener
    CashierSession.setOnSessionChanged(() {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild when session changes
        });
      }
    });
  }

  @override
  void dispose() {
    // Clear the session change listener
    CashierSession.setOnSessionChanged(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 2.5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(width: 1, color: Colors.white.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 23,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: _brandLogoBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),

                          child: Image.memory(
                            _brandLogoBytes!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            "assets/images/logo.png",
                            width: 100,
                            height: 100,
                          ),
                        ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    detaileViewbuild(context, _brandLocation ?? "Location"),
                    detaileViewbuild(
                      context,
                      CashierSession.cashierUsername ?? "Not Logged In",
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: BillState.current,
                      builder: (context, bill, _) =>
                          detaileViewbuild(context, bill.billNumber),
                    ),
                    detaileViewbuild(
                      context,
                      DatabaseConfig.unit.isNotEmpty
                          ? "Unit ${DatabaseConfig.unit}"
                          : "Unit",
                    ),
                  ],
                ),
              ),
            ),
            // ! Date and Time
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // ? Date
                    Date(),
                    // ? Time
                    Time(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [NetworkWidget(isShowButton: widget.isShowButton)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
