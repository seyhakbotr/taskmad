class Topic {
  final String id;
  final String name;
  final String? color;

  Topic({this.color, required this.id, required this.name});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Topic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Topic(id: $id, name: $name)';
}
