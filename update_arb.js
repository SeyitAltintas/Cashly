const fs = require('fs');
const tr = JSON.parse(fs.readFileSync('lib/l10n/app_tr.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));

const append = {
  'transferPageTitle': ['Para Transferi', 'Money Transfer'],
  'pleaseSelectAccounts': ['Lütfen hesapları seçin', 'Please select accounts'],
  'cannotTransferToSameAccount': ['Aynı hesaba transfer yapılamaz', 'Cannot transfer to the same account'],
  'enterValidAmount': ['Geçerli bir tutar girin', 'Enter a valid amount'],
  'noDebtOnCreditCard': ['Bu kredi kartında borç bulunmuyor. Transfer yapılamaz.', 'There is no debt on this credit card. Transfer cannot be made.'],
  'creditCardDebtLimit': ['Kredi kartı borcu {amount}, en fazla bu kadar gönderebilirsiniz', 'Credit card debt is {amount}, you can send at most this much'],
  'scheduledTransferMessage': ['{fromAccount} ➔ {toAccount}\n{amount} {date} tarihinde transfer edilmek üzere zamanlandı.', '{fromAccount} ➔ {toAccount}\n{amount} scheduled to be transferred on {date}.'],
  'completedTransferMessage': ['{fromAccount} ➔ {toAccount}\n{amount} saat {time}\'de başarıyla transfer edildi.', '{fromAccount} ➔ {toAccount}\n{amount} successfully transferred at {time}.'],
  'sender': ['GÖNDEREN', 'SENDER'],
  'receiver': ['ALAN', 'RECEIVER'],
  'selectAccount': ['Hesap Seçin', 'Select Account'],
  'amountToSend': ['Gönderilecek Tutar', 'Amount to Send'],
  'enterAmountHint': ['Tutar giriniz', 'Enter amount'],
  'amountMustBeGreaterThanZero': ['Tutar 0\'dan büyük olmalı', 'Amount must be greater than 0'],
  'maximumAmountExceeded': ['Maksimum tutar aşıldı', 'Maximum amount exceeded'],
  'payAllDebt': ['Tüm borcu öde ({amount})', 'Pay all debt ({amount})'],
  'scheduledTransferInfo': ['Bu transfer {date} saat {time}\'de gerçekleştirilecek.', 'This transfer will be executed on {date} at {time}.'],
  'scheduleTransferButton': ['Transferi Zamanla', 'Schedule Transfer'],
  'makeTransferButton': ['Transfer Yap', 'Make Transfer'],
  'transactionHistory': ['İşlem Geçmişi', 'Transaction History'],
  'pendingTransfers': ['⏳ Bekleyen ({count})', '⏳ Pending ({count})'],
  'failedTransfers': ['✗ Başarısız ({count})', '✗ Failed ({count})'],
  'completedTransfersLabel': ['✓ Tamamlanan ({count})', '✓ Completed ({count})'],
  'noTransferHistory': ['Henüz transfer işlemi yok', 'No transfer history yet'],
  'unknownAccount': ['Bilinmeyen', 'Unknown']
};

for (const [k, [vTr, vEn]] of Object.entries(append)) {
  tr[k] = vTr;
  en[k] = vEn;
}

const pString = { placeholders: { amount: { type: 'String' } } };
const pS2 = { placeholders: { fromAccount: { type: 'String' }, toAccount: { type: 'String' }, amount: { type: 'String' }, date: { type: 'String' } } };
const pS3 = { placeholders: { fromAccount: { type: 'String' }, toAccount: { type: 'String' }, amount: { type: 'String' }, time: { type: 'String' } } };
const pS4 = { placeholders: { date: { type: 'String' }, time: { type: 'String' } } };
const pInt = { placeholders: { count: { type: 'int' } } };

Object.assign(tr, { '@creditCardDebtLimit': pString, '@payAllDebt': pString, '@scheduledTransferMessage': pS2, '@completedTransferMessage': pS3, '@scheduledTransferInfo': pS4, '@pendingTransfers': pInt, '@failedTransfers': pInt, '@completedTransfersLabel': pInt });
Object.assign(en, { '@creditCardDebtLimit': pString, '@payAllDebt': pString, '@scheduledTransferMessage': pS2, '@completedTransferMessage': pS3, '@scheduledTransferInfo': pS4, '@pendingTransfers': pInt, '@failedTransfers': pInt, '@completedTransfersLabel': pInt });

fs.writeFileSync('lib/l10n/app_tr.arb', JSON.stringify(tr, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
