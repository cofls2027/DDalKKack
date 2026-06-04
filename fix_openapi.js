const fs = require('fs');
const lines = fs.readFileSync('backend/openapi.yaml', 'utf8').split(/\r?\n/);
let out = [];
let skip = false;
let skipPrefix = '';

for(let i=0; i<lines.length; i++) {
  const line = lines[i];
  
  if(line === '  - name: Rules' || line === '  - name: Stats' || line === '  - name: Expense' || line === '  - name: Trip') {
    skip = true;
    skipPrefix = '  '; // wait, the description is indented by 4 spaces
    continue;
  }
  
  if(skip && line.startsWith('    description:')) {
    skip = false;
    continue;
  }
  
  const pathsToRemove = [
    '  /api/expenses:',
    '  /api/expenses/{id}:',
    '  /api/trips:',
    '  /api/trips/{id}/expenses:',
    '  /api/cards:',
    '  /api/rules:',
    '  /api/stats/my:'
  ];
  if(pathsToRemove.includes(line)) {
    skip = true;
    skipPrefix = '    ';
    continue;
  }
  
  if(skip && skipPrefix === '    ' && (line.startsWith('  /api/') || line.startsWith('components:'))) {
    skip = false;
  }
  
  const schemasToRemove = [
    '    Rule:',
    '    MyStatsResponse:'
  ];
  if(schemasToRemove.includes(line)) {
    skip = true;
    skipPrefix = '      ';
    continue;
  }
  
  if(skip && skipPrefix === '      ' && (line.match(/^    [A-Z]/) || line.startsWith('security:'))) {
    skip = false;
  }
  
  if(!skip) {
    out.push(line);
  }
}

fs.writeFileSync('backend/openapi.yaml', out.join('\n'));
console.log('done');
