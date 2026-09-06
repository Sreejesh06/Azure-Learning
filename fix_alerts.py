import os
import re

alert_map = {
    'NOTE': 'info',
    'TIP': 'info',
    'IMPORTANT': 'warn',
    'WARNING': 'warn',
    'CAUTION': 'error'
}

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    for old_type, new_type in alert_map.items():
        # Match `> [!TYPE]\n> Text\n> More text`
        # We need a regex that captures all subsequent lines starting with `> `
        pattern = r'>\s*\[!' + old_type + r'\]\n((?:>\s*.*\n?)+)'
        
        def replacer(match):
            inner_text = match.group(1)
            # Remove the `> ` from the inner text lines
            clean_text = re.sub(r'^>\s*', '', inner_text, flags=re.MULTILINE)
            return f'<Callout type="{new_type}">\n{clean_text}</Callout>\n'

        content = re.sub(pattern, replacer, content)

    with open(filepath, 'w') as f:
        f.write(content)

for root, _, files in os.walk('content/docs'):
    for file in files:
        if file.endswith('.mdx'):
            process_file(os.path.join(root, file))
