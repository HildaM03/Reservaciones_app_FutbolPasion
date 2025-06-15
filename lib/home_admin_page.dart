import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resrevacion_canchas/seleccion_login_page.dart';

class HomeAdminPage extends StatelessWidget {
  const HomeAdminPage({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SeleccionLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color azul = const Color(0xFF0D47A1);
    final Color naranja = const Color(0xFFFF6F00);
    final Color blanco = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        title: const Text('Panel de Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildAdminCard(
              icon: Icons.calendar_today,
              label: 'Ver Reservas',
              color: naranja,
              onTap: () {
                // Navegar a página de reservas
              },
            ),
            _buildAdminCard(
              icon: Icons.people,
              label: 'Usuarios',
              color: naranja,
              onTap: () {
                // Navegar a gestión de usuarios
              },
            ),
            _buildAdminCard(
              icon: Icons.sports_soccer,
              label: 'Canchas',
              color: naranja,
              onTap: () {
                // Navegar a gestión de canchas
              },
            ),
            _buildAdminCard(
              icon: Icons.bar_chart,
              label: 'Estadísticas',
              color: naranja,
              onTap: () {
                // Navegar a estadísticas
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
