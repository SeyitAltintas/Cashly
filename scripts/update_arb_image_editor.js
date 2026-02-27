const fs = require('fs');
const tr = JSON.parse(fs.readFileSync('lib/l10n/app_tr.arb', 'utf8'));
const en = JSON.parse(fs.readFileSync('lib/l10n/app_en.arb', 'utf8'));

const append = {
    // image crop
    'cropPhoto': ['Fotoğrafı Kırp', 'Crop Photo'],
    'continueText': ['Devam', 'Continue'],
    'rotateLeft90': ['90° Sol', '90° Left'],
    'rotateRight90': ['90° Sağ', '90° Right'],
    'flipHorizontal': ['Yatay', 'Horizontal'],
    'flipVertical': ['Dikey', 'Vertical'],
    'compare': ['Karşılaştır', 'Compare'],
    'undo': ['Geri Al', 'Undo'],
    'redo': ['İleri Al', 'Redo'],
    'resetAll': ['Tümünü Sıfırla', 'Reset All'],
    'rotation': ['Döndürme', 'Rotation'],
    'grid': ['Grid', 'Grid'],

    // advanced image editor
    'editPhoto': ['Fotoğraf Düzenle', 'Edit Photo'],
    'apply': ['Uygula', 'Apply'],
    'filters': ['Filtreler', 'Filters'],
    'adjustments': ['Ayarlar', 'Adjustments'],
    'transform': ['Dönüşüm', 'Transform'],
    'text': ['Metin', 'Text'],
    'emoji': ['Emoji', 'Emoji'],
    'frame': ['Çerçeve', 'Frame'],
    'intensity': ['Yoğunluk', 'Intensity'],
    'brightness': ['Parlaklık', 'Brightness'],
    'contrast': ['Kontrast', 'Contrast'],
    'saturation': ['Doygunluk', 'Saturation'],
    'temperature': ['Sıcaklık', 'Temperature'],
    'tint': ['Renk Tonu', 'Tint'],
    'shadows': ['Gölgeler', 'Shadows'],
    'highlights': ['Parlaklıklar', 'Highlights'],
    'vignette': ['Vinyet', 'Vignette'],

    // profile settings helper
    'selectProfilePhoto': ['Profil Resmi Seç', 'Select Profile Photo'],
    'selectProfilePhotoDesc': ['Galerinizden bir fotoğraf seçerek ya da kameradan fotoğraf çekerek profil resminizi değiştirebilirsiniz.', 'You can change your profile picture by choosing a photo from your gallery or taking a picture with your camera.'],
    'camera': ['Kamera', 'Camera'],
    'takePhoto': ['Fotoğraf Çek', 'Take Photo'],
    'gallery': ['Galeri', 'Gallery'],
    'choosePhoto': ['Fotoğraf Seç', 'Choose Photo']
};

for (const [k, [vTr, vEn]] of Object.entries(append)) {
    if (!tr[k]) tr[k] = vTr;
    if (!en[k]) en[k] = vEn;
}

fs.writeFileSync('lib/l10n/app_tr.arb', JSON.stringify(tr, null, 2));
fs.writeFileSync('lib/l10n/app_en.arb', JSON.stringify(en, null, 2));
