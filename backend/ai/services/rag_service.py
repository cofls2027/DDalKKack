from google import genai
from supabase import create_client
from config import GEMINI_API_KEY, SUPABASE_URL, SUPABASE_ANON_KEY

client   = genai.Client(api_key=GEMINI_API_KEY)
_supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)
EMB_MODEL = "gemini-embedding-001"

def get_embedding(text: str) -> list:
    result = client.models.embed_content(
        model=EMB_MODEL,
        contents=text,
    )
    return result.embeddings[0].values

async def retrieve_relevant_rules(ocr_data: dict, card_type: str, company_id: int) -> str:
    """영수증 정보로 관련 규정 조각 검색"""
    try:
        query = " | ".join([
            f"카드종류: {card_type}",
            f"가맹점: {ocr_data.get('merchant', '')}",
            f"금액: {ocr_data.get('amount', 0)}원",
            f"카테고리: {ocr_data.get('category', '')}",
            f"품목: {', '.join(ocr_data.get('items', []))}",
        ])
        query_vector = get_embedding(query)

        response = _supabase.rpc("match_rule_chunks", {
            "query_embedding":  query_vector,
            "match_company_id": company_id,
            "match_threshold":  0.5,
            "match_count":      5,
        }).execute()

        chunks = response.data or []
        if not chunks:
            print("[RAG] 관련 규정 없음 → 폴백 사용")
            return ""

        return "\n\n".join(f"[규정 {i+1}] {c['content']}" for i, c in enumerate(chunks))

    except Exception as e:
        print(f"[RAG] 검색 실패: {e}")
        return ""

async def embed_and_store_rules(rule_text: str, rule_id: int, company_id: int):
    """규정 문서 청킹 → 임베딩 → DB 저장"""
    CHUNK_SIZE, OVERLAP = 500, 100
    chunks, i = [], 0
    while i < len(rule_text):
        chunks.append(rule_text[i:i + CHUNK_SIZE])
        if i + CHUNK_SIZE >= len(rule_text): break
        i += CHUNK_SIZE - OVERLAP

    for idx, chunk in enumerate(chunks):
        embedding = get_embedding(chunk)
        _supabase.table("rule_chunks").insert({
            "rule_id": rule_id, "company_id": company_id,
            "chunk_index": idx, "content": chunk, "embedding": embedding,
        }).execute()
    print(f"[RAG] {len(chunks)}개 청크 저장 완료")