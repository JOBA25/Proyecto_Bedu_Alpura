USE sello_rojo;


/****************************** lineas para arreglar la conexión con python ***************************************/
ALTER USER 'root'@'localhost' IDENTIFIED BY 'toor' PASSWORD EXPIRE NEVER;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'toor';
/* ******************************************************************************************* */


/*vista de Tabla completa */
create view dbFull
as
select v.FECHA, v.CANTIDAD_VENTA, v.IMP_VENTA_BRUTA, pl.ID_PLAZA, pl.DEPOSITOS, pl.AREA, pl.ESTADO, pl.ZONA, pl.CLAVE,
cl.Clave_Cliente, cl.NUM_CLIENTE, cl.NUM_SUC_ALPURA, cl.RAZON_SOCIAL, cl.SUCURSAL, cl.CADENA, 
p.ID_PRODUCTO, p.SKU, p.FAMILIA, p.CATEGORIA_SOP
from ventas v
join productos p
on v.ID_PRODUCTO = p.ID_PRODUCTO
join plazas pl
on v.ID_PLAZA = pl.ID_PLAZA
join clientes cl
on v.Clave_Cliente = cl.Clave_Cliente;


/**************************************************ya en la libreta de python*************************************************/
/* tabla con el total de ventas por producto*/
/*create view ventas_prod
as*/
SELECT sum(v.IMP_VENTA_BRUTA) as ventas_totales, p.SKU 
from ventas v
join productos p
on v.ID_PRODUCTO = p.ID_PRODUCTO
join plazas pl
group by p.SKU
order by 1 desc;


/**************************************************ya en la libreta de python*************************************************/
/*ventas por Estado en plazas*/
/*create view ventas_estado
as*/
SELECT sum(v.IMP_VENTA_BRUTA) as ventas , pl.ESTADO
from ventas v
join plazas pl
on v.ID_PLAZA = pl.ID_PLAZA
group by pl.ESTADO
order by 1 desc
limit 5;



/**************************************************ya en la libreta de python*************************************************/
/*ventas por mes*/
/*create view ventas_mes
as*/
select sum(v.IMP_VENTA_BRUTA) as ventas, monthname(v.fecha) as Mes
from ventas v
group by 2;
/*order by 1 asc;
*/


/****************************************************no agregada******************************************************************/
select sum(v.IMP_VENTA_BRUTA) as ventas, sum(v.CANTIDAD_VENTA) as cantidad_venta ,cl.Clave_Cliente, cl.SUCURSAL,  pl.ESTADO, pr.FAMILIA, cl.CADENA, cl.RAZON_SOCIAL
from ventas v
join clientes cl
on v.Clave_Cliente = cl.Clave_Cliente
join plazas pl
on v.ID_PLAZA = pl.ID_PLAZA
join productos pr
on v.ID_PRODUCTO = pr.ID_PRODUCTO
group by pl.ESTADO, cl.SUCURSAL,cl.Clave_Cliente  , pr.FAMILIA, cl.CADENA, cl.RAZON_SOCIAL
order by 1 desc;



/**********************************************************************************************************************/
/*         productos que generaron más ventas en los 5 estados con mayores ventas*/
/*                            ya en la libreta                                    */
/*
create view prod_est
as*/
WITH inventory
AS (
	SELECT row_number() over(partition by x.ESTADO order by x.ventas_totales desc) row_num , 
			 x.ventas_totales,
			 x.SKU,
			 x.ESTADO 
    from (
			select 
			sum(v.IMP_VENTA_BRUTA) as ventas_totales,
			 p.SKU,
			 pl.ESTADO 
			from ventas v
			join productos p
			on v.ID_PRODUCTO = p.ID_PRODUCTO
			join (SELECT sum(v.IMP_VENTA_BRUTA) as ventas , pl.ESTADO, pl.ID_PLAZA
					from ventas v
					join plazas pl
					on v.ID_PLAZA = pl.ID_PLAZA
					group by pl.ESTADO
					order by 1 desc
					limit 6) as pl
			on v.ID_PLAZA = pl.ID_PLAZA
			group by p.SKU, pl.ESTADO
			order by 1 desc
		) x
)
select i.ventas_totales,
	 i.SKU,
	 i.ESTADO
from inventory i
where i.row_num <= 5;



/**********************************************************************************************************************************/
/*                                                    cadenas                                                                     */ 
/*                                                 ya en la libreta                                                                 */
create view cad
as
select sum(v.IMP_VENTA_BRUTA) ventas, cl.CADENA
from ventas v
join clientes cl
on v.Clave_Cliente = cl.Clave_Cliente
where cl.CADENA not Like  "%Z IND%" and cl.CADENA not Like  "(PENAL)"
group by cl.CADENA
having sum(v.IMP_VENTA_BRUTA) > 0
order by 1 desc;



/**********************************************************************************************************************************/
/*                                                cadenas por estados                                                             */

create view cad_estado
as
WITH inventory
AS (
	SELECT row_number() over(partition by x.ESTADO order by x.ventas_totales desc) row_num , 
			 x.ventas_totales,
			 x.CADENA,
			 x.ESTADO 
    from (
			select 
			sum(v.IMP_VENTA_BRUTA) as ventas_totales,
			 c.CADENA ,
			 pl.ESTADO 
			from ventas v
			join clientes c 
			on v.Clave_Cliente = c.Clave_Cliente
			join (SELECT sum(v.IMP_VENTA_BRUTA) as ventas , pl.ESTADO, pl.ID_PLAZA
					from ventas v
					join plazas pl
					on v.ID_PLAZA = pl.ID_PLAZA
					group by pl.ESTADO
					order by 1 desc
					limit 6) as pl
			on v.ID_PLAZA = pl.ID_PLAZA
            where c.CADENA not Like  "%Z IND%" and c.CADENA not Like  "(PENAL)"
			group by c.CADENA , pl.ESTADO
			order by 1 desc
		) x
)
select 
	i.ventas_totales,
	 i.CADENA,
	 i.ESTADO
from inventory i
where i.row_num <= 5;
