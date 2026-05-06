// TODO: Add form validators for all input fields

class Validators {
  Validators._();

  static String? required(String? value, [String field = 'Trường này']) {
    if (value == null || value.trim().isEmpty) return '$field không được để trống';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }
}
