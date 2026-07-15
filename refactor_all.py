import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# MEDIA REFACTOR
# Remove media constants
content = re.sub(r'const int _kImageMaxWidth = 1280;\nconst int _kImageQuality = 78;\n', '', content)
# Remove _imagePicker
content = re.sub(r'  final ImagePicker _imagePicker = ImagePicker\(\);\n', '', content)

# Remove media methods
start_media = content.find('  Future<String?> _pickAndReturnVideoPath(BuildContext context) async {')
end_media = content.find('  // ─── Sesli Dikte İşlemleri')
if start_media != -1 and end_media != -1:
    content = content[:start_media] + content[end_media:]

# Replace media handlers
content = content.replace(
    'onPickImageFromGallery: _pickAndReturnImagePath,',
    'onPickImageFromGallery: (ctx) => NoteMediaHelper.pickImage(ctx, fromCamera: false),'
)
content = content.replace(
    'onPickVideoFromGallery: _pickAndReturnVideoPath,',
    'onPickVideoFromGallery: (ctx) => NoteMediaHelper.pickVideo(ctx, fromCamera: false),'
)

camera_image_pattern = r'onTakePhoto: \(\) async \{\s*final path =\s*await _pickAndReturnImagePathFromCamera\(\s*context,\s*\);\s*if \(path != null\) _insertMedia\(path, false\);\s*\},'
replacement_camera_image = r'''onTakePhoto: () async {
                                  final path = await NoteMediaHelper.pickImage(context, fromCamera: true);
                                  if (path != null) NoteMediaHelper.insertMedia(controller: _controller!, path: path, isVideo: false, onMediaInserted: _markUnsaved);
                                },'''
content = re.sub(camera_image_pattern, replacement_camera_image, content, flags=re.DOTALL)

camera_video_pattern = r'onRecordVideo: \(\) async \{\s*final path =\s*await _pickAndReturnVideoPathFromCamera\(\s*context,\s*\);\s*if \(path != null\) _insertMedia\(path, true\);\s*\},'
replacement_camera_video = r'''onRecordVideo: () async {
                                  final path = await NoteMediaHelper.pickVideo(context, fromCamera: true);
                                  if (path != null) NoteMediaHelper.insertMedia(controller: _controller!, path: path, isVideo: true, onMediaInserted: _markUnsaved);
                                },'''
content = re.sub(camera_video_pattern, replacement_camera_video, content, flags=re.DOTALL)

# Add NoteMediaHelper import
imports = "import 'package:cashly/features/notes/utils/note_media_helper.dart';\n"
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports)

# VOICE REFACTOR
# Add VoiceDictationManager property
content = content.replace("  QuillController? _controller;\n", "  QuillController? _controller;\n  VoiceDictationManager? _voiceDictationManager;\n")

# Init manager in _loadNote
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
# insert at the end of _loadNote
load_note_end_idx = content.find("      _isLoading = false;")
if load_note_end_idx != -1:
    content = content[:load_note_end_idx] + init_code + content[load_note_end_idx:]

# Dispose manager
content = content.replace("    _speechService.dispose();\n", "    _voiceDictationManager?.dispose();\n")

# Remove properties
content = re.sub(r'  // Speech-to-text\n  final SpeechService _speechService = SpeechService\(\);\n', '', content)
content = re.sub(r'  bool _isDictationBoxOpen = false;\n  bool _isListening = false;\n  bool _isRestarting = false;[^\n]*\n  String _interimText = \'\';[^\n]*\n  int _interimOffset = -1;[^\n]*\n', '', content)
content = re.sub(r'  Timer\? _voicePauseTimer;[^\n]*\n', '', content)
content = re.sub(r'  Timer\?\n\s*_voiceSilenceTimer;[^\n]*\n', '', content)

# Remove voice methods
start_voice_methods = content.find('  // ─── Sesli Dikte İşlemleri ──────────────────────────────────────────────')
end_voice_methods = content.find('  // ─── Build ──────────────────────────────────────────────────────────────')
if start_voice_methods != -1 and end_voice_methods != -1:
    content = content[:start_voice_methods] + content[end_voice_methods:]

# Replace usages in build
content = content.replace('_isDictationBoxOpen', '(_voiceDictationManager?.isDictationBoxOpen ?? false)')
content = content.replace('_isListening', '(_voiceDictationManager?.isListening ?? false)')
content = content.replace('_interimText', '(_voiceDictationManager?.interimText ?? \'\')')

content = content.replace('onStartVoiceDictation: _startVoiceDictation,', 'onStartVoiceDictation: () => _voiceDictationManager?.startVoiceDictation(),')
content = content.replace('onToggleListening: _toggleListening,', 'onToggleListening: () => _voiceDictationManager?.toggleListening(),')
content = content.replace('onStopDictation: _stopVoiceDictation,', 'onStopDictation: () => _voiceDictationManager?.stopVoiceDictation(),')

# Add import for manager at the END of imports to be safe
import_idx = content.rfind("import '")
end_of_imports = content.find('\n', import_idx) + 1
content = content[:end_of_imports] + "import 'package:cashly/features/notes/utils/voice_dictation_manager.dart';\n" + content[end_of_imports:]

# Remove unused imports
content = re.sub(r"import 'dart:io';\n", "", content)
content = re.sub(r"import 'dart:math';\n", "", content)
content = re.sub(r"import 'package:path_provider/path_provider.dart';\n", "", content)
content = re.sub(r"import 'package:image_picker/image_picker.dart';\n", "", content)
content = re.sub(r"import 'package:cashly/core/services/image_compression_service.dart';\n", "", content)
content = re.sub(r"import 'package:cashly/core/services/speech/speech_service.dart';\n", "", content)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
