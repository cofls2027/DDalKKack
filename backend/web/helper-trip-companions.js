function normalizeTripCompanions(value){
  if(Array.isArray(value)) return value;
  if(!value) return [];
  return String(value)
    .split(',')
    .map(item => item.trim())
    .filter(Boolean);
}

module.exports = {
  normalizeTripCompanions
};
