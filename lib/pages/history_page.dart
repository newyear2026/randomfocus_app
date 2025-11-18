import 'package:flutter/material.dart';
import '../widgets/slide_in_widget.dart';
import '../services/history_service.dart';
import '../models/timer_history.dart';
import '../widgets/scroll_animated_list.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  Map<String, List<TimerHistory>> _groupedHistories = {};
  bool _isLoading = true;
  final Set<String> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistories() async {
    setState(() {
      _isLoading = true;
    });

    final grouped = await HistoryService.getHistoriesByDate();

    if (mounted) {
      setState(() {
        _groupedHistories = grouped;
        _isLoading = false;
      });
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelection(String sessionId) {
    setState(() {
      if (_selectedIds.contains(sessionId)) {
        _selectedIds.remove(sessionId);
      } else {
        _selectedIds.add(sessionId);
      }
      if (_selectedIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: Text(
          'Are you sure you want to delete ${_selectedIds.length} item(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await HistoryService.deleteHistories(_selectedIds.toList());
      _selectedIds.clear();
      _isSelectionMode = false;
      _loadHistories();
    }
  }

  Future<void> _deleteHistory(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await HistoryService.deleteHistory(sessionId);
      _loadHistories();
    }
  }

  Color _getColorForMinutes(int minutes) {
    if (minutes <= 25) return Colors.pink.shade400;
    if (minutes <= 35) return Colors.amber.shade600;
    if (minutes <= 45) return Colors.green.shade500;
    if (minutes <= 50) return Colors.cyan.shade500;
    if (minutes <= 60) return Colors.blue.shade700;
    return Colors.purple.shade600;
  }

  String _formatDateHeader(String dateKey) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        if (date == today) {
          return 'Today';
        } else if (date == today.subtract(const Duration(days: 1))) {
          return 'Yesterday';
        } else {
          return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      }
    } catch (e) {
      // 파싱 실패 시 원본 반환
    }
    return dateKey;
  }

  List<String> _getSortedDateKeys() {
    final keys = _groupedHistories.keys.toList();
    keys.sort((a, b) => b.compareTo(a)); // 최신순 정렬
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _groupedHistories.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (totalCount > 0)
            IconButton(
              icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: _isSelectionMode ? 'Cancel selection' : 'Select items',
            ),
          if (_isSelectionMode && _selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelected,
              tooltip: 'Delete selected',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideInWidget(
                    index: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No History Yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete a focus session to see it here',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistories,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _getSortedDateKeys().length,
                itemBuilder: (context, dateIndex) {
                  final dateKey = _getSortedDateKeys()[dateIndex];
                  final histories = _groupedHistories[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 헤더
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          _formatDateHeader(dateKey),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                      ),
                      // 해당 날짜의 히스토리 목록
                      ...histories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final history = entry.value;
                        final isSelected = _selectedIds.contains(
                          history.sessionId,
                        );
                        final color = _getColorForMinutes(history.selectedTime);

                        return ScrollAnimatedListItem(
                          index: dateIndex * 100 + index,
                          scrollController: _scrollController,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: _isSelectionMode && isSelected
                                  ? Border.all(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: _isSelectionMode
                                  ? SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: Checkbox(
                                        value: isSelected,
                                        onChanged: (value) =>
                                            _toggleSelection(history.sessionId),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color.withOpacity(0.4),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${history.selectedTime}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                              title: Row(
                                children: [
                                  Text(
                                    '${history.selectedTime} minutes',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          history.status ==
                                              SessionStatus.completed
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      history.status == SessionStatus.completed
                                          ? 'Completed'
                                          : 'Stopped',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            history.status ==
                                                SessionStatus.completed
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Actual: ${history.formattedActualTime}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${history.dateTime.hour.toString().padLeft(2, '0')}:${history.dateTime.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: _isSelectionMode
                                  ? null
                                  : SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red.shade400,
                                        onPressed: () =>
                                            _deleteHistory(history.sessionId),
                                        tooltip: 'Delete',
                                        iconSize: 24,
                                      ),
                                    ),
                              onTap: _isSelectionMode
                                  ? () => _toggleSelection(history.sessionId)
                                  : null,
                              minVerticalPadding: 12,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
