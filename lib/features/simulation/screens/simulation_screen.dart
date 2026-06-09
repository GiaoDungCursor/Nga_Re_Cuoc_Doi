import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/character.dart';
import '../../../shared/models/event.dart';
import '../state/simulation_state.dart';
import '../../assessment/state/quiz_state.dart';

class SimulationScreen extends ConsumerWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simState = ref.watch(simulationProvider);
    final simNotifier = ref.read(simulationProvider.notifier);

    if (simState.character == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
      );
    }

    final char = simState.character!;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Don't show top stats and resources on final report screen to focus on diagnosis
            if (simState.phase != SimulationPhase.finalReport) ...[
              _buildStatsBar(char),
              const SizedBox(height: 10),
              _buildResourceBar(char),
              const SizedBox(height: 12),
            ],
            
            // Phase Content Area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<SimulationPhase>(simState.phase),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildPhaseContent(context, ref, simState, simNotifier),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STATS TOP BAR ---
  Widget _buildStatsBar(Character char) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        border: const Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatIndicator(Icons.trending_up, AppColors.neonCyan, char.employability, 'Tuyển dụng'),
          _buildStatIndicator(Icons.school, AppColors.neonGreen, char.skillScore, 'Kỹ năng'),
          _buildStatIndicator(Icons.monetization_on, AppColors.neonGold, char.financeScore, 'Tài chính', isMoney: true),
          _buildStatIndicator(Icons.favorite, AppColors.neonRed, char.wellBeingScore, 'Well-being', burnoutVal: char.burnout),
        ],
      ),
    );
  }

  Widget _buildStatIndicator(IconData icon, Color color, double val, String label, {bool isMoney = false, double? burnoutVal}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              isMoney 
                  ? '${val.toInt()}M' 
                  : (burnoutVal != null ? '${val.toInt()}/${burnoutVal.toInt()} BO' : '${val.toInt()}%'),
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          width: 72,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (val / 100.0).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // --- RESOURCE BAR (Time, Energy, Cash) ---
  Widget _buildResourceBar(Character char) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResourceItem(Icons.access_time, AppColors.neonCyan, '${char.timePoints}/12', 'Thời gian'),
          _buildResourceItem(Icons.bolt, AppColors.neonPink, '${char.energyPoints}/${(char.wellBeingScore / 10).round().clamp(2, 12)}', 'Năng lượng'),
          _buildResourceItem(Icons.account_balance_wallet, AppColors.neonGold, '${char.moneyPoints.toStringAsFixed(1)}M', 'Tiền tiêu dùng'),
        ],
      ),
    );
  }

  Widget _buildResourceItem(IconData icon, Color color, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'SpaceGrotesk'),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w700),
            ),
          ],
        )
      ],
    );
  }

  // --- PHASE ROUTER ---
  Widget _buildPhaseContent(BuildContext context, WidgetRef ref, SimulationStateData state, SimulationNotifier notifier) {
    switch (state.phase) {
      case SimulationPhase.yearIntro:
        return _buildYearIntro(context, state, notifier);
      case SimulationPhase.mainDecision:
        return _buildMainDecision(context, state, notifier);
      case SimulationPhase.subDecision:
        return _buildSubDecision(context, state, notifier);
      case SimulationPhase.consequenceReveal:
        return _buildConsequenceReveal(context, state, notifier);
      case SimulationPhase.reflection:
        return _buildReflection(context, state, notifier);
      case SimulationPhase.yearSummary:
        return _buildYearSummary(context, state, notifier);
      case SimulationPhase.finalReport:
        return _buildFinalReport(context, ref, state, notifier);
    }
  }

  // ==========================================
  // PHASE 1: YEAR INTRO
  // ==========================================
  Widget _buildYearIntro(BuildContext context, SimulationStateData state, SimulationNotifier notifier) {
    final char = state.character!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withOpacity(0.08),
            border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'NĂM ${char.year}',
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.neonCyan,
              letterSpacing: 2,
              shadows: [Shadow(color: AppColors.neonCyan, blurRadius: 10)],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.neonCyan, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Khởi Đầu Chu Kỳ Quyết Định Mới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn bước sang năm ${char.year} phát triển sự nghiệp. Hãy cẩn trọng phân bổ 12 điểm Thời gian cùng với ${char.energyPoints} điểm Năng lượng cơ thể để đối mặt với thử thách năm nay.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.glassBorder),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vai trò:', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  Text(char.archetype.toUpperCase(), style: const TextStyle(color: AppColors.neonPink, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thu nhập hiện tại:', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  Text('${char.currentIncome.toInt()}M VND / tháng', style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => notifier.proceedToMainDecision(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ).copyWith(
            elevation: ButtonStyleButton.allOrNull(8.0),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Khám Phá Tình Huống',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PHASE 2: MAIN DECISION
  // ==========================================
  Widget _buildMainDecision(BuildContext context, SimulationStateData state, SimulationNotifier notifier) {
    final char = state.character!;
    final event = state.currentEvent;

    if (event == null) {
      return const Center(child: Text('Không có sự kiện cho năm này. Hãy tiếp tục.'));
    }

    // Kiểm tra xem nhân vật có đủ khả năng chi trả cho BẤT KỲ lựa chọn phụ nào của sự kiện này không
    bool canAffordAny = false;
    for (var choice in event.choices) {
      for (var sub in choice.subChoices) {
        if (sub.cost.isAffordableBy(char)) {
          canAffordAny = true;
          break;
        }
      }
      if (canAffordAny) break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Event Weight Badge
        _buildWeightBadge(event.weight),
        const SizedBox(height: 10),
        // Event Title
        Text(
          event.title,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        // Event Description Card
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: SingleChildScrollView(
              child: Text(
                event.description,
                style: const TextStyle(fontSize: 14.5, color: AppColors.textSecondary, height: 1.6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Action Area
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!canAffordAny) ...[
                  // Forced Rest Warning
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neonRed.withOpacity(0.08),
                      border: Border.all(color: AppColors.neonRed.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: AppColors.neonRed, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'KIỆT QUỆ TÀI NGUYÊN',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.neonRed, fontSize: 13),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Quỹ Thời gian hoặc Năng lượng của bạn không đủ để thực hiện bất kỳ lựa chọn nào của sự kiện năm nay. Cơ thể bạn đang đình công vì quá tải!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notifier.forceRest(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen.withOpacity(0.12),
                      side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Center(
                      child: Text(
                        'Nghỉ ngơi phục hồi bắt buộc (+Sức khỏe, -Kỹ năng)',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.neonGreen, fontSize: 13.5),
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'HÃY CHỌN HƯỚNG ĐI CHÍNH:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  ...event.choices.map((choice) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Card(
                        color: AppColors.bgCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.glassBorder),
                        ),
                        child: InkWell(
                          onTap: () => notifier.selectMainChoice(choice),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        choice.title,
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        choice.description,
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PHASE 3: SUB DECISION (TRADE-OFF DETAIL)
  // ==========================================
  Widget _buildSubDecision(BuildContext context, SimulationStateData state, SimulationNotifier notifier) {
    final char = state.character!;
    final choice = state.selectedChoice;

    if (choice == null) {
      return const Center(child: Text('Không tìm thấy lựa chọn. Hãy quay lại.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => notifier.backToMainDecision(),
        ),
        const SizedBox(height: 4),
        const Text(
          'CHI TIẾT ĐÁNH ĐỔI (TRADE-OFF)',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.neonGold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          choice.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 14),
        const Text(
          'Bạn muốn thực hiện lựa chọn này ở mức độ nào? Hãy cân nhắc kỹ hao tổn tài nguyên:',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: choice.subChoices.length,
            itemBuilder: (context, index) {
              final sub = choice.subChoices[index];
              final tCost = sub.cost.time;
              final eCost = sub.cost.energy;
              final mCost = sub.cost.money;

              // Check affordability using model helper
              final canAfford = sub.cost.isAffordableBy(char);
              final hasTime = char.timePoints >= tCost;
              final hasEnergy = char.energyPoints >= eCost;
              final hasMoney = char.moneyPoints >= mCost;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Opacity(
                  opacity: canAfford ? 1.0 : 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: canAfford ? AppColors.glassBorder : AppColors.neonRed.withOpacity(0.3),
                        width: canAfford ? 1 : 1.5,
                      ),
                    ),
                    child: InkWell(
                      onTap: canAfford ? () => notifier.selectSubChoice(sub) : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.title,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sub.description,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                            ),
                            const SizedBox(height: 14),
                            // Resources Cost Display
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _buildCostBadge(Icons.access_time, '$tCost Time', hasTime),
                                _buildCostBadge(Icons.bolt, '$eCost Energy', hasEnergy),
                                _buildCostBadge(Icons.account_balance_wallet, '${mCost.toStringAsFixed(0)}M Cash', hasMoney, isStrict: false),
                              ],
                            ),
                            if (!canAfford) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: const [
                                  Icon(Icons.lock_clock, color: AppColors.neonRed, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Không đủ Thời gian hoặc Năng lượng!',
                                    style: TextStyle(color: AppColors.neonRed, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCostBadge(IconData icon, String text, bool isAffordable, {bool isStrict = true}) {
    final textColor = isAffordable 
        ? AppColors.neonGreen 
        : (isStrict ? AppColors.neonRed : AppColors.neonGold);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PHASE 4: CONSEQUENCE REVEAL (PREVIEW)
  // ==========================================
  Widget _buildConsequenceReveal(BuildContext context, SimulationStateData state, SimulationNotifier notifier) {
    final sub = state.selectedSubChoice;

    if (sub == null) {
      return const Center(child: Text('Không tìm thấy dữ liệu. Hãy quay lại.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => notifier.backToSubDecision(),
        ),
        const SizedBox(height: 4),
        const Text(
          'DỰ BÁO HẬU QUẢ MƠ HỒ (CONSEQUENCE PREVIEW)',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.neonPink, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sub.title,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.4, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                sub.description,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Hệ quả dự kiến lên các phương diện sự nghiệp:',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: ListView(
              children: sub.effects.entries.map((entry) {
                return _buildConsequenceIndicator(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => notifier.confirmDecision(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ).copyWith(
            elevation: ButtonStyleButton.allOrNull(8.0),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Xác Nhận Quyết Định',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildConsequenceIndicator(String key, double val) {
    String name = '';
    String direction = '';
    Color color = AppColors.textPrimary;
    IconData icon = Icons.circle;

    switch (key) {
      case 'careerScore':
        name = 'Cơ hội & Danh tiếng (Career)';
        icon = Icons.trending_up;
        break;
      case 'skillScore':
        name = 'Kỹ năng chuyên môn (Skill)';
        icon = Icons.school;
        break;
      case 'networkScore':
        name = 'Mạng lưới quan hệ (Network)';
        icon = Icons.people;
        break;
      case 'financeScore':
        name = 'Tài sản tích lũy (Finance)';
        icon = Icons.monetization_on;
        break;
      case 'wellBeingScore':
        name = 'Sức khỏe & Tinh thần (Well-being)';
        icon = Icons.favorite;
        break;
      case 'burnout':
        name = 'Mức độ stress (Burnout)';
        icon = Icons.bolt;
        break;
      case 'currentIncome':
        name = 'Thu nhập hàng tháng';
        icon = Icons.wallet;
        break;
      default:
        name = key;
    }

    if (val > 15) {
      direction = 'Tăng rất nhiều (↑↑)';
      color = (key == 'burnout') ? AppColors.neonRed : AppColors.neonGreen;
    } else if (val > 0) {
      direction = 'Tăng (↑)';
      color = (key == 'burnout') ? AppColors.neonRed : AppColors.neonGreen;
    } else if (val < -10) {
      direction = 'Giảm mạnh (↓↓)';
      color = (key == 'burnout') ? AppColors.neonGreen : AppColors.neonRed;
    } else if (val < 0) {
      direction = 'Giảm nhẹ (↓)';
      color = (key == 'burnout') ? AppColors.neonGreen : AppColors.neonRed;
    } else {
      direction = 'Không đổi';
      color = AppColors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            direction,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PHASE 5: REFLECTION — Kết quả Quyết Định
  // ==========================================
  Widget _buildReflection(BuildContext context, SimulationStateData state, SimulationNotifier notifier) {
    final question = state.reflectionQuestion ?? 'Tư duy của bạn sau quyết định này là gì?';
    final options = state.reflectionOptions;
    final event = state.currentEvent;
    final choice = state.selectedChoice;
    final sub = state.selectedSubChoice;

    // Nếu không có options → tự động bỏ qua phase này
    if (options.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.selectReflection('Bỏ qua');
      });
      return const Center(child: CircularProgressIndicator(color: AppColors.neonCyan));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // ── Tóm tắt Sự kiện & Quyết định vừa thực hiện ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nhãn SỰ KIỆN
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neonViolet.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.neonViolet.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'SỰ KIỆN NĂM NAY',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.neonViolet, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  event?.title ?? 'Sự kiện trong năm',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.3),
                ),
                if (event?.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    event!.description,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(color: AppColors.glassBorder),
                const SizedBox(height: 10),
                // Nhãn QUYẾT ĐỊNH
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.neonCyan.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'QUYẾT ĐỊNH CỦA BẠN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.neonCyan, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 8),
                if (choice != null)
                  Text(
                    '• ${choice.title}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                if (sub != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '↳ ${sub.title}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sub.log,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontStyle: FontStyle.italic, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ── Câu hỏi tư duy ────────────────────────────────
          const Text(
            'TƯ DUY CỦA BẠN SAU QUYẾT ĐỊNH NÀY:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
            ),
            child: Text(
              question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          // ── Các lựa chọn tư duy ───────────────────────────
          ...List.generate(options.length, (index) {
            final opt = options[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                onPressed: () => notifier.selectReflection(opt),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.01),
                  side: const BorderSide(color: AppColors.glassBorder),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.neonCyan),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }




  // ==========================================
  // PHASE 6: YEAR SUMMARY (SHOW RESULTS)
  // ==========================================
  Widget _buildYearSummary(BuildContext context, SimulationStateData state, SimulationNotifier notifier) {
    final char = state.character!;
    final reflection = state.selectedReflection;

    // Tìm quyết định gần nhất từ lịch sử DecisionHistory
    final history = state.decisionsHistory;
    final DecisionHistory? lastDecision = history.isNotEmpty ? history.last : null;

    final title = lastDecision?.eventTitle ?? 'Năm bình lặng';
    final logText = lastDecision?.log ?? 'Mọi chuyện diễn ra bình ổn.';
    final effects = lastDecision?.effects ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neonGreen.withOpacity(0.4)),
          ),
          child: Text(
            'TỔNG KẾT NĂM ${char.year}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.neonGreen, letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story Log Card
                Container(
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
                      const Text(
                        'Kết quả hành vi:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        logText,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                      ),
                      if (reflection != null) ...[
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.glassBorder),
                        const SizedBox(height: 8),
                        const Text(
                          'Nhận thức phản tư của bạn:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"$reflection"',
                          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.neonCyan, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'THAY ĐỔI CHỈ SỐ THỰC TẾ:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                // Stat Changes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    children: effects.entries.map((entry) {
                      final val = entry.value;
                      final isPositive = val > 0;
                      final sign = isPositive ? '+' : '';
                      
                      String label = entry.key;
                      if (label == 'careerScore') label = 'Cơ hội & Danh tiếng';
                      if (label == 'skillScore') label = 'Kỹ năng chuyên môn';
                      if (label == 'networkScore') label = 'Mối quan hệ';
                      if (label == 'financeScore') label = 'Tài sản tích lũy';
                      if (label == 'wellBeingScore') label = 'Sức khỏe & Tinh thần';
                      if (label == 'burnout') label = 'Mức độ stress';
                      if (label == 'currentIncome') label = 'Thu nhập tăng';

                      final txtColor = isPositive 
                          ? (entry.key == 'burnout' ? AppColors.neonRed : AppColors.neonGreen)
                          : (entry.key == 'burnout' ? AppColors.neonGreen : AppColors.neonRed);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            Text(
                              '$sign${val.toInt()}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: txtColor),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Show Log Button
                GestureDetector(
                  onTap: () => _showLogBottomSheet(context, state.lifeLog),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 6),
                      Text('Xem toàn bộ Nhật ký sự nghiệp', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => notifier.progressToNextYear(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ).copyWith(
            elevation: ButtonStyleButton.allOrNull(8.0),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Bước Sang Năm Tiếp Theo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.double_arrow, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ==========================================
  // PHASE 7: FINAL DIAGNOSTIC REPORT (GAME OVER / END GAME)
  // ==========================================
  Widget _buildFinalReport(BuildContext context, WidgetRef ref, SimulationStateData state, SimulationNotifier notifier) {
    final char = state.character!;
    final report = state.finalReportData ?? {
      'title': 'Chưa xác định',
      'details': 'Chúc mừng bạn đã hoàn thành lộ trình mô phỏng sự nghiệp.',
      'analysis': <String>[],
      'topDecisions': <String>[],
      'recommendations': <String>[],
    };

    final isFailed = char.isGameOver && (char.gameOverReason?.contains('Burnout') == true || char.gameOverReason?.contains('Sức khỏe') == true);
    final themeColor = isFailed ? AppColors.neonRed : AppColors.neonCyan;

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeColor.withOpacity(0.4)),
          ),
          child: Text(
            isFailed ? 'KHỦNG HOẢNG SỰ NGHIỆP 🏥' : 'KẾT THÚC LỘ TRÌNH 10 NĂM 🏆',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeColor, letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        // Diagnosis Title
        Text(
          report['title'] as String,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: themeColor,
            shadows: [Shadow(color: themeColor.withOpacity(0.5), blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 14),
        // Diagnostic Report Contents
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Diagnosis summary description
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    report['details'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.55),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Final stats Radar Chart
                const Text(
                  'BẢN ĐỒ CÂN BẰNG CHỈ SỐ CUỐI KỲ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                _buildFinalRadarChart(char),
                
                const SizedBox(height: 20),
                
                // Section: Vì sao ra kết quả này?
                _buildDiagnosticSection(
                  title: 'Phân Tích Nguyên Nhân (Vì sao có kết quả này?)',
                  icon: Icons.analytics,
                  iconColor: AppColors.neonCyan,
                  bullets: List<String>.from(report['analysis'] as Iterable? ?? []),
                ),
                
                const SizedBox(height: 16),
                
                // Section: 3 quyết định ảnh hưởng nhất
                _buildDiagnosticSection(
                  title: '3 Quyết Định Trọng Yếu Nhất Bạn Đã Đưa Ra',
                  icon: Icons.alt_route,
                  iconColor: AppColors.neonGold,
                  bullets: List<String>.from(report['topDecisions'] as Iterable? ?? []),
                ),
                
                const SizedBox(height: 16),
                
                // Section: Nếu chơi lại
                _buildDiagnosticSection(
                  title: 'Lời Khuyên Chiến Lược (Nếu chơi lại)',
                  icon: Icons.lightbulb,
                  iconColor: AppColors.neonGreen,
                  bullets: List<String>.from(report['recommendations'] as Iterable? ?? []),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Action Buttons
        Column(
          children: [
            ElevatedButton(
              onPressed: () => _showRealRoadmapBottomSheet(context, char.archetype),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.neonViolet,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Center(
                child: Text(
                  'Xem Lộ Trình Học Tập Thực Tế',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref.read(quizProvider.notifier).reset();
                ref.read(simulationProvider.notifier).reset();
                context.pushReplacement('/');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: AppColors.glassBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Center(
                child: Text(
                  'Chơi Lại Kịch Bản Khác',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  // --- DIAGNOSTIC SECTION BUILDER ---
  Widget _buildDiagnosticSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> bullets,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.glassBorder),
          const SizedBox(height: 8),
          if (bullets.isEmpty)
            const Text('Không có ghi nhận đặc biệt.', style: TextStyle(color: AppColors.textMuted, fontSize: 13))
          else
            Column(
              children: bullets.map((b) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Icon(Icons.circle, size: 6, color: iconColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // --- RADAR CHART FOR ENDING STATS ---
  Widget _buildFinalRadarChart(Character char) {
    return SizedBox(
      height: 180,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.neonCyan.withOpacity(0.15),
              borderColor: AppColors.neonCyan,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: [
                RadarEntry(value: char.careerScore),
                RadarEntry(value: char.skillScore),
                RadarEntry(value: char.networkScore),
                RadarEntry(value: (char.financeScore / 2.5).clamp(0, 100)), // scale down finance to fit 0-100 chart range
                RadarEntry(value: char.wellBeingScore),
              ],
            ),
          ],
          radarShape: RadarShape.circle,
          radarBorderData: const BorderSide(color: AppColors.glassBorder, width: 1),
          gridBorderData: const BorderSide(color: AppColors.glassBorder, width: 1),
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          titlePositionPercentageOffset: 0.18,
          getTitle: (index, angle) {
            final titles = ['Chuyên môn', 'Kỹ năng', 'Quan hệ', 'Tài chính', 'Sức khỏe'];
            return RadarChartTitle(text: titles[index], angle: angle);
          },
          titleTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // --- EVENT WEIGHT BADGE ---
  Widget _buildWeightBadge(DecisionWeight weight) {
    String label = '';
    Color color = AppColors.neonCyan;

    switch (weight) {
      case DecisionWeight.small:
        label = 'Quyết định nhỏ';
        color = AppColors.neonCyan;
        break;
      case DecisionWeight.medium:
        label = 'Quyết định vừa';
        color = AppColors.neonGold;
        break;
      case DecisionWeight.turningPoint:
        label = 'BƯỚC NGOẶT LỚN';
        color = AppColors.neonPink;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 1),
      ),
    );
  }

  // --- LOG BOTTOM SHEET ---
  void _showLogBottomSheet(BuildContext context, List<String> logs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C0B12),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nhật ký sự nghiệp đầy đủ',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(color: AppColors.glassBorder),
              Expanded(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final reversedLog = logs.reversed.toList()[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 8, color: AppColors.neonViolet),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reversedLog,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- REAL ROADMAP BOTTOM SHEET ---
  void _showRealRoadmapBottomSheet(BuildContext context, String archetypeKey) {
    String content = '';
    
    if (archetypeKey == 'sage') {
      content = '📚 CHUYÊN MÔN: KHOA HỌC DỮ LIỆU, TRÍ TUỆ NHÂN TẠO\n\n'
          '1. Các khóa học nền tảng đề xuất:\n'
          ' - Google Data Analytics Certificate (Coursera)\n'
          ' - Machine Learning Specialization by Andrew Ng\n'
          ' - CS50 Harvard (Tư duy lập trình khoa học máy tính)\n\n'
          '2. Lộ trình phát triển tại Việt Nam:\n'
          ' - Tốt nghiệp ngành CNTT/Toán-tin tại Bách Khoa, KHTN hoặc Công nghệ.\n'
          ' - Tham gia làm trợ lý nghiên cứu tại các Lab của trường.\n'
          ' - Thực tập sinh AI/Data Analyst tại các tập đoàn công nghệ lớn (FPT, Viettel, VNG).';
    } else if (archetypeKey == 'creator') {
      content = '🎨 CHUYÊN MÔN: THIẾT KẾ ĐỒ HỌA, SÁNG TẠO NỘI DUNG\n\n'
          '1. Các khóa học đề xuất:\n'
          ' - Google UX Design Professional Certificate (Coursera)\n'
          ' - Graphic Design Specialization (CalArts)\n'
          ' - The Art of Storytelling (Pixar in a Box)\n\n'
          '2. Lộ trình phát triển tại Việt Nam:\n'
          ' - Xây dựng Portfolio thiết kế trên Behance/Dribbble từ sớm.\n'
          ' - Làm việc tự do (Freelance) qua dự án nhỏ để lấy kinh nghiệm.\n'
          ' - Gia nhập Agency quảng cáo lớn tại TP.HCM/Hà Nội.';
    } else if (archetypeKey == 'guardian') {
      content = '🛡️ CHUYÊN MÔN: TÀI CHÍNH, BẢO MẬT & QUẢN TRỊ\n\n'
          '1. Các khóa học đề xuất:\n'
          ' - Wharton Finance and Accounting Essentials (Coursera)\n'
          ' - Google Cybersecurity Professional Certificate\n'
          ' - Excel Skills for Business Specialization\n\n'
          '2. Lộ trình phát triển tại Việt Nam:\n'
          ' - Thi lấy chứng chỉ nghề nghiệp quốc tế (ACCA cho kế toán, CFA cho tài chính).\n'
          ' - Ứng tuyển chương trình Management Trainee của các ngân hàng thương mại lớn.';
    } else if (archetypeKey == 'influencer') {
      content = '🗣️ CHUYÊN MÔN: MARKETING, PHÁT TRIỂN KINH DOANH\n\n'
          '1. Các khóa học đề xuất:\n'
          ' - Brand Management (London Business School)\n'
          ' - Successful Negotiation (University of Michigan)\n'
          ' - Google Project Management Certificate\n\n'
          '2. Lộ trình phát triển tại Việt Nam:\n'
          ' - Hoạt động tích cực trong câu lạc bộ tranh biện, thuyết trình thời sinh viên.\n'
          ' - Thực tập tại các Agency/Brand lớn ở vị trí Account Executive hoặc Growth Hacker.';
    } else {
      content = '🛠️ CHUYÊN MÔN: LẬP TRÌNH DI ĐỘNG, IoT & PHẦN MỀM\n\n'
          '1. Các khóa học đề xuất:\n'
          ' - Meta Mobile Developer Certificate (React Native / Flutter)\n'
          ' - CS50 Harvard (Tư duy khoa học máy tính)\n'
          ' - Lập trình di động Flutter nâng cao từ cộng đồng\n\n'
          '2. Lộ trình phát triển tại Việt Nam:\n'
          ' - Tự thực hiện 2-3 dự án nhỏ đưa lên Github cá nhân.\n'
          ' - Ứng tuyển làm Intern/Fresher tại các công ty gia công phần mềm hàng đầu Việt Nam.';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F18),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(22.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lộ trình học tập thực tế ngoài đời',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.glassBorder),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
