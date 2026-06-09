import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': '🔀',
      'title': 'Ngã Rẽ Cuộc Đời',
      'subtitle': 'Trải nghiệm tương lai của chính bạn trước khi đưa ra quyết định thực tế',
      'color': AppColors.neonViolet,
    },
    {
      'icon': '🧬',
      'title': 'Khám Phá Career DNA',
      'subtitle': 'Làm bài khảo sát chuyên sâu về kỹ năng, sở thích và tính cách để tìm ra lớp nghề nghiệp (Archetype) phù hợp nhất với bạn trong ngành Công nghệ.',
      'color': AppColors.neonCyan,
    },
    {
      'icon': '⏳',
      'title': 'Mô Phỏng 10 Năm Sự Nghiệp',
      'subtitle': 'Quản lý Thời gian, Năng lượng và Tài chính để vượt qua các quyết định cam go từ năm 2026 đến 2036. Sẵn sàng chưa?',
      'color': AppColors.neonPink,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [
              Color(0x228A2BE2),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Nút Bỏ qua (Skip)
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/quiz');
                    },
                    child: const Text(
                      'Bỏ qua',
                      style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // Nội dung Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Biểu tượng Orb
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      (slide['color'] as Color).withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (slide['color'] as Color).withOpacity(0.5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (slide['color'] as Color).withOpacity(0.2),
                                      blurRadius: 20,
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    slide['icon'] as String,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          // Tiêu đề
                          if (index == 0) ...[
                            const Text(
                              'Ngã Rẽ',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.1,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppColors.neonCyan, AppColors.neonPink],
                              ).createShader(bounds),
                              child: const Text(
                                'Cuộc Đời',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              slide['title'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: slide['color'] as Color,
                                height: 1.2,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Mô tả
                          Text(
                            slide['subtitle'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Navigation & Indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicators
                    Row(
                      children: List.generate(
                        _slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _slides[_currentPage]['color'] as Color
                                : AppColors.glassBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    // Nút Next / Start
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _slides.length - 1) {
                          context.push('/quiz');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: _slides[_currentPage]['color'] as Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1 ? 'Khảo sát ngay' : 'Tiếp tục',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
