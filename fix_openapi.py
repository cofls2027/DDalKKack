
import re

with open('backend/openapi.yaml', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove tags
content = re.sub(r'  - name: Rules\n    description: 지출 규칙 조회\n', '', content)
content = re.sub(r'  - name: Stats\n    description: 통계 조회\n', '', content)
content = re.sub(r'  - name: Expense\n    description: 지출 및 영수증 관리\n', '', content)
content = re.sub(r'  - name: Trip\n    description: 출장 등록 및 관리\n', '', content)

paths_to_remove = [
    '/api/expenses',
    '/api/expenses/{id}',
    '/api/trips',
    '/api/trips/{id}/expenses',
    '/api/cards',
    '/api/rules',
    '/api/stats/my'
]

for p in paths_to_remove:
    p_escaped = re.escape(p)
    pattern = r'^  ' + p_escaped + r':[\s\S]*?(?=\n  /api/|\ncomponents:)'
    content = re.sub(pattern, '', content, flags=re.MULTILINE)

schemas_to_remove = ['Rule', 'MyStatsResponse']
for s in schemas_to_remove:
    pattern = r'^    ' + s + r':[\s\S]*?(?=\n    [A-Z]|\nsecurity:)'
    content = re.sub(pattern, '', content, flags=re.MULTILINE)

with open('backend/openapi.yaml', 'w', encoding='utf-8') as f:
    f.write(content)
print('done')

