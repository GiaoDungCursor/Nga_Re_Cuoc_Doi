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
      'question': '1. Trong một dự án nhóm ở lớp, bạn thường thích đảm nhận vai trò nào nhất?',
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
        {'text': 'Đọc kỹ tài liệu kỹ thuật và tìm hiểu cơ chế hoạt động bên trong.', 'type': 'sage'},
        {'text': 'Khám phá giao diện, màu sắc và độ mượt mà của hiệu ứng.', 'type': 'creator'},
        {'text': 'Kiểm tra tính an toàn, bảo mật dữ liệu và độ tin cậy.', 'type': 'guardian'},
        {'text': 'Chia sẻ ngay với bạn bè và hỏi xem có ai muốn dùng thử không.', 'type': 'influencer'},
        {'text': 'Bắt đầu tháo rời ra hoặc tự tay vọc vạch sửa đổi cấu hình ngay.', 'type': 'builder'}
      ]
    },
    {
      'question': '3. Môn học mà bạn cảm thấy tự tin hoặc thích thú nhất khi còn đi học?',
      'options': [
        {'text': 'Toán học, Vật lý (các môn lý luận logic & tính toán).', 'type': 'sage'},
        {'text': 'Ngữ văn, Mỹ thuật, Âm nhạc (các môn nghệ thuật & bay bổng).', 'type': 'creator'},
        {'text': 'Lịch sử, Giáo dục công dân (các môn quy tắc & hệ thống).', 'type': 'guardian'},
        {'text': 'Ngoại ngữ, Hoạt động ngoại khóa (các môn giao tiếp).', 'type': 'influencer'},
        {'text': 'Tin học thực hành, Công nghệ kỹ thuật.', 'type': 'builder'}
      ]
    },
    {
      'question': '4. Môi trường làm việc lý tưởng trong tương lai của bạn trông như thế nào?',
      'options': [
        {'text': 'Một phòng làm việc tĩnh lặng để tập trung tối đa suy nghĩ.', 'type': 'sage'},
        {'text': 'Một studio tràn ngập ánh sáng, nghệ thuật và sự tự do.', 'type': 'creator'},
        {'text': 'Một công ty lớn, quy củ, giờ giấc ổn định, lộ trình thăng tiến rõ ràng.', 'type': 'guardian'},
        {'text': 'Một không gian mở náo nhiệt, thường xuyên đi gặp gỡ đối tác.', 'type': 'influencer'},
        {'text': 'Một phòng lab công nghệ, xưởng chế tạo hoặc chỗ đầy rẫy máy móc.', 'type': 'builder'}
      ]
    },
    {
      'question': '5. Khi đối mặt với một đoạn code bị lỗi (Bug) cực kỳ khó chịu, bạn sẽ phản ứng thế nào?',
      'options': [
        {'text': 'Mở log ra phân tích từng dòng để tìm ra nguyên nhân gốc rễ.', 'type': 'sage'},
        {'text': 'Nghĩ cách thiết kế lại toàn bộ luồng chức năng đó cho mượt hơn.', 'type': 'creator'},
        {'text': 'Kiểm tra lại tài liệu đặc tả và các test case để xem sai ở đâu.', 'type': 'guardian'},
        {'text': 'Hỏi ngay trên nhóm chat hoặc stackoverflow để tìm người giúp.', 'type': 'influencer'},
        {'text': 'Thử thay đổi code liên tục (trial-and-error) đến khi nào chạy được thì thôi.', 'type': 'builder'}
      ]
    },
    {
      'question': '6. Điểm yếu lớn nhất mà bạn tự nhận thấy ở bản thân là gì?',
      'options': [
        {'text': 'Đôi khi quá lý trí, xa rời cảm xúc thực tế của mọi người.', 'type': 'sage'},
        {'text': 'Cảm xúc thất thường, dễ mất cảm hứng làm việc khi chán.', 'type': 'creator'},
        {'text': 'Ngại thay đổi đột ngột, có xu hướng an toàn quá mức.', 'type': 'guardian'},
        {'text': 'Dễ bị phân tâm bởi nhiều thứ, đôi khi hứa hẹn nhưng quên làm.', 'type': 'influencer'},
        {'text': 'Quá sa đà vào chi tiết kỹ thuật mà quên mất bức tranh tổng thể.', 'type': 'builder'}
      ]
    },
    {
      'question': '7. Bạn thường dành ngày nghỉ cuối tuần rảnh rỗi để làm gì?',
      'options': [
        {'text': 'Đọc sách chuyên ngành, nghiên cứu một công nghệ/lý thuyết mới.', 'type': 'sage'},
        {'text': 'Vẽ vời, làm đồ handmade, chụp ảnh hoặc xem phim nghệ thuật.', 'type': 'creator'},
        {'text': 'Dọn dẹp nhà cửa, sắp xếp lại chi tiêu và lên kế hoạch tuần tới.', 'type': 'guardian'},
        {'text': 'Tụ tập bạn bè, đi cafe trò chuyện hoặc tham gia các sự kiện xã hội.', 'type': 'influencer'},
        {'text': 'Code một dự án cá nhân (pet project) hoặc sửa chữa đồ đạc trong nhà.', 'type': 'builder'}
      ]
    },
    {
      'question': '8. Cách học hiệu quả nhất đối với bạn khi tiếp cận một công nghệ mới là:',
      'options': [
        {'text': 'Đọc tài liệu chuẩn (Whitepaper/Documentation) từ nhà phát triển.', 'type': 'sage'},
        {'text': 'Xem các video hướng dẫn có hình ảnh minh họa sinh động.', 'type': 'creator'},
        {'text': 'Tham gia các khóa học có cấu trúc bài bản, cấp chứng chỉ rõ ràng.', 'type': 'guardian'},
        {'text': 'Học thông qua thảo luận với bạn bè hoặc mentor trong ngành.', 'type': 'influencer'},
        {'text': 'Tải code mẫu về chạy thử, phá thử rồi tự rút ra bài học.', 'type': 'builder'}
      ]
    },
    {
      'question': '9. Khi đối mặt với một dự án bị trễ deadline trầm trọng, bạn chọn giải pháp nào?',
      'options': [
        {'text': 'Phân tích lại thuật toán xem có thể tối ưu hiệu suất ở đâu không.', 'type': 'sage'},
        {'text': 'Cắt giảm bớt tính năng phụ nhưng vẫn đảm bảo giao diện đẹp và mượt.', 'type': 'creator'},
        {'text': 'Lập bảng tiến độ khắt khe từng giờ và yêu cầu team tuân thủ tuyệt đối.', 'type': 'guardian'},
        {'text': 'Động viên tinh thần cả team và đàm phán xin thêm thời gian từ sếp.', 'type': 'influencer'},
        {'text': 'Mua nước tăng lực, thức trắng đêm code liên tục để hoàn thành.', 'type': 'builder'}
      ]
    },
    {
      'question': '10. Nếu bạn được trao quyền tạo ra một ứng dụng triệu view, nó sẽ là:',
      'options': [
        {'text': 'Một hệ thống phân tích dữ liệu AI siêu thông minh.', 'type': 'sage'},
        {'text': 'Một công cụ vẽ hoặc ứng dụng chỉnh sửa ảnh/video nghệ thuật.', 'type': 'creator'},
        {'text': 'Một ứng dụng quản lý bảo mật cá nhân và tài chính an toàn.', 'type': 'guardian'},
        {'text': 'Một mạng xã hội mới kết nối mọi người qua sở thích độc đáo.', 'type': 'influencer'},
        {'text': 'Một công cụ tiện ích hoặc game hành động với cơ chế phức tạp.', 'type': 'builder'}
      ]
    },
    {
      'question': '11. Khi nhận được lời khen về công việc, bạn thích được khen về khía cạnh nào nhất?',
      'options': [
        {'text': '"Giải pháp logic của bạn thực sự thông minh và đột phá!"', 'type': 'sage'},
        {'text': '"Thiết kế của bạn trông quá tuyệt vời và đầy tính thẩm mỹ!"', 'type': 'creator'},
        {'text': '"Nhờ bạn mà dự án chạy vô cùng ổn định và đúng tiến độ!"', 'type': 'guardian'},
        {'text': '"Bạn thuyết trình hay quá, ai cũng bị thuyết phục!"', 'type': 'influencer'},
        {'text': '"Code của bạn chạy nhanh thật, tính năng nào cũng hoạt động hoàn hảo!"', 'type': 'builder'}
      ]
    },
    {
      'question': '12. Bàn làm việc hiện tại của bạn trông như thế nào?',
      'options': [
        {'text': 'Tối giản, chỉ có máy tính và sổ tay, không có đồ vật thừa.', 'type': 'sage'},
        {'text': 'Nhiều màu sắc, có cây cảnh, đồ trang trí hoặc mô hình anime.', 'type': 'creator'},
        {'text': 'Gọn gàng, tài liệu được dán nhãn phân loại ngăn nắp.', 'type': 'guardian'},
        {'text': 'Hơi bừa bộn một chút, có dán nhiều ảnh kỷ niệm với bạn bè.', 'type': 'influencer'},
        {'text': 'Đầy rẫy dây cáp, 2-3 màn hình lớn và các linh kiện điện tử.', 'type': 'builder'}
      ]
    },
    {
      'question': '13. Nếu có một siêu năng lực, bạn muốn chọn khả năng nào?',
      'options': [
        {'text': 'Khả năng hấp thụ kiến thức vô hạn và giải mã mọi bí ẩn.', 'type': 'sage'},
        {'text': 'Khả năng bẻ cong thực tại theo trí tưởng tượng của mình.', 'type': 'creator'},
        {'text': 'Khả năng nhìn thấy trước rủi ro và bảo vệ mọi người tuyệt đối.', 'type': 'guardian'},
        {'text': 'Khả năng thấu hiểu suy nghĩ và thuyết phục bất kỳ ai.', 'type': 'influencer'},
        {'text': 'Khả năng điều khiển máy móc và tự tay lắp ráp bất cứ thứ gì trong chớp mắt.', 'type': 'builder'}
      ]
    },
    {
      'question': '14. Điều gì trong công việc khiến bạn cảm thấy bực mình nhất?',
      'options': [
        {'text': 'Phải làm việc với những quy trình phi logic, thiếu cơ sở khoa học.', 'type': 'sage'},
        {'text': 'Bị gò bó sự tự do sáng tạo, phải làm theo các khuôn mẫu xấu xí.', 'type': 'creator'},
        {'text': 'Sự thay đổi kế hoạch xoành xoạch, thiếu tổ chức và vô kỷ luật.', 'type': 'guardian'},
        {'text': 'Bị cô lập, phải làm việc một mình không được giao tiếp với ai.', 'type': 'influencer'},
        {'text': 'Mạng internet chậm, máy tính lag hoặc các công cụ bị lỗi liên tục.', 'type': 'builder'}
      ]
    },
    {
      'question': '15. Thể loại game bạn yêu thích nhất (hoặc sẽ chơi nếu có thời gian) là gì?',
      'options': [
        {'text': 'Game chiến thuật, giải đố logic hóc búa (vd: Portal, Civilization).', 'type': 'sage'},
        {'text': 'Game có cốt truyện sâu sắc, đồ họa nghệ thuật đẹp mắt (vd: Journey, Ori).', 'type': 'creator'},
        {'text': 'Game mô phỏng quản lý, xây dựng thành phố (vd: Cities: Skylines, The Sims).', 'type': 'guardian'},
        {'text': 'Game online nhiều người chơi, tương tác đồng đội (vd: Liên minh, Valorant).', 'type': 'influencer'},
        {'text': 'Game sinh tồn, chế tạo đồ đạc hoặc hành động nhịp độ cao (vd: Minecraft, Doom).', 'type': 'builder'}
      ]
    },
    {
      'question': '16. Khi quyết định mua một chiếc Laptop/PC mới, tiêu chí quan trọng nhất là:',
      'options': [
        {'text': 'Thông số kỹ thuật CPU, RAM phải cực mạnh để xử lý dữ liệu.', 'type': 'sage'},
        {'text': 'Màn hình hiển thị màu sắc chuẩn xác, thiết kế máy mỏng nhẹ tinh tế.', 'type': 'creator'},
        {'text': 'Thương hiệu uy tín, chế độ bảo hành dài hạn và máy có độ bền cao.', 'type': 'guardian'},
        {'text': 'Máy thiết kế bắt mắt, là thương hiệu nổi tiếng để tự tin khi ra quán cafe.', 'type': 'influencer'},
        {'text': 'Nhiều cổng kết nối, dễ dàng nâng cấp RAM/Ổ cứng và tản nhiệt tốt.', 'type': 'builder'}
      ]
    },
    {
      'question': '17. Trong các cuộc họp nhóm, phong cách giao tiếp của bạn thường là:',
      'options': [
        {'text': 'Ngắn gọn, súc tích, chỉ nói khi có dữ kiện chứng minh rõ ràng.', 'type': 'sage'},
        {'text': 'Thường xuyên đưa ra các ý tưởng bay bổng, đôi khi hơi lan man.', 'type': 'creator'},
        {'text': 'Ghi chép cẩn thận, nhắc nhở mọi người tập trung vào Agenda chính.', 'type': 'guardian'},
        {'text': 'Hoạt ngôn, khuấy động không khí và dẫn dắt câu chuyện.', 'type': 'influencer'},
        {'text': '"Đừng nói nữa, mở code/màn hình lên cho tôi xem trực tiếp đi!"', 'type': 'builder'}
      ]
    },
    {
      'question': '18. Cách bạn đối mặt và xử lý sự thất bại trong một dự án quan trọng?',
      'options': [
        {'text': 'Làm một bảng phân tích chi tiết (post-mortem) lý do tại sao lại hỏng.', 'type': 'sage'},
        {'text': 'Cảm thấy buồn một chút, sau đó dùng cảm xúc đó làm chất liệu sáng tác.', 'type': 'creator'},
        {'text': 'Lập tức xây dựng phương án dự phòng (Plan B) để giảm thiểu thiệt hại.', 'type': 'guardian'},
        {'text': 'Tìm một người bạn đáng tin cậy để tâm sự xả stress và lấy lại tinh thần.', 'type': 'influencer'},
        {'text': 'Bỏ qua nó, bắt tay ngay vào việc làm lại từ đầu hoặc làm dự án mới.', 'type': 'builder'}
      ]
    },
    {
      'question': '19. Nếu một ngày bạn trở thành quản lý, phong cách lãnh đạo của bạn sẽ là:',
      'options': [
        {'text': 'Đưa ra định hướng chiến lược bằng tầm nhìn sâu rộng, để nhân viên tự xử lý kỹ thuật.', 'type': 'sage'},
        {'text': 'Truyền cảm hứng sáng tạo, khuyến khích nhân viên phá vỡ mọi quy tắc.', 'type': 'creator'},
        {'text': 'Thiết lập quy trình rõ ràng, theo sát tiến độ và đảm bảo quyền lợi công bằng.', 'type': 'guardian'},
        {'text': 'Luôn lắng nghe, thấu hiểu và tạo động lực tinh thần cho từng thành viên.', 'type': 'influencer'},
        {'text': 'Xắn tay áo xuống làm cùng anh em, dùng hành động thực tế để làm gương.', 'type': 'builder'}
      ]
    },
    {
      'question': '20. Đâu là mục tiêu lớn nhất trong sự nghiệp tương lai của bạn?',
      'options': [
        {'text': 'Tìm ra một đột phá công nghệ mới mang tính nền tảng, được ghi danh.', 'type': 'sage'},
        {'text': 'Tạo ra những sản phẩm để lại dấu ấn thẩm mỹ và nghệ thuật lâu dài.', 'type': 'creator'},
        {'text': 'Đạt được sự ổn định tài chính tuyệt đối và có một vị trí vững chãi an toàn.', 'type': 'guardian'},
        {'text': 'Trở thành người có tầm ảnh hưởng lớn, dẫn dắt xu hướng của cộng đồng.', 'type': 'influencer'},
        {'text': 'Xây dựng nên một ứng dụng/sản phẩm mà hàng triệu người dùng mỗi ngày.', 'type': 'builder'}
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
        resultArchetype: selectedArch, // Gợi ý hàng đầu
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
