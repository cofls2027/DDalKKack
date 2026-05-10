# 4) 카테고리 매칭되는 규정 찾기
applicable_rule = None
for rule in rules:
    policy = rule.get("policy_data", {})
    if policy.get("category") == db_category:
        applicable_rule = rule
        break

# 5) 규정 없으면 보류
if not applicable_rule:
    return {"status": "pending", "reason": "해당 카테고리 규정 없음 - 수동 확인 필요"}

policy            = applicable_rule.get("policy_data", {})
max_amount        = policy.get("max_amount")
approval_required = policy.get("approval_required", False)
allowed_time_from = policy.get("allowed_time_from")

# 6) 시간 검증
receipt_time = ocr_data.get("time")
if receipt_time and allowed_time_from:
    if receipt_time < allowed_time_from:
        return {
            "status": "rejected",
            "reason": f"{allowed_time_from} 이후만 허용 (영수증 시간: {receipt_time})"
        }

# 7) 1인당 금액 계산
per_person = amount / headcount
print(f"[검증] 총액: {amount:,}원 / {headcount}명 = 1인당 {per_person:,.0f}원 / 한도: {max_amount:,}원")

# 8) 한도 초과 검사
if max_amount and per_person > max_amount:
    return {
        "status": "rejected",
        "reason": f"1인당 {per_person:,.0f}원 (한도: {max_amount:,}원, {headcount}명 기준)"
    }

# 9) 관리자 승인 필요 항목
if approval_required:
    return {
        "status": "pending",
        "reason": f"관리자 승인 필요 항목: {applicable_rule.get('rule_name')}"
    }

# 10) 통과
return {"status": "approved", "reason": None}