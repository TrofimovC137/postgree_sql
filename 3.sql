SELECT city.name, income.ddate, income.ndoc, 
goods_groops.name, goods.name,
(goods.length * goods.height * goods.width * incgoods.volume) as VOLUME

FROM income
JOIN clients ON clients.id = income.client
JOIN city ON clients.city = city.id
JOIN incgoods ON incgoods.id = recept.id
JOIN goods ON goods.id = incgoods.goods
JOIN goods_groups ON goods.groups.id = goods.g_groups
WHERE month(income.ddate) in (4, 5, 6) AND 
  year(income.ddate) = 2020 AND
  VOLUME > 10