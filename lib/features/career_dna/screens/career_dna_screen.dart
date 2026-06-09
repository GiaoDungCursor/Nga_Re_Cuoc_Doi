import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../assessment/state/quiz_state.dart';
import '../../simulation/state/simulation_state.dart';

class CareerDnaScreen extends ConsumerWidget {
  const CareerDnaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final archetypeKey = quizState.resultArchetype ?? 'sage';

    final data = _getArchetypeDetails(archetypeKey);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.0,
            colors: [
              data.color.withOpacity(0.25),
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
                  'HỒ SƠ CAREER DNA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.textPrimary, data.color],
                  ).createShader(bounds),
                  child: Text(
                    data.name.toUpperCase(),
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
                            border: Border.all(color: data.color.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: data.color.withOpacity(0.15),
                                blurRadius: 25,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                data.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 25),
                              
                              // Radar Chart
                              SizedBox(
                                height: 210,
                                child: RadarChart(
                                  RadarChartData(
                                    dataSets: [
                                      RadarDataSet(
                                        fillColor: data.color.withOpacity(0.25),
                                        borderColor: data.color,
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
                        _buildCompatibilityList(data),

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
                    ref.read(simulationProvider.notifier).startNewLife(archetypeKey);
                    context.pushReplacement('/simulation');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.transparent,
                    shadowColor: data.color.withOpacity(0.4),
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
                        colors: [data.color, AppColors.neonViolet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Bắt đầu Mô phỏng Sự nghiệp (2026)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.play_arrow, color: Colors.white),
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
    double logic = (scores['sage'] ?? 10).toDouble();
    double creative = (scores['creator'] ?? 10).toDouble();
    double stability = (scores['guardian'] ?? 10).toDouble();
    double communication = (scores['influencer'] ?? 10).toDouble();
    double execution = (scores['builder'] ?? 10).toDouble();

    return [
      RadarEntry(value: logic.clamp(5, 30)),
      RadarEntry(value: creative.clamp(5, 30)),
      RadarEntry(value: stability.clamp(5, 30)),
      RadarEntry(value: communication.clamp(5, 30)),
      RadarEntry(value: execution.clamp(5, 30)),
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
          name: '🧙‍♂️ Nhà Thông Thái',
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
          name: '🎨 Người Kiến Tạo',
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
            _CareerMatch('Database Administrator', 12),
          ],
        );
      case 'guardian':
        return const _ArchetypeUIHelper(
          name: '🛡️ Người Bảo Vệ',
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
          name: '🗣️ Kẻ Thuyết Phục',
          description: 'Bạn sở hữu kỹ năng giao tiếp xuất sắc và khả năng kết nối con người vượt trội. Bạn có khả năng truyền cảm hứng và dẫn dắt đám đông.',
          color: AppColors.neonPink,
          suitableCareers: [
            _CareerMatch('Product Manager', 95),
            _CareerMatch('Marketing Director', 89),
            _CareerMatch('Business Developer', 83),
          ],
          unsuitableCareers: [
            _CareerMatch('Embedded Systems Engineer', 30),
            _CareerMatch('Research Scientist', 22),
            _CareerMatch('Archivist', 15),
          ],
        );
      case 'builder':
      default:
        return const _ArchetypeUIHelper(
          name: '🛠️ Người Thực Thi',
          description: 'Bạn là con người của hành động thực tế. Thích tạo dựng sản phẩm, làm việc với máy móc, code lập trình hay xây dựng các cơ sở hạ tầng.',
          color: AppColors.neonViolet,
          suitableCareers: [
            _CareerMatch('Mobile App Developer', 91),
            _CareerMatch('Backend Software Engineer', 85),
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
  final String description;
  final Color color;
  final List<_CareerMatch> suitableCareers;
  final List<_CareerMatch> unsuitableCareers;

  const _ArchetypeUIHelper({
    required this.name,
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
