-- ============================================================================
-- PHẦN 1: DỌN SẠCH DỮ LIỆU CŨ ĐỂ TRÁNH TRÙNG LẶP KHÓA NGOẠI
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE user_tokens;
TRUNCATE TABLE user_memberships;
TRUNCATE TABLE notifications;
TRUNCATE TABLE fines;
TRUNCATE TABLE borrow_records;
TRUNCATE TABLE book_reviews;
TRUNCATE TABLE book_reservations;
TRUNCATE TABLE book_copies;
TRUNCATE TABLE book_authors;
TRUNCATE TABLE books;
TRUNCATE TABLE categories;
TRUNCATE TABLE authors;
TRUNCATE TABLE membership_tiers;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- PHẦN 2: CHÈN DỮ LIỆU CHO CÁC BẢNG DANH MỤC CẤU HÌNH CỐ ĐỊNH
-- ============================================================================

-- 1. Hạng thành viên (Membership Tiers)
INSERT INTO membership_tiers (id, name, level, min_books_borrowed, max_borrow_days, max_simultaneous_borrows,
                              fine_discount_percent, benefits_description)
VALUES (1, 'Đồng', 'BRONZE', 0, 14, 3, 0.00, 'Hạng mặc định cho thành viên mới đăng ký'),
       (2, 'Bạc', 'SILVER', 10, 21, 5, 15.00, 'Giảm 15% tiền phạt quá hạn, mượn tối đa 5 quyển'),
       (3, 'Vàng', 'GOLD', 30, 30, 7, 30.00, 'Giảm 30% tiền phạt quá hạn, mượn tối đa 7 quyển'),
       (4, 'Kim Cương', 'PLATINUM', 60, 45, 10, 50.00, 'Ưu đãi cao nhất: Giảm 50% tiền phạt, mượn tối đa 10 quyển');

-- 2. Danh mục sách (Categories)
INSERT INTO categories (id, name, description)
VALUES (1, 'Khoa học & Công nghệ', 'Sách về công nghệ thông tin, trí tuệ nhân tạo và khoa học máy tính'),
       (2, 'Kinh tế & Quản trị', 'Sách kỹ năng kinh doanh, khởi nghiệp và quản trị tài chính doanh nghiệp'),
       (3, 'Văn học & Nghệ thuật', 'Tiểu thuyết, truyện ngắn, thơ ca nội địa và quốc tế nổi tiếng'),
       (4, 'Tâm lý & Kỹ năng sống', 'Sách phát triển bản thân, tư duy tích cực và tâm lý học hành vi'),
       (5, 'Lịch sử & Triết học', 'Nghiên cứu lịch sử Việt Nam, thế giới và các học thuyết triết học');


-- ============================================================================
-- PHẦN 3: ĐỊNH NGHĨA CÁC STORED PROCEDURE ĐỂ SINH DỮ LIỆU ĐỘNG VỚI QUY MÔ LỚN
-- ============================================================================

DELIMITER $$

-- ----------------------------------------------------------------------------
-- 1. Thủ tục sinh 40 tác giả Độc nhất (Sửa lỗi trùng lặp Unique Name hoàn toàn)
-- ----------------------------------------------------------------------------
CREATE PROCEDURE DynamicSeedAuthors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE ho VARCHAR(50);
    DECLARE dem VARCHAR(50);
    DECLARE ten VARCHAR(50);
    DECLARE quoc_tich VARCHAR(50);
    DECLARE ten_chinh_thuc VARCHAR(150);

    WHILE i <= 40
        DO
            -- Phân cụm giá trị i để bẻ gãy tính tuần hoàn lặp chuỗi của hàm ELT, kết hợp thêm hậu tố biến số i
            IF i <= 10 THEN
                SET ho = ELT(1 + (i % 4), 'John', 'Robert', 'William', 'David');
                SET dem = ELT(1 + (i % 3), 'J.', 'M.', 'K.');
                SET ten = ELT(1 + (i % 4), 'Smith', 'Johnson', 'Brown', 'Miller');
                SET quoc_tich = 'Mỹ';
                SET ten_chinh_thuc =
                        TRIM(CONCAT(ho, ' ', dem, ' ', ten, ' ', ELT(1 + (i % 3), 'I', 'II', 'Jr.'), ' (A-', i, ')'));

            ELSEIF i > 10 AND i <= 20 THEN
                SET ho = ELT(1 + (i % 3), 'Haruki', 'Keigo', 'Ichiro');
                SET dem = '';
                SET ten = ELT(1 + (i % 3), 'Murakami', 'Higashino', 'Kishimi');
                SET quoc_tich = 'Nhật Bản';
                SET ten_chinh_thuc = CONCAT(ho, ' ', ten, ' (Mã ', i, ')');

            ELSEIF i > 20 AND i <= 30 THEN
                SET ho = ELT(1 + (i % 5), 'Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng');
                SET dem = ELT(1 + (i % 4), 'Nhật', 'Đặng', 'Hoàng', 'Văn');
                SET ten = ELT(1 + (i % 5), 'Ánh', 'Khoa', 'Giang', 'Bình', 'Sơn');
                SET quoc_tich = 'Việt Nam';
                SET ten_chinh_thuc = CONCAT(ho, ' ', dem, ' ', ten, ' - Nhà văn ', i);

ELSE
                SET ho = ELT(1 + (i % 4), 'Vũ', 'Đỗ', 'Bùi', 'Ngô');
                SET dem = ELT(1 + (i % 3), 'Trọng', 'Đình', 'Mạnh');
                SET ten = ELT(1 + (i % 4), 'Phụng', 'Tố', 'Tấn', 'Hải');
                SET quoc_tich = 'Việt Nam';
                SET ten_chinh_thuc = CONCAT(ho, ' ', dem, ' ', ten, ' (Tập sự ', i, ')');
END IF;

INSERT INTO authors (id, name, nationality, birth_date, bio)
VALUES (i,
        ten_chinh_thuc,
        quoc_tich,
        DATE_SUB('1985-01-01', INTERVAL (i * 365) DAY),
        CONCAT('Tác giả mã số hệ thống ', i,
               ', chuyên viết sách có nhiều đóng góp lớn đóng góp xuất sắc tại nền văn học ', quoc_tich,
               '.'));
SET i = i + 1;
END WHILE;
END$$


-- ----------------------------------------------------------------------------
-- 2. Thủ tục sinh 80 Người dùng (Gồm Admin, Thủ thư và 77 Độc giả)
-- ----------------------------------------------------------------------------
CREATE PROCEDURE DynamicSeedUsers()
BEGIN
    DECLARE i INT DEFAULT 4;
    DECLARE ho VARCHAR(50);
    DECLARE dem VARCHAR(50);
    DECLARE ten VARCHAR(50);

    -- Thêm trước 3 tài khoản vận hành hệ thống cố định
INSERT INTO users (id, username, password, full_name, email, phone, student_id, role, active)
VALUES (1, 'admin', '$2a$12$L8B7E9F...', 'Nguyễn Minh Hoàng (Admin)', 'admin@thuvien.edu.vn', '0912345678', NULL, 'ADMIN',
        1),
       (2, 'librarian1', '$2a$12$L8B7E9F...', 'Trần Thị Tuyết (Thủ thư trưởng)', 'tuyet.tt@thuvien.edu.vn',
        '0922345679', NULL, 'LIBRARIAN', 1),
       (3, 'librarian2', '$2a$12$L8B7E9F...', 'Phạm Văn Đức (Thủ thư quầy)', 'duc.pv@thuvien.edu.vn', '0932345680',
        NULL, 'LIBRARIAN', 1);

-- Vòng lặp chèn tự động 77 độc giả
WHILE i <= 80
        DO
            SET ho = ELT(1 + (i % 5), 'Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng');
            SET dem = ELT(1 + (i % 4), 'Văn', 'Thị', 'Minh', 'Thành');
            SET ten = ELT(1 + (i % 6), 'Tuấn', 'Hoa', 'Dũng', 'Trang', 'Nam', 'Linh');

INSERT INTO users (id, username, password, full_name, email, phone, student_id, role, active)
VALUES (i,
        CONCAT('reader', i),
        '$2a$12$L8B7E9F...',
        CONCAT(ho, ' ', dem, ' ', ten),
        CONCAT('reader', i, '@thuvien.edu.vn'),
        CONCAT('09', LPAD(i * 12345, 8, '0')),
        CONCAT('HE170', LPAD(i, 3, '0')),
        'READER',
        1);

-- Chia hạng đều dựa trên mã ID từ Đồng đến Kim Cương
INSERT INTO user_memberships (user_id, tier_id, total_books_borrowed, tier_achieved_at)
VALUES (i,
        (1 + (i % 4)),
        (i * 2),
        DATE_SUB(CURDATE(), INTERVAL i DAY));
SET i = i + 1;
END WHILE;
END$$


-- ----------------------------------------------------------------------------
-- 3. Thủ tục sinh đúng 450 Cuốn sách phân bố ngẫu nhiên vào 40 tác giả trên
-- ----------------------------------------------------------------------------
CREATE PROCEDURE DynamicSeed450Books()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE dm_id INT;
    DECLARE tg_id INT;
    DECLARE tieu_de VARCHAR(255);
    DECLARE tg_ten VARCHAR(150);

    WHILE i <= 450
        DO
            SET dm_id = 1 + (i % 5);
            SET tg_id = 1 + (i % 40); -- Đảm bảo lấy ngẫu nhiên chuẩn Khóa ngoại từ 1 đến 40 tác giả có sẵn
            SET tg_ten = (SELECT name FROM authors WHERE id = tg_id);

            -- Thiết lập tên sách thuần Việt có ý nghĩa dựa theo nhóm phân loại Danh mục (Category)
            IF dm_id = 1 THEN
                SET tieu_de = ELT(1 + (i % 5), 'Lập trình ứng dụng Web chuyên sâu', 'Phân tích dữ liệu Big Data',
                                  'Học sâu & Trí tuệ nhân tạo', 'Mạng máy tính nâng cao',
                                  'Điện toán đám mây cho doanh nghiệp');
            ELSEIF dm_id = 2 THEN
                SET tieu_de =
                        ELT(1 + (i % 5), 'Khởi nghiệp tinh gọn trong kỷ nguyên số', 'Quản trị dòng tiền doanh nghiệp',
                            'Chiến lược Marketing hiện đại', 'Tối ưu hóa vận hành chuỗi cung ứng',
                            'Nghệ thuật đàm phán thương mại');
            ELSEIF dm_id = 3 THEN
                SET tieu_de =
                        ELT(1 + (i % 5), 'Cho tôi một vé đi tuổi thơ hoài niệm', 'Rừng Na Uy và những bản tình ca',
                            'Mắt biếc ngày xưa', 'Tiếng gọi từ vùng hoang dã lạnh giá', 'Ký ức những ngày mưa Hà Nội');
            ELSEIF dm_id = 4 THEN
                SET tieu_de =
                        ELT(1 + (i % 5), 'Đắc nhân tâm và Nghệ thuật ứng xử', 'Tư duy nhanh và chậm trong hành động',
                            'Làm chủ tư duy thay đổi tương lai', 'Bí quyết quản lý thời gian hiệu quả',
                            'Đánh thức tiềm năng tài chính cá nhân');
ELSE
                SET tieu_de =
                        ELT(1 + (i % 5), 'Lịch sử văn minh thế giới cổ đại', 'Lịch sử hào hùng các triều đại Việt',
                            'Triết học đại cương phương Đông', 'Khảo cổ học và Tiến trình nhân loại',
                            'Kinh tế chính trị học ứng dụng');
END IF;

INSERT INTO books (id, isbn, title, category, category_id, publisher, publish_year, quantity,
                   available, description, subject, area, shelf, slot)
VALUES (i,
        CONCAT('978-604-', LPAD(i * 251, 6, '0')),
        CONCAT(tieu_de, ' (Tập ', (1 + (i % 3)), ')'),
        (SELECT name FROM categories WHERE id = dm_id),
        dm_id,
        ELT(1 + (i % 3), 'NXB Trẻ', 'NXB Giáo Dục', 'NXB Kim Đồng'),
        (2018 + (i % 8)),
        3,
        3,
        CONCAT('Tài liệu giáo trình chính thống hỗ trợ kiến thức chuyên ngành chuyên sâu về đầu sách: ',
               tieu_de),
        ELT(1 + (i % 5), 'Lập trình Web', 'Cơ sở dữ liệu', 'Toán rời rạc', 'Kinh tế vĩ mô', 'Vật lý đại cương'),
        CONCAT('Tầng ', (1 + (i % 3))),
        CONCAT('Kệ K', LPAD(1 + (i % 12), 2, '0')),
        CONCAT('Ngăn N', LPAD(1 + (i % 5), 2, '0')));

-- Thêm 3 bản sao vật lý cho mỗi đầu sách
INSERT INTO book_copies (book_id, barcode, book_condition, status)
VALUES (i, CONCAT('B', LPAD(i, 4, '0'), 'C01'), 'GOOD', 'AVAILABLE'),
       (i, CONCAT('B', LPAD(i, 4, '0'), 'C02'), 'GOOD', 'AVAILABLE'),
       (i, CONCAT('B', LPAD(i, 4, '0'), 'C03'), 'WORN', 'AVAILABLE');

-- Gán quan hệ vào bảng trung gian nhiều - nhiều: book_authors
INSERT INTO book_authors(book_id, author_id, role) VALUES (i, tg_id, 'PRIMARY');

-- Đa dạng hóa: Sách có ID chẵn sẽ có thêm 1 Đồng tác giả (CO_AUTHOR)
IF i % 2 = 0 THEN
                INSERT INTO book_authors(book_id, author_id, role) VALUES (i, 1 + ((tg_id + 5) % 40), 'CO_AUTHOR');
END IF;

            SET i = i + 1;
END WHILE;
END$$


-- ----------------------------------------------------------------------------
-- 4. Thủ tục tạo 180 Bản ghi giao dịch (Mượn trả, Phạt quá hạn, Gửi thông báo)
-- ----------------------------------------------------------------------------
CREATE PROCEDURE DynamicSeedTransactions()
BEGIN
    DECLARE j INT DEFAULT 1;
    DECLARE target_u_id INT;
    DECLARE target_b_id INT;
    DECLARE target_c_id INT;

    WHILE j <= 180
        DO
            SET target_u_id = 4 + (j % 76); -- Chọn Độc giả từ ID 4 đến 80
            SET target_b_id = 1 + (j * 3 % 449); -- Chọn Sách từ ID 1 đến 450
            SET target_c_id = (SELECT id FROM book_copies WHERE book_id = target_b_id LIMIT 1);

            IF j % 3 = 0 THEN
                -- Trường hợp 1: Sách đã được mượn trong quá khứ và hoàn trả đúng hạn sạch sẽ
                INSERT INTO borrow_records (id, user_id, book_id, copy_id, borrow_date, due_date, return_date, status, note)
                VALUES (j, target_u_id, target_b_id, target_c_id, '2026-04-01', '2026-04-15', '2026-04-14', 'RETURNED',
                        'Độc giả hoàn trả sách nguyên vẹn sạch đẹp.');
            ELSEIF j % 3 = 1 THEN
                -- Trường hợp 2: Đang mượn hợp lệ (Tiến hành trừ bớt 1 quyển khả dụng tại kho của bảng books)
                INSERT INTO borrow_records (id, user_id, book_id, copy_id, borrow_date, due_date, return_date, status, note)
                VALUES (j, target_u_id, target_b_id, target_c_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL, 'BORROWING',
                        'Mượn đọc tự nghiên cứu tại nhà.');

UPDATE books SET available = available - 1 WHERE id = target_b_id;
UPDATE book_copies SET status = 'BORROWED' WHERE id = target_c_id;
ELSE
                -- Trường hợp 3: Quá hạn trả sách (Trừ kho khả dụng + Tạo tiền phạt + Tạo thông báo nhắc độc giả)
                INSERT INTO borrow_records (id, user_id, book_id, copy_id, borrow_date, due_date, return_date, status, note)
                VALUES (j, target_u_id, target_b_id, target_c_id, '2026-03-01', '2026-03-15', NULL, 'OVERDUE',
                        'Hệ thống tự động quét và gửi cảnh báo trễ hạn lần 3.');

UPDATE books SET available = available - 1 WHERE id = target_b_id;
-- Thay vì 'OVERDUE', status của book_copies vẫn có thể là BORROWED hoặc LOST, ta set thành BORROWED
UPDATE book_copies SET status = 'BORROWED' WHERE id = target_c_id;

INSERT INTO fines (borrow_record_id, user_id, amount, overdue_days, reason, status, payment_method)
VALUES (j, target_u_id, 45000.00, 12, 'Hội viên trả trễ hạn cuốn sách quy định quá 12 ngày', 'UNPAID',
        'ONLINE');

INSERT INTO notifications (user_id, title, message, type, is_read)
VALUES (target_u_id, 'Cảnh báo sách mượn quá hạn phạt tiền',
        'Bạn đang giữ sách quá hạn của thư viện, tiền phạt đang tích lũy, vui lòng đến quầy xử lý gấp.',
        'OVERDUE', 0);
END IF;

            SET j = j + 1;
END WHILE;
END$$

DELIMITER ;


-- ============================================================================
-- PHẦN 4: KÍCH HOẠT CHẠY CÁC PROCEDURE VÀ XÓA CHÚNG (CLEANUP BỘ NHỚ)
-- ============================================================================
CALL DynamicSeedAuthors();
CALL DynamicSeedUsers();
CALL DynamicSeed450Books();
CALL DynamicSeedTransactions();

-- Gỡ bỏ các hàm tạm khỏi hệ thống sau khi đổ xong dữ liệu mẫu thành công
DROP PROCEDURE IF EXISTS DynamicSeedAuthors;
DROP PROCEDURE IF EXISTS DynamicSeedUsers;
DROP PROCEDURE IF EXISTS DynamicSeed450Books;
DROP PROCEDURE IF EXISTS DynamicSeedTransactions;

-- Chèn thêm dữ liệu Đánh giá sách (Reviews) và Token xác thực ngẫu nhiên mẫu ở bước cuối cùng
INSERT INTO book_reviews (book_id, user_id, rating, comment)
VALUES (1, 5, 5, 'Nội dung thực hành cực kỳ chi tiết, phù hợp làm đồ án tốt nghiệp!'),
       (15, 12, 4, 'Văn phong mượt mà, cấu trúc các chương mạch lạc dễ tiếp cận.'),
       (120, 43, 5, 'Cuốn sách hay nhất mà tôi từng đọc tại thư viện trường từ trước đến nay.');

INSERT INTO user_tokens (user_id, token, type, expiry)
VALUES (4, 'MYSQL_TOKEN_VALID_AUTH_SESSION_KEY_2026_V5', 'REGISTRATION', '2026-08-30 00:00:00');


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

-- Fix user passwords with proper MD5 hashes
-- MD5 hash of "12345" = 827ccb0eea8a706c4c34a16891f84e7b

UPDATE users SET password = '827ccb0eea8a706c4c34a16891f84e7b' WHERE username = 'admin';
UPDATE users SET password = '827ccb0eea8a706c4c34a16891f84e7b' WHERE username = 'librarian1';
UPDATE users SET password = '827ccb0eea8a706c4c34a16891f84e7b' WHERE username = 'librarian2';
UPDATE users SET password = '827ccb0eea8a706c4c34a16891f84e7b' WHERE username LIKE 'reader%';