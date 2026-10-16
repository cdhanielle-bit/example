# Public uploads setup (Supabase)

The GitHub Pages site is static, so it cannot safely store uploads by itself. This repository now includes `community.html`, a public gallery page that uses Supabase Auth + Storage. No service-role key or secret belongs in browser code.

## 1. Create the Supabase project
1. Create a project at https://supabase.com/ and keep its database password private.
2. In **Project Settings → API** (or **Connect**), copy the **Project URL** and **publishable/anon key**. These are public client configuration values; never use the service-role/secret key in this website.
3. Open `community.html` and replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_PUBLISHABLE_KEY` with those two values.

## 2. Create the storage bucket
In **Storage**, create a bucket named exactly `community-media`.
- Set it to **Public** so other visitors can view uploaded media.
- Set the maximum file size to **25 MB**.
- Restrict allowed MIME types to images, videos, and audio (e.g. image/*, video/*, audio/*).

## 3. Apply database and storage policies
Open **SQL Editor**, paste all contents of `supabase-setup.sql`, and run it. The policies allow anyone to read published gallery entries, but only signed-in users can upload and they can only write inside their own user-ID folder. Users can delete only their own uploads.

## 4. Authentication settings
In **Authentication → URL Configuration**, add these redirect URLs:
- `https://cdhanielle-bit.github.io/example/community.html`
- Your local preview URL if you use one.

For the simplest sign-up experience, configure email confirmation as you prefer. If email confirmation is enabled, users must verify their email before signing in.

## 5. Publish and test
1. Commit/push `community.html`, `supabase-setup.sql`, and this guide to `main`.
2. Wait for GitHub Pages to publish.
3. Open https://cdhanielle-bit.github.io/example/community.html
4. Create an account or sign in, choose a photo/video/audio file, and click **Publish file**. It should appear in the public list for other visitors.

## Notes
- Public means uploaded media can be viewed by anyone with the website link. Do not upload private or sensitive files.
- This starter limits files to image/video/audio and 25 MB in the interface; the bucket limit and MIME restrictions must also be configured in Supabase as above.
- The Supabase publishable/anon key is designed for frontend use when Row Level Security and storage policies are configured. Never expose a service-role key.
- Existing `index.html` creator remains a local-browser gallery. The new community page is the shared, online gallery.
