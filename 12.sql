SELECT 
	recept.id, 
	recept.ddate, 
	recgoods.goods, 
	recept.client,
	recgoods.volume * recgoods.price, 
	AVG(recgoods.volume * recgoods.price)
OVER (PARTITION BY date_part('month', recept.ddate), recgoods.goods) average_summ,
SUM(recgoods.volume * recgoods.price) OVER (ORDER BY recept.ddate) itog
FROM recept
	JOIN recgoods ON recept.id = recgoods.id