import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/payment_methods/domain/transfer_schedule_policy.dart';

void main() {
  group('TransferSchedulePolicy', () {
    test('bugun ilerideki dakika zamanlanmis transfer sayilir', () {
      final now = DateTime(2026, 5, 30, 10, 15, 45);
      final selected = DateTime(2026, 5, 30, 10, 16);

      expect(
        TransferSchedulePolicy.isScheduled(selectedDate: selected, now: now),
        isTrue,
      );
    });

    test('ayni dakikadaki secim zamanlanmis transfer sayilmaz', () {
      final now = DateTime(2026, 5, 30, 10, 15, 45);
      final selected = DateTime(2026, 5, 30, 10, 15);

      expect(
        TransferSchedulePolicy.isScheduled(selectedDate: selected, now: now),
        isFalse,
      );
    });

    test('bugun ilerideki dakika henuz vadesi gelmis sayilmaz', () {
      final now = DateTime(2026, 5, 30, 10, 15, 45);
      final selected = DateTime(2026, 5, 30, 10, 16);

      expect(
        TransferSchedulePolicy.isDue(selectedDate: selected, now: now),
        isFalse,
      );
    });
  });
}
