begin;

create extension if not exists pgtap with schema extensions;

select plan(6);

insert into auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
values
  ('00000000-0000-0000-0000-0000000000a1', 'authenticated', 'authenticated', 'alice@example.test', '', now(), now(), now()),
  ('00000000-0000-0000-0000-0000000000b2', 'authenticated', 'authenticated', 'bob@example.test', '', now(), now(), now())
on conflict (id) do nothing;

set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000a1';
set local request.jwt.claim.role = 'authenticated';

select lives_ok(
  $$insert into public.vibe_checks (user_id, photo_path, stage1_text)
    values ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000a1/photos/a.jpg', 'x')$$,
  'user can insert own vibe check'
);

select throws_ok(
  $$insert into public.vibe_checks (user_id, photo_path, stage1_text)
    values ('00000000-0000-0000-0000-0000000000b2', '00000000-0000-0000-0000-0000000000b2/photos/b.jpg', 'x')$$,
  '42501',
  null,
  'user cannot insert another user vibe check'
);

select is(
  (select count(*)::int from public.vibe_checks),
  1,
  'user only reads own vibe checks'
);

select ok(
  (select allowed from public.claim_daily_vibe_check(2) limit 1),
  'first rate-limit claim is allowed'
);

select ok(
  (select allowed from public.claim_daily_vibe_check(2) limit 1),
  'second rate-limit claim is allowed'
);

select is(
  (select allowed from public.claim_daily_vibe_check(2) limit 1),
  false,
  'third rate-limit claim is rejected'
);

select * from finish();

rollback;
