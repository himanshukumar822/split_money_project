class Group {
  final String id;
  final String name;
  final List<dynamic> members;
  final List<dynamic> expenses;
  final List<dynamic> balances;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.expenses,
    required this.balances,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['_id'],
      name: json['name'] ?? '',
      members: json['members'] ?? [],
      expenses: json['expenses'] ?? [],
      balances: json['balances'] ?? [],
    );
  }
}
