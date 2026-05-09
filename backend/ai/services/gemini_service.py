import json, re, os
from google import genai
from google.genai import types
from PIL import Image
from config import GEMINI_API_KEY

client = genai.Client(api_key=GEMINI_API_KEY)
MODEL  = "gemini-2.5-flash"

async def analyze_receipt(image_path: str) -> dict:
    """영수증 이미지 → OCR 데이터 추출"""
    image = Image.open(image_path)

    prompt = """
영수증 이미지를 분석해서 반드시 JSON만 반환해. 다른 텍스트 금지.
{
  "merchant": "가맹점명",
  "amount": 숫자만(원화),
  "date": "YYYY-MM-DD",
  "category": "식비|교통|숙박|기타",
  "items": ["품목1", "품목2"],
  "rawText": "OCR로 읽은 전체 텍스트"
}
"""

    response = client.models.generate_content(
        model=MODEL,
        contents=[image, prompt],
    )
    cleaned = re.sub(r'```json\n?|```\n?', '', response.text).strip()
    print(f"Gemini OCR 응답: {cleaned[:200]}")

    try:
        return json.loads(cleaned)
    except:
        return {
            "merchant": "인식 실패", "amount": 0,
            "date": "", "category": "기타",
            "items": [], "rawText": response.text,
        }