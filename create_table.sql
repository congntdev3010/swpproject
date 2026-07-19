create table authors
(
    id          int auto_increment
        primary key,
    name        varchar(150)                         not null,
    nationality varchar(100)                         null,
    birth_date  date                                 null,
    bio         text                                 null,
    avatar_url  varchar(500)                         null,
    created_at  datetime   default CURRENT_TIMESTAMP not null,
    updated_at  datetime   default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment 'Thá»�i gian cáº­p nháº­t gáº§n nháº¥t',
    is_deleted  tinyint(1) default 0                 not null comment 'Soft delete: 0 = active, 1 = deleted',
    created_by  varchar(50)                          null comment 'TÃ i khoáº£n táº¡o báº£n ghi',
    updated_by  varchar(50)                          null comment 'TÃ i khoáº£n cáº­p nháº­t gáº§n nháº¥t',
    constraint uq_authors_name
        unique (name)
);

create index idx_authors_is_deleted
    on authors (is_deleted);

create index idx_authors_name
    on authors (name);

create table book_copy_logs
(
    id            int auto_increment
        primary key,
    copy_id       int                                not null,
    action        varchar(20)                        not null,
    changed_by    varchar(50)                        not null,
    old_status    varchar(20)                        null,
    new_status    varchar(20)                        null,
    old_condition varchar(20)                        null,
    new_condition varchar(20)                        null,
    note          varchar(255)                       null,
    created_at    datetime default CURRENT_TIMESTAMP null
);

create table categories
(
    id          int auto_increment
        primary key,
    name        varchar(100)                         not null,
    description varchar(500)                         null,
    created_at  datetime   default CURRENT_TIMESTAMP not null,
    updated_at  datetime   default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    is_deleted  tinyint(1) default 0                 not null comment 'Soft delete: 0 = active, 1 = deleted',
    created_by  varchar(50)                          null comment 'TÃ i khoáº£n táº¡o báº£n ghi',
    updated_by  varchar(50)                          null comment 'TÃ i khoáº£n cáº­p nháº­t gáº§n nháº¥t',
    constraint uq_categories_name
        unique (name)
);

create table books
(
    id           int auto_increment
        primary key,
    isbn         varchar(20)                          not null,
    title        varchar(255)                         not null,
    category     varchar(50)                          not null,
    category_id  int                                  null,
    publisher    varchar(150)                         null,
    publish_year int                                  null,
    price        int        default 100000            null,
    quantity     int        default 0                 not null,
    available    int        default 0                 not null,
    description  text                                 null,
    cover_image  varchar(500)                         null,
    subject      varchar(100)                         null comment 'Môn học liên quan (Toán, Vật lý, CNTT...)',
    area         varchar(50)                          null comment 'Khu vực (Tầng 1, Tầng 2...)',
    shelf        varchar(20)                          null comment 'Kệ (K01, K02...)',
    slot         varchar(20)                          null comment 'Ngăn (N01, N02...)',
    created_at   datetime   default CURRENT_TIMESTAMP not null,
    updated_at   datetime   default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    is_deleted   tinyint(1) default 0                 not null comment 'Soft delete: 0 = active, 1 = deleted',
    created_by   varchar(50)                          null comment 'Tài khoản tạo bản ghi',
    updated_by   varchar(50)                          null comment 'Tài khoản cập nhật gần nhất',
    constraint uq_books_isbn
        unique (isbn),
    constraint fk_books_category
        foreign key (category_id) references categories (id)
            on update cascade on delete set null,
    constraint chk_available
        check ((`available` >= 0) and (`available` <= `quantity`)),
    constraint chk_quantity
        check (`quantity` >= 0)
);

create table book_authors
(
    book_id   int                                                                     not null,
    author_id int                                                                     not null,
    role      enum ('PRIMARY', 'CO_AUTHOR', 'TRANSLATOR', 'EDITOR') default 'PRIMARY' not null,
    primary key (book_id, author_id),
    constraint fk_ba_author
        foreign key (author_id) references authors (id)
            on update cascade,
    constraint fk_ba_book
        foreign key (book_id) references books (id)
            on update cascade on delete cascade
);

create index idx_ba_author
    on book_authors (author_id);

create table book_copies
(
    id             int auto_increment
        primary key,
    book_id        int                                                                                         not null,
    barcode        varchar(50)                                                                                 not null comment 'Mã vạch từng bản sao vật lý',
    book_condition enum ('GOOD', 'WORN', 'DAMAGED', 'LOST')                          default 'GOOD'            not null,
    status         enum ('AVAILABLE', 'BORROWED', 'RESERVED', 'MAINTENANCE', 'LOST') default 'AVAILABLE'       not null,
    note           text                                                                                        null,
    created_at     datetime                                                          default CURRENT_TIMESTAMP not null,
    updated_at     datetime                                                          default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    is_deleted     tinyint(1)                                                        default 0                 not null comment 'Soft delete: 0 = active, 1 = deleted',
    created_by     varchar(50)                                                                                 null comment 'Tài khoản thêm bản sao',
    updated_by     varchar(50)                                                                                 null comment 'Tài khoản cập nhật gần nhất',
    area           varchar(50)                                                                                 null comment 'Khu vực (Tầng 1, Tầng 2...)',
    shelf          varchar(20)                                                                                 null comment 'Kệ (K01, K02...)',
    slot           varchar(20)                                                                                 null comment 'Ngăn (N01, N02...)',
    constraint uq_copy_barcode
        unique (barcode),
    constraint fk_copy_book
        foreign key (book_id) references books (id)
            on update cascade on delete cascade
);

create index idx_copies_is_deleted
    on book_copies (is_deleted);

create index idx_copy_barcode
    on book_copies (barcode);

create index idx_copy_book
    on book_copies (book_id);

create index idx_copy_status
    on book_copies (status);

create index idx_books_category
    on books (category);

create index idx_books_category_id
    on books (category_id);

create index idx_books_is_deleted
    on books (is_deleted);

create index idx_books_subject
    on books (subject);

create index idx_books_title
    on books (title);

create index idx_categories_is_deleted
    on categories (is_deleted);

create table membership_tiers
(
    id                       int auto_increment
        primary key,
    name                     varchar(50)                                   not null,
    level                    enum ('BRONZE', 'SILVER', 'GOLD', 'PLATINUM') not null,
    min_books_borrowed       int           default 0                       not null,
    max_borrow_days          int           default 14                      not null,
    max_simultaneous_borrows int           default 3                       not null,
    fine_discount_percent    decimal(5, 2) default 0.00                    not null,
    benefits_description     text                                          null,
    constraint uq_membership_tier_level
        unique (level)
);

create table users
(
    id         int auto_increment
        primary key,
    username   varchar(50)                                                     not null,
    password   varchar(255)                                                    not null,
    full_name  varchar(100)                                                    not null,
    email      varchar(100)                                                    not null,
    phone      varchar(15)                                                     null,
    student_id varchar(20)                                                     null comment 'MSSV hoặc mã định danh sinh viên',
    avatar     varchar(255)                                                    null,
    role       enum ('ADMIN', 'LIBRARIAN', 'READER') default 'READER'          not null,
    active     tinyint(1)                            default 1                 not null,
    created_at datetime                              default CURRENT_TIMESTAMP not null,
    updated_at datetime                              default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint uq_users_student_id
        unique (student_id),
    constraint uq_users_username
        unique (username)
);

create table book_reservations
(
    id           int auto_increment
        primary key,
    book_id      int                                                                                      not null,
    user_id      int                                                                                      not null,
    reserve_date datetime                                                       default CURRENT_TIMESTAMP not null,
    expiry_date  datetime                                                                                 null,
    status       enum ('PENDING', 'READY', 'COMPLETED', 'CANCELLED', 'EXPIRED') default 'PENDING'         not null,
    notified_at  datetime                                                                                 null,
    created_at   datetime                                                       default CURRENT_TIMESTAMP not null,
    updated_at   datetime                                                       default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint fk_reservations_book
        foreign key (book_id) references books (id)
            on update cascade on delete cascade,
    constraint fk_reservations_user
        foreign key (user_id) references users (id)
            on update cascade on delete cascade
);

create index idx_reservations_book
    on book_reservations (book_id);

create index idx_reservations_status
    on book_reservations (status);

create index idx_reservations_user
    on book_reservations (user_id);

create table book_reviews
(
    id         int auto_increment
        primary key,
    book_id    int                                not null,
    user_id    int                                not null,
    rating     tinyint                            not null,
    comment    text                               null,
    created_at datetime default CURRENT_TIMESTAMP not null,
    updated_at datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint uq_review_book_user
        unique (book_id, user_id),
    constraint fk_reviews_book
        foreign key (book_id) references books (id)
            on update cascade on delete cascade,
    constraint fk_reviews_user
        foreign key (user_id) references users (id)
            on update cascade on delete cascade,
    constraint chk_rating
        check ((`rating` >= 1) and (`rating` <= 5))
);

create index idx_reviews_book
    on book_reviews (book_id);

create index idx_reviews_user
    on book_reviews (user_id);

create table borrow_records
(
    id            int auto_increment
        primary key,
    user_id       int                                                                         not null,
    book_id       int                                                                         not null,
    copy_id       int                                                                         null comment 'Bản sao vật lý cụ thể được mượn',
    borrow_date   date                                                                        not null,
    due_date      date                                                                        not null,
    return_date   date                                                                        null,
    renewal_count int                                               default 0                 not null comment 'Số lần đã gia hạn',
    status        enum ('BORROWING', 'RETURNED', 'OVERDUE', 'LOST') default 'BORROWING'       not null,
    note          text                                                                        null,
    created_at    datetime                                          default CURRENT_TIMESTAMP not null,
    updated_at    datetime                                          default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint fk_borrow_book
        foreign key (book_id) references books (id)
            on update cascade,
    constraint fk_borrow_copy
        foreign key (copy_id) references book_copies (id)
            on update cascade on delete set null,
    constraint fk_borrow_user
        foreign key (user_id) references users (id)
            on update cascade,
    constraint chk_renewal
        check (`renewal_count` >= 0)
);

create index idx_borrow_book
    on borrow_records (book_id);

create index idx_borrow_copy
    on borrow_records (copy_id);

create index idx_borrow_due
    on borrow_records (due_date);

create index idx_borrow_status
    on borrow_records (status);

create index idx_borrow_user
    on borrow_records (user_id);

create table fines
(
    id               int auto_increment
        primary key,
    borrow_record_id int                                                                           not null,
    user_id          int                                                                           not null,
    amount           decimal                                             default 0                 not null,
    overdue_days     int                                                 default 0                 not null,
    reason           varchar(500)                                                                  null,
    status           enum ('UNPAID', 'PENDING_VERIFY', 'PAID', 'WAIVED') default 'UNPAID'          not null,
    payment_method   enum ('CASH', 'ONLINE')                             default 'CASH'            not null,
    payment_note     varchar(255)                                                                  null,
    paid_date        date                                                                          null,
    created_at       datetime                                            default CURRENT_TIMESTAMP not null,
    updated_at       datetime                                            default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint fk_fines_borrow
        foreign key (borrow_record_id) references borrow_records (id)
            on update cascade on delete cascade,
    constraint fk_fines_user
        foreign key (user_id) references users (id)
            on update cascade on delete cascade
);

create index idx_fines_borrow
    on fines (borrow_record_id);

create index idx_fines_status
    on fines (status);

create index idx_fines_user
    on fines (user_id);

create table notifications
(
    id             int auto_increment
        primary key,
    user_id        int                                                                                         not null,
    title          varchar(255)                                                                                not null,
    message        text                                                                                        not null,
    type           enum ('DUE_REMINDER', 'OVERDUE', 'FINE', 'RESERVATION', 'SYSTEM') default 'SYSTEM'          not null,
    is_read        tinyint(1)                                                        default 0                 not null,
    reference_id   int                                                                                         null,
    reference_type varchar(50)                                                                                 null,
    created_at     datetime                                                          default CURRENT_TIMESTAMP not null,
    constraint fk_notif_user
        foreign key (user_id) references users (id)
            on update cascade on delete cascade
);

create index idx_notif_created
    on notifications (created_at);

create index idx_notif_read
    on notifications (is_read);

create index idx_notif_user
    on notifications (user_id);

create table user_memberships
(
    id                   int auto_increment
        primary key,
    user_id              int                                not null,
    tier_id              int                                not null,
    total_books_borrowed int      default 0                 not null,
    tier_achieved_at     date     default (curdate())       not null,
    updated_at           datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint uq_um_user
        unique (user_id),
    constraint fk_um_tier
        foreign key (tier_id) references membership_tiers (id)
            on update cascade,
    constraint fk_um_user
        foreign key (user_id) references users (id)
            on update cascade on delete cascade
);

create table user_tokens
(
    id         int auto_increment
        primary key,
    user_id    int                                     not null,
    token      varchar(255)                            not null,
    type       enum ('REGISTRATION', 'RESET_PASSWORD') not null,
    expiry     datetime                                not null,
    created_at datetime default CURRENT_TIMESTAMP      not null,
    constraint uq_user_token
        unique (token),
    constraint fk_token_user
        foreign key (user_id) references users (id)
            on delete cascade
);

create index idx_user_tokens_token
    on user_tokens (token);

create index idx_user_tokens_user
    on user_tokens (user_id);

create index idx_users_role
    on users (role);

create index idx_users_student_id
    on users (student_id);

create index idx_users_username
    on users (username);

