class Category {
  int? id;
  String? name;
  String? description;
  String? selectedStatus;

  Category();

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    selectedStatus = json['status'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': selectedStatus
    };
  }
}
