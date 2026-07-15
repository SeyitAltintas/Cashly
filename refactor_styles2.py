import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

styles_start = content.find('  DefaultStyles _buildEditorStyles(ColorScheme cs, bool isDark) {')
styles_end = content.find('    );\n  }\n', styles_start)
if styles_end != -1:
    styles_end += len('    );\n  }\n')

if styles_start != -1 and styles_end != -1:
    styles_code = content[styles_start:styles_end]
    
    text_color_start = content.find('  Color _getTextColor(ColorScheme cs) {')
    text_color_end = content.find('  }\n', text_color_start) + 4
    
    text_color_code = ""
    if text_color_start != -1:
        text_color_code = content[text_color_start:text_color_end].replace('  Color _getTextColor', '  static Color _getTextColor')
    
    new_styles_code = """import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditorStyles {
""" + text_color_code + "\n" + styles_code.replace('  DefaultStyles _buildEditorStyles(ColorScheme cs, bool isDark) {', '  static DefaultStyles buildStyles(ColorScheme cs, bool isDark) {') + "\n}\n"
    
    with open(r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\widgets\note_editor_styles.dart', 'w', encoding='utf-8') as f:
        f.write(new_styles_code)
        
    content = content[:styles_start] + content[styles_end:]
    if text_color_start != -1:
        content = content[:text_color_start] + content[text_color_end:]

content = content.replace('customStyles: _buildEditorStyles(', 'customStyles: NoteEditorStyles.buildStyles(')

embeds_start = content.find('          embedBuilders: [')
embeds_end = content.find('          customStyles:', embeds_start)

if embeds_start != -1 and embeds_end != -1:
    content = content[:embeds_start] + '          embedBuilders: NoteEditorEmbedBuilders.build(context),\n' + content[embeds_end:]

imports = "import 'package:cashly/features/notes/presentation/widgets/note_editor_styles.dart';\nimport 'package:cashly/features/notes/presentation/widgets/note_editor_embed_builders.dart';\n"
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
