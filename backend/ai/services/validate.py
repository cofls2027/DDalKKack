import google.generativeai as genai
import os, json, re
from services.rag_service import retrieve_relevant_rules

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel("gemini-1.5-flash")

# 카드 타입별 폴백 규정
FALLBACK = {
    "정부지원카드": {"banned": ["담배","주류","술","맥주","소주","와인"]},
    "회사카드":     {"banned": ["담배"]},
    "개인카드":     {"banned": ["담배"]},
}

async def validate_receipt(ocr_data: dict, card_type: str, company_id: int) -> dict:
    """RAG 기반 검증 판정"""
    fb = FALLBACK.get(card_type, FALLBACK["회사카드"])

    # 1) 빠른 금지어 체크
    target = " ".join([ocr_data.get("rawText", "")] + ocr_data.get("items", []))
    for word in fb["banned"]:
        if word in target:
            return {"status": "rejected", "reason": f"[{card_type}] 금지 품목: '{word}'"}

    # 2) 금액 인식 실패
    if not ocr_data.get("amount") or ocr_data["amount"] <= 0:
        return {"status": "pending", "reason": "금액 인식 실패 - 수동 확인 필요"}

    # 3) RAG 검색
    rule_context = await retrieve_relevant_rules(ocr_data, card_type, company_id)

    # RAG 결과 없으면 한도 체크 폴백
    if not rule_context:
        if ocr_data["amount"] > fb["limit"]:
            return {"status": "pending", "reason": f"한도 초과: {ocr_data['amount']:,}원"}
        return {"status": "approved", "reason": None}

    # 4) Gemini 판정
    prompt = f"""
당신은 기업 지출 심사 AI입니다.
아래 [회사 규정]을 참고해서 [영수증 정보]의 승인 여부를 판단하세요.

[회사 규정]
{rule_context}

[영수증 정보]
- 카드 종류: {card_type}
- 가맹점: {ocr_data.get('merchant')}
- 결제 금액: {ocr_data.get('amount')}원
- 카테고리: {ocr_data.get('category')}
- 품목: {', '.join(ocr_data.get('items', []))}

반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트 금지.
{{
  "status": "approved" | "pending" | "rejected",
  "reason": "한 문장 이유 (approved면 null)"
}}
"""

    response = model.generate_content(prompt)
    cleaned  = re.sub(r'```json\n?|```\n?', '', response.text).strip()

    try:
        return json.loads(cleaned)
    except:
        return {"status": "pending", "reason": "AI 판정 실패 - 수동 확인 필요"}