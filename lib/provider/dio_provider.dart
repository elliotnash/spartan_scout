import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@riverpod
class ScoutingDio extends _$ScoutingDio {
  @override
  Dio build() {
    return Dio();
  }
}
