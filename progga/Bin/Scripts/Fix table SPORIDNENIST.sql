delete from `SPORIDNENIST`
where (`ID` in (select
                    q.MIN_ID
                from (
                    select
                        min(s.`id`) MIN_ID,
                        count(s.`ID_TYP_SPORIDNENOSTI`),
                        s.`ID_HOSPODARSTVO`,
                        s.`ID_NASELENNIA_KHTO`,
                        s.`ID_NASELENNIA_KOMU`,
                        s.`ID_TYP_SPORIDNENOSTI`
                    from `SPORIDNENIST` s
                    group by 3, 4, 5, 6
                    having count(s.`ID_TYP_SPORIDNENOSTI`) > 1
                ) q ));

delete from `SPORIDNENIST`
where (`ID_NASELENNIA_KHTO` = `ID_NASELENNIA_KOMU`);

delete from `SPORIDNENIST`
where (`ID_NASELENNIA_KHTO` < 1);

delete from `SPORIDNENIST`
where (`ID_NASELENNIA_KOMU` < 1);