// lib/controller/profile_logic.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileLogic {
  String userName = '';
  String email = '';
  int rating = 0;
  bool isLoading = true;
  String currentDateTime = '';
  late Timer timer;

  Future<void> fetchUserData(Function(String, String, int) onDataLoaded) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      userName = data['name'] ?? 'No Name';
      email = data['email'] ?? 'No Email';
      rating = data['rating'] ?? 0;
      isLoading = false;
      onDataLoaded(userName, email, rating);
    } else {
      print('⚠️ No user document found');
    }
  }

  void startClock(Function(String) onTimeUpdate) {
    updateTime(onTimeUpdate);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateTime(onTimeUpdate);
    });
  }

  void updateTime(Function(String) callback) {
    final now = DateTime.now();
    final formatted = DateFormat('EEEE, MMM d, yyyy – h:mm:ss a').format(now);
    callback(formatted);
  }

  void disposeTimer() {
    timer.cancel();
  }

  double calculateProgress(int completedTasks, int totalTasks) {
    return (totalTasks == 0) ? 0.0 : completedTasks / totalTasks;
  }

  double calculateWinRate(int totalWins, int totalGames) {
    return (totalGames == 0) ? 0.0 : (totalWins / totalGames) * 100;
  }

  Future<void> signOut(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
