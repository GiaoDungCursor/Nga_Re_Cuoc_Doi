import 'character.dart';

enum DecisionWeight {
  small,
  medium,
  turningPoint,
}

class ResourceCost {
  final int time;
  final int energy;
  final double money;

  const ResourceCost({
    this.time = 0,
    this.energy = 0,
    this.money = 0.0,
  });

  // Kiểm tra xem nhân vật có đủ tài nguyên chi trả không
  bool isAffordableBy(Character character) {
    return character.timePoints >= time &&
           character.energyPoints >= energy &&
           character.moneyPoints >= money;
  }
}

class DecisionHistory {
  final int year;
  final String eventId;
  final String eventTitle;
  final String choiceId;
  final String subChoiceId;
  final String subChoiceTitle;
  final DecisionWeight weight;
  final Map<String, double> effects;
  final double impactScore;
  final String log;

  const DecisionHistory({
    required this.year,
    required this.eventId,
    required this.eventTitle,
    required this.choiceId,
    required this.subChoiceId,
    required this.subChoiceTitle,
    required this.weight,
    required this.effects,
    required this.impactScore,
    required this.log,
  });
}

class Event {
  final String id;
  final String title;
  final String description;
  final String type; // 'choice' | 'random'
  final String category; // 'career' | 'skill' | 'opportunity' | 'economic' | 'ai'
  final DecisionWeight weight;
  final int minYear;
  final int maxYear;
  final List<Choice> choices;
  final Map<String, dynamic>? triggerConditions;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.weight,
    this.minYear = 2026,
    this.maxYear = 2036,
    required this.choices,
    this.triggerConditions,
  });

  bool canTrigger(int currentYear, double currentWellBeing, double currentFinance, double currentCareer, double currentEmployability) {
    if (currentYear < minYear || currentYear > maxYear) return false;
    
    if (triggerConditions != null) {
      if (triggerConditions!.containsKey('well_being_below')) {
        if (currentWellBeing >= (triggerConditions!['well_being_below'] as num)) return false;
      }
      if (triggerConditions!.containsKey('finance_above')) {
        if (currentFinance <= (triggerConditions!['finance_above'] as num)) return false;
      }
      if (triggerConditions!.containsKey('career_above')) {
        if (currentCareer <= (triggerConditions!['career_above'] as num)) return false;
      }
      if (triggerConditions!.containsKey('employability_below')) {
        if (currentEmployability >= (triggerConditions!['employability_below'] as num)) return false;
      }
    }
    return true;
  }
}

class Choice {
  final String id;
  final String title;
  final String description;
  final List<SubChoice> subChoices;

  const Choice({
    required this.id,
    required this.title,
    required this.description,
    required this.subChoices,
  });
}

class SubChoice {
  final String id;
  final String title;
  final String description;
  final ResourceCost cost;
  final Map<String, double> effects; // e.g. {'careerScore': 10, 'burnout': 15}
  final String log;

  const SubChoice({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.effects,
    required this.log,
  });
}
