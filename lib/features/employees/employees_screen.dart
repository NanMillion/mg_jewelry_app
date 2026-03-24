import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class EmployeesScreen extends StatefulWidget {
  final String role;

  const EmployeesScreen({super.key, required this.role});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final _userService = UserService();
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];

  bool _loading = true;
  bool _actionLoading = false;

  bool get isOwner => widget.role == 'owner';
  bool get isAdmin => widget.role == 'admin' || widget.role == 'owner';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ================= LOAD =================
  Future<void> _loadUsers() async {
    try {
      setState(() => _loading = true);

      final data = await _userService.fetchUsers();

      if (!mounted) return;

      setState(() {
        _users = data;
        _filtered = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint("USER LOAD ERROR: $e");
      _showMessage("Failed to load users");
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= SEARCH =================
  void _search(String text) {
    final q = text.toLowerCase();

    setState(() {
      _filtered = _users.where((u) {
        final email = (u['email'] ?? '').toString().toLowerCase();
        return email.contains(q);
      }).toList();
    });
  }

  // ================= DELETE =================
  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _actionLoading = true);

        await _userService.deleteUser(id);

        if (!mounted) return;
        _showMessage("User deleted");
        await _loadUsers();
      } catch (e) {
        _showMessage("Delete failed");
      } finally {
        if (mounted) setState(() => _actionLoading = false);
      }
    }
  }

  // ================= UPDATE ROLE =================
  Future<void> _updateRole(String userId, String role) async {
    try {
      setState(() => _actionLoading = true);

      await _userService.updateRole(userId: userId, role: role);

      if (!mounted) return;
      _showMessage("Role updated");
      await _loadUsers();
    } catch (e) {
      _showMessage("Update failed");
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  // ================= ROLE COLOR =================
  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.redAccent;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return const Center(child: Text("🚫 Access Denied"));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _header(),
                _searchBar(),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text("No users found",
                              style: TextStyle(color: Colors.white70)))
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final u = _filtered[i];

                              return _userCard(
                                u['id'].toString(),
                                u['email'] ?? '',
                                u['role'] ?? 'employee',
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // ================= HEADER =================
  Widget _header() => const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.group, color: Colors.white),
            SizedBox(width: 10),
            Text("Employee Management",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      );

  // ================= SEARCH =================
  Widget _searchBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchCtrl,
          onChanged: _search,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search users...",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white10,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  // ================= USER CARD =================
  Widget _userCard(String id, String email, String role) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(email.isNotEmpty ? email[0].toUpperCase() : "?"),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14)),

                const SizedBox(height: 4),

                // 🔥 ROLE BADGE (FIXED)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleColor(role).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      color: _roleColor(role),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isOwner)
            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: "owner", child: Text("Owner")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
                DropdownMenuItem(value: "employee", child: Text("Employee")),
              ],
              onChanged: (val) {
                if (val != null) _updateRole(id, val);
              },
            ),

          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed:
                  _actionLoading ? null : () => _confirmDelete(id),
            ),
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}