class Character {
  final int year; // Năm mô phỏng (2026 -> 2036)
  final double careerScore; // Điểm chuyên môn, kinh nghiệm (0 -> 100)
  final double skillScore; // Điểm kỹ năng cứng & mềm (0 -> 100)
  final double networkScore; // Mối quan hệ, Mentor, đồng nghiệp (0 -> 100)
  final double financeScore; // Tài sản tích lũy (M VND)
  final double wellBeingScore; // Sức khỏe công việc (0 -> 100)
  final double burnout; // Mức độ quá tải (0 -> 100)
  final double currentIncome; // Thu nhập mỗi tháng (M VND)
  final String archetype;
  final bool isGameOver;
  final String? gameOverReason;

  // --- Hệ thống Tài nguyên của Năm ---
  final int timePoints; // Điểm thời gian khả dụng (mặc định 12 điểm mỗi năm)
  final int energyPoints; // Điểm năng lượng khả dụng (dựa trên wellBeingScore)
  final double moneyPoints; // Điểm tiền mặt khả dụng để tiêu dùng trong năm

  const Character({
    this.year = 2026,
    this.careerScore = 30,
    this.skillScore = 30,
    this.networkScore = 30,
    this.financeScore = 20,
    this.wellBeingScore = 80,
    this.burnout = 10,
    this.currentIncome = 0,
    required this.archetype,
    this.isGameOver = false,
    this.gameOverReason,
    this.timePoints = 12,
    this.energyPoints = 8,
    this.moneyPoints = 10,
  });

  // Tính khả năng tuyển dụng (Employability)
  double get employability {
    final score = (careerScore * 0.45) + (skillScore * 0.35) + (networkScore * 0.20);
    return score.clamp(0.0, 100.0);
  }

  // Tạo nhân vật từ Lớp nghề nghiệp + Bối cảnh cá nhân từ quiz
  factory Character.fromArchetype(String archetype, {Map<String, String> backgroundAnswers = const {}}) {
    double initialCareer = 30;
    double initialSkill = 30;
    double initialNetwork = 30;
    double initialFinance = 15;
    double initialWellBeing = 85;
    double initialIncome = 0;
    int initialTime = 12;

    // ── Base stats theo Archetype ────────────────────────
    switch (archetype) {
      case 'scientist':
        initialCareer = 35; initialSkill = 45; initialNetwork = 20; initialFinance = 15;
        break;
      case 'artist':
        initialCareer = 25; initialSkill = 40; initialNetwork = 30; initialWellBeing = 75;
        break;
      case 'leader':
        initialCareer = 40; initialSkill = 30; initialNetwork = 45; initialFinance = 20;
        break;
      case 'connector':
        initialCareer = 30; initialSkill = 25; initialNetwork = 50; initialFinance = 15;
        break;
      case 'executor':
        initialCareer = 35; initialSkill = 40; initialNetwork = 20; initialFinance = 10;
        break;
      case 'entrepreneur':
        initialCareer = 30; initialSkill = 30; initialNetwork = 35; initialFinance = 10;
        break;
      case 'explorer':
        initialCareer = 25; initialSkill = 35; initialNetwork = 30; initialFinance = 12;
        break;
      // Legacy archetypes
      case 'sage':
        initialCareer = 40; initialSkill = 40; initialNetwork = 20; initialFinance = 15;
        break;
      case 'creator':
        initialCareer = 30; initialSkill = 45; initialNetwork = 25; initialWellBeing = 75;
        break;
      case 'guardian':
        initialCareer = 35; initialSkill = 30; initialNetwork = 35; initialFinance = 25;
        break;
      case 'influencer':
        initialCareer = 25; initialSkill = 30; initialNetwork = 50; initialFinance = 20;
        break;
      case 'builder':
      default:
        initialCareer = 35; initialSkill = 35; initialNetwork = 25; initialFinance = 10;
        break;
    }

    // ── Điều chỉnh theo Trình độ học vấn ─────────────────
    switch (backgroundAnswers['educationLevel']) {
      case 'edu_highschool':
        // Mới THPT: không bonus
        break;
      case 'edu_vocational':
        initialSkill += 12; initialCareer += 8; initialFinance += 5;
        break;
      case 'edu_studying':
        initialSkill += 8; initialCareer += 5;
        break;
      case 'edu_graduated':
        initialSkill += 18; initialCareer += 20; initialFinance += 10;
        break;
      case 'edu_postgrad':
        initialSkill += 28; initialCareer += 30; initialNetwork += 10; initialFinance += 15;
        break;
    }

    // ── Điều chỉnh theo Tuổi ─────────────────────────────
    switch (backgroundAnswers['ageBracket']) {
      case 'age_teen':
        break; // không bonus
      case 'age_student':
        initialSkill += 5; initialNetwork += 5;
        break;
      case 'age_junior':
        initialSkill += 10; initialCareer += 10; initialNetwork += 10;
        break;
      case 'age_mid':
        initialSkill += 18; initialCareer += 20; initialNetwork += 20; initialFinance += 15;
        break;
      case 'age_senior':
        initialSkill += 25; initialCareer += 30; initialNetwork += 30; initialFinance += 25;
        break;
    }

    // ── Điều chỉnh theo Thu nhập ─────────────────────────
    switch (backgroundAnswers['monthlyIncome']) {
      case 'income_zero':
        initialIncome = 0; initialFinance += 0;
        break;
      case 'income_low':
        initialIncome = 4; initialFinance += 5;
        break;
      case 'income_mid':
        initialIncome = 10; initialFinance += 15;
        break;
      case 'income_high':
        initialIncome = 22; initialFinance += 30;
        break;
      case 'income_very_high':
        initialIncome = 35; initialFinance += 50;
        break;
    }

    // ── Điều chỉnh theo Tình trạng hiện tại ─────────────
    switch (backgroundAnswers['currentStatus']) {
      case 'status_studying':
        initialTime = 12;
        break;
      case 'status_working':
        initialTime = 8; initialCareer += 5; initialSkill += 5;
        break;
      case 'status_both':
        initialTime = 6; initialSkill += 8; initialCareer += 8;
        break;
      case 'status_seeking':
        initialTime = 12; initialWellBeing -= 5;
        break;
      case 'status_gap':
        initialTime = 12; initialWellBeing += 5;
        break;
    }

    // Clamp tất cả về giới hạn hợp lệ
    initialCareer = initialCareer.clamp(0, 95);
    initialSkill = initialSkill.clamp(0, 95);
    initialNetwork = initialNetwork.clamp(0, 95);
    initialFinance = initialFinance.clamp(0, double.infinity);
    initialWellBeing = initialWellBeing.clamp(20, 100);

    final initialEnergy = (initialWellBeing / 10).round().clamp(2, 12);

    return Character(
      year: 2026,
      careerScore: initialCareer,
      skillScore: initialSkill,
      networkScore: initialNetwork,
      financeScore: initialFinance,
      wellBeingScore: initialWellBeing,
      burnout: 10,
      currentIncome: initialIncome,
      archetype: archetype,
      timePoints: initialTime,
      energyPoints: initialEnergy,
      moneyPoints: initialFinance > 0 ? initialFinance * 0.5 : 5,
    );
  }



  Character copyWith({
    int? year,
    double? careerScore,
    double? skillScore,
    double? networkScore,
    double? financeScore,
    double? wellBeingScore,
    double? burnout,
    double? currentIncome,
    String? archetype,
    bool? isGameOver,
    String? gameOverReason,
    int? timePoints,
    int? energyPoints,
    double? moneyPoints,
  }) {
    return Character(
      year: year ?? this.year,
      careerScore: (careerScore ?? this.careerScore).clamp(0.0, 100.0),
      skillScore: (skillScore ?? this.skillScore).clamp(0.0, 100.0),
      networkScore: (networkScore ?? this.networkScore).clamp(0.0, 100.0),
      financeScore: financeScore ?? this.financeScore,
      wellBeingScore: (wellBeingScore ?? this.wellBeingScore).clamp(0.0, 100.0),
      burnout: (burnout ?? this.burnout).clamp(0.0, 100.0),
      currentIncome: currentIncome ?? this.currentIncome,
      archetype: archetype ?? this.archetype,
      isGameOver: isGameOver ?? this.isGameOver,
      gameOverReason: gameOverReason ?? this.gameOverReason,
      timePoints: timePoints ?? this.timePoints,
      energyPoints: energyPoints ?? this.energyPoints,
      moneyPoints: moneyPoints ?? this.moneyPoints,
    );
  }
}
