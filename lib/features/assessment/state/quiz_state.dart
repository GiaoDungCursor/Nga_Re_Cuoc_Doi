import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizStateData {
  final int currentStep;
  final Map<String, int> scores;
  final String? resultArchetype;
  final bool isCompleted;

  QuizStateData({
    this.currentStep = 0,
    required this.scores,
    this.resultArchetype,
    this.isCompleted = false,
  });

  QuizStateData copyWith({
    int? currentStep,
    Map<String, int>? scores,
    String? resultArchetype,
    bool? isCompleted,
  }) {
    return QuizStateData(
      currentStep: currentStep ?? this.currentStep,
      scores: scores ?? this.scores,
      resultArchetype: resultArchetype ?? this.resultArchetype,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizStateData> {
  QuizNotifier()
      : super(QuizStateData(scores: {
          'sage': 0,
          'creator': 0,
          'guardian': 0,
          'influencer': 0,
          'builder': 0
        }));

  static const List<Map<String, dynamic>> questions = [
    {
      'question': '1. Trong một dự án nhóm ở lớp học, bạn thường thích đảm nhận vai trò nào nhất?',
      'options': [
        {'text': 'Phân tích số liệu, lập luận logic và tìm giải pháp kỹ thuật.', 'type': 'sage'},
        {'text': 'Thiết kế slide, chuẩn bị hình ảnh và lên ý tưởng sáng tạo.', 'type': 'creator'},
        {'text': 'Lập kế hoạch chi tiết, theo dõi tiến độ và quản lý ngân sách.', 'type': 'guardian'},
        {'text': 'Thuyết trình trước lớp, đàm phán thuyết phục người nghe.', 'type': 'influencer'},
        {'text': 'Trực tiếp lắp ráp mô hình hoặc viết code/chạy chương trình.', 'type': 'builder'}
      ]
    },
    {
      'question': '2. Khi gặp một thiết bị hoặc một phần mềm mới, bạn sẽ làm gì đầu tiên?',
      'options': [
        {'text': 'Đọc kỹ hướng dẫn sử dụng và tìm hiểu cơ chế hoạt động bên trong.', 'type': 'sage'},
        {'text': 'Khám phá giao diện, các màu sắc và độ mượt mà của hiệu ứng.', 'type': 'creator'},
        {'text': 'Kiểm tra tính an toàn, bảo mật dữ liệu và độ bền của thiết bị.', 'type': 'guardian'},
        {'text': 'Chia sẻ ngay với bạn bè và hỏi xem có ai muốn dùng thử không.', 'type': 'influencer'},
        {'text': 'Bắt đầu tháo rời ra hoặc tự tay vọc vạch sửa đổi cấu hình.', 'type': 'builder'}
      ]
    },
    {
      'question': '3. Hãy chọn một môn học mà bạn cảm thấy tự tin hoặc thích thú nhất khi còn đi học:',
      'options': [
        {'text': 'Toán học, Vật lý hoặc Triết học (các môn lý luận logic).', 'type': 'sage'},
        {'text': 'Ngữ văn, Mỹ thuật, Âm nhạc (các môn nghệ thuật & bay bổng).', 'type': 'creator'},
        {'text': 'Lịch sử, Giáo dục công dân, Địa lý (các môn quy tắc & hệ thống).', 'type': 'guardian'},
        {'text': 'Ngoại ngữ, Kỹ năng mềm, Hoạt động ngoại khóa (các môn giao tiếp).', 'type': 'influencer'},
        {'text': 'Tin học văn phòng, Lập trình hoặc Công nghệ kỹ thuật.', 'type': 'builder'}
      ]
    },
    {
      'question': '4. Môi trường làm việc lý tưởng trong tương lai của bạn trông như thế nào?',
      'options': [
        {'text': 'Một phòng thí nghiệm tĩnh lặng hoặc một bàn làm việc yên tĩnh để tập trung.', 'type': 'sage'},
        {'text': 'Một studio tràn ngập ánh sáng, âm nhạc và những tác phẩm sáng tạo.', 'type': 'creator'},
        {'text': 'Một văn phòng công ty lớn, quy củ, giờ giấc ổn định, chế độ rõ ràng.', 'type': 'guardian'},
        {'text': 'Một không gian mở náo nhiệt, thường xuyên đi gặp gỡ khách hàng bên ngoài.', 'type': 'influencer'},
        {'text': 'Một xưởng chế tạo công nghệ, phòng máy chủ hoặc công trường thực địa.', 'type': 'builder'}
      ]
    },
    {
      'question': '5. Khi giải quyết một mâu thuẫn trong cuộc sống, bạn chọn cách nào?',
      'options': [
        {'text': 'Thu thập dữ kiện, phân tích đúng sai dựa trên bằng chứng cụ thể.', 'type': 'sage'},
        {'text': 'Tìm cách tiếp cận mới lạ, viết thư hoặc dùng nghệ thuật để giãi bày.', 'type': 'creator'},
        {'text': 'Bám sát các quy định chung, nội quy hoặc nhờ người có thẩm quyền giải quyết.', 'type': 'guardian'},
        {'text': 'Ngồi lại trò chuyện trực tiếp, lắng nghe cảm xúc để hòa giải mâu thuẫn.', 'type': 'influencer'},
        {'text': 'Xắn tay áo tìm giải pháp khắc phục vấn đề thực tế ngay lập tức.', 'type': 'builder'}
      ]
    },
    {
      'question': '6. Điểm yếu lớn nhất mà bạn tự nhận thấy ở bản thân là gì?',
      'options': [
        {'text': 'Đôi khi quá lý trí, xa rời cảm xúc thực tế của mọi người.', 'type': 'sage'},
        {'text': 'Cảm xúc thất thường, dễ mất cảm hứng làm việc khi chán.', 'type': 'creator'},
        {'text': 'Ngại thay đổi đột ngột, thích sự an toàn tuyệt đối.', 'type': 'guardian'},
        {'text': 'Dễ bị phân tâm, nói nhiều hơn làm.', 'type': 'influencer'},
        {'text': 'Đôi khi quá tập trung vào chi tiết kỹ thuật mà quên đi bức tranh toàn cảnh.', 'type': 'builder'}
      ]
    }
  ];

  void selectOption(String archetypeType) {
    final updatedScores = Map<String, int>.from(state.scores);
    updatedScores[archetypeType] = (updatedScores[archetypeType] ?? 0) + 10;

    if (state.currentStep < questions.length - 1) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        scores: updatedScores,
      );
    } else {
      // Đã hoàn thành câu hỏi cuối cùng
      String selectedArch = 'sage';
      int maxScore = -1;
      updatedScores.forEach((key, value) {
        if (value > maxScore) {
          maxScore = value;
          selectedArch = key;
        }
      });

      state = state.copyWith(
        scores: updatedScores,
        resultArchetype: selectedArch,
        isCompleted: true,
      );
    }
  }

  void previousQuestion() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void reset() {
    state = QuizStateData(
      currentStep: 0,
      scores: {'sage': 0, 'creator': 0, 'guardian': 0, 'influencer': 0, 'builder': 0},
      isCompleted: false,
      resultArchetype: null,
    );
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizStateData>((ref) {
  return QuizNotifier();
});
