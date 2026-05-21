enum Flavor { customer, staff }

class AppFlavor {
  static Flavor _current = Flavor.customer;

  static Flavor get current => _current;
  static bool get isCustomer => _current == Flavor.customer;
  static bool get isStaff => _current == Flavor.staff;

  static void init(Flavor flavor) => _current = flavor;

  // Called at startup when the Dart entry point cannot set the flavor
  // (e.g. both flavors were compiled from main.dart by the Gradle wrapper).
  // Falls back to package-name detection via the app ID injected by Gradle.
  static void initFromAppId(String appId) {
    _current = appId.contains('staff') ? Flavor.staff : Flavor.customer;
  }
}
