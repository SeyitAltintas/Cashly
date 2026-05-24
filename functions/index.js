const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Kullanıcı Firebase Auth üzerinden silindiğinde tetiklenir.
 * KVKK ve GDPR gereği kullanıcının veritabanında (Firestore) kalan
 * "Yetim (Orphaned)" verilerini güvenli ve tek seferde siler.
 */
exports.cleanupUserDataOnDelete = functions.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  console.log(`🧹 Hesap silindi: ${uid}. Firestore temizliği başlatılıyor...`);

  const userRef = db.collection("users").doc(uid);

  try {
    // recursiveDelete metodu Firebase Admin SDK v10+ ile gelir.
    // Kullanıcının root dökümanını ve altındaki tüm subcollection'ları (incomes, expenses vb.)
    // chunk'lar halinde güvenlice siler.
    await db.recursiveDelete(userRef);
    console.log(`✅ [BAŞARILI] ${uid} ID'li kullanıcının tüm verileri kalıcı olarak silindi.`);
  } catch (error) {
    console.error(`❌ [HATA] ${uid} ID'li kullanıcının verileri silinirken hata oluştu:`, error);
  }
});
