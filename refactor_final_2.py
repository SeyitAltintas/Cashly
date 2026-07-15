import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    # Media constants
    if 'const int _kImageMaxWidth = 1280;' in line or 'const int _kImageQuality = 78;' in line:
        continue
    # imagePicker
    if 'final ImagePicker _imagePicker = ImagePicker();' in line:
        continue
    # voice variables
    if 'final SpeechService _speechService = SpeechService();' in line:
        continue
    if 'bool _isDictationBoxOpen = false;' in line:
        continue
    if 'bool _isListening = false;' in line:
        continue
    if 'bool _isRestarting = false;' in line:
        continue
    if "String _interimText = ''; // Son partial metin" in line:
        continue
    if "int _interimOffset = -1; // Interim metnin başladığı Quill offset'i" in line:
        continue
    if "Timer? _voicePauseTimer;" in line:
        continue
    if "Timer?" in line and "_voiceSilenceTimer;" in lines[lines.index(line) + 1] if lines.index(line) + 1 < len(lines) else False:
        continue
    if "_voiceSilenceTimer;" in line and "Timer?" in lines[lines.index(line) - 1] if lines.index(line) - 1 >= 0 else False:
        continue
        
    # properties added
    if '  QuillController? _controller;' in line:
        new_lines.append(line)
        new_lines.append("  VoiceDictationManager? _voiceDictationManager;\n")
        continue

    # methods to skip
    if 'Future<String?> _pickAndReturnVideoPath(BuildContext context) async {' in line:
        skip = True
    if 'Future<void> _startVoiceDictation() async {' in line:
        skip = True
        
    # end of methods to skip
    if skip and '  // ─── Build ' in line:
        skip = False
    
    if not skip:
        # replace inner usages
        if '_speechService.dispose();' in line:
            line = line.replace('_speechService.dispose();', '_voiceDictationManager?.dispose();')
        
        if '_isDictationBoxOpen = false;' in line:
            line = line.replace('_isDictationBoxOpen = false;', '_voiceDictationManager?.stopVoiceDictation();')
        
        if '_isListening = false;' in line or '_isRestarting = false;' in line:
            continue
            
        if '_isDictationBoxOpen' in line:
            line = line.replace('_isDictationBoxOpen', '(_voiceDictationManager?.isDictationBoxOpen ?? false)')
            
        if '_isListening' in line:
            line = line.replace('_isListening', '(_voiceDictationManager?.isListening ?? false)')
            
        if '_interimText' in line:
            line = line.replace('_interimText', '(_voiceDictationManager?.interimText ?? \'\')')

        if 'onPickImageFromGallery: _pickAndReturnImagePath,' in line:
            line = line.replace('onPickImageFromGallery: _pickAndReturnImagePath,', 'onPickImageFromGallery: (ctx) => NoteMediaHelper.pickImage(ctx, fromCamera: false),')

        if 'onPickVideoFromGallery: _pickAndReturnVideoPath,' in line:
            line = line.replace('onPickVideoFromGallery: _pickAndReturnVideoPath,', 'onPickVideoFromGallery: (ctx) => NoteMediaHelper.pickVideo(ctx, fromCamera: false),')

        if 'onTakePhoto: () async {' in line:
            # We will handle these blocks below manually
            pass

        if 'onStartVoiceDictation: _startVoiceDictation,' in line:
            line = line.replace('onStartVoiceDictation: _startVoiceDictation,', 'onStartVoiceDictation: () => _voiceDictationManager?.startVoiceDictation(),')
            
        if 'onToggleListening: _toggleListening,' in line:
            line = line.replace('onToggleListening: _toggleListening,', 'onToggleListening: () => _voiceDictationManager?.toggleListening(),')
            
        if 'onStopDictation: _stopVoiceDictation,' in line:
            line = line.replace('onStopDictation: _stopVoiceDictation,', 'onStopDictation: () => _voiceDictationManager?.stopVoiceDictation(),')
        
        if '      _isLoading = false;' in line:
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
            new_lines.append(init_code)
            
        new_lines.append(line)

content = "".join(new_lines)

# Fix camera handlers
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
