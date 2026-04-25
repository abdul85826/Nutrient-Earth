
import '../core/models/app_models.dart';

/// Simple representation of health state returned by [HealthEngine].
class HealthState {
  final String hydration;
  final String energy;
  final String reason;
  final String metabolicWhy;
  final String biologicalImpact;
  final List<String> actions;
  final List<ActionStep> recommendedTasks;
  final List<String> recommendedProductIds;

  HealthState({
    required this.hydration,
    required this.energy,
    required this.reason,
    required this.metabolicWhy,
    required this.biologicalImpact,
    required this.actions,
    required this.recommendedTasks,
    required this.recommendedProductIds,
  });
}

class HealthEngine {
  static HealthState interpret({
    required String text,
    required List<String> tags,
  }) {
    int waterIntake = 2000;
    int energyLevel = 3;
    double temperature = 36.6;
    int acidityLevel = 2; // 1-5 scale

    final combinedInput = "$text ${tags.join(" ")}".toLowerCase();

    // Interpretation Mapping
    if (combinedInput.contains('tired') || combinedInput.contains('exhausted') || combinedInput.contains('fatigued')) {
      energyLevel = 1;
    } else if (combinedInput.contains('heavy') || combinedInput.contains('bloated') || combinedInput.contains('sluggish')) {
      energyLevel = 2;
      acidityLevel = 4; // Sluggish often linked to acidity/load
    } else if (combinedInput.contains('fresh') || combinedInput.contains('energetic') || combinedInput.contains('sharp') || combinedInput.contains('focused')) {
      energyLevel = 5;
      acidityLevel = 1;
    }

    if (combinedInput.contains('dry') || combinedInput.contains('thirsty') || combinedInput.contains('parched')) {
      waterIntake = 800;
    } else if (combinedInput.contains('hydrated') || combinedInput.contains('water')) {
      waterIntake = 3000;
    }

    if (combinedInput.contains('burning') || combinedInput.contains('acidic') || combinedInput.contains('heartburn')) {
      temperature = 38.8;
      acidityLevel = 5;
    } else if (combinedInput.contains('stressed') || combinedInput.contains('anxious') || combinedInput.contains('panic') || combinedInput.contains('overwhelmed')) {
      temperature = 38.2;
      acidityLevel = 4;
      energyLevel = energyLevel > 3 ? 3 : energyLevel; // Stress drains energy
    }

    return process(
      waterIntake: waterIntake,
      energyLevel: energyLevel,
      temperature: temperature,
      acidityLevel: acidityLevel,
    );
  }

  static HealthState process({
    required int waterIntake,
    required int energyLevel,
    required double temperature,
    int acidityLevel = 2,
  }) {
    String hydration = waterIntake < 1500 ? "LOW" : (waterIntake < 3000 ? "NORMAL" : "HIGH");
    String energy = energyLevel <= 2 ? "LOW" : (energyLevel >= 4 ? "HIGH" : "NORMAL");

    String reason = '';
    String metabolicWhy = '';
    String biologicalImpact = '';
    List<String> actions = [];
    List<ActionStep> tasks = [];
    List<String> products = [];

    // Logic for Energy
    if (energyLevel <= 2) {
      reason = 'Biological fatigue detected.';
      metabolicWhy = 'Glycogen depletion and elevated cortisol are disrupting mitochondrial ATP production.';
      biologicalImpact = 'Prolonged state leads to muscle catabolism and cognitive fog.';
      actions.add('10-minute sunlight exposure');
      tasks.add(ActionStep(
        id: 'task_sun',
        title: 'SUNLIGHT EXPOSURE',
        instruction: '10 mins of direct sunlight.',
        benefit: 'Regulates circadian rhythm and resets cortisol.',
      ));
      products.add('2');
    } else if (energyLevel >= 4) {
      reason = 'Optimal energy resonance.';
      metabolicWhy = 'Efficient lipid oxidation and balanced neurotransmitters (Dopamine/Serotonin).';
      biologicalImpact = 'Peak cognitive performance and accelerated tissue repair.';
      tasks.add(ActionStep(
        id: 'task_flow',
        title: 'FLOW STATE SESSION',
        instruction: 'Engage in 90 mins of deep work.',
        benefit: 'Capitalizes on current neurochemical peak.',
      ));
    } else {
      reason = 'System stability maintained.';
      metabolicWhy = 'Basal metabolic rate is steady with normal hormonal feedback.';
      biologicalImpact = 'Standard physiological maintenance.';
    }

    // Logic for Hydration
    if (hydration == "LOW") {
      metabolicWhy += ' Cellular osmosis is restricted due to low solvent volume.';
      biologicalImpact += ' Increased blood viscosity and reduced toxin clearance.';
      actions.add('Drink 500ml structured water');
      tasks.add(ActionStep(
        id: 'task_water',
        title: 'HYDRATION BOOST',
        instruction: 'Drink 500ml mineralized water.',
        benefit: 'Restores electrolyte balance and blood flow.',
      ));
      products.add('1');
    }

    // Logic for Acidity/Heat/Stress
    if (acidityLevel >= 4 || temperature > 37.5) {
      if (reason.isEmpty) reason = 'Internal resonance shift.';
      metabolicWhy += ' Oxidative stress is triggering inflammatory cytokines and mitochondrial uncoupling.';
      biologicalImpact += ' Potential for DNA damage and accelerated cellular aging.';
      
      if (acidityLevel == 4 && energyLevel <= 2) {
        // Heavy/Sluggish case
        actions.add('Digestive botanical infusion');
        tasks.add(ActionStep(
          id: 'task_digest',
          title: 'METABOLIC WALK',
          instruction: '15 mins light movement.',
          benefit: 'Clears lymphatic system and aids ATP recycling.',
        ));
      } else {
        actions.add('Cooling botanical infusion');
        tasks.add(ActionStep(
          id: 'task_breath',
          title: 'BOX BREATHING',
          instruction: '4 cycles of 4-4-4-4 breathing.',
          benefit: 'Reduces cortisol and internal heat.',
        ));
      }
      products.add('3');
    }

    if (tasks.isEmpty) {
      tasks.add(ActionStep(
        id: 'task_default',
        title: 'MAINTAIN PROTOCOL',
        instruction: 'Continue current wellness routine.',
        benefit: 'Ensures long-term stability.',
      ));
    }

    if (products.isEmpty) {
      products.addAll(['1', '4']);
    }

    return HealthState(
      hydration: hydration,
      energy: energy,
      reason: reason,
      metabolicWhy: metabolicWhy,
      biologicalImpact: biologicalImpact,
      actions: actions,
      recommendedTasks: tasks,
      recommendedProductIds: products,
    );
  }
}