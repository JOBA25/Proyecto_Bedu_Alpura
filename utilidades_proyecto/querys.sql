USE sello_rojo;
/* tabla con el total de ventas por producto*/
SELECT sum(v.IMP_VENTA_BRUTA) as ventas_totales, p.SKU 
from ventas v
join productos p
on v.ID_PRODUCTO = p.ID_PRODUCTO
group by p.SKU
having sum(v.IMP_VENTA_BRUTA) > 5000000
order by 1 desc;


/*ventas por Estado en plazas*/
SELECT sum(v.IMP_VENTA_BRUTA) as ventas , pl.ESTADO
from ventas v
join plazas pl
on v.ID_PLAZA = pl.ID_PLAZA
group by pl.ESTADO
order by 1 desc;

select sum(v.IMP_VENTA_BRUTA) as ventas, sum(v.CANTIDAD_VENTA) as cantidad_venta ,cl.Clave_Cliente, cl.SUCURSAL,  pl.ESTADO, pr.FAMILIA, cl.CADENA, cl.RAZON_SOCIAL
from ventas v
join clientes cl
on v.Clave_Cliente = cl.Clave_Cliente
join plazas pl
on v.ID_PLAZA = pl.ID_PLAZA
join productos pr
on v.ID_PRODUCTO = pr.ID_PRODUCTO
group by cl.Clave_Cliente, cl.SUCURSAL,  pl.ESTADO, pr.FAMILIA, cl.CADENA, cl.RAZON_SOCIAL
order by 1 desc;


/*ventas por mes*/
select sum(v.IMP_VENTA_BRUTA) as ventas, month(v.fecha) as Mes
from ventas v
group by 2
order by 1 desc;
/****************************** lineas para arreglar la conexión con python ***************************************/
ALTER USER 'root'@'localhost' IDENTIFIED BY 'toor' PASSWORD EXPIRE NEVER;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'toor';
/* ******************************************************************************************* */



/*Tabla completa */
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
on v.Clave_Cliente = cl.Clave_Cliente
