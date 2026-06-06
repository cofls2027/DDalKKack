-- 관리자가 직원의 현재 로그인 비밀번호를 확인·설정할 수 있도록 기록(평문).
alter table public.users
  add column if not exists staff_current_password text;

comment on column public.users.staff_current_password is '관리자 참고용 현재 로그인 비밀번호. Auth 비밀번호 변경 시 함께 갱신.';

update public.users
set staff_current_password = staff_initial_password
where staff_current_password is null
  and staff_initial_password is not null;
