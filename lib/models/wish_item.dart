import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WishItem extends Equatable {
  final String id;
  final String name;
  final double price; 
  final String link;
  final String description;
  final String category;
  final bool isPublic;
  final bool isBooked;
  final String? imageUrl;
  final Timestamp createdAt;

  const WishItem({
    required this.id,
    required this.name,
    this.price = 0.0,
    this.link = '',
    this.description = '',
    required this.category,
    this.isPublic = false,
    this.isBooked = false,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, name, price, link, description, category,
        isPublic, isBooked, imageUrl, createdAt
      ];

  factory WishItem.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(), 
      link: data['link'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Other', 
      isPublic: data['isPublic'] ?? false,
      isBooked: data['isBooked'] ?? false,
      imageUrl: data['imageUrl'], 
      createdAt: data['createdAt'] ?? Timestamp.now(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'link': link,
      'description': description,
      'category': category,
      'isPublic': isPublic,
      'isBooked': isBooked,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  WishItem copyWith({
    String? id,
    String? name,
    double? price,
    String? link,
    String? description,
    String? category,
    bool? isPublic,
    bool? isBooked,
    String? imageUrl,
    Timestamp? createdAt,
  }) {
    return WishItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      link: link ?? this.link,
      description: description ?? this.description,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      isBooked: isBooked ?? this.isBooked,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}