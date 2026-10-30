--===TASK 1
create table employees_archive_it (
    emp_id    number,
    emp_name  varchar2(50),
    salary    number
);

create table employees_archive_other (
    emp_id    number,
    emp_name  varchar2(50),
    salary    number
);

create table high_earners_audit (
    employee_id    number,
    annual_salary  number
);

--1)
select e.first_name, e.last_name, e.salary, e.department_id
from employees e
where e.salary in (
    select e2.salary
    from employees e2
    join departments d on e2.department_id = d.department_id
    where d.department_name = 'IT'
)
and e.department_id != (select d.department_id from departments d where d.department_name = 'IT');
--2)
select e.first_name, e.last_name
from employees e
where e.department_id = (
    select e2.department_id
    from employees e2
    group by e2.department_id
    having count(*) = (
        select max(count(*))
        from employees e3
        group by e3.department_id
    )
);

--3) exists
select d.department_id, d.department_name
from departments d
where exists (
    select 1
    from employees e
    where e.department_id = d.department_id
    group by e.department_id
    having count(*) >= 2
);

--4) all ile: butun menecerlerin maasindan yuksek maas alan adi isciler
select e.first_name, e.last_name, e.salary
from employees e
where e.employee_id not in (
    select m.manager_id from employees m where m.manager_id is not null
)
and e.salary > all (
    select m2.salary
    from employees m2
    where m2.employee_id in (
        select m3.manager_id from employees m3 where m3.manager_id is not null
    )
);

--5) with: iki cte, departament uzre max ve min maas
with max_maas as (
    select e.department_id, max(e.salary) as max_sal
    from employees e
    group by e.department_id
),
min_maas as (
    select e.department_id, min(e.salary) as min_sal
    from employees e
    group by e.department_id
)
select d.department_name, mx.max_sal, mn.min_sal, (mx.max_sal - mn.min_sal) as ferq
from max_maas mx
join min_maas mn on mx.department_id = mn.department_id
join departments d on mx.department_id = d.department_id;

--6) insert all: 2018-den evvel olanlar it arxivine, qalanlar other arxivine
insert all
    when hire_date < to_date('01.01.2018','dd.mm.yyyy') then
        into employees_archive_it (emp_id, emp_name, salary) values (emp_id, emp_name, salary)
    else
        into employees_archive_other (emp_id, emp_name, salary) values (emp_id, emp_name, salary)
select e.employee_id as emp_id, e.first_name || ' ' || e.last_name as emp_name, e.salary, e.hire_date
from employees e;
commit;


--7) merge: maasi 10000-den cox olanlari high_earners_audit ile sinxron et
merge into high_earners_audit a
using (
    select e.employee_id, e.salary * 12 as annual_salary
    from employees e
    where e.salary > 10000
) s
on (a.employee_id = s.employee_id)
when matched then
    update set a.annual_salary = s.annual_salary
when not matched then
    insert (employee_id, annual_salary) values (s.employee_id, s.annual_salary);
commit;


--Task 2
CREATE TABLE sobeler (
    sobe_id    NUMBER        CONSTRAINT pk_sobeler PRIMARY KEY,
    sobe_adi   VARCHAR2(50)  NOT NULL,
    region     VARCHAR2(50),
    isci_sayi  NUMBER                       -- Tapşırıq 17-də doldurulacaq
);

CREATE TABLE isciler (
    isci_id  NUMBER        CONSTRAINT pk_isciler PRIMARY KEY,
    ad       VARCHAR2(50)  NOT NULL,
    sobe_id  NUMBER        CONSTRAINT fk_isciler_sobe REFERENCES sobeler (sobe_id),
    maas     NUMBER(10,2)
);

CREATE TABLE layiheler (
    layihe_id   NUMBER         CONSTRAINT pk_layiheler PRIMARY KEY,
    layihe_adi  VARCHAR2(100),
    isci_id     NUMBER         NOT NULL CONSTRAINT fk_layihe_isci REFERENCES isciler (isci_id),
    budce       NUMBER
);

CREATE TABLE isci_yenilenme (               -- HR-dan gələn yeni məlumat (MERGE üçün)
    isci_id  NUMBER,
    ad       VARCHAR2(50),
    sobe_id  NUMBER,
    maas     NUMBER(10,2)
);

CREATE TABLE isci_yuksek (isci_id NUMBER, ad VARCHAR2(50), maas NUMBER(10,2));
CREATE TABLE isci_orta   (isci_id NUMBER, ad VARCHAR2(50), maas NUMBER(10,2));
CREATE TABLE isci_asagi  (isci_id NUMBER, ad VARCHAR2(50), maas NUMBER(10,2));

INSERT INTO sobeler VALUES (10, 'Maliyyə',   'Bakı',     NULL);
INSERT INTO sobeler VALUES (20, 'IT',        'Bakı',     NULL);
INSERT INTO sobeler VALUES (30, 'Satış',     'Gəncə',    NULL);
INSERT INTO sobeler VALUES (40, 'Marketinq', 'Sumqayıt', NULL);

INSERT INTO isciler VALUES (1, 'Anar',   10,   3000);
INSERT INTO isciler VALUES (2, 'Aysel',  10,   2200);
INSERT INTO isciler VALUES (3, 'Rəşad',  20,   4500);
INSERT INTO isciler VALUES (4, 'Nigar',  20,   3800);
INSERT INTO isciler VALUES (5, 'Elvin',  20,   2500);
INSERT INTO isciler VALUES (6, 'Leyla',  30,   1800);
INSERT INTO isciler VALUES (7, 'Tural',  30,   2100);
INSERT INTO isciler VALUES (8, 'Kamran', NULL, 1500);     -- şöbəsi yoxdur

INSERT INTO layiheler VALUES (101, 'CRM sistemi',       3, 50000);
INSERT INTO layiheler VALUES (102, 'Mobil bank',        4, 30000);
INSERT INTO layiheler VALUES (103, 'Hesabat paneli',    1, 20000);
INSERT INTO layiheler VALUES (104, 'Satış kampaniyası', 7, 15000);
INSERT INTO layiheler VALUES (105, 'Data anbarı',       3, 40000);

INSERT INTO isci_yenilenme VALUES (2,  'Aysel',  10, 2600);
INSERT INTO isci_yenilenme VALUES (6,  'Leyla',  30, 2000);
INSERT INTO isci_yenilenme VALUES (9,  'Səbinə', 20, 3300);
INSERT INTO isci_yenilenme VALUES (10, 'Orxan',  40, 2400);














--1) 
select i.ad, i.maas
from isciler i
where exists (select 1 from layiheler l where l.isci_id = i.isci_id);

--2) 
select i.ad, i.maas
from isciler i
where not exists (select 1 from layiheler l where l.isci_id = i.isci_id);

--3) 
select s.sobe_adi
from sobeler s
where not exists (select 1 from isciler i where i.sobe_id = s.sobe_id);

--4) 
select i.ad
from isciler i
where exists (select 1 from layiheler l where l.isci_id = i.isci_id and l.budce >= 30000);

--5)
select s.sobe_adi
from sobeler s
where exists (
    select 1 from isciler i
    where i.sobe_id = s.sobe_id
    and exists (select 1 from layiheler l where l.isci_id = i.isci_id)
);

--6) 
select i.ad, i.maas
from isciler i
where i.maas > any (select i2.maas from isciler i2 where i2.sobe_id = 20);

--7) 
select i.ad, i.maas
from isciler i
where i.maas < some (select i2.maas from isciler i2 where i2.sobe_id = 10);


--8) 
select i.ad, i.maas
from isciler i
where i.maas > all (select i2.maas from isciler i2 where i2.sobe_id = 30);

--9)
select i.ad, i.sobe_id
from isciler i
where i.sobe_id in (select s.sobe_id from sobeler s where s.region = 'Bakı');

--10a) 
select s.sobe_adi from sobeler s
where s.sobe_id not in (select i.sobe_id from isciler i);

--10b) 
select s.sobe_adi from sobeler s
where s.sobe_id not in (select i.sobe_id from isciler i where i.sobe_id is not null);

--11) 
select i.ad, i.sobe_id
from isciler i
where i.sobe_id not in (select s.sobe_id from sobeler s where s.region = 'Bakı');


--12) 
update isciler i
set i.maas = i.maas * 1.05
where not exists (select 1 from layiheler l where l.isci_id = i.isci_id);
select i.ad, i.maas from isciler i;


--13) 
update sobeler s
set s.isci_sayi = (select count(*) from isciler i where i.sobe_id = s.sobe_id);
select s.sobe_adi, s.isci_sayi from sobeler s;



--14) 
select l.layihe_id, l.layihe_adi
from layiheler l
where l.isci_id in (
    select i.isci_id from isciler i
    where i.sobe_id in (select s.sobe_id from sobeler s where s.region = 'Gəncə')
);
delete from layiheler l
where l.isci_id in (
    select i.isci_id from isciler i
    where i.sobe_id in (select s.sobe_id from sobeler s where s.region = 'Gəncə')
);
rollback;

--15) merge: isci_yenilenme -> isciler
merge into isciler i
using isci_yenilenme y
on (i.isci_id = y.isci_id)
when matched then
    update set i.maas = y.maas, i.sobe_id = y.sobe_id
when not matched then
    insert (isci_id, ad, sobe_id, maas) values (y.isci_id, y.ad, y.sobe_id, y.maas);
-- 2 setir yenilendi , 2 setir elave olundu 
select i.isci_id, i.ad, i.sobe_id, i.maas from isciler i order by i.isci_id;










