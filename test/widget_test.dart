import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydropulse/services/storage_service.dart';
import 'package:hydropulse/services/audio_service.dart';
import 'package:hydropulse/services/notification_service.dart';
import 'package:hydropulse/providers/app_state.dart';
import 'package:hydropulse/models/timer_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HydroPulse AppState initializes with default 25m and 0ml water', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final audio = AudioService();
    final notifications = NotificationService();

    final state = AppState(
      storage: storage,
      audio: audio,
      notifications: notifications,
    );

    expect(state.sessionMode, SessionMode.focus);
    expect(state.remainingSeconds, 25 * 60);
    expect(state.todayWaterMl, 0);
    expect(state.isRunning, false);
  });

  test('Adding water updates today count and progress correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final audio = AudioService();
    final notifications = NotificationService();

    final state = AppState(
      storage: storage,
      audio: audio,
      notifications: notifications,
    );

    await state.addWater(250);
    expect(state.todayWaterMl, 250);
    expect(state.entries.length, 1);
    expect(state.entries.first.amountMl, 250);

    await state.addWater(500);
    expect(state.todayWaterMl, 750);
    expect(state.entries.length, 2);
  });
}
