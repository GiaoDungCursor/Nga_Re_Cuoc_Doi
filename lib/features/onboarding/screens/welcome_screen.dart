import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.fork_right_rounded,
      'title': 'Ngã Rẽ\nCuộc Đời',
      'subtitle':
          'Trải nghiệm mô phỏng sự nghiệp 10 năm trước khi đưa ra những quyết định thực sự thay đổi cuộc đời bạn.',
      'color': AppColors.neonViolet,
      'tag': 'CAREER SIMULATION',
    },
    {
      'icon': Icons.auto_graph_rounded,
      'title': 'Khảo Sát\nCareer DNA',
      'subtitle':
          'Trả lời 25 câu hỏi chuyên sâu về bối cảnh cá nhân, kỹ năng và tính cách. Hệ thống sẽ xác định lớp nghề nghiệp phù hợp nhất với bạn — từ Bác sĩ đến Chính trị gia.',
      'color': AppColors.neonCyan,
      'tag': '25 CÂU HỎI',
    },
    {
      'icon': Icons.timeline_rounded,
      'title': 'Mô Phỏng\n10 Năm',
      'subtitle':
          'Phân bổ Thời gian, Năng lượng và Tài chính để vượt qua các ngã rẽ lớn từ 2026–2036. Mỗi quyết định đều có hậu quả thực tế.',
      'color': AppColors.neonPink,
      'tag': 'YEAR 2026 → 2036',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _fadeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final color = slide['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: Stack(
        children: [
          // ── Animated background gradient ───────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.7),
                radius: 1.4,
                colors: [
                  color.withOpacity(0.18),
                  const Color(0xFF0A0A12),
                ],
              ),
            ),
          ),

          // ── Decorative grid lines ──────────────────────
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(color.withOpacity(0.04)),
          ),

          // ── Main content ───────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand logo
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.fork_right_rounded,
                              color: color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'NGA RẼ',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push('/quiz'),
                        child: Row(
                          children: [
                            Text(
                              'Bỏ qua',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Slide content ──────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final s = _slides[index];
                      final c = s['color'] as Color;
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon with animated orb
                              Center(
                                child: AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: index == _currentPage
                                          ? _pulseAnimation.value
                                          : 1.0,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          c.withOpacity(0.25),
                                          c.withOpacity(0.05),
                                          Colors.transparent,
                                        ],
                                      ),
                                      border: Border.all(
                                        color: c.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: c.withOpacity(0.3),
                                          blurRadius: 40,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      s['icon'] as IconData,
                                      color: c,
                                      size: 52,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Tag chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: c.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: c.withOpacity(0.3)),
                                ),
                                child: Text(
                                  s['tag'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: c,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Title
                              Text(
                                s['title'] as String,
                                style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Subtitle
                              Text(
                                s['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: Colors.white.withOpacity(0.55),
                                  height: 1.65,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Bottom navigation ─────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    children: [
                      // Step indicators
                      Row(
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 6),
                            height: 4,
                            width: _currentPage == i ? 28 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? color
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // CTA Button — full width
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_currentPage == _slides.length - 1) {
                                  context.push('/quiz');
                                } else {
                                  _pageController.nextPage(
                                    duration:
                                        const Duration(milliseconds: 450),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 24,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _currentPage == _slides.length - 1
                                          ? 'Bắt đầu Khảo sát'
                                          : 'Tiếp tục',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vẽ lưới nền mờ phong cách tech/matrix
class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const spacing = 48.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
