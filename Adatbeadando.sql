create table Szgk(
    Rendszam varchar(7) primary key,
    Tipus varchar(50) not null, 
    Automata_e bit not null
)

 

create table Statuszok(
    Statusz_id int primary key,
    Statusz varchar(50) not null
)

 

create table Helyszinek(
    Helyszin_id int primary key,
    Helyszin_nev varchar(50) not null
)


create table Oktato (
	Oktato_id int primary key,
	Rendszam varchar(7) not null,
	Vezeteknev varchar(50) not null, 
	Keresztnev varchar(50) not null,
	Telefon varchar(12) not null,
	Helyszin_id int not null,
	foreign key(Rendszam) references Szgk(Rendszam),
	foreign key(Helyszin_id) references Helyszinek(Helyszin_id),
)


create table Tanulok (
	Tanulo_id int primary key,
	Vezeteknev varchar(50) not null,
	Keresztnev varchar(50) not null,
	Telefon varchar(12) not null,
	Email varchar(50) null,
	Kezdes_datum date not null
	constraint jo_datum
	check (getdate()> Kezdes_datum),
	Eddigi_orak int null,
	Oktato_id int not null,
	Statusz_id int not null,
	foreign key(Oktato_id) references Oktato(Oktato_id),
	foreign key(Statusz_id) references Statuszok(Statusz_id)
)




insert into Szgk(Rendszam, Tipus, Automata_e)
values ('ABC-123', 'Skoda Octavia', 0),
		('LMP-324', 'Toyota Yaris', 0),
		('MMM-765', 'Citroen C4', 1)


insert into Statuszok(Statusz_id, Statusz)
values (1, 'Oktatóra vár'),
		(2, 'Vezetés folyamatban'),
		(3, 'Vizsga elõtt áll'),
		(4, 'Levizsgázott')


insert into Helyszinek(Helyszin_id, Helyszin_nev)
values (1, 'Budapest'),
		(2, 'Szeged'),
		(3, 'Kaposvár')


insert into Oktato(Oktato_id, Rendszam, Vezeteknev, Keresztnev, Telefon, Helyszin_id)
values (1, 'ABC-123', 'Hús', 'Leves', '06201234567', 1),
        (2, 'LMP-324', 'Benedek', 'Elek', '06201234567', 2),
        (3, 'LMP-324', 'Csirke', 'Pörkölt', '06201234567', 2),
        (4, 'ABC-123', 'Cinka', 'Panka', '06201234567', 1),
        (5, 'MMM-765', 'Leves', 'Kocka', '06201234567', 3)


insert into Tanulok (Tanulo_id, Vezeteknev, Keresztnev, Telefon, Kezdes_datum, Eddigi_orak, Oktato_id, Statusz_id)
values(1, 'Bernáth', 'Flóra', '06201234567', '2023.02.03', 20, 2, 2),
        (2, 'Tasnádi-Tulogdi', 'Zsófia', '06201234567', '2021.12.20', 33, 3, 4),
        (3, 'Epres', 'Barnabás', '06201234567', '2021.06.07', 30, 3, 4),
        (4, 'Gipsz', 'Jakab', '06201234567', '2023.04.20', 0, 2, 1),
        (5, 'Iksz', 'Ipszilon', '06201234567', '2022.10.31', 26, 3, 2),
        (6, 'Róbert', 'Gida', '06201234567', '2021.03.21', 36, 1, 4),
        (7, 'Arany', 'Hal', '06201234567', '2022.05.14', 30, 2, 3),
        (8, 'Kecske', 'Gida', '06201234567', '2023.03.12', 0, 5, 1),
        (9, 'Mátyás', 'Király', '06201234567', '2022.09.08', 30, 4, 3),
        (10, 'Ferenc', 'József', '06201234567', '2023.01.10', 22, 3, 2)





--1. Listázzuk az egyes tanulókat (tanulo_id) a beiratkozás dátuma alapján, sorrenbde rendezve
--a. Jelenjen meg az eddigi óraszámuk is
--b. Mellé egy új oszlopban az elõttük beiratkozott három tanuló átlagórszáma is jelenjen meg egy új oszlopban.

select Tanulo_id, Eddigi_orak, 
		avg(Eddigi_orak) over(order by kezdes_datum rows between 5 preceding and 1 preceding) as 'Elõzõ 3 tanuló átlag óraszáma' 
from Tanulok 
order by Kezdes_datum


--2. Listázzuk a tanulók kódját és vezetéknevét, státusz alapján és hogy hányadikak helyen vannak az adott státuszban?

select t.Tanulo_id, t.Vezeteknev, st.Statusz, rank() over (partition by st.statusz order by kezdes_datum) as 'Státuszon belüli rang'
from Statuszok st join Tanulok t on t.Statusz_id = st.Statusz_id



--3. Hányan vezetik a különbözõ nem automata kocsikat? (akik levizsgáztak, õk már nem számítanak) 

select sz.Tipus, count(t.Tanulo_id) as 'Tanulószám'
from Tanulok t join Oktato o on t.Oktato_id = o.Oktato_id
				join Szgk sz on o.Rendszam = sz.Rendszam
				join Statuszok st on t.Statusz_id = st.Statusz_id
where sz.Automata_e = 0 and st.Statusz != 'Levizsgázott'
group by sz.Tipus


--4. Jelenítse meg a tanulók számát oktatók, és státuszok szerint. A részösszegek és végösszegek is látszódjanak!

select isnull(o.Vezeteknev + ' ' + o.Keresztnev, 'Végösszeg') as 'Oktató neve', isnull(st.Statusz, 'Részösszeg') as 'Státusz', count(t.Tanulo_id) 'Tanulók száma'
from Tanulok t join Oktato o on t.Oktato_id = o.Oktato_id
		join Statuszok st on t.Statusz_id = st.Statusz_id
group by rollup (o.Vezeteknev + ' ' + o.Keresztnev, st.Statusz)


--5. Ki az aki egy éven belül belül csatlakozott? Jelenjen meg a neve, a csatlakozás dátuma és az elõtte és utána csatlakozó dátuma, két külön oszlopban!

select Vezeteknev + ' ' + Keresztnev as 'Tanuló neve', Kezdes_datum,
			lag(Kezdes_datum) over (order by Kezdes_datum) as 'elõzõ csatlakozás', 
			LEAD(Kezdes_datum) over (order by Kezdes_datum) as 'következõ csatlakozás'
from Tanulok
where DATEDIFF(year, Kezdes_datum, getdate()) <= 1


--6. Ki az aki automata váltósat vezet és 2023-ban csatlakozott? (elég a tanuló id)


select t.Tanulo_id
from Tanulok t join Oktato o on t.Oktato_id = o.Oktato_id
				join Szgk sz on o.Rendszam = sz.Rendszam
where sz.Automata_e = 1

intersect

select Tanulo_id
from Tanulok
where year(Kezdes_datum) = 2023


--7. Melyek azok a tanulók, akik oktatójának keresztnevében nincsen a betû?

select t.*
from Tanulok t 
where not exists (
	select t2.*
	from Tanulok t2 join Oktato o on t2.Oktato_id = o.Oktato_id
	where o.Keresztnev like '%a%' and t.Oktato_id = t2.Oktato_id
)


--8. Helyszínek és rendszám alapján csoportosítsuk a tanulókat! 


select h.Helyszin_nev, o.Rendszam, count(t.Tanulo_id) as 'Tanulók száma'
from Tanulok t join Oktato o on t.Oktato_id = o.Oktato_id
				join Helyszinek h on  h.Helyszin_id = o.Helyszin_id
group by grouping sets (h.Helyszin_nev, o.Rendszam)


--9. Jelenítse meg, hogy az egyes kocsikkal (típus) vezetõ tanulók átlagosan hány órát vezettek már! 
--a. Csak a 30-nál kevesebb órát vevõ diákok legyenek figyelmbe véve! 

select sz.Tipus, avg(t.Eddigi_orak)
from Szgk sz join Oktato o on sz.Rendszam = o.Rendszam 
				join Tanulok t on o.Oktato_id = t.Oktato_id
where t.Eddigi_orak < 30
group by sz.Tipus


--10. Vezetett órák alapján ossza három részre a tanulókat!
-- a. A tanulók minden adata látszódjon, de csak azokat vegyük figyelembe akik még nem vizsgáztak!
-- b. Vezetett órák alapján lévõ csoport oszlopneve legyen 'Csoportbontás'!


select t.*, ntile(3) over (order by eddigi_orak) as 'Csoportbontás'
from Tanulok t join Statuszok s on t.Statusz_id = s.Statusz_id
where s.Statusz != 'Levizsgázott'


