import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/test_record.dart';
import '../../l10n/app_strings.dart';
import '../theme.dart';

class EntryScreen extends StatefulWidget {
  final List<TestRecord> records;
  final String language;
  final Function(TestRecord) onAdd;
  final Function(String) onDelete;
  final VoidCallback onClearAll;

  const EntryScreen({
    super.key,
    required this.records,
    required this.language,
    required this.onAdd,
    required this.onDelete,
    required this.onClearAll,
  });

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedErrors = 2;

  void _submit() {
    final record = TestRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: _selectedDate,
      errors: _selectedErrors,
    );
    widget.onAdd(record);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final total = widget.records.length;
    final passed = widget.records.where((r) => r.isPassed).length;
    final passRate = total == 0 ? 0.0 : (passed / total) * 100.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Stats Banner
          if (total > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('$total', AppStrings.t('tab_entries', lang)),
                    Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.1)),
                    _statItem('$passed', AppStrings.t('passed_badge', lang), color: AppTheme.passGreen),
                    Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.1)),
                    _statItem('${passRate.toStringAsFixed(0)}%', AppStrings.t('historical_pass', lang)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Add Quiz Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.t('new_quiz', lang),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppStrings.t('errors_made', lang)}: $_selectedErrors',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _selectedErrors <= 3 ? AppTheme.passGreen : AppTheme.failRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Mistakes Selector Chips (0 to 7)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(8, (i) {
                        final isSelected = _selectedErrors == i;
                        final isPass = i <= 3;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              '$i',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : (isPass ? AppTheme.passGreen : AppTheme.failRed),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: isPass ? AppTheme.passGreen : AppTheme.failRed,
                            backgroundColor: AppTheme.darkSurface,
                            onSelected: (val) {
                              if (val) setState(() => _selectedErrors = i);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Slider for higher mistake counts
                  Slider(
                    value: _selectedErrors.toDouble(),
                    min: 0,
                    max: 15,
                    divisions: 15,
                    activeColor: _selectedErrors <= 3 ? AppTheme.passGreen : AppTheme.failRed,
                    onChanged: (val) => setState(() => _selectedErrors = val.toInt()),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add_task),
                      label: Text(
                        AppStrings.t('add_button', lang),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // History Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.t('history', lang)} ($total)',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              if (total > 0)
                TextButton.icon(
                  onPressed: () => _confirmClearAll(context),
                  icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.white54),
                  label: Text(
                    AppStrings.t('clear_all', lang),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Quiz History List
          if (widget.records.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    Icon(Icons.quiz_outlined, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.t('no_records_title', lang),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.t('no_records_desc', lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.records.length,
              itemBuilder: (context, index) {
                // Show latest first
                final record = widget.records[widget.records.length - 1 - index];
                final isPass = record.isPassed;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: isPass ? AppTheme.passGreen.withValues(alpha: 0.2) : AppTheme.failRed.withValues(alpha: 0.2),
                      child: Icon(
                        isPass ? Icons.check_circle : Icons.cancel,
                        color: isPass ? AppTheme.passGreen : AppTheme.failRed,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      DateFormat('dd/MM/yyyy').format(record.date),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      '${record.errors} ${record.errors == 1 ? AppStrings.t('error_label', lang) : AppStrings.t('errors_label', lang)}',
                      style: TextStyle(
                        color: isPass ? AppTheme.passGreen : AppTheme.failRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPass ? AppTheme.passGreen.withValues(alpha: 0.15) : AppTheme.failRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isPass ? AppStrings.t('passed_badge', lang) : AppStrings.t('failed_badge', lang),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPass ? AppTheme.passGreen : AppTheme.failRed,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white38),
                          onPressed: () => widget.onDelete(record.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  void _confirmClearAll(BuildContext context) {
    final lang = widget.language;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t('clear_all', lang)),
        content: Text(AppStrings.t('clear_all_confirm', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.t('cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.failRed),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onClearAll();
            },
            child: Text(AppStrings.t('delete', lang), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
