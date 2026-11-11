import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

enum Level { easy, medium, hard }

String levelName(Level l) => switch (l) {
      Level.easy => 'Oson',
      Level.medium => "O'rta",
      Level.hard => 'Qiyin',
    };

class Question {
  final String id;
  final Level level;
  final String text;
  final List<String> options;
  final int answer;
  final String? imageKey;

  const Question({
    required this.id,
    required this.level,
    required this.text,
    required this.options,
    required this.answer,
    this.imageKey,
  });

  static final _fixedOrder = RegExp(
      r"(barcha|hammasi|yuqoridagi|ikkalasi|ikkala|a va b|hech biri)",
      caseSensitive: false);

  /// Variantlarni aralashtiradi ("barchasi" kabi tartibga bogʻliq variantlar boʻlsa — tegmaydi)
  Question shuffled(Random r) {
    if (options.any((o) => _fixedOrder.hasMatch(o))) return this;
    final idx = List<int>.generate(options.length, (i) => i)..shuffle(r);
    return Question(
      id: id,
      level: level,
      text: text,
      options: idx.map((i) => options[i]).toList(),
      answer: idx.indexOf(answer),
      imageKey: imageKey,
    );
  }
}

class Answered {
  final Question q;
  final int picked;
  const Answered(this.q, this.picked);
  bool get isCorrect => picked == q.answer;
}

class QuizResult {
  final bool exam;
  final List<Answered> items;
  final int total;
  final bool passed;
  final String reason; // ok | mistakes | time | practice
  final int seconds;
  const QuizResult({
    required this.exam,
    required this.items,
    required this.total,
    required this.passed,
    required this.reason,
    required this.seconds,
  });
}

class Bank {
  static late Bank i;

  final Map<Level, List<Question>> byLevel;
  final Map<String, String> svgs;
  final Map<String, Question> byId;
  final List<Question> all;

  Bank(this.byLevel, this.svgs, this.byId, this.all);

  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/prava.json');
    final m = jsonDecode(raw) as Map<String, dynamic>;
    const keys = {'e': Level.easy, 'm': Level.medium, 'h': Level.hard};
    final byLevel = <Level, List<Question>>{};
    final byId = <String, Question>{};
    final all = <Question>[];
    keys.forEach((k, level) {
      final list = m[k] as List;
      final qs = <Question>[];
      for (var n = 0; n < list.length; n++) {
        final row = list[n] as List;
        final img = row[3];
        final q = Question(
          id: '$k:$n',
          level: level,
          text: row[0] as String,
          options: (row[1] as List).cast<String>(),
          answer: row[2] as int,
          imageKey: (img is String && img.isNotEmpty) ? img : null,
        );
        qs.add(q);
        byId[q.id] = q;
        all.add(q);
      }
      byLevel[level] = qs;
    });
    final svgs = (m['img'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String));
    i = Bank(byLevel, svgs, byId, all);
  }

  /// Imtihon: 6 oson + 8 oʻrta + 6 qiyin = 20 savol
  List<Question> buildExam() {
    final r = Random();
    List<Question> pick(Level l, int n) {
      final pool = [...byLevel[l]!]..shuffle(r);
      return pool.take(n).map((q) => q.shuffled(r)).toList();
    }

    return [...pick(Level.easy, 6), ...pick(Level.medium, 8), ...pick(Level.hard, 6)]..shuffle(r);
  }
}
