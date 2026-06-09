import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Câu hỏi bối cảnh cá nhân (5 câu đầu) — lưu vào backgroundAnswers
/// Câu hỏi lớp nghề nghiệp (20 câu sau) — tính điểm archetype
const int kBackgroundQuestionCount = 5;

class QuizStateData {
  final int currentStep;
  final Map<String, int> scores;
  final String? resultArchetype;
  final bool isCompleted;
  final Map<String, String> backgroundAnswers; // Bối cảnh cá nhân

  QuizStateData({
    this.currentStep = 0,
    required this.scores,
    this.resultArchetype,
    this.isCompleted = false,
    this.backgroundAnswers = const {},
  });

  QuizStateData copyWith({
    int? currentStep,
    Map<String, int>? scores,
    String? resultArchetype,
    bool? isCompleted,
    Map<String, String>? backgroundAnswers,
  }) {
    return QuizStateData(
      currentStep: currentStep ?? this.currentStep,
      scores: scores ?? this.scores,
      resultArchetype: resultArchetype ?? this.resultArchetype,
      isCompleted: isCompleted ?? this.isCompleted,
      backgroundAnswers: backgroundAnswers ?? this.backgroundAnswers,
    );
  }

  bool get isInBackgroundPhase => currentStep < kBackgroundQuestionCount;
}

class QuizNotifier extends StateNotifier<QuizStateData> {
  QuizNotifier()
      : super(QuizStateData(scores: {
          'scientist': 0,
          'artist': 0,
          'leader': 0,
          'connector': 0,
          'executor': 0,
          'entrepreneur': 0,
          'explorer': 0,
        }));

  // ── PHẦN I: CÂU HỎI BỐI CẢNH CÁ NHÂN (5 câu) ──────────────────────────────
  // Kết quả lưu vào backgroundAnswers, KHÔNG tính vào điểm archetype
  // Mỗi câu có key riêng (ageBracket, educationLevel, studyField, currentStatus, monthlyIncome)
  static const List<Map<String, dynamic>> backgroundQuestions = [
    {
      'key': 'ageBracket',
      'question': 'Bạn đang ở độ tuổi nào?',
      'subtitle': 'Thông tin này giúp chúng tôi cá nhân hóa lộ trình mô phỏng phù hợp với giai đoạn sống của bạn.',
      'options': [
        {'text': '15 – 18 tuổi (Học sinh THPT, sắp bước vào ngưỡng cửa đại học)', 'value': 'age_teen'},
        {'text': '18 – 22 tuổi (Sinh viên đại học / cao đẳng)', 'value': 'age_student'},
        {'text': '22 – 26 tuổi (Mới ra trường, bước đầu xây dựng sự nghiệp)', 'value': 'age_junior'},
        {'text': '26 – 30 tuổi (Có kinh nghiệm, đang tăng tốc)', 'value': 'age_mid'},
        {'text': 'Trên 30 tuổi (Dày dặn kinh nghiệm, đang định hướng lại)', 'value': 'age_senior'},
      ]
    },
    {
      'key': 'educationLevel',
      'question': 'Trình độ học vấn hiện tại của bạn là gì?',
      'subtitle': 'Học vấn ảnh hưởng đến điểm Kỹ năng và Cơ hội nghề nghiệp khởi đầu.',
      'options': [
        {'text': 'Đang học THPT (Chưa tốt nghiệp cấp 3)', 'value': 'edu_highschool'},
        {'text': 'Học nghề / Trung cấp nghề (Kỹ thuật hoặc dịch vụ)', 'value': 'edu_vocational'},
        {'text': 'Đang theo học Cao đẳng / Đại học', 'value': 'edu_studying'},
        {'text': 'Đã tốt nghiệp Cao đẳng / Đại học', 'value': 'edu_graduated'},
        {'text': 'Thạc sĩ, Tiến sĩ hoặc chứng chỉ chuyên nghiệp quốc tế', 'value': 'edu_postgrad'},
      ]
    },
    {
      'key': 'studyField',
      'question': 'Bạn đang học tập hoặc làm việc trong lĩnh vực nào?',
      'subtitle': 'Lĩnh vực này sẽ xác định bối cảnh các sự kiện trong lộ trình mô phỏng của bạn.',
      'options': [
        {'text': '⚙️ Kỹ thuật & Công nghệ (IT, Điện, Cơ khí, Xây dựng, Môi trường)', 'value': 'field_tech'},
        {'text': '💼 Kinh tế, Tài chính & Kinh doanh (Kế toán, Marketing, BĐS, Ngân hàng)', 'value': 'field_business'},
        {'text': '🏥 Y tế, Dược & Khoa học sức khỏe (Bác sĩ, Y tá, Dược sĩ, Tâm lý)', 'value': 'field_health'},
        {'text': '🎨 Nghệ thuật, Thiết kế & Truyền thông (Báo chí, Phim ảnh, Âm nhạc, Hội họa)', 'value': 'field_arts'},
        {'text': '📚 Khoa học Xã hội, Nhân văn & Giáo dục (Sư phạm, Luật, Xã hội học)', 'value': 'field_social'},
        {'text': '🌾 Nông - Lâm - Ngư nghiệp, Thực phẩm & Môi trường', 'value': 'field_agri'},
        {'text': '⚖️ Pháp lý, Chính trị & Quản lý nhà nước (Luật, Hành chính, Ngoại giao)', 'value': 'field_law'},
        {'text': '❓ Chưa xác định / Đang tìm kiếm định hướng phù hợp', 'value': 'field_unknown'},
      ]
    },
    {
      'key': 'currentStatus',
      'question': 'Tình trạng hiện tại của bạn là gì?',
      'subtitle': 'Tình trạng này ảnh hưởng đến điểm Thời gian và Năng lượng khởi đầu của bạn.',
      'options': [
        {'text': '🎓 Đang đi học toàn thời gian (Chưa đi làm)', 'value': 'status_studying'},
        {'text': '💼 Đang đi làm toàn thời gian (Không học thêm)', 'value': 'status_working'},
        {'text': '⚡ Vừa đi học vừa đi làm (Part-time hoặc freelance)', 'value': 'status_both'},
        {'text': '🔍 Đang tìm việc / Vừa nghỉ việc / Mới thất nghiệp', 'value': 'status_seeking'},
        {'text': '🌱 Nghỉ ngơi / Gap year / Đang định hướng lại cuộc đời', 'value': 'status_gap'},
      ]
    },
    {
      'key': 'monthlyIncome',
      'question': 'Thu nhập (hoặc học bổng) hàng tháng của bạn hiện tại khoảng bao nhiêu?',
      'subtitle': 'Thu nhập này sẽ ảnh hưởng đến số tiền mặt khởi điểm trong mô phỏng.',
      'options': [
        {'text': '🈚 Chưa có thu nhập (Phụ thuộc gia đình hoặc học bổng)', 'value': 'income_zero'},
        {'text': '💵 Dưới 5 triệu VNĐ / tháng (Làm thêm, lương tập sự)', 'value': 'income_low'},
        {'text': '💵💵 Từ 5 – 15 triệu VNĐ / tháng (Nhân viên cơ bản)', 'value': 'income_mid'},
        {'text': '💰 Từ 15 – 30 triệu VNĐ / tháng (Có kinh nghiệm)', 'value': 'income_high'},
        {'text': '🏆 Trên 30 triệu VNĐ / tháng (Senior hoặc tự kinh doanh)', 'value': 'income_very_high'},
      ]
    },
  ];

  // ── PHẦN II: CÂU HỎI LỚP NGHỀ NGHIỆP (20 câu) ──────────────────────────────
  static const List<Map<String, dynamic>> archetypeQuestions = [
    {
      'question': '6. Khi đối mặt với một vấn đề phức tạp, bước đầu tiên bạn làm là gì?',
      'options': [
        {'text': 'Thu thập dữ liệu, đặt giả thuyết và kiểm chứng từng bước một.', 'type': 'scientist'},
        {'text': 'Vẽ ra, sơ đồ hóa hoặc hình dung vấn đề theo cách riêng của mình.', 'type': 'artist'},
        {'text': 'Xác định ai đang nắm quyền quyết định rồi thuyết phục họ ngay.', 'type': 'leader'},
        {'text': 'Hỏi ý kiến những người xung quanh để hiểu cảm nhận của mọi người.', 'type': 'connector'},
        {'text': 'Xắn tay áo thử ngay một giải pháp, sai thì sửa tiếp.', 'type': 'executor'},
        {'text': 'Tìm kiếm ngay xem đây có phải cơ hội kinh doanh tiềm năng không.', 'type': 'entrepreneur'},
        {'text': 'Chấp nhận sự không chắc chắn và xem đây như một thách thức thú vị.', 'type': 'explorer'},
      ]
    },
    {
      'question': '7. Nếu được trao một năm tự do hoàn toàn (có lương, không cần đi làm), bạn sẽ làm gì?',
      'options': [
        {'text': 'Nghiên cứu một lĩnh vực khoa học mà mình luôn tò mò.', 'type': 'scientist'},
        {'text': 'Viết tiểu thuyết, làm phim, hoặc hoàn thiện một tác phẩm nghệ thuật.', 'type': 'artist'},
        {'text': 'Du học, kết nối với các nhà lãnh đạo thế giới, xây dựng danh tiếng.', 'type': 'leader'},
        {'text': 'Đi tình nguyện, giúp đỡ cộng đồng hoặc dạy học ở vùng sâu.', 'type': 'connector'},
        {'text': 'Xây nhà, tu sửa xe, hoặc hoàn thiện một dự án cá nhân thực tế.', 'type': 'executor'},
        {'text': 'Khởi nghiệp một dự án kinh doanh từ 0 mà mình đã ấp ủ lâu nay.', 'type': 'entrepreneur'},
        {'text': 'Đi du lịch đến những nơi ít người đặt chân đến nhất trên thế giới.', 'type': 'explorer'},
      ]
    },
    {
      'question': '8. Hoạt động nào dưới đây mang lại cho bạn sự thỏa mãn sâu sắc nhất?',
      'options': [
        {'text': 'Giải xong một bài toán hóc búa hoặc tìm ra một quy luật chưa ai khám phá.', 'type': 'scientist'},
        {'text': 'Hoàn thành một tác phẩm và được người khác cảm nhận cảm xúc trong đó.', 'type': 'artist'},
        {'text': 'Dẫn dắt một nhóm đạt được mục tiêu mà lúc đầu ai cũng cho là bất khả thi.', 'type': 'leader'},
        {'text': 'Giúp ai đó vượt qua một giai đoạn khó khăn trong cuộc đời họ.', 'type': 'connector'},
        {'text': 'Nhìn thấy sản phẩm/công trình do mình tạo ra hoạt động hoàn hảo.', 'type': 'executor'},
        {'text': 'Ký kết hợp đồng đầu tiên hoặc bán được sản phẩm cho khách đầu tiên.', 'type': 'entrepreneur'},
        {'text': 'Đặt chân đến một vùng đất, văn hóa hoặc lĩnh vực hoàn toàn xa lạ.', 'type': 'explorer'},
      ]
    },
    {
      'question': '9. Bạn thường được bạn bè hoặc đồng nghiệp nhờ vả điều gì nhiều nhất?',
      'options': [
        {'text': 'Giải thích những khái niệm khó hoặc giúp phân tích số liệu.', 'type': 'scientist'},
        {'text': 'Góp ý về thiết kế, nội dung hoặc cách trình bày một thứ gì đó.', 'type': 'artist'},
        {'text': 'Lắng nghe và đưa ra quyết định khi mọi người không đồng ý với nhau.', 'type': 'leader'},
        {'text': 'Lắng nghe tâm sự, hòa giải mâu thuẫn hoặc kết nối họ với người phù hợp.', 'type': 'connector'},
        {'text': 'Sửa chữa đồ đạc, cài đặt thiết bị, hay giải quyết vấn đề thực tế ngay tại chỗ.', 'type': 'executor'},
        {'text': 'Cho lời khuyên về kinh doanh, mua bán, đầu tư hoặc khởi nghiệp.', 'type': 'entrepreneur'},
        {'text': 'Gợi ý địa điểm du lịch, hoạt động mới lạ hoặc những trải nghiệm độc đáo.', 'type': 'explorer'},
      ]
    },
    {
      'question': '10. Điểm mạnh lớn nhất của bạn trong công việc là gì?',
      'options': [
        {'text': 'Khả năng phân tích và tư duy logic chặt chẽ.', 'type': 'scientist'},
        {'text': 'Trí tưởng tượng phong phú và góc nhìn thẩm mỹ tinh tế.', 'type': 'artist'},
        {'text': 'Khả năng ra quyết định dưới áp lực và truyền cảm hứng cho người khác.', 'type': 'leader'},
        {'text': 'Sự đồng cảm sâu sắc và khả năng xây dựng lòng tin.', 'type': 'connector'},
        {'text': 'Tốc độ thực thi và khả năng hoàn thành công việc cụ thể.', 'type': 'executor'},
        {'text': 'Nhạy bén với thị trường và dám chấp nhận rủi ro có tính toán.', 'type': 'entrepreneur'},
        {'text': 'Khả năng thích nghi nhanh và học hỏi trong môi trường hoàn toàn mới.', 'type': 'explorer'},
      ]
    },
    {
      'question': '11. Điểm yếu nào dưới đây bạn tự nhận thấy rõ nhất ở mình?',
      'options': [
        {'text': 'Đôi khi quá lý trí, bỏ qua yếu tố cảm xúc của con người.', 'type': 'scientist'},
        {'text': 'Hay dao động cảm xúc, khó duy trì kỷ luật và sự ổn định lâu dài.', 'type': 'artist'},
        {'text': 'Đôi khi quá tự tin, khó lắng nghe và thừa nhận sai lầm.', 'type': 'leader'},
        {'text': 'Quá quan tâm đến người khác, đôi khi quên mất lợi ích của bản thân.', 'type': 'connector'},
        {'text': 'Hay bỏ qua tầm nhìn dài hạn vì quá tập trung vào công việc trước mắt.', 'type': 'executor'},
        {'text': 'Thiếu kiên nhẫn với quy trình chậm chạp và hay bỏ dở để bắt đầu cái mới.', 'type': 'entrepreneur'},
        {'text': 'Khó gắn bó lâu dài với một nơi, một công việc hay một thói quen.', 'type': 'explorer'},
      ]
    },
    {
      'question': '12. Với bạn, "thành công" có nghĩa là gì?',
      'options': [
        {'text': 'Được công nhận đóng góp cho sự tiến bộ của nhân loại.', 'type': 'scientist'},
        {'text': 'Tác phẩm của mình còn được nhắc đến sau khi mình đã mất.', 'type': 'artist'},
        {'text': 'Nắm giữ vị trí quyền lực và tạo ra sự thay đổi ở tầm vĩ mô.', 'type': 'leader'},
        {'text': 'Được những người xung quanh tin tưởng và thực sự cần đến mình.', 'type': 'connector'},
        {'text': 'Tạo ra được thứ gì đó chắc chắn, bền vững và có giá trị sử dụng thực tế.', 'type': 'executor'},
        {'text': 'Đạt được tự do tài chính và tự mình làm chủ cuộc sống.', 'type': 'entrepreneur'},
        {'text': 'Sống trọn vẹn và không bao giờ ngừng khám phá.', 'type': 'explorer'},
      ]
    },
    {
      'question': '13. Bạn vừa nhận được 500 triệu đồng. Bạn sẽ làm gì với số tiền đó?',
      'options': [
        {'text': 'Đầu tư vào học bổng, khóa học hoặc thiết bị nghiên cứu chuyên sâu.', 'type': 'scientist'},
        {'text': 'Mở một studio nghệ thuật hoặc tài trợ cho một dự án sáng tạo lớn.', 'type': 'artist'},
        {'text': 'Xây dựng mạng lưới quan hệ và tham gia các diễn đàn lãnh đạo quốc tế.', 'type': 'leader'},
        {'text': 'Thành lập một tổ chức từ thiện hoặc trường học ở vùng khó khăn.', 'type': 'connector'},
        {'text': 'Mua đất, xây nhà, hoặc đầu tư vào trang thiết bị sản xuất cụ thể.', 'type': 'executor'},
        {'text': 'Đổ vào vốn kinh doanh hoặc đầu tư chứng khoán/bất động sản.', 'type': 'entrepreneur'},
        {'text': 'Lên kế hoạch một chuyến đi vòng quanh thế giới kéo dài nhiều tháng.', 'type': 'explorer'},
      ]
    },
    {
      'question': '14. Trong một cuộc tranh luận nhóm, bạn thường đóng vai trò nào?',
      'options': [
        {'text': 'Người đưa ra bằng chứng và dữ liệu để chứng minh quan điểm.', 'type': 'scientist'},
        {'text': 'Người đề xuất góc nhìn mới mẻ và đặt câu hỏi không ai nghĩ đến.', 'type': 'artist'},
        {'text': 'Người chốt kết luận, đưa ra quyết định và chịu trách nhiệm về nó.', 'type': 'leader'},
        {'text': 'Người hòa giải, giúp mọi người hiểu nhau và tránh xung đột leo thang.', 'type': 'connector'},
        {'text': 'Người bực mình với tranh luận dài dòng và muốn đi thẳng vào hành động.', 'type': 'executor'},
        {'text': 'Người liên tục hỏi "Vậy ai được lợi? Cơ hội ở đây là gì?"', 'type': 'entrepreneur'},
        {'text': 'Người lắng nghe tất cả, rút ra bài học rồi tự đi con đường của mình.', 'type': 'explorer'},
      ]
    },
    {
      'question': '15. Bạn mơ về cuộc sống lý tưởng khi 45 tuổi sẽ trông như thế nào?',
      'options': [
        {'text': 'Giảng dạy tại đại học danh tiếng, tiếp tục nghiên cứu và xuất bản sách.', 'type': 'scientist'},
        {'text': 'Sống trong một ngôi nhà đẹp, yên tĩnh, tập trung sáng tác toàn thời gian.', 'type': 'artist'},
        {'text': 'Giữ vị trí quan trọng trong chính phủ, tập đoàn lớn hoặc tổ chức quốc tế.', 'type': 'leader'},
        {'text': 'Có một gia đình ấm áp, sống trong cộng đồng gắn kết và được mọi người yêu quý.', 'type': 'connector'},
        {'text': 'Sở hữu một xưởng sản xuất, trang trại hoặc doanh nghiệp vận hành trơn tru.', 'type': 'executor'},
        {'text': 'Điều hành nhiều dự án song song, có đội ngũ nhân sự giỏi và tự do tài chính.', 'type': 'entrepreneur'},
        {'text': 'Vẫn đang trên đường, khám phá thử thách mới và sống không có lịch cố định.', 'type': 'explorer'},
      ]
    },
    {
      'question': '16. Phong cách làm việc nào phù hợp nhất với bạn?',
      'options': [
        {'text': 'Làm việc độc lập, tập trung sâu, ít bị làm phiền trong thời gian dài.', 'type': 'scientist'},
        {'text': 'Không gian sáng tạo tự do, giờ giấc linh hoạt, được thể hiện cá tính.', 'type': 'artist'},
        {'text': 'Phòng họp lớn, nhiều cuộc gặp gỡ, phát biểu và ra quyết định liên tục.', 'type': 'leader'},
        {'text': 'Tương tác trực tiếp với con người — bệnh nhân, học sinh, khách hàng...', 'type': 'connector'},
        {'text': 'Công xưởng, công trường, bếp, hoặc bất kỳ nơi nào làm ra sản phẩm vật chất.', 'type': 'executor'},
        {'text': 'Văn phòng nhỏ năng động, họp nhanh, thay đổi kế hoạch liên tục theo thị trường.', 'type': 'entrepreneur'},
        {'text': 'Remote, không gian ngoài trời, hoặc liên tục thay đổi địa điểm.', 'type': 'explorer'},
      ]
    },
    {
      'question': '17. Khi thấy một bất công xảy ra trước mắt, bạn thường làm gì?',
      'options': [
        {'text': 'Thu thập bằng chứng và viết báo cáo hoặc đề xuất giải pháp hệ thống.', 'type': 'scientist'},
        {'text': 'Dùng nghệ thuật — viết bài, vẽ tranh, làm phim — để phơi bày sự thật.', 'type': 'artist'},
        {'text': 'Lên tiếng công khai, vận động người khác và tìm cách thay đổi chính sách.', 'type': 'leader'},
        {'text': 'Trực tiếp hỗ trợ nạn nhân và lắng nghe câu chuyện của họ.', 'type': 'connector'},
        {'text': 'Hành động ngay: can thiệp hoặc sửa chữa tình huống bằng tay mình.', 'type': 'executor'},
        {'text': 'Xem đây là cơ hội để tạo ra một dịch vụ/sản phẩm giải quyết vấn đề đó.', 'type': 'entrepreneur'},
        {'text': 'Rời đi và tìm đến môi trường khác công bằng và lành mạnh hơn.', 'type': 'explorer'},
      ]
    },
    {
      'question': '18. Nghề nghiệp nào dưới đây hấp dẫn bạn NHẤT dù bạn chưa học về nó?',
      'options': [
        {'text': 'Bác sĩ phẫu thuật não, Nhà vật lý thiên văn, Kỹ sư hạt nhân.', 'type': 'scientist'},
        {'text': 'Đạo diễn điện ảnh, Nhà văn bestseller, Nghệ sĩ trình diễn quốc tế.', 'type': 'artist'},
        {'text': 'Nghị sĩ Quốc hội, CEO tập đoàn đa quốc gia, Đại sứ ngoại giao.', 'type': 'leader'},
        {'text': 'Bác sĩ tâm lý, Nhà xã hội học, Giáo viên trường làng.', 'type': 'connector'},
        {'text': 'Thợ mộc thủ công, Đầu bếp 5 sao, Kỹ sư xây dựng công trình lớn.', 'type': 'executor'},
        {'text': 'Nhà sáng lập startup, Nhà đầu tư thiên thần, Trader chứng khoán.', 'type': 'entrepreneur'},
        {'text': 'Phi công chiến đấu, Nhà leo núi chuyên nghiệp, Phóng viên chiến trường.', 'type': 'explorer'},
      ]
    },
    {
      'question': '19. Nếu phải chọn một di sản (legacy) để lại cho đời, bạn muốn đó là gì?',
      'options': [
        {'text': 'Một khám phá khoa học hoặc phát minh cải thiện chất lượng sống của nhân loại.', 'type': 'scientist'},
        {'text': 'Một tác phẩm nghệ thuật bất hủ — cuốn sách, bộ phim, bản nhạc.', 'type': 'artist'},
        {'text': 'Một chính sách, tổ chức hoặc phong trào thay đổi xã hội tích cực.', 'type': 'leader'},
        {'text': 'Thế hệ học trò xuất sắc hoặc cộng đồng mà mình đã giúp xây dựng.', 'type': 'connector'},
        {'text': 'Những công trình, sản phẩm vật chất vẫn còn tồn tại sau nhiều thế kỷ.', 'type': 'executor'},
        {'text': 'Một đế chế kinh doanh tạo ra hàng ngàn việc làm và cơ hội cho mọi người.', 'type': 'entrepreneur'},
        {'text': 'Những câu chuyện và bản đồ về những vùng đất chưa ai biết đến.', 'type': 'explorer'},
      ]
    },
    {
      'question': '20. Điều gì trong công việc khiến bạn bực mình nhất?',
      'options': [
        {'text': 'Phải làm việc với những quy trình phi logic, thiếu cơ sở khoa học.', 'type': 'scientist'},
        {'text': 'Bị ép phải tuân theo quy trình nhàm chán, không có chỗ cho sáng tạo.', 'type': 'artist'},
        {'text': 'Thiếu người có khả năng đưa ra quyết định dứt khoát và chịu trách nhiệm.', 'type': 'leader'},
        {'text': 'Văn hóa công ty lạnh lùng, không ai quan tâm đến phúc lợi của nhau.', 'type': 'connector'},
        {'text': 'Họp hành liên miên mà không có sản phẩm thực tế nào được tạo ra.', 'type': 'executor'},
        {'text': 'Bộ máy cồng kềnh, ra quyết định chậm chạp, không dám thử điều mới.', 'type': 'entrepreneur'},
        {'text': 'Gắn với một chỗ quá lâu mà không có gì mới mẻ hay thử thách.', 'type': 'explorer'},
      ]
    },
    {
      'question': '21. Khi nhìn vào tin tức thế giới, chủ đề nào bạn LUÔN dừng lại xem?',
      'options': [
        {'text': 'Các đột phá khoa học, y tế, vũ trụ hoặc biến đổi khí hậu.', 'type': 'scientist'},
        {'text': 'Lễ hội nghệ thuật, phim ảnh, âm nhạc hoặc văn hóa các nước.', 'type': 'artist'},
        {'text': 'Bầu cử, địa chính trị, xung đột quốc tế và các nhà lãnh đạo thế giới.', 'type': 'leader'},
        {'text': 'Câu chuyện con người — người vô gia cư, trẻ em khó khăn, chiến tranh.', 'type': 'connector'},
        {'text': 'Kinh tế, hạ tầng, xây dựng đô thị hoặc các công trình kỳ vĩ.', 'type': 'executor'},
        {'text': 'Startup tỷ đô, IPO, M&A hoặc xu hướng thị trường mới nổi.', 'type': 'entrepreneur'},
        {'text': 'Thiên tai, thám hiểm, kỷ lục thể thao hoặc phát hiện địa lý mới.', 'type': 'explorer'},
      ]
    },
    {
      'question': '22. Cách học hiệu quả nhất đối với bạn khi tiếp cận một chủ đề mới là:',
      'options': [
        {'text': 'Đọc sách, nghiên cứu tài liệu chuyên sâu và phân tích từng chi tiết.', 'type': 'scientist'},
        {'text': 'Xem video trực quan, nghe podcast và cảm nhận bằng trực giác.', 'type': 'artist'},
        {'text': 'Tham gia hội thảo, thảo luận với chuyên gia và quan sát người giỏi.', 'type': 'leader'},
        {'text': 'Học thông qua nhóm, chia sẻ kinh nghiệm với bạn bè và cộng đồng.', 'type': 'connector'},
        {'text': 'Tải xuống và tự tay làm thử ngay — học qua thực hành.', 'type': 'executor'},
        {'text': 'Tìm kiếm ngay xem có thể áp dụng kiếm tiền hay kinh doanh từ điều này không.', 'type': 'entrepreneur'},
        {'text': 'Thử nghiệm thực tế bằng cách trực tiếp trải nghiệm trong môi trường thực.', 'type': 'explorer'},
      ]
    },
    {
      'question': '23. Khi phải ra một quyết định khó, ảnh hưởng đến nhiều người, bạn dựa vào điều gì?',
      'options': [
        {'text': 'Dữ liệu, con số thống kê và phân tích rủi ro chi tiết.', 'type': 'scientist'},
        {'text': 'Cảm xúc và trực giác nghệ thuật — điều gì cảm thấy "đúng" nhất.', 'type': 'artist'},
        {'text': 'Tầm nhìn dài hạn và lợi ích của số đông.', 'type': 'leader'},
        {'text': 'Cảm nhận của các bên liên quan và tác động đến con người cụ thể.', 'type': 'connector'},
        {'text': 'Tính khả thi thực tế và nguồn lực hiện có để thực hiện.', 'type': 'executor'},
        {'text': 'ROI (lợi nhuận đầu tư) và cơ hội tăng trưởng.', 'type': 'entrepreneur'},
        {'text': 'Bản năng phiêu lưu và mức độ thú vị của thử thách.', 'type': 'explorer'},
      ]
    },
    {
      'question': '24. Nếu một ngày bạn trở thành quản lý, phong cách lãnh đạo của bạn sẽ là:',
      'options': [
        {'text': 'Đưa ra định hướng chiến lược bằng tầm nhìn sâu rộng, để nhân viên tự xử lý.', 'type': 'scientist'},
        {'text': 'Truyền cảm hứng sáng tạo, khuyến khích nhân viên phá vỡ mọi quy tắc.', 'type': 'artist'},
        {'text': 'Thiết lập quy trình rõ ràng, theo sát tiến độ và đảm bảo quyền lợi công bằng.', 'type': 'leader'},
        {'text': 'Luôn lắng nghe, thấu hiểu và tạo động lực tinh thần cho từng thành viên.', 'type': 'connector'},
        {'text': 'Xắn tay áo xuống làm cùng anh em, dùng hành động thực tế để làm gương.', 'type': 'executor'},
        {'text': 'Phân quyền triệt để, đo lường bằng KPI và thưởng mạnh cho kết quả tốt.', 'type': 'entrepreneur'},
        {'text': 'Để nhân viên tự do thử nghiệm, sai sửa — miễn là học hỏi được điều gì đó.', 'type': 'explorer'},
      ]
    },
    {
      'question': '25. Đâu là mục tiêu lớn nhất trong sự nghiệp tương lai của bạn?',
      'options': [
        {'text': 'Tìm ra một đột phá mang tính nền tảng, được ghi danh trong lịch sử khoa học.', 'type': 'scientist'},
        {'text': 'Tạo ra những tác phẩm để lại dấu ấn thẩm mỹ và nghệ thuật lâu dài.', 'type': 'artist'},
        {'text': 'Trở thành người có tầm ảnh hưởng lớn, dẫn dắt xu hướng của xã hội.', 'type': 'leader'},
        {'text': 'Xây dựng một cộng đồng hoặc tổ chức giúp đỡ hàng triệu người.', 'type': 'connector'},
        {'text': 'Hoàn thiện kỹ năng thực hành đến mức bậc thầy và được thừa nhận.', 'type': 'executor'},
        {'text': 'Xây dựng và nhân rộng một mô hình kinh doanh tác động đến xã hội.', 'type': 'entrepreneur'},
        {'text': 'Khám phá mọi ngóc ngách của thế giới và chia sẻ câu chuyện với đại chúng.', 'type': 'explorer'},
      ]
    },
  ];

  /// Tổng số câu hỏi = Background (5) + Archetype (20)
  static int get totalQuestions => kBackgroundQuestionCount + archetypeQuestions.length;

  void selectBackgroundOption(String key, String value) {
    final updatedAnswers = Map<String, String>.from(state.backgroundAnswers);
    updatedAnswers[key] = value;

    state = state.copyWith(
      currentStep: state.currentStep + 1,
      backgroundAnswers: updatedAnswers,
    );
  }

  void selectArchetypeOption(String archetypeType) {
    final updatedScores = Map<String, int>.from(state.scores);
    updatedScores[archetypeType] = (updatedScores[archetypeType] ?? 0) + 10;

    final archetypeStepIndex = state.currentStep - kBackgroundQuestionCount;
    if (archetypeStepIndex < archetypeQuestions.length - 1) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        scores: updatedScores,
      );
    } else {
      // Hoàn thành — tìm Archetype có điểm cao nhất
      String topArch = 'executor';
      int maxScore = -1;
      updatedScores.forEach((key, value) {
        if (value > maxScore) {
          maxScore = value;
          topArch = key;
        }
      });

      state = state.copyWith(
        scores: updatedScores,
        resultArchetype: topArch,
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
      scores: {
        'scientist': 0,
        'artist': 0,
        'leader': 0,
        'connector': 0,
        'executor': 0,
        'entrepreneur': 0,
        'explorer': 0,
      },
      isCompleted: false,
      resultArchetype: null,
      backgroundAnswers: {},
    );
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizStateData>((ref) {
  return QuizNotifier();
});
