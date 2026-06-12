ALTER TABLE book_copies 
ADD COLUMN area VARCHAR(50) NULL COMMENT 'Khu vực (Tầng 1, Tầng 2...)',
ADD COLUMN shelf VARCHAR(20) NULL COMMENT 'Kệ (K01, K02...)',
ADD COLUMN slot VARCHAR(20) NULL COMMENT 'Ngăn (N01, N02...)';
-- Tầng 1 - Khu Khoa học tự nhiên (id 1-200)
UPDATE book_copies SET area='Tầng 1', shelf='K01', slot='N01' WHERE id BETWEEN 1 AND 25;
UPDATE book_copies SET area='Tầng 1', shelf='K01', slot='N02' WHERE id BETWEEN 26 AND 50;
UPDATE book_copies SET area='Tầng 1', shelf='K02', slot='N01' WHERE id BETWEEN 51 AND 75;
UPDATE book_copies SET area='Tầng 1', shelf='K02', slot='N02' WHERE id BETWEEN 76 AND 100;
UPDATE book_copies SET area='Tầng 1', shelf='K03', slot='N01' WHERE id BETWEEN 101 AND 125;
UPDATE book_copies SET area='Tầng 1', shelf='K03', slot='N02' WHERE id BETWEEN 126 AND 150;
UPDATE book_copies SET area='Tầng 1', shelf='K04', slot='N01' WHERE id BETWEEN 151 AND 175;
UPDATE book_copies SET area='Tầng 1', shelf='K04', slot='N02' WHERE id BETWEEN 176 AND 200;

-- Tầng 1 - Khu Công nghệ thông tin (id 201-400)
UPDATE book_copies SET area='Tầng 1', shelf='K05', slot='N01' WHERE id BETWEEN 201 AND 225;
UPDATE book_copies SET area='Tầng 1', shelf='K05', slot='N02' WHERE id BETWEEN 226 AND 250;
UPDATE book_copies SET area='Tầng 1', shelf='K06', slot='N01' WHERE id BETWEEN 251 AND 275;
UPDATE book_copies SET area='Tầng 1', shelf='K06', slot='N02' WHERE id BETWEEN 276 AND 300;
UPDATE book_copies SET area='Tầng 1', shelf='K07', slot='N01' WHERE id BETWEEN 301 AND 325;
UPDATE book_copies SET area='Tầng 1', shelf='K07', slot='N02' WHERE id BETWEEN 326 AND 350;
UPDATE book_copies SET area='Tầng 1', shelf='K08', slot='N01' WHERE id BETWEEN 351 AND 375;
UPDATE book_copies SET area='Tầng 1', shelf='K08', slot='N02' WHERE id BETWEEN 376 AND 400;

-- Tầng 2 - Khu Kinh tế (id 401-600)
UPDATE book_copies SET area='Tầng 2', shelf='K01', slot='N01' WHERE id BETWEEN 401 AND 425;
UPDATE book_copies SET area='Tầng 2', shelf='K01', slot='N02' WHERE id BETWEEN 426 AND 450;
UPDATE book_copies SET area='Tầng 2', shelf='K02', slot='N01' WHERE id BETWEEN 451 AND 475;
UPDATE book_copies SET area='Tầng 2', shelf='K02', slot='N02' WHERE id BETWEEN 476 AND 500;
UPDATE book_copies SET area='Tầng 2', shelf='K03', slot='N01' WHERE id BETWEEN 501 AND 525;
UPDATE book_copies SET area='Tầng 2', shelf='K03', slot='N02' WHERE id BETWEEN 526 AND 550;
UPDATE book_copies SET area='Tầng 2', shelf='K04', slot='N01' WHERE id BETWEEN 551 AND 575;
UPDATE book_copies SET area='Tầng 2', shelf='K04', slot='N02' WHERE id BETWEEN 576 AND 600;

-- Tầng 2 - Khu Ngoại ngữ (id 601-800)
UPDATE book_copies SET area='Tầng 2', shelf='K05', slot='N01' WHERE id BETWEEN 601 AND 625;
UPDATE book_copies SET area='Tầng 2', shelf='K05', slot='N02' WHERE id BETWEEN 626 AND 650;
UPDATE book_copies SET area='Tầng 2', shelf='K06', slot='N01' WHERE id BETWEEN 651 AND 675;
UPDATE book_copies SET area='Tầng 2', shelf='K06', slot='N02' WHERE id BETWEEN 676 AND 700;
UPDATE book_copies SET area='Tầng 2', shelf='K07', slot='N01' WHERE id BETWEEN 701 AND 725;
UPDATE book_copies SET area='Tầng 2', shelf='K07', slot='N02' WHERE id BETWEEN 726 AND 750;
UPDATE book_copies SET area='Tầng 2', shelf='K08', slot='N01' WHERE id BETWEEN 751 AND 775;
UPDATE book_copies SET area='Tầng 2', shelf='K08', slot='N02' WHERE id BETWEEN 776 AND 800;

-- Tầng 3 - Khu Khoa học xã hội (id 801-1000)
UPDATE book_copies SET area='Tầng 3', shelf='K01', slot='N01' WHERE id BETWEEN 801 AND 825;
UPDATE book_copies SET area='Tầng 3', shelf='K01', slot='N02' WHERE id BETWEEN 826 AND 850;
UPDATE book_copies SET area='Tầng 3', shelf='K02', slot='N01' WHERE id BETWEEN 851 AND 875;
UPDATE book_copies SET area='Tầng 3', shelf='K02', slot='N02' WHERE id BETWEEN 876 AND 900;
UPDATE book_copies SET area='Tầng 3', shelf='K03', slot='N01' WHERE id BETWEEN 901 AND 925;
UPDATE book_copies SET area='Tầng 3', shelf='K03', slot='N02' WHERE id BETWEEN 926 AND 950;
UPDATE book_copies SET area='Tầng 3', shelf='K04', slot='N01' WHERE id BETWEEN 951 AND 975;
UPDATE book_copies SET area='Tầng 3', shelf='K04', slot='N02' WHERE id BETWEEN 976 AND 1000;