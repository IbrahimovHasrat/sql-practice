create table warehouses (
    warehouse_id    number primary key,
    warehouse_name  varchar2(50)
);

create table products (
    product_id       number primary key,
    product_name     varchar2(50),
    warehouse_id     number,
    sale_price       number,
    purchase_price   number,
    quantity         number,
    category_id      number,
    constraint fk_prod_wh  foreign key (warehouse_id) references warehouses(warehouse_id),
    constraint fk_prod_cat foreign key (category_id)  references category(category_id)
);

create table invoices (
    invoice_id     number primary key,
    warehouse_id   number,
    product_id     number,
    invoice_date   date,
    total_amount   number,
    constraint fk_inv_wh   foreign key (warehouse_id) references warehouses(warehouse_id),
    constraint fk_inv_prod foreign key (product_id)   references products(product_id)
);
insert into warehouses values (1,'baki anbari');
insert into warehouses values (2,'gence anbari');
insert into warehouses values (3,'sumqayit anbari');
insert into warehouses values (4,'mingecevir anbari');
insert into warehouses values (5,'seki anbari');




select * from category;
insert into category values (1,'elektronika');
insert into category values (2,'ofis_avadanligi');

insert into products values (101,'noutbuk',1,1200,900,15,1);
insert into products values (102,'telefon',1,800,600,30,1);
insert into products values (103,'printer',2,350,250,10,2);
insert into products values (104,'monitor',2,250,180,20,2);
insert into products values (105,'klaviatura',3,20,12,50,2);

insert into invoices values (1001,1,101,to_date('01.10.2026','dd.mm.yyyy'),2400);
insert into invoices values (1002,1,101,to_date('02.10.2026','dd.mm.yyyy'),1200);
insert into invoices values (1003,2,103,to_date('03.10.2026','dd.mm.yyyy'),700);
insert into invoices values (1004,2,104,to_date('04.10.2026','dd.mm.yyyy'),500);
insert into invoices values (1005,3,105,to_date('05.10.2026','dd.mm.yyyy'),100);
--1
select p.product_name, p.quantity
from invoices i
join products p on i.product_id = p.product_id;
--2
select p.product_name, i.warehouse_id, i.total_amount
from invoices i
join products p on i.product_id = p.product_id
where i.total_amount = (select min(total_amount) from invoices);
--3
select w.warehouse_name, p.product_name
from warehouses w
join products p on w.warehouse_id = p.warehouse_id
fetch first 4 rows only;
--4
select p.product_name, sum(i.total_amount / p.sale_price) as satilan_eded
from invoices i
join products p on i.product_id = p.product_id
group by p.product_name;
--5
select *
from invoices i
join products p on i.product_id = p.product_id
join warehouses w on i.warehouse_id = w.warehouse_id;
--6
create or replace view v_warehouses_with_a as
select warehouse_id, warehouse_name
from warehouses
where warehouse_name like '%a%';
--7
-- insert
insert into v_warehouses_with_a values (6,'xirdalan anbari');
-- update
update v_warehouses_with_a set warehouse_name = 'astara anbari' where warehouse_id = 6;
-- delete
delete from v_warehouses_with_a where warehouse_id = 6;
--8
create or replace view v_full_invoice as
select i.invoice_id, i.invoice_date, p.product_name, p.sale_price, w.warehouse_name,
       (p.sale_price - p.purchase_price) as profit
from invoices i
join products p on i.product_id = p.product_id
join warehouses w on i.warehouse_id = w.warehouse_id;

insert into v_full_invoice (invoice_id, invoice_date, product_name, sale_price, warehouse_name, profit)
values (9999, sysdate, 'test', 100, 'test anbari', 50);
--9
create or replace view v_full_invoice as
select i.invoice_id, i.invoice_date, p.product_name, p.sale_price, w.warehouse_name,
       p.category_id, (p.sale_price - p.purchase_price) as profit
from invoices i
join products p on i.product_id = p.product_id
join warehouses w on i.warehouse_id = w.warehouse_id;

--10
select c.category_name,
       count(v.product_name) as mehsul_sayi,
       count(distinct v.warehouse_name) as unikal_anbar_sayi
from v_full_invoice v
join category c on v.category_id = c.category_id
group by c.category_name;


--task 2
create table departments_task2 (
    department_id    number primary key,
    department_name  varchar2(30),
    location         varchar2(30)
);
insert into departments_task2 values (10,'accounting','new york');
insert into departments_task2 values (20,'research','dallas');
insert into departments_task2 values (30,'sales','chicago');
insert into departments_task2 values (40,'operations','boston');

create table employees_task2 (
    employee_id    number primary key,
    last_name      varchar2(30),
    job            varchar2(30),
    manager_id     number,
    hiredate       date,
    salary         number,
    commission     number,
    department_id  number,
    constraint fk_emp_dept2 foreign key (department_id) references departments_task2(department_id)
);

insert into employees_task2 values (7369,'smith','clerk',7902,to_date('17-12-1980','dd-mm-yyyy'),800,null,20);
insert into employees_task2 values (7499,'allen','salesman',7698,to_date('20-02-1981','dd-mm-yyyy'),1600,300,30);
insert into employees_task2 values (7521,'ward','salesman',7698,to_date('22-02-1981','dd-mm-yyyy'),1250,500,30);
insert into employees_task2 values (7566,'jones','manager',7839,to_date('02-04-1981','dd-mm-yyyy'),2975,null,20);
insert into employees_task2 values (7654,'martin','salesman',7698,to_date('28-09-1981','dd-mm-yyyy'),1250,1400,30);
insert into employees_task2 values (7698,'blake','manager',7839,to_date('01-05-1981','dd-mm-yyyy'),2850,null,30);
insert into employees_task2 values (7782,'clark','manager',7839,to_date('09-06-1981','dd-mm-yyyy'),2450,null,10);
insert into employees_task2 values (7788,'scott','analyst',7566,to_date('19-04-1987','dd-mm-yyyy'),3000,null,20);
insert into employees_task2 values (7839,'king','president',null,to_date('17-11-1981','dd-mm-yyyy'),5000,null,10);
insert into employees_task2 values (7844,'turner','salesman',7698,to_date('08-09-1981','dd-mm-yyyy'),1500,0,30);

-- union
select department_id, department_name from departments_task2 where department_id >= 20
union
select department_id, department_name from departments_task2 where department_id <= 30;


--4) intersect, minus, union all
select department_id from departments_task2
intersect
select department_id from employees_task2;

select department_id from departments_task2
minus
select department_id from employees_task2;

select department_id from departments_task2
union all
select department_id from employees_task2;

--5) tarixlərə görə union
select employee_id, hiredate from employees_task2 where hiredate < to_date('01.01.2000','dd.mm.yyyy')
union
select employee_id, hiredate from employees_task2 where hiredate > to_date('31.12.2005','dd.mm.yyyy');
--6) en cox maas alan ilk 4 isci
select last_name, salary
from employees_task2
order by salary desc
fetch first 4 rows only;






create table hr_employees_last(
    employee_id    number,
    full_name      varchar2(50),
    job_title      varchar2(30),
    salary         number,
    hire_date      date,
    department_id  number
);
insert into hr_employees_last values (301,'ali mammadov','hr manager',4000,date '2019-01-10',10);
insert into hr_employees_last values (302,'nigar aliyeva','hr analyst',2800,date '2020-03-15',20);
insert into hr_employees_last values (203,'orxan huseynov','hr specialist',2500,date '2021-06-01',30);
insert into hr_employees_last values (204,'leyla karimova','hr partner',3200,date '2018-11-20',50);
insert into hr_employees_last values (205,'elvin rahimov','hr assistant',1800,date '2022-09-05',60);



select employee_id, last_name as full_name from employees_task2
union
select employee_id, full_name from hr_employees_last;

(select employee_id from employees_task2 minus select employee_id from hr_employees_last)
union
(select employee_id from hr_employees_last minus select employee_id from employees_task2);


select employee_id from employees_task2
intersect
select employee_id from hr_employees_last;

select last_name, job as job_title from employees_task2
union all
select full_name, job_title from hr_employees_last;


select salary from employees_task2
intersect
select salary from hr_employees_last;


select employee_id, full_name, job_title, salary, hire_date, department_id,
       null as manager_id, 'hr_last' as menbe
from hr_employees_last
union all
select employee_id, last_name as full_name, job as job_title,
       salary, hiredate, department_id, manager_id, 'employees' as menbe
from employees_task2;

