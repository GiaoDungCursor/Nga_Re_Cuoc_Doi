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

    // Nếu đã hoàn thành khảo sát, tự động chuyển hướng sang trang kết quả DNA
    if (quizState.isCompleted && quizState.resultArchetype != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/career-dna');
      });
    }

    final currentQuestion = QuizNotifier.questions[quizState.currentStep];
    final questionText = currentQuestion['question'] as String;
    final options = currentQuestion['options'] as List<Map<String, String>>;
    final totalQuestions = QuizNotifier.questions.length;
    final progress = (quizState.currentStep + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Progress Indicator
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quizState.currentStep > 0) {
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
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${quizState.currentStep + 1}/$totalQuestions',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neonCyan,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // Question Card Area
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
                          Text(
                            questionText,
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Options List
                          Column(
                            children: options.map((opt) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: InkWell(
                                  onTap: () {
                                    quizNotifier.selectOption(opt['type']!);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.02),
                                      border: Border.all(color: AppColors.glassBorder),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            opt['text']!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textMuted,
                                          size: 20,
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
