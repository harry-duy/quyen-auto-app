import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/models/response/department_response.dart';
import '../../data/models/response/staff_profile_response.dart';
import '../../data/services/api_service.dart';
import '../../domain/entities/department.dart';
import '../../domain/entities/user.dart';
import 'service_providers.dart';

// ─── Departments ─────────────────────────────────────────────────────────────

final departmentListProvider = FutureProvider.autoDispose<List<Department>>((
  ref,
) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<Department>>(
    ApiConstants.departments,
    fromData: (json) => _asList(
      json,
    ).map((e) => _departmentFromJson(e as Map<String, dynamic>)).toList(),
  );
  return res.data ?? [];
});

final departmentDetailProvider = FutureProvider.autoDispose
    .family<Department, String>((ref, id) async {
      final api = ref.watch(apiServiceProvider);
      final res = await api.get<Department>(
        ApiConstants.resolve(ApiConstants.departmentDetail, {'id': id}),
        fromData: (json) => _departmentFromJson(json as Map<String, dynamic>),
      );
      return res.data!;
    });

// ─── Staff Members ───────────────────────────────────────────────────────────

final staffMemberDepartmentFilter = StateProvider<String?>((ref) => null);

final staffMemberListProvider = FutureProvider.autoDispose<List<User>>((
  ref,
) async {
  final api = ref.watch(apiServiceProvider);
  final deptFilter = ref.watch(staffMemberDepartmentFilter);
  final res = await api.get<List<User>>(
    ApiConstants.staffMembers,
    queryParams: {'page': 0, 'size': 100, 'departmentId': ?deptFilter},
    fromData: (json) => _asList(
      json,
    ).map((e) => _staffFromJson(e as Map<String, dynamic>)).toList(),
  );
  return res.data ?? [];
});

// ─── Customer Management ─────────────────────────────────────────────────────

final customerSearchQueryProvider = StateProvider<String>((ref) => '');

final customerListProvider = FutureProvider.autoDispose<List<User>>((
  ref,
) async {
  final api = ref.watch(apiServiceProvider);
  final keyword = ref.watch(customerSearchQueryProvider);
  final res = await api.get<List<User>>(
    ApiConstants.staffCustomers,
    queryParams: {
      'page': 0,
      'size': 100,
      'sort': 'createdAt,desc',
      if (keyword.isNotEmpty) 'keyword': keyword,
    },
    fromData: (json) => _asList(
      json,
    ).map((e) => _staffFromJson(e as Map<String, dynamic>)).toList(),
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
        'description': ?description,
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
        'description': ?description,
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
        'email': ?email,
        if (departmentId != null) 'departmentId': int.parse(departmentId),
        'position': ?position,
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
    await _api.put(
      ApiConstants.resolve(ApiConstants.staffMemberUpdate, {'id': id}),
      data: {
        'fullName': ?fullName,
        'email': ?email,
        'role': ?role,
        if (departmentId != null) 'departmentId': int.parse(departmentId),
        'position': ?position,
      },
    );
    ref.invalidate(staffMemberListProvider);
  }

  Future<void> toggleStaffActive(String id) async {
    await _api.put(
      ApiConstants.resolve(ApiConstants.staffMemberToggle, {'id': id}),
    );
    ref.invalidate(staffMemberListProvider);
  }

  // Customer CRUD
  Future<void> createCustomer({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    String? note,
  }) async {
    await _api.post(
      ApiConstants.staffCustomers,
      data: {
        'fullName': fullName,
        'phone': phone,
        'password': password,
        'email': ?email,
        'note': ?note,
      },
    );
    ref.invalidate(customerListProvider);
  }

  Future<void> toggleCustomerActive(String id) async {
    await _api.patch(
      ApiConstants.resolve(ApiConstants.staffCustomerToggle, {'id': id}),
    );
    ref.invalidate(customerListProvider);
  }

  // Product CRUD (ADMIN only)
  Future<void> createProduct({
    required String name,
    required int categoryId,
    required double basePrice,
    String? description,
    String? specifications,
  }) async {
    await _api.post(
      ApiConstants.adminProducts,
      data: {
        'name': name,
        'categoryId': categoryId,
        'basePrice': basePrice,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (specifications != null && specifications.isNotEmpty)
          'specifications': specifications,
      },
    );
    ref.invalidate(adminProductListProvider);
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required int categoryId,
    required double basePrice,
    String? description,
    String? specifications,
  }) async {
    await _api.put(
      ApiConstants.resolve(ApiConstants.adminProductDetail, {'id': id}),
      data: {
        'name': name,
        'categoryId': categoryId,
        'basePrice': basePrice,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (specifications != null && specifications.isNotEmpty)
          'specifications': specifications,
      },
    );
    ref.invalidate(adminProductListProvider);
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete(
      ApiConstants.resolve(ApiConstants.adminProductDetail, {'id': id}),
    );
    ref.invalidate(adminProductListProvider);
  }

  Future<void> createQuotationTemplate({
    required String name,
    String? categoryId,
    String? productId,
    String? description,
    String? vehicleModel,
    int? chassisWidth,
    String? boxType,
    String? acType,
    String? acModel,
    String? specifications,
    required double basePrice,
    String? optionPrices,
    String? managerNote,
    bool isActive = true,
  }) async {
    await _api.post(
      ApiConstants.managerQuotationTemplates,
      data: _quotationTemplatePayload(
        name: name,
        categoryId: categoryId,
        productId: productId,
        description: description,
        vehicleModel: vehicleModel,
        chassisWidth: chassisWidth,
        boxType: boxType,
        acType: acType,
        acModel: acModel,
        specifications: specifications,
        basePrice: basePrice,
        optionPrices: optionPrices,
        managerNote: managerNote,
        isActive: isActive,
      ),
    );
    ref.invalidate(quotationTemplateListProvider);
    ref.invalidate(activeQuotationTemplateListProvider);
  }

  Future<void> updateQuotationTemplate({
    required String id,
    required String name,
    String? categoryId,
    String? productId,
    String? description,
    String? vehicleModel,
    int? chassisWidth,
    String? boxType,
    String? acType,
    String? acModel,
    String? specifications,
    required double basePrice,
    String? optionPrices,
    String? managerNote,
    bool isActive = true,
  }) async {
    await _api.put(
      ApiConstants.resolve(ApiConstants.managerQuotationTemplateDetail, {
        'id': id,
      }),
      data: _quotationTemplatePayload(
        name: name,
        categoryId: categoryId,
        productId: productId,
        description: description,
        vehicleModel: vehicleModel,
        chassisWidth: chassisWidth,
        boxType: boxType,
        acType: acType,
        acModel: acModel,
        specifications: specifications,
        basePrice: basePrice,
        optionPrices: optionPrices,
        managerNote: managerNote,
        isActive: isActive,
      ),
    );
    ref.invalidate(quotationTemplateListProvider);
    ref.invalidate(activeQuotationTemplateListProvider);
  }

  Future<void> toggleQuotationTemplate(String id) async {
    await _api.patch(
      ApiConstants.resolve(ApiConstants.managerQuotationTemplateToggle, {
        'id': id,
      }),
    );
    ref.invalidate(quotationTemplateListProvider);
    ref.invalidate(activeQuotationTemplateListProvider);
  }

  Future<void> createQuotationOption({
    required String name,
    required String position,
    required String unit,
    required double defaultPrice,
    String? description,
    String? internalNote,
    bool isActive = true,
  }) async {
    await _api.post(
      ApiConstants.managerQuotationOptions,
      data: _quotationOptionPayload(
        name: name,
        position: position,
        unit: unit,
        defaultPrice: defaultPrice,
        description: description,
        internalNote: internalNote,
        isActive: isActive,
      ),
    );
    ref.invalidate(quotationOptionListProvider);
    ref.invalidate(activeQuotationOptionListProvider);
  }

  Future<void> updateQuotationOption({
    required String id,
    required String name,
    required String position,
    required String unit,
    required double defaultPrice,
    String? description,
    String? internalNote,
    bool isActive = true,
  }) async {
    await _api.put(
      ApiConstants.resolve(ApiConstants.managerQuotationOptionDetail, {
        'id': id,
      }),
      data: _quotationOptionPayload(
        name: name,
        position: position,
        unit: unit,
        defaultPrice: defaultPrice,
        description: description,
        internalNote: internalNote,
        isActive: isActive,
      ),
    );
    ref.invalidate(quotationOptionListProvider);
    ref.invalidate(activeQuotationOptionListProvider);
  }

  Future<void> toggleQuotationOption(String id) async {
    await _api.patch(
      ApiConstants.resolve(ApiConstants.managerQuotationOptionToggle, {
        'id': id,
      }),
    );
    ref.invalidate(quotationOptionListProvider);
    ref.invalidate(activeQuotationOptionListProvider);
  }
}

final managementActionsProvider =
    NotifierProvider<ManagementActionsNotifier, void>(
      ManagementActionsNotifier.new,
    );

// ─── Products (Admin only) ───────────────────────────────────────────────────

class AdminProduct {
  final String id;
  final String name;
  final String? description;
  final String? specifications;
  final double basePrice;
  final String? categoryId;
  final String? categoryName;
  final bool isActive;
  final List<String> imageUrls;

  const AdminProduct({
    required this.id,
    required this.name,
    this.description,
    this.specifications,
    required this.basePrice,
    this.categoryId,
    this.categoryName,
    required this.isActive,
    required this.imageUrls,
  });
}

class QuotationTemplateModel {
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final String? productId;
  final String? productName;
  final String? vehicleModel;
  final int? chassisWidth;
  final String? boxType;
  final String? acType;
  final String? acModel;
  final String? specifications;
  final double basePrice;
  final String? optionPrices;
  final String? managerNote;
  final bool isActive;

  const QuotationTemplateModel({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.productId,
    this.productName,
    this.vehicleModel,
    this.chassisWidth,
    this.boxType,
    this.acType,
    this.acModel,
    this.specifications,
    required this.basePrice,
    this.optionPrices,
    this.managerNote,
    required this.isActive,
  });
}

class QuotationOptionModel {
  final String id;
  final String name;
  final String position;
  final String unit;
  final double defaultPrice;
  final String? description;
  final String? internalNote;
  final bool isActive;

  const QuotationOptionModel({
    required this.id,
    required this.name,
    required this.position,
    required this.unit,
    required this.defaultPrice,
    this.description,
    this.internalNote,
    required this.isActive,
  });
}

final adminProductListProvider = FutureProvider.autoDispose<List<AdminProduct>>(
  (ref) async {
    final api = ref.watch(apiServiceProvider);
    final res = await api.get<List<AdminProduct>>(
      ApiConstants.productList,
      queryParams: {'page': 0, 'size': 200},
      fromData: (json) {
        final page = json as Map<String, dynamic>;
        final content = page['content'] as List? ?? [];
        return content
            .map((e) => _adminProductFromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return res.data ?? [];
  },
);

final productCategoryListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final api = ref.watch(apiServiceProvider);
      final res = await api.get<List<Map<String, dynamic>>>(
        'products/categories',
        fromData: (json) =>
            _asList(json).map((e) => e as Map<String, dynamic>).toList(),
      );
      return res.data ?? [];
    });

final quotationTemplateListProvider =
    FutureProvider.autoDispose<List<QuotationTemplateModel>>((ref) async {
      final api = ref.watch(apiServiceProvider);
      final res = await api.get<List<QuotationTemplateModel>>(
        ApiConstants.managerQuotationTemplates,
        queryParams: {'page': 0, 'size': 200, 'activeOnly': false},
        fromData: (json) {
          final page = json as Map<String, dynamic>;
          final content = page['content'] as List? ?? [];
          return content
              .map((e) => _quotationTemplateFromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
      return res.data ?? [];
    });

final activeQuotationTemplateListProvider =
    FutureProvider.autoDispose<List<QuotationTemplateModel>>((ref) async {
      final api = ref.watch(apiServiceProvider);
      final res = await api.get<List<QuotationTemplateModel>>(
        ApiConstants.quotationTemplates,
        queryParams: {'page': 0, 'size': 200},
        fromData: (json) {
          final page = json as Map<String, dynamic>;
          final content = page['content'] as List? ?? [];
          return content
              .map((e) => _quotationTemplateFromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
      return res.data ?? [];
    });

final quotationOptionListProvider =
    FutureProvider.autoDispose<List<QuotationOptionModel>>((ref) async {
      final api = ref.watch(apiServiceProvider);
      final res = await api.get<List<QuotationOptionModel>>(
        ApiConstants.managerQuotationOptions,
        queryParams: {'page': 0, 'size': 300, 'activeOnly': false},
        fromData: (json) {
          final page = json as Map<String, dynamic>;
          final content = page['content'] as List? ?? [];
          return content
              .map((e) => _quotationOptionFromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
      return res.data ?? [];
    });

final activeQuotationOptionListProvider =
    FutureProvider.autoDispose<List<QuotationOptionModel>>((ref) async {
      final api = ref.watch(apiServiceProvider);
      final res = await api.get<List<QuotationOptionModel>>(
        ApiConstants.quotationOptions,
        queryParams: {'page': 0, 'size': 300},
        fromData: (json) {
          final page = json as Map<String, dynamic>;
          final content = page['content'] as List? ?? [];
          return content
              .map((e) => _quotationOptionFromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
      return res.data ?? [];
    });

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Handles null, plain List, or Spring Boot Page `{"content":[...]}`.
List<dynamic> _asList(dynamic json) {
  if (json == null) return [];
  if (json is List) return json;
  return (json as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
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

AdminProduct _adminProductFromJson(Map<String, dynamic> j) => AdminProduct(
  id: (j['id'] ?? '').toString(),
  name: j['name'] as String? ?? '',
  description: j['description'] as String?,
  specifications: j['specifications'] as String?,
  basePrice: (j['basePrice'] as num?)?.toDouble() ?? 0,
  categoryId: j['categoryId']?.toString(),
  categoryName: j['categoryName'] as String?,
  isActive: j['isActive'] as bool? ?? true,
  imageUrls: (j['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
);

QuotationTemplateModel _quotationTemplateFromJson(Map<String, dynamic> j) =>
    QuotationTemplateModel(
      id: (j['id'] ?? '').toString(),
      name: j['name'] as String? ?? '',
      description: j['description'] as String?,
      categoryId: j['categoryId']?.toString(),
      categoryName: j['categoryName'] as String?,
      productId: j['productId']?.toString(),
      productName: j['productName'] as String?,
      vehicleModel: j['vehicleModel'] as String?,
      chassisWidth: (j['chassisWidth'] as num?)?.toInt(),
      boxType: j['boxType'] as String?,
      acType: j['acType'] as String?,
      acModel: j['acModel'] as String?,
      specifications: j['specifications'] as String?,
      basePrice: (j['basePrice'] as num?)?.toDouble() ?? 0,
      optionPrices: j['optionPrices'] as String?,
      managerNote: j['managerNote'] as String?,
      isActive: j['isActive'] as bool? ?? true,
    );

QuotationOptionModel _quotationOptionFromJson(Map<String, dynamic> j) =>
    QuotationOptionModel(
      id: (j['id'] ?? '').toString(),
      name: j['name'] as String? ?? '',
      position: j['position'] as String? ?? 'OTHER',
      unit: j['unit'] as String? ?? 'cai',
      defaultPrice: (j['defaultPrice'] as num?)?.toDouble() ?? 0,
      description: j['description'] as String?,
      internalNote: j['internalNote'] as String?,
      isActive: j['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _quotationTemplatePayload({
  required String name,
  String? categoryId,
  String? productId,
  String? description,
  String? vehicleModel,
  int? chassisWidth,
  String? boxType,
  String? acType,
  String? acModel,
  String? specifications,
  required double basePrice,
  String? optionPrices,
  String? managerNote,
  required bool isActive,
}) {
  return {
    'name': name,
    if (categoryId != null) 'categoryId': int.parse(categoryId),
    if (productId != null) 'productId': int.parse(productId),
    if (description != null && description.isNotEmpty)
      'description': description,
    if (vehicleModel != null && vehicleModel.isNotEmpty)
      'vehicleModel': vehicleModel,
    'chassisWidth': ?chassisWidth,
    if (boxType != null && boxType.isNotEmpty) 'boxType': boxType,
    if (acType != null && acType.isNotEmpty) 'acType': acType,
    if (acModel != null && acModel.isNotEmpty) 'acModel': acModel,
    if (specifications != null && specifications.isNotEmpty)
      'specifications': specifications,
    'basePrice': basePrice,
    if (optionPrices != null && optionPrices.isNotEmpty)
      'optionPrices': optionPrices,
    if (managerNote != null && managerNote.isNotEmpty)
      'managerNote': managerNote,
    'isActive': isActive,
  };
}

Map<String, dynamic> _quotationOptionPayload({
  required String name,
  required String position,
  required String unit,
  required double defaultPrice,
  String? description,
  String? internalNote,
  required bool isActive,
}) {
  return {
    'name': name,
    'position': position,
    'unit': unit,
    'defaultPrice': defaultPrice,
    if (description != null && description.isNotEmpty)
      'description': description,
    if (internalNote != null && internalNote.isNotEmpty)
      'internalNote': internalNote,
    'isActive': isActive,
  };
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
