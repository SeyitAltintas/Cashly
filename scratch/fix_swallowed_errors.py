import os
import re

IMPORT_STMT = "import 'package:cashly/core/services/error_logger_service.dart';"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    lines = content.split('\n')
    new_lines = []
    
    i = 0
    modified = False
    has_import = IMPORT_STMT in content
    
    while i < len(lines):
        line = lines[i]
        new_lines.append(line)
        
        if 'catch (e, stackTrace) {' in line or 'catch (e, s) {' in line:
            catch_body_lines = []
            j = i + 1
            open_braces = 1
            
            while j < len(lines) and open_braces > 0:
                if '{' in lines[j]: open_braces += lines[j].count('{')
                if '}' in lines[j]: open_braces -= lines[j].count('}')
                catch_body_lines.append(lines[j])
                j += 1
                
            catch_body_str = '\n'.join(catch_body_lines)
            
            if 'ErrorLoggerService' not in catch_body_str and 'ErrorHandler' not in catch_body_str:
                for k in range(len(catch_body_lines)):
                    if 'debugPrint' in catch_body_lines[k] and ('$e' in catch_body_lines[k] or 'e.toString()' in catch_body_lines[k] or 'e)' in catch_body_lines[k] or ', e' in catch_body_lines[k]):
                        match = re.search(r"debugPrint\((['\"].*?['\"])\)", catch_body_lines[k])
                        msg = match.group(1) if match else "'Hata: $e'"
                        
                        indent = len(catch_body_lines[k]) - len(catch_body_lines[k].lstrip())
                        indent_str = ' ' * indent
                        
                        st_var = 'stackTrace' if 'catch (e, stackTrace)' in line else 's'
                        log_line = f"{indent_str}ErrorLoggerService.logError({msg}, stackTrace: {st_var}?.toString());"
                        
                        catch_body_lines.insert(k+1, log_line)
                        modified = True
                        break 
                
            new_lines.extend(catch_body_lines)
            i = j - 1
        i += 1
        
    if modified:
        final_content = '\n'.join(new_lines)
        if not has_import:
            import_idx = 0
            lines_final = final_content.split('\n')
            for idx, l in enumerate(lines_final):
                if l.startswith('import '):
                    import_idx = idx
            
            lines_final.insert(import_idx + 1, IMPORT_STMT)
            final_content = '\n'.join(lines_final)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(final_content)
        print(f'Updated {filepath}')

dirs_to_scan = [
    'lib/features/expenses/data/repositories',
    'lib/features/income/data/repositories',
    'lib/features/settings/data/repositories',
    'lib/features/streak/data/repositories',
    'lib/features/payment_methods/data/repositories',
    'lib/features/analysis/presentation/controllers'
]

for d in dirs_to_scan:
    if os.path.exists(d):
        for root, _, files in os.walk(d):
            for file in files:
                if file.endswith('.dart'):
                    process_file(os.path.join(root, file))
