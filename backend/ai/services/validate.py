import json, re
from google import genai
from supabase import create_client
from config import GEMINI_API_KEY, SUPABASE_URL, SUPABASE_ANON_KEY
from datetime import datetime
print("######## VALIDATOR FILE RUNNING ########")
client    = genai.Client(api_key=GEMINI_API_KEY)
MODEL     = "gemini-2.5-flash"
_supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

# OCR 카테고리 → DB 카테고리 매핑
CATEGORY_MAP = {
    "식비":  "식비",
    "교통":  "교통비",
    "숙박":  "숙박",
    "기타":  "기타",
    "용품":  "용품",
}

async def validate_receipt(ocr_data: dict, card_type: str, company_id: int, position: str = None, headcount: int = 1) -> dict:
    """DB rules_2 테이블 기반 검증 판정"""

    # 1) 금액 인식 실패
    if not ocr_data.get("amount") or ocr_data["amount"] <= 0:
        return {"status": "pending", "reason": "금액 인식 실패 - 수동 확인 필요"}

    amount   = ocr_data.get("amount", 0)
    category = ocr_data.get("category", "기타")
    db_category = CATEGORY_MAP.get(category, category)

    # 2) DB에서 해당 회사 + 카테고리 규정 조회
    response = _supabase.table("rules_2") \
        .select("*") \
        .eq("company_id", company_id) \
        .execute()

    rules = response.data or []
    print(f"[검증] 전체 규정 수: {len(rules)}")

    # 3) 카테고리 매칭되는 규정 찾기
    applicable_rule = None
    for rule in rules:
        policy = rule.get("policy_data", {})
        if policy.get("category") == db_category:
            applicable_rule = rule
            break

    print(f"[검증] 적용 규정: {applicable_rule}")

    # 4) 규정 없으면 보류
    if not applicable_rule:
        print("######## NO RULE -> PENDING ########")
        return {"status": "pending", "reason": "해당 카테고리 규정 없음 - 수동 확인 필요"}

    policy     = applicable_rule.get("policy_data", {})
    max_amount = policy.get("max_amount")
    approval_required = policy.get("approval_required", False)

    # 5) 1인당 금액 계산
    per_person = amount / headcount
    print(f"[검증] 총액: {amount:,}원 / {headcount}명 = 1인당 {per_person:,.0f}원 / 한도: {max_amount:,}원")

    # 6) 한도 초과 검사
    if max_amount and per_person > max_amount:
        return {
            "status": "rejected",
            "reason": f"1인당 {per_person:,.0f}원 (한도: {max_amount:,}원, {headcount}명 기준)"
        }

    # 7) 관리자 승인 필요 항목
    if approval_required:
        return {
            "status": "pending",
            "reason": f"관리자 승인 필요 항목: {applicable_rule.get('rule_name')}"
        }

    # 8) 통과
    return {"status": "approved", "reason": None}