import json
from pathlib import Path
import urllib.parse

path = Path('D:/ios/iOSStore/store.json')
data = json.loads(path.read_text(encoding='utf-8'))

for item in data['items']:
    # Ensure icon_url is always a valid URL placeholder
    name = urllib.parse.quote(item['name'])
    item['icon_url'] = f"https://placehold.co/512x512/002855/BD9648.png?text={name}"

    # Ensure telegram_description is a string (not missing)
    if 'telegram_description' not in item:
        item['telegram_description'] = ""

path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
print('Updated store.json with safe values')
