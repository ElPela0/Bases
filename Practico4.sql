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