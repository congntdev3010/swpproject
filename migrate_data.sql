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

DROP PROCEDURE IF EXISTS DynamicSeedAuthors;
DROP PROCEDURE IF EXISTS DynamicSeedUsers;
DROP PROCEDURE IF EXISTS DynamicSeed450Books;
DROP PROCEDURE IF EXISTS DynamicSeedTransactions;

DELIMITER $$

-- ----------------------------------------------------------------------------
-- 1. Thủ tục sinh 40 tác giả Độc nhất (Sử dụng tên các tác giả nổi tiếng có thật)
-- ----------------------------------------------------------------------------
CREATE PROCEDURE DynamicSeedAuthors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE ten_chinh_thuc VARCHAR(150);
    DECLARE quoc_tich VARCHAR(50);
    DECLARE bio_text VARCHAR(500);

    WHILE i <= 40
        DO
            CASE i
                WHEN 1 THEN BEGIN SET ten_chinh_thuc = 'Nguyễn Du'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Đại thi hào dân tộc Việt Nam, danh nhân văn hóa thế giới, tác giả Truyện Kiều.'; END;
                WHEN 2 THEN BEGIN SET ten_chinh_thuc = 'Nam Cao'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà văn hiện thực xuất sắc, chuyên viết về người nông dân và trí thức nghèo trước cách mạng.'; END;
                WHEN 3 THEN BEGIN SET ten_chinh_thuc = 'Vũ Trọng Phụng'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Ông vua phóng sự đất Bắc, tác giả Số Đỏ, Giông Tố phản ánh xã hội thực dân nửa phong kiến.'; END;
                WHEN 4 THEN BEGIN SET ten_chinh_thuc = 'Tô Hoài'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà văn lớn của văn học hiện đại Việt Nam, tác giả Dế Mèn Phiêu Lưu Ký nổi tiếng.'; END;
                WHEN 5 THEN BEGIN SET ten_chinh_thuc = 'Nguyễn Nhật Ánh'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà văn chuyên viết cho tuổi học trò với các tác phẩm như Mắt Biếc, Kính Vạn Hoa.'; END;
                WHEN 6 THEN BEGIN SET ten_chinh_thuc = 'Thạch Lam'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Thành viên Tự Lực Văn Đoàn, chuyên viết truyện ngắn với văn phong nhẹ nhàng, sâu lắng.'; END;
                WHEN 7 THEN BEGIN SET ten_chinh_thuc = 'Xuân Diệu'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Ông hoàng thơ tình Việt Nam, nhà thơ lớn trong phong trào Thơ Mới.'; END;
                WHEN 8 THEN BEGIN SET ten_chinh_thuc = 'Huy Cận'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà thơ lớn của phong trào Thơ Mới, nổi tiếng với tập Lửa Thiêng.'; END;
                WHEN 9 THEN BEGIN SET ten_chinh_thuc = 'Hàn Mặc Tử'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà thơ tài hoa nhưng đoản mệnh, đại diện tiêu biểu của trường thơ loạn.'; END;
                WHEN 10 THEN BEGIN SET ten_chinh_thuc = 'Tố Hữu'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Lá cờ đầu của thơ ca cách mạng Việt Nam với các tập thơ Từ Ấy, Việt Bắc.'; END;
                WHEN 11 THEN BEGIN SET ten_chinh_thuc = 'Haruki Murakami'; SET quoc_tich = 'Nhật Bản'; SET bio_text = 'Nhà văn đương đại nổi tiếng toàn cầu, tác giả Rừng Na Uy, Kafka Bên Bờ Biển.'; END;
                WHEN 12 THEN BEGIN SET ten_chinh_thuc = 'Keigo Higashino'; SET quoc_tich = 'Nhật Bản'; SET bio_text = 'Nhà văn trinh thám hàng đầu Nhật Bản, tác giả Phía Sau Nghi Can X.'; END;
                WHEN 13 THEN BEGIN SET ten_chinh_thuc = 'Arthur Conan Doyle'; SET quoc_tich = 'Anh'; SET bio_text = 'Nhà văn nổi tiếng với bộ truyện trinh thám về thám tử lừng danh Sherlock Holmes.'; END;
                WHEN 14 THEN BEGIN SET ten_chinh_thuc = 'Agatha Christie'; SET quoc_tich = 'Anh'; SET bio_text = 'Nữ hoàng trinh thám với nhân vật thám tử Hercule Poirot và Miss Marple.'; END;
                WHEN 15 THEN BEGIN SET ten_chinh_thuc = 'J.K. Rowling'; SET quoc_tich = 'Anh'; SET bio_text = 'Tác giả của bộ truyện giả tưởng Harry Potter bán chạy nhất lịch sử.'; END;
                WHEN 16 THEN BEGIN SET ten_chinh_thuc = 'Stephen King'; SET quoc_tich = 'Mỹ'; SET bio_text = 'Ông hoàng kinh dị Mỹ với các tác phẩm IT, The Shining, The Shawshank Redemption.'; END;
                WHEN 17 THEN BEGIN SET ten_chinh_thuc = 'Dale Carnegie'; SET quoc_tich = 'Mỹ'; SET bio_text = 'Tác giả cuốn Đắc Nhân Tâm, nhà phát triển các khóa học phát triển bản thân.'; END;
                WHEN 18 THEN BEGIN SET ten_chinh_thuc = 'Napoleon Hill'; SET quoc_tich = 'Mỹ'; SET bio_text = 'Sáng lập học thuyết thành công cá nhân, tác giả cuốn Nghĩ Giàu Và Làm Giàu.'; END;
                WHEN 19 THEN BEGIN SET ten_chinh_thuc = 'Sigmund Freud'; SET quoc_tich = 'Áo'; SET bio_text = 'Nhà bác sĩ thần kinh và tâm lý học, người sáng lập ra ngành phân tâm học.'; END;
                WHEN 20 THEN BEGIN SET ten_chinh_thuc = 'Albert Einstein'; SET quoc_tich = 'Đức'; SET bio_text = 'Nhà vật lý lý thuyết vĩ đại, người phát triển thuyết tương đối rộng và hẹp.'; END;
                WHEN 21 THEN BEGIN SET ten_chinh_thuc = 'William Shakespeare'; SET quoc_tich = 'Anh'; SET bio_text = 'Nhà văn và nhà viết kịch vĩ đại nhất của nước Anh, tác giả Romeo và Juliet.'; END;
                WHEN 22 THEN BEGIN SET ten_chinh_thuc = 'Victor Hugo'; SET quoc_tich = 'Pháp'; SET bio_text = 'Nhà văn theo chủ nghĩa lãng mạn vĩ đại của Pháp, tác giả Những Người Khốn Khổ.'; END;
                WHEN 23 THEN BEGIN SET ten_chinh_thuc = 'Leo Tolstoy'; SET quoc_tich = 'Nga'; SET bio_text = 'Nhà văn vĩ đại người Nga, tác giả Chiến Tranh và Hòa Bình, Anna Karenina.'; END;
                WHEN 24 THEN BEGIN SET ten_chinh_thuc = 'Fyodor Dostoevsky'; SET quoc_tich = 'Nga'; SET bio_text = 'Nhà văn Nga xuất sắc nhất thế kỷ 19, tác giả Tội Ác và Hình Phạt.'; END;
                WHEN 25 THEN BEGIN SET ten_chinh_thuc = 'Ernest Hemingway'; SET quoc_tich = 'Mỹ'; SET bio_text = 'Nhà văn Mỹ đoạt giải Nobel văn học, tác giả cuốn Ông Già và Biển Cả.'; END;
                WHEN 26 THEN BEGIN SET ten_chinh_thuc = 'Mark Twain'; SET quoc_tich = 'Mỹ'; SET bio_text = 'Cha đẻ của văn học Mỹ hiện đại, tác giả Cuộc Phiêu Lưu của Tom Sawyer.'; END;
                WHEN 27 THEN BEGIN SET ten_chinh_thuc = 'Charles Dickens'; SET quoc_tich = 'Anh'; SET bio_text = 'Nhà văn hiện thực vĩ đại thời kỳ Victoria, tác giả Oliver Twist.'; END;
                WHEN 28 THEN BEGIN SET ten_chinh_thuc = 'Jane Austen'; SET quoc_tich = 'Anh'; SET bio_text = 'Nữ văn sĩ nổi tiếng với các tiểu thuyết Kiêu Hãnh và Định Kiến, Emma.'; END;
                WHEN 29 THEN BEGIN SET ten_chinh_thuc = 'George Orwell'; SET quoc_tich = 'Anh'; SET bio_text = 'Tác giả của các tiểu thuyết phê phán chính trị nổi tiếng như 1984, Trại Súc Vật.'; END;
                WHEN 30 THEN BEGIN SET ten_chinh_thuc = 'Franz Kafka'; SET quoc_tich = 'Áo'; SET bio_text = 'Nhà văn tiếng Đức lỗi lạc, nổi tiếng với truyện ngắn Hóa Thân.'; END;
                WHEN 31 THEN BEGIN SET ten_chinh_thuc = 'Nguyễn Trãi'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Anh hùng dân tộc, danh nhân văn hóa thế giới, tác giả Bình Ngô Đại Cáo.'; END;
                WHEN 32 THEN BEGIN SET ten_chinh_thuc = 'Chu Văn An'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà giáo mẫu mực của nước Việt, người dâng Thất trảm sớ dẹp quan tham.'; END;
                WHEN 33 THEN BEGIN SET ten_chinh_thuc = 'Phan Bội Châu'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà cách mạng lớn đầu thế kỷ XX, người khởi xướng phong trào Đông Du.'; END;
                WHEN 34 THEN BEGIN SET ten_chinh_thuc = 'Phan Châu Trinh'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà yêu nước, người khởi xướng phong trào Duy Tân chống thực dân Pháp.'; END;
                WHEN 35 THEN BEGIN SET ten_chinh_thuc = 'Trần Hưng Đạo'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Anh hùng dân tộc, danh tướng nhà Trần ba lần đánh bại quân Nguyên Mông.'; END;
                WHEN 36 THEN BEGIN SET ten_chinh_thuc = 'Võ Nguyên Giáp'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Đại tướng huyền thoại của Việt Nam, người chỉ huy chiến dịch Điện Biên Phủ.'; END;
                WHEN 37 THEN BEGIN SET ten_chinh_thuc = 'Nguyễn Hiến Lê'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Học giả, nhà dịch thuật xuất sắc đã dịch cuốn Đắc Nhân Tâm về Việt Nam đầu tiên.'; END;
                WHEN 38 THEN BEGIN SET ten_chinh_thuc = 'Xuân Quỳnh'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nữ nhà thơ tình nổi tiếng với bài thơ Sóng, Thuyền và Biển.'; END;
                WHEN 39 THEN BEGIN SET ten_chinh_thuc = 'Lưu Quang Vũ'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà viết kịch xuất sắc, tác giả vở kịch Hồn Trương Ba Da Hàng Thịt.'; END;
                WHEN 40 THEN BEGIN SET ten_chinh_thuc = 'Nguyễn Duy'; SET quoc_tich = 'Việt Nam'; SET bio_text = 'Nhà thơ lớn của Việt Nam, tác giả bài thơ Tre Việt Nam.'; END;
            END CASE;

            INSERT INTO authors (id, name, nationality, birth_date, bio, created_by, updated_by, is_deleted)
            VALUES (i,
                    ten_chinh_thuc,
                    quoc_tich,
                    DATE_SUB('1985-01-01', INTERVAL (i * 365) DAY),
                    bio_text,
                    'system',
                    'system',
                    0);
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
    VALUES (1, 'admin', '$2a$12$L8B7E9F...', 'Nguyễn Minh Hoàng (Admin)', 'admin@thuvien.edu.vn', '0912345678', NULL, 'ADMIN', 1),
           (2, 'librarian1', '$2a$12$L8B7E9F...', 'Trần Thị Tuyết (Thủ thư trưởng)', 'tuyet.tt@thuvien.edu.vn', '0922345679', NULL, 'LIBRARIAN', 1),
           (3, 'librarian2', '$2a$12$L8B7E9F...', 'Phạm Văn Đức (Thủ thư quầy)', 'duc.pv@thuvien.edu.vn', '0932345680', NULL, 'LIBRARIAN', 1);

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
    DECLARE prefix VARCHAR(100);
    DECLARE subject VARCHAR(150);
    DECLARE suffix VARCHAR(50);
    DECLARE seq INT;
    DECLARE anh_bia VARCHAR(500);

    WHILE i <= 450
        DO
            SET dm_id = 1 + (i % 5);
            SET tg_id = 1 + (i % 40);
            SET seq = (i - 1) DIV 5;

            -- Thiết lập tên sách có nghĩa thật dựa theo nhóm phân loại Danh mục (Category)
            IF dm_id = 1 THEN
                -- Khoa học & Công nghệ (90 sách)
                SET prefix = ELT(1 + (seq % 9), 'Lập trình', 'Phân tích', 'Thiết kế', 'Quản trị', 'Phát triển', 'Ứng dụng', 'Bảo mật', 'Nhập môn', 'Chuyên sâu');
                SET subject = ELT(1 + ((seq DIV 9) % 10), ' hệ thống IoT hiện đại', ' ứng dụng Web với React', ' trí tuệ nhân tạo AI', ' dữ liệu lớn Big Data', ' điện toán đám mây Cloud', ' mạng máy tính Cisco', ' cơ sở dữ liệu SQL', ' thuật toán và cấu trúc dữ liệu', ' an ninh mạng doanh nghiệp', ' blockchain và fintech');
                SET tieu_de = CONCAT(prefix, subject);
                SET anh_bia = ELT(1 + (i % 4), 
                                  'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1504639725590-34d0984388bd?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=400&q=80');
            ELSEIF dm_id = 2 THEN
                -- Kinh tế & Quản trị (90 sách)
                SET prefix = ELT(1 + (seq % 9), 'Quản trị', 'Chiến lược', 'Khởi nghiệp', 'Kinh doanh', 'Đầu tư', 'Nghệ thuật', 'Bí quyết', 'Phân tích', 'Tối ưu hóa');
                SET subject = ELT(1 + ((seq DIV 9) % 10), ' tài chính doanh nghiệp', ' marketing kỹ thuật số', ' chuỗi cung ứng toàn cầu', ' thương mại điện tử', ' nhân sự thời đại số', ' đàm phán quốc tế', ' thị trường chứng khoán', ' quản trị rủi ro kinh doanh', ' xây dựng thương hiệu dẫn đầu', ' đổi mới mô hình kinh doanh');
                SET tieu_de = CONCAT(prefix, subject);
                SET anh_bia = ELT(1 + (i % 4),
                                  'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=400&q=80');
            ELSEIF dm_id = 3 THEN
                -- Văn học & Nghệ thuật (90 sách)
                SET prefix = ELT(1 + (seq % 30), 'Chí Phèo', 'Lão Hạc', 'Tắt Đèn', 'Số Đỏ', 'Vợ Nhặt', 'Dế Mèn Phiêu Lưu Ký', 'Đất Rừng Phương Nam', 'Chiếc Lược Ngà', 'Truyện Kiều', 'Rừng Xà Nu', 'Bến Quê', 'Hồn Trương Ba Da Hàng Thịt', 'Mắt Biếc', 'Cho Tôi Một Vé Đi Tuổi Thơ', 'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 'Rừng Na Uy', 'Chiến Tranh Và Hòa Bình', 'Kiêu Hãnh Và Định Kiến', 'Đại Gia Gatsby', 'Ông Già Và Biển Cả', 'Tiếng Gọi Nơi Hoang Dã', 'Những Người Khốn Khổ', 'Đồi Gió Hú', 'Don Quixote', 'Trăm Năm Cô Đơn', 'Tội Ác Và Hình Phạt', 'Bắt Trẻ Đồng Xanh', 'Nhà Giả Kim', 'Hoàng Tử Bé', 'Sherlock Holmes');
                SET suffix = ELT(1 + ((seq DIV 30) % 3), ' (Tái Bản)', ' (Tập 1)', ' (Tập 2)');
                SET tieu_de = CONCAT(prefix, suffix);
                SET anh_bia = ELT(1 + (i % 4),
                                  'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1474932430478-367dbb6832c1?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=400&q=80');
            ELSEIF dm_id = 4 THEN
                -- Tâm lý & Kỹ năng sống (90 sách)
                SET prefix = ELT(1 + (seq % 30), 'Đắc Nhân Tâm', 'Quẳng Gánh Lo Đi Và Vui Sống', 'Tư Duy Nhanh Và Chậm', 'Cha Giàu Cha Nghèo', 'Đọc Vị Bất Kỳ Ai', 'Bảy Thói Quen Để Thành Đạt', 'Sức Mạnh Của Hiện Tại', 'Người Giàu Nhất Thành Babylon', 'Lối Tư Duy Tối Giản', 'Tìm Kiếm Lẽ Sống', 'Nghĩ Giàu Và Làm Giàu', 'Đánh Thức Con Người Phi Thường Trong Bạn', 'Giới Hạn Của Tư Duy', 'Hành Trình Về Phương Đông', 'Muôn Kiếp Nhân Sinh', 'Không Diệt Không Sinh Đừng Sợ Hãi', 'Dám Bị Ghét', 'Hiểu Về Trái Tim', 'Tuổi Trẻ Đáng Giá Bao Nhiêu', 'Đời Thay Đổi Khi Chúng Ta Thay Đổi', 'Sức Mạnh Của Thói Quen', 'Tư Duy Như Một Nhà Khắc Kỷ', 'Lòng Biết Ơn và Hạnh Phúc', 'Làm Chủ Cảm Xúc Làm Chủ Cuộc Đời', 'Nghệ Thuật Giao Tiếp Thành Công', 'Tập Trung Cao Độ', 'Kỷ Luật Tự Giác', 'Tư Duy Phản Biện', 'Hạt Giống Tâm Hồn', 'Trí Tuệ Cảm Xúc');
                SET suffix = ELT(1 + ((seq DIV 30) % 3), ' (Tái Bản)', ' (Tập 1)', ' (Tập 2)');
                SET tieu_de = CONCAT(prefix, suffix);
                SET anh_bia = ELT(1 + (i % 4),
                                  'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1489533119213-66a5cd877091?auto=format&fit=crop&w=400&q=80');
            ELSE
                -- Lịch sử & Triết học (90 sách)
                SET prefix = ELT(1 + (seq % 30), 'Lịch Sử Việt Nam', 'Đại Việt Sử Ký Toàn Thư', 'Lịch Sử Văn Minh Thế Giới', 'Sapiens: Lược Sử Loài Người', 'Homo Deus: Lược Sử Tương Lai', '21 Bài Học Cho Thế Kỷ 21', 'Sử Ký Tư Mã Thiên', 'Tam Quốc Diễn Nghĩa', 'Lược Sử Thời Gian', 'Vũ Trụ Trong Vỏ Hạt Dẻ', 'Bàn Về Khế Ước Xã Hội', 'Triết Học Mác - Lênin', 'Lịch Sử Triết Học Phương Tây', 'Cổ Học Tinh Hoa', 'Khổng Tử Và Luận Ngữ', 'Lão Tử Đạo Đức Kinh', 'Triết Học Khắc Kỷ', 'Sự Trỗi Dậy Và Suy Tàn Của La Mã', 'Chiến Tranh Thế Giới Thứ Hai', 'Lịch Sử Ngoại Giao Việt Nam', 'Tuyên Ngôn Độc Lập', 'Việt Nam Sử Lược', 'Nguồn Gốc Các Loài', 'Bản Đồ Lịch Sử Thế Giới', 'Lược Sử Triết Học', 'Đạo Đức Học Đại Cương', 'Lịch Sử Cách Mạng Pháp', 'Lịch Sử Quân Sự Việt Nam', 'Hồ Chí Minh Toàn Tập', 'Hành Trình Nhân Loại');
                SET suffix = ELT(1 + ((seq DIV 30) % 3), ' (Tái Bản)', ' (Tập 1)', ' (Tập 2)');
                SET tieu_de = CONCAT(prefix, suffix);
                SET anh_bia = ELT(1 + (i % 4),
                                  'https://images.unsplash.com/photo-1447069387593-a5de0862481e?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=400&q=80',
                                  'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=400&q=80');
            END IF;

            INSERT INTO books (id, isbn, title, category, category_id, publisher, publish_year, quantity,
                               available, description, cover_image, subject, area, shelf, slot, created_by, updated_by, is_deleted)
            VALUES (i,
                    CONCAT('978-604-', LPAD(i * 251, 6, '0')),
                    tieu_de,
                    (SELECT name FROM categories WHERE id = dm_id),
                    dm_id,
                    ELT(1 + (i % 3), 'NXB Trẻ', 'NXB Giáo Dục', 'NXB Kim Đồng'),
                    (2018 + (i % 8)),
                    3,
                    3,
                    CONCAT('Tài liệu giáo trình chính thống hỗ trợ kiến thức chuyên ngành chuyên sâu về đầu sách: ', tieu_de),
                    anh_bia,
                    ELT(1 + (i % 5), 'Lập trình Web', 'Cơ sở dữ liệu', 'Toán rời rạc', 'Kinh tế vĩ mô', 'Vật lý đại cương'),
                    CONCAT('Tầng ', (1 + (i % 3))),
                    CONCAT('Kệ K', LPAD(1 + (i % 12), 2, '0')),
                    CONCAT('Ngăn N', LPAD(1 + (i % 5), 2, '0')),
                    'system',
                    'system',
                    0);

            -- Thêm 3 bản sao vật lý cho mỗi đầu sách
            INSERT INTO book_copies (book_id, barcode, book_condition, status)
            VALUES (i, CONCAT('B', LPAD(i, 4, '0'), 'C01'), 'GOOD', 'AVAILABLE'),
                   (i, CONCAT('B', LPAD(i, 4, '0'), 'C02'), 'GOOD', 'AVAILABLE'),
                   (i, CONCAT('B', LPAD(i, 4, '0'), 'C03'), 'WORN', 'AVAILABLE');

            -- Gán quan hệ vào bảng trung gian nhiều - nhiều: book_authors
            INSERT INTO book_authors(book_id, author_id, role) VALUES (i, tg_id, 'PRIMARY');

            -- Sách có ID chẵn sẽ có thêm 1 Đồng tác giả (CO_AUTHOR)
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
                UPDATE book_copies SET status = 'BORROWED' WHERE id = target_c_id;

                INSERT INTO fines (borrow_record_id, user_id, amount, overdue_days, reason, status, payment_method)
                VALUES (j, target_u_id, 45000.00, 12, 'Hội viên trả trễ hạn cuốn sách quy định quá 12 ngày', 'UNPAID', 'ONLINE');

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