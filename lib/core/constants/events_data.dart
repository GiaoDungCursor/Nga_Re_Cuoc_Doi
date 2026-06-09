import '../../shared/models/event.dart';

class EventsData {
  static final List<Event> allEvents = [
    // ==========================================================
    // 1. SMALL EVENT (Sự kiện nhỏ) - Học UI/UX năm 2027
    // ==========================================================
    const Event(
      id: 'short_course',
      title: 'Học Kỹ Năng Thiết Kế Giao Diện (UI/UX)',
      description: 'Trung tâm đào tạo mở khóa học ngắn hạn về Figma và tư duy UI/UX cơ bản vào cuối tuần.',
      type: 'choice',
      category: 'skill',
      weight: DecisionWeight.small,
      minYear: 2027,
      maxYear: 2027,
      choices: [
        Choice(
          id: 'uiux_learn',
          title: 'Đăng ký tham gia lớp học.',
          description: 'Học Figma và tư duy UI/UX để tự thiết kế giao diện sản phẩm.',
          subChoices: [
            SubChoice(
              id: 'uiux_hard',
              title: 'Cày cuốc chăm chỉ 20h/tuần',
              description: 'Nâng cao kỹ năng vượt trội bằng cách thức đêm cày Figma.',
              cost: ResourceCost(time: 8, energy: 4, money: 3.0),
              effects: {'skillScore': 15.0, 'burnout': 10.0, 'wellBeingScore': -5.0},
              log: 'Bạn thức đêm cày Figma, hoàn thành sản phẩm UI xuất sắc cho Portfolio cá nhân.',
            ),
            SubChoice(
              id: 'uiux_casual',
              title: 'Học cưỡi ngựa xem hoa 5h/tuần',
              description: 'Nắm kiến thức nền tảng nhẹ nhàng ít tốn sức.',
              cost: ResourceCost(time: 3, energy: 1, money: 2.0),
              effects: {'skillScore': 5.0},
              log: 'Bạn hoàn thành khóa học ở mức cơ bản, hiểu khái niệm thiết kế nhưng chưa thực hành sâu.',
            ),
          ],
        ),
        Choice(
          id: 'uiux_skip',
          title: 'Bỏ qua để nghỉ ngơi.',
          description: 'Dành thời gian rảnh rỗi để phục hồi sức khỏe.',
          subChoices: [
            SubChoice(
              id: 'uiux_rest',
              title: 'Dành cuối tuần nghỉ ngơi',
              description: 'Dành thời gian ngủ nghỉ và đi chơi.',
              cost: ResourceCost(time: 1, energy: 0, money: 1.0),
              effects: {'wellBeingScore': 8.0, 'burnout': -10.0},
              log: 'Bạn dành thời gian nạp lại năng lượng tinh thần, giảm hẳn mệt mỏi.',
            ),
          ],
        ),
      ],
    ),

    // ==========================================================
    // 2. MEDIUM EVENT (Sự kiện vừa) - Chọn chuyên ngành năm 2028
    // ==========================================================
    const Event(
      id: 'choose_specialization',
      title: 'Lựa Chọn Chuyên Ngành Học Năm 3 (2028)',
      description: 'Thời điểm quyết định hướng đi chuyên sâu của bạn trong ngành Công nghệ.',
      type: 'choice',
      category: 'skill',
      weight: DecisionWeight.medium,
      minYear: 2028,
      maxYear: 2028,
      choices: [
        Choice(
          id: 'spec_mobile',
          title: 'Chuyên sâu vào Phát triển Ứng dụng Di động (Mobile Developer).',
          description: 'Lập trình ứng dụng chạy trên iOS và Android (Flutter, Swift, Kotlin).',
          subChoices: [
            SubChoice(
              id: 'spec_mobile_premium',
              title: 'Đầu tư mua Laptop đời mới & Điện thoại test chuyên dụng.',
              description: 'Thiết bị cấu hình cao giúp học Flutter/iOS vô cùng mượt mà.',
              cost: ResourceCost(time: 6, energy: 3, money: 18.0),
              effects: {'skillScore': 25.0, 'careerScore': 12.0},
              log: 'Bạn sở hữu máy móc cấu hình mạnh, học lập trình Flutter/iOS vô cùng mượt mà.',
            ),
            SubChoice(
              id: 'spec_mobile_budget',
              title: 'Dùng thiết bị cũ chạy giả lập chậm chạp.',
              description: 'Không tốn chi phí nhưng mất nhiều thời gian chờ đợi máy build code.',
              cost: ResourceCost(time: 4, energy: 2, money: 0.0),
              effects: {'skillScore': 12.0, 'burnout': 10.0},
              log: 'Bạn chọn tự học với máy cũ, mất nhiều thời gian chờ đợi máy build code gây ức chế.',
            ),
          ],
        ),
        Choice(
          id: 'spec_web',
          title: 'Chuyên sâu vào Phát triển Web (Web Developer).',
          description: 'Xây dựng giao diện và hệ thống máy chủ cho website.',
          subChoices: [
            SubChoice(
              id: 'spec_web_fullstack',
              title: 'Học cật lực Fullstack (Cả Front-end lẫn Back-end).',
              description: 'Nắm vững kiến trúc web phức tạp, tăng tính linh hoạt.',
              cost: ResourceCost(time: 6, energy: 4, money: 2.0),
              effects: {'skillScore': 22.0, 'careerScore': 10.0, 'burnout': 12.0},
              log: 'Bạn nắm vững kiến trúc web phức tạp, tăng tính linh hoạt công việc.',
            ),
            SubChoice(
              id: 'spec_web_frontend',
              title: 'Học Front-end chuyên sâu nhẹ nhàng.',
              description: 'Chỉ tập trung vào giao diện (ReactJS, HTML/CSS) ít áp lực.',
              cost: ResourceCost(time: 3, energy: 2, money: 0.0),
              effects: {'skillScore': 10.0, 'careerScore': 5.0},
              log: 'Bạn học CSS/HTML/ReactJS cơ bản, ít áp lực nhưng giới hạn chuyên môn kỹ thuật.',
            ),
          ],
        ),
      ],
    ),

    // ==========================================================
    // 3. TURNING POINT EVENT (Bước ngoặt lớn) - Tốt nghiệp/Khởi nghiệp năm 2029
    // ==========================================================
    const Event(
      id: 'graduate_or_startup',
      title: 'Bước Ngoặt Tốt Nghiệp / Khởi Nghiệp (2029)',
      description: 'Năm 2029, bạn đứng trước sự chọn lựa sống còn: Hoàn thành nốt đại học lấy bằng hay bỏ học dồn toàn lực khởi nghiệp ứng dụng di động riêng.',
      type: 'choice',
      category: 'career',
      weight: DecisionWeight.turningPoint,
      minYear: 2029,
      maxYear: 2029,
      choices: [
        Choice(
          id: 'path_degree',
          title: 'Tập trung lấy tấm bằng cử nhân Đại học.',
          description: 'Học nốt để ra trường lấy bằng làm bệ đỡ tuyển dụng.',
          subChoices: [
            SubChoice(
              id: 'path_degree_excellent',
              title: 'Nỗ lực thi cử đạt bằng Giỏi.',
              description: 'Xây dựng hồ sơ ứng tuyển hoàn hảo, lương khởi điểm tốt.',
              cost: ResourceCost(time: 9, energy: 5, money: 6.0),
              effects: {'careerScore': 25.0, 'skillScore': 12.0, 'financeScore': -5.0, 'currentIncome': 10.0},
              log: 'Bạn tốt nghiệp bằng Giỏi, lập tức có công ty tuyển dụng với lương khởi điểm 10 triệu/tháng.',
            ),
            SubChoice(
              id: 'path_degree_good',
              title: 'Ra trường với bằng Khá.',
              description: 'Dành sức đi làm sớm, cân bằng thời gian.',
              cost: ResourceCost(time: 4, energy: 2, money: 2.0),
              effects: {'careerScore': 15.0, 'currentIncome': 8.0},
              log: 'Bạn ra trường bằng Khá và bắt đầu công việc với mức lương 8 triệu/tháng.',
            ),
          ],
        ),
        Choice(
          id: 'path_dropout',
          title: 'Quyết định Bỏ học, dốc toàn lực làm Startup riêng.',
          description: 'Mạo hiểm làm ứng dụng di động riêng, chấp nhận rủi ro thất bại.',
          subChoices: [
            SubChoice(
              id: 'path_dropout_startup',
              title: 'Hợp tác mở công ty, làm việc 80h/tuần.',
              description: 'Chịu áp lực khủng khiếp để tự làm chủ.',
              cost: ResourceCost(time: 11, energy: 8, money: 12.0),
              effects: {'careerScore': 35.0, 'networkScore': 25.0, 'burnout': 30.0, 'wellBeingScore': -15.0, 'financeScore': -25.0, 'currentIncome': 5.0},
              log: 'Bỏ học khởi nghiệp! Bạn chịu áp lực khủng khiếp, tài chính cạn kiệt nhưng học được vô vàn bài học thương trường.',
            ),
          ],
        ),
      ],
    ),
  ];
}
