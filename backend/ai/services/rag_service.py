import google.generativeai as genai
import os
from supabase import create_client

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
supabase = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_SERVICE_KEY")
)

def get_embedding(text: str) -> list[float]:
    """텍스트 → 임베딩 벡터 (768차원)"""
    result = genai.embed_content(
        model="models/text-embedding-004",
        content=text,
    )
    return result["embedding"]

async def retrieve_relevant_rules(ocr_data: dict, card_type: str, company_id: int) -> str:
    """영수증 정보로 관련 규정 조각 검색"""
    query = " | ".join([
        f"카드종류: {card_type}",
        f"가맹점: {ocr_data.get('merchant', '')}",
        f"금액: {ocr_data.get('amount', 0)}원",
        f"카테고리: {ocr_data.get('category', '')}",
        f"품목: {', '.join(ocr_data.get('items', []))}",
    ])

    query_vector = get_embedding(query)

    # pgvector 유사도 검색
    response = supabase.rpc("match_rule_chunks", {
        "query_embedding":  query_vector,
        "match_company_id": company_id,
        "match_threshold":  0.7,
        "match_count":      5,
    }).execute()

    chunks = response.data or []
    if not chunks:
        return ""

    return "\n\n".join(
        f"[규정 {i+1}] {c['content']}"
        for i, c in enumerate(chunks)
    )

async def embed_and_store_rules(rule_text: str, rule_id: int, company_id: int):
    """규정 문서 청킹 → 임베딩 → DB 저장"""
    CHUNK_SIZE = 500
    OVERLAP    = 100
    chunks = []
    i = 0
    while i < len(rule_text):
        chunks.append(rule_text[i:i + CHUNK_SIZE])
        if i + CHUNK_SIZE >= len(rule_text):
            break
        i += CHUNK_SIZE - OVERLAP

    for idx, chunk in enumerate(chunks):
        embedding = get_embedding(chunk)
        supabase.table("rule_chunks").insert({
            "rule_id":    rule_id,
            "company_id": company_id,
            "chunk_index": idx,
            "content":   chunk,
            "embedding": embedding,
        }).execute()