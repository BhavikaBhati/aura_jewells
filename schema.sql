CREATE DATABASE IF NOT EXISTS aura_jewells;
USE aura_jewells;
DROP TABLE IF EXISTS custom_orders,appointments,contact_messages,redemptions,gold_tx,gold_bookings,order_items,orders,price_history,rates,products,users;

CREATE TABLE users(
  id INT AUTO_INCREMENT PRIMARY KEY,
  cid VARCHAR(12) UNIQUE,
  name VARCHAR(80),
  email VARCHAR(90) UNIQUE,
  mobile VARCHAR(15),
  pw VARCHAR(255),
  is_admin TINYINT DEFAULT 0
);

CREATE TABLE products(
  code VARCHAR(8) PRIMARY KEY,
  name VARCHAR(90),
  cat VARCHAR(10),       -- gold / silver / diamond / gemstone
  type VARCHAR(12),       -- ring / necklace / earrings / bracelet / bangle / chain / anklet
  purity VARCHAR(2),      -- 24 / 22 / 18 / S
  weight DOUBLE,
  making DOUBLE,
  stone DOUBLE,
  stock INT,
  image VARCHAR(500) DEFAULT NULL,
  carat DOUBLE DEFAULT NULL,
  cut VARCHAR(20) DEFAULT NULL,
  clarity VARCHAR(10) DEFAULT NULL,
  colour VARCHAR(10) DEFAULT NULL,
  certificate VARCHAR(60) DEFAULT NULL,
  description VARCHAR(400) DEFAULT NULL,
  featured TINYINT DEFAULT 0,
  new_arrival TINYINT DEFAULT 0,
  on_sale TINYINT DEFAULT 0,
  sale_price DOUBLE DEFAULT NULL,
  created DATE DEFAULT NULL
);

CREATE TABLE rates(purity VARCHAR(2) PRIMARY KEY, price DOUBLE, updated DATETIME);
CREATE TABLE price_history(purity VARCHAR(2), d DATE, price DOUBLE, PRIMARY KEY(purity,d));

CREATE TABLE orders(
  id VARCHAR(14) PRIMARY KEY,
  cid VARCHAR(12),
  total DOUBLE,
  pay VARCHAR(30),
  pay_status VARCHAR(10),
  status VARCHAR(12) DEFAULT 'Pending',
  address VARCHAR(255),
  created DATE
);
CREATE TABLE order_items(
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id VARCHAR(14),
  code VARCHAR(8),
  qty INT,
  unit DOUBLE,
  FOREIGN KEY(order_id) REFERENCES orders(id)
);

CREATE TABLE gold_bookings(
  id VARCHAR(12) PRIMARY KEY,
  cid VARCHAR(12),
  purity VARCHAR(2),
  qty DOUBLE,
  used DOUBLE DEFAULT 0,
  rate DOUBLE,
  val DOUBLE,
  status VARCHAR(20) DEFAULT 'Active',
  created DATE
);
CREATE TABLE gold_tx(
  id INT AUTO_INCREMENT PRIMARY KEY,
  cid VARCHAR(12),
  type VARCHAR(12),
  ref VARCHAR(14),
  grams DOUBLE,
  created DATE
);
CREATE TABLE redemptions(
  id VARCHAR(10) PRIMARY KEY,
  cid VARCHAR(12),
  product VARCHAR(90),
  grams DOUBLE,
  extra DOUBLE,
  status VARCHAR(12),
  created DATE
);

CREATE TABLE contact_messages(
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80),
  email VARCHAR(90),
  message VARCHAR(1000),
  created DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE appointments(
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80),
  email VARCHAR(90),
  mobile VARCHAR(15),
  pdate DATE,
  ptime VARCHAR(10),
  purpose VARCHAR(200),
  created DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO rates VALUES('24',13400,NOW()),('22',12290,NOW()),('18',10050,NOW()),('S',165,NOW());

-- Gold (12 products)
INSERT INTO products (code,name,cat,type,purity,weight,making,stone,stock,carat,description,featured,new_arrival,on_sale,sale_price,created) VALUES
('GR01','Classic Gold Ring','gold','ring','22',5,6000,0,8,NULL,'A timeless everyday gold ring, hand-finished for a smooth luxurious feel.',1,0,0,NULL,'2026-06-01'),
('GR02','Floral Gold Ring','gold','ring','22',4.5,5500,0,10,NULL,'A delicate floral-pattern band, perfect for daily elegance.',0,0,1,9500,'2026-08-10'),
('GN01','Temple Gold Necklace','gold','necklace','22',22,14000,0,4,NULL,'Traditional temple-inspired design, a statement piece for special occasions.',1,0,0,NULL,'2026-05-15'),
('GN02','Layered Gold Necklace','gold','necklace','18',15,11000,0,6,NULL,'A modern layered chain necklace for everyday luxury.',0,1,0,NULL,'2026-09-22'),
('GE01','Jhumka Gold Earrings','gold','earrings','22',8,5000,1500,6,NULL,'Classic jhumka earrings with fine detailing and a light gemstone accent.',0,1,0,NULL,'2026-09-10'),
('GE02','Stud Gold Earrings','gold','earrings','22',3,3000,0,14,NULL,'Minimal gold studs for everyday wear.',0,0,1,6500,'2026-07-02'),
('GB01','Twisted Gold Bracelet','gold','bracelet','18',10,6000,0,5,NULL,'A modern twisted-rope bracelet in warm 18K gold.',0,0,0,NULL,'2026-04-20'),
('GB02','Charm Gold Bracelet','gold','bracelet','22',9,7000,0,7,NULL,'A playful charm bracelet with delicate links.',0,0,0,NULL,'2026-03-18'),
('GG01','Royal Gold Bangle','gold','bangle','22',18,10000,0,3,NULL,'Bold and regal, this bangle is crafted for celebration wear.',1,0,0,NULL,'2026-03-01'),
('GG02','Slim Gold Bangle Pair','gold','bangle','22',14,8000,0,5,NULL,'A pair of slim everyday bangles.',0,0,0,NULL,'2026-02-10'),
('GC01','Rope Gold Chain','gold','chain','24',12,7000,0,9,NULL,'Pure 24K rope chain, sold by weight.',0,1,0,NULL,'2026-09-20'),
('GC02','Box Gold Chain','gold','chain','22',10,6500,0,8,NULL,'A sturdy box-link chain, a versatile everyday piece.',0,0,0,NULL,'2026-06-18');

-- Silver (11 products)
INSERT INTO products (code,name,cat,type,purity,weight,making,stone,stock,description,featured,new_arrival,on_sale,sale_price,created) VALUES
('SR01','Silver Band Ring','silver','ring','S',8,400,0,20,'A minimal sterling silver band for daily wear.',0,0,0,NULL,'2026-02-11'),
('SR02','Oxidised Silver Ring','silver','ring','S',6,350,0,18,'A boho-style oxidised silver ring with intricate detailing.',0,0,1,1200,'2026-08-05'),
('SE01','Silver Drop Earrings','silver','earrings','S',6,350,0,15,'Lightweight drop earrings finished in polished sterling silver.',0,0,0,NULL,'2026-02-15'),
('SE02','Silver Hoop Earrings','silver','earrings','S',7,400,0,16,'Classic hoops that go with everything.',0,1,0,NULL,'2026-09-12'),
('SB01','Silver Link Bracelet','silver','bracelet','S',18,700,0,10,'A sturdy link bracelet with a secure lobster clasp.',0,1,0,NULL,'2026-09-05'),
('SB02','Beaded Silver Bracelet','silver','bracelet','S',12,500,0,12,'A delicate beaded bracelet, adjustable to fit.',0,0,0,NULL,'2026-05-22'),
('SA01','Silver Anklet Pair','silver','anklet','S',30,900,0,12,'A pair of delicate chain anklets with tiny charm bells.',1,0,0,NULL,'2026-01-20'),
('SA02','Beaded Silver Anklet','silver','anklet','S',20,600,0,14,'A single beaded anklet for a boho look.',0,0,0,NULL,'2026-04-14'),
('SN01','Silver Pendant Necklace','silver','necklace','S',14,800,0,9,'A simple pendant necklace in polished silver.',0,0,0,NULL,'2026-03-09'),
('SC01','Silver Curb Chain','silver','chain','S',16,700,0,11,'A durable curb-link chain in sterling silver.',0,0,0,NULL,'2026-06-02'),
('SG01','Silver Cuff Bangle','silver','bangle','S',22,1000,0,7,'An open-cuff bangle with a brushed matte finish.',0,0,0,NULL,'2026-07-19');

-- Diamond (10 products)
INSERT INTO products (code,name,cat,type,purity,weight,making,stone,stock,carat,cut,clarity,colour,certificate,description,featured,new_arrival,on_sale,sale_price,created) VALUES
('DR01','Solitaire Diamond Ring','diamond','ring','18',4,8000,60000,3,0.5,'Excellent','VS1','F','IGI Certified (demo)','A brilliant round solitaire set in 18K white gold.',1,0,0,NULL,'2026-06-25'),
('DR02','Halo Diamond Ring','diamond','ring','18',4.5,9000,72000,2,0.6,'Very Good','VS2','F','IGI Certified (demo)','A center stone surrounded by a sparkling halo.',0,0,1,95000,'2026-08-28'),
('DN01','Diamond Pendant Necklace','diamond','necklace','18',6,9000,45000,2,0.3,'Very Good','VS2','G','IGI Certified (demo)','A delicate pendant with a single sparkling diamond.',0,0,0,NULL,'2026-07-01'),
('DN02','Diamond Drop Necklace','diamond','necklace','18',7,10000,58000,2,0.4,'Excellent','SI1','F','IGI Certified (demo)','An elegant drop-style diamond necklace.',0,1,0,NULL,'2026-09-18'),
('DE01','Diamond Stud Earrings','diamond','earrings','18',3,5000,38000,5,0.25,'Excellent','VVS2','F','IGI Certified (demo)','Everyday diamond studs with brilliant-cut stones.',1,1,0,NULL,'2026-09-15'),
('DE02','Diamond Halo Earrings','diamond','earrings','18',3.5,6000,47000,3,0.3,'Very Good','VS1','G','IGI Certified (demo)','Halo-style earrings with extra sparkle.',0,0,0,NULL,'2026-05-30'),
('DB01','Diamond Tennis Bracelet','diamond','bracelet','18',9,12000,90000,1,1.2,'Very Good','SI1','G','IGI Certified (demo)','A classic tennis bracelet lined with round diamonds.',0,0,0,NULL,'2026-05-05'),
('DB02','Diamond Charm Bracelet','diamond','bracelet','18',6,8000,42000,2,0.35,'Excellent','VS2','F','IGI Certified (demo)','A delicate bracelet with scattered diamond charms.',0,0,0,NULL,'2026-04-11'),
('DG01','Diamond Eternity Bangle','diamond','bangle','18',10,13000,98000,1,1.0,'Very Good','SI2','G','IGI Certified (demo)','A continuous eternity band of round diamonds.',0,0,0,NULL,'2026-03-25'),
('DC01','Diamond Tennis Chain','diamond','chain','18',11,14000,110000,1,1.3,'Excellent','VS1','F','IGI Certified (demo)','A statement diamond line chain.',0,0,0,NULL,'2026-02-20');

-- Gemstone (10 products) -- priced using the mount's gold rate plus the gemstone charge in `stone`
INSERT INTO products (code,name,cat,type,purity,weight,making,stone,stock,description,featured,new_arrival,on_sale,sale_price,created) VALUES
('EM01','Emerald Halo Ring','gemstone','ring','18',4,6000,28000,4,'A rich green emerald set in a gold halo mount.',1,0,0,NULL,'2026-07-10'),
('RB01','Ruby Drop Earrings','gemstone','earrings','18',4.5,5500,25000,5,'Deep red rubies in a classic drop setting.',0,0,0,NULL,'2026-06-14'),
('SP01','Blue Sapphire Pendant','gemstone','necklace','18',5,6500,30000,3,'A royal blue sapphire pendant with a delicate chain.',0,1,0,NULL,'2026-09-08'),
('AM01','Amethyst Cocktail Ring','gemstone','ring','S',6,1200,6000,8,'A bold purple amethyst set in sterling silver.',0,0,1,6800,'2026-08-01'),
('TQ01','Turquoise Bangle','gemstone','bangle','S',16,1500,8000,6,'A statement bangle set with polished turquoise stones.',0,0,0,NULL,'2026-05-19'),
('OP01','Opal Stud Earrings','gemstone','earrings','18',3,3500,18000,7,'Iridescent opal studs with a soft rainbow shimmer.',0,1,0,NULL,'2026-09-25'),
('GT01','Garnet Tennis Bracelet','gemstone','bracelet','18',8,9000,32000,3,'A warm red garnet line bracelet.',0,0,0,NULL,'2026-04-05'),
('PL01','Pearl Strand Necklace','gemstone','necklace','S',20,2000,15000,5,'A classic strand of freshwater pearls.',1,0,0,NULL,'2026-03-14'),
('CT01','Citrine Drop Pendant','gemstone','necklace','18',4,5000,16000,6,'A sunny citrine pendant on a fine gold chain.',0,0,0,NULL,'2026-06-28'),
('AQ01','Aquamarine Earrings','gemstone','earrings','18',4,5500,22000,4,'Soft blue aquamarine earrings with a gold setting.',0,0,0,NULL,'2026-07-22');

-- === Added: collection tags, custom orders (v2 feature pack) ===
ALTER TABLE products
  ADD COLUMN wedding TINYINT DEFAULT 0,
  ADD COLUMN gifting TINYINT DEFAULT 0,
  ADD COLUMN mens TINYINT DEFAULT 0,
  ADD COLUMN kids TINYINT DEFAULT 0,
  ADD COLUMN daily_wear TINYINT DEFAULT 0;

CREATE TABLE custom_orders(
  id VARCHAR(12) PRIMARY KEY,
  cid VARCHAR(12),
  name VARCHAR(80),
  email VARCHAR(90),
  mobile VARCHAR(15),
  category VARCHAR(20),
  metal VARCHAR(10),
  budget VARCHAR(30),
  details VARCHAR(600),
  status VARCHAR(20) DEFAULT 'Received',
  created DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- === New products added to reach >=10 per jewellery type (v2 feature pack) ===
INSERT INTO products (code,name,cat,type,purity,weight,making,stone,stock,carat,cut,clarity,colour,certificate,description,featured,new_arrival,on_sale,sale_price,created,image) VALUES
('GR03','Men''s Signet Gold Ring','gold','ring','22',7,6500,0,10,NULL,NULL,NULL,NULL,NULL,'A bold signet ring crafted in warm 22K gold, designed for men.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1611955167811-4711904bb9f8?auto=format&fit=crop&w=800&q=80'),
('DR03','Bridal Diamond Ring','diamond','ring','18',5,11000,95000,2,0.8,'Excellent','VVS1','F','IGI Certified (demo)','A statement bridal solitaire with a brilliant-cut diamond.',1,0,0,NULL,'2026-09-29','https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=800&q=80'),
('GN03','Bridal Gold Necklace Set','gold','necklace','22',35,22000,0,2,NULL,NULL,NULL,NULL,NULL,'An elaborate bridal necklace set with matching earrings, for the big day.',0,1,0,NULL,'2026-09-29','https://images.unsplash.com/photo-1611107683227-e9060eccd846?auto=format&fit=crop&w=800&q=80'),
('SN02','Kids Butterfly Necklace','silver','necklace','S',5,300,0,16,NULL,NULL,NULL,NULL,NULL,'A playful butterfly-pendant necklace in soft sterling silver, sized for children.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?auto=format&fit=crop&w=800&q=80'),
('SE03','Kids Flower Stud Earrings','silver','earrings','S',2,250,0,20,NULL,NULL,NULL,NULL,NULL,'Tiny flower-shaped silver studs, gentle on young ears.',0,0,0,NULL,'2026-09-28','https://plus.unsplash.com/premium_photo-1681276169512-dd5bd94a8b49?auto=format&fit=crop&w=800&q=80'),
('GB03','Men''s Curb Gold Bracelet','gold','bracelet','22',14,8500,0,6,NULL,NULL,NULL,NULL,NULL,'A heavy curb-link bracelet in 22K gold, built for everyday men''s wear.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80'),
('SB03','Daily Wear Silver Bracelet','silver','bracelet','S',9,400,0,18,NULL,NULL,NULL,NULL,NULL,'A light, comfortable silver bracelet made for daily wear.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1645748655333-3179eba628be?auto=format&fit=crop&w=800&q=80'),
('DB03','Gifting Diamond Bracelet','diamond','bracelet','18',5,7000,36000,3,0.28,'Very Good','VS2','G','IGI Certified (demo)','A delicate diamond bracelet, beautifully boxed for gifting.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1645748655333-3179eba628be?auto=format&fit=crop&w=800&q=80'),
('GG03','Bridal Gold Bangle Set','gold','bangle','22',45,20000,0,2,NULL,NULL,NULL,NULL,NULL,'A set of ornately crafted bridal bangles for wedding ceremonies.',1,0,0,NULL,'2026-09-29','https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80'),
('GG04','Gifting Gold Bangle','gold','bangle','22',10,6000,0,9,NULL,NULL,NULL,NULL,NULL,'A single elegant gold bangle, perfectly sized for gifting.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80'),
('SG02','Daily Wear Silver Bangle','silver','bangle','S',14,650,0,15,NULL,NULL,NULL,NULL,NULL,'A light brushed-silver bangle for comfortable daily wear.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80'),
('DG02','Gifting Diamond Bangle','diamond','bangle','18',8,10000,70000,2,0.5,'Very Good','SI1','G','IGI Certified (demo)','A refined diamond bangle presented in a gift-ready box.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1645748655333-3179eba628be?auto=format&fit=crop&w=800&q=80'),
('KG01','Kids Gold Bangle','gold','bangle','22',6,3500,0,12,NULL,NULL,NULL,NULL,NULL,'A dainty gold bangle sized for children, smooth-edged and safe.',0,1,0,NULL,'2026-09-29','https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80'),
('GC03','Men''s Gold Chain','gold','chain','22',18,9500,0,7,NULL,NULL,NULL,NULL,NULL,'A thick, masculine gold chain designed for men.',0,0,0,NULL,'2026-09-28','https://plus.unsplash.com/premium_photo-1709033404514-c3953af680b4?auto=format&fit=crop&w=800&q=80'),
('GC04','Wedding Mangalsutra Chain','gold','chain','22',16,9000,0,5,NULL,NULL,NULL,NULL,NULL,'A traditional mangalsutra chain for wedding ceremonies.',0,0,0,NULL,'2026-09-29','https://plus.unsplash.com/premium_photo-1708958117373-5d354f07a61a?auto=format&fit=crop&w=800&q=80'),
('SC02','Daily Wear Silver Chain','silver','chain','S',12,500,0,16,NULL,NULL,NULL,NULL,NULL,'A fine, lightweight silver chain for everyday wear.',0,0,0,NULL,'2026-09-28','https://plus.unsplash.com/premium_photo-1757489874995-2f7c64b921ea?auto=format&fit=crop&w=800&q=80'),
('SC03','Kids Silver Chain','silver','chain','S',6,300,0,18,NULL,NULL,NULL,NULL,NULL,'A delicate, short silver chain sized for children.',0,0,0,NULL,'2026-09-28','https://plus.unsplash.com/premium_photo-1757489874995-2f7c64b921ea?auto=format&fit=crop&w=800&q=80'),
('DC02','Men''s Diamond Chain','diamond','chain','18',13,15000,120000,1,1.4,'Excellent','VS2','F','IGI Certified (demo)','A bold diamond-studded chain for men.',0,0,0,NULL,'2026-09-28','https://plus.unsplash.com/premium_photo-1708958117373-5d354f07a61a?auto=format&fit=crop&w=800&q=80'),
('GC05','Gifting Gold Chain','gold','chain','22',8,5500,0,11,NULL,NULL,NULL,NULL,NULL,'A slim gold chain, ideal as a gift.',0,0,0,NULL,'2026-09-28','https://plus.unsplash.com/premium_photo-1709033404514-c3953af680b4?auto=format&fit=crop&w=800&q=80'),
('GA01','Bridal Gold Payal','gold','anklet','22',24,12000,0,4,NULL,NULL,NULL,NULL,NULL,'Ornate bridal gold anklets (payal) with tiny bells, for wedding wear.',0,1,0,NULL,'2026-09-29','https://images.unsplash.com/photo-1627293509201-cd0c780043e6?auto=format&fit=crop&w=800&q=80'),
('SA03','Daily Wear Silver Anklet','silver','anklet','S',14,450,0,20,NULL,NULL,NULL,NULL,NULL,'A simple chain anklet made for everyday wear.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80'),
('SA04','Daily Wear Silver Anklet Pair','silver','anklet','S',18,550,0,16,NULL,NULL,NULL,NULL,NULL,'A comfortable pair of daily-wear silver anklets.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80'),
('SA05','Kids Silver Anklet','silver','anklet','S',8,300,0,20,NULL,NULL,NULL,NULL,NULL,'A small, safe silver anklet sized for children.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80'),
('SA06','Kids Silver Anklet Pair','silver','anklet','S',10,350,0,18,NULL,NULL,NULL,NULL,NULL,'A pair of lightweight silver anklets for kids, with tiny bells.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80'),
('DA01','Diamond Anklet','diamond','anklet','18',10,9000,55000,2,0.4,'Very Good','VS2','G','IGI Certified (demo)','A refined anklet lined with small round diamonds.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1645748655333-3179eba628be?auto=format&fit=crop&w=800&q=80'),
('GA02','Gifting Gold Anklet','gold','anklet','22',12,6500,0,10,NULL,NULL,NULL,NULL,NULL,'A graceful single gold anklet, gift-boxed.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1627293509201-cd0c780043e6?auto=format&fit=crop&w=800&q=80'),
('EM02','Turquoise Anklet','gemstone','anklet','S',12,1200,7000,8,NULL,NULL,NULL,NULL,NULL,'A playful anklet set with polished turquoise beads.',0,0,0,NULL,'2026-09-28','https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80');

-- === Real photos assigned to existing products (v2 feature pack) ===
UPDATE products SET image='https://images.unsplash.com/photo-1611955167811-4711904bb9f8?auto=format&fit=crop&w=800&q=80' WHERE code='GR01';
UPDATE products SET image='https://images.unsplash.com/photo-1611955167811-4711904bb9f8?auto=format&fit=crop&w=800&q=80' WHERE code='GR02';
UPDATE products SET image='https://images.unsplash.com/photo-1611107683227-e9060eccd846?auto=format&fit=crop&w=800&q=80' WHERE code='GN01';
UPDATE products SET image='https://images.unsplash.com/photo-1611107683227-e9060eccd846?auto=format&fit=crop&w=800&q=80' WHERE code='GN02';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1681276169512-dd5bd94a8b49?auto=format&fit=crop&w=800&q=80' WHERE code='GE01';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1681276169512-dd5bd94a8b49?auto=format&fit=crop&w=800&q=80' WHERE code='GE02';
UPDATE products SET image='https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80' WHERE code='GB01';
UPDATE products SET image='https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80' WHERE code='GB02';
UPDATE products SET image='https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80' WHERE code='GG01';
UPDATE products SET image='https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80' WHERE code='GG02';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1709033404514-c3953af680b4?auto=format&fit=crop&w=800&q=80' WHERE code='GC01';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1709033404514-c3953af680b4?auto=format&fit=crop&w=800&q=80' WHERE code='GC02';
UPDATE products SET image='https://images.unsplash.com/photo-1595538934869-503c9448981b?auto=format&fit=crop&w=800&q=80' WHERE code='SR01';
UPDATE products SET image='https://images.unsplash.com/photo-1595538934869-503c9448981b?auto=format&fit=crop&w=800&q=80' WHERE code='SR02';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1681276169512-dd5bd94a8b49?auto=format&fit=crop&w=800&q=80' WHERE code='SE01';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1681276169512-dd5bd94a8b49?auto=format&fit=crop&w=800&q=80' WHERE code='SE02';
UPDATE products SET image='https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80' WHERE code='SB01';
UPDATE products SET image='https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80' WHERE code='SB02';
UPDATE products SET image='https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80' WHERE code='SA01';
UPDATE products SET image='https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80' WHERE code='SA02';
UPDATE products SET image='https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?auto=format&fit=crop&w=800&q=80' WHERE code='SN01';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1757489874995-2f7c64b921ea?auto=format&fit=crop&w=800&q=80' WHERE code='SC01';
UPDATE products SET image='https://images.unsplash.com/photo-1744189424749-2064fba7f06e?auto=format&fit=crop&w=800&q=80' WHERE code='SG01';
UPDATE products SET image='https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=800&q=80' WHERE code='DR01';
UPDATE products SET image='https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=800&q=80' WHERE code='DR02';
UPDATE products SET image='https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?auto=format&fit=crop&w=800&q=80' WHERE code='DN01';
UPDATE products SET image='https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?auto=format&fit=crop&w=800&q=80' WHERE code='DN02';
UPDATE products SET image='https://images.unsplash.com/photo-1714700513036-558227ceabc4?auto=format&fit=crop&w=800&q=80' WHERE code='DE01';
UPDATE products SET image='https://images.unsplash.com/photo-1714700513036-558227ceabc4?auto=format&fit=crop&w=800&q=80' WHERE code='DE02';
UPDATE products SET image='https://images.unsplash.com/photo-1645748655333-3179eba628be?auto=format&fit=crop&w=800&q=80' WHERE code='DB01';
UPDATE products SET image='https://images.unsplash.com/photo-1645748655333-3179eba628be?auto=format&fit=crop&w=800&q=80' WHERE code='DB02';
UPDATE products SET image='https://images.unsplash.com/photo-1645748655333-3179eba628be?auto=format&fit=crop&w=800&q=80' WHERE code='DG01';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1708958117373-5d354f07a61a?auto=format&fit=crop&w=800&q=80' WHERE code='DC01';
UPDATE products SET image='https://images.unsplash.com/photo-1551346261-e19dd7ae9587?auto=format&fit=crop&w=800&q=80' WHERE code='EM01';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1681276169512-dd5bd94a8b49?auto=format&fit=crop&w=800&q=80' WHERE code='RB01';
UPDATE products SET image='https://images.unsplash.com/photo-1654699991520-aaaf4dd2608b?auto=format&fit=crop&w=800&q=80' WHERE code='SP01';
UPDATE products SET image='https://images.unsplash.com/photo-1551346261-e19dd7ae9587?auto=format&fit=crop&w=800&q=80' WHERE code='AM01';
UPDATE products SET image='https://images.unsplash.com/photo-1709295208567-ce817387e977?auto=format&fit=crop&w=800&q=80' WHERE code='TQ01';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1681276169512-dd5bd94a8b49?auto=format&fit=crop&w=800&q=80' WHERE code='OP01';
UPDATE products SET image='https://images.unsplash.com/photo-1645748655333-3179eba628be?auto=format&fit=crop&w=800&q=80' WHERE code='GT01';
UPDATE products SET image='https://images.unsplash.com/photo-1654699991520-aaaf4dd2608b?auto=format&fit=crop&w=800&q=80' WHERE code='PL01';
UPDATE products SET image='https://images.unsplash.com/photo-1654699991520-aaaf4dd2608b?auto=format&fit=crop&w=800&q=80' WHERE code='CT01';
UPDATE products SET image='https://plus.unsplash.com/premium_photo-1681276169512-dd5bd94a8b49?auto=format&fit=crop&w=800&q=80' WHERE code='AQ01';

-- === Collection tagging: wedding/gifting/mens/kids/daily_wear (v2 feature pack) ===
UPDATE products SET wedding=1 WHERE code IN ('GN03','DR03','GG03','GC04','GA01','GN01','GG01','DB01','DN02','PL01');
UPDATE products SET gifting=1 WHERE code IN ('GG04','DB03','GC05','GA02','GE02','SE01','AM01','CT01','RB01','SB02');
UPDATE products SET mens=1 WHERE code IN ('GR03','GB03','GC03','DC02','SC01','GC01','GC02','SR01','GT01','SB01');
UPDATE products SET kids=1 WHERE code IN ('SN02','SE03','KG01','SC03','SA05','SA06','SE02','SA02','OP01','EM02');
UPDATE products SET daily_wear=1 WHERE code IN ('SB03','SG02','SC02','SA03','SA04','GE02','SE01','GB02','GC02','SN01');

-- === Bump featured/new_arrival so Featured Collection & New Arrivals each have >=10 (v2 feature pack) ===
UPDATE products SET featured=1 WHERE code IN ('GG03','DR03');
UPDATE products SET new_arrival=1 WHERE code IN ('GN03','KG01');
