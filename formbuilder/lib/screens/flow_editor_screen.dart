import 'package:flutter/material.dart';
import '../models/form_config.dart';
import '../models/step_config.dart';
import 'step_editor_screen.dart';

class FlowEditorScreen extends StatefulWidget {
  final String professionId;
  final String flowId;
  final FlowConfig initialFlow;
  final Function(FlowConfig) onFlowUpdated;

  const FlowEditorScreen({
    super.key,
    required this.professionId,
    required this.flowId,
    required this.initialFlow,
    required this.onFlowUpdated,
  });

  @override
  State<FlowEditorScreen> createState() => _FlowEditorScreenState();
}

class _FlowEditorScreenState extends State<FlowEditorScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  late FlowConfig _currentFlow;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentFlow = widget.initialFlow;
    _displayNameController.text = _currentFlow.displayName;
  }

  void _saveChanges() {
    final updatedFlow = FlowConfig(
      flowId: _currentFlow.flowId,
      displayName: _displayNameController.text.trim(),
      steps: _currentFlow.steps,
      initialStepId: _currentFlow.initialStepId,
    );

    widget.onFlowUpdated(updatedFlow);
    setState(() {
      _currentFlow = updatedFlow;
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flow updated')),
    );
  }

  void _addStep() async {
    final stepIdController = TextEditingController();
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Step'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stepIdController,
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
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle (optional)',
                  hintText: 'e.g., Please select your status',
                ),
              ),
            ],
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

    if (result == true) {
      final stepId = stepIdController.text.trim();
      final title = titleController.text.trim();
      final subtitle = subtitleController.text.trim();

      if (stepId.isEmpty || title.isEmpty) return;

      final newStep = StepConfig(
        stepId: stepId,
        stepType: 'form',
        title: title,
        subtitle: subtitle.isEmpty ? null : subtitle,
        fields: [],
        showProgress: true,
        validateBeforeNavigate: true,
      );

      setState(() {
        _currentFlow = FlowConfig(
          flowId: _currentFlow.flowId,
          displayName: _currentFlow.displayName,
          steps: [..._currentFlow.steps, newStep],
          initialStepId: _currentFlow.initialStepId,
        );
        _hasChanges = true;
      });
    }
  }

  void _deleteStep(int index) async {
    final step = _currentFlow.steps[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Step'),
        content: Text('Are you sure you want to delete "${step.title}"?'),
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
      final steps = List<StepConfig>.from(_currentFlow.steps);
      steps.removeAt(index);

      setState(() {
        _currentFlow = FlowConfig(
          flowId: _currentFlow.flowId,
          displayName: _currentFlow.displayName,
          steps: steps,
          initialStepId: _currentFlow.initialStepId,
        );
        _hasChanges = true;
      });
    }
  }

  void _moveStepUp(int index) {
    if (index == 0) return;

    final steps = List<StepConfig>.from(_currentFlow.steps);
    final temp = steps[index];
    steps[index] = steps[index - 1];
    steps[index - 1] = temp;

    setState(() {
      _currentFlow = FlowConfig(
        flowId: _currentFlow.flowId,
        displayName: _currentFlow.displayName,
        steps: steps,
        initialStepId: _currentFlow.initialStepId,
      );
      _hasChanges = true;
    });
  }

  void _moveStepDown(int index) {
    if (index >= _currentFlow.steps.length - 1) return;

    final steps = List<StepConfig>.from(_currentFlow.steps);
    final temp = steps[index];
    steps[index] = steps[index + 1];
    steps[index + 1] = temp;

    setState(() {
      _currentFlow = FlowConfig(
        flowId: _currentFlow.flowId,
        displayName: _currentFlow.displayName,
        steps: steps,
        initialStepId: _currentFlow.initialStepId,
      );
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flow: ${_currentFlow.displayName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: SingleChildScrollView(
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
                      'Flow Properties',
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
                    const SizedBox(height: 12),
                    Text(
                      'Flow ID: ${_currentFlow.flowId}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Steps',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentFlow.steps.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No steps yet. Add a step to get started.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentFlow.steps.length,
                itemBuilder: (context, index) {
                  final step = _currentFlow.steps[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        step.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'ID: ${step.stepId} | Type: ${step.stepType} | Fields: ${step.fields.length}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: index == 0 ? null : () => _moveStepUp(index),
                            tooltip: 'Move Up',
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward),
                            onPressed: index >= _currentFlow.steps.length - 1
                                ? null
                                : () => _moveStepDown(index),
                            tooltip: 'Move Down',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StepEditorScreen(
                                    professionId: widget.professionId,
                                    flowId: widget.flowId,
                                    stepId: step.stepId,
                                    initialStep: step,
                                    onStepUpdated: (updatedStep) {
                                      final steps =
                                          List<StepConfig>.from(_currentFlow.steps);
                                      steps[index] = updatedStep;

                                      setState(() {
                                        _currentFlow = FlowConfig(
                                          flowId: _currentFlow.flowId,
                                          displayName: _currentFlow.displayName,
                                          steps: steps,
                                          initialStepId: _currentFlow.initialStepId,
                                        );
                                        _hasChanges = true;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            tooltip: 'Edit Step',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStep(index),
                            tooltip: 'Delete Step',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }
}
