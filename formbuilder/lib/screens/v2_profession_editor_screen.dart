import 'package:flutter/material.dart';
import '../services/v2_firebase_service.dart';
import '../models/v2_form_config.dart';
import 'v2_flow_editor_screen.dart';

/// V2 Profession Editor Screen
class V2ProfessionEditorScreen extends StatefulWidget {
  final String professionId;
  final V2FormConfig? initialConfig;

  const V2ProfessionEditorScreen({
    super.key,
    required this.professionId,
    this.initialConfig,
  });

  @override
  State<V2ProfessionEditorScreen> createState() =>
      _V2ProfessionEditorScreenState();
}

class _V2ProfessionEditorScreenState extends State<V2ProfessionEditorScreen> {
  final V2FirebaseService _service = V2FirebaseService();
  late V2FormConfig _config;
  late TextEditingController _displayNameController;
  late TextEditingController _iconController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _config =
        widget.initialConfig ??
        V2FormConfig(
          version: '2.0.0',
          profession: V2ProfessionMetadata(
            id: widget.professionId,
            displayName: widget.professionId,
          ),
          flows: {},
        );
    _displayNameController = TextEditingController(
      text: _config.profession.displayName,
    );
    _iconController = TextEditingController(
      text: _config.profession.icon ?? '',
    );
  }

  Future<void> _saveChanges() async {
    final updatedConfig = _config.copyWith(
      profession: _config.profession.copyWith(
        displayName: _displayNameController.text.trim(),
        icon: _iconController.text.trim().isEmpty
            ? null
            : _iconController.text.trim(),
      ),
    );

    final success = await _service.saveProfessionConfig(
      widget.professionId,
      updatedConfig,
    );

    if (success && mounted) {
      setState(() {
        _config = updatedConfig;
        _hasChanges = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved successfully')));
    }
  }

  Future<void> _addFlow() async {
    final idController = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Flow'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Flow ID',
                hintText: 'e.g., b_pharm',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., B.Pharm',
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
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      final flowId = idController.text.trim();
      final displayName = nameController.text.trim();

      if (flowId.isEmpty || displayName.isEmpty) return;

      final newFlow = V2FlowConfig(
        id: flowId,
        displayName: displayName,
        startStep: 'start',
        steps: {
          'start': V2StepConfig(
            id: 'start',
            type: 'cardSelection',
            title: 'Start',
            edges: [],
          ),
        },
      );

      setState(() {
        final updatedFlows = Map<String, V2FlowConfig>.from(_config.flows);
        updatedFlows[flowId] = newFlow;
        _config = _config.copyWith(flows: updatedFlows);
        _hasChanges = true;
      });
    }
  }

  Future<void> _deleteFlow(String flowId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flow'),
        content: Text('Delete flow "$flowId"?'),
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
      setState(() {
        final updatedFlows = Map<String, V2FlowConfig>.from(_config.flows);
        updatedFlows.remove(flowId);
        _config = _config.copyWith(flows: updatedFlows);
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.professionId}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (_hasChanges)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profession Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profession Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() => _hasChanges = true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _iconController,
                      decoration: const InputDecoration(
                        labelText: 'Icon (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., medication',
                      ),
                      onChanged: (_) => setState(() => _hasChanges = true),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Flows Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Flows',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addFlow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Flow'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_config.flows.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No flows. Add one to get started.'),
                  ),
                ),
              )
            else
              ...(_config.flows.entries.map((entry) {
                final flow = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.account_tree, color: Colors.white),
                    ),
                    title: Text(
                      flow.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Steps: ${flow.steps.length} | Start: ${flow.startStep}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          onPressed: () async {
                            final updatedFlow =
                                await Navigator.push<V2FlowConfig>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        V2FlowEditorScreen(flow: flow),
                                  ),
                                );
                            if (updatedFlow != null) {
                              setState(() {
                                final updatedFlows =
                                    Map<String, V2FlowConfig>.from(
                                      _config.flows,
                                    );
                                updatedFlows[entry.key] = updatedFlow;
                                _config = _config.copyWith(flows: updatedFlows);
                                _hasChanges = true;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFlow(entry.key),
                        ),
                      ],
                    ),
                  ),
                );
              })),
          ],
        ),
      ),
      floatingActionButton: _hasChanges
          ? FloatingActionButton.extended(
              onPressed: _saveChanges,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Save', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _iconController.dispose();
    super.dispose();
  }
}
