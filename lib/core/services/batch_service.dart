import 'package:cloud_firestore/cloud_firestore.dart';

/// Soyut Batch Operasyonu sınıfı. Clean architecture kapsamında, domain katmanının
/// Firestore'u bilmemesi için oluşturulmuştur.
abstract class BatchOperation {
  final String collectionPath;
  final String documentId;
  final Map<String, dynamic>? data;
  final BatchOperationType type;
  final bool merge;

  const BatchOperation({
    required this.collectionPath,
    required this.documentId,
    required this.type,
    this.data,
    this.merge = false,
  });
}

enum BatchOperationType { set, update, delete }

/// Firestore özelindeki Batch Operasyonu
class FirestoreBatchOperation extends BatchOperation {
  const FirestoreBatchOperation({
    required super.collectionPath,
    required super.documentId,
    required super.type,
    super.data,
    super.merge,
  });
}

/// Uygulama genelinde kullanılacak toplu işlem (batch) servisi
abstract class BatchService {
  /// Verilen operasyon listesini tek bir batch (transaction/toplu işlem) halinde veritabanına yazar.
  /// Eğer operasyonlardan biri bile başarısız olursa, hiçbiri yazılmaz (veya catch bloğuna düşer).
  Future<void> commit(List<BatchOperation> operations);
}

/// Firestore altyapısını kullanan Batch Servisi
class FirestoreBatchService implements BatchService {
  final FirebaseFirestore _firestore;

  FirestoreBatchService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> commit(List<BatchOperation> operations) async {
    if (operations.isEmpty) return;

    // Firestore limiti gereği bir batch en fazla 500 işlem alabilir.
    const int chunkSize = 500;
    final List<Future<void>> futures = [];

    for (var i = 0; i < operations.length; i += chunkSize) {
      final end = (i + chunkSize < operations.length) ? i + chunkSize : operations.length;
      final chunk = operations.sublist(i, end);

      final batch = _firestore.batch();

      for (final op in chunk) {
        final docRef = _firestore
            .collection(op.collectionPath)
            .doc(op.documentId);

        switch (op.type) {
          case BatchOperationType.set:
            if (op.data != null) {
              if (op.merge) {
                batch.set(docRef, op.data!, SetOptions(merge: true));
              } else {
                batch.set(docRef, op.data!);
              }
            }
            break;
          case BatchOperationType.update:
            if (op.data != null) {
              batch.update(docRef, op.data!);
            }
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      futures.add(batch.commit());
    }

    // Toplu işlemleri gerçekleştir. Herhangi bir ağ bağlantı problemi veya hata durumunda
    // catch bloğuna düşecek ve hatalı chunklar yakalanabilecektir.
    await Future.wait(futures);
  }
}
