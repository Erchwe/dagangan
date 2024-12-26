import 'package:flutter/material.dart';
import 'package:dagangan/core/auth_services.dart';
import 'package:dagangan/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
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
    // Mendapatkan lebar layar
    final screenWidth = MediaQuery.of(context).size.width;

    // Menentukan jumlah kolom berdasarkan lebar layar
    int crossAxisCount = screenWidth > 1200
        ? 4 // Jika layar sangat lebar, tampilkan 4 kolom
        : screenWidth > 800
            ? 3 // Jika layar sedang, tampilkan 3 kolom
            : 2; // Jika layar kecil, tampilkan 2 kolom

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Welcome to Dagangan POS!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6, // Jumlah total menu item
              itemBuilder: (context, index) {
                final menuItems = [
                  {'icon': Icons.shopping_bag, 'title': 'Categories', 'route': '/categories'},
                  {'icon': Icons.settings, 'title': 'Settings', 'route': '/settings'},
                  {'icon': Icons.shopping_cart, 'title': 'Input Transaction', 'route': '/transaction'},
                  {'icon': Icons.person, 'title': 'Profile', 'route': '/profile'},
                  {'icon': Icons.bar_chart, 'title': 'Reports', 'route': '/reports'},
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
    return HoverableCard(
      icon: icon,
      title: title,
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}

// Widget Khusus untuk Animasi Hover dan Klik
class HoverableCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const HoverableCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
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
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _isClicked
                ? Colors.deepPurple[300]
                : _isHovered
                    ? Colors.deepPurple[100]
                    : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 40,
                color: _isClicked
                    ? Colors.white
                    : _isHovered
                        ? Colors.deepPurple
                        : Color(0xFF6A11CB),
              ),
              SizedBox(height: 10),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  color: _isClicked
                      ? Colors.white
                      : _isHovered
                          ? Colors.deepPurple
                          : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
