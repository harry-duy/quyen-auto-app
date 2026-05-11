import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/models/response/department_response.dart';
import '../../data/models/response/staff_profile_response.dart';
import '../../data/services/api_service.dart';
import '../../domain/entities/department.dart';
import '../../domain/entities/user.dart';
import 'service_providers.dart';

// ─── Departments ─────────────────────────────────────────────────────────────

final departmentListProvider =
    FutureProvider.autoDispose<List<Department>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<Department>>(
    ApiConstants.departments,
    fromData: (json) => _items(json)
        .map((e) => _departmentFromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

final departmentDetailProvider =
    FutureProvider.autoDispose.family<Department, String>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<Department>(
    ApiConstants.resolve(ApiConstants.departmentDetail, {'id': id}),
    fromData: (json) => _departmentFromJson(json as Map<String, dynamic>),
  );
  return res.data!;
});

// ─── Staff Members ───────────────────────────────────────────────────────────

final staffMemberDepartmentFilter = StateProvider<String?>((ref) => null);

final staffMemberListProvider =
    FutureProvider.autoDispose<List<User>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final deptFilter = ref.watch(staffMemberDepartmentFilter);
  final res = await api.get<List<User>>(
    ApiConstants.staffMembers,
    queryParams: {
      'page': 0,
      'size': 100,
      if (deptFilter != null) 'departmentId': deptFilter,
    },
    fromData: (json) => _items(json)
        .map((e) => _staffFromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

// ─── Management Actions ──────────────────────────────────────────────────────

class ManagementActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  ApiService get _api => ref.read(apiServiceProvider);

  // Department CRUD
  Future<void> createDepartment({
    required String name,
    String? description,
    String? managerId,
  }) async {
    await _api.post(
      ApiConstants.departments,
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (managerId != null) 'managerId': int.parse(managerId),
      },
    );
    ref.invalidate(departmentListProvider);
  }

  Future<void> updateDepartment({
    required String id,
    required String name,
    String? description,
    String? managerId,
  }) async {
    await _api.put(
      ApiConstants.resolve(ApiConstants.departmentDetail, {'id': id}),
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (managerId != null) 'managerId': int.parse(managerId),
      },
    );
    ref.invalidate(departmentListProvider);
    ref.invalidate(departmentDetailProvider(id));
  }

  // Staff CRUD
  Future<void> createStaffAccount({
    required String fullName,
    required String phone,
    required String password,
    required String role,
    String? email,
    String? departmentId,
    String? position,
  }) async {
    await _api.post(
      ApiConstants.staffMemberCreate,
      data: {
        'fullName': fullName,
        'phone': phone,
        'password': password,
        'role': role,
        if (email != null) 'email': email,
        if (departmentId != null) 'departmentId': int.parse(departmentId),
        if (position != null) 'position': position,
      },
    );
    ref.invalidate(staffMemberListProvider);
  }

  Future<void> updateStaffMember({
    required String id,
    String? fullName,
    String? email,
    String? role,
    String? departmentId,
    String? position,
  }) async {
    await _api.patch(
      ApiConstants.resolve(ApiConstants.staffMemberUpdate, {'id': id}),
      data: {
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
        if (departmentId != null) 'departmentId': int.parse(departmentId),
        if (position != null) 'position': position,
      },
    );
    ref.invalidate(staffMemberListProvider);
  }

  Future<void> toggleStaffActive(String id) async {
    await _api.patch(
      ApiConstants.resolve(ApiConstants.staffMemberToggle, {'id': id}),
    );
    ref.invalidate(staffMemberListProvider);
  }
}

final managementActionsProvider =
    NotifierProvider<ManagementActionsNotifier, void>(
        ManagementActionsNotifier.new);

// ─── Helpers ─────────────────────────────────────────────────────────────────

List<dynamic> _items(dynamic json) {
  if (json is Map<String, dynamic> && json['content'] is List) {
    return json['content'] as List;
  }
  return json as List;
}

Department _departmentFromJson(Map<String, dynamic> j) {
  final r = DepartmentResponse.fromJson(j);
  return Department(
    id: r.id.toString(),
    name: r.name,
    description: r.description,
    managerId: r.managerId?.toString(),
    managerName: r.managerName,
    staffCount: r.staffCount,
    isActive: r.isActive,
  );
}

User _staffFromJson(Map<String, dynamic> j) {
  final r = StaffProfileResponse.fromJson(j);
  return User(
    id: r.id.toString(),
    fullName: r.fullName,
    phone: r.phone,
    email: r.email,
    avatarUrl: r.avatarUrl,
    role: UserRole.fromString(r.role),
    isActive: r.isActive,
    departmentId: r.departmentId?.toString(),
    departmentName: r.departmentName,
    position: r.position,
    employeeCode: r.employeeCode,
  );
}
