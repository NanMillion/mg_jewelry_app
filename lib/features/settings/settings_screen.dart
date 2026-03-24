import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../services/storage_service.dart';
import '../../models/company_settings.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final service = SettingsService();
  final storage = StorageService();

  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final gstCtrl = TextEditingController();

  String? logoUrl;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    gstCtrl.dispose();
    super.dispose();
  }

  // ================= LOAD =================
  Future<void> load() async {
    try {
      final data = await service.fetchSettings();

      if (!mounted) return;

      if (data != null) {
        nameCtrl.text = data.name;
        addressCtrl.text = data.address;
        gstCtrl.text = data.gst;
        logoUrl = data.logoUrl;
      }

      setState(() => loading = false);
    } catch (e) {
      debugPrint("Settings load error: $e");
      setState(() => loading = false);
    }
  }

  // ================= PICK LOGO =================
  Future<void> pickLogo() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);

      if (file == null) return;

      final bytes = await file.readAsBytes();

      setState(() => saving = true);

      final url = await storage.uploadLogo(bytes);

      setState(() {
        logoUrl = url;
        saving = false;
      });
    } catch (e) {
      setState(() => saving = false);
    }
  }

  // ================= SAVE =================
  Future<void> save() async {
    setState(() => saving = true);

    try {
      final settings = CompanySettings(
        name: nameCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        gst: gstCtrl.text.trim(),
        logoUrl: logoUrl,
      );

      await service.updateSettings(settings);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Saved successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Save failed")));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),

      appBar: AppBar(
        title: const Text("Company Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _logoSection(),

                  const SizedBox(height: 20),

                  _input(nameCtrl, "Company Name"),
                  const SizedBox(height: 12),

                  _input(addressCtrl, "Address"),
                  const SizedBox(height: 12),

                  _input(gstCtrl, "GST Number"),

                  const SizedBox(height: 30),

                  _saveButton(),
                ],
              ),
            ),
    );
  }

  // ================= LOGO =================
  Widget _logoSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.white10,
          backgroundImage:
              logoUrl != null ? NetworkImage(logoUrl!) : null,
          child: logoUrl == null
              ? const Icon(Icons.business, size: 40, color: Colors.white54)
              : null,
        ),

        const SizedBox(height: 10),

        TextButton.icon(
          onPressed: saving ? null : pickLogo,
          icon: const Icon(Icons.upload, color: Colors.white),
          label: const Text(
            "Upload Logo",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ================= INPUT =================
  Widget _input(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= SAVE BUTTON =================
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : save,
        child: saving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Save Settings"),
      ),
    );
  }
}