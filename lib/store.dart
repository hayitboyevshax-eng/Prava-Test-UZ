import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExamRecord {
  final int date;
  final int correct;
  final int wrong;
  final int total;
  final int seconds;
  final bool passed;
  final String reason;
  const ExamRecord({
    required this.date,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.seconds,
    required this.passed,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'd': date,
        'c': correct,
        'w': wrong,
        't': total,
        's': seconds,
        'p': passed,
        'r': reason,
      };

  factory ExamRecord.fromJson(Map<String, dynamic> j) => ExamRecord(
        date: j['d'] as int,
        correct: j['c'] as int,
        wrong: j['w'] as int,
        total: j['t'] as int,
        seconds: j['s'] as int,
        passed: j['p'] as bool,
        reason: j['r'] as String,
      );
}

class Store {
  static late SharedPreferences _p;
  static Future<void> init() async => _p = await SharedPreferences.getInstance();

  // Imtihonlar tarixi (yangisi birinchi)
  static List<ExamRecord> get history => (_p.getStringList('history') ?? [])
      .map((s) => ExamRecord.fromJson(jsonDecode(s) as Map<String, dynamic>))
      .toList();

  static Future<void> addRecord(ExamRecord r) async {
    final raw = _p.getStringList('history') ?? [];
    raw.insert(0, jsonEncode(r.toJson()));
    await _p.setStringList('history', raw.take(60).toList());
  }

  // Xato qilingan savollar
  static Set<String> get wrongIds => (_p.getStringList('wrong') ?? []).toSet();

  static Future<void> markWrong(String id) async {
    final s = wrongIds..add(id);
    await _p.setStringList('wrong', s.toList());
  }

  static Future<void> markCorrect(String id) async {
    final s = wrongIds;
    if (s.remove(id)) await _p.setStringList('wrong', s.toList());
  }

  // "Barcha testlar" rejimi progressi
  static int get allProgress => _p.getInt('all_progress') ?? 0;
  static Future<void> setAllProgress(int v) => _p.setInt('all_progress', v);
}
