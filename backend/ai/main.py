from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import analyze
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="DDalKKack AI Server", version="1.0.0")

# Node.js(3000)에서 오는 요청 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(analyze.router, prefix="/ai")

@app.get("/health")
def health():
    return {"status": "ok", "server": "FastAPI"}