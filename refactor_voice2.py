import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add manager property
content = content.replace("  QuillController? _controller;\n", "  QuillController? _controller;\n  late final VoiceDictationManager _voiceDictationManager;\n")

# 2. Init manager in _loadNote
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
# find the exact place inside _loadNote
load_note_idx = content.find('  Future<void> _loadNote() async {')
controller_init_idx = content.find('_controller = QuillController(', load_note_idx)
end_of_controller_init = content.find(');', controller_init_idx) + 2
content = content[:end_of_controller_init] + init_code + content[end_of_controller_init:]

# 3. Dispose manager
content = content.replace("    _speechService.dispose();\n", "    _voiceDictationManager.dispose();\n")

# 4. Remove properties
content = re.sub(r'  // Speech-to-text\n  final SpeechService _speechService = SpeechService\(\);\n', '', content)
content = re.sub(r'  // --- Voice Dictation State ---\n  bool _isDictationBoxOpen = false;\n  bool _isListening = false;\n  String _lastRecognizedWords = \'\';\n  String _interimText = \'\'; // Son partial metin\n  Timer\? _voiceSilenceTimer;\n', '', content)

# 5. Remove methods
start_voice_methods = content.find('  // ─── Sesli Dikte İşlemleri ──────────────────────────────────────────────')
end_voice_methods = content.find('  // ─── Build ──────────────────────────────────────────────────────────────')
if start_voice_methods != -1 and end_voice_methods != -1:
    content = content[:start_voice_methods] + content[end_voice_methods:]

# 6. Replace usages in build
content = content.replace('_isDictationBoxOpen', '_voiceDictationManager.isDictationBoxOpen')
content = content.replace('_isListening', '_voiceDictationManager.isListening')
content = content.replace('_interimText', '_voiceDictationManager.interimText')

content = content.replace('onStartVoiceDictation: _startVoiceDictation,', 'onStartVoiceDictation: _voiceDictationManager.startVoiceDictation,')
content = content.replace('onToggleListening: _toggleListening,', 'onToggleListening: _voiceDictationManager.toggleListening,')
content = content.replace('onStopDictation: _stopVoiceDictation,', 'onStopDictation: _voiceDictationManager.stopVoiceDictation,')

# 7. Add import for manager at the END of imports to be safe
import_idx = content.rfind("import '")
end_of_imports = content.find('\n', import_idx) + 1
content = content[:end_of_imports] + "import 'package:cashly/features/notes/utils/voice_dictation_manager.dart';\n" + content[end_of_imports:]

# 8. Remove unused speech import
content = content.replace("import 'package:cashly/core/services/speech/speech_service.dart';\n", "")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
