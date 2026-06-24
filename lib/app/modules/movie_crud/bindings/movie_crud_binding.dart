import 'package:get/get.dart';

import '../controllers/movie_crud_controller.dart';

class MovieCrudBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovieCrudController>(
      () => MovieCrudController(),
    );
  }
}
