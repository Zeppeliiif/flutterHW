import 'package:flutter/material.dart';
import 'dart:math';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  final List<_EmojiParticle> _emojis = [];
  final List<String> _emojiList = [
    '😂',
    '😍',
    '👍',
    '🥳',
    '😎',
    '🤩',
    '😢',
    '🥷',
    '😱',
    '🤪',
    '😅',
    '🥶',
    '🥰',
  ];

  late DateTime _pressStart;

  void _addEmojiParticle([int pressDurationMs = 0]) {
    final random = Random();
    final emoji = _emojiList[random.nextInt(_emojiList.length)];
    final key = UniqueKey();
    final particle = _EmojiParticle(
      key: key,
      emoji: emoji,
      onCompleted: () {
        setState(() {
          _emojis.removeWhere((e) => e.key == key);
        });
      },
      pressDurationMs: pressDurationMs,
    );
    _emojis.add(particle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bouncy Emoji')),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text('试试长按！', style: const TextStyle(fontSize: 18)),
          ),
          ..._emojis,
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'try this👇',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTapDown: (_) {
          _pressStart = DateTime.now();
        },
        onTapUp: (_) {
          final pressDuration =
              DateTime.now().difference(_pressStart).inMilliseconds;
          setState(() {
            _addEmojiParticle(pressDuration);
          });
        },
        onTapCancel: () {
          final pressDuration =
              DateTime.now().difference(_pressStart).inMilliseconds;
          setState(() {
            _addEmojiParticle(pressDuration);
          });
        },
        child: const FloatingActionButton(
          onPressed: null,
          tooltip: 'Emoji',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

// 单个 emoji 粒子动画
class _EmojiParticle extends StatefulWidget {
  final String emoji;
  final VoidCallback onCompleted;
  final int pressDurationMs;

  const _EmojiParticle({
    Key? key,
    required this.emoji,
    required this.onCompleted,
    this.pressDurationMs = 0,
  }) : super(key: key);

  @override
  State<_EmojiParticle> createState() => _EmojiParticleState();
}

class _EmojiParticleState extends State<_EmojiParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double x, y;
  late double vx, vy;
  int bounceCount = 0;
  final int maxBounce = 4;
  final double gravity = 600; // 重力加速度，单位像素/秒²
  final double emojiSize = 40;
  late double screenWidth, screenHeight;
  late DateTime lastTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      screenWidth = size.width;
      screenHeight = size.height - 100; // 预留AppBar和底部空间

      final random = Random();
      x = random.nextDouble() * (screenWidth - emojiSize);
      y = screenHeight - emojiSize - 20;
      vx = (random.nextDouble() - 0.5) * 200; // -200~200 px/s

      // 按压时间越长，vy 绝对值越大，最小200，最大-1200
      double power = (widget.pressDurationMs / 1000.0).clamp(
        0.1,
        1.2,
      ); // 0.1~1.2秒
      vy = -(200 + power * 800); // -480 ~ -1360 px/s（向上）

      lastTime = DateTime.now();

      _controller =
          AnimationController(
              vsync: this,
              duration: const Duration(seconds: 10),
            )
            ..addListener(_tick)
            ..forward();
    });
  }

  void _tick() {
    final now = DateTime.now();
    final dt = now.difference(lastTime).inMilliseconds / 1000.0;
    lastTime = now;

    setState(() {
      // 更新位置
      x += vx * dt;
      vy += gravity * dt;
      y += vy * dt;

      // 边界检测与反弹
      bool bounced = false;
      if (x < 0) {
        x = 0;
        vx = -vx;
        bounced = true;
      } else if (x > screenWidth - emojiSize) {
        x = screenWidth - emojiSize;
        vx = -vx;
        bounced = true;
      }
      if (y > screenHeight - emojiSize) {
        y = screenHeight - emojiSize;
        vy = -vy * 0.7; // 每次弹跳能量损失
        bounced = true;
        bounceCount++;
      }
      if (y < 0) {
        y = 0;
        vy = -vy;
        bounced = true;
      }

      if (bounced && bounceCount >= maxBounce) {
        _controller.dispose();
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      _controller.value;
    } catch (e) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: x,
      top: y,
      child: Text(widget.emoji, style: const TextStyle(fontSize: 40)),
    );
  }
}
