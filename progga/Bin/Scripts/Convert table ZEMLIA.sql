update `ZEMLIA` z
set
    z.`ID` = -1 * z.`ID`;

alter table `ZEMLIA` engine=innodb, auto_increment = 1;

-- Особисте сільське господарство
insert into `ZEMLIA`(`ID_NASELENNIA`, `ID_TYP_ZEMLI`, `PLOSHCHA`)
select
    z.`ID_NASELENNIA`,
    1       ID_TYP_ZEMLI,
    z.`OSG` PLOSHCHA
from `ZEMLIA` z
where (1 = 1)
  and (z.`OSG` > 0);

-- Підсобне господарство
insert into `ZEMLIA`(`ID_NASELENNIA`, `ID_TYP_ZEMLI`, `PLOSHCHA`)
select
    z.`ID_NASELENNIA`,
    2                         ID_TYP_ZEMLI,
    z.`PIDSOBNE_GOSPODARSTVO` PLOSHCHA
from `ZEMLIA` z
where (1 = 1)
  and (z.`PIDSOBNE_GOSPODARSTVO` > 0);

-- Житлове будівництво
insert into `ZEMLIA`(`ID_NASELENNIA`, `ID_TYP_ZEMLI`, `PLOSHCHA`)
select
    z.`ID_NASELENNIA`,
    3                         ID_TYP_ZEMLI,
    z.`ZHYTLOVE_BUDIVNYTSTVO` PLOSHCHA
from `ZEMLIA` z
where (1 = 1)
  and (z.`ZHYTLOVE_BUDIVNYTSTVO` > 0);

-- Паї
insert into `ZEMLIA`(`ID_NASELENNIA`, `ID_TYP_ZEMLI`, `PLOSHCHA`)
select
    z.`ID_NASELENNIA`,
    4       ID_TYP_ZEMLI,
    z.`PAI` PLOSHCHA
from `ZEMLIA` z
where (1 = 1)
  and (z.`PAI` > 0);

-- Сад
insert into `ZEMLIA`(`ID_NASELENNIA`, `ID_TYP_ZEMLI`, `PLOSHCHA`)
select
    z.`ID_NASELENNIA`,
    5       ID_TYP_ZEMLI,
    z.`SAD` PLOSHCHA
from `ZEMLIA` z
where (1 = 1)
  and (z.`SAD` > 0);

-- Сіно
insert into `ZEMLIA`(`ID_NASELENNIA`, `ID_TYP_ZEMLI`, `PLOSHCHA`)
select
    z.`ID_NASELENNIA`,
    6        ID_TYP_ZEMLI,
    z.`SINO` PLOSHCHA
from `ZEMLIA` z
where (1 = 1)
  and (z.`SINO` > 0);

-- Город
insert into `ZEMLIA`(`ID_NASELENNIA`, `ID_TYP_ZEMLI`, `PLOSHCHA`)
select
    z.`ID_NASELENNIA`,
    7         ID_TYP_ZEMLI,
    z.`GOROD` PLOSHCHA
from `ZEMLIA` z
where (1 = 1)
  and (z.`GOROD` > 0);

-- Худоба
insert into `ZEMLIA`(`ID_NASELENNIA`, `ID_TYP_ZEMLI`, `PLOSHCHA`)
select
    z.`ID_NASELENNIA`,
    8          ID_TYP_ZEMLI,
    z.`HUDOBA` PLOSHCHA
from `ZEMLIA` z
where (1 = 1)
  and (z.`HUDOBA` > 0);

delete from `ZEMLIA`
where (1 = 1)
  and (`ID` < 0);