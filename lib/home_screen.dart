import 'package:flutter/material.dart';
import 'data.dart';
import 'exam_screen.dart';
import 'practice_screen.dart';
import 'practice_setup_screen.dart';
import 'store.dart';
import 'theme.dart';
import 'ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _go(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    if (mounted) setState(() {});
  }

  Future<void> _startAll() async {
    final all = Bank.i.all;
    final p = Store.allProgress;
    var start = 0;
    if (p > 0 && p < all.length) {
      final cont = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Davom ettirasizmi?'),
          content: Text('Oxirgi to\'xtagan joyingiz: ${p + 1}-savol.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Boshidan')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Davom etish')),
          ],
        ),
      );
      if (cont == null) return;
      start = cont ? p : 0;
      if (!cont) await Store.setAllProgress(0);
    }
    if (!mounted) return;
    _go(PracticeScreen(title: 'Barcha testlar', questions: all, startIndex: start, saveProgress: true));
  }

  void _startMistakes() {
    final qs = Store.wrongIds.map((id) => Bank.i.byId[id]).whereType<Question>().toList();
    if (qs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hozircha xato qilingan savol yo'q — ajoyib! 👏")),
      );
      return;
    }
    qs.shuffle();
    _go(PracticeScreen(title: 'Xatolar ustida ishlash', questions: qs));
  }

  String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.day)}.${p(d.month)} ${p(d.hour)}:${p(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final history = Store.history;
    final passed = history.where((h) => h.passed).length;
    final best = history.isEmpty ? 0 : history.map((h) => h.correct).reduce((a, b) => a > b ? a : b);
    final wrongCount = Store.wrongIds.length;
    final prog = Store.allProgress;

    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [
          Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.directions_car_filled_rounded, color: Colors.black, size: 30),
            ),
            const SizedBox(width: 14),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Prava Test UZ', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              Text('YHQ imtihoniga tayyorlaning', style: TextStyle(color: C.muted)),
            ]),
          ]),
          const SizedBox(height: 22),
          Panel(
            borderColor: C.gold,
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Imtihon rejimi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text("Haqiqiy imtihondek: vaqt cheklangan, xatoga yo'l qo'yilmaydi.",
                  style: TextStyle(color: C.muted, height: 1.35)),
              const SizedBox(height: 12),
              SizedBox(height: 14, width: double.infinity, child: CustomPaint(painter: RoadPainter())),
              const SizedBox(height: 12),
              const Wrap(spacing: 8, runSpacing: 8, children: [
                InfoChip(Icons.quiz_rounded, '20 savol'),
                InfoChip(Icons.timer_rounded, '20 daqiqa'),
                InfoChip(Icons.favorite_rounded, '2 xatoga ruxsat', color: C.bad),
              ]),
              const SizedBox(height: 16),
              GoldButton(
                label: 'Imtihonni boshlash',
                icon: Icons.play_arrow_rounded,
                onTap: () => _go(const ExamScreen()),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _StatBox('Urinish', '${history.length}')),
            const SizedBox(width: 10),
            Expanded(child: _StatBox("O'tdi", '$passed', color: C.ok)),
            const SizedBox(width: 10),
            Expanded(child: _StatBox('Eng yaxshi', '$best/20')),
          ]),
          const SizedBox(height: 22),
          const Text('Mashq', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.fitness_center_rounded,
            title: 'Mashq rejimi',
            subtitle: "Daraja va savollar sonini tanlang · javob darhol ko'rinadi",
            onTap: () => _go(const PracticeSetupScreen()),
          ),
          _MenuTile(
            icon: Icons.library_books_rounded,
            title: 'Barcha testlar',
            subtitle: prog > 0
                ? '${Bank.i.all.length} ta savol · ${prog + 1}-savolda to\'xtagansiz'
                : '${Bank.i.all.length} ta savolni ketma-ket yechish',
            onTap: _startAll,
          ),
          _MenuTile(
            icon: Icons.replay_circle_filled_rounded,
            title: 'Xatolar ustida ishlash',
            subtitle: wrongCount == 0 ? "Hozircha xato yo'q" : '$wrongCount ta savol takrorlashni kutmoqda',
            onTap: _startMistakes,
          ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text("So'nggi natijalar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final h in history.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Panel(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Icon(h.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: h.passed ? C.ok : C.bad),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${h.correct}/${h.total} to\'g\'ri · ${h.wrong} xato',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('${fmtTime(h.seconds)} · ${_date(h.date)}',
                        style: const TextStyle(color: C.muted, fontSize: 12.5)),
                  ]),
                ),
              ),
          ],
        ]),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox(this.label, this.value, {this.color = C.gold});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: C.muted, fontSize: 12.5)),
        ]),
      );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: C.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: C.line)),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: C.goldBg, borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: C.gold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: C.muted, fontSize: 13, height: 1.3)),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: C.muted),
              ]),
            ),
          ),
        ),
      );
}
