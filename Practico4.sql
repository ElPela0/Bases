--1)
create view ENVIOS500 as(
select *
from envio
    where cantidad >= 500
                        );
--Automaticamente actualizable en estandar y postgre
CREATE view ENVIOS500_M as (
select *
from ENVIOS500
    where cantidad < 1000
                           );
--Automaticamente actualizable en estandar y postgre
Create view RUBROS_PROV as(
    select rubro
    from proveedor
    where upper(ciudad) = 'TANDIL'
                          );
--Automaticamente actualizable en estandar y postgre
create view ENVIOS_PROV as (
select p.id_proveedor,
       p.nombre,
       e.cantidad
    from proveedor p join envio e
        on p.id_proveedor = e.id_proveedor
                           );
--no es automaticamente actualizable ni en estandarSQL ni Postgre
--porque tiene mas de una tabla en la clausula from
--Con una subconsulta seria automaticamente actualizable en postgre

--2)
--1.
create view EMPLEADO_DIST_20 as (
select 
    id_empleado,
    nombre,
    apellido,
    sueldo,
    fecha_nacimiento
from empleado 
where id_departamento = 20
                                );
--2
create view EMPLEADO_DIST_2000 as (
    select 
        id_empleado,
        nombre,
        apellido,
        sueldo,
        fecha_nacimiento
    from empleado
    where sueldo > 2000
);
--3
create view EMPLEADO_DIST_20_70 as (
select 
    id_empleado,
    nombre,
    apellido,
    sueldo,
    fecha_nacimiento
from EMPLEADO_DIST_20
where extract(Year from (fecha_nacimiento)) >1969 AND extract(Year from (fecha_nacimiento)) < 1980
);
--4
Create view PELICULAS_ENTREGADAS as (
    select 
        p.codigo_pelicula,
        re.cantidad
    from pelicula p join renglon_entrega re
        on p. codigo_pelicula = re.codigo_pelicula
);
--5
CREATE VIEW DISTRIB_NAC as (
    select
        id_distribuidor
        nro_inscripcion
        encargado
    from nacional
    where id_distrib_mayorista = 'AR'
);
--6
CREATE VIEW DISTRIB_NAC_MAS2EMP as (
    select 
        dn.id_distribuidor
        dn.nro_inscripcion
        dn.encargado
    from DISTRIB_NAC dn join departamento d 
        on dn.id_distribuidor = d.id_distribuidor
    where d. id_departamento in (
        select id_departamento
        from empleado
        group by id_departamento
        having count(*) >2
    )
);
-- b) las vistas que no son actualizables son la 4,5 y 6 porque obtiene los datos de mas de una tabla 

/*
3) si se agrega el with check option se debera cumplir la condicion con la que se impuso
*/
INSERT INTO ENVIOS500 VALUES ('P1', 'A1', 500);
/*
Con o sin check inserta /se actualiza siempre porque cumple la condicion de ENVIOS500
*/
INSERT INTO ENVIOS500 VALUES ('P2', 'A2', 300);
/*
Sin CHECK ocurre migracion de tuplas porque se inserta en envio porque se puede insertar en la tabla base
Con CHECK no se actualizaria en la vista ni en la tabla base porque obliga a que se cumpla la condicion
*/
UPDATE ENVIOS500 SET cantidad=100 WHERE id_proveedor= 'P1';
/*
Sin CHECK se actualiza y se quita de la vista porque deja de cumplir la condicion
Con CHECK no se actualiza porque no cumple con la condicion
*/
UPDATE ENVIOS500 SET cantidad=1000 WHERE id_proveedor= 'P2';
/*
Con o sin check se permitiria igual o no se haria porque no se encontraria P2 porque en el insert no se encontraria p2
*/
INSERT INTO ENVIOS500 VALUES ('P1', 'A3', 700);
/*
Con o sin check se permitiria igual la actualizacion
*/
----------------------------------------------------------------------------------------------------------------------------------
--4
CREATE OR REPLACE VIEW tarea10000hs AS
SELECT *  FROM tarea
WHERE max_horas > 10000
WITH LOCAL CHECK OPTION;

CREATE OR REPLACE VIEW tarea10000rep AS
SELECT *  FROM tarea10000hs
WHERE id_tarea LIKE '%REP%'
WITH LOCAL CHECK OPTION;

INSERT INTO tarea10000rep (id_tarea, nombre_tarea, min_horas, max_horas)
     VALUES ( 'MGR', 'Org Salud', 18000, 20000);
/*
No se insertaria porque no cumple con el primer filtro de las vistas
*/
INSERT INTO tarea10000hs (id_tarea, nombre_tarea, min_horas, max_horas)
     VALUES (  'REPA', 'Organiz Salud', 4000, 5500);
/*
no se va a insertar porque no cumple con la condicion de tarea10000hs
*/
INSERT INTO tarea10000rep (id_tarea, nombre_tarea, min_horas, max_horas)
     VALUES ( 'CC_REP', 'Organizacion Salud', 8000, 9000);
/*
No se inserta porque cumple con tarea10000rep pero como tarea10000hs tiene wco
se tiene que cumplir la condicion de max_horas > 10000
*/
INSERT INTO tarea10000hs (id_tarea, nombre_tarea, min_horas, max_horas)
     VALUES (  'ROM', 'Org Salud', 10000, 12000);
/*
Se inserta en la vista y se actualiza porque como se quiere insertar en tarea10000hs
solo con que cumpla con max_horas > 100000 ya se inserta
*/
-------------------------------------------------------------------------------------------------
/* 5)
Empleado dist 20 con local o cascade seria lo mismo porque iria directamente a la tabla base
pero en empleado dist 20 70 con local si dist20 no tiene WCO solo checkearia si nacio entre el 70  y el 79
   y con cascade iria a checkear si dist20 cumple con la condicion
lo mismo para empleado dist 2000
*/

------------------------------------------------------------------------------------------------------------------------
CREATE VIEW ciudad_kp_2 AS
SELECT id_ciudad, nombre_ciudad, c.id_pais, nombre_pais
FROM ciudad c NATURAL JOIN pais p;
/*
La clave es id_ciudad que es la PK de la tabla ciudad y se
actualizarian los datos de la tabla base a la cual pertenece la
clave de la vista

Luego de haber identificado la clave el resto es actualizable
(nombre_ciudad,c.id_pais,c.nombre_pais)
*/
CREATE VIEW entregas_kp_3 AS
SELECT nro_entrega, re.codigo_pelicula, cantidad, titulo
FROM renglon_entrega re JOIN pelicula p using (codigo_pelicula);
/*
la clave va a ser nro_entrega se puede actualizar el resto
*/

create or replace function fn_ciudad_kp2 () returns trigger as  $$
    begin
        if(not exists(select 1 from ciudad where id_ciudad= new.id_ciudad )and tg_op='INSERT') then
            insert into ciudad(id_ciudad, nombre_ciudad, id_pais) VALUES (new.id_ciudad,new.nombre_ciudad,new.id_pais);
        end if;
        if(tg_op = 'UPDATE')then
            --if por atributo y cambiar
        end if;
    end;
    $$ language 'plpgsql'

CREATE OR REPLACE TRIGGER tr_ciudad_kp2
    instead of insert or update on ciudad_kp_2
    for statement execute function fn_ciudad_kp2();
-- el otro lo hace dios

--7
create or replace view Vista1 as (
select v.nro_voluntario,
       v.nombre,
       v.apellido,
       v.horas_aportadas,
       t.id_tarea,
       t.nombre_tarea,
       t.max_horas,
       t.min_horas
    from voluntario v join tarea t
        on v.id_tarea = t.id_tarea
                                 )
-- no es automaticamente actualizable por el join entre voluntario y tarea
create or replace function fn_vista1_act () returns trigger as $$
    begin
        if (tg_op = 'INSERT') then
            insert into voluntario (nombre, apellido, e_mail, telefono, fecha_nacimiento,id_tarea)
            values (new.nombre,new.apellido,new.e_mail,new.telefono,new.fecha_nacimiento,new.id_tarea);
        end if;
    end;
    $$