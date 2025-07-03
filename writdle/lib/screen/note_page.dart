// lib/screen/notes_page.dart

import 'package:flutter/material.dart';
import 'package:writdle/widget/note_list.dart';

class NotesPage extends StatefulWidget {
  final DateTime? selectedDay;
  const NotesPage({super.key, this.selectedDay});

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

  String get _formattedSelectedDate =>
      '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _goToPreviousDay,
            ),
            Text('Notes for $_formattedSelectedDate'),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _goToNextDay,
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
            ),
          ),
        ),
      ),
      body: NoteList(date: _formattedSelectedDate, searchQuery: _searchQuery),
    );
  }
}
