-- Enforce one active direct conversation per unordered user pair.
alter table public.conversations add column if not exists direct_pair_key text;
create unique index if not exists active_direct_pair_unique on public.conversations(direct_pair_key) where kind = 'direct' and deleted_at is null;

create or replace function public.create_direct_conversation(other_user uuid)
returns uuid language plpgsql security definer set search_path=public as $$
declare cid uuid; pair text;
begin
  if auth.uid() is null or auth.uid() = other_user then raise exception 'invalid direct member'; end if;
  pair := least(auth.uid()::text, other_user::text) || ':' || greatest(auth.uid()::text, other_user::text);
  select id into cid from conversations where direct_pair_key=pair and deleted_at is null;
  if cid is null then
    insert into conversations(kind, created_by, direct_pair_key) values ('direct',auth.uid(),pair) returning id into cid;
    insert into conversation_members(conversation_id,user_id,role) values (cid,auth.uid(),'owner'),(cid,other_user,'member');
  end if;
  return cid;
end $$;

create or replace function public.create_group_conversation(group_title text, group_description text default '')
returns uuid language plpgsql security definer set search_path=public as $$
declare cid uuid; begin
  if auth.uid() is null or length(trim(group_title))=0 then raise exception 'invalid group'; end if;
  insert into conversations(kind,title,description,created_by) values('group',trim(group_title),group_description,auth.uid()) returning id into cid;
  insert into conversation_members(conversation_id,user_id,role) values(cid,auth.uid(),'owner'); return cid;
end $$;

create or replace function public.is_group_admin(cid uuid) returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from conversation_members where conversation_id=cid and user_id=auth.uid() and role in ('owner','admin') and left_at is null)$$;
create policy "authenticated create groups" on public.conversations for insert to authenticated with check(kind='group' and created_by=auth.uid());
create policy "admins manage group membership" on public.conversation_members for insert to authenticated with check(public.is_group_admin(conversation_id));
create policy "admins update group membership" on public.conversation_members for update to authenticated using(public.is_group_admin(conversation_id));
create policy "members leave groups" on public.conversation_members for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "creator updates groups" on public.conversations for update to authenticated using(created_by=auth.uid() or public.is_group_admin(id));
create policy "sender delete everyone" on public.messages for delete to authenticated using(sender_id=auth.uid() and created_at > now() - interval '48 hours');

create or replace function public.touch_conversation_last_message() returns trigger language plpgsql security definer set search_path=public as $$ begin update conversations set last_message_at=new.created_at where id=new.conversation_id; return new; end $$;
drop trigger if exists messages_touch_conversation on public.messages;
create trigger messages_touch_conversation after insert on public.messages for each row execute function public.touch_conversation_last_message();
create or replace function public.create_profile() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,username,display_name) values(new.id,coalesce(nullif(new.raw_user_meta_data->>'username',''),'user_'||substring(new.id::text,1,8)),coalesce(nullif(new.raw_user_meta_data->>'display_name',''),'New user')); return new; end $$;
drop trigger if exists auth_user_profile on auth.users;
create trigger auth_user_profile after insert on auth.users for each row execute function public.create_profile();
