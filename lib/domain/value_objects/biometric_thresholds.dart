/// Value object representing a biological human age limit.
class BiologicalAge {
  final int value;

  BiologicalAge(this.value) {
    if (value < 0 || value > 130) {
      throw ArgumentError('Invalid biological age window. Must be between 0 and 130. Got: $value');
    }
  }
}

/// Value object validating safe human body weight bounds.
class BiologicalWeight {
  final double value;

  BiologicalWeight(this.value) {
    if (value < 2.0 || value > 600.0) {
      throw ArgumentError('Body weight value ($value kg) is clinically outside human parameters.');
    }
  }
}

/// Value object validating safe human body height bounds.
class BiologicalHeight {
  final double value;

  BiologicalHeight(this.value) {
    if (value < 30.0 || value > 300.0) {
      throw ArgumentError('Body height value ($value cm) is clinically outside human parameters.');
    }
  }
}
