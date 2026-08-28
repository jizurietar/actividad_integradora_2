import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/user.dart';
import '../models/product.dart';

class DataService {
  static List<User> _users = [];
  static List<Product> _products = [];

  static List<User> get users => _users;
  static List<Product> get products => _products;

  // Cargar datos desde assets (se llama al inicio)
  static Future<void> loadData() async {
    // Cargar usuarios
    final userJson = await rootBundle.loadString('assets/data/users.json');
    final userList = json.decode(userJson) as List;
    _users = userList.map((e) => User.fromJson(e)).toList();

    // Cargar productos
    final productJson = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final productList = json.decode(productJson) as List;
    _products = productList.map((e) => Product.fromJson(e)).toList();
  }

  // Autenticación
  static User? login(String email, String password) {
    try {
      return _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }
}
