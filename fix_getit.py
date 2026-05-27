import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Skip if GetIt is not used or it's already properly reset
    if 'GetIt' not in content or 'GetIt.instance.reset()' in content:
        return

    # If it imports get_it but doesn't reset it
    if 'get_it.dart' in content and 'void main() {' in content:
        print(f'Fixing {filepath}')
        
        # Check if tearDownAll exists
        if 'tearDownAll(() {' in content:
            content = content.replace('tearDownAll(() {', 'tearDownAll(() {\n    GetIt.instance.reset();')
        else:
            # Inject tearDownAll right after main() {
            content = content.replace('void main() {', 'void main() {\n  tearDownAll(() {\n    GetIt.instance.reset();\n  });\n')
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

for root, dirs, files in os.walk('test'):
    for file in files:
        if file.endswith('_test.dart'):
            process_file(os.path.join(root, file))
