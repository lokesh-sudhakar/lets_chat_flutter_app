import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/viewmodel/login_view_model.dart';
import 'package:chat_app/viewmodel/registration_view_model.dart';
import 'package:get_it/get_it.dart';


GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(()=> DatabaseHelper());
  locator.registerFactory(() => LoginViewModel());
  locator.registerFactory(() => RegistrationViewModel());

}