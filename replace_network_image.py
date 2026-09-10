import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    if 'NetworkImage' not in content:
        return

    # Replace NetworkImage with CachedNetworkImageProvider
    new_content = content.replace('NetworkImage', 'CachedNetworkImageProvider')
    
    # Add import if not present
    if 'import \'package:cached_network_image/cached_network_image.dart\';' not in new_content:
        # Find first import and insert after it
        import_match = re.search(r'^import .*;$', new_content, re.MULTILINE)
        if import_match:
            insert_pos = import_match.end()
            new_content = new_content[:insert_pos] + '\nimport \'package:cached_network_image/cached_network_image.dart\';' + new_content[insert_pos:]
        else:
            new_content = 'import \'package:cached_network_image/cached_network_image.dart\';\n' + new_content

    with open(filepath, 'w') as f:
        f.write(new_content)
    print(f"Updated {filepath}")

lib_dir = 'lib'
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

