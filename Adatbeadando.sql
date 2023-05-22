create table Szgk(
��� Rendszam varchar(7) primary key,
��� Tipus varchar(50) not null,�
��� Automata_e bit not null
)

�

create table Statuszok(
��� Statusz_id int primary key,
��� Statusz varchar(50) not null
)

�

create table Helyszinek(
��� Helyszin_id int primary key,
��� Helyszin_nev varchar(50) not null
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
values (1, 'Oktat�ra v�r'),
		(2, 'Vezet�s folyamatban'),
		(3, 'Vizsga el�tt �ll'),
		(4, 'Levizsg�zott')


insert into Helyszinek(Helyszin_id, Helyszin_nev)
values (1, 'Budapest'),
		(2, 'Szeged'),
		(3, 'Kaposv�r')


insert into Oktato(Oktato_id, Rendszam, Vezeteknev, Keresztnev, Telefon, Helyszin_id)
values (1, 'ABC-123', 'H�s', 'Leves', '06201234567', 1),
������� (2, 'LMP-324', 'Benedek', 'Elek', '06201234567', 2),
������� (3, 'LMP-324', 'Csirke', 'P�rk�lt', '06201234567', 2),
������� (4, 'ABC-123', 'Cinka', 'Panka', '06201234567', 1),
������� (5, 'MMM-765', 'Leves', 'Kocka', '06201234567', 3)


insert into Tanulok (Tanulo_id, Vezeteknev, Keresztnev, Telefon, Kezdes_datum, Eddigi_orak, Oktato_id, Statusz_id)
values(1, 'Bern�th', 'Fl�ra', '06201234567', '2023.02.03', 20, 2, 2),
������� (2, 'Tasn�di-Tulogdi', 'Zs�fia', '06201234567', '2021.12.20', 33, 3, 4),
������� (3, 'Epres', 'Barnab�s', '06201234567', '2021.06.07', 30, 3, 4),
������� (4, 'Gipsz', 'Jakab', '06201234567', '2023.04.20', 0, 2, 1),
������� (5, 'Iksz', 'Ipszilon', '06201234567', '2022.10.31', 26, 3, 2),
������� (6, 'R�bert', 'Gida', '06201234567', '2021.03.21', 36, 1, 4),
������� (7, 'Arany', 'Hal', '06201234567', '2022.05.14', 30, 2, 3),
������� (8, 'Kecske', 'Gida', '06201234567', '2023.03.12', 0, 5, 1),
������� (9, 'M�ty�s', 'Kir�ly', '06201234567', '2022.09.08', 30, 4, 3),
������� (10, 'Ferenc', 'J�zsef', '06201234567', '2023.01.10', 22, 3, 2)





--1. List�zzuk az egyes tanul�kat (tanulo_id) a beiratkoz�s d�tuma alapj�n, sorrenbde rendezve
--a. Jelenjen meg az eddigi �rasz�muk is
--b. Mell� egy �j oszlopban az el�tt�k beiratkozott h�rom tanul� �tlag�rsz�ma is jelenjen meg egy �j oszlopban.

select Tanulo_id, Eddigi_orak, 
		avg(Eddigi_orak) over(order by kezdes_datum rows between 5 preceding and 1 preceding) as 'El�z� 3 tanul� �tlag �rasz�ma' 
from Tanulok 
order by Kezdes_datum


--2. List�zzuk a tanul�k k�dj�t �s vezet�knev�t, st�tusz alapj�n �s hogy h�nyadikak helyen vannak az adott st�tuszban?

select t.Tanulo_id, t.Vezeteknev, st.Statusz, rank() over (partition by st.statusz order by kezdes_datum) as 'St�tuszon bel�li rang'
from Statuszok st join Tanulok t on t.Statusz_id = st.Statusz_id



--3. H�nyan vezetik a k�l�nb�z� nem automata kocsikat? (akik levizsg�ztak, �k m�r nem sz�m�tanak) 

select sz.Tipus, count(t.Tanulo_id) as 'Tanul�sz�m'
from Tanulok t join Oktato o on t.Oktato_id = o.Oktato_id
				join Szgk sz on o.Rendszam = sz.Rendszam
				join Statuszok st on t.Statusz_id = st.Statusz_id
where sz.Automata_e = 0 and st.Statusz != 'Levizsg�zott'
group by sz.Tipus


--4. Jelen�tse meg a tanul�k sz�m�t oktat�k, �s st�tuszok szerint. A r�sz�sszegek �s v�g�sszegek is l�tsz�djanak!

select isnull(o.Vezeteknev + ' ' + o.Keresztnev, 'V�g�sszeg') as 'Oktat� neve', isnull(st.Statusz, 'R�sz�sszeg') as 'St�tusz', count(t.Tanulo_id) 'Tanul�k sz�ma'
from Tanulok t join Oktato o on t.Oktato_id = o.Oktato_id
		join Statuszok st on t.Statusz_id = st.Statusz_id
group by rollup (o.Vezeteknev + ' ' + o.Keresztnev, st.Statusz)


--5. Ki az aki egy �ven bel�l bel�l csatlakozott? Jelenjen meg a neve, a csatlakoz�s d�tuma �s az el�tte �s ut�na csatlakoz� d�tuma, k�t k�l�n oszlopban!

select Vezeteknev + ' ' + Keresztnev as 'Tanul� neve', Kezdes_datum,
			lag(Kezdes_datum) over (order by Kezdes_datum) as 'el�z� csatlakoz�s', 
			LEAD(Kezdes_datum) over (order by Kezdes_datum) as 'k�vetkez� csatlakoz�s'
from Tanulok
where DATEDIFF(year, Kezdes_datum, getdate()) <= 1


--6. Ki az aki automata v�lt�sat vezet �s 2023-ban csatlakozott? (el�g a tanul� id)


select t.Tanulo_id
from Tanulok t join Oktato o on t.Oktato_id = o.Oktato_id
				join Szgk sz on o.Rendszam = sz.Rendszam
where sz.Automata_e = 1

intersect

select Tanulo_id
from Tanulok
where year(Kezdes_datum) = 2023


--7. Melyek azok a tanul�k, akik oktat�j�nak keresztnev�ben nincsen a bet�?

select t.*
from Tanulok t 
where not exists (
	select t2.*
	from Tanulok t2 join Oktato o on t2.Oktato_id = o.Oktato_id
	where o.Keresztnev like '%a%' and t.Oktato_id = t2.Oktato_id
)


--8. Helysz�nek �s rendsz�m alapj�n csoportos�tsuk a tanul�kat! 


select h.Helyszin_nev, o.Rendszam, count(t.Tanulo_id) as 'Tanul�k sz�ma'
from Tanulok t join Oktato o on t.Oktato_id = o.Oktato_id
				join Helyszinek h on  h.Helyszin_id = o.Helyszin_id
group by grouping sets (h.Helyszin_nev, o.Rendszam)


--9. Jelen�tse meg, hogy az egyes kocsikkal (t�pus) vezet� tanul�k �tlagosan h�ny �r�t vezettek m�r! 
--a. Csak a 30-n�l kevesebb �r�t vev� di�kok legyenek figyelmbe v�ve! 

select sz.Tipus, avg(t.Eddigi_orak)
from Szgk sz join Oktato o on sz.Rendszam = o.Rendszam 
				join Tanulok t on o.Oktato_id = t.Oktato_id
where t.Eddigi_orak < 30
group by sz.Tipus


--10. Vezetett �r�k alapj�n ossza h�rom r�szre a tanul�kat!
-- a. A tanul�k minden adata l�tsz�djon, de csak azokat vegy�k figyelembe akik m�g nem vizsg�ztak!
-- b. Vezetett �r�k alapj�n l�v� csoport oszlopneve legyen 'Csoportbont�s'!


select t.*, ntile(3) over (order by eddigi_orak) as 'Csoportbont�s'
from Tanulok t join Statuszok s on t.Statusz_id = s.Statusz_id
where s.Statusz != 'Levizsg�zott'


