import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/field_config.dart';

/// Date picker field widget
/// Based on work experience date picker patterns
class DateField extends StatefulWidget {
  final FieldConfig config;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? minDate;
  final DateTime? maxDate;

  const DateField({
    super.key,
    required this.config,
    this.value,
    required this.onChanged,
    this.minDate,
    this.maxDate,
  });

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late TextEditingController _controller;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value != null ? _dateFormat.format(widget.value!) : '',
    );
  }

  @override
  void didUpdateWidget(DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value != null ? _dateFormat.format(widget.value!) : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime _getMinDate() {
    // Check config constraints
    if (widget.config.validation?.minDate != null) {
      final minDateStr = widget.config.validation!.minDate!;
      if (minDateStr.toLowerCase() == 'today') {
        return DateTime.now();
      }
      try {
        return DateTime.parse(minDateStr);
      } catch (e) {
        print('Invalid minDate format: $minDateStr');
      }
    }
    // Default to 1965
    return widget.minDate ?? DateTime(1965);
  }

  DateTime _getMaxDate() {
    // Check config constraints
    if (widget.config.validation?.maxDate != null) {
      final maxDateStr = widget.config.validation!.maxDate!;
      if (maxDateStr.toLowerCase() == 'today') {
        return DateTime.now();
      }
      try {
        return DateTime.parse(maxDateStr);
      } catch (e) {
        print('Invalid maxDate format: $maxDateStr');
      }
    }
    // Default to today
    return widget.maxDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = widget.value ?? DateTime.now();
    final minDate = _getMinDate();
    final maxDate = _getMaxDate();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(minDate)
          ? minDate
          : initialDate.isAfter(maxDate)
          ? maxDate
          : initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff00A4E1), // mainBlue
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _controller.text = _dateFormat.format(picked);
      });
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.config.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.config.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),

        // Date field
        TextFormField(
          controller: _controller,
          readOnly: true,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: widget.config.hint ?? 'Date of birth',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                onPressed: () => _selectDate(context),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xff00A4E1),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
          ),
          validator: (val) {
            if (widget.config.required && (val == null || val.isEmpty)) {
              return widget.config.validation?.requiredMessage ??
                  'Date is required';
            }
            return null;
          },
          onTap: () => _selectDate(context),
        ),
      ],
    );
  }
}