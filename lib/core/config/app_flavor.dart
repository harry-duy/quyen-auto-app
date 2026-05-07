enum Flavor { customer, staff }

class AppFlavor {
  static Flavor _current = Flavor.customer;

  static Flavor get current => _current;
  static bool get isCustomer => _current == Flavor.customer;
  static bool get isStaff => _current == Flavor.staff;

  static void init(Flavor flavor) => _current = flavor;
}
