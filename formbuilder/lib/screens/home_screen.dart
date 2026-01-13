import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/form_config.dart';
import 'profession_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<String> _professionIds = [];
  Map<String, FormConfig?> _professions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfessions();
  }

  Future<void> _loadProfessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ids = await _firebaseService.getAllProfessionIds();
      final professionsMap = <String, FormConfig?>{};

      for (final id in ids) {
        final config = await _firebaseService.getProfessionConfig(id);
        professionsMap[id] = config;
      }

      setState(() {
        _professionIds = ids;
        _professions = professionsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading professions: $e')),
        );
      }
    }
  }

  Future<void> _createNewProfession() async {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Profession'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Profession ID',
                hintText: 'e.g., doctor, nurse',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., Doctor, Nurse',
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
      final professionId = idController.text.trim();
      final displayName = nameController.text.trim();

      if (professionId.isEmpty || displayName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all fields')),
          );
        }
        return;
      }

      // Create empty profession config
      final newConfig = FormConfig(
        version: '1.0.0',
        profession: ProfessionMetadata(
          id: professionId,
          displayName: displayName,
          courseTypes: [],
        ),
        flows: {},
        lastUpdated: DateTime.now().toIso8601String(),
      );

      final success =
          await _firebaseService.saveProfessionConfig(professionId, newConfig);

      if (success) {
        await _loadProfessions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profession created successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create profession')),
          );
        }
      }
    }
  }

  Future<void> _deleteProfession(String professionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profession'),
        content: Text('Are you sure you want to delete "$professionId"?'),
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
      final success = await _firebaseService.deleteProfessionConfig(professionId);

      if (success) {
        await _loadProfessions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profession deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete profession')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Meds - Form Builder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Form Builder Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Professions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Import/Export'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Version History'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ),
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
                      const Text(
                        'No professions found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _createNewProfession,
                        icon: const Icon(Icons.add),
                        label: const Text('Create New Profession'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _professionIds.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final professionId = _professionIds[index];
                    final config = _professions[professionId];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(professionId[0].toUpperCase()),
                        ),
                        title: Text(
                          config?.profession.displayName ?? professionId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Flows: ${config?.flows.length ?? 0} | '
                          'Version: ${config?.version ?? "N/A"}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfessionEditorScreen(
                                      professionId: professionId,
                                      initialConfig: config,
                                    ),
                                  ),
                                );
                                _loadProfessions();
                              },
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProfession(professionId),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewProfession,
        tooltip: 'Create New Profession',
        child: const Icon(Icons.add),
      ),
    );
  }
}
