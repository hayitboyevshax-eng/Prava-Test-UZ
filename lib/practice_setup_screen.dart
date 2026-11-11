import 'dart:math';
import 'package:flutter/material.dart';
import 'data.dart';
import 'practice_screen.dart';
import 'theme.dart';
import 'ui.dart';

class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({super.key});
  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  Level? level; // null = aralash
  int count = 20; // 0 = hammasi
  bool shuffle = true;

  List<Question> get _pool => level == null ? Bank.i.all : Bank.i.byLevel[level]!;

  void _start() {
    final r = Random();
    var list = [..._pool];
    if (shuffle) list.shuffle(r);
    if (count > 0) list = list.take(count).toList();
    list = list.map((q) => shuffle ? q.shuffled(r) : q).toList();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeScreen(
          title: 'Mashq · ${level == null ? 'Aralash' : levelName(level!)}',
          questions: list,
        ),
      ),
    );
  }

  Widget _choice(String label, bool selected, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? C.gold : C.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? C.gold : C.line),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: selected ? Colors.black : C.text)),
        ),
      );

  Widget _section(String title, List<Widget> chips) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: chips),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final total = _pool.length;
    final n = count == 0 ? total : min(count, total);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mashq rejimi', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              _section('Qiyinlik darajasi', [
                _choice('Aralash', level == null, () => setState(() => level = null)),
                for (final l in Level.values)
                  _choice('${levelName(l)} (${Bank.i.byLevel[l]!.length})', level == l, () => setState(() => level = l)),
              ]),
              _section('Savollar soni', [
                for (final c in [10, 20, 40])
                  _choice('$c ta', count == c, () => setState(() => count = c)),
                _choice('Hammasi', count == 0, () => setState(() => count = 0)),
              ]),
              Panel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: C.gold,
                  title: const Text('Aralashtirish', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Savollar va javoblar tartibi tasodifiy', style: TextStyle(color: C.muted)),
                  value: shuffle,
                  onChanged: (v) => setState(() => shuffle = v),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Mashqda javob darhol ko'rsatiladi, vaqt cheklanmagan, orqaga qaytish mumkin.",
                style: TextStyle(color: C.muted, height: 1.4),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: GoldButton(label: 'Boshlash · $n ta savol', icon: Icons.play_arrow_rounded, onTap: _start),
          ),
        ]),
      ),
    );
  }
}
