-- рекурсивный запрос на вывод дерева групп клиентов

WITH RECURSIVE t AS (
	SELECT 
		cg.id, 
		cg.name, 
		cg.parent, 
		cg_.name as parent_name
	FROM 
		client_groups cg 
		JOIN client_groups cg_ ON cg.id = cg_.parent
	UNION ALL 
		  SELECT 
				cg_.id, 
				cg_.name, 
				t.parent, 
				c_gp.name 
			FROM client_groups AS cg_ 
				JOIN t ON t.id = gg.parent
				JOIN client_groups c_gp ON c_gp.id = t.parent
)

SELECT DISTINCT 
	cl.id c_id,
	cl.name c_name,
	cl.client_groups g_id,
	g.name g_name
	FROM client cl 
		JOIN client_groups g ON cl.client_groups = g.id
UNION
SELECT
	cl.id,
	cl.name,
	t.parent,
	t.parent_name 
FROM client cl
	JOIN t ON t.id = cl.client_groups