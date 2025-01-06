import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Color Blind Mode",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RadioListTile<ColorBlindMode>(
              title: const Text("Normal Vision"),
              value: ColorBlindMode.normal,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setColorBlindMode(value);
                }
              },
            ),
            RadioListTile<ColorBlindMode>(
              title: const Text("Deuteranopia"),
              value: ColorBlindMode.deuteranopia,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setColorBlindMode(value);
                }
              },
            ),
            RadioListTile<ColorBlindMode>(
              title: const Text("Protanopia"),
              value: ColorBlindMode.protanopia,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setColorBlindMode(value);
                }
              },
            ),
            RadioListTile<ColorBlindMode>(
              title: const Text("Tritanopia"),
              value: ColorBlindMode.tritanopia,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setColorBlindMode(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
