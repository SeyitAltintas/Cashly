import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports
imports = """import 'package:cashly/features/notes/presentation/widgets/custom_text_link_dialog.dart';
import 'package:cashly/features/notes/presentation/widgets/camera_options_dialog.dart';
"""
content = content.replace("import 'package:cashly/features/notes/presentation/widgets/note_color_picker_sheet.dart';", 
                          "import 'package:cashly/features/notes/presentation/widgets/note_color_picker_sheet.dart';\n" + imports)

# Remove _showCustomTextLinkDialog
content = re.sub(r'  void _showCustomTextLinkDialog\(\) \{.*?(?=  Future<String\?> _pickAndReturnImagePathFromCamera)', '', content, flags=re.DOTALL)

# Replace usage of _showCustomTextLinkDialog
content = re.sub(r'onPressed:\s*_showCustomTextLinkDialog', 'onPressed: () => CustomTextLinkDialog.show(context, _controller!, () { _markUnsaved(); })', content)

# Remove _showCameraOptionsDialog
content = re.sub(r'  void _showCameraOptionsDialog\(\) \{.*?(?=  // ─── Build)', '', content, flags=re.DOTALL)

# Replace usage of _showCameraOptionsDialog
content = re.sub(r'onPressed:\s*_showCameraOptionsDialog', 'onPressed: () => CameraOptionsDialog.show(context: context, onTakePhoto: () async { final path = await _pickAndReturnImagePathFromCamera(context); if (path != null) _insertMedia(path, false); }, onRecordVideo: () async { final path = await _pickAndReturnVideoPathFromCamera(context); if (path != null) _insertMedia(path, true); })', content)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Refactor successful')
