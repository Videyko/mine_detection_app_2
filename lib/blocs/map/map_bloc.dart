// TODO Implement this library.import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:mine_detection_app_2/models/detected_object.dart';
import 'package:mine_detection_app_2/repositories/scan_repository.dart';

// Events
abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapLoaded extends MapEvent {
  final String? scanId;

  const MapLoaded({this.scanId});

  @override
  List<Object?> get props => [scanId];
}

class MapZoomChanged extends MapEvent {
  final double zoom;

  const MapZoomChanged({required this.zoom});

  @override
  List<Object> get props => [zoom];
}

class MapPositionChanged extends MapEvent {
  final LatLng center;

  const MapPositionChanged({required this.center});

  @override
  List<Object> get props => [center];
}

class ObjectsFilterChanged extends MapEvent {
  final double? minConfidence;
  final int? minDangerLevel;
  final String? objectType;

  const ObjectsFilterChanged({
    this.minConfidence,
    this.minDangerLevel,
    this.objectType,
  });

  @override
  List<Object?> get props => [minConfidence, minDangerLevel, objectType];
}

// States
abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapReady extends MapState {
  final List<DetectedObject> detectedObjects;
  final LatLng center;
  final double zoom;
  final double? minConfidence;
  final int? minDangerLevel;
  final String? objectType;

  const MapReady({
    required this.detectedObjects,
    required this.center,
    required this.zoom,
    this.minConfidence,
    this.minDangerLevel,
    this.objectType,
  });

  List<DetectedObject> get filteredObjects => detectedObjects.where((object) {
    if (minConfidence != null && object.confidence < minConfidence!) {
      return false;
    }
    if (minDangerLevel != null && object.dangerLevel < minDangerLevel!) {
      return false;
    }
    if (objectType != null && object.objectType != objectType) {
      return false;
    }
    return true;
  }).toList();

  MapReady copyWith({
    List<DetectedObject>? detectedObjects,
    LatLng? center,
    double? zoom,
    double? minConfidence,
    int? minDangerLevel,
    String? objectType,
  }) {
    return MapReady(
      detectedObjects: detectedObjects ?? this.detectedObjects,
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      minConfidence: minConfidence ?? this.minConfidence,
      minDangerLevel: minDangerLevel ?? this.minDangerLevel,
      objectType: objectType ?? this.objectType,
    );
  }

  @override
  List<Object?> get props => [
    detectedObjects,
    center,
    zoom,
    minConfidence,
    minDangerLevel,
    objectType,
  ];
}

class MapFailure extends MapState {
  final String message;

  const MapFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class MapBloc extends Bloc<MapEvent, MapState> {
  final ScanRepository _scanRepository;

  MapBloc({required ScanRepository scanRepository})
      : _scanRepository = scanRepository,
        super(MapInitial()) {
    on<MapLoaded>(_onMapLoaded);
    on<MapZoomChanged>(_onMapZoomChanged);
    on<MapPositionChanged>(_onMapPositionChanged);
    on<ObjectsFilterChanged>(_onObjectsFilterChanged);
  }

  Future<void> _onMapLoaded(
      MapLoaded event,
      Emitter<MapState> emit,
      ) async {
    emit(MapLoading());
    try {
      List<DetectedObject> detectedObjects = [];

      if (event.scanId != null) {
        detectedObjects = await _scanRepository.getDetectedObjects(event.scanId!);
      }

      // Визначення центру карти
      LatLng center;
      if (detectedObjects.isNotEmpty) {
        // Розрахувати середню точку виявлених об'єктів
        double sumLat = 0;
        double sumLon = 0;
        for (final obj in detectedObjects) {
          sumLat += obj.latitude;
          sumLon += obj.longitude;
        }
        center = LatLng(sumLat / detectedObjects.length, sumLon / detectedObjects.length);
      } else {
        // За замовчуванням - Україна
        center = const LatLng(49.0, 31.0);
      }

      emit(MapReady(
        detectedObjects: detectedObjects,
        center: center,
        zoom: 12.0,
      ));
    } catch (e) {
      emit(MapFailure(message: e.toString()));
    }
  }

  void _onMapZoomChanged(
      MapZoomChanged event,
      Emitter<MapState> emit,
      ) {
    final currentState = state;
    if (currentState is MapReady) {
      emit(currentState.copyWith(zoom: event.zoom));
    }
  }

  void _onMapPositionChanged(
      MapPositionChanged event,
      Emitter<MapState> emit,
      ) {
    final currentState = state;
    if (currentState is MapReady) {
      emit(currentState.copyWith(center: event.center));
    }
  }

  void _onObjectsFilterChanged(
      ObjectsFilterChanged event,
      Emitter<MapState> emit,
      ) {
    final currentState = state;
    if (currentState is MapReady) {
      emit(currentState.copyWith(
        minConfidence: event.minConfidence,
        minDangerLevel: event.minDangerLevel,
        objectType: event.objectType,
      ));
    }
  }
}