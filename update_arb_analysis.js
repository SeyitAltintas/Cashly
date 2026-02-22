const fs = require('fs');
const tr = JSON.parse(fs.readFileSync('lib/l10n/app_tr.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));

const append = {
    'downloadReportTooltip': ['Rapor İndir', 'Download Report'],
    'noExpenseDataForThisMonth': ['Bu ay için harcama verisi yok.', 'No expense data for this month.'],
    'highestExpense': ['En çok harcama', 'Highest expense'],
    'categoryDistribution': ['Kategori Dağılımı', 'Category Distribution'],
    'noIncomeDataForThisMonth': ['Bu ay için gelir verisi bulunmuyor.', 'No income data for this month.'],
    'highestIncome': ['En fazla gelir', 'Highest income'],
    'incomeCategories': ['Gelir Kategorileri', 'Income Categories'],
    'noAssetsAddedYet': ['Henüz varlık eklenmemiş.', 'No assets added yet.'],
    'mostValuableType': ['En değerli tür', 'Most valuable type'],
    'assetTypes': ['Varlık Türleri', 'Asset Types'],
    'distributionByPaymentMethod': ['Ödeme Yöntemine Göre Dağılım', 'Distribution By Payment Method'],
    'notSpecified': ['Belirtilmemiş', 'Not specified'],
    'otherStr': ['Diğer', 'Other']
};

for (const [k, [vTr, vEn]] of Object.entries(append)) {
    tr[k] = vTr;
    en[k] = vEn;
}

fs.writeFileSync('lib/l10n/app_tr.arb', JSON.stringify(tr, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
