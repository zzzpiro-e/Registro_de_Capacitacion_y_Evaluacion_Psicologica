import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:io';

class ConnectivityOverlay extends StatefulWidget {
  final Widget child;

  const ConnectivityOverlay({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityOverlay> createState() =>
      _ConnectivityOverlayState();
}

class _ConnectivityOverlayState
    extends State<ConnectivityOverlay> {

  bool hasInternet = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    checkInternet();

    timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => checkInternet(),
    );
  }

  Future<void> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      final connected =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (connected != hasInternet) {
        setState(() {
          hasInternet = connected;
        });
      }
    } catch (_) {
      if (hasInternet) {
        setState(() {
          hasInternet = false;
        });
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (!hasInternet)
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.15),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Container(
                              width: 320,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.12),
                                    blurRadius: 30,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.shade300,
                                          Colors.green.shade600,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.wifi_off_rounded,
                                      size: 45,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  Text(
                                    'Sin conexión',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade800,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    'Revisa tu conexión a internet.\nLa aplicación se reconectará automáticamente.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}