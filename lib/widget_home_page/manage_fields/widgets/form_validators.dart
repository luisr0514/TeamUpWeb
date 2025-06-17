class FormValidators {
  static String? required(String? value, [String message = 'Este campo es requerido']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? isNumeric(String? value, [String message = 'Debe ser un valor numérico']) {
    if (value == null || value.isEmpty) return null; // 'required' validator handles this
    if (double.tryParse(value) == null) {
      return message;
    }
    return null;
  }

  static String? isPositiveNumber(String? value, [String message = 'El valor no puede ser negativo']) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number != null && number < 0) {
      return message;
    }
    return null;
  }

  static String? isUrl(String? value, [String message = 'Debe ser una URL válida']) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.isAbsolute) {
      return message;
    }
    return null;
  }

  // Combina múltiples validadores
  static String? compose(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}