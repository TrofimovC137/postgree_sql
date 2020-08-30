-- Прайсы
-- Создание и заполнение таблиц

CREATE TABLE goods_group(
	id SERIAL,
	name VARCHAR(255),
	PRIMARY KEY(id)
);
INSERT INTO goods_group(name)
	SELECT 'g '||FLOOR(random()*50)::VARCHAR(255)
	FROM GENERATE_SERIES(1, 10);
	
CREATE TABLE partner(
	id SERIAL,
	name VARCHAR(255),
	group_id INT REFERENCES goods_group(id),
	PRIMARY KEY(id));
INSERT INTO partner(name)
	SELECT 'p '||FLOOR(random()*50)::VARCHAR(255)
	FROM GENERATE_SERIES(1, 5);
	
CREATE TABLE partners_groups(
	id SERIAL,
	name VARCHAR(255),
	PRIMARY KEY(id)
);
INSERT INTO partners_groups(name) 
	SELECT 
  		'p group' || floor(random()*20):: varchar(255) 
	FROM generate_series(1, 3);

CREATE TABLE partners_groups_(
	id SERIAL,
	partner_group_id INT REFERENCES partners_groups(id),
	group_id INT REFERENCES goods_group(id),
	PRIMARY KEY(id)
);
INSERT INTO partners_groups_(partner_group_id, group_id)
	SELECT 
		(SELECT id FROM partners_groups WHERE link_flag > 0 ORDER BY  random() LIMIT 1),
        (SELECT id FROM goods_group WHERE link_flag > 0 ORDER BY  random() LIMIT 1)
	FROM generate_series(1, 10) link_flag;

CREATE TABLE goods(
	id SERIAL,
	name VARCHAR(255),
	group_id INT REFERENCES goods_group(id),
	PRIMARY KEY(id)
);
INSERT INTO goods(name, group_id)
	SELECT 
		('good '||x)::VARCHAR(255),
		(SELECT id FROM goods_group ORDER BY random() LIMIT 1)
	FROM generate_series(1, 10) x;
	
CREATE TABLE price_list(
	id SERIAL,
	name VARCHAR(255),
	PRIMARY KEY(id)
);
INSERT INTO price_list(name)
	SELECT 
		'price'||FLOOR(random()*50)::VARCHAR(255)
		FROM generate_series(1, 5);
		
CREATE TABLE price_list_(
	id SERIAL,
	price_list_id INT REFERENCES price_list(id),
	goods_id int REFERENCES goods(id),
	price decimal(18,4),
	ddate date,
	PRIMARY KEY(id) 
);
INSERT INTO price_list_(price_list_id, goods_id, price, ddate)
	SELECT
		(SELECT id FROM price_list where link_flag > 0 ORDER BY random() limit 1),
        (SELECT id FROM goods where link_flag > 0 ORDER BY random() limit 1),
         random()*1000,
         '2020-01-01'::date + link_flag
	FROM generate_series(1,31) link_flag;