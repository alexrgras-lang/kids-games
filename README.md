# Kids games

Two small browser games, no build step, no accounts. Progress saves in the browser.

- `/` Sparkle Boutique: adaptive 2nd-grade math (coins, add/subtract, patterns, charts)
- `/words/` Word Quest: weekly spelling list + pre-K sight words; Camila also gets Rescue Math (adaptive, starts at 2nd grade)

Word Quest progress syncs across computers through Supabase project `kids-games` (mvvjoaluidddzjifxkai). Turn it on in the grown-ups panel; the family code rides in the link as `?sync=CODE`. Schema: `words/sync-setup.sql`.
