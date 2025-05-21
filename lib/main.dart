import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine_detection_app_2/app.dart';
import 'package:mine_detection_app_2/blocs/auth/auth_bloc.dart';
import 'package:mine_detection_app_2/blocs/device/device_bloc.dart';
import 'package:mine_detection_app_2/blocs/map/map_bloc.dart';
import 'package:mine_detection_app_2/blocs/scan/scan_bloc.dart';
import 'package:mine_detection_app_2/repositories/auth_repository.dart';
import 'package:mine_detection_app_2/repositories/device_repository.dart';
import 'package:mine_detection_app_2/repositories/scan_repository.dart';
import 'package:mine_detection_app_2/services/api_service.dart';
import 'package:mine_detection_app_2/services/websocket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService(baseUrl: 'http://localhost:8080/api/v1');
  final wsService = WebSocketService(baseUrl: 'ws://localhost:8080/api/v1/ws');

  final authRepository = AuthRepository(apiService: apiService);
  final deviceRepository = DeviceRepository(apiService: apiService);
  final scanRepository = ScanRepository(apiService: apiService, wsService: wsService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: authRepository,
          ),
        ),
        BlocProvider<DeviceBloc>(
          create: (context) => DeviceBloc(
            deviceRepository: deviceRepository,
          ),
        ),
        BlocProvider<ScanBloc>(
          create: (context) => ScanBloc(
            scanRepository: scanRepository,
          ),
        ),
        BlocProvider<MapBloc>(
          create: (context) => MapBloc(
            scanRepository: scanRepository,
          ),
        ),
      ],
      child: const MineDetectionApp(),
    ),
  );
}