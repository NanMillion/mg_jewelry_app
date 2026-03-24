class PermissionHelper {
  // ================= SAFE CHECK =================
  static bool _check(Map<String, dynamic>? p, String key) {
    if (p == null) return false;

    final value = p[key];

    // Handle bool or int (1/0) safely
    if (value is bool) return value;
    if (value is int) return value == 1;

    return false;
  }

  // ================= BILLING =================
  static bool canBilling(Map<String, dynamic>? p) =>
      _check(p, 'can_manage_billing');

  // ================= INVENTORY =================
  static bool canInventory(Map<String, dynamic>? p) =>
      _check(p, 'can_manage_inventory');

  // ================= USERS =================
  static bool canManageUsers(Map<String, dynamic>? p) =>
      _check(p, 'can_manage_users');

  // ================= REPORTS =================
  static bool canViewReports(Map<String, dynamic>? p) =>
      _check(p, 'can_view_reports');

  // ================= INVOICE =================
  static bool canInvoice(Map<String, dynamic>? p) =>
      _check(p, 'can_create_invoice');

  // ================= EXTRA (PRO FEATURES) =================

  static bool canDelete(Map<String, dynamic>? p) =>
      _check(p, 'can_delete');

  static bool canEdit(Map<String, dynamic>? p) =>
      _check(p, 'can_edit');

  static bool canCreate(Map<String, dynamic>? p) =>
      _check(p, 'can_create');

  static bool isAdmin(Map<String, dynamic>? p) =>
      _check(p, 'is_admin');

  static bool isOwner(Map<String, dynamic>? p) =>
      _check(p, 'is_owner');
}