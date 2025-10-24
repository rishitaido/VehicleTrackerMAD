// Form validators for Vehicle and Maintenance screens
class Validators {
  // Validate required field
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Validate year
  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year is required';
    }
    
    final year = int.tryParse(value);
    if (year == null) {
      return 'Year must be a number';
    }
    
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Year must be between 1900 and ${currentYear + 1}';
    }
    
    return null;
  }
  
  // Validate mileage
  static String? mileage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mileage is required';
    }
    
    final mileage = int.tryParse(value);
    if (mileage == null) {
      return 'Mileage must be a number';
    }
    
    if (mileage < 0) {
      return 'Mileage cannot be negative';
    }
    
    return null;
  }
  
  // Validate mileage with max check
  static String? mileageWithMax(String? value, int maxMileage) {
    final basicError = mileage(value);
    if (basicError != null) return basicError;
    
    final mileageValue = int.parse(value!);
    if (mileageValue > maxMileage) {
      return 'Mileage ($mileageValue) cannot exceed $maxMileage';
    }
    
    return null;
  }
  
  // Validate mileage increase (for editing vehicle)
  static String? mileageIncrease(String? value, int currentMileage) {
    final basicError = mileage(value);
    if (basicError != null) return basicError;
    
    final newMileage = int.parse(value!);
    if (newMileage < currentMileage) {
      return 'New mileage ($newMileage) cannot be less than current mileage ($currentMileage)';
    }
    
    return null;
  }
  
  // Validate cost/price
  static String? cost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cost is required';
    }
    
    final cost = double.tryParse(value);
    if (cost == null) {
      return 'Cost must be a number';
    }
    
    if (cost < 0) {
      return 'Cost cannot be negative';
    }
    
    return null;
  }
  
  // Validate optional cost (can be empty)
  static String? optionalCost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // OK to be empty
    }
    
    final cost = double.tryParse(value);
    if (cost == null) {
      return 'Cost must be a number';
    }
    
    if (cost < 0) {
      return 'Cost cannot be negative';
    }
    
    return null;
  }
  
  // Validate VIN (17 characters, alphanumeric)
  static String? vin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // VIN is optional
    }
    
    final vin = value.trim();
    if (vin.length != 17) {
      return 'VIN must be exactly 17 characters';
    }
    
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]+$').hasMatch(vin)) {
      return 'VIN contains invalid characters';
    }
    
    return null;
  }
  
  /// Validate email (if needed in future)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate optional email
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // OK to be empty
    }
    
    return email(value);
  }
  
  /// Validate phone
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone is required';
    }
    
    // Remove all non-digits
    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length < 10) {
      return 'Phone must have at least 10 digits';
    }
    
    return null;
  }
  
  // Validate optional phone
  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // OK to be empty
    }
    
    return phone(value);
  }
  
  // Validate min length
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }
  
  // Validate max length
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value == null) return null;
    
    if (value.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    
    return null;
  }
}