import google.generativeai as genai
import os, json, re
from PIL import Image

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel("gemini-1.5-flash")

async def analyze_receipt(image_path: str) -> dict:
    """영수증 이미지 → OCR 데이터 추출"""
    image = Image.open(image_path)

    prompt = """
아래 영수증 이미지를 분석해서 반드시 JSON 형식으로만 응답해.
다른 텍스트는 절대 포함하지 마.

{
  "merchant": "가맹점명",
  "amount": 숫자만(원화),
  "date": "YYYY-MM-DD",
  "category": "식비|교통|숙박|기타",
  "items": ["품목1", "품목2"],
  "rawText": "OCR로 읽은 전체 텍스트"
}
"""

    response = model.generate_content([image, prompt])
    text = response.text

    # ```json 블록 제거
    cleaned = re.sub(r'```json\n?|```\n?', '', text).strip()

    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        return {
            "merchant": "인식 실패",
            "amount":   0,
            "date":     "",
            "category": "기타",
            "items":    [],
            "rawText":  text,
        }