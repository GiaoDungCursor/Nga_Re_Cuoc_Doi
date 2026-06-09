import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../assessment/state/quiz_state.dart';
import '../../simulation/state/simulation_state.dart';

class CareerDnaScreen extends ConsumerStatefulWidget {
  const CareerDnaScreen({super.key});

  @override
  ConsumerState<CareerDnaScreen> createState() => _CareerDnaScreenState();
}

class _CareerDnaScreenState extends ConsumerState<CareerDnaScreen> {
  String? _selectedKey;

  final List<String> _allArchetypes = [
    'sage',
    'creator',
    'guardian',
    'influencer',
    'builder',
  ];

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final recommendedKey = quizState.resultArchetype ?? 'sage';
    
    // Nếu chưa chọn gì thì mặc định chọn cái được khuyến nghị
    final activeKey = _selectedKey ?? recommendedKey;
    final activeData = _getArchetypeDetails(activeKey);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.0,
            colors: [
              activeData.color.withOpacity(0.25),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'HỒ SƠ CAREER DNA CỦA BẠN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Horizontal List of Archetypes to select
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _allArchetypes.length,
                    itemBuilder: (context, index) {
                      final key = _allArchetypes[index];
                      final data = _getArchetypeDetails(key);
                      final isSelected = key == activeKey;
                      final isRecommended = key == recommendedKey;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedKey = key;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 12),
                          width: 85,
                          decoration: BoxDecoration(
                            color: isSelected ? data.color.withOpacity(0.2) : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? data.color : AppColors.glassBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Text(
                                    data.icon,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  if (isRecommended)
                                    const Positioned(
                                      top: -5,
                                      right: -5,
                                      child: Icon(Icons.star, color: AppColors.neonGold, size: 16),
                                    )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.shortName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? data.color : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Tiêu đề của Lớp được chọn
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.textPrimary, activeData.color],
                  ).createShader(bounds),
                  child: Text(
                    activeData.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Glass Card with Description & Radar Chart & Match Careers
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Description Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: activeData.color.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: activeData.color.withOpacity(0.15),
                                blurRadius: 25,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                activeData.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 25),
                              
                              // Radar Chart (Base on Quiz Scores, color matches selected archetype)
                              SizedBox(
                                height: 210,
                                child: RadarChart(
                                  RadarChartData(
                                    dataSets: [
                                      RadarDataSet(
                                        fillColor: activeData.color.withOpacity(0.25),
                                        borderColor: activeData.color,
                                        borderWidth: 2.5,
                                        entryRadius: 4,
                                        dataEntries: _getRadarEntries(quizState.scores),
                                      ),
                                    ],
                                    radarShape: RadarShape.circle,
                                    radarBorderData: const BorderSide(color: AppColors.glassBorder, width: 1),
                                    gridBorderData: const BorderSide(color: AppColors.glassBorder, width: 1),
                                    tickBorderData: const BorderSide(color: AppColors.glassBorder, width: 1),
                                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                                    titlePositionPercentageOffset: 0.15,
                                    getTitle: (index, angle) {
                                      final titles = ['Chuyên môn', 'Kỹ năng', 'Mối quan hệ', 'Tài chính', 'Cân bằng'];
                                      return RadarChartTitle(
                                        text: titles[index],
                                        angle: angle,
                                      );
                                    },
                                    titleTextStyle: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // Career Compatibility list (Top Phù hợp & Không Phù hợp)
                        _buildCompatibilityList(activeData),

                        const SizedBox(height: 20),
                        
                        const Text(
                          'Mức độ phù hợp dựa trên thuật toán kết hợp RIASEC & Big Five của bạn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Button CTA
                ElevatedButton(
                  onPressed: () {
                    final bg = quizState.backgroundAnswers;
                    ref.read(simulationProvider.notifier).startNewLife(
                      activeKey,
                      backgroundAnswers: bg,
                    );
                    context.pushReplacement('/simulation');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.transparent,
                    shadowColor: activeData.color.withOpacity(0.4),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ).copyWith(
                    elevation: ButtonStyleButton.allOrNull(8.0),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [activeData.color, AppColors.neonViolet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            activeKey == recommendedKey 
                              ? 'Chọn Lộ trình Khuyến nghị (2026)' 
                              : 'Thử thách với Lộ trình này (2026)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.play_arrow, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Khởi tạo các dòng radar
  List<RadarEntry> _getRadarEntries(Map<String, int> scores) {
    // Scores now have max of 200 (20 questions * 10 points) instead of 60.
    // Let's normalize it to a smaller range for display, or just use raw. RadarChart scales automatically but we can cap it.
    double logic = (scores['sage'] ?? 0).toDouble();
    double creative = (scores['creator'] ?? 0).toDouble();
    double stability = (scores['guardian'] ?? 0).toDouble();
    double communication = (scores['influencer'] ?? 0).toDouble();
    double execution = (scores['builder'] ?? 0).toDouble();

    // Scale down if it's too high just so it looks good, or just let FlChart handle the max value automatically.
    // Since FlChart handles relative values if we don't set min/max, we just pass the values directly.
    return [
      RadarEntry(value: logic > 0 ? logic : 5),
      RadarEntry(value: creative > 0 ? creative : 5),
      RadarEntry(value: stability > 0 ? stability : 5),
      RadarEntry(value: communication > 0 ? communication : 5),
      RadarEntry(value: execution > 0 ? execution : 5),
    ];
  }

  // Danh sách so sánh nghề nghiệp phù hợp / không phù hợp
  Widget _buildCompatibilityList(_ArchetypeUIHelper data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PHÙ HỢP CAO
          Row(
            children: const [
              Icon(Icons.check_circle_outline, color: AppColors.neonGreen, size: 18),
              SizedBox(width: 8),
              Text(
                'Top Nghề Phù Hợp',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...data.suitableCareers.map((car) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(car.title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      '${car.percent}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neonGreen),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 18),
          const Divider(color: AppColors.glassBorder),
          const SizedBox(height: 12),

          // KHÔNG PHÙ HỢP
          Row(
            children: const [
              Icon(Icons.highlight_off, color: AppColors.neonRed, size: 18),
              SizedBox(width: 8),
              Text(
                'Nghề Hạn Chế / Ít Phù Hợp',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...data.unsuitableCareers.map((car) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(car.title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      '${car.percent}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neonRed),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  _ArchetypeUIHelper _getArchetypeDetails(String key) {
    switch (key) {
      case 'sage':
        return const _ArchetypeUIHelper(
          name: 'Nhà Thông Thái',
          shortName: 'Sage',
          icon: '🧙‍♂️',
          description: 'Bạn có tư duy logic sắc sảo, niềm đam mê nghiên cứu và khả năng phân tích dữ liệu phức tạp. Bạn đi tìm giải pháp tối ưu nhất cho nhân loại.',
          color: AppColors.neonCyan,
          suitableCareers: [
            _CareerMatch('AI Specialist', 94),
            _CareerMatch('Data Scientist', 88),
            _CareerMatch('Research Engineer', 81),
          ],
          unsuitableCareers: [
            _CareerMatch('Sales Broker', 30),
            _CareerMatch('Public Relations (PR)', 22),
            _CareerMatch('Tour Guide', 15),
          ],
        );
      case 'creator':
        return const _ArchetypeUIHelper(
          name: 'Người Kiến Tạo',
          shortName: 'Creator',
          icon: '🎨',
          description: 'Bạn mang trong mình tâm hồn tự do và năng lực sáng tạo không giới hạn. Bạn luôn biến những ý tưởng trừu tượng thành những tác phẩm độc đáo.',
          color: AppColors.neonPink,
          suitableCareers: [
            _CareerMatch('UI/UX Designer', 92),
            _CareerMatch('Game Artist', 86),
            _CareerMatch('Content Producer', 80),
          ],
          unsuitableCareers: [
            _CareerMatch('Compliance Auditor', 25),
            _CareerMatch('Accountant', 18),
            _CareerMatch('Database Admin', 12),
          ],
        );
      case 'guardian':
        return const _ArchetypeUIHelper(
          name: 'Người Bảo Vệ',
          shortName: 'Guardian',
          icon: '🛡️',
          description: 'Bạn cẩn thận, có tính tổ chức cao và là chỗ dựa vững chắc cho mọi hệ thống. Bạn yêu thích quy trình ổn định lâu dài và quản trị rủi ro tốt.',
          color: AppColors.neonGold,
          suitableCareers: [
            _CareerMatch('Financial Risk Analyst', 93),
            _CareerMatch('Systems Auditor', 87),
            _CareerMatch('Security Architect', 81),
          ],
          unsuitableCareers: [
            _CareerMatch('Creative Copywriter', 35),
            _CareerMatch('Event Host', 28),
            _CareerMatch('Game Designer', 18),
          ],
        );
      case 'influencer':
        return const _ArchetypeUIHelper(
          name: 'Kẻ Thuyết Phục',
          shortName: 'Influencer',
          icon: '🗣️',
          description: 'Bạn sở hữu kỹ năng giao tiếp xuất sắc và khả năng kết nối con người vượt trội. Bạn có khả năng truyền cảm hứng và dẫn dắt đám đông.',
          color: AppColors.neonPink, // Trùng màu Creator, có thể đổi sang cam hoặc tím nhạt
          suitableCareers: [
            _CareerMatch('Product Manager', 95),
            _CareerMatch('Marketing Director', 89),
            _CareerMatch('Business Developer', 83),
          ],
          unsuitableCareers: [
            _CareerMatch('Embedded Systems', 30),
            _CareerMatch('Research Scientist', 22),
            _CareerMatch('Archivist', 15),
          ],
        );
      case 'builder':
      default:
        return const _ArchetypeUIHelper(
          name: 'Người Thực Thi',
          shortName: 'Builder',
          icon: '🛠️',
          description: 'Bạn là con người của hành động thực tế. Thích tạo dựng sản phẩm, làm việc với máy móc, code lập trình hay xây dựng các cơ sở hạ tầng.',
          color: AppColors.neonViolet,
          suitableCareers: [
            _CareerMatch('Mobile App Developer', 91),
            _CareerMatch('Backend Engineer', 85),
            _CareerMatch('IoT System Specialist', 79),
          ],
          unsuitableCareers: [
            _CareerMatch('Public Spokesperson', 35),
            _CareerMatch('HR Coordinator', 28),
            _CareerMatch('Real Estate Broker', 22),
          ],
        );
    }
  }
}

class _ArchetypeUIHelper {
  final String name;
  final String shortName;
  final String icon;
  final String description;
  final Color color;
  final List<_CareerMatch> suitableCareers;
  final List<_CareerMatch> unsuitableCareers;

  const _ArchetypeUIHelper({
    required this.name,
    required this.shortName,
    required this.icon,
    required this.description,
    required this.color,
    required this.suitableCareers,
    required this.unsuitableCareers,
  });
}

class _CareerMatch {
  final String title;
  final int percent;

  const _CareerMatch(this.title, this.percent);
}
