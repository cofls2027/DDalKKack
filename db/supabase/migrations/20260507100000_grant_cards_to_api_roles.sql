-- public.cards was missing API role grants; RLS still enforces row access.
grant delete, insert, select, update on table public.cards to anon;
grant delete, insert, select, update on table public.cards to authenticated;
grant all on table public.cards to service_role;
