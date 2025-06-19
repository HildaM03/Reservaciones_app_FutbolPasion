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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: blanco,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bienvenido(a)',
                        style: TextStyle(
                          color: blanco,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Cómo deseas ingresar?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blanco.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  Column(
                    children: [
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
                          elevation: 8,
                          shadowColor: Colors.black45,
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                          elevation: 6,
                          shadowColor: Colors.black26,
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
