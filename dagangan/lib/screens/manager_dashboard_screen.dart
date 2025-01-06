import 'package:flutter/material.dart';
import 'package:dagangan/core/auth_services.dart';
import 'package:dagangan/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  String displayName = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchDisplayName();
  }

  Future<void> fetchDisplayName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.userMetadata != null) {
        setState(() {
          displayName = user.userMetadata?['display_name'] ?? 'No Display Name';
        });
      }
    } catch (e) {
      setState(() {
        displayName = 'Error fetching display name';
      });
      print('Error fetching display name: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout gagal: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    int crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
            ? 3
            : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colorScheme.onPrimary),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome, Manager: $displayName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                final menuItems = [
                  {'icon': Icons.analytics, 'title': 'Sales Reports', 'route': '/sales-reports'},
                  {'icon': Icons.settings, 'title': 'Settings', 'route': '/settings'},
                  {'icon': Icons.support_agent, 'title': 'Support', 'route': '/support'},
                ];

                final item = menuItems[index];
                return _buildMenuItem(
                  context,
                  item['icon'] as IconData,
                  item['title'] as String,
                  item['route'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
