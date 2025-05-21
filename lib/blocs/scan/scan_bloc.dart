// TODO Implement this library.import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mine_detection_app_2/models/detected_object.dart';
import 'package:mine_detection_app_2/models/scan.dart';
import 'package:mine_detection_app_2/repositories/scan_repository.dart';

// Events
abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class ScansFetched extends ScanEvent {
  final Map<String, dynamic>? filters;

  const ScansFetched({this.filters});

  @override
  List<Object?> get props => [filters];
}

class ScanStarted extends ScanEvent {
  final String missionId;
  final String deviceId;
  final String scanType;
  final Map<String, dynamic>? metadata;

  const ScanStarted({
    required this.missionId,
    required this.deviceId,
    required this.scanType,
    this.metadata,
  });

  @override
  List<Object?> get props => [missionId, deviceId, scanType, metadata];
}

class ScanEnded extends ScanEvent {
  final String scanId;

  const ScanEnded({required this.scanId});

  @override
  List<Object> get props => [scanId];
}

class ScanUpdatesSubscribed extends ScanEvent {
  final String scanId;
  final String token;

  const ScanUpdatesSubscribed({
    required this.scanId,
    required this.token,
  });

  @override
  List<Object> get props => [scanId, token];
}

class ScanUpdatesUnsubscribed extends ScanEvent {
  final String scanId;

  const ScanUpdatesUnsubscribed({required this.scanId});

  @override
  List<Object> get props => [scanId];
}

class ScanUpdateReceived extends ScanEvent {
  final dynamic update;

  const ScanUpdateReceived({required this.update});

  @override
  List<Object> get props => [update];
}

class DetectedObjectsFetched extends ScanEvent {
  final String scanId;

  const DetectedObjectsFetched({required this.scanId});

  @override
  List<Object> get props => [scanId];
}

// States
abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScansLoaded extends ScanState {
  final List<Scan> scans;

  const ScansLoaded({required this.scans});

  @override
  List<Object> get props => [scans];
}

class ScanOperationSuccess extends ScanState {
  final String message;
  final Scan? scan;

  const ScanOperationSuccess({
    required this.message,
    this.scan,
  });

  @override
  List<Object?> get props => [message, scan];
}

class ScanLiveUpdating extends ScanState {
  final Scan scan;
  final List<DetectedObject> detectedObjects;

  const ScanLiveUpdating({
    required this.scan,
    required this.detectedObjects,
  });

  @override
  List<Object> get props => [scan, detectedObjects];
}

class DetectedObjectsLoaded extends ScanState {
  final List<DetectedObject> detectedObjects;

  const DetectedObjectsLoaded({required this.detectedObjects});

  @override
  List<Object> get props => [detectedObjects];
}

class ScanFailure extends ScanState {
  final String message;

  const ScanFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanRepository _scanRepository;
  StreamSubscription<dynamic>? _scanUpdatesSubscription;

  ScanBloc({required ScanRepository scanRepository})
      : _scanRepository = scanRepository,
        super(ScanInitial()) {
    on<ScansFetched>(_onScansFetched);
    on<ScanStarted>(_onScanStarted);
    on<ScanEnded>(_onScanEnded);
    on<ScanUpdatesSubscribed>(_onScanUpdatesSubscribed);
    on<ScanUpdatesUnsubscribed>(_onScanUpdatesUnsubscribed);
    on<ScanUpdateReceived>(_onScanUpdateReceived);
    on<DetectedObjectsFetched>(_onDetectedObjectsFetched);
  }

  Future<void> _onScansFetched(
      ScansFetched event,
      Emitter<ScanState> emit,
      ) async {
    emit(ScanLoading());
    try {
      final scans = await _scanRepository.getScans(filters: event.filters);
      emit(ScansLoaded(scans: scans));
    } catch (e) {
      emit(ScanFailure(message: e.toString()));
    }
  }

  Future<void> _onScanStarted(
      ScanStarted event,
      Emitter<ScanState> emit,
      ) async {
    emit(ScanLoading());
    try {
      final scan = await _scanRepository.startScan(
        missionId: event.missionId,
        deviceId: event.deviceId,
        scanType: event.scanType,
        metadata: event.metadata,
      );
      emit(ScanOperationSuccess(
        message: 'Сканування розпочато',
        scan: scan,
      ));
    } catch (e) {
      emit(ScanFailure(message: e.toString()));
    }
  }

  Future<void> _onScanEnded(
      ScanEnded event,
      Emitter<ScanState> emit,
      ) async {
    emit(ScanLoading());
    try {
      await _scanRepository.endScan(event.scanId);
      emit(const ScanOperationSuccess(message: 'Сканування завершено'));

      // Оновлення списку сканувань
      final scans = await _scanRepository.getScans();
      emit(ScansLoaded(scans: scans));
    } catch (e) {
      emit(ScanFailure(message: e.toString()));
    }
  }

  Future<void> _onScanUpdatesSubscribed(
      ScanUpdatesSubscribed event,
      Emitter<ScanState> emit,
      ) async {
    emit(ScanLoading());
    try {
      // Отримання поточних даних сканування
      final scan = await _scanRepository.getScanById(event.scanId);
      final detectedObjects = await _scanRepository.getDetectedObjects(event.scanId);

      // Підписка на оновлення
      final updatesStream = _scanRepository.subscribeScanUpdates(
        event.scanId,
        event.token,
      );

      _scanUpdatesSubscription?.cancel();
      _scanUpdatesSubscription = updatesStream.listen((update) {
        add(ScanUpdateReceived(update: update));
      });

      emit(ScanLiveUpdating(
        scan: scan,
        detectedObjects: detectedObjects,
      ));
    } catch (e) {
      emit(ScanFailure(message: e.toString()));
    }
  }

  Future<void> _onScanUpdatesUnsubscribed(
      ScanUpdatesUnsubscribed event,
      Emitter<ScanState> emit,
      ) async {
    _scanRepository.unsubscribeScanUpdates(event.scanId);
    _scanUpdatesSubscription?.cancel();
    _scanUpdatesSubscription = null;
  }

  Future<void> _onScanUpdateReceived(
      ScanUpdateReceived event,
      Emitter<ScanState> emit,
      ) async {
    final currentState = state;
    if (currentState is ScanLiveUpdating) {
      // Обробка різних типів оновлень
      if (event.update is Map && event.update['type'] == 'detection') {
        // Обробка нового виявленого об'єкта
        final newDetection = DetectedObject.fromJson(event.update['data']);
        final updatedDetections = List<DetectedObject>.from(currentState.detectedObjects)
          ..add(newDetection);

        emit(ScanLiveUpdating(
          scan: currentState.scan,
          detectedObjects: updatedDetections,
        ));
      }
      // Обробка інших типів оновлень...
    }
  }

  Future<void> _onDetectedObjectsFetched(
      DetectedObjectsFetched event,
      Emitter<ScanState> emit,
      ) async {
    emit(ScanLoading());
    try {
      final detectedObjects = await _scanRepository.getDetectedObjects(event.scanId);
      emit(DetectedObjectsLoaded(detectedObjects: detectedObjects));
    } catch (e) {
      emit(ScanFailure(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _scanUpdatesSubscription?.cancel();
    return super.close();
  }
}