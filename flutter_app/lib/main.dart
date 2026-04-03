import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_money/screens/auth/auth_landing_screen.dart';
import 'package:split_money/providers/auth_provider.dart';
import 'package:split_money/providers/group_provider.dart';
import 'package:split_money/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.loadUser(); // 🔥 load saved data

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider? authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    //final provider = authProvider ?? AuthProvider();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // ignore: unnecessary_null_comparison
            home: provider.token != null
                ? const MainScreen()
                : const AuthLandingScreen(),
          );
        },
      ),
    );
  }
}
