import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
imports = """import 'package:cashly/features/notes/presentation/widgets/voice_dictation_overlay.dart';
"""
content = content.replace("import 'package:cashly/features/notes/presentation/widgets/camera_options_dialog.dart';", 
                          "import 'package:cashly/features/notes/presentation/widgets/camera_options_dialog.dart';\n" + imports)

# Remove _buildListeningOverlay
content = re.sub(r'  Widget _buildListeningOverlay\(ColorScheme colorScheme\) \{.*?(?=  Future<void> _startVoiceDictation\(\) async)', '', content, flags=re.DOTALL)

# Replace usage of _buildListeningOverlay
content = re.sub(r'_buildListeningOverlay\(colorScheme\)', 'VoiceDictationOverlay(isListening: _isListening, onToggleListening: _toggleListening)', content)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Refactor VoiceDictationOverlay successful')
