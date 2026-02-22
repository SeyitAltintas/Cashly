const fs = require('fs');
const tr = JSON.parse(fs.readFileSync('lib/l10n/app_tr.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));

const append = {
    'pdfReportTitle': ['PDF Raporu', 'PDF Report'],
    'selectSectionsToInclude': ['Dahil edilecek bölümleri seçin', 'Select sections to include'],
    'reportPeriod': ['Rapor Dönemi', 'Report Period'],
    'reportOptions': ['Rapor Seçenekleri', 'Report Options'],
    'selectAll': ['Hepsi', 'All'],
    'includeAllVisualSummaries': ['Tüm görsel özet seçeneklerini dahil et', 'Include all visual summary options'],
    'financialSummaryCards': ['Finansal Özet Kartları', 'Financial Summary Cards'],
    'expenseIncomeAssetTotals': ['Harcama, gelir ve varlık toplamları', 'Expense, income and asset totals'],
    'netStatusCards': ['Net Durum Kartları', 'Net Status Cards'],
    'monthlyNetStatusAndSavings': ['Aylık net durum ve tasarruf oranı', 'Monthly net status and savings rate'],
    'pieChartAndDistribution': ['Pasta Grafiği ve Dağılım', 'Pie Chart and Distribution'],
    'expenseIncomeAssetDistribution': ['Harcama/gelir/varlık dağılım grafiği', 'Expense/income/asset distribution graph'],
    'budgetStatusTitle': ['Bütçe Durumu', 'Budget Status'],
    'budgetProgressBarAndLimit': ['Bütçe ilerleme çubuğu ve limit bilgisi', 'Budget progress bar and limit info'],
    'statisticsCards': ['İstatistik Kartları', 'Statistics Cards'],
    'dailyAverageAndPreviousMonthComparison': ['Günlük ortalama ve geçen ay karşılaştırma', 'Daily average and previous month comparison'],
    'top5Expenses': ['En Yüksek 5 Harcama', 'Top 5 Expenses'],
    'top5ExpensesListDescription': ['En yüksek tutarlı 5 harcama listesi', 'List of top 5 expenses by amount'],
    'tablesToIncludeInReport': ['Rapora Dahil Edilecek Tablolar', 'Tables to Include in Report'],
    'monthlyExpenseDetails': ['Aylık harcama detayları', 'Monthly expense details'],
    'monthlyIncomeDetails': ['Aylık gelir detayları', 'Monthly income details'],
    'assetListAndValues': ['Varlık listesi ve değerleri', 'Asset list and values'],
    'selectAtLeastOneTable': ['En az bir tablo seçmelisiniz', 'You must select at least one table'],
    'preparing': ['Hazırlanıyor...', 'Preparing...'],
    'createAndSharePdf': ['PDF Oluştur ve Paylaş', 'Create and Share PDF'],
    'analysisAndReports': ['Analiz ve Raporlar', 'Analysis and Reports'],
    'expenseTab': ['Harcama', 'Expense'],
    'incomeTab': ['Gelir', 'Income'],
    'assetTab': ['Varlık', 'Asset']
};

for (const [k, [vTr, vEn]] of Object.entries(append)) {
    if (!tr[k]) tr[k] = vTr;
    if (!en[k]) en[k] = vEn;
}

fs.writeFileSync('lib/l10n/app_tr.arb', JSON.stringify(tr, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
