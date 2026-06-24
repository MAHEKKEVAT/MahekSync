import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/movie_model.dart';
import 'package:maheksync/app/services/imagekit_api.dart';

class MovieFirestoreUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'movies';

  static Future<bool> addMovie(MovieModel movie) async {
    try {
      final movieId = MahekConstant.getUuid();
      movie.id = movieId;
      movie.createdAt = Timestamp.now();
      await _firestore.collection(_collectionName).doc(movieId).set(movie.toJson());
      return true;
    } catch (e) {
      print('Error adding movie: $e');
      return false;
    }
  }

  static Future<bool> updateMovie(MovieModel movie) async {
    try {
      await _firestore.collection(_collectionName).doc(movie.id).update(movie.toJson());
      return true;
    } catch (e) {
      print('Error updating movie: $e');
      return false;
    }
  }

  static Future<bool> deleteMovie(String movieId) async {
    try {
      await _firestore.collection(_collectionName).doc(movieId).delete();
      return true;
    } catch (e) {
      print('Error deleting movie: $e');
      return false;
    }
  }

  static Stream<List<MovieModel>> getUserMovies(String ownerId) {
    return _firestore
        .collection(_collectionName)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final movies = snapshot.docs
          .map((doc) => MovieModel.fromJson(doc.data()))
          .toList();

      movies.sort((a, b) {
        final aTime = a.createdAt?.toDate() ?? DateTime(2000);
        final bTime = b.createdAt?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return movies;
    });
  }

  static Future<MovieModel?> getMovie(String movieId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(movieId).get();
      if (doc.exists) {
        return MovieModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> uploadPoster({
    required XFile imageFile,
    required String ownerId,
  }) async {
    final folderName = 'movies/$ownerId';
    return await ImageKitAPI.uploadImage(
      imageFile: imageFile,
      folderName: folderName,
    );
  }
}
