import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
imports = """import 'package:cashly/features/notes/presentation/widgets/note_editor_toolbar.dart';
"""
content = content.replace("import 'package:cashly/features/notes/presentation/widgets/voice_dictation_overlay.dart';", 
                          "import 'package:cashly/features/notes/presentation/widgets/voice_dictation_overlay.dart';\n" + imports)

# Remove _isFormatMode and _isMediaMode declarations
content = re.sub(r'\n\s*bool _isFormatMode = false;\n', '\n', content)
content = re.sub(r'\n\s*bool _isMediaMode = false;\n', '\n', content)

# Remove _isFormatMode and _isMediaMode from _startVoiceDictation
content = re.sub(r'\s*_isFormatMode = false;\n', '\n', content)
content = re.sub(r'\s*_isMediaMode = false;\n', '\n', content)

# Remove _decreaseFontSize and _increaseFontSize
content = re.sub(r'  void _decreaseFontSize\(\) \{.*?(?=  Widget _buildFloatingToolbar)', '', content, flags=re.DOTALL)

# Remove _buildFloatingToolbar
content = re.sub(r'  Widget _buildFloatingToolbar\(\n.*?\n  \) \{.*?(?=  Widget _buildEditor)', '', content, flags=re.DOTALL)

# Remove _buildMicButton 
content = re.sub(r'  Widget _buildMicButton\(\) \{.*?(?=  /// Dinleme aktifken)', '', content, flags=re.DOTALL)

# Replace usage of _buildFloatingToolbar
toolbar_usage = """NoteEditorToolbar(
                            controller: controller,
                            onMarkUnsaved: _markUnsaved,
                            onStartVoiceDictation: _startVoiceDictation,
                            onPickImageFromGallery: _pickAndReturnImagePath,
                            onPickVideoFromGallery: _pickAndReturnVideoPath,
                            onTakePhoto: () async {
                              final path = await _pickAndReturnImagePathFromCamera(context);
                              if (path != null) _insertMedia(path, false);
                            },
                            onRecordVideo: () async {
                              final path = await _pickAndReturnVideoPathFromCamera(context);
                              if (path != null) _insertMedia(path, true);
                            },
                          )"""

content = re.sub(r'_buildFloatingToolbar\(colorScheme,\s*controller\)', toolbar_usage, content)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Refactor NoteEditorToolbar successful')
