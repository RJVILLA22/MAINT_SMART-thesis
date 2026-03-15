class Tool {
  String? id;
  String model;
  int borrowDays;
  String status;
  String? borrowedBy; //null if status is available
  String? description;

  Tool({
    this.id,
    required this.model,
    required this.borrowDays,
    required this.status,
    this.borrowedBy,
    this.description,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'],
      model: json['model'],
      borrowDays: json['borrowDays'],
      status: json['status'],
      borrowedBy: json['borrowedBy'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'borrowDays': borrowDays,
      'status': status,
      'borrowedBy': borrowedBy,
      'description': description,
    };
  }
}
