-- 1. pgvector 확장 활성화 (Supabase는 기본 제공)
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. 규정 청크 저장 테이블
CREATE TABLE rule_chunks (
  id          bigserial    PRIMARY KEY,
  rule_id     int8         REFERENCES rules(id) ON DELETE CASCADE,
  company_id  int8         NOT NULL,
  chunk_index int4         NOT NULL,
  content     text         NOT NULL,
  embedding   vector(768)  NOT NULL,   -- Gemini text-embedding-004 차원
  created_at  timestamptz  DEFAULT now()
);

-- 3. 벡터 인덱스 (빠른 유사도 검색)
CREATE INDEX rule_chunks_embedding_idx
  ON rule_chunks
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);

-- 4. 유사도 검색 함수 (ragService.js에서 supabase.rpc()로 호출)
CREATE OR REPLACE FUNCTION match_rule_chunks(
  query_embedding  vector(768),
  match_company_id int8,
  match_threshold  float  DEFAULT 0.7,
  match_count      int    DEFAULT 5
)
RETURNS TABLE (
  id         bigint,
  content    text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    id,
    content,
    1 - (embedding <<=>> query_embedding) AS similarity
  FROM   rule_chunks
  WHERE  company_id = match_company_id
    AND  1 - (embedding <<=>> query_embedding) > match_threshold
  ORDER BY embedding <<=>> query_embedding
  LIMIT  match_count;
$$;