import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

// 앱 전체에서 하나의 클라이언트만 사용 (싱글턴)
export const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY  // 서버는 service key 사용
);