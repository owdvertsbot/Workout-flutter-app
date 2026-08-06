// Adaptive Health - Evidence Service
// Provides scientific explanations for all recommendations

import '../models/models.dart';

/// Service for managing and presenting evidence-based explanations
class EvidenceService {
  /// Get explanation for why a specific exercise is recommended
  static String getExerciseRationale(ExercisePrescription exercise, UserProfile profile) {
    List<String> reasons = [];
    
    // Add exercise-specific reasons
    reasons.add(_getExerciseTypeRationale(exercise.type));
    
    // Add goal-specific reasons
    reasons.add(_getGoalSpecificRationale(profile.primaryGoal, exercise.type));
    
    // Add accessibility reasons if applicable
    if (exercise.accessibilityMods.isNotEmpty) {
      reasons.add(_getAccessibilityRationale(exercise.accessibilityMods.first));
    }
    
    return reasons.join('\n\n');
  }
  
  static String _getExerciseTypeRationale(ExercisePrescriptionType type) {
    switch (type) {
      case ExercisePrescriptionType.warmup:
        return '热身准备身体进行主要训练，减少受伤风险，提高运动表现。';
      case ExercisePrescriptionType.strength:
        return '力量训练增加肌肉质量和骨密度，改善代谢健康，增强日常功能能力。';
      case ExercisePrescriptionType.hypertrophy:
        return '肌肉肥大训练通过机械张力和代谢应激刺激肌肉生长。';
      case ExercisePrescriptionType.cardio:
        return '心血管训练改善心脏和肺部功能，降低慢性疾病风险。';
      case ExercisePrescriptionType.flexibility:
        return '柔韧性训练改善关节活动范围，减少受伤风险。';
      case ExercisePrescriptionType.balance:
        return '平衡训练提高本体感觉和协调性，特别对老年人重要。';
      case ExercisePrescriptionType.functional:
        return '功能性训练模拟日常动作模式，提高整体运动能力。';
      case ExercisePrescriptionType.mobility:
        return '关节活动训练改善关节灵活性，支持更好的运动表现。';
      case ExercisePrescriptionType.cooldown:
        return '冷却活动帮助身体恢复正常状态，减少肌肉酸痛。';
    }
  }
  
  static String _getGoalSpecificRationale(HealthGoal goal, ExercisePrescriptionType type) {
    switch (goal) {
      case HealthGoal.fatLoss:
        return '这种训练方式有助于增加能量消耗，支持脂肪减少。结合适当的热量赤字，可以有效降低体脂。';
      case HealthGoal.muscleGain:
        return '这个练习针对主要肌群，有助于增加肌肉质量。肌肉增加可以提高基础代谢率。';
      case HealthGoal.strength:
        return '这个练习有助于提高最大力量和神经肌肉效率。';
      case HealthGoal.generalHealth:
        return '这种训练支持整体健康，包括心血管健康、肌肉力量和灵活性。';
      case HealthGoal.endurance:
        return '这个练习有助于提高有氧和无氧耐力。';
    }
  }
  
  static String _getAccessibilityRationale(AccessibilityModification mod) {
    return '由于您的健康状况，我们选择了这个替代练习：${mod.description}。${mod.reason}';
  }
  
  /// Get explanation for prescription dose (sets, reps, rest)
  static String getDoseRationale(ExercisePrescription exercise) {
    StringBuffer rationale = StringBuffer();
    
    // Sets explanation
    rationale.writeln('**组数: ${exercise.targetSets}组**');
    if (exercise.targetSets >= 3) {
      rationale.writeln('3组或更多训练已被证明能有效刺激肌肉生长和力量提高。');
    } else {
      rationale.writeln('1-2组足以提供训练刺激，同时保持效率。');
    }
    
    // Reps explanation
    rationale.writeln('\n**次数: ${exercise.repRangeDisplay}次**');
    if (exercise.targetReps <= 6) {
      rationale.writeln('较低的次数范围（1-6次）主要提高最大力量。');
    } else if (exercise.targetReps <= 12) {
      rationale.writeln('中等次数范围（8-12次）在增肌和增力之间取得良好平衡。');
    } else {
      rationale.writeln('较高次数范围（15+次）提高肌肉耐力和代谢应激。');
    }
    
    // Rest explanation
    rationale.writeln('\n**休息时间: ${exercise.restSeconds}秒**');
    if (exercise.restSeconds <= 60) {
      rationale.writeln('短休息时间增加代谢应激和泵感。');
    } else if (exercise.restSeconds <= 90) {
      rationale.writeln('中等休息时间平衡能量系统和肌肉恢复。');
    } else {
      rationale.writeln('较长休息时间确保完全恢复，适合大重量训练。');
    }
    
    // Tempo if specified
    if (exercise.tempo != null) {
      rationale.writeln('\n**节奏: ${exercise.tempo!.display}**');
      rationale.writeln('控制的动作节奏增加肌肉在张力下的时间（Time Under Tension），促进肌肉生长。');
    }
    
    return rationale.toString();
  }
  
  /// Get explanation for nutrition targets
  static String getNutritionRationale(UserProfile profile) {
    StringBuffer rationale = StringBuffer();
    
    // Calories
    rationale.writeln('**目标热量: ${profile.targetCalories.round()}千卡/天**\n');
    
    switch (profile.primaryGoal) {
      case HealthGoal.fatLoss:
        rationale.writeln('为了安全有效地减少脂肪，我们建议每天产生约20%的热量赤字。');
        rationale.writeln('这种适度的热量限制可以保持肌肉，同时促进脂肪减少。');
        break;
      case HealthGoal.muscleGain:
        rationale.writeln('为了支持肌肉生长，我们建议每天摄入约10%的热量盈余。');
        rationale.writeln('这提供了额外的能量和营养物质来支持蛋白质合成。');
        break;
      case HealthGoal.strength:
        rationale.writeln('为了优化力量表现，我们建议轻微的热量盈余来支持训练恢复。');
        break;
      case HealthGoal.generalHealth:
      case HealthGoal.endurance:
        rationale.writeln('这个热量目标支持您的日常活动和训练需求。');
        break;
    }
    
    // Protein
    rationale.writeln('\n**目标蛋白质: ${profile.targetProteinGrams.round()}克/天**\n');
    rationale.writeln('蛋白质摄入对于：');
    rationale.writeln('• 肌肉修复和生长');
    rationale.writeln('• 饱腹感维持');
    rationale.writeln('• 基础代谢率支持');
    
    if (profile.primaryGoal == HealthGoal.fatLoss) {
      rationale.writeln('\n在减脂期间，较高的蛋白质摄入（每公斤体重2.0-2.2克）有助于：');
      rationale.writeln('• 保持肌肉质量');
      rationale.writeln('• 增加饱腹感');
      rationale.writeln('• 支持免疫功能');
    }
    
    return rationale.toString();
  }
  
  /// Get explanation for recovery recommendations
  static String getRecoveryRationale(RecoveryPrescription prescription) {
    StringBuffer rationale = StringBuffer();
    
    // Sleep
    rationale.writeln('**睡眠目标: ${prescription.sleep.targetHours}小时**\n');
    rationale.writeln('充足的睡眠对健康至关重要：');
    rationale.writeln('• 肌肉在睡眠期间恢复和生长');
    rationale.writeln('• 睡眠调节荷尔蒙包括生长激素和皮质醇');
    rationale.writeln('• 睡眠支持免疫功能和认知能力');
    
    if (prescription.sleep.targetHours >= 8) {
      rationale.writeln('\n建议每晚8小时或更多睡眠来支持最佳恢复。');
    }
    
    // Readiness-based recommendations
    if (prescription.restDayScore > 60) {
      rationale.writeln('\n**恢复建议：**');
      rationale.writeln('今天的训练强度已根据您的恢复状态进行了调整。');
      rationale.writeln('如果感到疲劳或酸痛，优先选择轻度活动或休息。');
    }
    
    return rationale.toString();
  }
  
  /// Format evidence source for display
  static String formatEvidenceSource(EvidenceSource source) {
    StringBuffer formatted = StringBuffer();
    
    formatted.writeln('**${source.title}**');
    formatted.writeln('${source.authors}');
    formatted.writeln('${source.journal}${source.year != null ? ', ${source.year}' : ''}');
    formatted.writeln('证据等级: ${source.level.label}');
    
    if (source.relevance.isNotEmpty) {
      formatted.writeln('\n相关性: ${source.relevance}');
    }
    
    return formatted.toString();
  }
  
  /// Generate a "Why?" explanation card content
  static Map<String, String> generateWhyExplanation({
    required String topic,
    required dynamic recommendation,
    required UserProfile profile,
  }) {
    switch (topic) {
      case 'exercise':
        return {
          'title': '为什么推荐这个练习？',
          'content': getExerciseRationale(
            recommendation as ExercisePrescription,
            profile,
          ),
        };
      case 'dose':
        return {
          'title': '为什么是这个强度？',
          'content': getDoseRationale(recommendation as ExercisePrescription),
        };
      case 'nutrition':
        return {
          'title': '为什么是这个目标？',
          'content': getNutritionRationale(profile),
        };
      case 'recovery':
        return {
          'title': '为什么需要恢复？',
          'content': getRecoveryRationale(recommendation as RecoveryPrescription),
        };
      default:
        return {
          'title': '科学依据',
          'content': '这个建议基于当前的最佳实践和科学研究。',
        };
    }
  }
}
