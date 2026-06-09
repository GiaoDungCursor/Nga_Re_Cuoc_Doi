import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../state/quiz_state.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quizNotifier = ref.read(quizProvider.notifier);

    // Nếu đã hoàn thành khảo sát, chuyển hướng sang trang Career DNA
    if (quizState.isCompleted && quizState.resultArchetype != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/career-dna');
      });
    }

    final totalSteps = QuizNotifier.totalQuestions;
    final currentStep = quizState.currentStep;
    final progress = (currentStep + 1) / totalSteps;
    final isBackground = quizState.isInBackgroundPhase;

    // Lấy dữ liệu câu hỏi hiện tại
    final String questionText;
    final String? subtitle;
    final List<Map<String, String>> options;
    final String? bgKey;

    if (isBackground) {
      final q = QuizNotifier.backgroundQuestions[currentStep];
      questionText = q['question'] as String;
      subtitle = q['subtitle'] as String?;
      bgKey = q['key'] as String;
      options = (q['options'] as List)
          .map((o) => {'text': o['text'] as String, 'value': o['value'] as String})
          .toList();
    } else {
      final archetypeIndex = currentStep - kBackgroundQuestionCount;
      final q = QuizNotifier.archetypeQuestions[archetypeIndex];
      questionText = q['question'] as String;
      subtitle = null;
      bgKey = null;
      options = (q['options'] as List)
          .map((o) => {'text': o['text'] as String, 'value': o['type'] as String})
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header & Progress ──────────────────────────
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (currentStep > 0) {
                        quizNotifier.previousQuestion();
                      } else {
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 28),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isBackground ? AppColors.neonGold : AppColors.neonCyan,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${currentStep + 1}/$totalSteps',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isBackground ? AppColors.neonGold : AppColors.neonCyan,
                    ),
                  ),
                ],
              ),

              // ── Phase badge ───────────────────────────────
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isBackground
                        ? AppColors.neonGold.withOpacity(0.1)
                        : AppColors.neonCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBackground
                          ? AppColors.neonGold.withOpacity(0.3)
                          : AppColors.neonCyan.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    isBackground
                        ? 'PHẦN 1/2 — BỐI CẢNH CÁ NHÂN (${currentStep + 1}/$kBackgroundQuestionCount)'
                        : 'PHẦN 2/2 — LỚP NGHỀ NGHIỆP (${currentStep - kBackgroundQuestionCount + 1}/${QuizNotifier.archetypeQuestions.length})',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isBackground ? AppColors.neonGold : AppColors.neonCyan,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Question Card + Options ───────────────────
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.glassBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Câu hỏi
                          Text(
                            questionText,
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          // Mô tả phụ (chỉ có ở background questions)
                          if (subtitle != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Danh sách lựa chọn
                          Column(
                            children: options.map((opt) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: InkWell(
                                  onTap: () {
                                    if (isBackground && bgKey != null) {
                                      quizNotifier.selectBackgroundOption(bgKey, opt['value']!);
                                    } else {
                                      quizNotifier.selectArchetypeOption(opt['value']!);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.02),
                                      border: Border.all(color: AppColors.glassBorder),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            opt['text']!,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              color: AppColors.textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textMuted,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
