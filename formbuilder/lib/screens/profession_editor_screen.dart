import 'package:flutter/material.dart';
import '../models/form_config.dart';
import '../services/firebase_service.dart';
import 'flow_editor_screen.dart';

class ProfessionEditorScreen extends StatefulWidget {
  final String professionId;
  final FormConfig? initialConfig;

  const ProfessionEditorScreen({
    super.key,
    required this.professionId,
    this.initialConfig,
  });

  @override
  State<ProfessionEditorScreen> createState() => _ProfessionEditorScreenState();
}

class _ProfessionEditorScreenState extends State<ProfessionEditorScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  FormConfig? _config;
  List<String> _courseTypes = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeConfig();
  }

  void _initializeConfig() {
    _config = widget.initialConfig;
    if (_config != null) {
      _displayNameController.text = _config!.profession.displayName;
      _iconController.text = _config!.profession.icon ?? '';
      _descriptionController.text = _config!.profession.description ?? '';
      _courseTypes = List.from(_config!.profession.courseTypes);
    }
  }

  Future<void> _saveConfig() async {
    if (_config == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfession = ProfessionMetadata(
        id: widget.professionId,
        displayName: _displayNameController.text.trim(),
        courseTypes: _courseTypes,
        icon: _iconController.text.trim().isEmpty
            ? null
            : _iconController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      final updatedConfig = _config!.copyWith(
        profession: updatedProfession,
        lastUpdated: DateTime.now().toIso8601String(),
      );

      final success =
          await _firebaseService.saveProfessionConfig(widget.professionId, updatedConfig);

      if (success) {
        setState(() {
          _config = updatedConfig;
          _hasChanges = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profession saved successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save profession')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addCourseType() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Course Type'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Course Type',
            hintText: 'e.g., mbbs, bsc_nursing',
          ),
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

    if (result == true && controller.text.trim().isNotEmpty) {
      setState(() {
        _courseTypes.add(controller.text.trim());
        _hasChanges = true;
      });
    }
  }

  void _removeCourseType(String courseType) {
    setState(() {
      _courseTypes.remove(courseType);
      _hasChanges = true;
    });
  }

  void _addFlow() async {
    final flowIdController = TextEditingController();
    final displayNameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Flow'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: flowIdController,
              decoration: const InputDecoration(
                labelText: 'Flow ID',
                hintText: 'e.g., mbbs, b_pharm',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., MBBS, B.Pharm',
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
      final flowId = flowIdController.text.trim();
      final displayName = displayNameController.text.trim();

      if (flowId.isEmpty || displayName.isEmpty) return;

      final newFlow = FlowConfig(
        flowId: flowId,
        displayName: displayName,
        steps: [],
      );

      setState(() {
        _config = _config!.copyWith(
          flows: {..._config!.flows, flowId: newFlow},
        );
        _hasChanges = true;
      });
    }
  }

  void _deleteFlow(String flowId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flow'),
        content: Text('Are you sure you want to delete "$flowId"?'),
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
      final flows = Map<String, FlowConfig>.from(_config!.flows);
      flows.remove(flowId);

      setState(() {
        _config = _config!.copyWith(flows: flows);
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.professionId}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveConfig,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: _config == null
          ? const Center(child: Text('No configuration found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profession Metadata',
                            style: TextStyle(
                              fontSize: 20,
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
                            onChanged: (value) {
                              setState(() {
                                _hasChanges = true;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _iconController,
                            decoration: const InputDecoration(
                              labelText: 'Icon (Material Design icon name)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., medical_services',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _hasChanges = true;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onChanged: (value) {
                              setState(() {
                                _hasChanges = true;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Course Types',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ..._courseTypes.map(
                                (courseType) => Chip(
                                  label: Text(courseType),
                                  onDeleted: () => _removeCourseType(courseType),
                                ),
                              ),
                              ActionChip(
                                label: const Text('+ Add'),
                                onPressed: _addCourseType,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Flows',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _addFlow,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Flow'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_config!.flows.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No flows yet. Add a flow to get started.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._config!.flows.entries.map((entry) {
                      final flowId = entry.key;
                      final flow = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            flow.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Flow ID: $flowId | Steps: ${flow.steps.length}',
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
                                      builder: (context) => FlowEditorScreen(
                                        professionId: widget.professionId,
                                        flowId: flowId,
                                        initialFlow: flow,
                                        onFlowUpdated: (updatedFlow) {
                                          setState(() {
                                            final flows = Map<String, FlowConfig>.from(
                                                _config!.flows);
                                            flows[flowId] = updatedFlow;
                                            _config = _config!.copyWith(flows: flows);
                                            _hasChanges = true;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                                tooltip: 'Edit Flow',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteFlow(flowId),
                                tooltip: 'Delete Flow',
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _iconController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
