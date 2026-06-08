create extension if not exists "pgcrypto";

create table if not exists public.app_config (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.vibe_checks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  photo_path text not null,
  stage1_text text not null,
  stage1_confidence numeric,
  tweak_text text,
  style_vector jsonb,
  garments jsonb not null default '[]'::jsonb,
  device jsonb,
  stage1_latency_ms int,
  stage2_latency_ms int,
  created_at timestamptz not null default now()
);

create table if not exists public.wardrobe_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source_vibe_check_id uuid references public.vibe_checks(id) on delete cascade,
  source_photo_path text,
  category text,
  type text,
  color text,
  confidence numeric,
  attributes jsonb not null default '{}'::jsonb,
  status text not null default 'active',
  created_at timestamptz not null default now()
);

create table if not exists public.daily_usage (
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  vibe_check_count int not null default 0,
  last_vibe_check_at timestamptz,
  primary key (user_id, date)
);

create index if not exists vibe_checks_user_created_idx
  on public.vibe_checks (user_id, created_at desc);

create index if not exists wardrobe_items_user_created_idx
  on public.wardrobe_items (user_id, created_at desc);

create index if not exists wardrobe_items_source_vibe_check_idx
  on public.wardrobe_items (user_id, source_vibe_check_id);

alter table public.app_config enable row level security;
alter table public.vibe_checks enable row level security;
alter table public.wardrobe_items enable row level security;
alter table public.daily_usage enable row level security;

grant select on public.app_config to authenticated;
grant select, insert, update, delete on public.vibe_checks to authenticated;
grant select, insert, update, delete on public.wardrobe_items to authenticated;
grant select on public.daily_usage to authenticated;

create policy "Users can read app config"
  on public.app_config for select
  to authenticated
  using (true);

create policy "Users read their own vibe checks"
  on public.vibe_checks for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users insert their own vibe checks"
  on public.vibe_checks for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users update their own vibe checks"
  on public.vibe_checks for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users delete their own vibe checks"
  on public.vibe_checks for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users read their own wardrobe items"
  on public.wardrobe_items for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users insert their own wardrobe items"
  on public.wardrobe_items for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users update their own wardrobe items"
  on public.wardrobe_items for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users delete their own wardrobe items"
  on public.wardrobe_items for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users read their own daily usage"
  on public.daily_usage for select
  to authenticated
  using ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('outfit-photos', 'outfit-photos', false, 5242880, array['image/jpeg'])
on conflict (id) do update
set public = false,
    file_size_limit = 5242880,
    allowed_mime_types = array['image/jpeg'];

create policy "Users read their own outfit photos"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'outfit-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "Users upload their own outfit photos"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'outfit-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "Users update their own outfit photos"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'outfit-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'outfit-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "Users delete their own outfit photos"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'outfit-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create or replace function public.claim_daily_vibe_check(limit_count int)
returns table (allowed boolean, limit_value int, remaining int)
language plpgsql
security definer
set search_path = public
as $$
declare
  current_uid uuid := auth.uid();
  today date := (now() at time zone 'utc')::date;
  next_count int;
  configured_limit int;
  effective_limit int := limit_count;
begin
  if current_uid is null then
    raise exception 'Sign-in required' using errcode = '28000';
  end if;

  select nullif(value #>> '{}', '')::int
  into configured_limit
  from public.app_config
  where key = 'daily_vibe_check_limit';

  effective_limit := least(greatest(coalesce(effective_limit, 1000), 1), coalesce(configured_limit, 1000));

  insert into public.daily_usage (user_id, date, vibe_check_count, last_vibe_check_at)
  values (current_uid, today, 0, now())
  on conflict (user_id, date) do nothing;

  perform 1
  from public.daily_usage
  where user_id = current_uid and date = today
  for update;

  select vibe_check_count
  into next_count
  from public.daily_usage
  where user_id = current_uid and date = today;

  if next_count >= effective_limit then
    allowed := false;
    limit_value := effective_limit;
    remaining := 0;
    return next;
    return;
  end if;

  update public.daily_usage
  set vibe_check_count = vibe_check_count + 1,
      last_vibe_check_at = now()
  where user_id = current_uid and date = today
  returning vibe_check_count into next_count;

  allowed := true;
  limit_value := effective_limit;
  remaining := greatest(0, effective_limit - next_count);
  return next;
end;
$$;

revoke all on function public.claim_daily_vibe_check(int) from public;
revoke all on function public.claim_daily_vibe_check(int) from anon;
grant execute on function public.claim_daily_vibe_check(int) to authenticated;
