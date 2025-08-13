// vegetables_app/models/profile_model.dart

class Profile {
  final String success;
  final String error;
  final String name;
  final String mobileno;
  final String mail;
  final String? address;
  final String? profileimg; // This should be nullable
  final String? userId; // Example, if it exists in your model/response

  Profile({
    required this.success,
    required this.error,
    required this.name,
    required this.mobileno,
    required this.mail,
    this.address,
    this.profileimg,
    this.userId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    // Helper function to safely get a string, returning null if the value is null or empty
    String? _safeGetString(dynamic value) {
      if (value == null || value.toString().isEmpty) {
        return null;
      }
      return value.toString();
    }

    return Profile(
      // These are usually guaranteed to be strings and non-null by the API
      success: json['success'] as String,
      error: json['error'] as String,

      // These are likely always present and non-null in your case:
      name: json['name'] as String,
      mobileno: json['mobile'] as String,    // Using 'mobile' from your response
      mail: json['mail'] as String,        // Using 'mail' from your response

      // For potentially nullable fields, use the safe getter or direct cast to nullable String?
      // The issue is likely here, if 'address' or 'profile' can be '""' or 'null'
      address: _safeGetString(json['address']),
      profileimg: _safeGetString(json['profile']), // Map 'profile' from JSON to 'profileimg' in model
      userId: _safeGetString(json['userid']), // If 'userid' is in the response and can be null/empty
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'name': name,
      'mobile': mobileno,
      'mail': mail,
      'address': address, // Will send null if address is null
      'profileimg': profileimg, // Will send null if profileimg is null
      'userid': userId,
    };
  }

  // copyWith method for convenient local state updates in ProfileNotifier
  Profile copyWith({
    String? name,
    String? address,
    String? mail,
    String? profileimg,
    String? userId,
    String? success,
    String? error, required String mobileno,
  }) {
    return Profile(
      success: success ?? this.success,
      error: error ?? this.error,
      name: name ?? this.name,
      mobileno: mobileno ?? this.mobileno,
      address: address ?? this.address,
      mail: mail ?? this.mail,
      profileimg: profileimg ?? this.profileimg,
      userId: userId ?? this.userId,
    );
  }
}