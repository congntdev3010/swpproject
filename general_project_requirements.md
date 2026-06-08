# 1 Chương trình
1. **Bắt buộc phải validate (Required, format, length....)**
    * **Required:** Test trường hợp nhập blank, space
    * **Length:** Nhập độ dài text vượt quá DB xem có lỗi DB không? Có vỡ khung không?
    * **format:** date, email, mobibe, image -> chỉ được chọn file đuôi jpg, png,....
    * ....
2. **Bảng dữ liệu bắt buộc phải có đủ search, filter, sort, pagging.**

# Report
* Bắt buộc gửi daily report hàng ngày

# 1 Source code (Bắt buộc, không làm được -> không bảo vệ)
1. **Bắt buộc phải tích hợp vào source chung của nhóm, thầy sẽ không review source riêng lẻ**
    * Tích hợp gồm:
        * Về mặt vật lý, source code phải merge vào main branch hàng ngày, khi demo chỉ chạy trên 1 bản source, không mỗi người demo trên máy riêng
        * Về mặt logic, source code cần chung định dạng, format, css, chung header/footer, menu, các màn hình cần di chuyển được sang nhau mà ko được đi từ URL,...
2. Các màn hình có UI tương tự nhau -> cần code chung vào 1 source code (Ví dụ: Create, Update, View detail cần dùng chung jsp, model...)
3. 1 function được dùng chung cho nhiều role -> cần code chung 1 source, không tách mỗi role 1 source riêng (Ví dụ chỉ có 1 màn hình View List Order -> cả manager, shipper, staff dùng chung, phân quyền thao tác theo role)
4. Phần dùng chung như header, footer, menu -> code chung trong 1 jsp, các màn hình chỉ cần import vào
