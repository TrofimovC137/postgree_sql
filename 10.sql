-- рекурсивный запрос на вывод дерева групп товаров

with recursive tree (name, id, level, pathstr)
as (select name, id, 0, cast('' as text)
   from goods_groups
   where parent is null
union all
   select goods_groups.name, goods_groups.id, tree.level + 1, concat(tree.pathstr,goods_groups.name)
   from goods_groups
     inner join tree on tree.id = goods_groups.parent)
select id, concat(level, '→' , name) as name
from tree
order by pathstr