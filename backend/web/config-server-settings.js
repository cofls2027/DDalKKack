const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '..', '.env') });

const PORT = Number(process.env.PORT || 3000);
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_PUBLISHABLE_KEY = process.env.SUPABASE_PUBLISHABLE_KEY;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

function assertServerSettings(){
  if(!SUPABASE_URL || !SUPABASE_PUBLISHABLE_KEY || !SUPABASE_SERVICE_ROLE_KEY){
    console.error('Missing Supabase environment variables. Copy .env.example to .env and fill the keys.');
    process.exit(1);
  }
}

module.exports = {
  PORT,
  SUPABASE_URL,
  SUPABASE_PUBLISHABLE_KEY,
  SUPABASE_SERVICE_ROLE_KEY,
  assertServerSettings
};
