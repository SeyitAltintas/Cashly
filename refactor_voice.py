import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove properties
content = re.sub(r'  // Speech-to-text\n  final SpeechService _speechService = SpeechService\(\);\n', '', content)
content = re.sub(r'  // --- Voice Dictation State ---\n', '', content)
content = re.sub(r'  bool _isDictationBoxOpen = false;\n', '', content)
content = re.sub(r'  bool _isListening = false;\n', '', content)
content = re.sub(r"  String _lastRecognizedWords = '';\n", "", content)
content = re.sub(r"  String _interimText = ''; // Son partial metin\n", "", content)
content = re.sub(r"  Timer\? _voiceSilenceTimer;\n", "", content)

# Add manager property
content = content.replace("  QuillController? _controller;\n", "  QuillController? _controller;\n  late final VoiceDictationManager _voiceDictationManager;\n")

# Init manager in _loadNote because it requires _controller
init_code = """
    _voiceDictationManager = VoiceDictationManager(
      context: context,
      controller: _controller!,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      onUnsavedChanges: _markUnsaved,
    );
"""
# insert after _controller = QuillController(
controller_init_index = content.find('_controller = QuillController(')
end_of_controller_init = content.find(');', controller_init_index) + 2
content = content[:end_of_controller_init] + init_code + content[end_of_controller_init:]


# Dispose manager
content = content.replace("    _speechService.dispose();\n", "    _voiceDictationManager.dispose();\n")

# Remove methods
start_voice_methods = content.find('  // ─── Sesli Dikte İşlemleri ──────────────────────────────────────────────')
end_voice_methods = content.find('  // ─── Build ──────────────────────────────────────────────────────────────')
if start_voice_methods != -1 and end_voice_methods != -1:
    content = content[:start_voice_methods] + content[end_voice_methods:]

# Replace usages in build
content = content.replace('_isDictationBoxOpen', '_voiceDictationManager.isDictationBoxOpen')
content = content.replace('_isListening', '_voiceDictationManager.isListening')
content = content.replace('_interimText', '_voiceDictationManager.interimText')

content = content.replace('onStartVoiceDictation: _startVoiceDictation,', 'onStartVoiceDictation: _voiceDictationManager.startVoiceDictation,')
content = content.replace('onToggleListening: _toggleListening,', 'onToggleListening: _voiceDictationManager.toggleListening,')
content = content.replace('onStopDictation: _stopVoiceDictation,', 'onStopDictation: _voiceDictationManager.stopVoiceDictation,')

# Add import
imports = "import 'package:cashly/features/notes/utils/voice_dictation_manager.dart';\n"
content = content.replace("import 'package:cashly/features/notes/utils/note_media_helper.dart';", "import 'package:cashly/features/notes/utils/note_media_helper.dart';\n" + imports)

# Remove unused speech import if it exists
content = content.replace("import 'package:cashly/core/services/speech/speech_service.dart';\n", "")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
