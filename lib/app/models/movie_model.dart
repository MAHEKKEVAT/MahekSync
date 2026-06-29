import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  String? id;
  String? ownerId;
  String? movieName;
  String? year;
  int? totalDuration;
  int? watchedDuration;
  String? posterUrl;
  String? status;
  String? genre;
  String? description;
  String? director;
  double? rating;
  Timestamp? createdAt;

  MovieModel({
    this.id,
    this.ownerId,
    this.movieName,
    this.year,
    this.totalDuration,
    this.watchedDuration,
    this.posterUrl,
    this.status,
    this.genre,
    this.description,
    this.director,
    this.rating,
    this.createdAt,
  });

  MovieModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    movieName = json['movieName'];
    year = json['year'];
    totalDuration = json['totalDuration'];
    watchedDuration = json['watchedDuration'];
    posterUrl = json['posterUrl'];
    status = json['status'];
    genre = json['genre'];
    description = json['description'];
    director = json['director'];
    rating = (json['rating'] as num?)?.toDouble();
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ownerId'] = ownerId;
    data['movieName'] = movieName;
    data['year'] = year;
    data['totalDuration'] = totalDuration;
    data['watchedDuration'] = watchedDuration;
    data['posterUrl'] = posterUrl;
    data['status'] = status;
    data['genre'] = genre;
    data['description'] = description;
    data['director'] = director;
    data['rating'] = rating;
    data['createdAt'] = createdAt ?? Timestamp.now();
    return data;
  }

  double get progressPercent =>
      (totalDuration != null && totalDuration! > 0 && watchedDuration != null)
          ? (watchedDuration! / totalDuration!) * 100
          : 0.0;

  bool get isCompleted => status == 'COMPLETED';

  int get remainingMinutes =>
      (totalDuration ?? 0) - (watchedDuration ?? 0);

  String get formattedTotalDuration {
    if (totalDuration == null) return '0h 0m';
    final h = (totalDuration! / 60).floor();
    final m = totalDuration! % 60;
    return '${h}h ${m}m';
  }

  String get formattedWatchedDuration {
    if (watchedDuration == null) return '0h 0m';
    final h = (watchedDuration! / 60).floor();
    final m = watchedDuration! % 60;
    return '${h}h ${m}m';
  }

  String get formattedRemainingDuration {
    final r = remainingMinutes;
    if (r <= 0) return '0m';
    final h = (r / 60).floor();
    final m = r % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String get statusLabel {
    switch (status) {
      case 'WATCHING':
        return 'Watching';
      case 'COMPLETED':
        return 'Completed';
      case 'NOT_STARTED':
        return 'Not Started';
      case 'NOT_DOWNLOADED':
        return 'Not Downloaded';
      default:
        return 'Not Downloaded';
    }
  }

  List<String> get genreTags {
    if (genre == null || genre!.isEmpty) return [];
    return genre!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}
