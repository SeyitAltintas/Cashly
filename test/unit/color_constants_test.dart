import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/constants/color_constants.dart';

/// ColorConstants testleri
void main() {
  group('ColorConstants', () {
    group('Temel renk sabitleri', () {
      test('neonMor doğru değere sahip olmalı', () {
        expect(ColorConstants.neonMor, const Color(0xFF9D00FF));
      });

      test('safSiyah doğru değere sahip olmalı', () {
        expect(ColorConstants.safSiyah, const Color(0xFF000000));
      });

      test('hataRengi doğru değere sahip olmalı', () {
        expect(ColorConstants.hataRengi, const Color(0xFFCF6679));
      });
    });

    group('getColorForExpenseCategory', () {
      test('yemek kategorisi için turuncu döndürmeli', () {
        expect(
          ColorConstants.getColorForExpenseCategory('yemek'),
          ColorConstants.turuncuVurgu,
        );
      });

      test('market kategorisi için yeşil döndürmeli', () {
        expect(
          ColorConstants.getColorForExpenseCategory('market'),
          ColorConstants.yesilVurgu,
        );
      });

      test('bilinmeyen kategori için gri döndürmeli', () {
        expect(
          ColorConstants.getColorForExpenseCategory('bilinmeyen'),
          ColorConstants.gri,
        );
      });

      test('büyük/küçük harf duyarsız olmalı', () {
        expect(
          ColorConstants.getColorForExpenseCategory('YEMEK'),
          ColorConstants.turuncuVurgu,
        );
      });
    });

    group('getColorForAssetCategory', () {
      test('altın kategorisi için amber döndürmeli', () {
        expect(
          ColorConstants.getColorForAssetCategory('altın'),
          ColorConstants.amber,
        );
      });

      test('kripto kategorisi için turuncu döndürmeli', () {
        expect(
          ColorConstants.getColorForAssetCategory('kripto'),
          ColorConstants.turuncuVurgu,
        );
      });

      test('bilinmeyen kategori için açık mor döndürmeli', () {
        expect(
          ColorConstants.getColorForAssetCategory('bilinmeyen'),
          ColorConstants.acikMor,
        );
      });
    });

    group('getColorForBudgetRatio', () {
      test('yüksek oran (>0.8) için kırmızı döndürmeli', () {
        expect(
          ColorConstants.getColorForBudgetRatio(0.9),
          ColorConstants.kirmiziVurgu,
        );
      });

      test('orta oran (0.5-0.8) için turuncu döndürmeli', () {
        expect(
          ColorConstants.getColorForBudgetRatio(0.6),
          ColorConstants.turuncuVurgu,
        );
      });

      test('düşük oran (<0.5) için açık mor döndürmeli', () {
        expect(
          ColorConstants.getColorForBudgetRatio(0.3),
          ColorConstants.acikMor,
        );
      });
    });

    group('chartColorPalette', () {
      test('en az 5 renk içermeli', () {
        expect(
          ColorConstants.chartColorPalette.length,
          greaterThanOrEqualTo(5),
        );
      });

      test('null içermemeli', () {
        for (final color in ColorConstants.chartColorPalette) {
          expect(color, isNotNull);
        }
      });
    });
  });
}
