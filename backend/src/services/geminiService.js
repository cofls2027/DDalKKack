import { GoogleGenerativeAI } from '@google/generative-ai';
import fs from 'fs';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

export async function analyzeReceipt(imagePath) {
  const base64Image = fs.readFileSync(imagePath).toString('base64');
  const prompt = `영수증을 분석해서 반드시 JSON만 반환해. 다른 텍스트 금지.
{"merchant":"","amount":0,"date":"YYYY-MM-DD","category":"식비|교통|숙박|기타","items":[],"rawText":""}`;

  const result = await model.generateContent([
    { inlineData: { mimeType: 'image/jpeg', data: base64Image } },
    prompt,
  ]);

  const cleaned = result.response.text()
    .replace(/```json\n?|```\n?/g, '').trim();
  return JSON.parse(cleaned);
}