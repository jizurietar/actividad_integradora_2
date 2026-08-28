import 'product.dart';

enum OrderStatus { pending, completed, cancelled }

class Order {
  final String id;
  final String userId;
  final List<Product> products;
  final double total;
  final DateTime date;
  OrderStatus status;

  Order({
    required this.id,
    required this.userId,
    required this.products,
    required this.total,
    required this.date,
    this.status = OrderStatus.pending,
  });

  // Copia para modificar
  Order copyWith({
    OrderStatus? status,
    List<Product>? products,
    double? total,
  }) {
    return Order(
      id: id,
      userId: userId,
      products: products ?? this.products,
      total: total ?? this.total,
      date: date,
      status: status ?? this.status,
    );
  }
}
