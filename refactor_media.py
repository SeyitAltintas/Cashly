import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the properties
content = re.sub(r'const int _kImageMaxWidth = 1280;\n', '', content)
content = re.sub(r'const int _kImageQuality = 78;\n', '', content)
content = re.sub(r'  final ImagePicker _imagePicker = ImagePicker\(\);\n', '', content)

# Remove the methods
start = content.find('  Future<String?> _pickAndReturnVideoPath(BuildContext context) async {')
end = content.find('  // ─── Build ──────────────────────────────────────────────────────────────')

if start != -1 and end != -1:
    content = content[:start] + content[end:]

# Replace usages
content = content.replace('onPickImageFromGallery: _pickAndReturnImagePath,', 'onPickImageFromGallery: (ctx) => NoteMediaHelper.pickImage(ctx, fromCamera: false),')
content = content.replace('onPickVideoFromGallery: _pickAndReturnVideoPath,', 'onPickVideoFromGallery: (ctx) => NoteMediaHelper.pickVideo(ctx, fromCamera: false),')

content = content.replace('_pickAndReturnImagePathFromCamera(', 'NoteMediaHelper.pickImage(')
content = content.replace('_pickAndReturnVideoPathFromCamera(', 'NoteMediaHelper.pickVideo(')
content = content.replace('_insertMedia(path, false);', 'NoteMediaHelper.insertMedia(controller: _controller!, path: path, isVideo: false, onMediaInserted: _markUnsaved);')
content = content.replace('_insertMedia(path, true);', 'NoteMediaHelper.insertMedia(controller: _controller!, path: path, isVideo: true, onMediaInserted: _markUnsaved);')

# Add import
imports = "import 'package:cashly/features/notes/utils/note_media_helper.dart';\n"
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
