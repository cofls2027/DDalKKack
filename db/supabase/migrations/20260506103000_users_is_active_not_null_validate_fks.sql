-- Enforce is_active semantics and validate deferred FKs (safe when no orphan rows).

alter table public.users
  alter column is_active set default true;

update public.users
set is_active = coalesce(is_active, true)
where is_active is null;

alter table public.users
  alter column is_active set not null;

alter table public.users validate constraint users_id_fkey;
alter table public.receipts validate constraint receipts_user_id_fkey;
alter table public.trips validate constraint trips_user_id_fkey;
alter table public.cards validate constraint cards_user_id_fkey;
