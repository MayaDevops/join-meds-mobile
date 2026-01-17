import 'package:flutter/material.dart';
import '../models/v2_form_config.dart';
import 'v2_step_editor_screen.dart';

/// V2 Flow Editor Screen - Visual graph-based step editor
class V2FlowEditorScreen extends StatefulWidget {
  final V2FlowConfig flow;

  const V2FlowEditorScreen({super.key, required this.flow});

  @override
  State<V2FlowEditorScreen> createState() => _V2FlowEditorScreenState();
}

class _V2FlowEditorScreenState extends State<V2FlowEditorScreen> {
  late V2FlowConfig _flow;
  late TextEditingController _displayNameController;
  late TextEditingController _startStepController;

  @override
  void initState() {
    super.initState();
    _flow = widget.flow;
    _displayNameController = TextEditingController(text: _flow.displayName);
    _startStepController = TextEditingController(text: _flow.startStep);
  }

  void _saveAndReturn() {
    final updatedFlow = _flow.copyWith(
      displayName: _displayNameController.text.trim(),
      startStep: _startStepController.text.trim(),
    );
    Navigator.pop(context, updatedFlow);
  }

  Future<void> _addStep() async {
    final idController = TextEditingController();
    final titleController = TextEditingController();
    String selectedType = 'form';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Step'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Step ID',
                  hintText: 'e.g., academic_status',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Academic Status',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Step Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'cardSelection',
                    child: Text('Card Selection'),
                  ),
                  DropdownMenuItem(value: 'form', child: Text('Form')),
                  DropdownMenuItem(value: 'modal', child: Text('Modal')),
                  DropdownMenuItem(value: 'grid', child: Text('Grid')),
                  DropdownMenuItem(value: 'list', child: Text('List')),
                ],
                onChanged: (value) {
                  setDialogState(() => selectedType = value!);
                },
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
      ),
    );

    if (result == true) {
      final stepId = idController.text.trim();
      final title = titleController.text.trim();

      if (stepId.isEmpty || title.isEmpty) return;

      final newStep = V2StepConfig(
        id: stepId,
        type: selectedType,
        title: title,
        edges: [],
      );

      setState(() {
        final updatedSteps = Map<String, V2StepConfig>.from(_flow.steps);
        updatedSteps[stepId] = newStep;
        _flow = _flow.copyWith(steps: updatedSteps);
      });
    }
  }

  Future<void> _deleteStep(String stepId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Step'),
        content: Text('Delete step "$stepId"?'),
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
        final updatedSteps = Map<String, V2StepConfig>.from(_flow.steps);
        updatedSteps.remove(stepId);
        _flow = _flow.copyWith(steps: updatedSteps);
      });
    }
  }

  Color _getStepTypeColor(String type) {
    switch (type) {
      case 'cardSelection':
        return Colors.blue;
      case 'form':
        return Colors.green;
      case 'modal':
        return Colors.orange;
      case 'grid':
        return Colors.purple;
      case 'list':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStepTypeIcon(String type) {
    switch (type) {
      case 'cardSelection':
        return Icons.view_agenda;
      case 'form':
        return Icons.edit_note;
      case 'modal':
        return Icons.open_in_new;
      case 'grid':
        return Icons.grid_view;
      case 'list':
        return Icons.list;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flow: ${_flow.id}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAndReturn),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flow Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Flow Settings',
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
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _flow.steps.containsKey(_startStepController.text)
                          ? _startStepController.text
                          : _flow.steps.keys.firstOrNull,
                      decoration: const InputDecoration(
                        labelText: 'Start Step',
                        border: OutlineInputBorder(),
                      ),
                      items: _flow.steps.keys.map((stepId) {
                        return DropdownMenuItem(
                          value: stepId,
                          child: Text(stepId),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _startStepController.text = value;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Steps Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Steps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Visual Flow Graph
            if (_flow.steps.isNotEmpty) _buildFlowGraph(),

            const SizedBox(height: 24),

            // Steps List
            ...(_flow.steps.entries.map((entry) {
              final step = entry.value;
              final color = _getStepTypeColor(step.type);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color,
                        child: Icon(
                          _getStepTypeIcon(step.type),
                          color: Colors.white,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            step.id,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (step.id == _startStepController.text)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'START',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${step.type} | "${step.title}"'),
                          if (step.edges.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              children: step.edges.map((edge) {
                                return Chip(
                                  label: Text(
                                    edge.when != null
                                        ? '${edge.when!.entries.first.key}=${edge.when!.entries.first.value} → ${edge.goto}'
                                        : '→ ${edge.goto}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.grey.shade200,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.indigo),
                            onPressed: () async {
                              final updatedStep =
                                  await Navigator.push<V2StepConfig>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => V2StepEditorScreen(
                                        step: step,
                                        allStepIds: _flow.steps.keys.toList(),
                                      ),
                                    ),
                                  );
                              if (updatedStep != null) {
                                setState(() {
                                  final updatedSteps =
                                      Map<String, V2StepConfig>.from(
                                        _flow.steps,
                                      );
                                  updatedSteps[entry.key] = updatedStep;
                                  _flow = _flow.copyWith(steps: updatedSteps);
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStep(entry.key),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAndReturn,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Save Flow', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFlowGraph() {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flow Visualization',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFlowNodes(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFlowNodes() {
    final nodes = <Widget>[];
    final visited = <String>{};

    void addNode(String stepId, int depth) {
      if (visited.contains(stepId) || !_flow.steps.containsKey(stepId)) return;
      if (depth > 10) return; // Prevent infinite loops

      visited.add(stepId);
      final step = _flow.steps[stepId]!;

      nodes.add(
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStepTypeColor(step.type),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(_getStepTypeIcon(step.type), color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      stepId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (step.edges.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.arrow_downward, size: 16),
                ),
              ...step.edges.map((edge) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: edge.goto == '_complete'
                        ? Colors.green
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    edge.goto == '_complete' ? '✓ Complete' : edge.goto,
                    style: TextStyle(
                      fontSize: 10,
                      color: edge.goto == '_complete'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );

      // Add connected steps
      for (final edge in step.edges) {
        if (edge.goto != '_complete') {
          addNode(edge.goto, depth + 1);
        }
      }
    }

    // Start from the start step
    addNode(_flow.startStep, 0);

    // Add any unvisited steps
    for (final stepId in _flow.steps.keys) {
      if (!visited.contains(stepId)) {
        addNode(stepId, 0);
      }
    }

    return nodes;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _startStepController.dispose();
    super.dispose();
  }
}
