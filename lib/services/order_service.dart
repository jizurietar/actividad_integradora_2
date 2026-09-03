import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrderService {
  // Lista estática en memoria para todas las órdenes
  static final List<Order> _orders = [];
  static int _orderCounter = 1;

  // Cargar el contador guardado al iniciar la app
  static Future<void> initCounter() async {
    final prefs = await SharedPreferences.getInstance();
    _orderCounter = prefs.getInt('order_counter') ?? 1;
  }

  static List<Order> get orders => _orders;

  // Crear una nueva orden
  static void createOrder(String userId, List<Product> products, double total) {
    final orderId = 'ORD-${_orderCounter.toString().padLeft(3, '0')}';
    final order = Order(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      products: List.from(products),
      total: total,
      date: DateTime.now(),
      status: OrderStatus.pending,
    );
    _orders.add(order);
    _orderCounter++;
    _saveCounter();
  }

  static Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_counter', _orderCounter);
  }

  // Obtener órdenes de un usuario específico
  static List<Order> getOrdersByUser(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  // Modificar una orden (cambiar estado o productos)
  static void updateOrder(
    String orderId, {
    OrderStatus? status,
    List<Product>? products,
    double? total,
  }) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final old = _orders[index];
      _orders[index] = old.copyWith(
        status: status,
        products: products,
        total: total,
      );
    }
  }

  // Eliminar una orden
  static void deleteOrder(String orderId) {
    _orders.removeWhere((order) => order.id == orderId);
  }
}
