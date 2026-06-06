import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    
    # Fix invalid_null_aware_operator
    content = content.replace('stackTrace?.toString()', 'stackTrace.toString()')
    
    # Fix unused_catch_stack
    lines = content.split('\n')
    new_lines = []
    
    i = 0
    modified = False
    
    while i < len(lines):
        line = lines[i]
        
        if 'catch (e, stackTrace) {' in line or 'catch (e, s) {' in line:
            catch_body_lines = [line]
            j = i + 1
            open_braces = line.count('{') - line.count('}')
            
            while j < len(lines) and open_braces > 0:
                if '{' in lines[j]: open_braces += lines[j].count('{')
                if '}' in lines[j]: open_braces -= lines[j].count('}')
                catch_body_lines.append(lines[j])
                j += 1
                
            catch_body_str = '\n'.join(catch_body_lines[1:]) # Body without the catch line
            
            # Check if stackTrace is used
            st_var = 'stackTrace' if 'catch (e, stackTrace)' in line else 's'
            # Look for exact word match of st_var
            if not re.search(r'\b' + st_var + r'\b', catch_body_str):
                # not used, change to catch (e) {
                if 'catch (e, stackTrace) {' in line:
                    catch_body_lines[0] = line.replace('catch (e, stackTrace) {', 'catch (e) {')
                else:
                    catch_body_lines[0] = line.replace('catch (e, s) {', 'catch (e) {')
                modified = True
                
            new_lines.extend(catch_body_lines)
            i = j - 1
        else:
            new_lines.append(line)
        i += 1
        
    final_content = '\n'.join(new_lines)
    if final_content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(final_content)
        print(f'Updated {filepath}')

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
