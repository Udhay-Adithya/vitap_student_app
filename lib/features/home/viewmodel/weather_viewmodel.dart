import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/features/home/model/weather.dart';
import 'package:vit_ap_student_app/features/home/repository/home_remote_repository.dart';

part 'weather_viewmodel.g.dart';

@riverpod
class WeatherViewModel extends _$WeatherViewModel {
  late HomeRemoteRepository _homeRemoteRepository;

  @override
  AsyncValue<Weather>? build() {
    _homeRemoteRepository = ref.watch(homeRemoteRepositoryProvider);
    return null;
  }

  Future<void> fetchWeather() async {
    state = const AsyncValue.loading();
    final res = await _homeRemoteRepository.fetchWeather();

    state = switch (res) {
      Left(value: final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
      Right(value: final weather) => AsyncValue.data(weather),
    };
  }
}
