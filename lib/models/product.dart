class Product {
  int? id;
  String? name;
  String? description;
  double? price;
  String? barcode;
  bool? isAvailable;
  int? stock;
  String? image;
  int? categoryId;
  String? categoryName;

  Product();

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    stock = json['stock'];
    isAvailable = json['isAvaliable'];
    image = json['image'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'isAvaliable': isAvailable,
      'image': image,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
