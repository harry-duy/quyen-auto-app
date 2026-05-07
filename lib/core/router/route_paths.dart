abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const catalogue = '/home/catalogue';
  static const orders = '/home/orders';
  static const warranty = '/home/warranty';
  static const profile = '/home/profile';
  static const productDetail = '/product/:id';
  static const orderDetail = '/order/:id';
  static const quotation = '/quotation-form';
  static const chat = '/chat/:roomId';
  static const notifications = '/notifications';
  static const addVehicle = '/vehicle/add';

  static String productOf(String id) => '/product/$id';
  static String orderOf(String id) => '/order/$id';
  static String chatOf(String roomId) => '/chat/$roomId';
}

abstract final class StaffRoutes {
  static const home = '/staff/home';
  static const orderDetail = '/staff/order/:id';
  static const chat = '/staff/chat/:roomId';
  static const dealerMap = '/staff/dealers/map';
  static const departments = '/staff/management/departments';
  static const staffMembers = '/staff/management/staff';

  static String orderOf(String id) => '/staff/order/$id';
  static String chatOf(String roomId) => '/staff/chat/$roomId';
}
