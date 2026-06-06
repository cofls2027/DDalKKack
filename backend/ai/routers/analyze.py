from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from services.gemini_service import analyze_receipt
from services.validate import validate_receipt
from services.rag_service import embed_and_store_rules
from pydantic import BaseModel
import tempfile, os

router = APIRouter()

@router.post("/analyze")
async def analyze(
    image:      UploadFile = File(...),
    card_type:  str        = Form("회사카드"),
    company_id: int        = Form(...),
    position:   str        = Form(None),
    headcount:  int        = Form(1),
):
    suffix = os.path.splitext(image.filename)[1] or ".jpg"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(await image.read())
        tmp_path = tmp.name
    try:
        ocr_data = await analyze_receipt(tmp_path)
        result   = await validate_receipt(ocr_data, card_type, company_id, position, headcount)
        return {
            "ocr":      ocr_data,
            "merchant": ocr_data.get("merchant"),
            "amount":   ocr_data.get("amount"),
            "date":     ocr_data.get("date"),
            "time":     ocr_data.get("time"),      # ← 추가
            "category": ocr_data.get("category"),
            "cardType": card_type,                 # ← 추가
            "warnings": result.get("reason"),      # ← reason → warnings
            "status":   result["status"],
            "reason":   result["reason"],
        }
    finally:
        os.unlink(tmp_path)

@router.post("/batch")
async def batch_analyze(
    images:     list[UploadFile] = File(...),
    card_type:  str              = Form("회사카드"),
    company_id: int              = Form(...),
    position:   str              = Form(None),
    headcount:  int              = Form(1),
):
    if len(images) > 10:
        raise HTTPException(status_code=400, detail="최대 10장까지 가능합니다")

    results = []
    for image in images:
        suffix = os.path.splitext(image.filename)[1] or ".jpg"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            tmp.write(await image.read())
            tmp_path = tmp.name
        try:
            ocr_data = await analyze_receipt(tmp_path)
            result   = await validate_receipt(ocr_data, card_type, company_id, position, headcount)
            results.append({
                "filename": image.filename, "success": True,
                "merchant": ocr_data.get("merchant"),
                "amount":   ocr_data.get("amount"),
                "date":     ocr_data.get("date"),
                "time":     ocr_data.get("time"),      # ← 추가
                "category": ocr_data.get("category"),
                "cardType": card_type,                 # ← 추가
                "warnings": result.get("reason"),      # ← 추가
                "status":   result["status"],
                "reason":   result["reason"],
                "ocr":      ocr_data,
            })
        except Exception as e:
            results.append({"filename": image.filename, "success": False, "error": str(e)})
        finally:
            try:
                os.unlink(tmp_path)
            except Exception:
                pass

    succeeded = sum(1 for r in results if r["success"])
    return {"total": len(images), "succeeded": succeeded, "results": results}

class RuleEmbedRequest(BaseModel):
    rule_text:  str
    rule_id:    int
    company_id: int

@router.post("/embed-rules")
async def embed_rules(body: RuleEmbedRequest):
    await embed_and_store_rules(body.rule_text, body.rule_id, body.company_id)
    return {"message": "규정 임베딩 완료"}