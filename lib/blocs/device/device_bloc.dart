// TODO Implement this library.import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mine_detection_app_2/models/device.dart';
import 'package:mine_detection_app_2/repositories/device_repository.dart';

// Events
abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class DevicesFetched extends DeviceEvent {
  final Map<String, dynamic>? filters;

  const DevicesFetched({this.filters});

  @override
  List<Object?> get props => [filters];
}

class DeviceCreated extends DeviceEvent {
  final String deviceType;
  final String serialNumber;
  final Map<String, dynamic> configuration;

  const DeviceCreated({
    required this.deviceType,
    required this.serialNumber,
    required this.configuration,
  });

  @override
  List<Object> get props => [deviceType, serialNumber, configuration];
}

class DeviceStatusUpdated extends DeviceEvent {
  final String id;
  final String status;

  const DeviceStatusUpdated({
    required this.id,
    required this.status,
  });

  @override
  List<Object> get props => [id, status];
}

// States
abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<Device> devices;

  const DeviceLoaded({required this.devices});

  @override
  List<Object> get props => [devices];
}

class DeviceOperationSuccess extends DeviceState {
  final String message;

  const DeviceOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class DeviceFailure extends DeviceState {
  final String message;

  const DeviceFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository _deviceRepository;

  DeviceBloc({required DeviceRepository deviceRepository})
      : _deviceRepository = deviceRepository,
        super(DeviceInitial()) {
    on<DevicesFetched>(_onDevicesFetched);
    on<DeviceCreated>(_onDeviceCreated);
    on<DeviceStatusUpdated>(_onDeviceStatusUpdated);
  }

  Future<void> _onDevicesFetched(
      DevicesFetched event,
      Emitter<DeviceState> emit,
      ) async {
    emit(DeviceLoading());
    try {
      final devices = await _deviceRepository.getDevices(filters: event.filters);
      emit(DeviceLoaded(devices: devices));
    } catch (e) {
      emit(DeviceFailure(message: e.toString()));
    }
  }

  Future<void> _onDeviceCreated(
      DeviceCreated event,
      Emitter<DeviceState> emit,
      ) async {
    emit(DeviceLoading());
    try {
      await _deviceRepository.createDevice(
        deviceType: event.deviceType,
        serialNumber: event.serialNumber,
        configuration: event.configuration,
      );
      emit(const DeviceOperationSuccess(message: 'Пристрій успішно створено'));

      // Оновлення списку пристроїв
      final devices = await _deviceRepository.getDevices();
      emit(DeviceLoaded(devices: devices));
    } catch (e) {
      emit(DeviceFailure(message: e.toString()));
    }
  }

  Future<void> _onDeviceStatusUpdated(
      DeviceStatusUpdated event,
      Emitter<DeviceState> emit,
      ) async {
    emit(DeviceLoading());
    try {
      await _deviceRepository.updateDeviceStatus(event.id, event.status);
      emit(const DeviceOperationSuccess(message: 'Статус пристрою оновлено'));

      // Оновлення списку пристроїв
      final devices = await _deviceRepository.getDevices();
      emit(DeviceLoaded(devices: devices));
    } catch (e) {
      emit(DeviceFailure(message: e.toString()));
    }
  }
}