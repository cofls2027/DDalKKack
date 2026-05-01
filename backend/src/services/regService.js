import { GoogleGenerativeAI } from '@google/generative-ai';
import { supabase } from '../lib/supabase.js';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * 텍스트 → 임베딩 벡터 생성 (768차원)
 * Supabase pgvector와 호환
 */
export async function getEmbedding(text) {
  const embModel = genAI.getGenerativeModel({
    model: 'text-embedding-004',
  });
  const result = await embModel.embedContent(text);
  return result.embedding.values; // number[]
}

/**
 * RAG: 영수증 데이터와 가장 유사한 규정 조각을 찾아서 반환
 *
 * @param {object} ocrData   - { merchant, amount, category, items, rawText }
 * @param {string} cardType  - '회사카드' | '정부지원카드'
 * @param {number} companyId
 * @returns {string}  - 관련 규정 텍스트 (Gemini에게 넘길 context)
 */
export async function retrieveRelevantRules(ocrData, cardType, companyId) {
  // 1) 영수증 요약 텍스트 생성 (검색 쿼리로 사용)
  const query = [
    `카드종류: ${cardType}`,
    `가맹점: ${ocrData.merchant}`,
    `금액: ${ocrData.amount}원`,
    `카테고리: ${ocrData.category}`,
    `품목: ${(ocrData.items ?? []).join(', ')}`,
  ].join(' | ');

  // 2) 쿼리 임베딩
  const queryVector = await getEmbedding(query);

  // 3) pgvector 유사도 검색 (cosine distance)
  const { data: chunks, error } = await supabase
    .rpc('match_rule_chunks', {
      query_embedding: queryVector,
      match_company_id: companyId,
      match_threshold: 0.7,   // 유사도 70% 이상만
      match_count: 5,           // 상위 5개 조각
    });

  if (error) {
    console.error('[RAG] 벡터 검색 실패', error);
    return '';
  }

  // 4) 검색된 규정 조각들을 하나의 컨텍스트로 합치기
  return chunks
    ?.map((c, i) => `[규정 ${i + 1}] ${c.content}`)
    .join('\n\n') ?? '';
}

/**
 * 규정 문서 → 청킹 → 임베딩 → DB 저장
 * 관리자가 규정 PDF 업로드할 때 호출
 *
 * @param {string} ruleText  - 규정 전체 텍스트
 * @param {number} ruleId    - rules 테이블 id
 * @param {number} companyId
 */
export async function embedAndStoreRules(ruleText, ruleId, companyId) {
  // 500자씩 청킹 (100자 오버랩)
  const CHUNK_SIZE = 500;
  const OVERLAP    = 100;
  const chunks = [];

  for (let i = 0; i < ruleText.length; i += CHUNK_SIZE - OVERLAP) {
    chunks.push(ruleText.slice(i, i + CHUNK_SIZE));
    if (i + CHUNK_SIZE >= ruleText.length) break;
  }

  // 각 청크 임베딩 후 저장
  for (const [idx, chunk] of chunks.entries()) {
    const embedding = await getEmbedding(chunk);

    await supabase.from('rule_chunks').insert({
      rule_id:    ruleId,
      company_id: companyId,
      chunk_index: idx,
      content:    chunk,
      embedding,  // vector(768)
    });
  }
}