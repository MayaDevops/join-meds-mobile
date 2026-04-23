import 'package:flutter/material.dart';
import '../../core/config/feature_flags.dart';
import '../../core/config/remote_feature_flags.dart';

/// Debug screen for viewing and testing feature flags
/// Only use during development/testing
class FeatureFlagsDebugScreen extends StatefulWidget {
  const FeatureFlagsDebugScreen({super.key});

  @override
  State<FeatureFlagsDebugScreen> createState() =>
      _FeatureFlagsDebugScreenState();
}

class _FeatureFlagsDebugScreenState extends State<FeatureFlagsDebugScreen> {
  final RemoteFeatureFlags _remoteFlags = RemoteFeatureFlags();
  Map<String, dynamic>? _flagStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFlagStatus();
  }

  Future<void> _loadFlagStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = _remoteFlags.getStatus();
      setState(() {
        _flagStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading flags: $e');
    }
  }

  Future<void> _refreshFlags() async {
    setState(() => _isLoading = true);
    try {
      await _remoteFlags.refresh();
      await _loadFlagStatus();
      _showSuccess('Flags refreshed from Firebase');
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error refreshing flags: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feature Flags Debug',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff00A4E1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshFlags,
            tooltip: 'Refresh from Firebase',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00A4E1)),
              ),
            )
          : _flagStatus == null
              ? const Center(child: Text('No flag data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warning banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Debug screen - for development only',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // System flags
                      _buildSection(
                        'System Settings',
                        [
                          _buildInfoRow(
                            'Master Switch',
                            _flagStatus!['masterSwitch'].toString(),
                            _flagStatus!['masterSwitch'] as bool,
                          ),
                          _buildInfoRow(
                            'Force Enabled (Local)',
                            _flagStatus!['forceEnabled'].toString(),
                            _flagStatus!['forceEnabled'] as bool,
                          ),
                          _buildInfoRow(
                            'Rollout %',
                            '${_flagStatus!['rolloutPercentage']}%',
                            _flagStatus!['rolloutPercentage'] > 0,
                          ),
                          _buildInfoRow(
                            'Last Fetch',
                            _flagStatus!['lastFetch'] ?? 'Never',
                            _flagStatus!['lastFetch'] != 'never',
                          ),
                          _buildInfoRow(
                            'Cache Status',
                            _flagStatus!['cacheStale'] ? 'Stale' : 'Fresh',
                            !_flagStatus!['cacheStale'],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Profession flags
                      _buildSection(
                        'Profession Flags',
                        _buildProfessionFlags(),
                      ),

                      const SizedBox(height: 24),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff00A4E1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xff00A4E1),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'How to Update Flags',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildHelpText(
                              '1. Local flags: Edit lib/src/core/config/feature_flags.dart',
                            ),
                            _buildHelpText(
                              '2. Remote flags: Update Firebase Realtime Database at path: feature_flags/',
                            ),
                            _buildHelpText(
                              '3. Force enable: Set forceEnableDynamicForms = true in feature_flags.dart',
                            ),
                            _buildHelpText(
                              '4. Tap refresh icon to reload from Firebase',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isEnabled ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isEnabled ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: isEnabled ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProfessionFlags() {
    final professionFlags =
        _flagStatus!['professionFlags'] as Map<String, dynamic>;

    return professionFlags.entries.map((entry) {
      final professionId = entry.key;
      final isEnabled = entry.value as bool;

      return _buildInfoRow(
        _formatProfessionName(professionId),
        isEnabled ? 'Enabled' : 'Disabled',
        isEnabled,
      );
    }).toList();
  }

  String _formatProfessionName(String professionId) {
    return professionId
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildHelpText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
