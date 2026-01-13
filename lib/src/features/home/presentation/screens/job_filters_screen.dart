import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Job filters screen (placeholder for future implementation)
class JobFiltersScreen extends StatefulWidget {
  const JobFiltersScreen({super.key});

  @override
  State<JobFiltersScreen> createState() => _JobFiltersScreenState();
}

class _JobFiltersScreenState extends State<JobFiltersScreen> {
  String? _selectedJobType;
  String? _selectedExperienceLevel;
  RangeValues _salaryRange = const RangeValues(0, 100000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedJobType = null;
                _selectedExperienceLevel = null;
                _salaryRange = const RangeValues(0, 100000);
              });
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Type
            const Text(
              'Job Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('Full Time', _selectedJobType == 'full-time', () {
                  setState(() => _selectedJobType = 'full-time');
                }),
                _buildFilterChip('Part Time', _selectedJobType == 'part-time', () {
                  setState(() => _selectedJobType = 'part-time');
                }),
                _buildFilterChip('Contract', _selectedJobType == 'contract', () {
                  setState(() => _selectedJobType = 'contract');
                }),
                _buildFilterChip('Internship', _selectedJobType == 'internship', () {
                  setState(() => _selectedJobType = 'internship');
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Experience Level
            const Text(
              'Experience Level',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('Entry', _selectedExperienceLevel == 'entry', () {
                  setState(() => _selectedExperienceLevel = 'entry');
                }),
                _buildFilterChip('Mid', _selectedExperienceLevel == 'mid', () {
                  setState(() => _selectedExperienceLevel = 'mid');
                }),
                _buildFilterChip('Senior', _selectedExperienceLevel == 'senior', () {
                  setState(() => _selectedExperienceLevel = 'senior');
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Salary Range
            const Text(
              'Salary Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: _salaryRange,
              min: 0,
              max: 100000,
              divisions: 20,
              activeColor: AppColors.primaryBlue,
              labels: RangeLabels(
                '₹${_salaryRange.start.round()}',
                '₹${_salaryRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() => _salaryRange = values);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${_salaryRange.start.round()}',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  '₹${_salaryRange.end.round()}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Apply filters and navigate back
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryBlue,
      backgroundColor: Colors.grey.shade200,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
