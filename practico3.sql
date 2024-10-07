create or replace function fn_his_entrega_2 () returns trigger as $$
    begin
        insert into his_entrega_aux(numero) values (1);
        return new;
    end;
    $$ language 'plpgsql';


create or replace function fn_his_entrega() returns trigger as $$
    declare
        cant int;
    begin
        cant = (select count(*) from his_entrega_aux);
        insert into his_entrega(fecha, operacion, cant_reg_afectados, usuario) values(current_timestamp,tg_op,cant,current_user);
        delete from his_entrega_aux;
        return new;
    end
    $$ language 'plpgsql';



--Renglon entrega
create or replace trigger tr_cont_his_renglon
    after insert or update or delete on renglon_entrega
    for each row execute function fn_his_entrega_2();
create or replace trigger tr_his_renglon
    after insert or update or delete on renglon_entrega
    for statement execute function fn_his_entrega();
--Entrega
create or replace  trigger tr_cont_his_entrega
    after insert or update or delete on entrega
    for each row execute function fn_his_entrega_2();
create or replace trigger tr_his_entrega
    after insert or update or delete on entrega
    for statement execute function fn_his_entrega();


update  renglon_entrega set cantidad =cantidad+1 where nro_entrega=24;
delete from his_entrega;
select * from HIS_ENTREGA;


--5
create table his_empleado (
    id_empleado numeric(6) not null,
    fecha_inicio date not null,
    fecha_fin date
);
alter table empleado
add column fecha_inicio date;
update empleado set fecha_inicio= current_timestamp;


