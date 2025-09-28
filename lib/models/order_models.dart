class OrderSummary {
  final int id;
  final String uid;
  final DateTime createdAt;
  final double total;
  final int itemCount;
  final String status;
  const OrderSummary({
    required this.id,
    required this.uid,
    required this.createdAt,
    required this.total,
    required this.itemCount,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'created_at': createdAt.millisecondsSinceEpoch,
        'total': total,
        'item_count': itemCount,
        'status': status,
      };

  factory OrderSummary.fromJson(Map<String, dynamic> j) => OrderSummary(
        id: (j['id'] as num).toInt(),
        uid: j['uid'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch((j['created_at'] as num).toInt()),
        total: (j['total'] as num).toDouble(),
        itemCount: (j['item_count'] as num).toInt(),
        status: j['status'] as String,
      );
}

class OrderItemModel {
  final int? id;
  final int orderId;
  final int productId;
  final String title;
  final double price;
  final int qty;
  final String image;
  const OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.title,
    required this.price,
    required this.qty,
    required this.image,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'product_id': productId,
        'title': title,
        'price': price,
        'qty': qty,
        'image': image,
      };

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        id: (j['id'] as num?)?.toInt(),
        orderId: (j['order_id'] as num).toInt(),
        productId: (j['product_id'] as num).toInt(),
        title: j['title'] as String,
        price: (j['price'] as num).toDouble(),
        qty: (j['qty'] as num).toInt(),
        image: j['image'] as String,
      );
}
