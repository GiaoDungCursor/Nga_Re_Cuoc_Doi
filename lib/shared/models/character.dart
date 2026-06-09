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

  // Tạo nhân vật từ Lớp nghề nghiệp ban đầu
  factory Character.fromArchetype(String archetype) {
    double initialCareer = 30;
    double initialSkill = 30;
    double initialNetwork = 30;
    double initialFinance = 15;
    double initialWellBeing = 85;

    switch (archetype) {
      case 'sage':
        initialCareer = 40;
        initialSkill = 40;
        initialNetwork = 20;
        initialFinance = 15;
        break;
      case 'creator':
        initialCareer = 30;
        initialSkill = 45;
        initialNetwork = 25;
        initialWellBeing = 75;
        break;
      case 'guardian':
        initialCareer = 35;
        initialSkill = 30;
        initialNetwork = 35;
        initialFinance = 25;
        break;
      case 'influencer':
        initialCareer = 25;
        initialSkill = 30;
        initialNetwork = 50;
        initialFinance = 20;
        break;
      case 'builder':
      default:
        initialCareer = 35;
        initialSkill = 35;
        initialNetwork = 25;
        initialFinance = 10;
        break;
    }

    // Năng lượng ban đầu tính bằng công thức: wellBeing / 10
    final initialEnergy = (initialWellBeing / 10).round().clamp(2, 12);

    return Character(
      year: 2026,
      careerScore: initialCareer,
      skillScore: initialSkill,
      networkScore: initialNetwork,
      financeScore: initialFinance,
      wellBeingScore: initialWellBeing,
      burnout: 10,
      currentIncome: 0,
      archetype: archetype,
      timePoints: 12,
      energyPoints: initialEnergy,
      moneyPoints: initialFinance, // Khởi đầu tiền tiêu dùng bằng tài sản tích lũy ban đầu
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
