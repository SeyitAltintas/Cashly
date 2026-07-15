import re

filepath = r'c:\Users\seyit\Desktop\MobilProje\cashly\lib\features\notes\presentation\pages\note_editor_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
imports = """import 'package:cashly/features/notes/presentation/widgets/note_category_selector.dart';
"""
content = content.replace("import 'package:cashly/features/notes/presentation/widgets/note_editor_toolbar.dart';", 
                          "import 'package:cashly/features/notes/presentation/widgets/note_editor_toolbar.dart';\n" + imports)

# Remove _buildCategoryTags, _showCategoryPicker
# We will use regex to find and remove these methods.
# _buildCategoryTags starts at `  Widget _buildCategoryTags(ColorScheme colorScheme, Color fgColor) {`
# _showCategoryPicker starts at `  void _showCategoryPicker(` and goes until `  Widget _buildMicButton()` or `  Future<void> _startVoiceDictation() async {` if we removed mic button
# _showCreateCategoryDialog starts at `  void _showCreateCategoryDialog() {` and goes until `  PreferredSizeWidget _buildAppBar`
# _CreateCategoryDialog starts at `class _CreateCategoryDialog extends StatefulWidget {` to the end of file

content = re.sub(r'  Widget _buildCategoryTags\(.*?  \}\n\n', '', content, flags=re.DOTALL)
content = re.sub(r'  void _showCategoryPicker\(.*?  \}\n\n', '', content, flags=re.DOTALL)
content = re.sub(r'  void _showCreateCategoryDialog\(\) \{.*?  \}\n\n', '', content, flags=re.DOTALL)
content = re.sub(r'class _CreateCategoryDialog extends StatefulWidget \{.*\}\n', '', content, flags=re.DOTALL)

# Replace usage of _buildCategoryTags
selector_usage = """NoteCategorySelector(
                      selectedCategoryId: _note?.categoryId,
                      categories: _allCategories,
                      colorScheme: colorScheme,
                      fgColor: _getTextColor(colorScheme),
                      onCategorySelected: (categoryId) {
                        setState(() {
                          _note = _note?.copyWith(
                            categoryId: categoryId,
                            clearCategory: categoryId == null,
                          );
                          _hasUnsavedChanges = true;
                        });
                        _scheduleAutoSave();
                      },
                      onCategoryCreated: (newCat) async {
                        await _categoryRepository.saveCategory(newCat);
                        await _loadCategories();
                        if (mounted) {
                          setState(() {
                            _note = _note?.copyWith(categoryId: newCat.id);
                            _markUnsaved();
                          });
                        }
                      },
                    )"""

content = re.sub(r'_buildCategoryTags\(colorScheme, _getTextColor\(colorScheme\)\)', selector_usage, content)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Refactor NoteCategorySelector successful')
