import 'package:flutter/material.dart';
import 'package:resrevacion_canchas/login_users_page.dart';
import 'package:resrevacion_canchas/login_admin_page.dart';

class SeleccionLoginPage extends StatelessWidget {
  const SeleccionLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color azulElectrico = const Color(0xFF0D47A1);
    final Color naranjaFuerte = const Color(0xFFFF6F00);
    final Color blanco = Colors.white;

    return Scaffold(
      backgroundColor: azulElectrico,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 100, color: blanco),
              const SizedBox(height: 20),
              Text(
                'Fútbol Pasión',
                style: TextStyle(
                  color: naranjaFuerte,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginUsersPage()),
                  );
                },
                icon: const Icon(Icons.person),
                label: const Text('Ingresar como Usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: naranjaFuerte,
                  foregroundColor: blanco,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginAdminPage()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Ingresar como Administrador'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blanco,
                  foregroundColor: azulElectrico,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
