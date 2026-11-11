import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'result_screen.dart';
import 'store.dart';
import 'theme.dart';
import 'ui.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.title,
    required this.questions,
    this.startIndex = 0,
    this.saveProgress = false,
  });
  final String title;
  final List<Question> questions;
  final int startIndex;
  final bool saveProgress; // "Barcha testlar" uchun joyni eslab qolish

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late int i = widget.startIndex.clamp(0, widget.questions.length - 1);
  final Map<int, int> answers = {};
  final DateTime _start = DateTime.now();

  List<Question> get qs => widget.questions;
  int get correct => answers.entries.where((e) => qs[e.key].answer == e.value).length;
  int get wrong => answers.length - correct;

  void _pick(int idx) {
    if (answers.containsKey(i)) return;
    final q = qs[i];
    setState(() => answers[i] = idx);
    if (idx == q.answer) {
      HapticFeedback.selectionClick();
      Store.markCorrect(q.id);
    } else {
      HapticFeedback.heavyImpact();
      Store.markWrong(q.id);
    }
  }

  void _move(int d) {
    setState(() => i += d);
    if (widget.saveProgress) Store.setAllProgress(i);
  }

  void _finish() {
    if (widget.saveProgress && i >= qs.length - 1) Store.setAllProgress(0);
    final keys = answers.keys.toList()..sort();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: QuizResult(
            exam: false,
            items: [for (final k in keys) Answered(qs[k], answers[k]!)],
            total: qs.length,
            passed: true,
            reason: 'practice',
            seconds: DateTime.now().difference(_start).inSeconds,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = qs[i];
    final isLast = i == qs.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(children: [
              IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.close_rounded)),
              Expanded(
                child: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              InfoChip(Icons.check_circle_rounded, '$correct', color: C.ok),
              const SizedBox(width: 6),
              InfoChip(Icons.cancel_rounded, '$wrong', color: C.bad),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
            child: Row(children: [
              Text('${i + 1}/${qs.length}', style: const TextStyle(fontWeight: FontWeight.w800, color: C.gold)),
              const SizedBox(width: 10),
              Text(levelName(q.level), style: const TextStyle(color: C.muted, fontSize: 13)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (i + 1) / qs.length,
                minHeight: 6,
                backgroundColor: C.line,
                color: C.gold,
              ),
            ),
          ),
          Expanded(child: QuestionView(key: ValueKey(i), q: q, picked: answers[i], onPick: _pick)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(children: [
              if (i > 0) ...[
                SizedBox(
                  width: 64,
                  child: GoldButton(label: '', icon: Icons.arrow_back_rounded, outline: true, onTap: () => _move(-1)),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: GoldButton(
                  label: isLast ? 'Yakunlash' : 'Keyingi',
                  icon: isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                  onTap: isLast ? _finish : () => _move(1),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
