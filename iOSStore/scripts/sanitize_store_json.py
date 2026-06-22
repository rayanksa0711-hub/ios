import json
from pathlib import Path

path = Path('D:/ios/iOSStore/store.json')
data = json.loads(path.read_text(encoding='utf-8'))

for item in data['items']:
    if item.get('icon_url') == '':
        del item['icon_url']
    if item.get('ipa_url') == '':
        del item['ipa_url']

path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
print('Updated store.json')
