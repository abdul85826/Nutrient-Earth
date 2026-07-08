enum ConditionCategory {
  metabolic,
  energy,
  digestive,
  mental,
}

class HealthKnowledgeBase {
  /// Structured Symptoms Map
  /// Maps symptom keys to their ConditionCategory and Primary Cause.
  static const Map<String, Map<String, dynamic>> symptomsMap = {
    'prediabetes': {
      'category': ConditionCategory.metabolic,
      'cause': 'Insulin Resistance & Poor Glucose Clearance',
    },
    'type 2': {
      'category': ConditionCategory.metabolic,
      'cause': 'Insulin Resistance & Poor Glucose Clearance',
    },
    'weight gain': {
      'category': ConditionCategory.metabolic,
      'cause': 'Metabolic Slowdown & Caloric Surplus',
    },
    'weight loss': {
      'category': ConditionCategory.metabolic,
      'cause': 'High Insulin & Stubborn Adipose Tissue',
    },
    'fatigue': {
      'category': ConditionCategory.energy,
      'cause': 'Cellular Mitochondrial Dysfunction & Dehydration',
    },
    'low energy': {
      'category': ConditionCategory.energy,
      'cause': 'Cellular Mitochondrial Dysfunction & Dehydration',
    },
    'sleep issues': {
      'category': ConditionCategory.energy,
      'cause': 'Circadian Rhythm Disruption & Evening Cortisol Spikes',
    },
    'bloating': {
      'category': ConditionCategory.digestive,
      'cause': 'Low Stomach Acid & Gut Dysbiosis',
    },
    'acidity': {
      'category': ConditionCategory.digestive,
      'cause': 'Low Stomach Acid & Gut Dysbiosis',
    },
    'constipation': {
      'category': ConditionCategory.digestive,
      'cause': 'Slow Gastric Motility & Dehydration',
    },
    'stress': {
      'category': ConditionCategory.mental,
      'cause': 'Nervous System Dysregulation (Sympathetic Dominance)',
    },
    'anxiety': {
      'category': ConditionCategory.mental,
      'cause': 'Nervous System Dysregulation (Sympathetic Dominance)',
    },
    'brain fog': {
      'category': ConditionCategory.mental,
      'cause': 'Neuro-inflammation & Glucose Spikes',
    },
    'low activity': {
      'category': ConditionCategory.energy,
      'cause': 'Sedentary Cellular Stagnation',
    },
  };

  /// Structured Remedies Map
  /// Includes safety metadata (safe_for, avoid_for).
  static const Map<String, Map<String, dynamic>> remediesMap = {
    'acv_water': {
      'title': 'ACV Primer',
      'instruction': 'Drink 300ml warm water with 1 tbsp Apple Cider Vinegar.',
      'benefit': 'Improves morning insulin sensitivity.',
      'timing': 'Morning',
      'safe_for': ['diabetic', 'weight_loss'],
      'avoid_for': ['acid_reflux', 'gastritis'],
    },
    'lemon_water': {
      'title': 'Acid Primer',
      'instruction': 'Drink 300ml water with half a lemon squeezed.',
      'benefit': 'Stimulates gastric juices and liver bile.',
      'timing': 'Morning',
      'safe_for': ['digestion', 'fatigue'],
      'avoid_for': ['gastritis'],
    },
    'bitter_gourd_juice': {
      'title': 'Glucose Stabilizer',
      'instruction': '50ml fresh bitter gourd juice on an empty stomach.',
      'benefit': 'Mimics insulin to lower blood sugar naturally.',
      'timing': 'Morning',
      'safe_for': ['diabetic'],
      'avoid_for': ['underweight', 'pregnancy'],
    },
    'mineral_water': {
      'title': 'Cellular Hydration',
      'instruction': 'Drink 300ml warm water with a pinch of sea salt.',
      'benefit': 'Replenishes electrolytes and jumpstarts mitochondria.',
      'timing': 'Morning',
      'safe_for': ['fatigue', 'low_bp'],
      'avoid_for': ['high_bp'],
    },
    'fasted_walk': {
      'title': 'Fasted Walk',
      'instruction': '10 min brisk walk before breakfast.',
      'benefit': 'Clears fasting blood glucose.',
      'timing': 'Morning',
      'safe_for': ['diabetic', 'metabolic'],
      'avoid_for': [],
    },
    'protein_fiber_first': {
      'title': 'Smart Sequencing',
      'instruction': 'Eat protein and fiber first before touching carbs.',
      'benefit': 'Reduces post-meal glucose spikes by up to 70%.',
      'timing': 'Afternoon',
      'safe_for': ['diabetic', 'weight_loss'],
      'avoid_for': [],
    },
    'post_dinner_walk': {
      'title': 'Glucose Clearance',
      'instruction': '15 min post-dinner walk.',
      'benefit': 'Pushes glucose into muscles instead of fat storage.',
      'timing': 'Evening',
      'safe_for': ['diabetic', 'metabolic'],
      'avoid_for': [],
    },
    'magnesium_soak': {
      'title': 'Magnesium Reset',
      'instruction': '20 min Epsom salt foot soak.',
      'benefit': 'Absorbs magnesium to relax nervous system.',
      'timing': 'Evening',
      'safe_for': ['stress', 'insomnia'],
      'avoid_for': ['skin_infections'],
    },
    'digital_sunset': {
      'title': 'Digital Sunset',
      'instruction': 'Turn off all screens. Read a book or stretch.',
      'benefit': 'Allows brain to down-regulate for deep rest.',
      'timing': 'Night',
      'safe_for': ['all'],
      'avoid_for': [],
    },
  };

  /// Minimum Plan Templates
  static const Map<String, List<String>> minimumPlanTemplates = {
    'diabetic': [
      'bitter_gourd_juice',
      'protein_fiber_first',
      'post_dinner_walk',
    ],
    'fatigue': ['mineral_water', 'fasted_walk', 'digital_sunset'],
    'digestion': ['lemon_water', 'protein_fiber_first', 'digital_sunset'],
  };
}
