-- Word Quest cloud sync. Paste into the SQL editor of the new project and Run.
-- Saves are only reachable through the two functions below, and only with the family sync code.
create table if not exists public.game_saves (
  code       text   not null,
  kid        text   not null,
  data       jsonb  not null,
  saved_at   bigint not null default 0,
  updated_at timestamptz not null default now(),
  primary key (code, kid)
);
alter table public.game_saves enable row level security;  -- no policies: the table itself is closed to the public API
revoke all on public.game_saves from anon, authenticated;

create or replace function public.get_saves(p_code text)
returns table (kid text, data jsonb)
language sql security definer set search_path = public as $$
  select kid, data from public.game_saves where code = p_code and length(p_code) >= 10;
$$;

create or replace function public.put_save(p_code text, p_kid text, p_data jsonb)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if length(p_code) < 10 or length(p_code) > 40 or length(p_kid) > 20 or pg_column_size(p_data) > 200000 then
    raise exception 'bad request';
  end if;
  insert into public.game_saves (code, kid, data, saved_at)
  values (p_code, p_kid, p_data, coalesce((p_data->>'savedAt')::bigint, 0))
  on conflict (code, kid) do update
    set data = excluded.data, saved_at = excluded.saved_at, updated_at = now()
    where public.game_saves.saved_at <= excluded.saved_at;  -- an older device can't overwrite newer progress
end;
$$;

revoke all on function public.get_saves(text) from public;
revoke all on function public.put_save(text, text, jsonb) from public;
grant execute on function public.get_saves(text) to anon;
grant execute on function public.put_save(text, text, jsonb) to anon;

select 'ok' as setup;
