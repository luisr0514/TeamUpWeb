class FormValidators {
  static String? required(String? v, [String msg = 'Este campo es requerido']) {
    if (v == null || v.trim().isEmpty) return msg;
    return null;
  }

  static String? isNumeric(String? v, [String msg = 'Debe ser un número']) {
    if (v == null || v.isEmpty) return null;
    if (double.tryParse(v) == null) return msg;
    return null;
  }

  static String? isPositiveNumber(String? v, [String msg = 'No puede ser negativo']) {
    if (v == null || v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n != null && n < 0) return msg;
    return null;
  }

  /// Valida un teléfono (solo dígitos, entre 7 y 15 caracteres, opcional “+”)
  static String? phone(String? v, [String msg = 'Teléfono inválido']) {
    if (v == null || v.trim().isEmpty) return msg;
    final pattern = RegExp(r'^\+?[0-9]{7,15}$');
    if (!pattern.hasMatch(v.trim())) return msg;
    return null;
  }

  /// Valida un email básico
  static String? email(String? v, [String msg = 'Email inválido']) {
    if (v == null || v.trim().isEmpty) return msg;
    final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!pattern.hasMatch(v.trim())) return msg;
    return null;
  }

  /// Combina varios validadores
  static String? compose(String? v, List<String? Function(String?)> vs) {
    for (final fn in vs) {
      final error = fn(v);
      if (error != null) return error;
    }
    return null;
  }
}
