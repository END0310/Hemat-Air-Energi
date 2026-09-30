import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NotFoundScreen extends StatelessWidget {
  final String? routeName;
  const NotFoundScreen({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 72),
            const SizedBox(height: 8),
            Text('404', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            const Text('Halaman yang kamu tuju belum tersedia.'),
            if (routeName != null) Text('Route: $routeName'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}