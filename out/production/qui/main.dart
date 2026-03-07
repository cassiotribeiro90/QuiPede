import 'package:flutter/material.dart';
import 'app/routes/app_router.dart';
import 'app/routes/app_routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Meu App com BLoC',
      initialRoute: Routes.SPLASH,
      // A mágica acontece aqui!
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
