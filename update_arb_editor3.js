const fs = require('fs');
const tr = JSON.parse(fs.readFileSync('lib/l10n/app_tr.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));

const append = {
    // further transform
    'rotateLeft': ['Sola', 'Left'],
    'rotateRight': ['Sağa', 'Right'],
    'horizontal': ['Yatay', 'Horizontal'],
    'vertical': ['Dikey', 'Vertical'],
};

for (const [k, [vTr, vEn]] of Object.entries(append)) {
    if (!tr[k]) tr[k] = vTr;
    if (!en[k]) en[k] = vEn;
}

fs.writeFileSync('lib/l10n/app_tr.arb', JSON.stringify(tr, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
