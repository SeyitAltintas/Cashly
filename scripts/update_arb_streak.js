const fs = require('fs');
const tr = JSON.parse(fs.readFileSync('lib/l10n/app_tr.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));

const append = {
    'howStreakWorks': ['Seri Nasıl Çalışır?', 'How Streak Works?'],
    'daysText': ['gün', 'days'],
    'dailyStreak': ['Günlük Seri 🔥', 'Daily Streak 🔥'],
    'freezeUsed': ['Koruyucu kullanıldı', 'Freeze used'],
    'longestStreak': ['En Uzun Seri', 'Longest Streak'],
    'totalLogins': ['Toplam Giriş', 'Total Logins'],
    'streakFreeze': ['Seri Koruyucu', 'Streak Freeze'],
    'protectsStreakEvenIfSkipped': ['Bir gün atlasan bile serini korur', 'Protects your streak even if you skip a day'],
    'streakFreezeUsedToday': ['Bugün seri koruyucu kullanıldı!', 'Streak freeze used today!'],
    'nextFreezeIn': ['Sonraki koruyucu: {days} gün sonra', 'Next freeze in {days} days'],
    'nextBadgeIs': ['Sonraki Rozet: {badgeName}', 'Next Badge: {badgeName}'],
    'daysRemainingForBadge': ['{remaining} gün kaldı', '{remaining} days left'],
    'badges': ['Rozetler', 'Badges'],
    'achievements': ['Başarılar', 'Achievements'],
    'dShort': ['g', 'd'],
    'earned': ['✓ Kazanıldı', '✓ Earned'],
    'requiredStreakDays': ['{requiredStreak} günlük seri gerekli', '{requiredStreak} day streak required']
};

for (const [k, [vTr, vEn]] of Object.entries(append)) {
    if (!tr[k]) tr[k] = vTr;
    if (!en[k]) en[k] = vEn;
}

const pInt = { placeholders: { days: { type: 'int' } } };
const pIntRemaining = { placeholders: { remaining: { type: 'int' } } };
const pIntRequired = { placeholders: { requiredStreak: { type: 'int' } } };
const pStrBadge = { placeholders: { badgeName: { type: 'String' } } };

Object.assign(tr, { '@nextFreezeIn': pInt, '@daysRemainingForBadge': pIntRemaining, '@requiredStreakDays': pIntRequired, '@nextBadgeIs': pStrBadge });
Object.assign(en, { '@nextFreezeIn': pInt, '@daysRemainingForBadge': pIntRemaining, '@requiredStreakDays': pIntRequired, '@nextBadgeIs': pStrBadge });

fs.writeFileSync('lib/l10n/app_tr.arb', JSON.stringify(tr, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
