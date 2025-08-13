import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; // Import for BuildContext
import 'package:vegetables_app/models/profile_model.dart';
// import 'package:vegetables_app/screens/UpdateProfileRes.dart'; // This import is not used in the provider file
import 'package:vegetables_app/services/profile_service.dart'; // Make sure this path is correct

// Provider for the ProfileService
final profileServiceProvider = Provider((ref) => ProfileService());

// FutureProvider for fetching the initial user profile
final profileFutureProvider = FutureProvider.autoDispose<Profile>((ref) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.fetchProfile();
});

// StateNotifier to manage the mutable profile data (for local updates and UI rebuilds)
class ProfileNotifier extends StateNotifier<Profile?> {
  final ProfileService _profileService;

  ProfileNotifier(this._profileService) : super(null);

  // Initialize the profile with fetched data
  void setProfile(Profile profile) {
    state = profile;
  }

  // Update profile locally and then call the API
  // IMPORTANT: Add BuildContext as a parameter here
  Future<void> updateProfile({ // Changed return type to void as SnackBar is handled by service
    required BuildContext context, // <--- ADDED BuildContext parameter
    required String name,
    required String mobileno,
    required String mail,
    String? address,
    String? profileimg, // Added profileimg parameter
  }) async {
    try {
      // Optimistic update: update locally first for a snappier UI
      // Ensure your Profile model has a 'profileimg' field for this to work correctly.
      // Also, ensure all non-nullable fields of Profile are handled if state is null
      state = state?.copyWith(
        name: name,
        mobileno: mobileno,
        mail: mail,
        address: address,
        profileimg: profileimg, // Pass profileimg to copyWith
      ) ?? Profile(
        // Provide default values for all required fields if state was null
        success: 'true',
        error: 'false',
        name: name,
        mobileno: mobileno,
        mail: mail,
        address: address,
        profileimg: profileimg,
        // Add other required fields from Profile model if they are not nullable
        // Example: userId: 'temp_user_id', if userId is part of your Profile model
      );


      // Call the API to actually save the changes
      // Pass the context received by this method to the service call
      await _profileService.updateProfile(
        context: context, // <--- PASS THE CONTEXT HERE
        name: name,
        mobileno: mobileno,
        mail: mail,
        address: address,
        profileimg: profileimg, // Pass profileimg to the service call
      );

      // Note: The ProfileService now handles the SnackBar.
      // If the API returns the updated profile, you might want to update `state` with it.
      // For now, assuming the optimistic update is sufficient or the service handles UI feedback.
      // If your API returns the full updated profile, you could do:
      // state = apiReturnedUpdatedProfile;

    } catch (e) {
      // Revert optimistic update or show error to user
      // For a more robust solution, you might store the original state before optimistic update
      // and revert to it on error. Or use AsyncValue.
      print("Error updating profile via API: $e");
      // The ProfileService should be showing a SnackBar for errors,
      // so rethrowing here might not be necessary if you only want UI feedback via SnackBar.
      // If you need to handle errors differently in the UI, then rethrow.
      rethrow; // Re-throw to be caught by the UI
    }
  }
}

// StateNotifierProvider for the mutable profile data
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, Profile?>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileNotifier(profileService);
});

// Extension to Profile model for copyWith for easier local updates
// IMPORTANT: Ensure your Profile model has a 'profileimg' field (e.g., String? profileimg;)
extension ProfileCopyWith on Profile {
  Profile copyWith({
    String? success, // Added success to copyWith
    String? error,   // Added error to copyWith
    String? name,
    String? mobileno, // Corrected from 'mobile' to 'mobileno' to match model
    String? address,
    String? mail,
    String? profileimg, // Added profileimg to copyWith
  }) {
    return Profile(
      success: success ?? this.success, // Copy success
      error: error ?? this.error,       // Copy error
      name: name ?? this.name,
      mobileno: mobileno ?? this.mobileno, // Use mobileno
      address: address ?? this.address,
      mail: mail ?? this.mail,
      profileimg: profileimg ?? this.profileimg, // Update profileimg
      // Ensure all other fields from Profile model are also copied if they exist
      // e.g., userId: this.userId, etc.
    );
  }
}