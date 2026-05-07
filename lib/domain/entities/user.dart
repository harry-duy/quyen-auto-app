enum UserRole {
  customer,
  staff,
  manager,
  admin;

  bool get isStaffOrAbove =>
      this == staff || this == manager || this == admin;

  bool get isManagerOrAbove => this == manager || this == admin;

  bool get isAdmin => this == admin;

  String get label => switch (this) {
        customer => 'Khách hàng',
        staff => 'Nhân viên',
        manager => 'Quản lý',
        admin => 'Quản trị viên',
      };

  static UserRole fromString(String? value) => switch (value?.toUpperCase()) {
        'STAFF' => staff,
        'MANAGER' => manager,
        'ADMIN' => admin,
        _ => customer,
      };
}

class User {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final UserRole role;
  final bool isActive;
  final String? departmentId;
  final String? departmentName;
  final String? position;
  final String? employeeCode;

  const User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.departmentId,
    this.departmentName,
    this.position,
    this.employeeCode,
  });
}
