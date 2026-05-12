class Validators {
  Validators._();

  static String? required(String? value, [String field = 'Trường này']) {
    if (value == null || value.trim().isEmpty) return '$field không được để trống';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập số điện thoại';
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$').hasMatch(cleaned)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự';
    return null;
  }

  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 8) return 'Mật khẩu phải ít nhất 8 ký tự';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Cần ít nhất 1 chữ hoa';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Cần ít nhất 1 chữ số';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Cần ít nhất 1 ký tự đặc biệt';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ tên';
    if (value.trim().length < 2) return 'Họ tên quá ngắn';
    if (value.trim().length > 100) return 'Họ tên quá dài (tối đa 100 ký tự)';
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Họ tên không được chứa số hoặc ký tự đặc biệt';
    }
    return null;
  }

  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập biển số xe';
    final cleaned = value.replaceAll(RegExp(r'[\s\-.]'), '').toUpperCase();
    if (!RegExp(r'^[0-9]{2}[A-Z][0-9]{4,5}$').hasMatch(cleaned)) {
      return 'Biển số xe không hợp lệ (VD: 51F12345)';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Giá trị']) {
    if (value == null || value.trim().isEmpty) return '$field không được để trống';
    final num? parsed = num.tryParse(value.replaceAll(',', ''));
    if (parsed == null) return '$field phải là số';
    if (parsed <= 0) return '$field phải lớn hơn 0';
    return null;
  }

  static String sanitize(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[<>"\x27;]'), '')
        .trim();
  }
}
