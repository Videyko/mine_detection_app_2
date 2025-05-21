import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mine_detection_app_2/blocs/map/map_bloc.dart';
import 'package:mine_detection_app_2/models/detected_object.dart';
import 'package:mine_detection_app_2/widgets/object_info_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  DetectedObject? _selectedObject;

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const MapLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MapFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Помилка: ${state.message}'),
                ElevatedButton(
                  onPressed: () => context.read<MapBloc>().add(const MapLoaded()),
                  child: const Text('Спробувати знову'),
                ),
              ],
            ),
          );
        }

        if (state is MapReady) {
          return Row(
            children: [
              // Основна карта
              Expanded(
                flex: 3,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: state.center,
                    zoom: state.zoom,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        context.read<MapBloc>().add(
                          MapPositionChanged(center: position.center!),
                        );
                        context.read<MapBloc>().add(
                          MapZoomChanged(zoom: position.zoom!),
                        );
                      }
                    },
                    onTap: (_, __) => setState(() => _selectedObject = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: _buildMarkers(state.filteredObjects),
                    ),
                  ],
                ),
              ),

              // Панель з інформацією та фільтрами
              Expanded(
                flex: 1,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Фільтри',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Фільтр за рівнем довіри
                        Text('Мінімальний рівень довіри: ${(state.minConfidence ?? 0.0).toStringAsFixed(1)}'),
                        Slider(
                          value: state.minConfidence ?? 0.0,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          label: (state.minConfidence ?? 0.0).toStringAsFixed(1),
                          onChanged: (value) {
                            context.read<MapBloc>().add(
                              ObjectsFilterChanged(minConfidence: value),
                            );
                          },
                        ),

                        // Фільтр за рівнем небезпеки
                        Text('Мінімальний рівень небезпеки: ${state.minDangerLevel ?? 0}'),
                        Slider(
                          value: (state.minDangerLevel ?? 0).toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 5,
                          label: (state.minDangerLevel ?? 0).toString(),
                          onChanged: (value) {
                            context.read<MapBloc>().add(
                              ObjectsFilterChanged(minDangerLevel: value.toInt()),
                            );
                          },
                        ),

                        // Фільтр за типом об'єкта
                        DropdownButtonFormField<String?>(
                          decoration: const InputDecoration(
                            labelText: 'Тип об\'єкта',
                          ),
                          value: state.objectType,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Всі типи'),
                            ),
                            ...['anti_personnel_mine', 'anti_tank_mine', 'unknown']
                                .map((type) => DropdownMenuItem<String?>(
                              value: type,
                              child: Text(_getObjectTypeName(type)),
                            ))
                                .toList(),
                          ],
                          onChanged: (value) {
                            context.read<MapBloc>().add(
                              ObjectsFilterChanged(objectType: value),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        Text(
                          'Знайдено об\'єктів: ${state.filteredObjects.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const Spacer(),

                        // Інформація про вибраний об'єкт
                        if (_selectedObject != null)
                          ObjectInfoCard(object: _selectedObject!),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Немає даних'));
      },
    );
  }

  List<Marker> _buildMarkers(List<DetectedObject> objects) {
    return objects.map((object) {
      final isSelected = _selectedObject?.id == object.id;

      // Вибір кольору маркера на основі рівня небезпеки
      Color markerColor;
      switch (object.dangerLevel) {
        case 1:
          markerColor = Colors.blue;
          break;
        case 2:
          markerColor = Colors.green;
          break;
        case 3:
          markerColor = Colors.yellow;
          break;
        case 4:
          markerColor = Colors.orange;
          break;
        case 5:
          markerColor = Colors.red;
          break;
        default:
          markerColor = Colors.grey;
      }

      return Marker(
        point: LatLng(object.latitude, object.longitude),
        width: isSelected ? 40 : 30,
        height: isSelected ? 40 : 30,
        builder: (context) => GestureDetector(
          onTap: () => setState(() => _selectedObject = object),
          child: Icon(
            Icons.location_on,
            color: markerColor,
            size: isSelected ? 40 : 30,
          ),
        ),
      );
    }).toList();
  }

  String _getObjectTypeName(String type) {
    switch (type) {
      case 'anti_personnel_mine':
        return 'Протипіхотна міна';
      case 'anti_tank_mine':
        return 'Протитанкова міна';
      case 'unknown':
        return 'Невідомий тип';
      default:
        return type;
    }
  }
}