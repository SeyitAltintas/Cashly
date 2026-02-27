const fs = require('fs');
const tr = JSON.parse(fs.readFileSync('lib/l10n/app_tr.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));

const append = {
    // Profile settings extra
    'securityPin': ['Güvenlik PIN\'i', 'Security PIN'],
    'fullName': ['İsim Soyisim', 'Full Name'],
    'emailAddress': ['E-posta', 'Email Address'],

    // Streak Controller achievements
    'firstStep': ['İlk Adım', 'First Step'],
    'firstStepDesc': ['Uygulamayı ilk kez açtın', 'Opened the app for the first time'],
    'streakStarter': ['Seri Başlatıcı', 'Streak Starter'],
    'streakStarterDesc': ['3 günlük seri oluştur', 'Create a 3 day streak'],
    'streakFreezeDescAction': ['Bir seri koruyucu kullan', 'Use a streak freeze'],
    'regularUser': ['Düzenli Kullanıcı', 'Regular User'],
    'regularUserDesc': ['Toplam 10 gün giriş yap', 'Login for a total of 10 days'],
    'continuityMaster': ['Süreklilik Ustası', 'Continuity Master'],
    'continuityMasterDesc': ['30 günlük seri oluştur', 'Create a 30 day streak'],
    'financialGuru': ['Finansal Guru', 'Financial Guru'],
    'financialGuruDesc': ['Toplam 100 gün giriş yap', 'Login for a total of 100 days']
};

for (const [k, [vTr, vEn]] of Object.entries(append)) {
    if (!tr[k]) tr[k] = vTr;
    if (!en[k]) en[k] = vEn;
}

fs.writeFileSync('lib/l10n/app_tr.arb', JSON.stringify(tr, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
