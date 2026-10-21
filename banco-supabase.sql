-- Relatório de Supervisão: banco de dados no Supabase
-- Rode este arquivo inteiro uma vez no SQL Editor do Supabase.
-- Segurança: o código de acesso NÃO fica neste arquivo (veja iniciar_app no final).

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------- tabelas
-- Documentos do app (saídas, configuração, fotos, avaliações, acessos, perfil de cada pessoa).
create table if not exists public.docs (
  collection text not null,
  id text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid,
  primary key (collection, id)
);
create index if not exists docs_col_upd on public.docs (collection, updated_at desc);

-- Quem tem acesso e com qual papel (gerente, supervisor ou vendedor).
create table if not exists public.perfis (
  user_id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  papel text not null check (papel in ('gerente', 'supervisor', 'vendedor')),
  nome text not null default '',
  franquia text not null default '',
  ativo boolean not null default true,
  criado_em timestamptz not null default now()
);
create unique index if not exists perfis_email on public.perfis (lower(email));

-- E-mails liberados pelo gerente para o primeiro acesso.
create table if not exists public.convites (
  email text primary key,
  papel text not null check (papel in ('gerente', 'supervisor', 'vendedor')),
  nome text not null default '',
  franquia text not null default '',
  criado_em timestamptz not null default now(),
  usado_em timestamptz
);

-- Código de acesso (só o hash), tentativas e senhas de uso único do primeiro acesso.
create table if not exists public.app_segredo (chave text primary key, valor text not null);
create table if not exists public.tentativas (
  id bigserial primary key,
  em timestamptz not null default now(),
  email text,
  ip text,
  ok boolean not null
);
create table if not exists public.tickets (
  token_hash text primary key,
  email text not null,
  expira timestamptz not null,
  usado boolean not null default false
);

alter table public.docs enable row level security;
alter table public.perfis enable row level security;
alter table public.convites enable row level security;
alter table public.app_segredo enable row level security;
alter table public.tentativas enable row level security;
alter table public.tickets enable row level security;

revoke all on public.docs, public.perfis, public.convites, public.app_segredo, public.tentativas, public.tickets from anon, authenticated;
revoke all on sequence public.tentativas_id_seq from anon, authenticated;

-- ---------------------------------------------------------------- papel de quem está logado
create or replace function public.papel_atual()
returns text language sql stable security definer set search_path = public as $$
  select papel from public.perfis where user_id = auth.uid() and ativo
$$;
revoke all on function public.papel_atual() from public, anon;
grant execute on function public.papel_atual() to authenticated;

-- ---------------------------------------------------------------- leitura (RLS)
grant select on public.docs, public.perfis to authenticated;

drop policy if exists docs_ler on public.docs;
create policy docs_ler on public.docs for select to authenticated using (
  (select public.papel_atual()) is not null and (
    collection in ('saidas', 'config', 'fotos', 'avalSup')
    or (collection = 'acessos' and (select public.papel_atual()) in ('gerente', 'supervisor'))
    or collection = 'data/users/' || (select auth.uid())::text
  )
);

drop policy if exists perfis_ler on public.perfis;
create policy perfis_ler on public.perfis for select to authenticated using (
  user_id = (select auth.uid()) or (select public.papel_atual()) = 'gerente'
);

-- ---------------------------------------------------------------- gravação controlada
-- Toda gravação passa por aqui. O vendedor só consegue atualizar tarefas e prospecções:
-- vendas, visitas, pedidos, aberturas, horas e avaliações não mudam por ele.
create or replace function public.doc_salvar(p_col text, p_id text, p_data jsonb)
returns void language plpgsql security definer set search_path = public as $$
declare
  v_papel text := public.papel_atual();
  v_nome text;
  v_old jsonb;
  v_existe boolean;
  v_pad constant jsonb := '{"valor":0,"visitas":0,"pedidos":0,"aberturas":0,"horas":0,"meta":0,"vendedores":[],"avaliacoes":[],"supervisor":"","franquia":"","data":"","periodo":""}';
  k text;
begin
  if v_papel is null then raise exception 'permission-denied' using errcode = '42501'; end if;
  if p_col is null or p_id is null or p_data is null or jsonb_typeof(p_data) <> 'object' then
    raise exception 'documento invalido' using errcode = '22023';
  end if;
  if octet_length(p_data::text) > 1500000 then raise exception 'documento grande demais' using errcode = '22023'; end if;
  select data into v_old from public.docs where collection = p_col and id = p_id;
  v_existe := found;

  if p_col = 'saidas' then
    if v_papel = 'vendedor' then
      if not v_existe then raise exception 'permission-denied' using errcode = '42501'; end if;
      foreach k in array array['valor','visitas','pedidos','aberturas','horas','meta','vendedores','avaliacoes','supervisor','franquia','data','periodo'] loop
        if coalesce(p_data -> k, v_pad -> k) is distinct from coalesce(v_old -> k, v_pad -> k) then
          raise exception 'permission-denied' using errcode = '42501';
        end if;
      end loop;
    end if;
  elsif p_col = 'config' then
    if v_papel = 'vendedor' then raise exception 'permission-denied' using errcode = '42501'; end if;
  elsif p_col in ('fotos', 'avalSup') then
    if v_papel = 'vendedor' and v_existe then raise exception 'permission-denied' using errcode = '42501'; end if;
  elsif p_col = 'acessos' then
    if v_papel = 'vendedor' then
      select nome into v_nome from public.perfis where user_id = auth.uid();
      if p_data ->> 'vendedor' is distinct from v_nome then raise exception 'permission-denied' using errcode = '42501'; end if;
    end if;
  else
    raise exception 'permission-denied' using errcode = '42501';
  end if;

  insert into public.docs (collection, id, data, updated_at, updated_by)
  values (p_col, p_id, p_data, now(), auth.uid())
  on conflict (collection, id) do update
    set data = excluded.data, updated_at = now(), updated_by = auth.uid();
end $$;
revoke all on function public.doc_salvar(text, text, jsonb) from public, anon;
grant execute on function public.doc_salvar(text, text, jsonb) to authenticated;

create or replace function public.doc_excluir(p_col text, p_id text)
returns void language plpgsql security definer set search_path = public as $$
declare v_papel text := public.papel_atual();
begin
  if v_papel is null then raise exception 'permission-denied' using errcode = '42501'; end if;
  if p_col = 'saidas' and v_papel in ('gerente', 'supervisor') then
    delete from public.docs where collection = p_col and id = p_id;
  elsif p_col in ('fotos', 'avalSup', 'acessos') and v_papel = 'gerente' then
    delete from public.docs where collection = p_col and id = p_id;
  else
    raise exception 'permission-denied' using errcode = '42501';
  end if;
end $$;
revoke all on function public.doc_excluir(text, text) from public, anon;
grant execute on function public.doc_excluir(text, text) to authenticated;

-- ---------------------------------------------------------------- primeiro acesso
-- Passo 1: a pessoa informa e-mail e código de acesso. Se estiver tudo certo, recebe uma
-- senha de uso único (ticket) que vale 10 minutos. Sem ticket não é possível criar conta.
create or replace function public.checar_primeiro_acesso(p_email text, p_codigo text)
returns jsonb language plpgsql security definer set search_path = public, extensions as $$
declare
  v_email text := lower(trim(coalesce(p_email, '')));
  v_hdr text := nullif(current_setting('request.headers', true), '');
  v_ip text := 'desconhecido';
  v_hash text;
  v_falhas int;
  v_token text;
begin
  if v_hdr is not null then
    v_ip := coalesce(nullif(split_part(coalesce((v_hdr::jsonb) ->> 'x-forwarded-for', ''), ',', 1), ''), 'desconhecido');
  end if;
  delete from public.tentativas where em < now() - interval '2 days';
  delete from public.tickets where expira < now() - interval '1 day';

  select count(*) into v_falhas from public.tentativas
   where em > now() - interval '30 minutes' and not ok and (email = v_email or ip = v_ip);
  if v_falhas >= 6 then return jsonb_build_object('ok', false, 'motivo', 'bloqueado'); end if;

  select valor into v_hash from public.app_segredo where chave = 'codigo_acesso';
  if v_hash is null or crypt(coalesce(p_codigo, ''), v_hash) <> v_hash then
    insert into public.tentativas (email, ip, ok) values (v_email, v_ip, false);
    return jsonb_build_object('ok', false, 'motivo', 'codigo');
  end if;

  if exists (select 1 from public.perfis where lower(email) = v_email) then
    return jsonb_build_object('ok', false, 'motivo', 'ja_cadastrado');
  end if;
  if not exists (select 1 from public.convites where email = v_email) then
    insert into public.tentativas (email, ip, ok) values (v_email, v_ip, false);
    return jsonb_build_object('ok', false, 'motivo', 'sem_convite');
  end if;

  v_token := encode(gen_random_bytes(24), 'hex');
  insert into public.tickets (token_hash, email, expira)
  values (encode(digest(v_token, 'sha256'), 'hex'), v_email, now() + interval '10 minutes');
  insert into public.tentativas (email, ip, ok) values (v_email, v_ip, true);
  return jsonb_build_object('ok', true, 'ticket', v_token);
end $$;
revoke all on function public.checar_primeiro_acesso(text, text) from public;
grant execute on function public.checar_primeiro_acesso(text, text) to anon, authenticated;

-- Passo 2: ao criar a conta, o banco confere o ticket e o convite. Sem eles, a criação é recusada.
create or replace function public.auth_antes_de_criar()
returns trigger language plpgsql security definer set search_path = public, extensions as $$
declare
  v_ticket text := new.raw_user_meta_data ->> 'ticket';
  v_email text := lower(coalesce(new.email, ''));
begin
  if v_ticket is null or v_email = '' then raise exception 'acesso_negado'; end if;
  update public.tickets set usado = true
   where token_hash = encode(digest(v_ticket, 'sha256'), 'hex')
     and email = v_email and not usado and expira > now();
  if not found then raise exception 'acesso_negado'; end if;
  if not exists (select 1 from public.convites where email = v_email) then raise exception 'acesso_negado'; end if;
  return new;
end $$;

create or replace function public.auth_depois_de_criar()
returns trigger language plpgsql security definer set search_path = public as $$
declare c public.convites%rowtype;
begin
  select * into c from public.convites where email = lower(new.email);
  insert into public.perfis (user_id, email, papel, nome, franquia)
  values (new.id, lower(new.email), c.papel, c.nome, c.franquia);
  insert into public.docs (collection, id, data, updated_by)
  values ('data/users/' || new.id::text, 'perfil',
    jsonb_build_object(
      'papel', case c.papel when 'gerente' then 'Gerente' when 'supervisor' then c.nome else 'Vendedor' end,
      'nome', c.nome,
      'vend', case when c.papel = 'vendedor' then jsonb_build_object('name', c.nome, 'franquia', c.franquia) else null end),
    new.id);
  update public.convites set usado_em = now() where email = c.email;
  return new;
end $$;

drop trigger if exists auth_antes_de_criar on auth.users;
create trigger auth_antes_de_criar before insert on auth.users
  for each row execute function public.auth_antes_de_criar();
drop trigger if exists auth_depois_de_criar on auth.users;
create trigger auth_depois_de_criar after insert on auth.users
  for each row execute function public.auth_depois_de_criar();

-- ---------------------------------------------------------------- funções do gerente
create or replace function public.convidar(p_email text, p_papel text, p_nome text, p_franquia text default '')
returns void language plpgsql security definer set search_path = public as $$
declare v_email text := lower(trim(coalesce(p_email, '')));
begin
  if public.papel_atual() is distinct from 'gerente' then raise exception 'permission-denied' using errcode = '42501'; end if;
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'e-mail invalido' using errcode = '22023'; end if;
  if p_papel not in ('gerente', 'supervisor', 'vendedor') then raise exception 'papel invalido' using errcode = '22023'; end if;
  if p_papel <> 'gerente' and coalesce(trim(p_nome), '') = '' then raise exception 'informe o nome' using errcode = '22023'; end if;
  if p_papel = 'vendedor' and coalesce(trim(p_franquia), '') = '' then raise exception 'informe a franquia' using errcode = '22023'; end if;
  if exists (select 1 from public.perfis where lower(email) = v_email) then raise exception 'ja_cadastrado' using errcode = '23505'; end if;
  insert into public.convites (email, papel, nome, franquia)
  values (v_email, p_papel, coalesce(trim(p_nome), ''), coalesce(trim(p_franquia), ''))
  on conflict (email) do update set papel = excluded.papel, nome = excluded.nome, franquia = excluded.franquia, usado_em = null;
end $$;

create or replace function public.listar_acessos()
returns table (email text, papel text, nome text, franquia text, status text, ativo boolean, criado_em timestamptz)
language plpgsql security definer set search_path = public as $$
begin
  if public.papel_atual() is distinct from 'gerente' then raise exception 'permission-denied' using errcode = '42501'; end if;
  return query
    select c.email, c.papel, c.nome, c.franquia,
           case when p.user_id is null then 'aguardando' else 'cadastrado' end,
           coalesce(p.ativo, true), c.criado_em
      from public.convites c left join public.perfis p on lower(p.email) = c.email
     order by c.criado_em desc;
end $$;

create or replace function public.definir_ativo(p_email text, p_ativo boolean)
returns void language plpgsql security definer set search_path = public as $$
declare v_email text := lower(trim(coalesce(p_email, '')));
begin
  if public.papel_atual() is distinct from 'gerente' then raise exception 'permission-denied' using errcode = '42501'; end if;
  if exists (select 1 from public.perfis where lower(perfis.email) = v_email and user_id = auth.uid()) then
    raise exception 'voce nao pode desativar o proprio acesso' using errcode = '22023';
  end if;
  update public.perfis set ativo = p_ativo where lower(perfis.email) = v_email;
end $$;

create or replace function public.remover_acesso(p_email text)
returns void language plpgsql security definer set search_path = public as $$
declare v_email text := lower(trim(coalesce(p_email, '')));
begin
  if public.papel_atual() is distinct from 'gerente' then raise exception 'permission-denied' using errcode = '42501'; end if;
  if exists (select 1 from public.perfis where lower(perfis.email) = v_email and user_id = auth.uid()) then
    raise exception 'voce nao pode remover o proprio acesso' using errcode = '22023';
  end if;
  delete from public.docs where id = 'perfil'
    and collection = 'data/users/' || coalesce((select user_id::text from public.perfis where lower(perfis.email) = v_email), '-');
  delete from auth.users where lower(auth.users.email) = v_email;
  delete from public.convites where convites.email = v_email;
end $$;

create or replace function public.redefinir_senha(p_email text, p_nova text)
returns void language plpgsql security definer set search_path = public, extensions as $$
declare v_email text := lower(trim(coalesce(p_email, ''))); v_id uuid;
begin
  if public.papel_atual() is distinct from 'gerente' then raise exception 'permission-denied' using errcode = '42501'; end if;
  if length(coalesce(p_nova, '')) < 6 then raise exception 'a senha precisa de pelo menos 6 caracteres' using errcode = '22023'; end if;
  select id into v_id from auth.users where lower(auth.users.email) = v_email;
  if v_id is null then raise exception 'pessoa nao encontrada' using errcode = '22023'; end if;
  update auth.users set encrypted_password = crypt(p_nova, gen_salt('bf')), updated_at = now() where id = v_id;
  delete from auth.sessions where user_id = v_id;
end $$;

create or replace function public.trocar_codigo(p_novo text)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin
  if public.papel_atual() is distinct from 'gerente' then raise exception 'permission-denied' using errcode = '42501'; end if;
  if length(coalesce(p_novo, '')) < 4 then raise exception 'o codigo precisa de pelo menos 4 caracteres' using errcode = '22023'; end if;
  insert into public.app_segredo (chave, valor) values ('codigo_acesso', crypt(p_novo, gen_salt('bf')))
  on conflict (chave) do update set valor = excluded.valor;
  delete from public.tentativas where true;
end $$;

revoke all on function public.convidar(text, text, text, text), public.listar_acessos(), public.definir_ativo(text, boolean),
  public.remover_acesso(text), public.redefinir_senha(text, text), public.trocar_codigo(text) from public, anon;
grant execute on function public.convidar(text, text, text, text), public.listar_acessos(), public.definir_ativo(text, boolean),
  public.remover_acesso(text), public.redefinir_senha(text, text), public.trocar_codigo(text) to authenticated;

-- ---------------------------------------------------------------- início do app (rodar UMA vez)
-- Define o código de acesso e libera o e-mail do gerente. Só funciona se ainda não houver código.
-- Não é chamável pelo app: só pelo SQL Editor.
create or replace function public.iniciar_app(p_email text, p_codigo text)
returns text language plpgsql security definer set search_path = public, extensions as $$
begin
  if exists (select 1 from public.app_segredo where chave = 'codigo_acesso') then
    raise exception 'o app ja foi iniciado';
  end if;
  if length(coalesce(p_codigo, '')) < 4 then raise exception 'o codigo precisa de pelo menos 4 caracteres'; end if;
  if lower(trim(coalesce(p_email, ''))) !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'e-mail invalido'; end if;
  insert into public.app_segredo (chave, valor) values ('codigo_acesso', crypt(p_codigo, gen_salt('bf')));
  insert into public.convites (email, papel, nome, franquia)
  values (lower(trim(p_email)), 'gerente', 'Gerente', '')
  on conflict (email) do nothing;
  return 'ok';
end $$;
revoke all on function public.iniciar_app(text, text) from public, anon, authenticated;

-- ---------------------------------------------------------------- atualização ao vivo
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'docs') then
    alter publication supabase_realtime add table public.docs;
  end if;
end $$;
