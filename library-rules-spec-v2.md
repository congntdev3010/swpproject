# Đặc tả nghiệp vụ: Mượn sách, Phạt & Thông báo hệ thống

> Tài liệu này mô tả các quy tắc nghiệp vụ (business rules) cho module Mượn sách / Đặt trước / Phạt / Thông báo của hệ thống thư viện. Dùng làm input cho agent để triển khai logic backend.

---

## 1. Quy tắc mượn sách (Borrowing Rules)

### 1.1 Giới hạn số lượng mượn
- Mỗi **User** được phép mượn **tối đa 5 quyển** cùng lúc.
  - Giới hạn này tính **theo từng User**, **không tính tổng toàn thư viện**.
  - Giới hạn **mặc định là 5**, nhưng **thay đổi theo hạng (tier/rank) của người dùng** — mỗi hạng có ngưỡng mượn riêng (cần bảng cấu hình `user_tier -> max_borrow_limit`).
- Các phiếu ở trạng thái **"Đặt trước" (Reservation)** được **tính gộp** vào giới hạn số lượng này (không tách riêng quota cho đặt trước).

### 1.2 Hành vi khi vượt ngưỡng
- Khi User đạt/vượt ngưỡng giới hạn (ví dụ 5 quyển):
  - Hệ thống **hiển thị cảnh báo vi phạm số lượng** trên màn hình.
  - **Không tự động xóa** dữ liệu / phiếu đã import hoặc đã tạo của người dùng.
  - **Thủ thư (Librarian) hoặc Admin** là người đưa ra **quyết định cuối cùng** (duyệt tiếp / từ chối / xử lý ngoại lệ).

### 1.3 Quy trình đặt trước (Reservation)
- User chọn các quyển sách có trong **danh sách sách được hiển thị** (available list) để đặt trước.
- Phiếu đặt trước sẽ được tính vào tổng số lượng đang mượn/giữ của User (xem mục 1.1).

### 1.4 Gia hạn sách (Renewal)
User được phép gia hạn cho một cuốn sách **khi đồng thời thỏa cả 2 điều kiện**:
1. **book_copy còn tồn kho** (còn bản sao vật lý khả dụng).
2. **Không có phiếu đặt trước nào đang chờ vượt quá số lượng sách tồn kho** — tức là số lượng reservation đang chờ của đầu sách đó không được vượt số bản sao hiện có (nếu vượt, ưu tiên người đang đặt trước, từ chối gia hạn).

```
IF book.available_copies > 0
   AND pending_reservations_count(book) <= book.available_copies
THEN allow_renewal = true
ELSE allow_renewal = false
```

---

## 2. Quy tắc phạt (Fine Rules)

### 2.1 Phạt trễ hạn (Overdue Fine)
```
Overdue Fine = số_ngày_trễ × 5,000 (VND)
```
- **Trần phạt trễ hạn**: không được vượt quá **30% giá trị gốc** của cuốn sách.
  - *Giá trị gốc* = giá mua sách lúc nhập vào hệ thống (**không khấu hao theo thời gian**).

### 2.2 Cơ chế tự động chuyển trạng thái "Hư hỏng"
- Nếu số ngày trễ hạn khiến `Overdue Fine` tính toán được **vượt quá mốc 30% giá trị sách**:
  - Hệ thống **tự động gắn nhãn trạng thái "Hư hỏng"** cho cuốn sách đó.
  - Chuyển sang áp dụng **khung phạt Hư hỏng sách** (mục 2.3) thay vì tiếp tục tính phạt trễ hạn.

```
overdue_fine_raw = so_ngay_tre × 5000
fine_cap = book.original_price × 0.30

IF overdue_fine_raw > fine_cap:
    book.status = "Hư hỏng"
    apply_damage_fine(book)   // xem mục 2.3
ELSE:
    fine_applied = overdue_fine_raw   // đã <= fine_cap, không cần ép trần
```

### 2.3 Phạt hư hỏng & mất sách
| Loại phạt | Mức thu |
|---|---|
| Hư hỏng sách (Damage) | 70% giá trị gốc của sách lúc mua |
| Mất sách (Lost) | 100% giá trị gốc của sách lúc mua |

- Các mức phạt cụ thể **do Thủ thư (Librarian) đánh giá** tình trạng thực tế và **tạo mức phạt** cho người dùng (không hoàn toàn tự động — có bước xác nhận thủ công của thủ thư).

---

## 3. Thông báo hệ thống (System Notifications)

### 3.1 Các sự kiện kích hoạt thông báo
Hệ thống gửi thông báo đến tài khoản người dùng khi xảy ra các sự kiện sau:

| # | Sự kiện | Nội dung thông báo (gợi ý) |
|---|---|---|
| 1 | Nhắc nhở trả sách | Sắp đến / đã đến hạn trả sách |
| 2 | Sách đặt trước đã khả dụng | Sách User đặt trước đã có sẵn để nhận |
| 3 | Thủ thư xác nhận phiếu đặt | Phiếu đặt trước của User đã được thủ thư duyệt |
| 4 | Phát sinh tiền phạt | User bị áp mức phạt (trễ hạn / hư hỏng / mất sách) |
| 5 | Thông báo khóa tài khoản | Tài khoản User bị khóa (do vi phạm, nợ phạt, v.v.) |

Đây là các thông báo **tự động, hệ thống tự sinh** khi trigger event xảy ra (không cần Admin/Librarian soạn tay).

### 3.2 Quy trình tạo & gửi thông báo thủ công
Ngoài các thông báo tự động ở mục 3.1, hệ thống hỗ trợ **Admin & Librarian chủ động soạn thông báo**:

- **Role User**: **chỉ được nhận** thông báo hệ thống, **không có quyền tạo/chỉnh sửa/gửi** thông báo.
- **Role Admin & Librarian**: có quyền:
  1. **Tạo mới** nội dung thông báo (tiêu đề, nội dung, đối tượng nhận: 1 user / nhóm user / toàn bộ).
  2. **Chỉnh sửa** thông báo trước khi gửi (nếu chưa publish).
  3. **Gửi lên hệ thống** (publish) → hệ thống **tự động gửi đến (các) User** liên quan, không cần thao tác thủ công nào thêm từ phía User.

```
Admin/Librarian tạo notification (title, content, target_users)
        ↓
   Lưu nháp / Chỉnh sửa (optional)
        ↓
   Bấm "Gửi" (publish)
        ↓
Hệ thống tự động đẩy notification đến toàn bộ target_users
   (qua notification service/queue, xem mục 5)
```

---

## 4. Phân quyền theo Role (User / Librarian / Admin)

### 4.1 Nguyên tắc thiết kế
- **User**: chỉ thao tác trên **dữ liệu của chính mình** (self-service), không có quyền duyệt/override.
- **Librarian**: xử lý **nghiệp vụ vận hành hàng ngày** — duyệt phiếu, tính/tạo phạt, quản lý tồn kho sách, override cảnh báo vượt ngưỡng mượn — nhưng **không** thay đổi cấu hình hệ thống hay quản lý tài khoản người khác ở cấp hệ thống.
- **Admin**: có toàn bộ quyền của Librarian **+ cấu hình hệ thống** (hạn mức theo hạng, quy tắc phạt, quản lý tài khoản/role, báo cáo tổng).

### 4.2 Ma trận phân quyền

| Chức năng | User | Librarian | Admin |
|---|:---:|:---:|:---:|
| Xem danh sách/tìm kiếm sách | ✅ | ✅ | ✅ |
| Đặt trước sách (Reservation) | ✅ (của mình) | ✅ (thay mặt user nếu cần) | ✅ |
| Hủy phiếu đặt trước | ✅ (của mình) | ✅ (bất kỳ) | ✅ |
| Xem lịch sử mượn/đặt trước/phạt của bản thân | ✅ | ✅ (mình + user khác) | ✅ (toàn hệ thống) |
| Yêu cầu gia hạn sách | ✅ (nếu đủ điều kiện mục 1.4) | ✅ | ✅ |
| Xác nhận/duyệt phiếu đặt trước (Confirm reservation) | ❌ | ✅ | ✅ |
| Check-in / Check-out sách (giao – nhận sách) | ❌ | ✅ | ✅ |
| Duyệt/xử lý trường hợp **vượt ngưỡng 5 quyển** (override cảnh báo) | ❌ | ✅ | ✅ |
| Đánh giá & gắn trạng thái **Hư hỏng / Mất sách** | ❌ | ✅ | ✅ |
| Tạo mức phạt (Overdue / Damage / Lost) | ❌ | ✅ | ✅ |
| Điều chỉnh/miễn giảm phạt (waive fine) | ❌ | ⚠️ Giới hạn theo mức duyệt | ✅ Toàn quyền |
| Xem/thanh toán phạt của bản thân | ✅ | ✅ (ghi nhận thanh toán cho user) | ✅ |
| Khóa/mở khóa tài khoản người dùng | ❌ | ⚠️ Chỉ khóa tạm (VD: nợ phạt quá hạn), không mở khóa | ✅ Toàn quyền khóa/mở |
| Quản lý danh mục sách (thêm/sửa/xóa đầu sách, book_copy) | ❌ | ✅ (nhập/cập nhật tồn kho) | ✅ |
| Cấu hình **hạn mức mượn theo hạng user** (tier limits) | ❌ | ❌ | ✅ |
| Cấu hình **quy tắc phạt** (đơn giá/ngày, % trần, % hư hỏng, % mất) | ❌ | ❌ | ✅ |
| Quản lý tài khoản Librarian/Admin, phân quyền role | ❌ | ❌ | ✅ |
| Nâng/hạ hạng (tier) người dùng | ❌ | ❌ | ✅ |
| Xem báo cáo/thống kê vận hành (lưu thông sách, phạt, top overdue...) | ❌ | ✅ (phạm vi vận hành) | ✅ (toàn hệ thống) |
| Tạo / chỉnh sửa / gửi thông báo hệ thống (thủ công) | ❌ | ✅ | ✅ |
| Nhận thông báo hệ thống (tự động + thủ công) | ✅ | ✅ (nếu là đối tượng nhận) | ✅ (nếu là đối tượng nhận) |

> Chú thích: ✅ = toàn quyền · ❌ = không có quyền · ⚠️ = có quyền nhưng giới hạn/cần điều kiện

### 4.3 Ghi chú áp dụng vào các quy tắc đã nêu
- Mục **1.2** ("Thủ thư hoặc Admin đưa ra quyết định cuối cùng" khi vượt ngưỡng mượn) → cả 2 role đều có quyền override, nhưng nên **log lại ai là người duyệt** (audit trail) vì đây là hành vi ngoại lệ.
- Mục **2.3** ("mức phạt do Thủ thư đánh giá và tạo") → Librarian có quyền **tạo** phạt Damage/Lost, nhưng **quy tắc tính % (30/70/100)** chỉ Admin được sửa cấu hình, tránh Librarian tùy ý đổi công thức.
- Notification #3 "Thủ thư xác nhận phiếu đặt" → hành động **confirm** chỉ Librarian/Admin thực hiện được, khớp với dòng "Xác nhận/duyệt phiếu đặt trước" trong ma trận.
- Notification #5 "Khóa tài khoản" → nên giới hạn: Librarian chỉ **khóa tạm thời** (ví dụ do nợ phạt/quá hạn nhiều lần), còn **mở khóa** và **khóa vĩnh viễn** thuộc quyền Admin để tránh lạm quyền.
- Thông báo thủ công (mục 3.2): **User tuyệt đối không có quyền tạo/sửa/gửi**, chỉ là bên nhận. Admin & Librarian ngang quyền nhau trong việc soạn và gửi thông báo — không cần phân biệt cấp duyệt vì đây là kênh thông tin, không phải hành vi ảnh hưởng tài chính/kho sách.

---

## 5. Ghi chú cho agent triển khai

- Cần bảng cấu hình **hạn mức mượn theo hạng user** (`tier_borrow_limits`).
- Cần trạng thái phiếu mượn/đặt trước rõ ràng: `Đặt trước / Đang mượn / Quá hạn / Hư hỏng / Mất / Đã trả`.
- Cần cờ phân quyền cho **Librarian/Admin** để override cảnh báo vượt ngưỡng số lượng mượn.
- Logic tính phạt cần chạy theo lịch (cron/job) để tự động phát hiện quá hạn và tự chuyển trạng thái "Hư hỏng" khi vượt trần 30%, đồng thời trigger notification #4.
- Notification nên là 1 service/queue riêng, trigger theo sự kiện (event-driven) từ các module: Reservation, Borrowing, Fine, Account.
- Nên triển khai phân quyền theo **RBAC** (Role-Based Access Control) với 3 role cố định `USER / LIBRARIAN / ADMIN`, kèm middleware/guard kiểm tra quyền ở tầng API cho từng endpoint theo ma trận mục 4.2.
- Mọi hành động override/duyệt ngoại lệ (vượt ngưỡng mượn, tạo phạt, khóa/mở tài khoản) cần có **audit log** (ai thực hiện, thời gian, lý do) để tra soát sau này.
