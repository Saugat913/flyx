import 'package:flyx/core/services/file_picker_service.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:get_it/get_it.dart';


final GetIt getIt = GetIt.instance;

Future<void> initDependencies() async {
  //Service
  getIt.registerSingleton<FilePickerService>(FilePickerService());


  // Views model
  getIt.registerSingleton<SendViewModel>(SendViewModel());
  await getIt.allReady();
}
