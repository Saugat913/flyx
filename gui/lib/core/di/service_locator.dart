import 'package:flyx/core/services/file_picker_service.dart';
import 'package:flyx/features/receive/presentation/viewmodel/receive_view_model.dart';
import 'package:flyx/features/send/presentation/viewmodel/send_view_model.dart';
import 'package:flyx/features/setting/presentation/widgets/profile_card.dart';
import 'package:flyx/features/transfer/presentation/viewmodel/transfer_history_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

const kOnboardedPrefKey = 'onboarded';

Future<void> initDependencies() async {
  // Services
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<FilePickerService>(FilePickerService());
  await initDeviceName();

  // App-wide state
  getIt.registerSingleton<TransferHistoryViewModel>(TransferHistoryViewModel());

  // Flow-scoped ViewModels (reset & disposed on flow exit via FlowScope)
  getIt.registerLazySingleton<SendViewModel>(
    () => SendViewModel(),
    dispose: (vm) => vm.dispose(),
  );
  getIt.registerLazySingleton<ReceiveViewModel>(
    () => ReceiveViewModel(),
    dispose: (vm) => vm.dispose(),
  );
  await getIt.allReady();
}
