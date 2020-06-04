CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar,
  "email" varchar,
  "password" varchar,
  "created_at" timestamp
);

CREATE TABLE "items" (
  "id" SERIAL PRIMARY KEY,
  "item_name" varchar,
  "detail" varchar,
  "chain_id" int,
  "created_by" int,
  "created_at" timestamp,
  "status_id" int,
  "status_changed_by" int,
  "status_changed_at" timestamp,
  "status_changed_in" int
);

CREATE TABLE "chains" (
  "id" SERIAL PRIMARY KEY,
  "chain_name" varchar
);

CREATE TABLE "status" (
  "id" SERIAL PRIMARY KEY,
  "status_name" varchar
);

CREATE TABLE "stores" (
  "id" SERIAL PRIMARY KEY,
  "chain_id" int,
  "branch" varchar,
  "latitude" float,
  "longitude" float
);

ALTER TABLE "items" ADD FOREIGN KEY ("chain_id") REFERENCES "chains" ("id");

ALTER TABLE "items" ADD FOREIGN KEY ("created_by") REFERENCES "users" ("id");

ALTER TABLE "items" ADD FOREIGN KEY ("status_id") REFERENCES "status" ("id");

ALTER TABLE "items" ADD FOREIGN KEY ("status_changed_by") REFERENCES "users" ("id");

ALTER TABLE "items" ADD FOREIGN KEY ("status_changed_in") REFERENCES "stores" ("id");

ALTER TABLE "stores" ADD FOREIGN KEY ("chain_id") REFERENCES "chains" ("id");
