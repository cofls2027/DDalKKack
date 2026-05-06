-- Connect Supabase Auth users to app profiles and lock data behind RLS.
-- This migration expects app user ids to be auth.users.id UUIDs.

alter table if exists public.users
  add column if not exists email text,
  add column if not exists is_active boolean not null default true;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'users'
      and column_name = 'id'
      and data_type <> 'uuid'
  ) then
    alter table public.users drop constraint if exists users_pkey;
    alter table public.users alter column id drop identity if exists;
    alter table public.users alter column id drop default;
    update public.receipts set user_id = null;
    update public.trips set user_id = null;
    delete from public.users;
    alter table public.users alter column id type uuid using null;
    alter table public.users alter column id set not null;
    alter table public.users add constraint users_pkey primary key (id);
  end if;
end $$;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'receipts'
      and column_name = 'user_id'
      and data_type <> 'uuid'
  ) then
    alter table public.receipts alter column user_id type uuid using null;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'trips'
      and column_name = 'user_id'
      and data_type <> 'uuid'
  ) then
    alter table public.trips alter column user_id type uuid using null;
  end if;
end $$;

alter table if exists public.cards
  add column if not exists user_id uuid,
  add column if not exists card_description text;

update public.users
set role = 'employee'
where role is null;

alter table public.users
  alter column role set default 'employee',
  alter column role set not null;

create unique index if not exists users_email_key
  on public.users (email)
  where email is not null;

alter table public.users
  drop constraint if exists users_id_fkey,
  add constraint users_id_fkey foreign key (id) references auth.users(id) on delete cascade not valid;

alter table public.receipts
  drop constraint if exists receipts_user_id_fkey,
  add constraint receipts_user_id_fkey foreign key (user_id) references public.users(id) on delete set null not valid;

alter table public.trips
  drop constraint if exists trips_user_id_fkey,
  add constraint trips_user_id_fkey foreign key (user_id) references public.users(id) on delete set null not valid;

alter table public.cards
  drop constraint if exists cards_user_id_fkey,
  add constraint cards_user_id_fkey foreign key (user_id) references public.users(id) on delete set null not valid;

alter table public.users enable row level security;
alter table public.receipts enable row level security;
alter table public.trips enable row level security;
alter table public.cards enable row level security;
alter table public.companies enable row level security;
alter table public.rules enable row level security;

create or replace function public.is_active_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.users
    where id = auth.uid()
      and role = 'admin'
      and is_active = true
  );
$$;

create or replace function public.current_company_id()
returns bigint
language sql
stable
security definer
set search_path = public
as $$
  select company_id
  from public.users
  where id = auth.uid()
    and is_active = true
  limit 1;
$$;

drop policy if exists "active users can read own profile" on public.users;
drop policy if exists "admins can read company users" on public.users;
drop policy if exists "admins can manage company users" on public.users;

create policy "active users can read own profile"
  on public.users
  for select
  to authenticated
  using (id = auth.uid() and is_active = true);

create policy "admins can read company users"
  on public.users
  for select
  to authenticated
  using (
    public.is_active_admin()
    and company_id = public.current_company_id()
  );

create policy "admins can manage company users"
  on public.users
  for all
  to authenticated
  using (
    public.is_active_admin()
    and company_id = public.current_company_id()
  )
  with check (
    public.is_active_admin()
    and company_id = public.current_company_id()
  );

drop policy if exists "active users can manage own receipts" on public.receipts;
drop policy if exists "admins can manage company receipts" on public.receipts;

create policy "active users can manage own receipts"
  on public.receipts
  for all
  to authenticated
  using (
    user_id = auth.uid()
    and exists (
      select 1 from public.users
      where id = auth.uid() and is_active = true
    )
  )
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.users
      where id = auth.uid() and is_active = true
    )
  );

create policy "admins can manage company receipts"
  on public.receipts
  for all
  to authenticated
  using (
    public.is_active_admin()
    and company_id = public.current_company_id()
  )
  with check (
    public.is_active_admin()
    and company_id = public.current_company_id()
  );

drop policy if exists "active users can manage own trips" on public.trips;
drop policy if exists "admins can manage company trips" on public.trips;

create policy "active users can manage own trips"
  on public.trips
  for all
  to authenticated
  using (
    user_id = auth.uid()
    and exists (
      select 1 from public.users
      where id = auth.uid() and is_active = true
    )
  )
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.users
      where id = auth.uid() and is_active = true
    )
  );

create policy "admins can manage company trips"
  on public.trips
  for all
  to authenticated
  using (
    public.is_active_admin()
    and company_id = public.current_company_id()
  )
  with check (
    public.is_active_admin()
    and company_id = public.current_company_id()
  );

drop policy if exists "active users can read cards" on public.cards;
drop policy if exists "admins can manage company cards" on public.cards;

create policy "active users can read cards"
  on public.cards
  for select
  to authenticated
  using (
    is_active = true
    and company_id = public.current_company_id()
  );

create policy "admins can manage company cards"
  on public.cards
  for all
  to authenticated
  using (
    public.is_active_admin()
    and company_id = public.current_company_id()
  )
  with check (
    public.is_active_admin()
    and company_id = public.current_company_id()
  );

drop policy if exists "active users can read own company" on public.companies;
drop policy if exists "admins can manage own company" on public.companies;

create policy "active users can read own company"
  on public.companies
  for select
  to authenticated
  using (id = public.current_company_id());

create policy "admins can manage own company"
  on public.companies
  for all
  to authenticated
  using (
    public.is_active_admin()
    and id = public.current_company_id()
  )
  with check (
    public.is_active_admin()
    and id = public.current_company_id()
  );

drop policy if exists "active users can read rules" on public.rules;
drop policy if exists "admins can manage rules" on public.rules;

create policy "active users can read rules"
  on public.rules
  for select
  to authenticated
  using (public.current_company_id() is not null);

create policy "admins can manage rules"
  on public.rules
  for all
  to authenticated
  using (public.is_active_admin())
  with check (public.is_active_admin());
