import { GoogleGenerativeAI } from '@google/generative-ai';
import { supabase }              from '../lib/supabase.js';
import { retrieveRelevantRules } from './ragService.js';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

// 카드 타입별 하드코딩 금지어 (RAG 실패 시 폴백)
// 정부지원카드: 술 + 담배 금지 / 회사카드: 담배만 금지
const FALLBACK = {
  '정부지원카드': { banned: ['담배','주류','술','맥주','소주','와인'], limit: 50000 },
  '회사카드':     { banned: ['담배'], limit: 100000 },
};

/**
 * RAG 기반 규정 검색 → Gemini 판정
 * @returns {{ status, reason }}
 */
export async function validateReceipt(ocrData, cardType, companyId) {

  // ── STEP 1: 빠른 하드코딩 체크 (금지어·금액 0) ────────
  const fb = FALLBACK[cardType] ?? FALLBACK['회사카드'];
  const target = [ocrData.rawText, ...(ocrData.items ?? [])].join(' ');
  const found  = fb.banned.find(w => target.includes(w));
  if (found)
    return { status: 'rejected', reason: `[${cardType}] 금지 품목: "${found}"` };
  if (!ocrData.amount || ocrData.amount <= 0)
    return { status: 'pending', reason: '금액 인식 실패 - 수동 확인 필요' };

  // ── STEP 2: RAG — 관련 규정 검색 ──────────────────────
  const ruleContext = await retrieveRelevantRules(ocrData, cardType, companyId);

  // RAG 결과 없으면 단순 한도 체크로 폴백
  if (!ruleContext) {
    return ocrData.amount > fb.limit
      ? { status: 'pending',  reason: `한도 초과: ${ocrData.amount.toLocaleString()}원` }
      : { status: 'approved', reason: null };
  }

  // ── STEP 3: Gemini에게 규정 + 영수증 정보 주고 판정 요청 ─
  const prompt = `
당신은 기업 지출 심사 AI입니다.
아래 [회사 규정]을 참고해서 [영수증 정보]가 승인 가능한지 판단하세요.

[회사 규정]
${ruleContext}

[영수증 정보]
- 카드 종류: ${cardType}
- 가맹점: ${ocrData.merchant}
- 결제 금액: ${ocrData.amount}원
- 카테고리: ${ocrData.category}
- 품목: ${(ocrData.items ?? []).join(', ')}

반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트 금지.
{
  "status": "approved" | "pending" | "rejected",
  "reason": "한 문장으로 이유 설명 (approved면 null)"
}
`;

  const result = await model.generateContent(prompt);
  const cleaned = result.response.text()
    .replace(/```json\n?|```\n?/g, '').trim();

  try {
    return JSON.parse(cleaned);
  } catch {
    // JSON 파싱 실패 → 안전하게 보류
    return { status: 'pending', reason: 'AI 판정 실패 - 수동 확인 필요' };
  }
}