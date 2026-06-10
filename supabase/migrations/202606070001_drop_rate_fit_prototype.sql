-- Tear down the rate-fit prototype schema that lives on the repurposed Supabase
-- project, so the Combin cutover migration starts from a clean slate. Every
-- statement is idempotent: on a fresh local `supabase db reset` this is a no-op.

drop table if exists public.garment_suggestions cascade;
drop table if exists public.user_ai_feedback cascade;
drop table if exists public.social_events cascade;
drop table if exists public.embedding_jobs cascade;
drop table if exists public.outfit_embeddings cascade;
drop table if exists public.user_profile_aggregates cascade;
drop table if exists public.outfit_item_colors cascade;
drop table if exists public.outfit_items cascade;
drop table if exists public.outfit_palette cascade;
drop table if exists public.outfit_analysis cascade;
drop table if exists public.outfit_metadata cascade;
drop table if exists public.reviews cascade;
drop table if exists public.outfits cascade;
drop table if exists public.user_data_consents cascade;
drop table if exists public.profiles cascade;

-- The prototype's auth hook (if present) would break anonymous sign-in once
-- profiles is gone.
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user() cascade;

-- Remove the prototype's storage policies so the Combin cutover migration can
-- define the complete, intended set for outfit-photos.
do $$
declare
  pol record;
begin
  for pol in
    select policyname from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
  loop
    execute format('drop policy if exists %I on storage.objects', pol.policyname);
  end loop;
end
$$;
