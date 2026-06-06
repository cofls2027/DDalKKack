const express = require("express");
const { createClient } = require("@supabase/supabase-js");

const router = express.Router();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabaseAuth = createClient(supabaseUrl, supabaseAnonKey);
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);

router.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body || {};

        if (!email || !password) {
            return res.status(400).json({
                error: "이메일과 비밀번호를 입력하세요.",
            });
        }

        const { data: authData, error: authError } = await supabaseAuth.auth
            .signInWithPassword({
                email,
                password,
            });

        if (authError || !authData?.user || !authData?.session) {
            return res.status(401).json({
                error: "이메일 또는 비밀번호가 올바르지 않습니다.",
            });
        }

        const authUserId = authData.user.id;

        const { data: profile, error: profileError } = await supabaseAdmin
            .from("users")
            .select("id, name, phone, position, role, company_id, is_active")
            .eq("id", authUserId)
            .maybeSingle();

        if (profileError) {
            console.error(profileError);
            return res.status(500).json({
                error: "사용자 정보 조회 중 오류가 발생했습니다.",
            });
        }

        if (!profile) {
            return res.status(403).json({
                error: "등록된 사용자 정보가 없습니다.",
            });
        }

        if (profile.is_active !== true) {
            return res.status(403).json({
                error: "비활성화된 계정입니다.",
            });
        }

        return res.json({
            accessToken: authData.session.access_token,
            refreshToken: authData.session.refresh_token,
            profile,
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({
            error: "로그인 처리 중 오류가 발생했습니다.",
        });
    }
});

module.exports = router;
