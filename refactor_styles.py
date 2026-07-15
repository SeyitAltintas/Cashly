import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Extract _buildEditorStyles logic and replace it with NoteEditorStyles.buildStyles
styles_start_str = '  DefaultStyles _buildEditorStyles(ColorScheme cs, bool isDark) {'
styles_start = content.find(styles_start_str)
styles_end_str = '  Widget build(BuildContext context) {'
styles_end = content.find(styles_end_str, styles_start)

if styles_start != -1 and styles_end != -1:
    styles_code = content[styles_start:styles_end]
    
    # Write to a new file
    new_styles_code = """import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditorStyles {
  static Color _getTextColor(ColorScheme cs) {
    // Ayni mantik
    return cs.onSurface; // This needs to be correctly mapped, let's just grab _getTextColor from note_editor_page.dart
  }
""" + styles_code.replace('  DefaultStyles _buildEditorStyles(ColorScheme cs, bool isDark) {', '  static DefaultStyles buildStyles(ColorScheme cs, bool isDark) {') + "\n}\n"
    
    # We will need the _getTextColor function. 
    text_color_start = content.find('  Color _getTextColor(ColorScheme cs) {')
    text_color_end = content.find('  void _applyInterimText(String newText) {', text_color_start)
    if text_color_end == -1: text_color_end = content.find('  }', text_color_start) + 3
    
    if text_color_start != -1:
        text_color_code = content[text_color_start:text_color_end]
        new_styles_code = new_styles_code.replace('  static Color _getTextColor(ColorScheme cs) {\n    // Ayni mantik\n    return cs.onSurface; // This needs to be correctly mapped, let\'s just grab _getTextColor from note_editor_page.dart\n  }', text_color_code.replace('  Color _getTextColor', '  static Color _getTextColor'))
    
    with open(r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\widgets\note_editor_styles.dart', 'w', encoding='utf-8') as f:
        f.write(new_styles_code)
    
    # Remove from note_editor_page.dart
    content = content[:styles_start] + content[styles_end:]
    if text_color_start != -1:
        content = content[:text_color_start] + content[text_color_end:]

# 2. Replace customStyles call
content = content.replace('customStyles: _buildEditorStyles(', 'customStyles: NoteEditorStyles.buildStyles(')

# 3. Replace embedBuilders logic
embeds_start_str = '          embedBuilders: ['
embeds_start = content.find(embeds_start_str)
embeds_end_str = '          customStyles:'
embeds_end = content.find(embeds_end_str, embeds_start)

if embeds_start != -1 and embeds_end != -1:
    content = content[:embeds_start] + '          embedBuilders: NoteEditorEmbedBuilders.build(context),\n' + content[embeds_end:]

# Add imports
imports = "import 'package:cashly/features/notes/presentation/widgets/note_editor_styles.dart';\nimport 'package:cashly/features/notes/presentation/widgets/note_editor_embed_builders.dart';\n"
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done extracting styles and embeds')
