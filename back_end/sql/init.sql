Begin;

DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users(
	user_id serial not null,
	username text not null unique,
	nombre text,
	ssap text,
	sec_question text,
	sec_answer text,
	activation_code text,
	mail text,
	active boolean default true,
	blocked boolean default false,
	admin_user boolean default false,
	blocked_on timestamp,
	blocked_by text,
	created_on timestamp default now(),
	primary key (user_id)
);

CREATE INDEX idx_user ON users ( username );

DROP TABLE IF EXISTS categories cascade;
CREATE TABLE categories(
	id serial not null,
	category text,
	primary key (id)
);

DROP TABLE IF EXISTS tags cascade;
CREATE TABLE tags(
	id serial not null,
	tag text,
	primary key (id)
);

Drop table if exists recipes cascade;
Create table recipes(
	id serial not null,
	short_description text,
	portion_size int,
	author text,
	created_on timestamp default now(),
	created_by text,
	last_modified_on timestamp default now(),
	last_modified_by text,
	imgUrl text,
	img json default '{"name":null,"size":null,"uuidName":null}',
	imgFt text,
	preparacion text,
	source text,
	rate int,
	dificult text,
	time_preparation time,
	--"tags": "meat,pie,Canadian food",
	category_id int,
	primary key (id),
	foreign key (category_id) REFERENCES categories(id) ON UPDATE CASCADE,
	constraint chk_portion CHECK (portion_size > 0),
	constraint chk_rate CHECK ( rate >= 0 and rate <=5)
);

DROP TABLE IF EXISTS tag_recipe CASCADE;
CREATE TABLE tag_recipe(
	recipe_id int,
	tag_id int,
	primary key(recipe_id, tag_id),
	foreign key (tag_id) REFERENCES tags (id) ON DELETE CASCADE,
	foreign key (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
);

COMMIT;
