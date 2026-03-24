import 'package:flutter/material.dart';

// AUTH
import 'package:mg_jewelry/features/auth/login_screen.dart';

// 🔥 NEW NAVIGATION
import 'package:mg_jewelry/features/navigation/main_navigation.dart';

// FEATURES
import 'package:mg_jewelry/features/employees/employees_screen.dart';
import 'package:mg_jewelry/features/inventory/inventory_screen.dart';
import 'package:mg_jewelry/features/tasks/task_screen.dart';
import 'package:mg_jewelry/features/chat/chat_screen.dart';
import 'package:mg_jewelry/features/chat/chat_list_screen.dart';
import 'package:mg_jewelry/features/billing/billing_screen.dart';
import 'package:mg_jewelry/features/billing/invoice_history_screen.dart';
import 'package:mg_jewelry/features/billing/create_invoice_screen.dart';
import 'package:mg_jewelry/features/notifications/notification_screen.dart';

class AppRouter {
  // ================= ROUTES =================
  static const login = '/login';

  static const home = '/home';
  static const admin = '/admin';
  static const owner = '/owner';
  static const employee = '/employee';

  static const employees = '/employees';
  static const inventory = '/inventory';
  static const tasks = '/tasks';

  static const chatList = '/chatList';
  static const chat = '/chat';

  static const billing = '/billing';
  static const invoices = '/invoices';
  static const createInvoice = '/createInvoice';

  static const notifications = '/notifications';

  // ================= ROUTER =================
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final user = _extractUser(args);

    switch (settings.name) {
      // ================= AUTH =================
      case login:
        return _page(const LoginScreen());

      // ================= MAIN NAVIGATION =================
      case home:
      case admin:
      case owner:
      case employee:
        return _guard(
          user,
          ['owner', 'admin', 'employee'],
          () => MainNavigation(
            name: user['email'] ?? '',
            role: _role(user),
          ),
        );

      // ================= EMPLOYEES =================
      case employees:
        return _guard(
          user,
          ['owner', 'admin'],
          () => EmployeesScreen(role: _role(user)),
        );

      // ================= INVENTORY =================
      case inventory:
        return _guard(
          user,
          ['owner', 'admin', 'employee'],
          () => const InventoryScreen(),
        );

      // ================= TASKS =================
      case tasks:
        return _guard(
          user,
          ['owner', 'admin', 'employee'],
          () => TaskScreen(role: _role(user)),
        );

      // ================= CHAT =================
      case chatList:
        return _guard(
          user,
          ['owner', 'admin', 'employee'],
          () => ChatListScreen(user: user),
        );

      case chat:
        return _chatRoute(args);

      // ================= BILLING =================
      case billing:
        return _guard(
          user,
          ['owner', 'admin'],
          () => const BillingScreen(),
        );

      case invoices:
        return _guard(
          user,
          ['owner', 'admin'],
          () => const InvoiceHistoryScreen(),
        );

      case createInvoice:
        return _guard(
          user,
          ['owner', 'admin'],
          () => const CreateInvoiceScreen(),
        );

      // ================= NOTIFICATIONS =================
      case notifications:
        return _guard(
          user,
          ['owner', 'admin', 'employee'],
          () => NotificationScreen(),
        );

      // ================= DEFAULT =================
      default:
        return _page(const LoginScreen());
    }
  }

  // ================= CHAT ROUTE =================
  static Route _chatRoute(dynamic args) {
    if (args is Map<String, dynamic>) {
      final user = args['user'];
      final otherUser = args['otherUser'];

      if (_isValidUser(user) && _isValidUser(otherUser)) {
        return _page(
          ChatScreen(
            user: user,
            otherUser: otherUser,
          ),
        );
      }
    }

    return _page(const LoginScreen());
  }

  // ================= HELPERS =================

  static Map<String, dynamic> _extractUser(dynamic args) {
    if (args is Map<String, dynamic> && _isValidUser(args)) {
      return args;
    }

    return _emptyUser();
  }

  static Map<String, dynamic> _emptyUser() {
    return {
      'id': '',
      'role': 'employee',
      'email': '',
      'name': '',
    };
  }

  static bool _isValidUser(dynamic u) {
    return u is Map<String, dynamic> &&
        u['id'] != null &&
        u['id'].toString().isNotEmpty;
  }

  static String _role(Map<String, dynamic> user) {
    return user['role']?.toString() ?? 'employee';
  }

  static MaterialPageRoute _page(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }

  static MaterialPageRoute _guard(
    Map<String, dynamic> user,
    List<String> allowedRoles,
    Widget Function() builder,
  ) {
    if (!_isValidUser(user)) {
      return _page(const LoginScreen());
    }

    final role = _role(user);

    if (!allowedRoles.contains(role)) {
      return _page(
        MainNavigation(
          name: user['email'] ?? '',
          role: role,
        ),
      );
    }

    return _page(builder());
  }
}