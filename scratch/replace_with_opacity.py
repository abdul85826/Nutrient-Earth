import os
import re

root_dir = r'c:\Users\Abdul\Documents\NE_App\Nutrient_Earth\lib'

for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace .withOpacity(x) with .withValues(alpha: x)
                new_content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
                
                if new_content != content:
                    with open(path, 'w', encoding='utf-8', newline='') as f:
                        f.write(new_content)
                    print(f"Updated {path}")
            except Exception as e:
                print(f"Error processing {path}: {e}")
