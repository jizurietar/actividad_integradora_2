import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'services/data_service.dart';
import 'utils/constants.dart';
import 'models/product.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

void main() async {
  //Inicializa y conecta el motor de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  // Cargar datos JSON al inicio
  await DataService.loadData();
  runApp(
    ChangeNotifierProvider<CartProvider>(
      create: (context) => CartProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Tienda Virtual',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.primary,
          ),
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.cart: (context) => const CartScreen(),
        AppRoutes.orders: (context) => const OrdersScreen(),
      },
      //home: const Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
