SELECT extract(year from recept.ddate) year_DATE, sum(recgoods.volume * recgoods.price) income_SUM, sum(goods.weight*recgoods.volume)
FROM recept
JOIN recgoods ON recept.id = recgoods.id
JOIN goods ON recgoods.id = goods.id
GROUP BY year_DATE