import 'package:flutter/material.dart';
import 'package:dagangan/core/auth_services.dart';
import 'package:dagangan/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    // Ambil warna dari ThemeData
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
            ? 3
            : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
              'On Shift: $displayName',
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
              itemCount: 4,
              itemBuilder: (context, index) {
                final menuItems = [
                  {'icon': Icons.shopping_bag, 'title': 'Manage Products', 'route': '/categories'},
                  {'icon': Icons.settings, 'title': 'Settings', 'route': '/settings'},
                  {'icon': Icons.shopping_cart, 'title': 'Input Transaction', 'route': '/transaction'},
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

    return HoverableCard(
      icon: icon,
      title: title,
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      hoverColor: colorScheme.primary.withOpacity(0.1), // Warna hover dari tema
      clickedColor: colorScheme.primary.withOpacity(0.2), // Warna klik dari tema
      iconColor: colorScheme.primary, // Warna ikon dari tema
    );
  }
}

class HoverableCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color hoverColor;
  final Color clickedColor;
  final Color iconColor;

  const HoverableCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.hoverColor,
    required this.clickedColor,
    required this.iconColor,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isClicked = true),
        onTapUp: (_) {
          setState(() => _isClicked = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isClicked = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isClicked
                ? colorScheme.primary.withOpacity(0.3)
                : _isHovered
                    ? colorScheme.primary.withOpacity(0.1)
                    : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 40, color: colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}