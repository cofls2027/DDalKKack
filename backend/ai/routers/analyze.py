from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from services.gemini_service import analyze_receipt
from services.validate import validate_receipt
from services.rag_service import embed_and_store_rules
from pydantic import BaseModel
from typing import Optional
import tempfile, os

router = APIRouter()

# ── 단건 분석 ──────────────────────────────────────────
@router.post("/analyze")
async def analyze(
    image: UploadFile = File(...),
    card_type: str    = Form("회사카드"),
    company_id: int   = Form(...),
):
    # 임시 파일로 저장
    suffix = os.path.splitext(image.filename)[1]
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(await image.read())
        tmp_path = tmp.name

    try:
        # 1) Gemini OCR
        ocr_data = await analyze_receipt(tmp_path)

        # 2) RAG 기반 검증 판정
        result = await validate_receipt(ocr_data, card_type, company_id)

        return {
            "ocr":    ocr_data,
            "status": result["status"],
            "reason": result["reason"],
        }
    finally:
        os.unlink(tmp_path)  # 임시 파일 삭제


# ── 배치 분석 ──────────────────────────────────────────
@router.post("/batch")
async def batch_analyze(
    images: list[UploadFile] = File(...),
    card_type: str           = Form("회사카드"),
    company_id: int          = Form(...),
):
    if len(images) > 10:
        raise HTTPException(status_code=400, detail="최대 10장까지 가능합니다")

    results = []
    for image in images:
        suffix = os.path.splitext(image.filename)[1]
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            tmp.write(await image.read())
            tmp_path = tmp.name
        try:
            ocr_data = await analyze_receipt(tmp_path)
            result   = await validate_receipt(ocr_data, card_type, company_id)
            results.append({
                "filename": image.filename,
                "success":  True,
                "ocr":      ocr_data,
                "status":   result["status"],
                "reason":   result["reason"],
            })
        except Exception as e:
            results.append({"filename": image.filename, "success": False, "error": str(e)})
        finally:
            os.unlink(tmp_path)

    succeeded = sum(1 for r in results if r["success"])
    return {"total": len(images), "succeeded": succeeded, "results": results}


# ── 규정 문서 임베딩 저장 (관리자용) ────────────────────
class RuleEmbedRequest(BaseModel):
    rule_text:  str
    rule_id:    int
    company_id: int

@router.post("/embed-rules")
async def embed_rules(body: RuleEmbedRequest):
    await embed_and_store_rules(body.rule_text, body.rule_id, body.company_id)
    return {"message": "규정 임베딩 완료"}