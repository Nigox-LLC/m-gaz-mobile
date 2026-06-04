import '../models/profile_model.dart';

/// Contract for the remote profile data source. Implementations talk to the
/// backend HTTP API and translate transport errors into the typed exceptions
/// declared in `core/error/exceptions.dart`.
abstract class ProfileRemoteDataSource {
  /// Loads the authenticated user's profile from `directory/profile/`.
  Future<ProfileModel> loadProfile();
}
