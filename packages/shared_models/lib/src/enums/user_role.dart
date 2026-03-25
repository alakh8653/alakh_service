enum UserRole {
  customer,
  shopOwner,
  dispatcher,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.shopOwner:
        return 'Shop Owner';
      case UserRole.dispatcher:
        return 'Dispatcher';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
