class Order {
  int? id;
  String? label;
  double? orginalPrice;
  double? discount;
  double? discountedPrice;
  String? comment;
  int? clientId;
  String? clientName;

  Order();

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    orginalPrice = json['orginalPrice'];
    discount = json['discount'];
    discountedPrice = json['discountedPrice'];
    comment = json['comment'];
    clientId = json['clientId'];
    clientName = json['clientName'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'orginalPrice': orginalPrice,
      'discount': discount,
      'discountedPrice': discountedPrice,
      'comment': comment,
      'clientId': clientId,
      'clientName': clientName,
    };
  }
}
