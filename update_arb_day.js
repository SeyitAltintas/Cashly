const fs = require('fs');
const tr = JSON.parse(fs.readFileSync('lib/l10n/app_tr.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));

tr['day'] = 'gün';
en['day'] = 'day';

fs.writeFileSync('lib/l10n/app_tr.arb', JSON.stringify(tr, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
