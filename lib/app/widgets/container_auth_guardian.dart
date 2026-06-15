import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/admin_main_screen.dart';
import '../screens/psicologo_main_screen.dart';

class ContainerAuthGuardian extends StatelessWidget {
  const ContainerAuthGuardian({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('empleados')
          .limit(1)
          .snapshots(includeMetadataChanges: true),
      builder: (context, netSnapshot) {
        final bool esDesdeCache =
            netSnapshot.data?.metadata.isFromCache ?? false;
        final bool tieneEscriturasPendientes =
            netSnapshot.data?.metadata.hasPendingWrites ?? false;

        final bool mostrarBloqueoOffline =
            esDesdeCache &&
            !tieneEscriturasPendientes &&
            netSnapshot.connectionState == ConnectionState.active;

        return Stack(
          alignment: Alignment.center,
          children: [
            _buildAuthFlow(),
            if (mostrarBloqueoOffline)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            color: Color(0xFFE65100),
                            size: 52,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sin Conexión a Internet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Los servicios del sistema se reanudarán automáticamente cuando retorne la señal de red.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              color: Color(0xFFE65100),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAuthFlow() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            ),
          );
        }

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data?.uid != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  ),
                );
              }

              if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                final userData =
                    roleSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final String role = (userData['rol'] ?? userData['role'] ?? '')
                    .toString()
                    .toLowerCase();

                switch (role) {
                  case 'admin':
                    return const AdminMainScreen();
                  case 'psicologo':
                    return const PsicologoMainScreen();
                  case 'rrhh':
                  default:
                    return const MainScreen();
                }
              }

              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
