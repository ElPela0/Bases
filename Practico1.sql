--Punto 1
SELECT v.apellido,v.nombre
from voluntario v  join unc_esq_voluntario.tarea t on t.id_tarea = v.id_tarea
where v.id_tarea='IT_PROG'OR v.id_tarea='ST_CLERCK'
AND v.horas_aportadas != 2500 AND v.horas_aportadas != 3500 AND v.horas_aportadas != 7000
ORDER BY apellido,nombre
--punto 2
select nro_voluntario AS "numero", (nombre||' , '||apellido )as "Nombre y apellido",
       (e_mail||' , '||telefono) as "contacto"
from voluntario
where horas_aportadas < 1000
order by nro_voluntario
--Punto 3
select distinct id_coordinador
from voluntario
where id_coordinador is not null
--Punto4
select id_tarea
from voluntario
where porcentaje=0 or porcentaje is null
--punto5
select *
from voluntario
order by horas_aportadas desc
limit 5
--punto6
select nro_voluntario,apellido,nombre,extract(year FROM age(current_date,fecha_nacimiento)) as edad
from voluntario
where extract(MONTH from fecha_nacimiento)=extract(month from current_date)
order by edad desc
limit 3
--punto7
select max(horas_aportadas) as maximo,min(horas_aportadas) as minimo,avg(horas_aportadas)as promedio
from voluntario
where extract(year from age(current_date,fecha_nacimiento))>=30
;
--punto8
select
    id_institucion,
    count(id_institucion)as "cantidad empleados",
    sum(horas_aportadas)as "cant horas aportadas"
from voluntario
where id_institucion is not null
group by id_institucion
;
--punto9
select id_institucion, count(id_institucion)as cantidad
from voluntario
where id_institucion is not null
group by id_institucion
having count(nro_voluntario) >10
;
--punto10
select distinct id_coordinador,count(id_coordinador)
from voluntario
group by id_coordinador
having count(id_coordinador) > 3
order by count(id_coordinador)
;
--punto11
select
    e.id_empleado,
    e.nombre,
    e.apellido
from empleado e join tarea t
    on e.id_tarea = t.id_tarea
where e.id_jefe is null AND t.sueldo_maximo > 14800
order by t.sueldo_maximo
;
--punto12
select
    e.id_empleado,
    e.nombre,
    e.apellido,
    e.sueldo
from empleado e left join empleado e2
    on e.id_jefe = e2.id_empleado and e.id_jefe is not null
where e.sueldo > e2.sueldo
order by id_empleado
;
--punto13
--punto13
select d.id_distribuidor,
       d.tipo,
       d.nombre,
       count(distinct p.codigo_pelicula)
from distribuidor d
JOIN entrega e
    on d.id_distribuidor = e.id_distribuidor
JOIN renglon_entrega re
    on e.nro_entrega = re.nro_entrega
join pelicula p
    on re.codigo_pelicula = p.codigo_pelicula
where upper(p.idioma) ='ESPAÑOL' and
      extract(YEAR FROM (e.fecha_entrega)) > 2010

group by d.id_distribuidor, d.tipo, d.nombre
;
--punto14
select e.apellido,
       coalesce(e2.apellido,'no posee')as "apellido jefe"
from empleado e
left join empleado e2
    on e.id_jefe = e2.id_empleado
order by e.apellido, e2.apellido
;
--punto15
select d.id_distribuidor,
       d.nombre,
       count(*)
from distribuidor d
join entrega e
    on d.id_distribuidor = e.id_distribuidor
join video v
    on e.id_video = v.id_video
group by d.id_distribuidor, d.nombre
;
-- punto16
select p.*
from pelicula p
where p.codigo_pelicula in (
    select e.id_video
    from entrega e
    where e.id_distribuidor in (
        select d.id_distribuidor
        from distribuidor d
        where d.tipo = 'I'
        )
    )
;
--punto17
select de.nombre,
       de.id_distribuidor,
       de.id_departamento
from departamento de
where (de.id_departamento,de.id_distribuidor) in (
    select e.id_departamento, e.id_distribuidor
    from empleado e
    where e.id_tarea in (
        select t.id_tarea
        from tarea t
        where t.sueldo_minimo < 6000
        )
    group by (e.id_departamento, e.id_distribuidor)
    having count(*) >3
    )
order by de.id_departamento
;
--punto18
select de.*
from departamento de
where (de.id_distribuidor,de.id_departamento) in (
    select e.id_distribuidor,e.id_departamento
    from empleado e
    group by (e.id_distribuidor,e.id_departamento)
    having count(*)< (
        select count(*) *0.1
        from empleado
        )
    );
--punto19
select de.*
from departamento de
where (de.id_distribuidor,de.id_departamento) in(

    select e.id_distribuidor,e.id_departamento
    from empleado e
    group by (e.id_distribuidor,e.id_departamento)
    having count(*)= (
        select count(*)
        from empleado e
        group by (e.id_distribuidor,e.id_departamento)
        order by count(*) desc
        limit 1
    )
);
--punto20 se pueden todos menos el 14

--punto21
select d.id_distribuidor
from distribuidor d
except (
    select e.id_distribuidor
    from entrega e
)
;
select *
from distribuidor d
where d.id_distribuidor not in (
    select e.id_distribuidor
    from entrega e
    where e.id_distribuidor is not null
    );

--punto22
select e.*
from empleado e
join empleado e2
on e.id_empleado = e2.id_jefe
INTERSECT
select e3.*
from empleado e3
join departamento de
    on e3.id_empleado = de.jefe_departamento
;
--punto23
select d.*,'' as encargado
from distribuidor d
UNION
select d2.*,n.encargado
from distribuidor d2
join nacional n
    on d2.id_distribuidor = n.id_distribuidor
;
--punto24
select d.*
from distribuidor d
join entrega e on d.id_distribuidor = e.id_distribuidor
where not exists(
    select p.codigo_pelicula
    from pelicula p
    except
    select v.id_video
    from video v
    where v.id_video = e.id_video
)
;
