import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pet_buddy/models/use_model.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  late final UserModel user;



}
