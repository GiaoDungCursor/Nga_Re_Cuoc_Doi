import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/character.dart';
import '../../../shared/models/event.dart';
import '../../../core/constants/events_data.dart';

enum SimulationPhase {
  yearIntro,        // Giới thiệu năm mới & tài nguyên
  mainDecision,     // Lựa chọn lớn của năm
  subDecision,      // Lựa chọn chi tiết (trade-off)
  consequenceReveal,// Dự báo hậu quả mơ hồ
  reflection,       // Câu hỏi phản tư học tập
  yearSummary,      // Tổng kết năm & thay đổi thực tế
  finalReport,      // Báo cáo chẩn đoán cuối cùng
}

class SimulationStateData {
  final Character? character;
  final SimulationPhase phase;
  final Event? currentEvent;
  final Choice? selectedChoice;
  final SubChoice? selectedSubChoice;
  final String? reflectionQuestion;
  final List<String> reflectionOptions;
  final String? selectedReflection;
  final List<String> lifeLog;
  final bool isGameOver;
  final List<DecisionHistory> decisionsHistory;
  final Map<String, dynamic>? finalReportData;

  SimulationStateData({
    this.character,
    this.phase = SimulationPhase.yearIntro,
    this.currentEvent,
    this.selectedChoice,
    this.selectedSubChoice,
    this.reflectionQuestion,
    this.reflectionOptions = const [],
    this.selectedReflection,
    required this.lifeLog,
    this.isGameOver = false,
    this.decisionsHistory = const [],
    this.finalReportData,
  });

  SimulationStateData copyWith({
    Character? character,
    SimulationPhase? phase,
    Event? currentEvent,
    bool clearCurrentEvent = false,
    Choice? selectedChoice,
    bool clearSelectedChoice = false,
    SubChoice? selectedSubChoice,
    bool clearSelectedSubChoice = false,
    String? reflectionQuestion,
    List<String>? reflectionOptions,
    String? selectedReflection,
    bool clearSelectedReflection = false,
    List<String>? lifeLog,
    bool? isGameOver,
    List<DecisionHistory>? decisionsHistory,
    Map<String, dynamic>? finalReportData,
  }) {
    return SimulationStateData(
      character: character ?? this.character,
      phase: phase ?? this.phase,
      currentEvent: clearCurrentEvent ? null : (currentEvent ?? this.currentEvent),
      selectedChoice: clearSelectedChoice ? null : (selectedChoice ?? this.selectedChoice),
      selectedSubChoice: clearSelectedSubChoice ? null : (selectedSubChoice ?? this.selectedSubChoice),
      reflectionQuestion: reflectionQuestion ?? this.reflectionQuestion,
      reflectionOptions: reflectionOptions ?? this.reflectionOptions,
      selectedReflection: clearSelectedReflection ? null : (selectedReflection ?? this.selectedReflection),
      lifeLog: lifeLog ?? this.lifeLog,
      isGameOver: isGameOver ?? this.isGameOver,
      decisionsHistory: decisionsHistory ?? this.decisionsHistory,
      finalReportData: finalReportData ?? this.finalReportData,
    );
  }
}

class SimulationNotifier extends StateNotifier<SimulationStateData> {
  SimulationNotifier() : super(SimulationStateData(lifeLog: []));

  // Khởi động lượt chơi mới — sử dụng bối cảnh cá nhân từ quiz
  void startNewLife(String archetype, {Map<String, String> backgroundAnswers = const {}}) {
    final char = Character.fromArchetype(archetype, backgroundAnswers: backgroundAnswers);

    // ── Tạo sự kiện khai cuộc dựa trên trình độ học vấn thực tế ──
    final edu = backgroundAnswers['educationLevel'] ?? 'edu_highschool';
    final field = backgroundAnswers['studyField'] ?? 'field_unknown';
    final status = backgroundAnswers['currentStatus'] ?? 'status_studying';

    final initEvent = _buildOpeningEvent(edu, field, status);

    state = SimulationStateData(
      character: char,
      phase: SimulationPhase.yearIntro,
      currentEvent: initEvent,
      lifeLog: ['[Năm 2026] Khởi đầu lộ trình 10 năm phát triển sự nghiệp.'],
      isGameOver: false,
      decisionsHistory: [],
    );
  }

  /// Tạo sự kiện khai cuộc phù hợp với bối cảnh người dùng
  Event _buildOpeningEvent(String edu, String field, String status) {
    // ── Mô tả bối cảnh dựa trên trình độ ──────────────────
    final String contextDesc;
    switch (edu) {
      case 'edu_highschool':
        contextDesc = 'Năm 2026, bạn vừa tốt nghiệp THPT và đứng trước ngưỡng cửa quan trọng nhất cuộc đời — chọn con đường học vấn và sự nghiệp. Quyết định hôm nay sẽ định hình 10 năm tiếp theo.';
        break;
      case 'edu_vocational':
        contextDesc = 'Năm 2026, bạn đang học nghề hoặc vừa tốt nghiệp trung cấp. Bạn có kỹ năng thực hành tốt nhưng muốn xây dựng nền tảng vững chắc hơn để tiến xa trong sự nghiệp.';
        break;
      case 'edu_studying':
        contextDesc = 'Năm 2026, bạn đang là sinh viên đại học/cao đẳng. Đây là giai đoạn then chốt để đầu tư vào chuyên môn, thực tập và xây dựng mạng lưới quan hệ trước khi ra trường.';
        break;
      case 'edu_graduated':
        contextDesc = 'Năm 2026, bạn đã tốt nghiệp đại học và bước vào thị trường lao động với nền tảng kiến thức vững chắc. Lúc này là thời điểm chứng tỏ giá trị của bản thân trong thực tiễn.';
        break;
      case 'edu_postgrad':
        contextDesc = 'Năm 2026, với bằng thạc sĩ/tiến sĩ hoặc chứng chỉ chuyên nghiệp quốc tế, bạn có lợi thế cạnh tranh rõ rệt. Câu hỏi là bạn sẽ tận dụng lợi thế đó như thế nào?';
        break;
      default:
        contextDesc = 'Năm 2026, một chương mới bắt đầu. Bạn đứng trước những lựa chọn định hình con đường sự nghiệp của mình.';
    }

    // ── Tên lĩnh vực ──────────────────────────────────────
    final String fieldName;
    switch (field) {
      case 'field_tech': fieldName = 'Kỹ thuật & Công nghệ'; break;
      case 'field_business': fieldName = 'Kinh tế & Kinh doanh'; break;
      case 'field_health': fieldName = 'Y tế & Sức khỏe'; break;
      case 'field_arts': fieldName = 'Nghệ thuật & Truyền thông'; break;
      case 'field_social': fieldName = 'Khoa học Xã hội & Giáo dục'; break;
      case 'field_agri': fieldName = 'Nông - Lâm - Ngư nghiệp'; break;
      case 'field_law': fieldName = 'Pháp lý & Chính trị'; break;
      default: fieldName = 'Đa lĩnh vực'; break;
    }

    // ── Tạo các lựa chọn phù hợp với trình độ & lĩnh vực ─
    final List<Choice> choices = _buildOpeningChoices(edu, field, status, fieldName);

    return Event(
      id: 'init_2026',
      title: 'Định Hướng Sự Nghiệp 2026',
      description: '$contextDesc\n\nLĩnh vực của bạn: $fieldName. Bạn sẽ lựa chọn ngã rẽ nào?',
      type: 'choice',
      category: 'career',
      weight: DecisionWeight.turningPoint,
      choices: choices,
    );
  }

  /// Các lựa chọn năm 2026 tùy theo trình độ học vấn
  List<Choice> _buildOpeningChoices(String edu, String field, String status, String fieldName) {
    // Người đã tốt nghiệp đại học / sau đại học
    if (edu == 'edu_graduated' || edu == 'edu_postgrad') {
      return [
        Choice(
          id: 'opt_career_build',
          title: 'Tập trung phát triển sự nghiệp trong lĩnh vực $fieldName.',
          description: 'Dùng bằng cấp và kiến thức để tăng tốc thăng tiến và xây dựng thương hiệu cá nhân.',
          subChoices: [
            SubChoice(
              id: 'career_intensive',
              title: 'Cày cuốc, nhận thêm dự án và tích lũy kinh nghiệm dày dặn.',
              description: 'Tăng tốc sự nghiệp bằng cách dốc toàn lực vào công việc.',
              cost: const ResourceCost(time: 10, energy: 6, money: 5.0),
              effects: const {'careerScore': 22.0, 'skillScore': 12.0, 'networkScore': 8.0, 'burnout': 15.0, 'wellBeingScore': -5.0},
              log: 'Bạn dồn toàn lực vào công việc chuyên môn, thăng tiến nhanh và được đánh giá cao.',
            ),
            SubChoice(
              id: 'career_balanced',
              title: 'Làm việc vừa phải, song song học thêm kỹ năng mới.',
              description: 'Cân bằng giữa làm việc và nâng cao năng lực.',
              cost: const ResourceCost(time: 6, energy: 3, money: 3.0),
              effects: const {'careerScore': 12.0, 'skillScore': 15.0, 'networkScore': 5.0, 'wellBeingScore': 5.0},
              log: 'Bạn duy trì nhịp độ bền vững, vừa tích lũy kinh nghiệm vừa học thêm công cụ mới.',
            ),
          ],
        ),
        Choice(
          id: 'opt_upskill',
          title: 'Đầu tư nâng cấp chuyên môn — học chứng chỉ quốc tế hoặc khóa chuyên sâu.',
          description: 'Tận dụng thời gian để trở thành chuyên gia cốt lõi trong lĩnh vực.',
          subChoices: [
            SubChoice(
              id: 'upskill_cert',
              title: 'Học chứng chỉ quốc tế uy tín (PMP, CFA, IELTS, AWS...)',
              description: 'Nâng cao giá trị bản thân với chứng nhận được thị trường công nhận.',
              cost: const ResourceCost(time: 8, energy: 4, money: 15.0),
              effects: const {'skillScore': 25.0, 'careerScore': 15.0, 'networkScore': 5.0},
              log: 'Bạn đạt chứng chỉ quốc tế uy tín, CV bỗng nổi bật hơn hẳn so với đồng nghiệp cùng cấp.',
            ),
          ],
        ),
        Choice(
          id: 'opt_startup_grad',
          title: 'Tận dụng kiến thức chuyên môn để khởi nghiệp hoặc freelance.',
          description: 'Chuyển kiến thức thành thu nhập độc lập.',
          subChoices: [
            SubChoice(
              id: 'startup_solo',
              title: 'Nhận hợp đồng freelance, xây dựng thương hiệu cá nhân.',
              description: 'Bắt đầu kiếm tiền từ kỹ năng chuyên môn một cách độc lập.',
              cost: const ResourceCost(time: 9, energy: 5, money: 5.0),
              effects: const {'careerScore': 18.0, 'networkScore': 15.0, 'financeScore': 10.0, 'burnout': 12.0},
              log: 'Bạn bắt đầu nhận dự án freelance và xây dựng danh tiếng trong ngành một cách độc lập.',
            ),
          ],
        ),
      ];
    }

    // Đang đi học đại học
    if (edu == 'edu_studying') {
      return [
        Choice(
          id: 'opt_intern',
          title: 'Tìm kiếm cơ hội thực tập trong lĩnh vực $fieldName.',
          description: 'Kết hợp lý thuyết và thực tiễn, xây dựng mạng lưới quan hệ từ sớm.',
          subChoices: [
            SubChoice(
              id: 'intern_top',
              title: 'Nộp đơn vào công ty lớn, cạnh tranh cao.',
              description: 'Thực tập tại môi trường chuyên nghiệp, có mentorship tốt.',
              cost: const ResourceCost(time: 8, energy: 5, money: 3.0),
              effects: const {'careerScore': 20.0, 'networkScore': 15.0, 'skillScore': 10.0, 'burnout': 10.0},
              log: 'Bạn được nhận vào công ty uy tín, làm quen với môi trường chuyên nghiệp và xây dựng mạng lưới quan hệ.',
            ),
            SubChoice(
              id: 'intern_startup',
              title: 'Thực tập tại startup nhỏ — học được nhiều, tự do hơn.',
              description: 'Môi trường linh hoạt, được giao nhiệm vụ thực tế ngay.',
              cost: const ResourceCost(time: 6, energy: 3, money: 1.0),
              effects: const {'skillScore': 15.0, 'careerScore': 10.0, 'networkScore': 10.0},
              log: 'Bạn thực tập tại startup năng động, học được nhiều kỹ năng thực chiến đa dạng.',
            ),
          ],
        ),
        Choice(
          id: 'opt_study_hard',
          title: 'Tập trung học thật tốt, đạt học bổng hoặc thứ hạng cao.',
          description: 'Đầu tư vào kết quả học tập để mở ra cơ hội tốt hơn sau khi ra trường.',
          subChoices: [
            SubChoice(
              id: 'study_scholarship',
              title: 'Nỗ lực đạt học bổng xuất sắc.',
              description: 'Học bổng giúp tiết kiệm chi phí và mở ra cơ hội du học.',
              cost: const ResourceCost(time: 10, energy: 6, money: 0.0),
              effects: const {'skillScore': 20.0, 'careerScore': 12.0, 'financeScore': 15.0, 'burnout': 12.0},
              log: 'Bạn đạt học bổng xuất sắc, giảm đáng kể học phí và được ghi nhận trong danh sách sinh viên tiêu biểu.',
            ),
          ],
        ),
      ];
    }

    // Học nghề / Trung cấp
    if (edu == 'edu_vocational') {
      return [
        Choice(
          id: 'opt_practice',
          title: 'Tìm việc làm ngay trong lĩnh vực $fieldName để tích lũy kinh nghiệm thực tế.',
          description: 'Áp dụng kỹ năng thực hành ngay vào thực tế, kiếm thu nhập sớm.',
          subChoices: [
            SubChoice(
              id: 'practice_fulltime',
              title: 'Đi làm toàn thời gian, học hỏi từ đồng nghiệp.',
              description: 'Tích lũy kinh nghiệm thực tế nhanh nhất có thể.',
              cost: const ResourceCost(time: 8, energy: 5, money: 2.0),
              effects: const {'careerScore': 18.0, 'skillScore': 15.0, 'currentIncome': 6.0, 'financeScore': 5.0},
              log: 'Bạn bắt đầu đi làm toàn thời gian, kiếm thu nhập và học hỏi nhanh trong môi trường thực tế.',
            ),
          ],
        ),
        Choice(
          id: 'opt_upgrade_edu',
          title: 'Học thêm để nâng cấp bằng cấp lên Cao đẳng/Đại học.',
          description: 'Đầu tư thêm thời gian để có bằng cấp cao hơn, mở ra cơ hội tốt hơn.',
          subChoices: [
            SubChoice(
              id: 'upgrade_part',
              title: 'Học tại chức buổi tối, vừa đi làm vừa học.',
              description: 'Vừa có thu nhập vừa cải thiện bằng cấp.',
              cost: const ResourceCost(time: 9, energy: 5, money: 8.0),
              effects: const {'skillScore': 12.0, 'careerScore': 10.0, 'burnout': 10.0, 'wellBeingScore': -5.0},
              log: 'Bạn kiên trì học tại chức, vất vả nhưng mỗi ngày đang tiến gần hơn đến tấm bằng đại học.',
            ),
          ],
        ),
      ];
    }

    // Mặc định (THPT hoặc chưa xác định)
    return [
      Choice(
        id: 'opt_uni_default',
        title: 'Học Đại học / Cao đẳng — đầu tư nền tảng dài hạn.',
        description: 'Học tập bài bản để có kiến thức nền tảng vững chắc trong lĩnh vực $fieldName.',
        subChoices: [
          SubChoice(
            id: 'uni_hard',
            title: 'Học chăm chỉ 30h/tuần, đầu tư nghiêm túc.',
            description: 'Nỗ lực tối đa để có kết quả học tập xuất sắc.',
            cost: const ResourceCost(time: 10, energy: 6, money: 20.0),
            effects: const {'careerScore': 18.0, 'skillScore': 15.0, 'financeScore': -25.0, 'wellBeingScore': 5.0, 'burnout': 12.0},
            log: 'Bạn chọn học đại học và đầu tư học tập chăm chỉ, xây dựng nền tảng vững chắc cho tương lai.',
          ),
          SubChoice(
            id: 'uni_normal',
            title: 'Học vừa phải, cân bằng cuộc sống.',
            description: 'Duy trì kết quả tốt mà không kiệt sức.',
            cost: const ResourceCost(time: 6, energy: 3, money: 15.0),
            effects: const {'careerScore': 10.0, 'skillScore': 8.0, 'financeScore': -15.0, 'wellBeingScore': 10.0},
            log: 'Bạn học đại học nhịp độ bình thường, vừa học vừa tận hưởng cuộc sống sinh viên.',
          ),
        ],
      ),
      Choice(
        id: 'opt_work_early',
        title: 'Đi làm sớm, học từ thực tế thay vì đại học.',
        description: 'Tích lũy kinh nghiệm thực chiến ngay từ đầu, kiếm tiền sớm.',
        subChoices: [
          SubChoice(
            id: 'work_hard',
            title: 'Nhận bất kỳ công việc nào phù hợp, học việc tận tâm.',
            description: 'Bắt đầu từ vị trí thấp nhất nhưng học hỏi rất nhanh.',
            cost: const ResourceCost(time: 8, energy: 4, money: 0.0),
            effects: const {'careerScore': 12.0, 'skillScore': 10.0, 'currentIncome': 5.0, 'financeScore': 3.0},
            log: 'Bạn chọn đi làm ngay, học hỏi từ thực tế và bắt đầu kiếm thu nhập từ sớm.',
          ),
        ],
      ),
    ];
  }


  // Tạo sự kiện "Năm bình lặng" để tránh trả về null
  Event createQuietYearEvent(int year) {
    return Event(
      id: 'quiet_year_$year',
      title: 'Một Năm Bình Lặng ($year)',
      description: 'Năm vừa qua không xảy ra biến cố lớn nào đối với sự nghiệp của bạn. Bạn tiếp tục làm việc và củng cố chuyên môn của mình.',
      type: 'choice',
      category: 'economic',
      weight: DecisionWeight.small,
      minYear: year,
      maxYear: year,
      choices: [
        Choice(
          id: 'quiet_keep',
          title: 'Duy trì nhịp độ công việc hiện tại.',
          description: 'Tập trung hoàn thành công việc ổn định, tích lũy tài sản và chăm sóc sức khỏe.',
          subChoices: [
            SubChoice(
              id: 'quiet_work',
              title: 'Làm việc bình thường và dưỡng sức',
              description: 'Dành thời gian vừa phải cho công việc, tập trung hồi phục Well-being.',
              cost: const ResourceCost(time: 4, energy: 2, money: 0.0),
              effects: const {
                'careerScore': 2.0,
                'skillScore': 2.0,
                'wellBeingScore': 4.0,
                'burnout': -6.0,
              },
              log: 'Một năm trôi qua bình yên, bạn duy trì tốt nhịp độ làm việc và cuộc sống cân bằng.',
            ),
          ],
        ),
      ],
    );
  }

  // Pha 1 -> Pha 2: Chuyển sang chọn lựa chính
  void proceedToMainDecision() {
    state = state.copyWith(phase: SimulationPhase.mainDecision);
  }

  // Pha 2 -> Pha 3: Chọn lựa chính xong, chuyển sang chọn trade-off phụ
  void selectMainChoice(Choice choice) {
    state = state.copyWith(
      selectedChoice: choice,
      phase: SimulationPhase.subDecision,
    );
  }

  // Pha 3 -> Pha 4: Chọn sub choice xong, xem trước hậu quả mơ hồ
  void selectSubChoice(SubChoice sub) {
    state = state.copyWith(
      selectedSubChoice: sub,
      phase: SimulationPhase.consequenceReveal,
    );
  }

  // Quay lại pha chọn chính nếu muốn đổi ý
  void backToMainDecision() {
    state = state.copyWith(
      clearSelectedChoice: true,
      clearSelectedSubChoice: true,
      phase: SimulationPhase.mainDecision,
    );
  }

  // Quay lại pha chọn phụ nếu muốn đổi ý
  void backToSubDecision() {
    state = state.copyWith(
      clearSelectedSubChoice: true,
      phase: SimulationPhase.subDecision,
    );
  }

  // Pha 4 -> Pha 5: Xác nhận, áp dụng điểm số và chuyển sang Pha Phản Tư
  void confirmDecision() {
    if (state.character == null || state.selectedSubChoice == null) return;

    final char = state.character!;
    final sub = state.selectedSubChoice!;

    // Trừ tài nguyên từ ResourceCost
    int newTime = char.timePoints - sub.cost.time;
    int newEnergy = char.energyPoints - sub.cost.energy;
    double newMoney = char.moneyPoints - sub.cost.money;

    // Cộng trừ chỉ số sự nghiệp
    double newCareer = char.careerScore + (sub.effects['careerScore'] ?? 0);
    double newSkill = char.skillScore + (sub.effects['skillScore'] ?? 0);
    double newNetwork = char.networkScore + (sub.effects['networkScore'] ?? 0);
    double newFinance = char.financeScore + (sub.effects['financeScore'] ?? 0);
    double newWellBeing = char.wellBeingScore + (sub.effects['wellBeingScore'] ?? 0);
    double newBurnout = char.burnout + (sub.effects['burnout'] ?? 0);
    double newIncome = char.currentIncome + (sub.effects['currentIncome'] ?? 0);

    final updatedChar = char.copyWith(
      timePoints: newTime.clamp(0, 12),
      energyPoints: newEnergy.clamp(0, 12),
      moneyPoints: newMoney,
      careerScore: newCareer,
      skillScore: newSkill,
      networkScore: newNetwork,
      financeScore: newFinance,
      wellBeingScore: newWellBeing,
      burnout: newBurnout,
      currentIncome: newIncome,
    );

    // Tính điểm ảnh hưởng (impactScore) làm tổng trị tuyệt đối của các effects
    double impactScore = sub.effects.values.fold(0.0, (sum, value) => sum + value.abs());

    // Ghi chép lịch sử thông qua model DecisionHistory
    final historyEntry = DecisionHistory(
      year: char.year,
      eventId: state.currentEvent?.id ?? 'unknown',
      eventTitle: state.currentEvent?.title ?? 'Sự kiện',
      choiceId: state.selectedChoice?.id ?? 'unknown',
      subChoiceId: sub.id,
      subChoiceTitle: sub.title,
      weight: state.currentEvent?.weight ?? DecisionWeight.small,
      effects: sub.effects,
      impactScore: impactScore,
      log: sub.log,
    );

    final updatedHistory = List<DecisionHistory>.from(state.decisionsHistory)
      ..add(historyEntry);

    final updatedLog = List<String>.from(state.lifeLog)
      ..add('[Năm ${char.year}] ${sub.log}');

    // Chuẩn bị câu hỏi phản tư tùy theo danh mục sự kiện
    String refQuestion = 'Bạn cảm thấy thế nào về lựa chọn này?';
    List<String> refOptions = [
      'Tự tin và sẵn sàng gánh vác trách nhiệm',
      'Hơi lo lắng nhưng chấp nhận rủi ro để đi lên',
      'Có chút tiếc nuối vì phải đánh đổi nhiều thứ'
    ];

    if (state.currentEvent?.category == 'skill') {
      refQuestion = 'Khi đầu tư vào kỹ năng chuyên môn trong năm nay, động lực lớn nhất của bạn là gì?';
      refOptions = [
        'Xây dựng nền tảng chuyên môn sâu, bền vững lâu dài',
        'Tạo ra kết quả nhanh chóng để gia tăng cơ hội thu nhập',
        'Học hỏi nhẹ nhàng để ưu tiên sức khỏe và tinh thần'
      ];
    } else if (state.currentEvent?.category == 'career') {
      refQuestion = 'Khi đứng trước các ngã rẽ sự nghiệp hoặc thăng tiến lớn, tư duy của bạn là:';
      refOptions = [
        'Ưu tiên sự ổn định, an toàn để bảo toàn năng lượng',
        'Chấp nhận rủi ro lớn, sẵn sàng cày cuốc để đột phá',
        'Tìm kiếm sự hài hòa trung dung giữa tài chính và cuộc sống'
      ];
    }

    state = state.copyWith(
      character: updatedChar,
      decisionsHistory: updatedHistory,
      lifeLog: updatedLog,
      reflectionQuestion: refQuestion,
      reflectionOptions: refOptions,
      phase: SimulationPhase.reflection,
    );

    // Kiểm tra hệ quả Burnout/Well-being tức thời
    _checkImmediateCareerCrisis(updatedChar, updatedHistory);
  }

  // Pha 5 -> Pha 6: Chọn phản tư xong, hiển thị Báo cáo Tổng kết năm
  void selectReflection(String option) {
    state = state.copyWith(
      selectedReflection: option,
      phase: SimulationPhase.yearSummary,
    );
  }

  // Hỗ trợ chọn nghỉ ngơi dưỡng sức khi bị kiệt quệ tài nguyên
  void forceRest() {
    if (state.character == null) return;
    
    final char = state.character!;
    final updatedChar = char.copyWith(
      timePoints: 12,
      energyPoints: (char.energyPoints + 4).clamp(2, 12),
      wellBeingScore: char.wellBeingScore + 10,
      burnout: (char.burnout - 15).clamp(0.0, 100.0),
      careerScore: char.careerScore - 5,
      skillScore: char.skillScore - 5,
    );

    final historyEntry = DecisionHistory(
      year: char.year,
      eventId: state.currentEvent?.id ?? 'unknown',
      eventTitle: state.currentEvent?.title ?? 'Sự kiện',
      choiceId: 'force_rest',
      subChoiceId: 'force_rest',
      subChoiceTitle: 'Nghỉ ngơi hoàn toàn vì kiệt sức',
      weight: DecisionWeight.small,
      effects: const {'wellBeingScore': 10.0, 'burnout': -15.0, 'careerScore': -5.0, 'skillScore': -5.0},
      impactScore: 35.0,
      log: 'Bạn dành cả năm nghỉ ngơi phục hồi sức khỏe do kiệt quệ tài nguyên.',
    );

    final updatedHistory = List<DecisionHistory>.from(state.decisionsHistory)
      ..add(historyEntry);

    final updatedLog = List<String>.from(state.lifeLog)
      ..add('[Năm ${char.year}] Bạn buộc phải nghỉ ngơi cả năm để phục hồi do kiệt sức.');

    state = state.copyWith(
      character: updatedChar,
      decisionsHistory: updatedHistory,
      lifeLog: updatedLog,
      reflectionQuestion: 'Trải qua một năm dưỡng sức bắt buộc, bạn rút ra bài học gì?',
      reflectionOptions: [
        'Sức khỏe là vốn quý nhất, không có sức khỏe thì không thể làm gì',
        'Cần quản lý tài nguyên (thời gian, năng lượng) tốt hơn trong tương lai',
        'Rất tiếc vì đã bỏ lỡ cơ hội thăng tiến quý giá của năm nay'
      ],
      phase: SimulationPhase.reflection,
    );
  }

  // Nhảy sang năm tiếp theo
  void progressToNextYear() {
    if (state.character == null || state.isGameOver) return;

    final currentYear = state.character!.year;
    final nextYear = currentYear + 1;

    // Giới hạn 10 năm mô phỏng (Kết thúc vào năm 2036)
    if (nextYear > 2036) {
      _triggerFinalStrategicReport(state.character!, state.decisionsHistory);
      return;
    }

    // Thiết lập tài nguyên năm mới
    final prevChar = state.character!;
    
    // Tích lũy lương hàng năm (Tiết kiệm 30% thu nhập chuyển vào Finance, 70% còn lại chuyển vào quỹ tiền mặt Money tiêu dùng)
    double annualEarnings = prevChar.currentIncome * 12;
    double savings = annualEarnings * 0.3;
    double pocketMoney = annualEarnings * 0.7;

    // Burnout giảm nhẹ tự nhiên sau 1 năm (-8 điểm)
    double updatedBurnout = (prevChar.burnout - 8.0).clamp(0.0, 100.0);
    // Năng lượng năm mới tính từ Well-being hiện tại
    int newEnergy = (prevChar.wellBeingScore / 10).round().clamp(2, 12);

    final updatedChar = prevChar.copyWith(
      year: nextYear,
      timePoints: 12, // Reset quỹ thời gian
      energyPoints: newEnergy,
      moneyPoints: prevChar.moneyPoints + pocketMoney,
      financeScore: prevChar.financeScore + savings,
      burnout: updatedBurnout,
      wellBeingScore: prevChar.wellBeingScore - 1.0, // Lão hóa nhẹ
    );

    // Tải sự kiện của năm — luôn có event (fallback là quiet year)
    final nextEvent = _loadScheduledEventForYear(nextYear);

    state = state.copyWith(
      character: updatedChar,
      currentEvent: nextEvent,
      clearSelectedChoice: true,
      clearSelectedSubChoice: true,
      clearSelectedReflection: true,
      reflectionOptions: const [],
      phase: SimulationPhase.yearIntro,
    );
  }

  // Tải sự kiện — luôn trả về Event (không bao giờ null)
  Event _loadScheduledEventForYear(int year) {
    Event? found;
    switch (year) {
      case 2027:
        found = _findEventById('short_course');
        break;
      case 2028:
        found = _findEventById('choose_specialization');
        break;
      case 2029:
        found = _findEventById('graduate_or_startup');
        break;
      default:
        break;
    }
    // Fallback an toàn: Quiet year cho bất kỳ năm nào không có sự kiện được định nghĩa
    return found ?? createQuietYearEvent(year);
  }

  Event? _findEventById(String id) {
    try {
      return EventsData.allEvents.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // Kiểm tra burnout hoặc sức khỏe cạn kiệt gây dừng game sớm
  void _checkImmediateCareerCrisis(Character char, List<DecisionHistory> history) {
    if (char.burnout >= 95) {
      final failedChar = char.copyWith(
        isGameOver: true,
        gameOverReason: 'Burnout đỉnh điểm (${char.burnout.toInt()}%). Bạn rơi vào trạng thái kiệt sức nặng nề, mất toàn bộ khả năng tập trung. Bác sĩ yêu cầu bạn buộc phải xin nghỉ việc để điều trị tâm lý lâu dài.',
      );
      final report = _generateFinalDiagnosticReportInternal(failedChar, history);
      state = state.copyWith(
        character: failedChar,
        isGameOver: true,
        phase: SimulationPhase.finalReport,
        finalReportData: report,
        lifeLog: List<String>.from(state.lifeLog)..add('[Năm ${char.year}] Khủng hoảng: Buộc phải thôi việc do Burnout cực độ.'),
      );
    } else if (char.wellBeingScore <= 10) {
      final failedChar = char.copyWith(
        isGameOver: true,
        gameOverReason: 'Sức khỏe thể chất cạn kiệt (Well-being còn ${char.wellBeingScore.toInt()}%). Lối sống bỏ bê bản thân để cày cuốc khiến bạn đổ bệnh nặng, phải dừng hẳn công việc để điều trị dài hạn.',
      );
      final report = _generateFinalDiagnosticReportInternal(failedChar, history);
      state = state.copyWith(
        character: failedChar,
        isGameOver: true,
        phase: SimulationPhase.finalReport,
        finalReportData: report,
        lifeLog: List<String>.from(state.lifeLog)..add('[Năm ${char.year}] Khủng hoảng: Đổ bệnh nặng, gián đoạn sự nghiệp.'),
      );
    }
  }

  // Kết thúc 10 năm sự nghiệp thành công -> Tổng kết chẩn đoán
  void _triggerFinalStrategicReport(Character char, List<DecisionHistory> history) {
    final finalChar = char.copyWith(
      isGameOver: true,
      gameOverReason: 'Chúc mừng! Bạn đã hoàn thành xuất sắc lộ trình mô phỏng 10 năm đầu tiên phát triển sự nghiệp.',
    );
    final report = _generateFinalDiagnosticReportInternal(finalChar, history);

    state = state.copyWith(
      character: finalChar,
      isGameOver: true,
      phase: SimulationPhase.finalReport,
      finalReportData: report,
      lifeLog: List<String>.from(state.lifeLog)..add('[Năm 2036] Hoàn thành 10 năm mô phỏng phát triển sự nghiệp.'),
    );
  }

  // Hàm sinh báo cáo chẩn đoán nội bộ dùng DecisionHistory
  Map<String, dynamic> _generateFinalDiagnosticReportInternal(Character char, List<DecisionHistory> decisionsHistory) {
    String title = 'Chưa xác định';
    String details = '';
    
    // Tận dụng định danh choiceId để phân tích thay vì check Text
    bool didStartup = decisionsHistory.any((d) => d.choiceId == 'path_dropout');
    bool specializedInMobile = decisionsHistory.any((d) => d.choiceId == 'spec_mobile');
    bool specializedInWeb = decisionsHistory.any((d) => d.choiceId == 'spec_web');

    if (char.isGameOver && char.gameOverReason != null && (char.gameOverReason!.contains('Burnout') || char.gameOverReason!.contains('Sức khỏe'))) {
      title = char.gameOverReason!.contains('Burnout') ? '💔 Lập Trình Viên Kiệt Sức' : '🏥 Bệnh Nhân Sự Nghiệp';
      details = char.gameOverReason!;
    } else {
      if (didStartup) {
        if (char.careerScore >= 70 && char.skillScore >= 70) {
          title = '👑 Co-Founder & CTO Công nghệ';
          details = 'Bạn đã dũng cảm bỏ học khởi nghiệp và gặt hái thành quả ngọt ngào từ dự án di động riêng. Sự dũng cảm và năng lực thực thi xuất sắc giúp bạn xây dựng công ty riêng thành công.';
        } else {
          title = '💸 Nhà Khởi Nghiệp Vất Vả';
          details = 'Startup của bạn sống sót qua 10 năm nhưng chưa thể bứt phá lớn do thiếu hụt kỹ năng quản lý hoặc chuyên môn cốt lõi.';
        }
      } else if (specializedInMobile) {
        if (char.careerScore >= 75) {
          title = '📱 Chuyên Gia Flutter / iOS Cấp Cao (Senior Mobile Dev)';
          details = 'Quyết định đi sâu vào mảng Mobile cùng sự đầu tư thiết bị và kỹ năng từ sớm giúp bạn thăng tiến vượt bậc tại các tập đoàn lớn.';
        } else if (char.careerScore >= 50) {
          title = '📱 Lập Trình Viên Di Động Trung Cấp (Middle Mobile Dev)';
          details = 'Bạn có công việc ổn định, làm chủ công nghệ Flutter nhưng cần bứt phá hơn trong việc tối ưu hiệu năng và kết nối quan hệ rộng hơn.';
        } else {
          title = '📱 Lập Trình Viên Di Động Mới Vào Nghề (Junior Mobile Dev)';
          details = 'Bạn đã gia nhập ngành mobile nhưng tốc độ phát triển chuyên môn còn chậm hoặc bị cản trở bởi các đợt áp lực burnout.';
        }
      } else if (specializedInWeb) {
        if (char.careerScore >= 75) {
          title = '🌐 Chuyên Gia Phát Triển Web Cấp Cao (Senior Web Dev)';
          details = 'Bạn là chuyên gia Fullstack / Web hàng đầu, làm chủ các hệ thống phân tán lớn và có mức thu nhập cao.';
        } else if (char.careerScore >= 50) {
          title = '🌐 Lập Trình Viên Web Trung Cấp (Middle Web Dev)';
          details = 'Bạn hoàn thành tốt các dự án web nhưng cần học thêm kiến thức hệ thống lớn (System Design) hoặc cloud để nâng tầm sự nghiệp.';
        } else {
          title = '🌐 Lập Trình Viên Web Mới Vào Nghề (Junior Web Dev)';
          details = 'Bạn làm Front-end hoặc Back-end ở mức cơ bản, cần tích lũy thêm portfolio dự án thực chiến.';
        }
      } else {
        if (char.careerScore >= 60) {
          title = '💻 Kỹ Sư Phần Mềm Đa Năng (Generalist Software Engineer)';
          details = 'Bạn có kiến thức rộng ở nhiều mảng, dễ dàng thích nghi với các công nghệ mới trong doanh nghiệp.';
        } else {
          title = '💻 Lập Trình Viên Tự Do (Freelancer)';
          details = 'Bạn làm việc tự do hoặc làm các dự án nhỏ lẻ, sự nghiệp ở mức trung bình và thu nhập bấp bênh.';
        }
      }
    }

    List<String> analysis = [];
    if (char.skillScore >= 75) {
      analysis.add('Bạn sở hữu nền tảng Kỹ năng chuyên môn cực kỳ vững chắc (đạt ${char.skillScore.toInt()} điểm). Đây là bệ phóng lớn nhất giúp bạn giải quyết các bài toán kỹ thuật phức tạp.');
    } else if (char.skillScore < 45) {
      analysis.add('Chỉ số Kỹ năng của bạn khá thấp (dưới 45 điểm). Việc thiếu hụt chuyên môn sâu khiến bạn gặp khó khăn khi nhận các trọng trách kỹ thuật lớn.');
    }

    if (char.networkScore >= 70) {
      analysis.add('Bạn xây dựng mạng lưới Quan hệ (Network) chất lượng cao (đạt ${char.networkScore.toInt()} điểm), mang lại nhiều cơ hội giới thiệu nội bộ và sự dìu dắt từ các Mentor tài năng.');
    } else if (char.networkScore < 45) {
      analysis.add('Mối quan hệ xã hội khá hạn chế. Do ít tham gia cộng đồng và không tận dụng Mentor, bạn phải tự bơi và nhận các cơ hội muộn hơn hoặc ít chất lượng hơn.');
    }

    double maxBurnout = decisionsHistory.isEmpty ? 0.0 : decisionsHistory.map((d) => d.effects['burnout'] ?? 0.0).reduce(max);

    if (maxBurnout >= 25 || char.burnout >= 70) {
      analysis.add('Trạng thái Burnout (quá tải) nhiều lần chạm ngưỡng cao nguy hiểm. Áp lực công việc lớn và việc bỏ bê sức khỏe làm giảm Well-being, ảnh hưởng tiêu cực tới tốc độ tăng trưởng dài hạn.');
    } else {
      analysis.add('Bạn duy trì trạng thái cân bằng cuộc sống và công việc rất tốt (Well-being luôn ở mức an toàn). Điều này giúp bạn phát triển bền vững mà không bị kiệt sức.');
    }

    if (char.financeScore >= 150) {
      analysis.add('Tích lũy tài chính của bạn rất tốt (đạt ${char.financeScore.toInt()}M), nhờ vào các quyết định làm thêm thông minh, chọn lọc cơ hội và tiết kiệm hiệu quả.');
    } else if (char.financeScore < 50) {
      analysis.add('Tài sản tích lũy còn khiêm tốn. Có thể bạn đã chi tiêu nhiều cho học tập/thiết bị hoặc chọn các công việc thu nhập thấp ở giai đoạn đầu.');
    }

    // Lọc ra Top 3 quyết định có impactScore lớn nhất
    List<DecisionHistory> sortedDecisions = List.from(decisionsHistory);
    sortedDecisions.sort((a, b) => b.impactScore.compareTo(a.impactScore));

    List<String> topDecisions = [];
    for (int i = 0; i < min(3, sortedDecisions.length); i++) {
      final dec = sortedDecisions[i];
      topDecisions.add('Năm ${dec.year}: ${dec.eventTitle} (Bạn đã chọn: "${dec.subChoiceTitle}")');
    }

    List<String> recommendations = [];
    if (char.networkScore < 55) {
      recommendations.add('Thử tăng chỉ số Network sớm hơn (tham gia CLB lập trình năm 2026, học UI/UX năm 2027 để kết nối nhiều hơn). Mạng lưới quan hệ tốt giúp mở ra cơ hội nhanh hơn.');
    }
    if (char.wellBeingScore < 60 || char.burnout > 50) {
      recommendations.add('Giữ chỉ số Well-being trên 60 và quản lý Burnout dưới 50. Đừng quá ham cày cuốc thâu đêm, hãy lựa chọn phương án an toàn/cân bằng khi cần thiết.');
    }
    
    // Check if took short_course
    bool tookCourse = decisionsHistory.any((d) => d.eventId == 'short_course' && d.choiceId == 'uiux_learn');
    if (!tookCourse) {
      recommendations.add('Đầu tư tự học thêm kỹ năng ngoài giảng đường (như học thiết bị UI/UX năm 2027) sẽ giúp bạn mở rộng năng lực toàn diện sớm.');
    }
    
    if (char.skillScore < 60) {
      recommendations.add('Đầu tư mạnh mẽ hơn vào Kỹ năng chuyên môn ở 4 năm đầu sự nghiệp. Chọn phương án cày cuốc khi còn trẻ để tạo bệ phóng tốt.');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Thử các lựa chọn mạo hiểm hơn (như bỏ học khởi nghiệp Startup ở năm 2029) để trải nghiệm những biến động kịch tính khác của cuộc sống!');
    }

    return {
      'title': title,
      'details': details,
      'analysis': analysis,
      'topDecisions': topDecisions,
      'recommendations': recommendations,
    };
  }

  // Reset game
  void reset() {
    state = SimulationStateData(lifeLog: []);
  }
}

final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationStateData>((ref) {
  return SimulationNotifier();
});
