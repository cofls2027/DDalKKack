const ADMIN_TOKEN_KEY = 'ddalkkack-admin-token';
let adminAccessToken = sessionStorage.getItem(ADMIN_TOKEN_KEY) || '';
let currentAdminProfile = null;
let editUserCurrentPasswordOriginal = '';

const state = {
  users: [
    { id: 'u001', company_id: 1, name: '김민준', email: 'minjun@example.com', phone: '01011112222', position: '매니저', role: 'employee', is_active: true },
    { id: 'u002', company_id: 1, name: '이지현', email: 'jihyun@example.com', phone: '01022223333', position: '대리', role: 'employee', is_active: true },
    { id: 'u003', company_id: 1, name: '박지훈', email: 'jihoon@example.com', phone: '01033334444', position: '팀장', role: 'manager', is_active: true },
    { id: 'u004', company_id: 1, name: '최준호', email: 'junho@example.com', phone: '01044445555', position: '사원', role: 'employee', is_active: true }
  ],
  receipts: [
    { id: 1, user_id: 'u001', company_id: 1, trip_id: null, merchant_name: '교보문고 광화문', category: '복리후생', amount: 32000, payment_date: '2026.05.01', status: 'pending', card_type: '회사카드', card_company: '국민카드', card_number: '4821', purpose: '업무 도서 구매', image_url: '', items: ['클린 아키텍처 1권', '문구류 2개'], reject_reason: null, storage_path: '' },
    { id: 2, user_id: 'u002', company_id: 1, trip_id: null, merchant_name: '편의점 점심', category: '식대', amount: 29000, payment_date: '2026.05.01', status: 'pending', card_type: '회사카드', card_company: '국민카드', card_number: '4821', purpose: '외근 중 식사', image_url: '', items: ['도시락 2개', '음료 2개'], reject_reason: null, storage_path: '' },
    { id: 3, user_id: 'u003', company_id: 1, trip_id: null, merchant_name: '식당 A', category: '식대', amount: 30000, payment_date: '2026.04.30', status: 'approved', card_type: '회사카드', card_company: '국민카드', card_number: '4821', purpose: '고객 미팅 식사', image_url: '', items: ['점심 정식 2인'], reject_reason: null, storage_path: '' },
    { id: 4, user_id: 'u004', company_id: 1, trip_id: null, merchant_name: 'GS25 역삼점', category: '기타', amount: 4200, payment_date: '2026.04.29', status: 'rejected', card_type: '개인카드', card_company: '', card_number: '', purpose: '간식 구매', image_url: '', items: ['음료', '스낵'], reject_reason: '개인 간식 구매', storage_path: '' },
    { id: 5, user_id: 'u001', company_id: 1, trip_id: 1, merchant_name: 'KTX 승차권', category: '교통비', amount: 59800, payment_date: '2026.04.28', status: 'approved', card_type: '개인카드', card_company: '', card_number: '', purpose: '부산 출장 이동', image_url: '', items: ['KTX 일반실 1매'], reject_reason: null, storage_path: '' },
    { id: 6, user_id: 'u002', company_id: 1, trip_id: null, merchant_name: '스타벅스 강남점', category: '식대', amount: 28500, payment_date: '2026.04.27', status: 'approved', card_type: '회사카드', card_company: '국민카드', card_number: '4821', purpose: '외부 미팅', image_url: '', items: ['아메리카노 3잔'], reject_reason: null, storage_path: '' },
    { id: 7, user_id: 'u003', company_id: 1, trip_id: null, merchant_name: '한식당 점심', category: '회식비', amount: 87000, payment_date: '2026.04.26', status: 'approved', card_type: '회사카드', card_company: '국민카드', card_number: '4821', purpose: '팀 회식', image_url: '', items: ['점심 세트 6인'], reject_reason: null, storage_path: '' },
    { id: 8, user_id: 'u001', company_id: 1, trip_id: null, merchant_name: '스타벅스 강남점', category: '식대', amount: 9400, payment_date: '2026.04.25', status: 'approved', card_type: '회사카드', card_company: '국민카드', card_number: '4821', purpose: '팀 미팅', image_url: '', items: ['아메리카노 2잔'], reject_reason: null, storage_path: '' },
    { id: 9, user_id: 'u002', company_id: 1, trip_id: null, merchant_name: '스타벅스 강남점', category: '식대', amount: 17600, payment_date: '2026.04.24', status: 'approved', card_type: '회사카드', card_company: '국민카드', card_number: '4821', purpose: '고객 미팅', image_url: '', items: ['라떼 2잔'], reject_reason: null, storage_path: '' }
  ],
  trips: [
    { id: 1, user_id: 'u001', company_id: 1, trip_name: '부산 고객사 방문', trip_purpose: '신규 계약 협의 및 현장 미팅', trip_companions: ['u002'], start_date: '2026-05-04', end_date: '2026-05-04' },
    { id: 2, user_id: 'u002', company_id: 1, trip_name: '제주 워크숍', trip_purpose: '상반기 프로젝트 회고 및 기획 워크숍', trip_companions: ['u003', 'u004'], start_date: '2026-05-20', end_date: '2026-05-22' },
    { id: 3, user_id: 'u003', company_id: 1, trip_name: '대전 현장 점검', trip_purpose: '장비 설치 상태 점검', trip_companions: [], start_date: '2026-04-29', end_date: '2026-04-30' }
  ],
  cards: [
    { id: 1, company_id: 1, card_type: 'corporate', card_company: '국민카드', card_number: '4821', is_active: true, user_id: null, card_description: '본사 법인카드' },
    { id: 2, company_id: 1, card_type: 'government', card_company: '신한카드', card_number: '7304', is_active: true, user_id: null, card_description: '정부지원 R&D 카드' }
  ],
  currentReceiptIndex: null,
  receiptDecisionSavingId: null,
  isRefreshing: false,
  currentTripIndex: null,
  tripCompanionDraft: [],
  statsPeriod: 'all',
  statsStart: '',
  statsEnd: '',
  statsModalType: '',
  statsModalSearch: '',
  statsSearchComposing: false
};

async function apiFetch(path, options = {}){
  const headers = { ...(options.headers || {}) };
  if(options.body && !headers['Content-Type']) headers['Content-Type'] = 'application/json';
  if(adminAccessToken) headers.Authorization = `Bearer ${adminAccessToken}`;
  const res = await fetch(path, { ...options, headers });
  const body = await res.json().catch(() => ({}));
  if(!res.ok){
    if(res.status === 401){
      adminAccessToken = '';
      sessionStorage.removeItem(ADMIN_TOKEN_KEY);
      document.getElementById('admin-screen').classList.remove('active');
      document.getElementById('login-screen').classList.add('active');
    }
    throw new Error(body.error || `요청에 실패했습니다. (${res.status})`);
  }
  return body;
}

async function login(){
  const email = document.getElementById('admin-email').value.trim();
  const password = document.getElementById('admin-password').value;
  if(!email || !password){
    alert('이메일과 비밀번호를 입력해주세요.');
    return;
  }
  let result;
  try{
    result = await apiFetch('/api/admin/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    });
  }catch(err){
    console.error('관리자 로그인 실패:', err);
    alert(err.message || '관리자 계정 정보가 올바르지 않습니다.');
    return;
  }
  adminAccessToken = result.access_token;
  sessionStorage.setItem(ADMIN_TOKEN_KEY, adminAccessToken);
  currentAdminProfile = result.profile;
  const loaded = await loadAdminData();
  if(!loaded) return;
  document.getElementById('login-screen').classList.remove('active');
  document.getElementById('admin-screen').classList.add('active');
  renderAll();
}

async function logout(){
  adminAccessToken = '';
  currentAdminProfile = null;
  sessionStorage.removeItem(ADMIN_TOKEN_KEY);
  document.getElementById('admin-screen').classList.remove('active');
  document.getElementById('login-screen').classList.add('active');
}

async function loadCurrentAdminProfile(){
  const { profile } = await apiFetch('/api/admin/me');
  currentAdminProfile = profile;
  return profile;
}

async function loadAdminData(){
  try{
    const data = await apiFetch('/api/admin/data');
    state.users = data.users || [];
    state.receipts = data.receipts || [];
    state.trips = (data.trips || []).map(trip => ({
      ...trip,
      trip_companions: normalizeTripCompanions(trip.trip_companions)
    }));
    state.cards = data.cards || [];
    return true;
  }catch(err){
    console.error('관리자 데이터 조회 실패:', err);
    alert('데이터를 불러오지 못했습니다. 잠시 후 다시 시도하거나 담당자에게 문의해 주세요.');
    return false;
  }
}

function normalizeTripCompanions(value){
  if(Array.isArray(value)) return value;
  if(!value) return [];
  return String(value)
    .split(',')
    .map(item => item.trim())
    .filter(Boolean);
}

function setupRefreshButtons(){
  document.querySelectorAll('.topbar').forEach(topbar => {
    if(topbar.querySelector('.refresh-btn')) return;
    const actionButtons = Array.from(topbar.children).filter(child => child.tagName === 'BUTTON');
    const tools = document.createElement('div');
    tools.className = 'topbar-tools';
    actionButtons.forEach(button => tools.appendChild(button));
    tools.insertAdjacentHTML('beforeend', `
      <button type="button" class="refresh-btn" onclick="refreshAdminData()" aria-label="데이터 새로고침" title="데이터 새로고침">
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <path d="M20 11a8 8 0 1 0-2.3 5.7" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"></path>
          <path d="M20 5v6h-6" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"></path>
        </svg>
      </button>
    `);
    topbar.appendChild(tools);
  });
}

function setRefreshButtonsLoading(isLoading){
  document.querySelectorAll('.refresh-btn').forEach(btn => {
    btn.disabled = isLoading;
    btn.classList.toggle('loading', isLoading);
  });
}

async function refreshAdminData(){
  if(state.isRefreshing) return;
  state.isRefreshing = true;
  setRefreshButtonsLoading(true);
  const loaded = await loadAdminData();
  if(loaded) renderAll();
  state.isRefreshing = false;
  setRefreshButtonsLoading(false);
}

function showPanel(id){
  document.querySelectorAll('.panel').forEach(panel => panel.classList.remove('active'));
  document.getElementById(`panel-${id}`).classList.add('active');
  document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.toggle('active', btn.dataset.panel === id));
  if(id === 'dashboard') renderDashboard();
  if(id === 'stats') renderStats();
  if(id === 'trips') renderTrips();
  if(id === 'patterns') renderPatterns();
  if(id === 'cards') renderCards();
  if(id === 'accounts') renderAccounts();
}

function renderAll(){
  renderDashboard();
  renderStats();
  renderReviews();
  renderTrips();
  renderPatterns();
  renderCards();
  renderAccounts();
}

function renderDashboard(){
  renderTodayStatus();
  renderDashboardAlerts();
  renderRecentSubmissions();
}

function toDateOnly(value){
  if(!value) return '';
  return String(value).split('T')[0].replace(/\./g, '-');
}

function formatPaymentDate(value){
  return toDateOnly(value).replace(/-/g, '.');
}

function toLocalDate(value){
  if(!value) return null;
  const normalized = String(value).includes('T') ? String(value) : String(value).replace(' ', 'T');
  const date = new Date(normalized);
  return Number.isNaN(date.getTime()) ? null : date;
}

function getLocalDateKey(value){
  const date = value instanceof Date ? value : toLocalDate(value);
  if(!date) return '';
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function getTodayKey(){
  return getLocalDateKey(new Date());
}

function getReceiptDashboardDate(item){
  if(['approved', 'rejected'].includes(item.status) && item.reviewed_at) return item.reviewed_at;
  return item.created_at || item.payment_date;
}

function formatReviewDateTime(value){
  const date = toLocalDate(value);
  if(!date) return '';
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  return `${year}.${month}.${day} ${hours}:${minutes}`;
}

function getTodayReceipts(){
  const todayKey = getTodayKey();
  return getVisibleReceipts().filter(item => getLocalDateKey(getReceiptDashboardDate(item)) === todayKey);
}

function renderTodayStatus(){
  const today = getTodayReceipts();
  const total = today.reduce((sum, item) => sum + item.amount, 0);
  const approved = today.filter(item => item.status === 'approved').length;
  const pending = today.filter(item => item.status === 'pending').length;
  const rejected = today.filter(item => item.status === 'rejected').length;
  document.getElementById('today-status').innerHTML = `
    <div>
      <div class="today-total">${total.toLocaleString()}원</div>
    </div>
    <div class="today-meta">
      <div class="today-metric submit"><strong>${today.length}</strong><span>제출</span></div>
      <div class="today-metric pending"><strong>${pending}</strong><span>검토 대기</span></div>
      <div class="today-metric approved"><strong>${approved}</strong><span>승인</span></div>
      <div class="today-metric rejected"><strong>${rejected}</strong><span>반려</span></div>
    </div>
  `;
}

function getDashboardAlerts(){
  const today = getTodayReceipts();
  const receipts = getVisibleReceipts();
  const nearLimit = receipts.filter(item => item.category === '식대' && item.amount >= 28000 && item.amount <= 30000);
  const repeated = receipts.filter(item => item.merchant_name === '스타벅스 강남점');
  const rejected = today.filter(item => item.status === 'rejected');
  return [
    nearLimit.length ? { level: 'high', title: '식대 한도 근접', desc: `식대 28,000원 이상 결제가 ${nearLimit.length}건 있습니다.` } : null,
    repeated.length >= 3 ? { level: '', title: '동일 가맹점 반복', desc: `스타벅스 강남점 결제가 ${repeated.length}건 감지되었습니다.` } : null,
    rejected.length ? { level: 'high', title: '오늘 반려 발생', desc: `오늘 반려된 영수증이 ${rejected.length}건 있습니다.` } : null
  ].filter(Boolean);
}

function renderDashboardAlerts(){
  const alerts = getDashboardAlerts();
  document.getElementById('alert-count-badge').textContent = `${alerts.length}개`;
  if(!alerts.length){
    document.getElementById('dashboard-alerts').innerHTML = '<div class="empty">현재 표시할 이상 징후가 없습니다.</div>';
    return;
  }
  document.getElementById('dashboard-alerts').innerHTML = alerts.map(alert => `
    <div class="alert-item ${alert.level}">
      <div class="alert-title">${alert.title}</div>
      <div class="alert-desc">${alert.desc}</div>
    </div>
  `).join('');
}

function renderRecentSubmissions(){
  const recent = getVisibleReceipts().slice(0, 3);
  if(!recent.length){
    document.getElementById('recent-submissions').innerHTML = '<div class="empty">표시할 최근 제출이 없습니다.</div>';
    return;
  }
  document.getElementById('recent-submissions').innerHTML = recent.map(item => `
    <div class="recent-item">
      <div>
        <div class="recent-title">${item.merchant_name}</div>
        <div class="recent-meta">${getReceiptEmployeeDisplay(item)} · ${item.category} · ${formatPaymentDate(item.payment_date)}</div>
      </div>
      <div class="recent-side">
        <div class="recent-amount">${item.amount.toLocaleString()}원</div>
        ${statusWithReviewTime(item)}
      </div>
    </div>
  `).join('');
}

function renderStats(){
  renderStatsPeriodControls();
  renderStatsSummary();
  renderStatsCategoryBars();
  renderStatsChangeList();
  renderEmployeeBars();
  renderCardRatio();
  renderTrendBars();
  renderStatsTopMerchants();
  renderEmployeeCategoryMatrix();
}

function sumBy(items, key){
  return items.reduce((acc, item) => {
    acc[item[key]] = (acc[item[key]] || 0) + item.amount;
    return acc;
  }, {});
}

function escapeHtml(value){
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function getEmployeeKey(item){
  return item.user_id;
}

function isEmployeeActive(key){
  const account = state.users.find(item => item.id === key);
  return !account || account.is_active !== false;
}

function getVisibleReceipts(){
  return state.receipts.filter(item => isEmployeeActive(getEmployeeKey(item)));
}

function getApprovedReceipts(){
  return getVisibleReceipts().filter(item => item.status === 'approved');
}

function getVisibleReceiptEntries(){
  return state.receipts
    .map((item, index) => ({ item, index }))
    .filter(entry => isEmployeeActive(getEmployeeKey(entry.item)));
}

function getVisibleTripEntries(){
  return state.trips
    .map((item, index) => ({ item, index }))
    .filter(entry => isEmployeeActive(entry.item.user_id));
}

function getEmployeeProfile(key){
  return state.users.find(account => account.id === key || account.phone === key) || { name: key, position: '직급 미등록', phone: '' };
}

function getEmployeeDisplay(key){
  const profile = getEmployeeProfile(key);
  const phoneLast4 = profile.phone ? profile.phone.slice(-4) : '----';
  return `${profile.name} · ${profile.position} · ${phoneLast4}`;
}

function getReceiptEmployeeDisplay(item){
  return getEmployeeDisplay(getEmployeeKey(item));
}

function matchesEmployeeKeySearch(key){
  const profile = getEmployeeProfile(key);
  const keyword = state.statsModalSearch.trim().toLowerCase();
  const searchable = [
    profile.name,
    profile.position,
    profile.phone,
    profile.phone ? profile.phone.slice(-4) : '',
    getEmployeeDisplay(key)
  ].join(' ').toLowerCase();
  return searchable.includes(keyword);
}

function sumByEmployee(items){
  return items.reduce((acc, item) => {
    const key = getEmployeeKey(item);
    acc[key] = (acc[key] || 0) + item.amount;
    return acc;
  }, {});
}

function parseDate(value){
  return new Date(`${toDateOnly(value)}T00:00:00`);
}

function getLatestStatsReceiptDate(){
  return getApprovedReceipts().map(item => parseDate(item.payment_date)).sort((a, b) => b - a)[0];
}

function getStatsItems(){
  const latest = getLatestStatsReceiptDate();
  if(!latest) return [];
  let start = null;
  let end = latest;
  if(state.statsPeriod === 'custom' && state.statsStart && state.statsEnd){
    start = parseDate(state.statsStart);
    end = parseDate(state.statsEnd);
  }else if(state.statsPeriod === 'month'){
    start = new Date(latest.getFullYear(), latest.getMonth(), 1);
  }else if(state.statsPeriod === '3m'){
    start = new Date(latest.getFullYear(), latest.getMonth() - 2, 1);
  }else if(state.statsPeriod === '6m'){
    start = new Date(latest.getFullYear(), latest.getMonth() - 5, 1);
  }
  return getApprovedReceipts().filter(item => {
    const date = parseDate(item.payment_date);
    return (!start || date >= start) && (!end || date <= end);
  });
}

function getStatsPeriodLabel(){
  const labels = { month: '이번 달', '3m': '3개월', '6m': '6개월', all: '전체', custom: '직접 선택' };
  return labels[state.statsPeriod] || '이번 달';
}

function renderStatsPeriodControls(){
  document.querySelectorAll('.period-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.period === state.statsPeriod);
  });
  document.getElementById('stats-period-label').textContent = getStatsPeriodLabel();
}

function setStatsPeriod(period){
  state.statsPeriod = period;
  if(period !== 'custom'){
    state.statsStart = '';
    state.statsEnd = '';
    document.getElementById('stats-start').value = '';
    document.getElementById('stats-end').value = '';
  }
  renderStats();
}

function setCustomStatsRange(){
  state.statsStart = document.getElementById('stats-start').value;
  state.statsEnd = document.getElementById('stats-end').value;
  if(state.statsStart && state.statsEnd){
    state.statsPeriod = 'custom';
  }
  renderStats();
}

function renderStatsSummary(){
  const items = getStatsItems();
  const total = items.reduce((sum, item) => sum + item.amount, 0);
  const employees = new Set(items.map(item => getEmployeeKey(item)));
  const avg = Math.round(total / Math.max(employees.size, 1));
  document.getElementById('stats-summary').innerHTML = `
    <div class="stat"><strong>${total.toLocaleString()}원</strong><span>전체 지출</span></div>
    <div class="stat"><strong>${items.length}건</strong><span>승인 건수</span></div>
    <div class="stat"><strong>${avg.toLocaleString()}원</strong><span>1인 평균</span></div>
    <div class="stat"><strong>${employees.size}명</strong><span>사용 직원</span></div>
  `;
}

function renderStatsCategoryBars(){
  const totals = sumBy(getStatsItems(), 'category');
  const entries = Object.entries(totals).sort((a, b) => b[1] - a[1]);
  const max = Math.max(...entries.map(([, value]) => value), 1);
  document.getElementById('stats-category-bars').innerHTML = entries.map(([label, value]) => `
    <div class="bar-row">
      <div class="bar-label">${label}</div>
      <div class="bar-track"><div class="bar-fill" style="width:${Math.round(value / max * 100)}%"></div></div>
      <div class="bar-value">${value.toLocaleString()}원</div>
    </div>
  `).join('') || '<div class="empty">선택한 기간의 데이터가 없습니다.</div>';
}

function renderStatsChangeList(){
  const latest = getLatestStatsReceiptDate();
  if(!latest){
    document.getElementById('stats-change-list').innerHTML = '<div class="empty">선택한 기간의 데이터가 없습니다.</div>';
    return;
  }
  const currentStart = new Date(latest.getFullYear(), latest.getMonth(), 1);
  const prevStart = new Date(latest.getFullYear(), latest.getMonth() - 1, 1);
  const prevEnd = new Date(latest.getFullYear(), latest.getMonth(), 0);
  const receipts = getApprovedReceipts();
  const current = receipts.filter(item => parseDate(item.payment_date) >= currentStart && parseDate(item.payment_date) <= latest);
  const previous = receipts.filter(item => parseDate(item.payment_date) >= prevStart && parseDate(item.payment_date) <= prevEnd);
  const currentTotal = current.reduce((sum, item) => sum + item.amount, 0);
  const previousTotal = previous.reduce((sum, item) => sum + item.amount, 0);
  const diff = currentTotal - previousTotal;
  const percent = previousTotal ? Math.round(diff / previousTotal * 100) : 0;
  const currentFood = current.filter(item => item.category === '식대').reduce((sum, item) => sum + item.amount, 0);
  const previousFood = previous.filter(item => item.category === '식대').reduce((sum, item) => sum + item.amount, 0);
  const foodDiff = currentFood - previousFood;
  document.getElementById('stats-change-list').innerHTML = `
    <div class="change-item">
      <div><div class="change-title">전체 지출</div><div class="change-desc">전월 대비 ${Math.abs(percent)}%</div></div>
      <div class="change-value ${diff >= 0 ? 'change-up' : 'change-down'}">${diff >= 0 ? '+' : '-'}${Math.abs(diff).toLocaleString()}원</div>
    </div>
    <div class="change-item">
      <div><div class="change-title">식대</div><div class="change-desc">주요 반복 카테고리</div></div>
      <div class="change-value ${foodDiff >= 0 ? 'change-up' : 'change-down'}">${foodDiff >= 0 ? '+' : '-'}${Math.abs(foodDiff).toLocaleString()}원</div>
    </div>
  `;
}

function renderCategoryBars(){
  const approved = getVisibleReceipts().filter(item => item.status === 'approved');
  const totals = sumBy(approved, 'category');
  const entries = Object.entries(totals).sort((a, b) => b[1] - a[1]);
  const max = Math.max(...entries.map(([, value]) => value), 1);
  document.getElementById('category-bars').innerHTML = entries.map(([label, value]) => `
    <div class="bar-row">
      <div class="bar-label">${label}</div>
      <div class="bar-track"><div class="bar-fill" style="width:${Math.round(value / max * 100)}%"></div></div>
      <div class="bar-value">${value.toLocaleString()}원</div>
    </div>
  `).join('');
}

function renderStatusSummary(){
  const statuses = [
    { key: 'approved', label: '승인', cls: 'status-approved' },
    { key: 'pending', label: '검토 대기', cls: 'status-pending' },
    { key: 'rejected', label: '반려', cls: 'status-rejected' }
  ];
  document.getElementById('status-summary').innerHTML = statuses.map(status => {
    const count = getVisibleReceipts().filter(item => item.status === status.key).length;
    return `<div class="status-card ${status.cls}"><div class="status-number">${count}</div><div class="status-label">${status.label}</div></div>`;
  }).join('');
}

function renderEmployeeBars(){
  const entries = getEmployeeSpendEntries().slice(0, 5);
  const max = Math.max(...entries.map(([, value]) => value), 1);
  document.getElementById('employee-bars').innerHTML = entries.map(([key, value]) => `
    <div class="bar-row">
      <div class="bar-label">${getEmployeeDisplay(key)}</div>
      <div class="bar-track"><div class="bar-fill" style="width:${Math.round(value / max * 100)}%"></div></div>
      <div class="bar-value">${value.toLocaleString()}원</div>
    </div>
  `).join('') || '<div class="empty">선택한 기간의 데이터가 없습니다.</div>';
}

function getEmployeeSpendEntries(){
  const totals = sumByEmployee(getStatsItems());
  return Object.entries(totals).sort((a, b) => b[1] - a[1]);
}

function renderCardRatio(){
  const totals = sumBy(getStatsItems(), 'card_type');
  const entries = Object.entries(totals);
  const colors = ['var(--p)', 'var(--g)', 'var(--b)', 'var(--am)'];
  const total = entries.reduce((sum, [, value]) => sum + value, 0) || 1;
  if(!entries.length){
    document.getElementById('card-donut').style.background = 'conic-gradient(#eee 0% 100%)';
    document.getElementById('card-legend').innerHTML = '<div class="empty">선택한 기간의 데이터가 없습니다.</div>';
    return;
  }
  let start = 0;
  const gradient = entries.map(([, value], index) => {
    const end = start + value / total * 100;
    const segment = `${colors[index % colors.length]} ${start}% ${end}%`;
    start = end;
    return segment;
  }).join(', ');
  document.getElementById('card-donut').style.background = `conic-gradient(${gradient})`;
  document.getElementById('card-legend').innerHTML = entries.map(([label, value], index) => `
    <div class="legend-item">
      <span class="legend-dot" style="background:${colors[index % colors.length]}"></span>
      <span style="flex:1">${label}</span>
      <span>${Math.round(value / total * 100)}%</span>
    </div>
  `).join('');
}

function renderStatsTopMerchants(){
  const merchants = getStatsItems().reduce((acc, item) => {
    if(!acc[item.merchant_name]) acc[item.merchant_name] = { amount: 0, count: 0 };
    acc[item.merchant_name].amount += item.amount;
    acc[item.merchant_name].count += 1;
    return acc;
  }, {});
  const entries = Object.entries(merchants).sort((a, b) => b[1].amount - a[1].amount).slice(0, 5);
  document.getElementById('stats-top-merchants').innerHTML = entries.map(([name, data], index) => `
    <div class="merchant-item">
      <div class="merchant-rank">${index + 1}</div>
      <div>
        <div class="merchant-name">${name}</div>
        <div class="merchant-count">${data.count}건</div>
      </div>
      <div class="merchant-amount">${data.amount.toLocaleString()}원</div>
    </div>
  `).join('') || '<div class="empty">선택한 기간의 데이터가 없습니다.</div>';
}

function renderEmployeeCategoryMatrix(){
  const { employeeKeys, categories, matrix } = getEmployeeCategoryData();
  const previewEmployees = employeeKeys.slice(0, 5);
  if(!employeeKeys.length || !categories.length){
    document.getElementById('employee-category-matrix').innerHTML = '<tr><td class="empty">선택한 기간의 데이터가 없습니다.</td></tr>';
    return;
  }
  document.getElementById('employee-category-matrix').innerHTML = `
    <thead><tr><th>직원</th>${categories.map(category => `<th>${category}</th>`).join('')}</tr></thead>
    <tbody>
      ${previewEmployees.map(employeeKey => `
        <tr>
          <td><strong>${getEmployeeDisplay(employeeKey)}</strong></td>
          ${categories.map(category => `<td>${matrix[employeeKey]?.[category] ? Math.round(matrix[employeeKey][category] / 1000) + 'k' : '-'}</td>`).join('')}
        </tr>
      `).join('')}
    </tbody>
  `;
}

function getEmployeeCategoryData(){
  const items = getStatsItems();
  const employeeKeys = [...new Set(items.map(item => getEmployeeKey(item)))];
  const categories = [...new Set(items.map(item => item.category))];
  const matrix = {};
  items.forEach(item => {
    const employeeKey = getEmployeeKey(item);
    matrix[employeeKey] = matrix[employeeKey] || {};
    matrix[employeeKey][item.category] = (matrix[employeeKey][item.category] || 0) + item.amount;
  });
  return { employeeKeys, categories, matrix };
}

function showStatsModal(type){
  state.statsModalType = type;
  state.statsModalSearch = '';
  state.statsSearchComposing = false;
  if(type === 'employeeSpend'){
    showEmployeeSpendModal();
  }else if(type === 'employeeCategory'){
    showEmployeeCategoryModal();
  }
  document.getElementById('stats-modal').classList.add('show');
}

function showEmployeeSpendModal(){
  document.getElementById('stats-modal-title').textContent = '직원별 지출 전체보기';
  document.getElementById('stats-modal-sub').textContent = `${getStatsPeriodLabel()} 기준 전체 직원 지출입니다.`;
  document.getElementById('stats-modal-body').innerHTML = `
    <div class="modal-search">
      <input id="stats-employee-search" value="${escapeHtml(state.statsModalSearch)}" placeholder="이름, 직급, 전화번호 뒤 4자리로 검색" oncompositionstart="startStatsSearchComposition()" oncompositionend="endStatsSearchComposition(this.value)" oninput="filterStatsModal(this.value)" autofocus>
    </div>
    <div id="stats-modal-results"></div>
  `;
  renderEmployeeSpendModalResults();
}

function showEmployeeCategoryModal(){
  const { employeeKeys, categories } = getEmployeeCategoryData();
  document.getElementById('stats-modal-title').textContent = '직원별 카테고리 전체보기';
  document.getElementById('stats-modal-sub').textContent = `${getStatsPeriodLabel()} 기준 직원별 카테고리 지출입니다.`;
  if(!employeeKeys.length || !categories.length){
    document.getElementById('stats-modal-body').innerHTML = '<div class="empty">선택한 기간의 데이터가 없습니다.</div>';
    return;
  }
  document.getElementById('stats-modal-body').innerHTML = `
    <div class="modal-search">
      <input id="stats-employee-search" value="${escapeHtml(state.statsModalSearch)}" placeholder="이름, 직급, 전화번호 뒤 4자리로 검색" oncompositionstart="startStatsSearchComposition()" oncompositionend="endStatsSearchComposition(this.value)" oninput="filterStatsModal(this.value)" autofocus>
    </div>
    <div id="stats-modal-results"></div>
  `;
  renderEmployeeCategoryModalResults();
}

function renderEmployeeSpendModalResults(){
  const entries = getEmployeeSpendEntries().filter(([key]) => matchesEmployeeKeySearch(key));
  const max = Math.max(...entries.map(([, value]) => value), 1);
  document.getElementById('stats-modal-results').innerHTML = `
    <div class="chart-list">
      ${entries.map(([key, value]) => `
        <div class="bar-row">
          <div class="bar-label">${getEmployeeDisplay(key)}</div>
          <div class="bar-track"><div class="bar-fill" style="width:${Math.round(value / max * 100)}%"></div></div>
          <div class="bar-value">${value.toLocaleString()}원</div>
        </div>
      `).join('') || `<div class="empty">${state.statsModalSearch ? '검색 결과가 없습니다.' : '선택한 기간의 데이터가 없습니다.'}</div>`}
    </div>
  `;
}

function renderEmployeeCategoryModalResults(){
  const { employeeKeys, categories, matrix } = getEmployeeCategoryData();
  const filteredEmployees = employeeKeys.filter(employeeKey => matchesEmployeeKeySearch(employeeKey));
  document.getElementById('stats-modal-results').innerHTML = `
    <div class="table-wrap">
      <table>
        <thead><tr><th>직원</th>${categories.map(category => `<th>${category}</th>`).join('')}</tr></thead>
        <tbody>
          ${filteredEmployees.map(employeeKey => `
            <tr>
              <td><strong>${getEmployeeDisplay(employeeKey)}</strong></td>
              ${categories.map(category => `<td>${matrix[employeeKey]?.[category] ? matrix[employeeKey][category].toLocaleString() + '원' : '-'}</td>`).join('')}
            </tr>
          `).join('') || `<tr><td class="empty" colspan="${categories.length + 1}">검색 결과가 없습니다.</td></tr>`}
        </tbody>
      </table>
    </div>
  `;
}

function filterStatsModal(value){
  state.statsModalSearch = value;
  if(state.statsSearchComposing) return;
  if(state.statsModalType === 'employeeSpend'){
    renderEmployeeSpendModalResults();
  }else if(state.statsModalType === 'employeeCategory'){
    renderEmployeeCategoryModalResults();
  }
}

function startStatsSearchComposition(){
  state.statsSearchComposing = true;
}

function endStatsSearchComposition(value){
  state.statsSearchComposing = false;
  filterStatsModal(value);
}

function hideStatsModal(){
  state.statsSearchComposing = false;
  document.getElementById('stats-modal').classList.remove('show');
}

function closeStatsModal(event){
  if(event.target.id === 'stats-modal') hideStatsModal();
}

function renderTopMerchants(){
  const merchants = getVisibleReceipts().reduce((acc, item) => {
    if(!acc[item.merchant_name]) acc[item.merchant_name] = { amount: 0, count: 0 };
    acc[item.merchant_name].amount += item.amount;
    acc[item.merchant_name].count += 1;
    return acc;
  }, {});
  const entries = Object.entries(merchants)
    .sort((a, b) => b[1].amount - a[1].amount)
    .slice(0, 5);
  document.getElementById('top-merchants').innerHTML = entries.map(([name, data], index) => `
    <div class="merchant-item">
      <div class="merchant-rank">${index + 1}</div>
      <div>
        <div class="merchant-name">${name}</div>
        <div class="merchant-count">${data.count}건</div>
      </div>
      <div class="merchant-amount">${data.amount.toLocaleString()}원</div>
    </div>
  `).join('');
}

function renderTrendBars(){
  const latest = getLatestStatsReceiptDate();
  if(!latest){
    document.getElementById('trend-bars').innerHTML = '<div class="empty">선택한 기간의 데이터가 없습니다.</div>';
    return;
  }
  const approved = getApprovedReceipts();
  const months = Array.from({ length: 6 }, (_, index) => {
    const monthDate = new Date(latest.getFullYear(), latest.getMonth() - (5 - index), 1);
    const year = monthDate.getFullYear();
    const month = monthDate.getMonth();
    const value = approved
      .filter(item => {
        const date = parseDate(item.payment_date);
        return date.getFullYear() === year && date.getMonth() === month;
      })
      .reduce((sum, item) => sum + item.amount, 0);
    return { label: `${month + 1}월`, value };
  });
  const max = Math.max(...months.map(month => month.value), 1);
  document.getElementById('trend-bars').innerHTML = months.map(month => `
    <div class="trend-col">
      <div class="trend-value">${Math.round(month.value / 10000)}만</div>
      <div class="trend-bar" style="height:${Math.max(18, Math.round(month.value / max * 140))}px"></div>
      <div class="trend-label">${month.label}</div>
    </div>
  `).join('');
}

function renderPending(){
  const pending = getVisibleReceiptEntries().filter(entry => entry.item.status === 'pending');
  const target = document.getElementById('pending-list');
  if(!target)return;
  if(!pending.length){
    target.innerHTML = '<div class="empty">검토 대기 중인 영수증이 없습니다.</div>';
    return;
  }
  target.innerHTML = pending.map(({ item, index }) => receiptRow(item, index)).join('');
}

function renderReviews(){
  const entries = getVisibleReceiptEntries();
  if(!entries.length){
    document.getElementById('review-list').innerHTML = '<div class="empty">표시할 영수증이 없습니다.</div>';
    return;
  }
  document.getElementById('review-list').innerHTML = entries.map(({ item, index }) => {
    const isSaving = state.receiptDecisionSavingId === item.id;
    return `
      <div class="receipt-card">
        <div class="receipt-main">
          <div>
          <div class="receipt-name">${item.merchant_name}</div>
          <div class="receipt-meta">${getReceiptEmployeeDisplay(item)} · ${item.category} · ${formatPaymentDate(item.payment_date)}<br>${item.purpose || '-'}</div>
          </div>
          <button class="review-btn detail-btn" onclick="showReceiptDetail(${index})">영수증 확인</button>
        </div>
        <div class="receipt-status">${isSaving ? statusBadge('saving') : statusWithReviewTime(item)}</div>
        <div class="amount">${item.amount.toLocaleString()}원</div>
        <div class="receipt-side">
          ${item.status === 'pending' ? `
            <div class="review-actions">
              <button class="review-btn approve-btn" onclick="decideReceipt(${index}, 'approved')" ${isSaving ? 'disabled' : ''}>${isSaving ? '저장 중' : '승인'}</button>
              <button class="review-btn reject-btn" onclick="decideReceipt(${index}, 'rejected')" ${isSaving ? 'disabled' : ''}>${isSaving ? '저장 중' : '반려'}</button>
            </div>
          ` : ''}
        </div>
      </div>
    `;
  }).join('');
}

function formatTripDate(value){
  return value.replace(/-/g, '.');
}

function getTripDuration(item){
  return `${formatTripDate(item.start_date)} ~ ${formatTripDate(item.end_date)}`;
}

function getTripCompanionKeys(item){
  return (item.trip_companions || []).map(value => {
    const account = state.users.find(account => account.id === value || account.phone === value || account.name === value);
    return account ? account.id : value;
  });
}

function getTripCompanionDisplay(item){
  const companions = getTripCompanionKeys(item);
  if(!companions.length) return '-';
  return companions.map(key => {
    const profile = getEmployeeProfile(key);
    return profile.phone ? `${profile.name} · ${profile.position}` : key;
  }).join(', ');
}

function getAvailableTripCompanions(trip){
  return state.users.filter(account => account.is_active !== false && account.id !== trip.user_id);
}

function renderTripCompanionPicker(keyword = ''){
  const trip = state.trips[state.currentTripIndex];
  if(!trip) return;
  const selected = new Set(state.tripCompanionDraft);
  document.getElementById('edit-trip-companions').innerHTML = state.tripCompanionDraft.map(user_id => {
    const profile = getEmployeeProfile(user_id);
    return `
      <span class="selected-chip">
        ${profile.name}
        <button type="button" onclick="removeTripCompanion('${user_id}')" aria-label="${profile.name} 동행인 제외">x</button>
      </span>
    `;
  }).join('') || '<span class="muted">선택된 동행인이 없습니다.</span>';

  const query = keyword.trim().toLowerCase();
  if(!query){
    document.getElementById('trip-companion-results').innerHTML = '<div class="empty">사용자 이름을 검색해 동행인을 선택하세요.</div>';
    return;
  }
  const results = getAvailableTripCompanions(trip)
    .filter(account => !selected.has(account.id))
    .filter(account => [account.name, account.position, account.phone, account.phone.slice(-4)].join(' ').toLowerCase().includes(query));
  document.getElementById('trip-companion-results').innerHTML = results.map(account => `
    <button type="button" class="search-result" onclick="selectTripCompanion('${account.phone}')">
      ${account.name}
      <span class="choice-meta">${account.position} · ${account.phone.slice(-4)}</span>
    </button>
  `).join('') || '<div class="empty">검색 결과가 없습니다.</div>';
}

function renderTripCompanionSearch(value){
  renderTripCompanionPicker(value);
}

function selectTripCompanion(phone){
  const user = state.users.find(account => account.phone === phone || account.id === phone);
  const user_id = user ? user.id : phone;
  if(!state.tripCompanionDraft.includes(user_id)){
    state.tripCompanionDraft.push(user_id);
  }
  document.getElementById('edit-trip-companion-search').value = '';
  renderTripCompanionPicker();
}

function removeTripCompanion(phone){
  state.tripCompanionDraft = state.tripCompanionDraft.filter(value => value !== phone);
  renderTripCompanionPicker(document.getElementById('edit-trip-companion-search').value);
}

function getTodayIsoDate(){
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function isOngoingTrip(item){
  const today = getTodayIsoDate();
  return item.start_date <= today && today <= item.end_date;
}

function renderTrips(){
  const entries = getVisibleTripEntries();
  const currentEntries = entries.filter(entry => isOngoingTrip(entry.item));
  document.getElementById('current-trip-count').textContent = `(${currentEntries.length}건)`;
  document.getElementById('trip-count').textContent = `(${entries.length}건)`;
  document.getElementById('current-trip-table').innerHTML = renderTripRows(currentEntries, '현재 진행 중인 출장이 없습니다.');
  document.getElementById('trip-table').innerHTML = renderTripRows(entries, '등록된 출장이 없습니다.');
}

function renderTripRows(entries, emptyMessage){
  return entries.map(({ item, index }) => `
    <tr>
      <td>
        <strong>${item.trip_name}</strong>
        <div class="muted">${item.id} · ${item.trip_purpose || '-'}</div>
      </td>
      <td>
        <div class="person">
          <div class="avatar">${getEmployeeProfile(item.user_id).name.slice(0, 1)}</div>
          <div>
            <strong>${getEmployeeDisplay(item.user_id)}</strong>
          </div>
        </div>
      </td>
      <td>${getTripDuration(item)}</td>
      <td>${getTripCompanionDisplay(item)}</td>
      <td>
        <button class="review-btn detail-btn" onclick="showTripEdit(${index})">수정</button>
      </td>
    </tr>
  `).join('') || `<tr><td class="empty" colspan="5">${emptyMessage}</td></tr>`;
}

function showTripEdit(index){
  const trip = state.trips[index];
  if(!trip) return;
  state.currentTripIndex = index;
  document.getElementById('trip-edit-id').textContent = trip.id;
  document.getElementById('edit-trip-title').value = trip.trip_name;
  document.getElementById('edit-trip-purpose').value = trip.trip_purpose || '';
  document.getElementById('edit-trip-start').value = trip.start_date;
  document.getElementById('edit-trip-end').value = trip.end_date;
  state.tripCompanionDraft = getTripCompanionKeys(trip);
  document.getElementById('edit-trip-companion-search').value = '';
  renderTripCompanionPicker();
  document.getElementById('trip-form').classList.add('show');
  document.getElementById('edit-trip-title').focus();
}

function hideTripEdit(){
  state.currentTripIndex = null;
  state.tripCompanionDraft = [];
  document.getElementById('trip-form').classList.remove('show');
}

function saveTripEdit(){
  const trip = state.trips[state.currentTripIndex];
  if(!trip) return;
  const title = document.getElementById('edit-trip-title').value.trim();
  const purpose = document.getElementById('edit-trip-purpose').value.trim();
  const startDate = document.getElementById('edit-trip-start').value;
  const endDate = document.getElementById('edit-trip-end').value;
  const companions = [...state.tripCompanionDraft];
  if(!title || !purpose || !startDate || !endDate){
    alert('출장명, 목적, 시작일, 종료일은 필수입니다.');
    return;
  }
  if(startDate > endDate){
    alert('출장 종료일은 시작일보다 빠를 수 없습니다.');
    return;
  }
  trip.trip_name = title;
  trip.trip_purpose = purpose;
  trip.start_date = startDate;
  trip.end_date = endDate;
  trip.trip_companions = companions;
  hideTripEdit();
  renderTrips();
}

function renderPatterns(){
  const receipts = getVisibleReceipts();
  const repeatedMerchant = receipts.filter(item => item.merchant_name === '스타벅스 강남점');
  const nearLimit = receipts.filter(item => item.category === '식대' && item.amount >= 28000 && item.amount <= 30000);
  const rejected = receipts.filter(item => item.status === 'rejected');
  const employeeTotals = sumByEmployee(receipts.filter(item => item.status === 'approved'));
  const topEmployee = Object.entries(employeeTotals).sort((a, b) => b[1] - a[1])[0];
  const patterns = [
    {
      level: 'high',
      title: '동일 가맹점 반복',
      desc: `스타벅스 강남점 결제가 ${repeatedMerchant.length}건 감지되었습니다. 같은 목적의 반복 결제인지 확인이 필요합니다.`,
      tags: ['반복 결제', '가맹점']
    },
    {
      level: '',
      title: '한도 근접 결제',
      desc: `식대 한도에 근접한 결제가 ${nearLimit.length}건 있습니다. 자동 승인 전후 기준을 점검해보세요.`,
      tags: ['식대', '한도 근접']
    },
    {
      level: 'high',
      title: '반려 이력 확인',
      desc: `${rejected.map(item => getReceiptEmployeeDisplay(item)).join(', ') || '대상 없음'} 항목에서 반려 건이 있습니다. 금지 항목이나 목적 누락 여부를 확인하세요.`,
      tags: ['반려', '규정 확인']
    },
    {
      level: 'low',
      title: '직원별 지출 쏠림',
      desc: topEmployee ? `${getEmployeeDisplay(topEmployee[0])}님의 승인 지출이 ${topEmployee[1].toLocaleString()}원으로 가장 높습니다.` : '승인 지출 데이터가 아직 충분하지 않습니다.',
      tags: ['직원별', '승인 지출']
    }
  ];
  document.getElementById('pattern-list').innerHTML = patterns.map(pattern => `
    <div class="pattern-card ${pattern.level}">
      <div class="pattern-title">${pattern.title}</div>
      <div class="pattern-desc">${pattern.desc}</div>
      <div class="pattern-meta">${pattern.tags.map(tag => `<span class="badge ${pattern.level === 'high' ? 'ba' : 'bb'}">${tag}</span>`).join('')}</div>
    </div>
  `).join('');
}

function receiptRow(item, index){
  return `
    <div class="receipt-card">
      <div class="receipt-main">
        <div>
        <div class="receipt-name">${item.merchant_name}</div>
        <div class="receipt-meta">${getReceiptEmployeeDisplay(item)} · ${item.category} · ${formatPaymentDate(item.payment_date)}<br>${item.purpose || '-'}</div>
        </div>
        <button class="review-btn detail-btn" onclick="showReceiptDetail(${index})">영수증 확인</button>
      </div>
      <div class="receipt-status">${statusWithReviewTime(item)}</div>
      <div class="amount">${item.amount.toLocaleString()}원</div>
      <div class="receipt-side"></div>
    </div>
  `;
}

function renderReceiptImage(item){
  const lines = (item.items || []).map(name => `<div class="receipt-line"><span>${name}</span><span></span></div>`).join('');
  return `
    <div class="receipt-image-title">${item.merchant_name}</div>
    <div class="receipt-line"><span>일자</span><span>${formatPaymentDate(item.payment_date)}</span></div>
    <div class="receipt-line"><span>카드</span><span>${item.card_type || '-'}</span></div>
    ${lines}
    <div class="receipt-total"><span>합계</span><span>${item.amount.toLocaleString()}원</span></div>
  `;
}

function showReceiptDetail(index){
  const item = state.receipts[index];
  state.currentReceiptIndex = index;
  document.getElementById('receipt-image').innerHTML = renderReceiptImage(item);
  document.getElementById('detail-status').innerHTML = statusWithReviewTime(item);
  setReceiptEditMode(false);
  renderReceiptInfo(item, false);
  document.getElementById('receipt-modal').classList.add('show');
}

function renderReceiptInfo(item, editMode){
  document.getElementById('receipt-info').innerHTML = editMode ? `
    <div class="info-row"><div class="info-key">제출자</div><div class="info-val">${getReceiptEmployeeDisplay(item)}</div></div>
    <div class="info-row"><div class="info-key">가맹점</div><div class="info-val"><input class="edit-field" id="edit-merchant" value="${item.merchant_name}"></div></div>
    <div class="info-row"><div class="info-key">금액</div><div class="info-val"><input class="edit-field" id="edit-amount" type="number" value="${item.amount}"></div></div>
    <div class="info-row"><div class="info-key">카테고리</div><div class="info-val"><input class="edit-field" id="edit-category" value="${item.category}"></div></div>
    <div class="info-row"><div class="info-key">결제일</div><div class="info-val"><input class="edit-field" id="edit-date" value="${formatPaymentDate(item.payment_date)}"></div></div>
    <div class="info-row"><div class="info-key">카드</div><div class="info-val"><input class="edit-field" id="edit-card" value="${item.card_type || ''}"></div></div>
    <div class="info-row"><div class="info-key">목적</div><div class="info-val"><input class="edit-field" id="edit-purpose" value="${item.purpose || ''}"></div></div>
  ` : `
    <div class="info-row"><div class="info-key">제출자</div><div class="info-val">${getReceiptEmployeeDisplay(item)}</div></div>
    <div class="info-row"><div class="info-key">가맹점</div><div class="info-val">${item.merchant_name}</div></div>
    <div class="info-row"><div class="info-key">금액</div><div class="info-val">${item.amount.toLocaleString()}원</div></div>
    <div class="info-row"><div class="info-key">카테고리</div><div class="info-val">${item.category}</div></div>
    <div class="info-row"><div class="info-key">결제일</div><div class="info-val">${formatPaymentDate(item.payment_date)}</div></div>
    <div class="info-row"><div class="info-key">카드</div><div class="info-val">${item.card_type || '-'}</div></div>
    <div class="info-row"><div class="info-key">목적</div><div class="info-val">${item.purpose || '-'}</div></div>
  `;
}

function setReceiptEditMode(isEditing){
  document.getElementById('receipt-edit-btn').classList.toggle('hidden', isEditing);
  document.getElementById('receipt-save-btn').classList.toggle('hidden', !isEditing);
  document.getElementById('receipt-cancel-btn').classList.toggle('hidden', !isEditing);
}

function editReceiptDetail(){
  const item = state.receipts[state.currentReceiptIndex];
  if(!item)return;
  setReceiptEditMode(true);
  renderReceiptInfo(item, true);
}

function cancelReceiptEdit(){
  const item = state.receipts[state.currentReceiptIndex];
  if(!item)return;
  setReceiptEditMode(false);
  renderReceiptInfo(item, false);
}

function saveReceiptDetail(){
  const item = state.receipts[state.currentReceiptIndex];
  if(!item)return;
  const merchant = document.getElementById('edit-merchant').value.trim();
  const amount = Number(document.getElementById('edit-amount').value);
  const category = document.getElementById('edit-category').value.trim();
  const date = document.getElementById('edit-date').value.trim();
  if(!merchant || !amount || !category || !date){
    alert('가맹점, 금액, 카테고리, 결제일은 필수입니다.');
    return;
  }
  item.merchant_name = merchant;
  item.amount = amount;
  item.category = category;
  item.payment_date = date;
  item.card_type = document.getElementById('edit-card').value.trim();
  item.purpose = document.getElementById('edit-purpose').value.trim();
  document.getElementById('receipt-image').innerHTML = renderReceiptImage(item);
  setReceiptEditMode(false);
  renderReceiptInfo(item, false);
  renderDashboard();
  renderStats();
  renderReviews();
  renderPatterns();
}

function hideReceiptDetail(){
  document.getElementById('receipt-modal').classList.remove('show');
}

function closeReceiptDetail(event){
  if(event.target.id === 'receipt-modal') hideReceiptDetail();
}

function statusBadge(status){
  const map = {
    approved: '<span class="status-pill status-approved">승인</span>',
    pending: '<span class="status-pill status-pending">검토 대기</span>',
    rejected: '<span class="status-pill status-rejected">반려</span>',
    saving: '<span class="status-pill status-pending">저장 중</span>'
  };
  return map[status] || '<span class="status-pill status-pending">확인 필요</span>';
}

function statusWithReviewTime(item){
  if(!['approved', 'rejected'].includes(item.status)) return statusBadge(item.status);
  const reviewedAt = formatReviewDateTime(item.reviewed_at);
  return `${statusBadge(item.status)}${reviewedAt ? `<span class="status-time">${reviewedAt}</span>` : ''}`;
}

async function decideReceipt(index, status){
  if(!['approved', 'rejected'].includes(status)) return;
  const receipt = state.receipts[index];
  if(!receipt) return;
  if(state.receiptDecisionSavingId) return;
  state.receiptDecisionSavingId = receipt.id;
  renderReviews();
  let result;
  try{
    result = await apiFetch(`/api/admin/receipts/${receipt.id}/decision`, {
      method: 'PATCH',
      body: JSON.stringify({ status, reject_reason: receipt.reject_reason })
    });
  }catch(err){
    console.error('영수증 상태 저장 실패:', err);
    alert(err.message || '영수증 상태를 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.');
    state.receiptDecisionSavingId = null;
    renderReviews();
    return;
  }
  receipt.status = result.receipt.status;
  receipt.reject_reason = result.receipt.reject_reason;
  receipt.reviewed_at = result.receipt.reviewed_at;
  state.receiptDecisionSavingId = null;
  renderDashboard();
  renderStats();
  renderReviews();
  renderPatterns();
}

function showAddCard(){
  clearCardForm();
  document.getElementById('card-form').classList.add('show');
  document.getElementById('new-card-name').focus();
}

function hideAddCard(){
  document.getElementById('card-form').classList.remove('show');
  clearCardForm();
}

function clearCardForm(){
  document.getElementById('new-card-name').value = '';
  document.getElementById('new-card-type').value = 'corporate';
  document.getElementById('new-card-issuer').value = '';
  document.getElementById('new-card-number').value = '';
  document.getElementById('new-card-memo').value = '';
}

function getCardTypeLabel(type){
  return type === 'government' ? '정부지원카드' : '법인카드';
}

function generateCardId(){
  return Math.max(0, ...state.cards.map(card => Number(card.id) || 0)) + 1;
}

function normalizeCardNumber(value){
  return String(value || '').replace(/\D/g, '');
}

function formatCardNumber(value){
  const digits = normalizeCardNumber(value);
  if(!digits) return '-';
  return digits.replace(/(.{4})/g, '$1 ').trim();
}

async function addCard(){
  const name = document.getElementById('new-card-name').value.trim();
  const type = document.getElementById('new-card-type').value;
  const issuer = document.getElementById('new-card-issuer').value.trim();
  const cardNumber = normalizeCardNumber(document.getElementById('new-card-number').value);
  const memo = document.getElementById('new-card-memo').value.trim();
  if(!name || !issuer || !cardNumber){
    alert('카드명, 발급처, 카드번호 전체를 입력해주세요.');
    return;
  }
  if(cardNumber.length < 12 || cardNumber.length > 19){
    alert('카드번호는 숫자 12~19자리로 입력해주세요.');
    return;
  }
  if(state.cards.some(card => card.card_description === name || normalizeCardNumber(card.card_number) === cardNumber)){
    alert('이미 등록된 카드와 이름 또는 카드번호가 겹칩니다.');
    return;
  }
  let result;
  try{
    result = await apiFetch('/api/admin/cards', {
      method: 'POST',
      body: JSON.stringify({
        card_description: memo ? `${name} - ${memo}` : name,
        card_type: type,
        card_company: issuer,
        card_number: cardNumber
      })
    });
  }catch(err){
    console.error('카드 등록 실패:', err);
    alert(err.message || '카드를 등록하지 못했습니다.');
    return;
  }
  state.cards.push(result.card);
  hideAddCard();
  renderCards();
  alert(`${name} 카드가 등록되었습니다.`);
}

function renderCards(){
  const activeCards = state.cards.filter(card => card.is_active !== false);
  const inactiveCards = state.cards.filter(card => card.is_active === false);
  document.getElementById('active-card-count').textContent = `(${activeCards.length}장)`;
  document.getElementById('inactive-card-count').textContent = `(${inactiveCards.length}장)`;
  document.getElementById('active-card-table').innerHTML = renderCardRows(activeCards, '활성 카드가 없습니다.');
  document.getElementById('inactive-card-table').innerHTML = renderCardRows(inactiveCards, '비활성 카드가 없습니다.');
}

function renderCardRows(cards, emptyMessage){
  return cards.map(card => `
    <tr>
      <td class="card-name-col">
        <strong>${card.card_description}</strong>
        <div class="muted">${card.id}</div>
      </td>
      <td class="card-type-col"><span class="badge ${card.card_type === 'government' ? 'bb' : 'bp'}">${getCardTypeLabel(card.card_type)}</span></td>
      <td class="card-company-col">${card.card_company}</td>
      <td class="card-memo-col">${card.card_description || '-'}</td>
      <td class="card-number-col"><code>${formatCardNumber(card.card_number)}</code></td>
      <td class="card-status-col"><button class="account-status-btn ${card.is_active === false ? 'inactive' : 'active'}" onclick="toggleCardStatus('${card.id}')">${card.is_active === false ? '비활성' : '활성'}</button></td>
    </tr>
  `).join('') || `<tr><td class="empty" colspan="6">${emptyMessage}</td></tr>`;
}

async function toggleCardStatus(id){
  const card = state.cards.find(item => String(item.id) === String(id));
  if(!card) return;
  const nextActive = card.is_active === false;
  let result;
  try{
    result = await apiFetch(`/api/admin/cards/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ is_active: nextActive })
    });
  }catch(err){
    console.error('카드 상태 변경 실패:', err);
    alert(err.message || '카드 상태를 변경하지 못했습니다.');
    return;
  }
  card.is_active = result.card.is_active;
  renderCards();
}

function showAddAccount(){
  clearAccountForm();
  document.getElementById('account-form').classList.add('show');
  document.getElementById('new-email').focus();
}

function hideAddAccount(){
  document.getElementById('account-form').classList.remove('show');
  clearAccountForm();
}

function clearAccountForm(){
  document.getElementById('new-email').value = '';
  document.getElementById('new-phone').value = '';
  document.getElementById('new-name').value = '';
  document.getElementById('new-position').value = '';
}

function generateEmployeePassword(){
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
  const len = 16;
  const bytes = new Uint8Array(len);
  crypto.getRandomValues(bytes);
  let s = '';
  for(let i = 0; i < len; i++) s += chars[bytes[i] % chars.length];
  return s;
}

function showInitialPasswordModal(userName, password){
  document.getElementById('initial-password-sub').textContent = `${userName}님 계정의 초기 비밀번호입니다.`;
  document.getElementById('initial-password-display').value = password;
  document.getElementById('initial-password-modal').classList.add('show');
}

function hideInitialPasswordModal(){
  document.getElementById('initial-password-modal').classList.remove('show');
}

function closeInitialPasswordModal(event){
  if(event.target.id === 'initial-password-modal') hideInitialPasswordModal();
}

async function copyInitialPassword(){
  const el = document.getElementById('initial-password-display');
  try{
    await navigator.clipboard.writeText(el.value);
    alert('복사되었습니다.');
  } catch (_){
    el.select();
    alert('자동 복사에 실패했습니다. 필드를 직접 선택해 복사해 주세요.');
  }
}

function openEditUserModal(userId){
  const account = state.users.find(item => item.id === userId);
  if(!account) return;
  const currentPassword = account.staff_current_password || account.staff_initial_password || '';
  document.getElementById('edit-user-id').value = account.id;
  document.getElementById('edit-user-email').value = account.email || '';
  document.getElementById('edit-user-phone').value = account.phone || '';
  document.getElementById('edit-user-name').value = account.name || '';
  document.getElementById('edit-user-position').value = account.position || '';
  document.getElementById('edit-user-current-pw').value = currentPassword;
  editUserCurrentPasswordOriginal = currentPassword;
  document.getElementById('edit-user-staff-pw').value = account.staff_initial_password || '';
  document.getElementById('edit-user-modal').classList.add('show');
}

function hideEditUserModal(){
  document.getElementById('edit-user-modal').classList.remove('show');
}

function closeEditUserModal(event){
  if(event.target.id === 'edit-user-modal') hideEditUserModal();
}

async function saveEditedUser(){
  const id = document.getElementById('edit-user-id').value;
  const email = document.getElementById('edit-user-email').value.trim();
  const phone = normalizePhone(document.getElementById('edit-user-phone').value);
  const name = document.getElementById('edit-user-name').value.trim();
  const position = document.getElementById('edit-user-position').value.trim();
  const currentPassword = document.getElementById('edit-user-current-pw').value.trim();
  const staffPwRaw = document.getElementById('edit-user-staff-pw').value;
  const staff_initial_password = staffPwRaw.trim() === '' ? null : staffPwRaw.trim();
  const account = state.users.find(item => item.id === id);
  if(!account) return;
  if(!email || !phone || !name || !position){
    alert('이메일, 전화번호, 이름, 직급을 모두 입력해주세요.');
    return;
  }
  if(currentPassword && currentPassword.length < 6){
    alert('현재 로그인 비밀번호는 6자 이상이어야 합니다.');
    return;
  }
  if(!isValidPhone(phone)){
    alert('전화번호는 하이픈 없이 01012345678 형식의 11자리로 입력해주세요.');
    return;
  }
  if(state.users.some(u => u.id !== id && u.email === email)){
    alert('다른 사용자가 이미 사용 중인 이메일입니다.');
    return;
  }
  if(state.users.some(u => u.id !== id && u.phone === phone)){
    alert('다른 사용자가 이미 사용 중인 전화번호입니다.');
    return;
  }
  let result;
  try{
    const payload = { email, phone, name, position, staff_initial_password };
    if(currentPassword && currentPassword !== editUserCurrentPasswordOriginal){
      payload.password = currentPassword;
    }
    result = await apiFetch(`/api/admin/users/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(payload)
    });
  }catch(err){
    console.error('사용자 정보 수정 실패:', err);
    alert(err.message || '저장에 실패했습니다. 담당자에게 문의해 주세요.');
    return;
  }
  Object.assign(account, result.user);
  hideEditUserModal();
  renderAccounts();
  renderDashboard();
  renderStats();
  renderTrips();
  alert('저장되었습니다.');
}

function normalizePhone(phone){
  return phone.replace(/\D/g, '');
}

function isValidPhone(phone){
  return /^010\d{8}$/.test(phone);
}

async function addAccount(){
  const email = document.getElementById('new-email').value.trim();
  const phone = normalizePhone(document.getElementById('new-phone').value);
  const name = document.getElementById('new-name').value.trim();
  const position = document.getElementById('new-position').value.trim();
  if(!email || !phone || !name || !position){
    alert('이메일, 전화번호, 이름, 직급을 모두 입력해주세요.');
    return;
  }
  if(!isValidPhone(phone)){
    alert('전화번호는 하이픈 없이 01012345678 형식의 11자리로 입력해주세요.');
    return;
  }
  if(state.users.some(account => account.email === email)){
    alert('이미 등록된 이메일입니다.');
    return;
  }
  if(state.users.some(account => account.phone === phone)){
    alert('이미 등록된 전화번호입니다.');
    return;
  }
  const password = generateEmployeePassword();
  let result;
  try{
    result = await apiFetch('/api/admin/users', {
      method: 'POST',
      body: JSON.stringify({ email, phone, name, position, password })
    });
  } catch (err){
    console.error(err);
    alert(err.message || '로그인 계정 생성에 실패했습니다. 같은 이메일이 이미 존재할 수 있습니다.');
    return;
  }
  state.users.push(result.user);
  hideAddAccount();
  renderAccounts();
  renderDashboard();
  renderStats();
  renderTrips();
  showInitialPasswordModal(name, password);
}

function renderAccounts(){
  const activeAccounts = state.users.filter(account => account.is_active !== false);
  const inactiveAccounts = state.users.filter(account => account.is_active === false);
  document.getElementById('account-count').textContent = `(${activeAccounts.length}명)`;
  document.getElementById('inactive-account-count').textContent = `(${inactiveAccounts.length}명)`;
  document.getElementById('account-table').innerHTML = renderAccountRows(activeAccounts, '등록된 활성 사용자가 없습니다.');
  document.getElementById('inactive-account-table').innerHTML = renderAccountRows(inactiveAccounts, '비활성 사용자가 없습니다.');
}

function renderAccountRows(accounts, emptyMessage){
  return accounts.map(account => `
    <tr>
      <td>
        <div class="person">
          <div class="avatar">${account.name.charAt(0)}</div>
          <div>${account.name}</div>
        </div>
      </td>
      <td>${account.email || '-'}</td>
      <td>${account.phone || '-'}</td>
      <td>${account.position || '-'}</td>
      <td class="account-status-col"><button class="account-status-btn ${account.is_active === false ? 'inactive' : 'active'}" onclick="toggleAccountStatus('${account.id}')">${account.is_active === false ? '비활성' : '활성'}</button></td>
      <td class="account-action-col"><button type="button" class="modal-tool-btn" onclick="openEditUserModal('${account.id}')">수정</button></td>
    </tr>
  `).join('') || `<tr><td class="empty" colspan="6">${emptyMessage}</td></tr>`;
}

async function toggleAccountStatus(id){
  const account = state.users.find(item => item.id === id);
  if(!account) return;
  const nextActive = account.is_active === false;
  let result;
  try{
    result = await apiFetch(`/api/admin/users/${id}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ is_active: nextActive })
    });
  }catch(err){
    console.error('사용자 상태 변경 실패:', err);
    alert(err.message || '사용자 상태를 변경하지 못했습니다.');
    return;
  }
  account.is_active = result.user.is_active;
  renderAccounts();
  renderDashboard();
  renderStats();
  renderReviews();
  renderTrips();
  renderPatterns();
}

async function initAdminSession(){
  if(!adminAccessToken) return;
  try{
    const profile = await loadCurrentAdminProfile();
    if(!profile) return;
  }catch(err){
    console.error('관리자 세션 확인 실패:', err);
    adminAccessToken = '';
    sessionStorage.removeItem(ADMIN_TOKEN_KEY);
    return;
  }
  const loaded = await loadAdminData();
  if(!loaded) return;
  document.getElementById('login-screen').classList.remove('active');
  document.getElementById('admin-screen').classList.add('active');
  renderAll();
}

setupRefreshButtons();
initAdminSession();
