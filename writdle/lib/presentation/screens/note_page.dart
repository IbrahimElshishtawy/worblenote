import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:writdle/presentation/widgets/note_list.dart';
import 'package:writdle/presentation/widgets/notes/notes_header.dart';
import 'package:writdle/presentation/widgets/notes/notes_search_bar.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key, this.selectedDay});

  final DateTime? selectedDay;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _searchController = TextEditingController();
  late DateTime _selectedDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDay ?? DateTime.now();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _dateKey =>
      '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  String get _displayDate => DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);
  String get _deviceTime => DateFormat('hh:mm a').format(DateTime.now());

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.06),
              scheme.surface,
              scheme.secondary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: NotesHeader(
                  formattedDate: _displayDate,
                  localTime: _deviceTime,
                  onPrevious: _goToPreviousDay,
                  onNext: _goToNextDay,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: NotesSearchBar(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.trim()),
                ),
              ),
              Expanded(
                child: NoteList(
                  date: _dateKey,
                  searchQuery: _searchQuery,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
