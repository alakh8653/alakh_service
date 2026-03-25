import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_web/core/network/admin_api_client.dart';
import 'package:admin_web/core/network/admin_api_interceptors.dart';
import 'package:admin_web/core/security/admin_auth_service.dart';
import 'package:admin_web/core/security/admin_session_manager.dart';
import 'package:admin_web/core/security/rbac_service.dart';
import 'package:admin_web/core/analytics/admin_analytics_service.dart';
import 'package:admin_web/core/routing/admin_router.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // ── Session ───────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AdminSessionManager>(
    () => AdminSessionManager(getIt<SharedPreferences>()),
  );

  // ── Network ───────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AdminApiClient>(
    () {
      final sessionManager = getIt<AdminSessionManager>();
      final client = AdminApiClient.fromEnvironment();
      client.dio.interceptors.addAll([
        AuthInterceptor(sessionManager),
        ErrorInterceptor(sessionManager, client.dio),
        LoggingInterceptor(),
      ]);
      return client;
    },
  );

  // ── Security ──────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AdminAuthService>(
    () => AdminAuthService(
      apiClient: getIt<AdminApiClient>(),
      sessionManager: getIt<AdminSessionManager>(),
    ),
  );

  getIt.registerLazySingleton<RbacService>(() => RbacService());

  // ── Analytics ─────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AdminAnalyticsService>(
    () => AdminAnalyticsService(),
  );

  // ── Routing ───────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AdminRouter>(() => AdminRouter());

  // ── Feature: City Management ──────────────────────────────────────────────
  // registerLazySingleton<CityRemoteDataSource>(...)
  // registerLazySingleton<CityRepository>(...)
  // registerLazySingleton<GetCitiesUseCase>(...)
  // registerLazySingleton<CreateCityUseCase>(...)
  // registerLazySingleton<UpdateCityUseCase>(...)
  // registerLazySingleton<DeleteCityUseCase>(...)
  // registerFactory<CityBloc>(...)

  // ── Feature: Shop Approval ────────────────────────────────────────────────
  // registerLazySingleton<ShopRemoteDataSource>(...)
  // registerLazySingleton<ShopRepository>(...)
  // registerLazySingleton<GetShopsUseCase>(...)
  // registerLazySingleton<ApproveShopUseCase>(...)
  // registerLazySingleton<RejectShopUseCase>(...)
  // registerFactory<ShopApprovalBloc>(...)

  // ── Feature: Dispute Resolution ───────────────────────────────────────────
  // registerLazySingleton<DisputeRemoteDataSource>(...)
  // registerLazySingleton<DisputeRepository>(...)
  // registerLazySingleton<GetDisputesUseCase>(...)
  // registerLazySingleton<ResolveDisputeUseCase>(...)
  // registerFactory<DisputeBloc>(...)

  // ── Feature: Fraud Monitoring ─────────────────────────────────────────────
  // registerLazySingleton<FraudRemoteDataSource>(...)
  // registerLazySingleton<FraudRepository>(...)
  // registerLazySingleton<GetFraudAlertsUseCase>(...)
  // registerLazySingleton<ActionFraudAlertUseCase>(...)
  // registerFactory<FraudMonitoringBloc>(...)

  // ── Feature: Payments Monitoring ─────────────────────────────────────────
  // registerLazySingleton<PaymentsRemoteDataSource>(...)
  // registerLazySingleton<PaymentsRepository>(...)
  // registerLazySingleton<GetPaymentsUseCase>(...)
  // registerLazySingleton<RefundPaymentUseCase>(...)
  // registerFactory<PaymentsMonitoringBloc>(...)

  // ── Feature: Trust Engine Control ─────────────────────────────────────────
  // registerLazySingleton<TrustRemoteDataSource>(...)
  // registerLazySingleton<TrustRepository>(...)
  // registerLazySingleton<GetTrustScoresUseCase>(...)
  // registerLazySingleton<UpdateTrustRuleUseCase>(...)
  // registerFactory<TrustEngineBloc>(...)

  // ── Feature: Audit Logs ───────────────────────────────────────────────────
  // registerLazySingleton<AuditLogsRemoteDataSource>(...)
  // registerLazySingleton<AuditLogsRepository>(...)
  // registerLazySingleton<GetAuditLogsUseCase>(...)
  // registerFactory<AuditLogsBloc>(...)

  // ── Feature: Analytics Dashboard ─────────────────────────────────────────
  // registerLazySingleton<AnalyticsRemoteDataSource>(...)
  // registerLazySingleton<AnalyticsRepository>(...)
  // registerLazySingleton<GetAnalyticsOverviewUseCase>(...)
  // registerFactory<AnalyticsDashboardBloc>(...)

  // ── Feature: System Health ────────────────────────────────────────────────
  // registerLazySingleton<SystemHealthRemoteDataSource>(...)
  // registerLazySingleton<SystemHealthRepository>(...)
  // registerLazySingleton<GetSystemHealthUseCase>(...)
  // registerFactory<SystemHealthBloc>(...)
}
