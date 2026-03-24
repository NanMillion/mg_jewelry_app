import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/task_service.dart';
import '../../services/user_service.dart';

class TaskScreen extends StatefulWidget {
  final String role;

  const TaskScreen({super.key, required this.role});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final taskService = TaskService();
  final userService = UserService();

  List<Map<String, dynamic>> users = [];

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String? selectedUser;
  PlatformFile? selectedFile; // ✅ FILE

  String search = "";
  String statusFilter = "all";
  String sort = "latest";

  bool loadingUsers = true;

  bool get isAdmin =>
      widget.role == 'admin' || widget.role == 'owner';

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final u = await userService.fetchUsers();
      if (!mounted) return;

      setState(() {
        users = u;
        loadingUsers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loadingUsers = false);
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  // ================= CREATE =================
  Future<void> createTask() async {
    if (titleCtrl.text.isEmpty || selectedUser == null) return;

    String? fileUrl;

    // 🔥 UPLOAD FILE
    if (selectedFile != null) {
      fileUrl = await taskService.uploadFile(selectedFile!);
    }

    await taskService.createTask(
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      assignedTo: selectedUser!,
      fileUrl: fileUrl,
    );

    titleCtrl.clear();
    descCtrl.clear();

    if (!mounted) return;
    setState(() {
      selectedUser = null;
      selectedFile = null;
    });

    _show("Task created");
  }

  // ================= COLORS =================
  Color statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color priorityColor(String p) {
    switch (p) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // ================= DEADLINE =================
  String formatDeadline(String? value) {
    if (value == null) return "";

    try {
      final dt = DateTime.parse(value);
      final diff = dt.difference(DateTime.now());

      if (diff.isNegative) return "Overdue";
      if (diff.inDays > 0) return "${diff.inDays}d left";
      if (diff.inHours > 0) return "${diff.inHours}h left";

      return "${diff.inMinutes}m left";
    } catch (_) {
      return "";
    }
  }

  // ================= PROGRESS =================
  double taskProgress(String status) {
    switch (status) {
      case 'completed':
        return 1;
      case 'pending':
        return 0.3;
      default:
        return 0;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(title: const Text("Tasks")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isAdmin) _createBox(),

            _searchBar(),
            const SizedBox(height: 10),

            _filters(),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: taskService.streamTasks(role: widget.role),
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  var tasks = snap.data!;

                  // SEARCH
                  tasks = tasks.where((t) {
                    return (t['title'] ?? "")
                        .toString()
                        .toLowerCase()
                        .contains(search);
                  }).toList();

                  // STATUS
                  if (statusFilter != "all") {
                    tasks = tasks
                        .where((t) => t['status'] == statusFilter)
                        .toList();
                  }

                  // SORT
                  tasks.sort((a, b) {
                    final aTime = DateTime.tryParse(
                            a['created_at']?.toString() ?? '') ??
                        DateTime.now();

                    final bTime = DateTime.tryParse(
                            b['created_at']?.toString() ?? '') ??
                        DateTime.now();

                    return sort == "latest"
                        ? bTime.compareTo(aTime)
                        : aTime.compareTo(bTime);
                  });

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text("No tasks",
                          style: TextStyle(color: Colors.white70)),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final t = tasks[i];
                      final done = t['status'] == 'completed';

                      return _taskCard(t, done);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CREATE BOX =================
  Widget _createBox() {
    if (loadingUsers) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _input(titleCtrl, "Task Title"),
          const SizedBox(height: 8),
          _input(descCtrl, "Description"),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: selectedUser,
            dropdownColor: const Color(0xFF1E293B),
            hint: const Text("Assign User"),
            items: users.map<DropdownMenuItem<String>>((u) {
              return DropdownMenuItem<String>(
                value: u['id'].toString(),
                child: Text(u['email'] ?? ''),
              );
            }).toList(),
            onChanged: (v) => setState(() => selectedUser = v),
          ),

          const SizedBox(height: 10),

          // 📎 FILE PICKER
          ElevatedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: Text(
              selectedFile?.name ?? "Attach File",
            ),
            onPressed: () async {
              final result =
                  await FilePicker.platform.pickFiles();

              if (result != null) {
                setState(() {
                  selectedFile = result.files.first;
                });
              }
            },
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: createTask,
            child: const Text("Create Task"),
          ),
        ],
      ),
    );
  }

  // ================= TASK CARD =================
  Widget _taskCard(Map<String, dynamic> t, bool done) {
    final priority = t['priority'] ?? 'medium';
    final deadline = t['deadline'];
    final attachments = List.from(t['attachments'] ?? []);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 120,
            decoration: BoxDecoration(
              color: priorityColor(priority),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t['title'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(
                        done
                            ? Icons.check_circle
                            : Icons.pending,
                        color: statusColor(t['status']),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    t['description'] ?? '',
                    style:
                        const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: taskProgress(t['status']),
                    backgroundColor: Colors.white12,
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 6,
                    children: [
                      Chip(label: Text(t['status'])),
                      Chip(label: Text(priority)),
                    ],
                  ),

                  if (deadline != null)
                    Text(
                      "⏳ ${formatDeadline(deadline)}",
                      style:
                          const TextStyle(color: Colors.orange),
                    ),

                  // 📎 ATTACHMENTS
                  for (var file in attachments)
                    TextButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text("Open File"),
                      onPressed: () {
                        launchUrl(Uri.parse(file));
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _searchBar() {
    return TextField(
      onChanged: (v) =>
          setState(() => search = v.toLowerCase()),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search...",
        filled: true,
        fillColor: Colors.white10,
        prefixIcon:
            const Icon(Icons.search, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= FILTER =================
  Widget _filters() {
    return Row(
      children: [
        _dropdown(statusFilter,
            ["all", "pending", "completed"],
            (v) => setState(() => statusFilter = v)),
        const SizedBox(width: 8),
        _dropdown(sort, ["latest", "oldest"],
            (v) => setState(() => sort = v)),
      ],
    );
  }

  Widget _dropdown(
      String value, List<String> list, Function(String) onChange) {
    return DropdownButton<String>(
      value: value,
      items: list
          .map((e) =>
              DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => onChange(v!),
    );
  }

  Widget _input(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}