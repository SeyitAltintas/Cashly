import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/tools/presentation/controllers/tools_controller.dart';

/// ToolsController testleri
/// Loading, active section ve state notification davranışları
void main() {
  group('ToolsController', () {
    late ToolsController controller;

    setUp(() {
      controller = ToolsController();
    });

    group('Başlangıç durumu', () {
      test('isLoading başlangıçta false', () {
        expect(controller.isLoading, isFalse);
      });

      test('activeSection başlangıçta null', () {
        expect(controller.activeSection, isNull);
      });
    });

    group('setLoading', () {
      test('true olarak ayarlanabilir', () {
        controller.setLoading(true);
        expect(controller.isLoading, isTrue);
      });

      test('false olarak geri alınabilir', () {
        controller.setLoading(true);
        controller.setLoading(false);
        expect(controller.isLoading, isFalse);
      });

      test('aynı değer set edildiğinde notifyListeners çağrılmaz', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.setLoading(false); // Zaten false
        expect(notifyCount, equals(0));

        controller.setLoading(true); // false → true, çağrılır
        expect(notifyCount, equals(1));

        controller.setLoading(true); // Zaten true
        expect(notifyCount, equals(1));
      });
    });

    group('setActiveSection', () {
      test('string section ayarlanır', () {
        controller.setActiveSection('export');
        expect(controller.activeSection, equals('export'));
      });

      test('null ile sıfırlanabilir', () {
        controller.setActiveSection('tools');
        controller.setActiveSection(null);
        expect(controller.activeSection, isNull);
      });

      test('farklı section geçişleri doğru çalışır', () {
        controller.setActiveSection('backup');
        expect(controller.activeSection, equals('backup'));

        controller.setActiveSection('export');
        expect(controller.activeSection, equals('export'));
      });

      test('aynı section set edildiğinde notifyListeners çağrılmaz', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.setActiveSection('test');
        expect(notifyCount, equals(1));

        controller.setActiveSection('test'); // Aynı değer
        expect(notifyCount, equals(1));
      });
    });

    group('refresh', () {
      test('refresh her çağrıda notifyListeners tetikler', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.refresh();
        expect(notifyCount, equals(1));

        controller.refresh();
        expect(notifyCount, equals(2));
      });
    });

    group('ChangeNotifier entegrasyonu', () {
      test('listener ekle ve kaldır', () {
        int count = 0;
        void listener() => count++;

        controller.addListener(listener);
        controller.setLoading(true);
        expect(count, equals(1));

        controller.removeListener(listener);
        controller.setLoading(false);
        expect(count, equals(1)); // Listener kaldırıldı, değişmedi
      });
    });
  });
}
