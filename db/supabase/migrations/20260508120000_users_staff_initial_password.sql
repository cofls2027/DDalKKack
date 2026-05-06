-- 관리자가 직원 초기 비밀번호를 참고할 수 있도록 기록(평문). 앱에서는 이 컬럼을 select 하지 마세요.
alter table public.users
  add column if not exists staff_initial_password text;

comment on column public.users.staff_initial_password is '직원에게 전달한 초기 비밀번호 관리자 참고용. Auth 해시와 별개.';
