-- Relatório de Supervisão: o vendedor lê só o que é dele (rodar uma vez no SQL Editor do Supabase)
-- Depois de rodar: vendedor vê só as saídas em que participa, as próprias fotos, a própria avaliação
-- e os próprios acessos. Gerente e supervisor continuam vendo tudo.

-- Nome do vendedor logado (nulo para gerente, supervisor ou conta desativada).
create or replace function public.nome_vendedor()
returns text language sql stable security definer set search_path = public as $$
  select nome from public.perfis where user_id = auth.uid() and ativo and papel = 'vendedor'
$$;
revoke all on function public.nome_vendedor() from public, anon;
grant execute on function public.nome_vendedor() to authenticated;

drop policy if exists docs_ler on public.docs;
create policy docs_ler on public.docs for select to authenticated using (
  -- gerente e supervisor: tudo do app
  ((select public.papel_atual()) in ('gerente', 'supervisor')
    and collection in ('saidas', 'config', 'fotos', 'avalSup', 'acessos'))
  -- cada pessoa lê o próprio perfil
  or ((select public.papel_atual()) is not null
    and collection = 'data/users/' || (select auth.uid())::text)
  -- vendedor: só o que é dele
  or ((select public.nome_vendedor()) is not null and (
    (collection = 'saidas' and (
      data -> 'vendedores' ? (select public.nome_vendedor())
      or jsonb_path_exists(data, '$.tarefas[*].vendedores[*] ? (@ == $n)',
           jsonb_build_object('n', (select public.nome_vendedor())))))
    or (collection in ('fotos', 'avalSup', 'acessos')
      and data ->> 'vendedor' = (select public.nome_vendedor()))
  ))
);

-- Parte da configuração que o app do vendedor precisa (sem telefones, listas de equipe ou metas).
create or replace function public.config_publica()
returns jsonb language sql stable security definer set search_path = public as $$
  select case when (select public.papel_atual()) is null then null else (
    select jsonb_build_object(
      'franquias', coalesce(d.data -> 'franquias', '[]'::jsonb),
      'supervisores', coalesce(d.data -> 'supervisores', '[]'::jsonb),
      'generos', coalesce(d.data -> 'generos', '{}'::jsonb),
      'bonusAbertura', d.data -> 'bonusAbertura',
      'gerente', d.data -> 'gerente')
    from public.docs d where d.collection = 'config' and d.id = 'geral') end
$$;
revoke all on function public.config_publica() from public, anon;
grant execute on function public.config_publica() to authenticated;

-- O emblema "Líder de aberturas da franquia" é calculado aqui, sem o vendedor ver os números dos outros.
create or replace function public.lider_aberturas()
returns boolean language plpgsql stable security definer set search_path = public as $$
declare
  v_nome text := public.nome_vendedor();
  v_mes text := to_char(now() at time zone 'America/Sao_Paulo', 'YYYY-MM');
  v_bonus numeric;
  v_res boolean;
begin
  if v_nome is null then return false; end if;
  select coalesce((data ->> 'bonusAbertura')::numeric, 5) into v_bonus
    from public.docs where collection = 'config' and id = 'geral';
  if coalesce(v_bonus, 5) <= 0 then return false; end if;
  with s as (
    select d.data ->> 'franquia' as fr,
           jsonb_array_elements_text(d.data -> 'vendedores') as vend,
           coalesce((d.data ->> 'aberturas')::numeric, 0) / greatest(jsonb_array_length(d.data -> 'vendedores'), 1) as ab
      from public.docs d
     where d.collection = 'saidas'
       and left(coalesce(d.data ->> 'data', ''), 7) = v_mes
       and jsonb_typeof(d.data -> 'vendedores') = 'array'
  ), por_vend as (
    select vend, sum(ab) as ab,
           (select x.fr from (select s2.fr, count(*) as c from s s2 where s2.vend = s.vend
                               group by s2.fr order by c desc, s2.fr limit 1) x) as fr
      from s group by vend
  ), topo as (
    select fr, max(round(ab, 2)) as m from por_vend group by fr
  )
  select exists (
    select 1 from por_vend p join topo t on t.fr is not distinct from p.fr
     where p.vend = v_nome and round(p.ab, 2) > 0 and round(p.ab, 2) = t.m
  ) into v_res;
  return coalesce(v_res, false);
end $$;
revoke all on function public.lider_aberturas() from public, anon;
grant execute on function public.lider_aberturas() to authenticated;
