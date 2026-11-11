import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data.dart';
import 'theme.dart';

String fmtTime(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class GoldButton extends StatelessWidget {
  const GoldButton({super.key, required this.label, this.onTap, this.icon, this.outline = false});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = outline ? (enabled ? C.gold : C.muted) : Colors.black;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: outline ? BorderSide(color: enabled ? C.gold : C.line, width: 1.5) : BorderSide.none,
    );
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: outline ? Colors.transparent : (enabled ? C.gold : C.line),
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, color: fg, size: 22), const SizedBox(width: 8)],
              Text(label, style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.borderColor = C.line});
  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: child,
      );
}

class InfoChip extends StatelessWidget {
  const InfoChip(this.icon, this.text, {super.key, this.color = C.gold});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      );
}

class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = C.gold
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + 16, size.height / 2), p);
      x += 28;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum OptState { idle, correct, wrong }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
    this.dim = false,
  });
  final String letter;
  final String text;
  final OptState state;
  final VoidCallback? onTap;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    Color bg = C.surface, border = C.line, badgeBg = C.surface2, badgeFg = C.gold;
    IconData? trail;
    switch (state) {
      case OptState.idle:
        break;
      case OptState.correct:
        bg = C.okBg;
        border = C.ok;
        badgeBg = C.ok;
        badgeFg = Colors.black;
        trail = Icons.check_circle_rounded;
        break;
      case OptState.wrong:
        bg = C.badBg;
        border = C.bad;
        badgeBg = C.bad;
        badgeFg = Colors.black;
        trail = Icons.cancel_rounded;
        break;
    }
    return Opacity(
      opacity: dim ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: state == OptState.idle ? 1 : 1.6),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                    child: Text(letter, style: TextStyle(color: badgeFg, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text, style: const TextStyle(fontSize: 15.5, height: 1.3))),
                  if (trail != null) ...[
                    const SizedBox(width: 8),
                    Icon(trail, color: state == OptState.correct ? C.ok : C.bad),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignImage extends StatelessWidget {
  const SignImage(this.imageKey, {super.key, this.height = 170});
  final String imageKey;
  final double height;

  @override
  Widget build(BuildContext context) {
    final svg = Bank.i.svgs[imageKey];
    if (svg == null) return const SizedBox.shrink();
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(20)),
      child: SvgPicture.string(svg, fit: BoxFit.contain),
    );
  }
}

class QuestionView extends StatelessWidget {
  const QuestionView({super.key, required this.q, required this.picked, required this.onPick});
  final Question q;
  final int? picked;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final answered = picked != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      children: [
        if (q.imageKey != null) ...[SignImage(q.imageKey!), const SizedBox(height: 14)],
        Text(q.text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, height: 1.35)),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          OptionTile(
            letter: String.fromCharCode(65 + i),
            text: q.options[i],
            state: !answered
                ? OptState.idle
                : (i == q.answer ? OptState.correct : (i == picked ? OptState.wrong : OptState.idle)),
            dim: answered && i != q.answer && i != picked,
            onTap: answered ? null : () => onPick(i),
          ),
      ],
    );
  }
}
