import 'package:get_it/get_it.dart';


final GetIt getIt = GetIt.instance;

Future<void> initDependencies() async {
  
  await getIt.allReady();
}
