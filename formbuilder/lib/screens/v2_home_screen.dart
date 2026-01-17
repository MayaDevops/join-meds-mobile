import 'package:flutter/material.dart';
import '../services/v2_firebase_service.dart';
import '../models/v2_form_config.dart';
import 'v2_profession_editor_screen.dart';

/// V2 Home Screen - Profession list with V2 data structure
class V2HomeScreen extends StatefulWidget {
  const V2HomeScreen({super.key});

  @override
  State<V2HomeScreen> createState() => _V2HomeScreenState();
}

class _V2HomeScreenState extends State<V2HomeScreen> {
  final V2FirebaseService _service = V2FirebaseService();
  List<String> _professionIds = [];
  Map<String, V2FormConfig?> _professions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfessions();
  }

  Future<void> _loadProfessions() async {
    setState(() => _isLoading = true);

    try {
      final ids = await _service.getAllProfessionIds();
      final map = <String, V2FormConfig?>{};

      for (final id in ids) {
        map[id] = await _service.getProfessionConfig(id);
      }

      setState(() {
        _professionIds = ids;
        _professions = map;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _createProfession() async {
    final idController = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Profession'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID',
                hintText: 'e.g., pharmacist',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., Pharmacist',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      final id = idController.text.trim();
      final name = nameController.text.trim();

      if (id.isEmpty || name.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        return;
      }

      final config = V2FormConfig(
        version: '2.0.0',
        profession: V2ProfessionMetadata(id: id, displayName: name),
        flows: {},
      );

      final success = await _service.saveProfessionConfig(id, config);
      if (success) {
        await _loadProfessions();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profession created')));
        }
      }
    }
  }

  Future<void> _deleteProfession(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profession'),
        content: Text('Delete "$id"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _service.deleteProfessionConfig(id);
      if (success) {
        await _loadProfessions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Builder V2'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _professionIds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No professions'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _createProfession,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Profession'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _professionIds.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final id = _professionIds[index];
                final config = _professions[id];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Text(
                        id[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      config?.profession.displayName ?? id,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Flows: ${config?.flows.length ?? 0} | V${config?.version ?? "2.0.0"}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => V2ProfessionEditorScreen(
                                  professionId: id,
                                  initialConfig: config,
                                ),
                              ),
                            );
                            _loadProfessions();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProfession(id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProfession,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
