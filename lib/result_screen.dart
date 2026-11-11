import 'dart:math';
import 'package:flutter/material.dart';
import 'data.dart';
import 'exam_screen.dart';
import 'theme.dart';
import 'ui.dart';

const _passQuotes = [
  "Yo'l jasur va sabrli haydovchilarniki. Sen ikkalasini ham isbotlading!",
  "Bilim senga ishonch berdi, ishonch esa yo'lda xavfsizlik. Oq yo'l!",
  "Bugun imtihondan o'tding — ertaga yo'lning ustasi bo'lasan!",
];

const _mistakeQuotes = [
  "Yiqilish — tugash emas, yangi boshlanish. Har bir xato seni haqiqiy haydovchiga bir qadam yaqinlashtiradi. Yana urinib ko'r!",
  "Eng zo'r haydovchilar ham bir paytlar xato qilgan. To'xtama — g'alaba juda yaqin!",
  "Xato qilish — o'rganayotganingning belgisi. Tur, nafas ol va qaytadan boshla!",
  "Katta natija kichik urinishlardan tug'iladi. Bugun o'rgandingiz, ertaga o'tasiz!",
];

const _timeQuotes = [
  "Tezlik mashq bilan keladi. Yana bir bor urinib ko'r — bu safar ulguramiz!",
  "Vaqt tugadi, lekin shijoating tugamasin. Mashq qilib, kuchliroq qaytib kel!",
];

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});
  final QuizResult result;

  String _quote(int pct) {
    final r = Random();
    if (result.exam) {
      if (result.passed) return _passQuotes[r.nextInt(_passQuotes.length)];
      if (result.reason == 'time') return _timeQuotes[r.nextInt(_timeQuotes.length)];
      return _mistakeQuotes[r.nextInt(_mistakeQuotes.length)];
    }
    if (pct >= 90) return "A'lo natija! Imtihonga tayyorsan — endi sinab ko'r!";
    if (pct >= 60) return "Yaxshi natija! Xatolaringni qayta ishlab, yanada yuksal.";
    return "Boshlash — yarim g'alaba. Mashqni davom ettir, natija albatta keladi!";
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    final wrongs = r.items.where((a) => !a.isCorrect).toList();
    final correct = r.items.length - wrongs.length;
    final pct = r.items.isEmpty ? 0 : (correct * 100 / r.items.length).round();

    final bool good = r.exam ? r.passed : pct >= 60;
    final Color accent = good ? C.ok : (r.exam ? C.bad : C.orange);
    final IconData icon = r.exam
        ? (r.passed ? Icons.emoji_events_rounded : (r.reason == 'time' ? Icons.timer_off_rounded : Icons.sentiment_dissatisfied_rounded))
        : Icons.flag_rounded;
    final String title = r.exam
        ? (r.passed ? 'Tabriklaymiz!' : (r.reason == 'time' ? 'Vaqt tugadi' : "Bu safar bo'lmadi"))
        : 'Mashq yakunlandi';
    final String sub = r.exam
        ? (r.passed
            ? "Siz imtihondan muvaffaqiyatli o'tdingiz"
            : (r.reason == 'time' ? "20 daqiqa ichida ulgurmadingiz" : "3 ta xato qildingiz — imtihon to'xtatildi"))
        : "$correct/${r.items.length} to'g'ri javob ($pct%)";

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.15),
                    border: Border.all(color: accent, width: 2.5),
                  ),
                  child: Icon(icon, size: 48, color: accent),
                ),
              ),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: C.muted, fontSize: 15)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _Stat("To'g'ri", '$correct', C.ok)),
                const SizedBox(width: 10),
                Expanded(child: _Stat('Xato', '${wrongs.length}', C.bad)),
                const SizedBox(width: 10),
                Expanded(child: _Stat('Vaqt', fmtTime(r.seconds), C.gold)),
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.goldBg,
                  borderRadius: BorderRadius.circular(18),
                  border: const Border(left: BorderSide(color: C.gold, width: 4)),
                ),
                child: Text(_quote(pct),
                    style: const TextStyle(fontSize: 15.5, height: 1.45, fontStyle: FontStyle.italic)),
              ),
              if (wrongs.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text("Xatolar tahlili", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                for (final a in wrongs) _Review(a),
              ],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(children: [
              if (r.exam) ...[
                GoldButton(
                  label: 'Qayta topshirish',
                  icon: Icons.refresh_rounded,
                  onTap: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const ExamScreen())),
                ),
                const SizedBox(height: 10),
              ],
              GoldButton(
                label: 'Bosh sahifa',
                icon: Icons.home_rounded,
                outline: r.exam,
                onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: C.muted, fontSize: 12.5)),
        ]),
      );
}

class _Review extends StatelessWidget {
  const _Review(this.a);
  final Answered a;

  @override
  Widget build(BuildContext context) {
    final q = a.q;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (q.imageKey != null) ...[SignImage(q.imageKey!, height: 110), const SizedBox(height: 10)],
          Text(q.text, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35)),
          const SizedBox(height: 10),
          _line(Icons.close_rounded, C.bad, q.options[a.picked]),
          const SizedBox(height: 6),
          _line(Icons.check_rounded, C.ok, q.options[q.answer]),
        ]),
      ),
    );
  }

  Widget _line(IconData i, Color c, String t) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, size: 18, color: c),
        const SizedBox(width: 8),
        Expanded(child: Text(t, style: TextStyle(color: c, height: 1.3))),
      ]);
}
