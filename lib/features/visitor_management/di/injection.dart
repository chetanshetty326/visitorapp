import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:visitorappointment/core/constants/api_constants.dart';
import '../data/datasources/visitor_remote_data_source.dart';
import '../data/repositories/visitor_repository_impl.dart';
import '../domain/repositories/visitor_repository.dart';
import '../domain/usecases/check_in_visitor_usecase.dart';
import '../domain/usecases/check_out_visitor_usecase.dart';
import '../domain/usecases/delete_visitor_usecase.dart';
import '../domain/usecases/get_dashboard_stats_usecase.dart';
import '../domain/usecases/get_visitor_by_id_usecase.dart';
import '../domain/usecases/get_visitors_usecase.dart';
import '../domain/usecases/register_visitor_usecase.dart';
import '../domain/usecases/update_visitor_usecase.dart';
import '../presentation/bloc/visitor_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // External
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  sl.registerLazySingleton<Dio>(() => dio);

  // Data Sources
  sl.registerLazySingleton<VisitorRemoteDataSource>(
    () => VisitorRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<VisitorRepository>(
    () => VisitorRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetVisitorsUseCase(sl()));
  sl.registerLazySingleton(() => GetVisitorByIdUseCase(sl()));
  sl.registerLazySingleton(() => RegisterVisitorUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVisitorUseCase(sl()));
  sl.registerLazySingleton(() => DeleteVisitorUseCase(sl()));
  sl.registerLazySingleton(() => CheckInVisitorUseCase(sl()));
  sl.registerLazySingleton(() => CheckOutVisitorUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase());

  // BLoC
  sl.registerFactory(
    () => VisitorBloc(
      getVisitorsUseCase: sl(),
      registerVisitorUseCase: sl(),
      updateVisitorUseCase: sl(),
      deleteVisitorUseCase: sl(),
      checkInVisitorUseCase: sl(),
      checkOutVisitorUseCase: sl(),
      getDashboardStatsUseCase: sl(),
    ),
  );
}
