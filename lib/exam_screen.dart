import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'result_screen.dart';
import 'store.dart';
import 'theme.dart';
import 'ui.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  static const total = 20;
  static const maxMistakes = 2; // 3-xatoda imtihon tugaydi
  static const minutes = 20;

  late final List<Question> qs;
  final List<Answered> log = [];
  late final DateTime start;
  late final DateTime deadline;
  Timer? _timer;
  Duration left = const Duration(minutes: minutes);
  bool _finished = false;

  int i = 0, wrong = 0, correct = 0;
  int? picked;

  @override
  void initState() {
    super.initState();
    qs = Bank.i.buildExam();
    start = DateTime.now();
    deadline = start.add(const Duration(minutes: minutes));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final l = deadline.difference(DateTime.now());
      if (l <= Duration.zero) {
        _finish('time');
      } else if (mounted) {
        setState(() => left = l);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pick(int idx) {
    if (picked != null || _finished) return;
    final q = qs[i];
    final ok = idx == q.answer;
    setState(() {
      picked = idx;
      if (ok) {
        correct++;
      } else {
        wrong++;
      }
    });
    log.add(Answered(q, idx));
    if (ok) {
      HapticFeedback.selectionClick();
      Store.markCorrect(q.id);
    } else {
      HapticFeedback.heavyImpact();
      Store.markWrong(q.id);
    }
  }

  void _next() {
    if (wrong > maxMistakes) {
      _finish('mistakes');
    } else if (i == total - 1) {
      _finish('ok');
    } else {
      setState(() {
        i++;
        picked = null;
      });
    }
  }

  void _finish(String reason) {
    if (_finished || !mounted) return;
    _finished = true;
    _timer?.cancel();
    final elapsed = DateTime.now().difference(start).inSeconds.clamp(0, minutes * 60);
    final passed = reason == 'ok' && wrong <= maxMistakes;
    Store.addRecord(ExamRecord(
      date: DateTime.now().millisecondsSinceEpoch,
      correct: correct,
      wrong: wrong,
      total: total,
      seconds: elapsed,
      passed: passed,
      reason: reason,
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: QuizResult(
            exam: true,
            items: log,
            total: total,
            passed: passed,
            reason: reason,
            seconds: elapsed,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Imtihondan chiqasizmi?'),
        content: const Text("Chiqsangiz, bu urinish hisobga olinmaydi."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Davom etish')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Chiqish', style: TextStyle(color: C.bad)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _finished = true;
      _timer?.cancel();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = qs[i];
    final lives = 3 - wrong;
    final lowTime = left.inSeconds < 120;
    final isLast = i == total - 1;
    final failed = wrong > maxMistakes;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(children: [
                IconButton(onPressed: _confirmExit, icon: const Icon(Icons.close_rounded)),
                Text('${i + 1}/$total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                for (var h = 0; h < 3; h++)
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(Icons.favorite_rounded, size: 22, color: h < lives ? C.bad : C.line),
                  ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: lowTime ? C.badBg : C.goldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.timer_rounded, size: 17, color: lowTime ? C.bad : C.gold),
                    const SizedBox(width: 5),
                    Text(
                      fmtTime(left.inSeconds),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: lowTime ? C.bad : C.gold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (i + (picked != null ? 1 : 0)) / total,
                  minHeight: 6,
                  backgroundColor: C.line,
                  color: C.gold,
                ),
              ),
            ),
            Expanded(child: QuestionView(key: ValueKey(i), q: q, picked: picked, onPick: _pick)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: picked == null
                  ? const SizedBox(
                      height: 54,
                      child: Center(child: Text('Javobni tanlang', style: TextStyle(color: C.muted))),
                    )
                  : GoldButton(
                      label: failed ? "Natijani ko'rish" : (isLast ? 'Yakunlash' : 'Keyingi savol'),
                      icon: failed || isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                      onTap: _next,
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}
