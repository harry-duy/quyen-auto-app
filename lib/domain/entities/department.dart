class Department {
  final String id;
  final String name;
  final String? description;
  final String? managerId;
  final String? managerName;
  final int staffCount;
  final bool isActive;

  const Department({
    required this.id,
    required this.name,
    this.description,
    this.managerId,
    this.managerName,
    this.staffCount = 0,
    this.isActive = true,
  });
}
