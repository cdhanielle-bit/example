-- Run this in Supabase Dashboard > SQL Editor.
-- First create a PUBLIC Storage bucket named: community-media
-- Set its file size limit to 25 MB and allowed MIME types to image/*, video/*, audio/*.

create table if not exists public.gallery_uploads (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null references auth.users(id) on delete cascade,
  object_path text not null unique,
  original_name text not null,
  media_type text not null check (media_type in ('image', 'video', 'audio')),
  created_at timestamptz not null default now()
);

alter table public.gallery_uploads enable row level security;

grant select on public.gallery_uploads to anon, authenticated;
grant insert, delete on public.gallery_uploads to authenticated;

drop policy if exists "Anyone can view published gallery entries" on public.gallery_uploads;
create policy "Anyone can view published gallery entries"
on public.gallery_uploads for select
to anon, authenticated
using (true);

drop policy if exists "Signed-in users can publish their own entries" on public.gallery_uploads;
create policy "Signed-in users can publish their own entries"
on public.gallery_uploads for insert
to authenticated
with check (auth.uid() = owner);

drop policy if exists "Owners can delete their own entries" on public.gallery_uploads;
create policy "Owners can delete their own entries"
on public.gallery_uploads for delete
to authenticated
using (auth.uid() = owner);

-- Storage policies: signed-in users can only upload to their own user-ID folder.
drop policy if exists "Public can view community media" on storage.objects;
create policy "Public can view community media"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'community-media');

drop policy if exists "Users upload into their own folder" on storage.objects;
create policy "Users upload into their own folder"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'community-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users delete files in their own folder" on storage.objects;
create policy "Users delete files in their own folder"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'community-media'
  and (storage.foldername(name))[1] = auth.uid()::text
);
