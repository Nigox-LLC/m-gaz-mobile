import 'package:flutter/material.dart';

import '../../../core/utils/colors.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.catalogGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Hududiy Gaz Olchov Metrologiyasi Bo'limi",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(color: Colors.white24),

              // Menyu elementlari
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Hisobotlar",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    _drawerItem(Icons.people_alt, "Hodimlar hisobot", false),
                    _drawerItem(Icons.bar_chart, "KPI hisobot", false),
                    _drawerItem(Icons.today, "Kunlik hisobot", false),
                    _drawerItem(Icons.analytics, "EGXU tahlili hisobot", false),
                    _drawerItem(
                      Icons.insert_drive_file,
                      "Universal hisobotlari",
                      false,
                    ),

                    // 📄 Umumiy hisobotlar uchun
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Boshqa",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    _drawerItem(Icons.settings, "Sotamalar", false),
                    _drawerItem(
                      Icons.exit_to_app,
                      "Chiqish",
                      false,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    bool selected, {
    String? badge,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      selected: selected,
      selectedTileColor: Colors.white24,
      onTap: () {},
    );
  }
}
